extends SceneTree

## Deterministic full-fight replay against the production Boss scene.
##
## The replay does not replace human feel testing.  It drives the real
## Health/Hurtbox/DamagePolicy/Poise chain with the pre-Boss 14/28 weapon values
## and uses the production attack timelines to produce comparable telemetry.

const BOSS_PATH: String = "res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn"
const PLAYER_PATH: String = "res://scenes/player/player.tscn"

const P1_ACTIONS: Array[StringName] = [
	&"halberd_sweep",
	&"chain_anchor_slam",
	&"prison_hook_drag",
	&"floodgate_charge",
	&"soul_cage_pulse",
]
const P2_ACTIONS: Array[StringName] = [
	&"chainstorm_cleave",
	&"undertow_pull",
	&"drowned_cell_rupture",
	&"soul_shackle",
	&"flooded_judgment",
]

var _failures: PackedStringArray = []
var _attack_id: int = 1000


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var initial: Dictionary = await _replay_fight(
		&"INITIAL_STANDARD", 560, 0.82, 0.72, &"standard"
	)
	var standard: Dictionary = await _replay_fight(
		&"FINAL_STANDARD", 500, 0.87, 0.80, &"standard"
	)
	var conservative_a: Dictionary = await _replay_fight(
		&"FINAL_CONSERVATIVE_A", 500, 0.87, 0.80, &"conservative"
	)
	var conservative_b: Dictionary = await _replay_fight(
		&"FINAL_CONSERVATIVE_B", 500, 0.87, 0.80, &"conservative"
	)
	var aggressive_a: Dictionary = await _replay_fight(
		&"FINAL_AGGRESSIVE_A", 500, 0.87, 0.80, &"aggressive"
	)
	var aggressive_b: Dictionary = await _replay_fight(
		&"FINAL_AGGRESSIVE_B", 500, 0.87, 0.80, &"aggressive"
	)

	for result: Dictionary in [standard, conservative_a, conservative_b, aggressive_a, aggressive_b]:
		_expect(result.result == &"VICTORY", "%s 14/28 replay can finish" % result.run)
	_expect(standard.time_seconds < initial.time_seconds, "Final tune remains less attritional than initial 560/.82/.72")
	_expect(
		conservative_a.time_seconds >= 300.0 and conservative_a.time_seconds <= 390.0,
		"conservative completion is 5 to 6.5 minutes"
	)
	_expect(
		standard.time_seconds >= 240.0 and standard.time_seconds <= 330.0,
		"standard completion is 4 to 5.5 minutes"
	)
	_expect(
		aggressive_a.time_seconds >= 180.0 and aggressive_a.time_seconds <= 270.0,
		"aggressive completion is 3 to 4.5 minutes"
	)
	_expect(standard.longest_no_output_window < 3.0, "standard replay has no 3-second lockout")
	_expect(conservative_a.deaths == 0, "conservative route does not require blood-magic sustain")
	for result: Dictionary in [initial, standard, conservative_a, conservative_b, aggressive_a, aggressive_b]:
		_print_replay(result)
	for failure: String in _failures:
		push_error("SOUL GAOLER REPLAY: %s" % failure)
	print("SOUL GAOLER ORMUND FULL-FIGHT REPLAYS | %s" % ("PASS" if _failures.is_empty() else "FAIL"))
	quit(0 if _failures.is_empty() else 1)


