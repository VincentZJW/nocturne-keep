extends SceneTree

const TEST_ROOM: String = "res://chapters/chapter_02_silent_court/scenes/tests/hollow_duchess_test_room.tscn"
const ATTACKS: Array[StringName] = [
	&"rapier_thrust", &"fan_slash", &"backstep_riposte", &"side_step_cut",
	&"double_waltz_lunge", &"phantom_dancer_sweep", &"final_waltz_crossing",
]

var _failures: Array[String] = []
var _started_counts: Dictionary[StringName, int] = {}
var _active_counts: Dictionary[StringName, int] = {}
var _finished_counts: Dictionary[StringName, int] = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 12.0
	var packed: PackedScene = ResourceLoader.load(TEST_ROOM, "PackedScene") as PackedScene
	if packed == null:
		_fail("Boss test room does not load")
		_finish()
		return
	var room: Node = packed.instantiate()
	root.add_child(room)
	current_scene = room
	for _frame: int in range(12):
		await physics_frame
	var boss: HollowDuchess = room.get_node_or_null("HollowDuchess") as HollowDuchess
	var player: Player = room.get_node_or_null("Player") as Player
	if boss == null or player == null:
		_fail("Boss or Player is missing from standalone test room")
		_finish()
		return
	# Keep the target alive so the deterministic 70-cycle attack audit tests
	# Seraphine's state machine instead of eventually idling on a dead player.
	player.hurtbox.set_invulnerable(true)
	boss.attack_started.connect(_on_attack_started)
	boss.attack_active.connect(_on_attack_active)
	boss.attack_finished.connect(_on_attack_finished)
	_validate_config(boss)
	await _wait_until_combat_ready(boss)
	for attack_name: StringName in ATTACKS:
		for _iteration: int in range(10):
			if not boss.debug_force_attack(attack_name):
				_fail("Could not force %s" % attack_name)
				continue
			await _wait_for_attack_completion(boss, attack_name)
		print("HOLLOW_DUCHESS_ATTACK_CYCLES: %s x10" % attack_name)
		if _started_counts.get(attack_name, 0) != 10:
			_fail("%s start count != 10" % attack_name)
		if _active_counts.get(attack_name, 0) < 10:
			_fail("%s active count < 10" % attack_name)
		if _finished_counts.get(attack_name, 0) != 10:
			_fail("%s finish count != 10" % attack_name)
	await _validate_phase_and_poise(boss, player)
	Engine.time_scale = 1.0
	_finish()


func _validate_config(boss: HollowDuchess) -> void:
	var config: HollowDuchessConfig = boss.config
	_expect(is_equal_approx(boss.BEHAVIOR_REACTION_DELAY, 0.28), "Duchess behavior reaction delay must be 0.28s")
	_expect(boss.get_behavior_pressures().size() == 6, "Duchess exposes six decaying behavior pressures")
	var base_curtain: float = boss._adaptive_attack_multiplier(boss.ATTACK_SIDE_CUT)
	boss.crossup_pressure = 0.8
	var learned_curtain: float = boss._adaptive_attack_multiplier(boss.ATTACK_SIDE_CUT)
	_expect(learned_curtain > base_curtain, "Silk Curtain responds to delayed cross-up pressure")
	_expect(learned_curtain <= 2.65, "Duchess adaptive weighting remains capped")
	boss._reset_behavior_context()
	_expect(config.max_health == 220, "max HP must be 220")
	_expect(is_equal_approx(config.phase_2_threshold, 0.55), "phase threshold must be 55%")
	_expect(config.max_poise == 60, "max Poise must be 60")
	_expect(config.phase_2_max_poise == 80, "Phase 2 max Poise must be 80")
	_expect(is_equal_approx(config.phase_2_incoming_damage_multiplier, 0.85), "Phase 2 mitigation mismatch")
	_expect(is_equal_approx(boss.get_turn_total_duration(), 0.58), "turn total must be 0.58s")
	_expect(config.rapier_thrust_damage == 11, "Rapier damage mismatch")
	_expect(config.fan_slash_damage == 13, "Fan damage mismatch")
	_expect(config.riposte_damage == 12, "Riposte damage mismatch")
	_expect(config.side_step_cut_damage == 12, "Side Cut damage mismatch")
	_expect(config.phase_2_rapier_thrust_damage == 13, "Phase 2 Rapier damage mismatch")
	_expect(config.phase_2_fan_slash_damage == 16, "Phase 2 Fan damage mismatch")
	_expect(config.phase_2_riposte_damage == 14, "Phase 2 Riposte damage mismatch")
	_expect(config.phase_2_side_step_cut_damage == 14, "Phase 2 Side Cut damage mismatch")
	_expect(config.double_lunge_damage_1 == 10 and config.double_lunge_damage_2 == 14, "Double Lunge damage mismatch")
	_expect(config.phantom_damage == 12, "Phantom damage mismatch")
	_expect(config.final_waltz_damage == 10, "Final Waltz damage mismatch")
	_expect(config.rapier_thrust_windup >= 0.46 and config.rapier_thrust_recovery >= 0.60, "Rapier timing mismatch")
	_expect(config.fan_slash_windup >= 0.54 and config.fan_slash_recovery >= 0.72, "Fan timing mismatch")
	_expect(config.phase_1_min_attack_gap >= 0.84, "Phase 1 gap too short")
	_expect(is_equal_approx(config.phase_2_min_attack_gap, 0.82), "Phase 2 minimum gap mismatch")
	_expect(is_equal_approx(config.phase_2_max_attack_gap, 1.02), "Phase 2 maximum gap mismatch")


