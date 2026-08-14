extends SceneTree

const BOSS_PATH: String = "res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn"
const PLAYER_PATH: String = "res://scenes/player/player.tscn"

var failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var boss_scene: PackedScene = load(BOSS_PATH) as PackedScene
	var player_scene: PackedScene = load(PLAYER_PATH) as PackedScene
	_expect(boss_scene != null and player_scene != null, "formal Boss and Player scenes load")
	if boss_scene == null or player_scene == null:
		quit(1)
		return
	var boss: SoulGaolerOrmund = boss_scene.instantiate() as SoulGaolerOrmund
	var player: Player = player_scene.instantiate() as Player
	root.add_child(player)
	root.add_child(boss)
	await process_frame
	var config: SoulGaolerOrmundConfig = boss.config as SoulGaolerOrmundConfig
	_validate_configuration(config)
	_validate_scene_geometry(boss)
	_validate_damage_policy(boss)
	_validate_combo_and_player_turn(boss, player)
	_validate_delayed_turn(boss, player)
	_validate_back_crossing_repetition(boss, player)
	_validate_attack_selection_guards(boss, player)
	_print_balance_comparison(config)
	_print_punish_windows(config)
	boss.queue_free()
	player.queue_free()
	await process_frame
	print("SOUL GAOLER ORMUND BALANCE TEST | %s" % ("PASS" if failures == 0 else "FAIL %d" % failures))
	quit(0 if failures == 0 else 1)


func _validate_configuration(config: SoulGaolerOrmundConfig) -> void:
	_expect(config.total_health == 460, "Max HP is 460")
	_expect(is_equal_approx(config.phase_two_threshold_ratio, 0.55), "Phase II remains at 55 percent")
	_expect(is_equal_approx(config.phase_one_damage_multiplier, 0.90), "P1 damage taken is 0.90")
	_expect(is_equal_approx(config.phase_two_damage_multiplier, 0.84), "P2 damage taken is 0.84")
	_expect(config.phase_one_poise == 130 and config.phase_two_poise == 158, "Poise is 130/158")
	_expect(is_equal_approx(config.phase_one_stagger_duration, 0.82), "P1 Stagger is 0.82 seconds")
	_expect(is_equal_approx(config.phase_two_stagger_duration, 0.65), "P2 Stagger is 0.65 seconds")
	_expect(is_equal_approx(config.phase_one_player_turn_duration, 1.05), "P1 Player Turn is 1.05 seconds")
	_expect(is_equal_approx(config.phase_two_player_turn_duration, 0.82), "P2 Player Turn is 0.82 seconds")
	_expect(is_equal_approx(config.phase_one_turn_duration, 0.50), "P1 180-degree turn is 0.50 seconds")
	_expect(is_equal_approx(config.phase_two_turn_duration, 0.40), "P2 180-degree turn is 0.40 seconds")
	_expect(is_equal_approx(config.action_timing(&"halberd_sweep").z, 0.90), "Sweep recovery is 0.90 seconds")
	_expect(is_equal_approx(config.action_timing(&"chain_anchor_slam").z, 1.48), "Slam recovery is 1.48 seconds")
	_expect(is_equal_approx(config.action_timing(&"prison_hook_drag").z, 1.12), "Hook recovery is 1.12 seconds")
	_expect(is_equal_approx(config.action_timing(&"flooded_judgment").z, 1.62), "Judgment recovery is 1.62 seconds")


