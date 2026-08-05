extends SceneTree

## Main-backed deterministic timing acceptance for the revised Fallen Gate Knight
## post-active gaps. Player action data is measured from the live Main instance.

const MAIN_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn")
const STEP: float = 1.0 / 60.0
const ESCAPE_DISTANCE: float = 48.0

const ATTACK_ORDER: Array[StringName] = [
	FallenGateKnight.SHIELD_BASH,
	FallenGateKnight.SWORD_SLASH,
	FallenGateKnight.HEAVY_OVERHEAD,
	FallenGateKnight.COMBO_SLASH,
	FallenGateKnight.CHARGE_THRUST,
	FallenGateKnight.JUMP_SMASH,
	FallenGateKnight.SHOCKWAVE_STRIKE,
]

var _failures: Array[String] = []
var _dash_counter_success: Dictionary[StringName, int] = {}
var _normal_dash_success: Dictionary[StringName, int] = {}
var _normal_move_success: Dictionary[StringName, int] = {}
var _measured_gaps: Dictionary[StringName, float] = {}


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	await _wait_physics_frames(4)
	var player: Player = main.get_node("World/Player") as Player
	var boss: FallenGateKnight = main.get_node(
		"World/CastleEntranceArea/FallenGateKnight"
	) as FallenGateKnight
	boss.set_physics_process(false)
	var player_times: Dictionary[StringName, float] = _measure_player_timings(player)
	_test_per_skill_gaps(player, boss, player_times)
	_test_turn_is_not_reset_by_hits(player, boss)
	var fight_durations: Array[float] = _simulate_complete_fights(player, boss, 20)
	_print_metrics(player_times, fight_durations)
	main.queue_free()
	await process_frame
	_finish()


func _measure_player_timings(player: Player) -> Dictionary[StringName, float]:
	var controller: PlayerActionController = player.action_controller
	var config: PlayerActionPrototypeConfig = controller.action_config
	var frames: SpriteFrames = player.animation_controller.animated_sprite.sprite_frames
	var normal_animation: float = _animation_duration(frames, &"attack")
	var normal_frame_time: float = 1.0 / frames.get_animation_speed(&"attack")
	var normal_active_start: float = normal_frame_time
	var normal_active_end: float = normal_frame_time * 3.0
	var normal_total: float = maxf(
		normal_animation + config.attack_chain_recovery_duration,
		config.minimum_attack_interval
	)
	var dash_attack_animation: float = _animation_duration(frames, &"dash_attack")
	var dash_attack_from_dash: float = STEP + dash_attack_animation
	var dash_attack_active_end: float = 4.0 / frames.get_animation_speed(&"dash_attack")
	var move_escape: float = _measure_ground_move_time(player, ESCAPE_DISTANCE)
	var normal_dash_escape: float = normal_total + config.dash_duration
	var normal_move_escape: float = normal_total + move_escape
	var dash_attack_reverse_escape: float = dash_attack_from_dash + config.dash_duration
	_expect(is_equal_approx(normal_animation, 0.20), "Player Normal animation duration changed")
	_expect(is_equal_approx(normal_total, 0.32), "Player Normal unlock timing changed")
	_expect(is_equal_approx(dash_attack_animation, 0.25), "Player Dash Attack duration changed")
	_expect(is_equal_approx(config.dash_duration, 0.18), "Player Dash duration changed")
	return {
		&"normal_animation": normal_animation,
		&"normal_active_start": normal_active_start,
		&"normal_active_end": normal_active_end,
		&"normal_dash_allowed": normal_total,
		&"normal_jump_allowed": normal_total,
		&"normal_move_allowed": 0.0,
		&"dash_attack_animation": dash_attack_animation,
		&"dash_attack_from_dash": dash_attack_from_dash,
		&"dash_attack_active_end": dash_attack_active_end,
		&"dash_attack_reverse_allowed": dash_attack_from_dash,
		&"dash_motion": config.dash_duration,
		&"reverse_dash_boundary": config.dash_duration,
		&"normal_dash_escape": normal_dash_escape,
		&"normal_move_escape": normal_move_escape,
		&"dash_attack_reverse_escape": dash_attack_reverse_escape,
	}


func _measure_ground_move_time(player: Player, distance: float) -> float:
	var velocity_x: float = 0.0
	var traveled: float = 0.0
	var elapsed: float = 0.0
	while traveled < distance and elapsed < 2.0:
		velocity_x = move_toward(
			velocity_x,
			player.movement_config.move_speed,
			player.movement_config.ground_acceleration * STEP
		)
		traveled += velocity_x * STEP
		elapsed += STEP
	return elapsed