func _wait_until_combat_ready(boss: HollowDuchess) -> void:
	for _frame: int in range(240):
		await physics_frame
		if boss.get_state_name() not in [&"Dormant", &"Intro"]:
			return
	_fail("Boss did not leave Intro")


func _wait_for_attack_completion(boss: HollowDuchess, attack_name: StringName) -> void:
	var observed_start: bool = false
	for _frame: int in range(720):
		await physics_frame
		if boss.get_current_attack() == attack_name:
			observed_start = true
		if observed_start and boss.get_current_attack().is_empty():
			return
	_fail("%s did not complete" % attack_name)


func _validate_phase_and_poise(boss: HollowDuchess, player: Player) -> void:
	boss.reset_boss()
	boss.config.intro_retry_duration = 0.05
	boss.activate(player, true)
	await _wait_until_combat_ready(boss)
	boss.debug_set_health(121)
	for _frame: int in range(180):
		await physics_frame
		if boss.get_phase() == 2:
			break
	_expect(boss.get_phase() == 2, "Phase 2 did not activate at 121 HP")
	_expect(boss.health_component.current_health == 121, "Phase transition restored HP")
	_expect(boss.get_current_poise() == 80, "Phase 2 Poise did not increase to 80")
	_expect(boss.is_phase_transition_completed(), "Phase transition completion flag missing")
	var mitigation_probe: HitboxComponent = HitboxComponent.new()
	mitigation_probe.damage = 20
	_expect(boss.hurtbox.hit_policy.resolve_damage(mitigation_probe) == 17, "Phase 2 damage reduction is not 15%")
	mitigation_probe.queue_free()
	boss.reset_boss()
	boss.config.intro_retry_duration = 0.05
	boss.activate(player, true)
	await _wait_until_combat_ready(boss)
	var normal_hit: HitboxComponent = HitboxComponent.new()
	normal_hit.attack_kind = &"normal_attack"
	for index: int in range(6):
		boss._on_hit_resolving(normal_hit)
		boss._on_hit_received(12, player.global_position, 100 + index)
	_expect(boss.get_current_poise() == 0, "Six normal attacks should exhaust 60 Poise")
	_expect(boss.get_state_name() == &"Stagger", "Poise exhaustion did not enter Stagger")
	for _frame: int in range(10):
		await physics_frame
	_expect(boss.get_current_poise() == 60, "Poise did not restore after Stagger")
	normal_hit.queue_free()


func _on_attack_started(attack_name: StringName) -> void:
	_started_counts[attack_name] = _started_counts.get(attack_name, 0) + 1


func _on_attack_active(attack_name: StringName, _attack_id: int) -> void:
	_active_counts[attack_name] = _active_counts.get(attack_name, 0) + 1


func _on_attack_finished(attack_name: StringName) -> void:
	_finished_counts[attack_name] = _finished_counts.get(attack_name, 0) + 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("HOLLOW_DUCHESS_BOSS_TEST: PASS attacks=7 iterations=70 phase=2 poise=60")
		quit(0)
		return
	for failure: String in _failures:
		push_error("HOLLOW_DUCHESS_BOSS_TEST: %s" % failure)
	quit(1)