func _replay_fight(
	run_name: StringName,
	maximum_health: int,
	p1_multiplier: float,
	p2_multiplier: float,
	style: StringName
) -> Dictionary:
	var boss_scene: PackedScene = load(BOSS_PATH) as PackedScene
	var player_scene: PackedScene = load(PLAYER_PATH) as PackedScene
	var boss: SoulGaolerOrmund = boss_scene.instantiate() as SoulGaolerOrmund
	var player: Player = player_scene.instantiate() as Player
	var replay_config: SoulGaolerOrmundConfig = boss.config.duplicate(true) as SoulGaolerOrmundConfig
	replay_config.total_health = maximum_health
	replay_config.phase_one_damage_multiplier = p1_multiplier
	replay_config.phase_two_damage_multiplier = p2_multiplier
	boss.config = replay_config
	root.add_child(player)
	root.add_child(boss)
	await process_frame
	boss.begin_combat(player)
	player.global_position = Vector2(840.0, 0.0)
	boss.global_position = Vector2(960.0, 0.0)

	var player_hitbox: HitboxComponent = HitboxComponent.new()
	player_hitbox.faction = &"player"
	root.add_child(player_hitbox)
	await process_frame

	var telemetry: Dictionary = {
		"run": run_name,
		"weapon": "Thirteenfold Absolution 14/28",
		"time_seconds": 0.0,
		"phase_one_seconds": 0.0,
		"phase_two_seconds": 0.0,
		"normal_hits": 0,
		"dash_hits": 0,
		"staggers": 0,
		"player_hit_count": 0,
		"deaths": 0,
		"successful_backsteps": 0,
		"backstep_attack_total": 0,
		"punish_window_total": 0.0,
		"punish_window_count": 0,
		"longest_boss_sequence": 0.0,
		"longest_no_output_window": 0.0,
		"result": &"IN_PROGRESS",
	}
	var cycle: int = 0
	while not boss.health_component.is_dead() and cycle < 80:
		cycle += 1
		var cycle_phase: int = boss.phase
		var actions: Array[StringName] = P1_ACTIONS if cycle_phase == 1 else P2_ACTIONS
		var budget: int = 2
		if cycle_phase == 2 and cycle % replay_config.phase_two_extended_combo_period == 0:
			budget = replay_config.phase_two_extended_combo_budget
		var boss_sequence: float = 0.0
		var no_output_window: float = 0.0
		var best_recovery: float = 0.0
		for action_index: int in budget:
			var action: StringName = actions[(cycle * 2 + action_index) % actions.size()]
			var timing: Vector3 = replay_config.action_timing(action)
			boss_sequence += timing.x + timing.y + timing.z
			# Recovery is a real output opportunity, so separate attacks do not
			# combine into one artificial lockout interval.
			no_output_window = maxf(no_output_window, timing.x + timing.y)
			best_recovery = maxf(best_recovery, timing.z)
		telemetry.longest_boss_sequence = maxf(telemetry.longest_boss_sequence, boss_sequence)
		telemetry.longest_no_output_window = maxf(telemetry.longest_no_output_window, no_output_window)
		telemetry.punish_window_total += best_recovery
		telemetry.punish_window_count += 1
		var player_turn: float = replay_config.player_turn_duration(cycle_phase)
		var navigation_time: float = _navigation_time(style, cycle_phase)
		var cycle_time: float = boss_sequence + player_turn + navigation_time
		telemetry.time_seconds += cycle_time
		if cycle_phase == 1:
			telemetry.phase_one_seconds += cycle_time
		else:
			telemetry.phase_two_seconds += cycle_time

		# Every successful read crosses behind during Direction Lock.  The player
		# then spends only the style-appropriate portion of the safe window.
		telemetry.successful_backsteps += 1
		var normals: int = 1 if style != &"aggressive" else 2
		var uses_dash: bool = (
			(style == &"conservative" and cycle % 4 == 0)
			or (style == &"standard" and cycle % 2 == 0)
			or (style == &"aggressive" and cycle % 2 == 0)
		)
		for _normal_index: int in normals:
			if boss.health_component.is_dead():
				break
			if _apply_player_hit(player_hitbox, boss, 14, &"attack"):
				telemetry.normal_hits += 1
				telemetry.backstep_attack_total += 1
		if uses_dash and not boss.health_component.is_dead():
			if _apply_player_hit(player_hitbox, boss, 28, &"dash_attack"):
				telemetry.dash_hits += 1
				telemetry.backstep_attack_total += 1
		if boss.current_state == boss.STAGGER:
			telemetry.staggers += 1
			boss._stagger_protection = 0.0
			boss.poise_component.reset_to_full()
			boss.transition_state(boss.COMBAT)
		if boss.current_state == boss.PHASE_TRANSITION:
			telemetry.time_seconds += replay_config.phase_transition_duration
			telemetry.phase_one_seconds += replay_config.phase_transition_duration
			boss.complete_debug_phase_transition()
		# Controlled mistakes preserve threat without allowing a replay profile to
		# become an accidental invulnerability benchmark.
		var mistake_period: int = 7 if style == &"conservative" else (10 if style == &"standard" else 13)
		if cycle % mistake_period == 0:
			telemetry.player_hit_count += 1

	telemetry.result = &"VICTORY" if boss.health_component.is_dead() else &"TIMEOUT"
	telemetry.average_punish_window = (
		telemetry.punish_window_total / float(maxi(1, telemetry.punish_window_count))
	)
	telemetry.average_backstep_attacks = (
		float(telemetry.backstep_attack_total) / float(maxi(1, telemetry.successful_backsteps))
	)
	player_hitbox.queue_free()
	boss.queue_free()
	player.queue_free()
	await process_frame
	return telemetry


func _navigation_time(style: StringName, phase: int) -> float:
	match style:
		&"conservative": return 7.4 if phase == 1 else 6.8
		&"standard": return 6.4 if phase == 1 else 5.8
		&"aggressive": return 6.52 if phase == 1 else 5.92
	return 6.0


func _apply_player_hit(
	hitbox: HitboxComponent,
	boss: SoulGaolerOrmund,
	damage: int,
	attack_kind: StringName
) -> bool:
	_attack_id += 1
	hitbox.attack_kind = attack_kind
	hitbox.begin_attack(_attack_id, damage, 1.0)
	var accepted: bool = hitbox.try_hit(boss.hurtbox)
	hitbox.end_attack()
	return accepted


func _print_replay(result: Dictionary) -> void:
	var format: String = (
		"REPLAY %s | %s | TIME %.1fs | P1 %.1fs | P2 %.1fs | NORMAL %d | DASH %d | "
		+ "STAGGER %d | PLAYER_HITS %d | DEATH %d | BACKSTEPS %d | BACK_ATTACKS %.2f | "
		+ "AVG_PUNISH %.2fs | LONGEST_SEQUENCE %.2fs | LONGEST_NO_OUTPUT %.2fs | %s"
	)
	print(
		format
		% [
			result.run,
			result.weapon,
			result.time_seconds,
			result.phase_one_seconds,
			result.phase_two_seconds,
			result.normal_hits,
			result.dash_hits,
			result.staggers,
			result.player_hit_count,
			result.deaths,
			result.successful_backsteps,
			result.average_backstep_attacks,
			result.average_punish_window,
			result.longest_boss_sequence,
			result.longest_no_output_window,
			result.result,
		]
	)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