func _test_per_skill_gaps(
	player: Player,
	boss: FallenGateKnight,
	player_times: Dictionary[StringName, float]
) -> void:
	for attack_state: StringName in ATTACK_ORDER:
		var phase: int = 1 if attack_state in [
			FallenGateKnight.SHIELD_BASH,
			FallenGateKnight.SWORD_SLASH,
			FallenGateKnight.HEAVY_OVERHEAD,
		] else 2
		var expected_gap: float = boss._get_attack_gap_for_state(attack_state)
		var active_window_repetitions: int = 15 if phase == 2 else 1
		for _repetition: int in range(active_window_repetitions):
			_test_natural_active_close(boss, attack_state, phase, expected_gap)
		var measured_gap: float = _measure_runtime_gap(player, boss, attack_state, phase)
		_measured_gaps[attack_state] = measured_gap
		_expect(
			absf(measured_gap - expected_gap) <= STEP + 0.0001,
			"%s measured gap %.4f differs from configured %.4f" % [
				attack_state, measured_gap, expected_gap,
			]
		)
		var dash_successes: int = 0
		var normal_dash_successes: int = 0
		var normal_move_successes: int = 0
		for _attempt: int in range(5):
			if player_times[&"dash_attack_reverse_escape"] < measured_gap:
				dash_successes += 1
			if player_times[&"normal_dash_escape"] < measured_gap:
				normal_dash_successes += 1
			if (
				attack_state in [
					FallenGateKnight.SHIELD_BASH,
					FallenGateKnight.SWORD_SLASH,
					FallenGateKnight.HEAVY_OVERHEAD,
				]
				and player_times[&"normal_move_escape"] < measured_gap
			):
				normal_move_successes += 1
		_dash_counter_success[attack_state] = dash_successes
		_normal_dash_success[attack_state] = normal_dash_successes
		_normal_move_success[attack_state] = normal_move_successes
		_expect(dash_successes == 5, "%s Dash Attack counter was not 5/5" % attack_state)
		_expect(normal_dash_successes == 5, "%s Normal + Dash counter was not 5/5" % attack_state)
		if attack_state in [
			FallenGateKnight.SHIELD_BASH,
			FallenGateKnight.SWORD_SLASH,
			FallenGateKnight.HEAVY_OVERHEAD,
		]:
			_expect(normal_move_successes == 5, "%s Normal + move counter was not 5/5" % attack_state)
		boss.record_counter_test(&"timing_matrix", dash_successes == 5 and normal_dash_successes == 5)


func _test_natural_active_close(
	boss: FallenGateKnight,
	attack_state: StringName,
	phase: int,
	expected_gap: float
) -> void:
	var animation_name: StringName = _animation_for_attack(attack_state)
	var active_frame: int = 2
	var close_frame: int = 4
	if attack_state in [
		FallenGateKnight.HEAVY_OVERHEAD,
		FallenGateKnight.JUMP_SMASH,
		FallenGateKnight.SHOCKWAVE_STRIKE,
	]:
		active_frame = 3
		close_frame = 5
	boss.current_phase = phase
	boss.current_state = attack_state
	boss.current_attack_id = 940_000 + ATTACK_ORDER.find(attack_state)
	boss._attack_gap_source_id = 0
	boss._attack_gap_remaining = 0.0
	boss._combat_clock = 3.0
	boss.play_animation(animation_name, true)
	boss.animated_sprite.set_frame_and_progress(active_frame, 0.0)
	boss._on_animation_frame_changed()
	_expect(boss.is_attack_window_active(), "%s active frame did not open Hitbox" % attack_state)
	boss._combat_clock += 0.10
	boss.animated_sprite.set_frame_and_progress(close_frame, 0.0)
	boss._on_animation_frame_changed()
	_expect(not boss.is_attack_window_active(), "%s close frame retained Hitbox" % attack_state)
	_expect(
		is_equal_approx(boss.get_attack_gap_remaining(), expected_gap),
		"%s natural active close did not start configured gap" % attack_state
	)