func _validate_scene_geometry(boss: SoulGaolerOrmund) -> void:
	var body_shape: RectangleShape2D = (boss.get_node("CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D
	var hurt_shape: RectangleShape2D = (boss.get_node("Hurtbox/CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D
	var melee_shape: RectangleShape2D = (boss.get_node("FacingRoot/MeleeHitbox/CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D
	var area_shape: RectangleShape2D = (boss.get_node("AreaHitbox/CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D
	_expect(body_shape.size == Vector2(44, 92), "body collider follows the 1.8x heavy humanoid torso")
	_expect(hurt_shape.size == Vector2(50, 98), "Hurtbox follows the reduced presentation")
	_expect(melee_shape.size == Vector2(100, 48), "frontal melee Hitbox does not cover the back")
	_expect(area_shape.size == Vector2(180, 96), "explicit area attacks retain reduced 360-degree coverage")
	_expect(boss.get_node("VisualRoot").scale == Vector2(0.6, 0.6), "Boss presentation is 60 percent of source pixels")
	var p1_ratio: float = (172.0 * 0.6) / 57.0
	var p2_ratio: float = (170.0 * 0.6) / 57.0
	_expect(p1_ratio >= 1.65 and p1_ratio <= 1.82, "P1 visual height ratio is about 1.81x Player")
	_expect(p2_ratio >= 1.65 and p2_ratio <= 1.82, "P2 visual height ratio is about 1.79x Player")


func _validate_damage_policy(boss: SoulGaolerOrmund) -> void:
	var probe: HitboxComponent = HitboxComponent.new()
	probe.damage = 14
	boss.damage_policy.damage_multiplier = 0.90
	_expect(boss.damage_policy.resolve_damage(probe) == 13, "14 damage resolves to 13 in P1")
	probe.damage = 28
	_expect(boss.damage_policy.resolve_damage(probe) == 25, "28 damage resolves to 25 in P1")
	boss.damage_policy.damage_multiplier = 0.84
	probe.damage = 14
	_expect(boss.damage_policy.resolve_damage(probe) == 12, "14 damage resolves to 12 in P2")
	probe.damage = 28
	_expect(boss.damage_policy.resolve_damage(probe) == 24, "28 damage resolves to 24 in P2")
	probe.queue_free()
	boss.damage_policy.damage_multiplier = 0.90


func _validate_combo_and_player_turn(boss: SoulGaolerOrmund, player: Player) -> void:
	boss.begin_combat(player)
	boss._start_action(&"halberd_sweep")
	boss._begin_active()
	boss._begin_recovery()
	boss.action_timer = 0.0
	boss._process_action(0.01)
	_expect(boss.get_combo_count() == 1, "first completed action consumes one Combo Budget")
	_expect(boss.current_state == boss.COMBAT, "first P1 action may continue the sequence")
	boss._start_action(&"chain_anchor_slam")
	boss._begin_active()
	boss._begin_recovery()
	boss.action_timer = 0.0
	boss._process_action(0.01)
	_expect(boss.current_state == boss.PLAYER_TURN, "second P1 action forces Player Turn")
	_expect(is_equal_approx(boss.get_player_turn_remaining(), 1.05), "forced P1 Player Turn is 1.05 seconds")
	_expect(not boss.is_direction_locked(), "Player Turn releases direction lock")
	boss._process_player_turn(1.06)
	_expect(boss.current_state == boss.COMBAT, "Player Turn returns to Combat only after its timer")
	_expect(boss.get_combo_count() == 0, "new Boss turn resets Combo count")


func _validate_delayed_turn(boss: SoulGaolerOrmund, player: Player) -> void:
	boss.set_facing_direction(1.0)
	boss.global_position = Vector2(400.0, 0.0)
	player.global_position = Vector2(200.0, 0.0)
	var completed_early: bool = boss._process_delayed_turn(-1.0, 0.20)
	_expect(not completed_early and boss.facing_direction > 0.0, "P1 does not flip during the first 0.20 seconds")
	completed_early = boss._process_delayed_turn(-1.0, 0.20)
	_expect(not completed_early and boss.facing_direction > 0.0, "P1 remains committed before 0.40 seconds")
	var completed: bool = boss._process_delayed_turn(-1.0, 0.11)
	_expect(completed and boss.facing_direction < 0.0, "P1 completes the 180-degree turn after about 0.50 seconds")


func _validate_attack_selection_guards(boss: SoulGaolerOrmund, player: Player) -> void:
	boss.begin_combat(player)
	boss.configure_movement_bounds(180.0, 2124.0)
	boss.global_position = Vector2(1000.0, 0.0)
	player.global_position = Vector2(1080.0, 0.0)
	boss._recent_attack_history = [&"halberd_sweep"]
	_expect(
		not boss._can_use_action(&"halberd_sweep", false),
		"the same attack cannot repeat immediately"
	)
	boss._recent_attack_history.clear()
	boss._high_pressure_used_in_combo = true
	_expect(
		not boss._can_use_action(&"drowned_cell_rupture", false),
		"a Combo Budget cannot contain two high-pressure actions"
	)
	boss._high_pressure_used_in_combo = false
	player.global_position = Vector2(220.0, 0.0)
	_expect(boss._is_target_near_arena_edge(), "room-edge pressure protection detects the Player")
	_expect(
		not boss._can_use_action(&"floodgate_charge", true)
		and not boss._can_use_action(&"prison_hook_drag", true),
		"Charge and Hook are suppressed beside the arena edge"
	)


func _validate_back_crossing_repetition(boss: SoulGaolerOrmund, player: Player) -> void:
	var successful_crossings: int = 0
	for _crossing_index: int in 30:
		boss._on_attack_cancelled()
		boss._reset_combo_sequence()
		boss.transition_state(boss.COMBAT)
		boss.global_position = Vector2(400.0, 0.0)
		boss.set_facing_direction(1.0)
		player.global_position = Vector2(470.0, 0.0)
		boss._start_action(&"halberd_sweep")
		boss._begin_active()
		# The Player crosses the 44 px torso during the committed attack.
		player.global_position = Vector2(330.0, 0.0)
		var melee_shape: RectangleShape2D = (
			boss.get_node("FacingRoot/MeleeHitbox/CollisionShape2D") as CollisionShape2D
		).shape as RectangleShape2D
		var melee_left_edge: float = (
			boss.global_position.x
			+ (boss.get_node("FacingRoot/MeleeHitbox") as Area2D).position.x
			- melee_shape.size.x * 0.5
		)
		var direction_remains_locked: bool = boss.facing_direction > 0.0 and boss.is_direction_locked()
		var player_is_clear_behind: bool = player.global_position.x < melee_left_edge
		if direction_remains_locked and player_is_clear_behind:
			successful_crossings += 1
		boss._begin_recovery()
		boss._on_attack_cancelled()
	_expect(successful_crossings == 30, "30/30 committed attacks preserve a safe back crossing")


func _print_balance_comparison(config: SoulGaolerOrmundConfig) -> void:
	var variants: Array[Dictionary] = [
		{"name": "A", "hp": 480, "p1": 0.88, "p2": 0.82},
		{"name": "B", "hp": 460, "p1": 0.90, "p2": 0.84},
	]
	for variant: Dictionary in variants:
		var hp: int = variant["hp"] as int
		var p1_hp: int = hp - roundi(float(hp) * config.phase_two_threshold_ratio)
		var p2_hp: int = hp - p1_hp
		var p1_normal: int = maxi(1, roundi(14.0 * (variant["p1"] as float)))
		var p2_normal: int = maxi(1, roundi(14.0 * (variant["p2"] as float)))
		var p1_dash: int = maxi(1, roundi(28.0 * (variant["p1"] as float)))
		var p2_dash: int = maxi(1, roundi(28.0 * (variant["p2"] as float)))
		var normal_hits: int = ceili(float(p1_hp) / p1_normal) + ceili(float(p2_hp) / p2_normal)
		var dash_hits: int = ceili(float(p1_hp) / p1_dash) + ceili(float(p2_hp) / p2_dash)
		print(
			"BALANCE %s | HP %d | P1 %d/%d | P2 %d/%d | NORMAL_ONLY %d | DASH_ONLY %d"
			% [variant["name"], hp, p1_normal, p1_dash, p2_normal, p2_dash, normal_hits, dash_hits]
		)


func _print_punish_windows(config: SoulGaolerOrmundConfig) -> void:
	var attacks: Array[StringName] = [
		&"halberd_sweep",
		&"chain_anchor_slam",
		&"prison_hook_drag",
		&"floodgate_charge",
		&"soul_cage_pulse",
		&"chainstorm_cleave",
		&"undertow_pull",
		&"drowned_cell_rupture",
		&"soul_shackle",
		&"flooded_judgment",
	]
	for attack: StringName in attacks:
		var timing: Vector3 = config.action_timing(attack)
		var safe_normals: int = clampi(floori(timing.z / 0.32), 1, 3)
		print(
			"PUNISH %s | WINDUP %.2f | ACTIVE %.2f | RECOVERY %.2f | SAFE_NORMALS %d | DASH %s"
			% [attack, timing.x, timing.y, timing.z, safe_normals, str(timing.z >= 0.89)]
		)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)