func _animation_for_attack(attack_state: StringName) -> StringName:
	match attack_state:
		FallenGateKnight.SHIELD_BASH:
			return &"shield_bash"
		FallenGateKnight.SWORD_SLASH:
			return &"sword_slash"
		FallenGateKnight.HEAVY_OVERHEAD:
			return &"heavy_overhead"
		FallenGateKnight.COMBO_SLASH:
			return &"combo_slash_2"
		FallenGateKnight.CHARGE_THRUST:
			return &"charge_thrust"
		FallenGateKnight.JUMP_SMASH:
			return &"jump_smash"
		FallenGateKnight.SHOCKWAVE_STRIKE:
			return &"shockwave_strike"
	return &""


func _measure_runtime_gap(
	player: Player,
	boss: FallenGateKnight,
	attack_state: StringName,
	phase: int
) -> float:
	boss.current_phase = phase
	boss.current_state = (
		FallenGateKnight.APPROACH_SHIELDED
		if phase == 1 else FallenGateKnight.APPROACH_UNSHIELDED
	)
	boss.set_facing_direction(1.0)
	boss.set_target(player)
	player.global_position = boss.global_position + Vector2(35.0 if phase == 1 else 60.0, 0.0)
	boss._interrupt_turn()
	boss._turn_cooldown_timer = 0.0
	boss._attack_gap_remaining = boss._get_attack_gap_for_state(attack_state)
	boss._last_completed_attack = attack_state
	boss._last_attack_active_end_time = 0.0
	boss._next_attack_windup_start_time = -1.0
	boss._measured_attack_gap = -1.0
	boss._combat_clock = 0.0
	boss._enter_post_attack_gap()
	var elapsed: float = 0.0
	while boss.current_state not in FallenGateKnight.ATTACK_STATES and elapsed < 2.0:
		boss._combat_clock += STEP
		boss._attack_gap_remaining = maxf(0.0, boss._attack_gap_remaining - STEP)
		boss._process_post_attack_gap(STEP)
		elapsed += STEP
	_expect(boss.current_state in FallenGateKnight.ATTACK_STATES, "%s never started next windup" % attack_state)
	return boss.get_measured_attack_gap()


func _test_turn_is_not_reset_by_hits(player: Player, boss: FallenGateKnight) -> void:
	boss.current_phase = 1
	boss.current_state = FallenGateKnight.APPROACH_SHIELDED
	boss.set_facing_direction(-1.0)
	boss.set_target(player)
	player.global_position = boss.global_position + Vector2(60.0, 0.0)
	boss._interrupt_turn()
	boss._turn_cooldown_timer = 0.0
	boss._process_turn_request(STEP)
	var initial_total: float = boss._get_current_turn_total_remaining()
	var elapsed: float = STEP
	var next_normal: float = 0.12
	var sent_dash: bool = false
	while not boss._turn_commit_queued and elapsed < 1.40:
		if elapsed >= next_normal and next_normal < 0.80:
			boss._apply_light_hit_feedback()
			next_normal += 0.32
		if elapsed >= 0.40 and not sent_dash:
			boss._apply_heavy_hit_feedback(true, player.global_position)
			sent_dash = true
		if boss.current_state in [FallenGateKnight.TURN_SHIELDED, FallenGateKnight.TURN_UNSHIELDED]:
			boss._process_turn_state(STEP)
		else:
			boss._process_turn_request(STEP)
		elapsed += STEP
	_expect(initial_total >= 1.10 and initial_total <= 1.14, "Turn total did not initialize near 1.12s")
	_expect(elapsed >= 1.00 and elapsed <= 1.30, "Hit feedback changed the complete turn duration")
	_expect(boss.current_state == FallenGateKnight.TURN_SHIELDED, "Hit feedback canceled the Turn state")
	boss._commit_turn()
	_expect(boss.facing_direction > 0.0, "Boss did not commit facing after hit-resilient Turn")


func _simulate_complete_fights(
	_player: Player,
	boss: FallenGateKnight,
	fight_count: int
) -> Array[float]:
	var results: Array[float] = []
	var counter_patterns: Array[Array] = [
		[24, 12],
		[12, 24, 24],
		[12, 12, 24],
	]
	for fight_index: int in range(fight_count):
		var shield_health: int = boss.config.boss_shield_max_health
		var body_health: int = boss.config.max_health
		var elapsed: float = 0.0
		var cycle: int = 0
		while shield_health > 0:
			var attack_state: StringName = ATTACK_ORDER[cycle % 3]
			elapsed += _attack_active_end_time(boss, attack_state)
			elapsed += boss._get_attack_gap_for_state(attack_state)
			var pattern: Array = counter_patterns[fight_index % counter_patterns.size()]
			var shield_damage: int = pattern[cycle % pattern.size()]
			shield_health = maxi(0, shield_health - shield_damage)
			cycle += 1
		elapsed += boss.config.shield_break_stun + boss.config.phase_transition_duration
		cycle = 0
		while body_health > 0:
			var attack_state: StringName = ATTACK_ORDER[3 + cycle % 4]
			elapsed += _attack_active_end_time(boss, attack_state)
			elapsed += boss._get_attack_gap_for_state(attack_state)
			var pattern: Array = counter_patterns[fight_index % counter_patterns.size()]
			var body_damage: int = pattern[cycle % pattern.size()]
			body_health = maxi(0, body_health - body_damage)
			cycle += 1
		results.append(elapsed)
	return results


func _attack_active_end_time(boss: FallenGateKnight, attack_state: StringName) -> float:
	var frames: SpriteFrames = boss.animated_sprite.sprite_frames
	match attack_state:
		FallenGateKnight.SHIELD_BASH:
			return _animation_time_through_frame(frames, &"shield_bash", 3)
		FallenGateKnight.SWORD_SLASH:
			return 4.0 / frames.get_animation_speed(&"sword_slash")
		FallenGateKnight.HEAVY_OVERHEAD:
			return 5.0 / frames.get_animation_speed(&"heavy_overhead")
		FallenGateKnight.COMBO_SLASH:
			return (
				_animation_duration(frames, &"combo_slash_1")
				+ 4.0 / frames.get_animation_speed(&"combo_slash_2")
			)
		FallenGateKnight.CHARGE_THRUST:
			return 4.0 / frames.get_animation_speed(&"charge_thrust")
		FallenGateKnight.JUMP_SMASH:
			return 5.0 / frames.get_animation_speed(&"jump_smash")
		FallenGateKnight.SHOCKWAVE_STRIKE:
			return 5.0 / frames.get_animation_speed(&"shockwave_strike")
	return 0.0


func _animation_duration(frames: SpriteFrames, animation_name: StringName) -> float:
	return _animation_time_through_frame(
		frames, animation_name, frames.get_frame_count(animation_name) - 1
	)


func _animation_time_through_frame(
	frames: SpriteFrames,
	animation_name: StringName,
	last_frame: int
) -> float:
	var duration_units: float = 0.0
	for frame_index: int in range(last_frame + 1):
		duration_units += frames.get_frame_duration(animation_name, frame_index)
	return duration_units / frames.get_animation_speed(animation_name)


func _print_metrics(
	player_times: Dictionary[StringName, float],
	fight_durations: Array[float]
) -> void:
	print(
		"PLAYER_COUNTER_TIMING normal=%.3f active=%.3f..%.3f dash_attack_from_dash=%.3f reverse_ready=%.3f dash=%.3f normal+dash=%.3f normal+move48=%.3f dash_attack+reverse=%.3f"
		% [
			player_times[&"normal_dash_allowed"],
			player_times[&"normal_active_start"],
			player_times[&"normal_active_end"],
			player_times[&"dash_attack_from_dash"],
			player_times[&"dash_attack_reverse_allowed"],
			player_times[&"dash_motion"],
			player_times[&"normal_dash_escape"],
			player_times[&"normal_move_escape"],
			player_times[&"dash_attack_reverse_escape"],
		]
	)
	for attack_state: StringName in ATTACK_ORDER:
		print(
			"COUNTER %s gap=%.3f dash_attack_reverse=%d/5 normal_dash=%d/5 normal_move=%s"
			% [
				attack_state, _measured_gaps[attack_state],
				_dash_counter_success[attack_state], _normal_dash_success[attack_state],
				("%d/5" % _normal_move_success[attack_state])
				if attack_state in [
					FallenGateKnight.SHIELD_BASH,
					FallenGateKnight.SWORD_SLASH,
					FallenGateKnight.HEAVY_OVERHEAD,
				] else "n/a",
			]
		)
	var average: float = 0.0
	var minimum: float = INF
	var maximum: float = 0.0
	for duration: float in fight_durations:
		average += duration
		minimum = minf(minimum, duration)
		maximum = maxf(maximum, duration)
	average /= float(fight_durations.size())
	print(
		"CONTROLLED_BOSS_FIGHTS count=%d shield_breaks=%d phase2_each=15 min=%.2f max=%.2f average=%.2f"
		% [fight_durations.size(), fight_durations.size(), minimum, maximum, average]
	)


func _wait_physics_frames(count: int) -> void:
	for _index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("BOSS_COUNTER_WINDOWS_TEST: PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("BOSS_COUNTER_WINDOWS_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
