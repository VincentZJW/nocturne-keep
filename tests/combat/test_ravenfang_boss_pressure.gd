extends SceneTree

## Deterministic Main-backed acceptance for Ravenfang presentation, rear contact
## routing and ten simulated seconds of light-attack pressure.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const RAVENFANG_ROOT: String = "res://assets/sprites/player/ravenfang"
const RAVENFANG_FRAMES_PATH: String = "res://resources/player/ravenfang_player_sprite_frames.tres"

var _failures: Array[String] = []
var _rear_normal_first_hits: int = 0
var _rear_normal_second_hits: int = 0
var _rear_normal_third_hits: int = 0
var _rear_dash_hits: int = 0
var _pressure_attacks_started: int = 0
var _pressure_attacks_completed: int = 0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_test_ravenfang_resources()
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	await _wait_physics_frames(4)
	var player: Player = main.get_node("World/Player") as Player
	var boss: FallenGateKnight = main.get_node(
		"World/CastleEntranceArea/FallenGateKnight"
	) as FallenGateKnight
	boss.set_physics_process(false)
	_test_rear_normal_trials(player, boss)
	_test_rear_dash_trials(player, boss)
	_test_pressure_cadence(player, boss)
	main.queue_free()
	await process_frame
	_finish()


func _test_ravenfang_resources() -> void:
	var weapon: WeaponData = load(
		"res://resources/items/weapons/ravenfang_daggers.tres"
	) as WeaponData
	_expect(weapon != null, "Ravenfang WeaponData missing")
	if weapon != null:
		_expect(weapon.normal_attack_damage == 12, "Ravenfang normal damage changed")
		_expect(weapon.dash_attack_damage == 24, "Ravenfang Dash damage changed")
		_expect(weapon.icon != null, "Ravenfang icon missing")
	var icon: Image = Image.load_from_file(
		ProjectSettings.globalize_path("res://assets/ui/items/ravenfang_daggers.png")
	)
	_expect(icon.get_size() == Vector2i(16, 16), "Ravenfang icon is not 16x16")
	var frames: SpriteFrames = load(RAVENFANG_FRAMES_PATH) as SpriteFrames
	_expect(frames != null, "Ravenfang SpriteFrames resource missing")
	if frames == null:
		return
	for animation_name: StringName in PlayerSpriteFramesBuilder.ANIMATION_ORDER:
		_expect(frames.has_animation(animation_name), "Ravenfang animation missing: %s" % animation_name)
		_expect(
			frames.get_frame_count(animation_name) == PlayerSpriteFramesBuilder.FRAME_COUNTS[animation_name],
			"Ravenfang frame count mismatch: %s" % animation_name
		)
		for frame_index: int in range(frames.get_frame_count(animation_name)):
			var texture: Texture2D = frames.get_frame_texture(animation_name, frame_index)
			_expect(texture != null and texture.get_size() == Vector2(64, 64), "Ravenfang frame is not 64x64")
			if texture != null:
				_expect(
					texture.resource_path.begins_with(RAVENFANG_ROOT),
					"Ravenfang resource references a non-Ravenfang frame: %s" % texture.resource_path
				)


func _test_rear_normal_trials(player: Player, boss: FallenGateKnight) -> void:
	var normal: HitboxComponent = player.action_controller.attack_hitbox
	var step: float = 1.0 / 60.0
	for trial: int in range(20):
		_prepare_rear_turn_trial(player, boss)
		# A realistic landing/recognition delay precedes the first punish. The
		# second varies across a skilled-input band; the third starts after commit.
		var second_time: float = 0.70 + float(trial) * 0.02
		var attack_times: Array[float] = [0.35, second_time, second_time + 0.32]
		var next_attack: int = 0
		var elapsed: float = 0.0
		while next_attack < attack_times.size() and elapsed < 1.55:
			_advance_turn_only(boss, step)
			elapsed += step
			if elapsed + 0.00001 < attack_times[next_attack]:
				continue
			normal.begin_attack(810_000 + trial * 10 + next_attack, 1, 1.0, player)
			_expect(normal.try_hit(boss.hurtbox), "Rear normal trial contact was rejected")
			normal.end_attack()
			if boss.shield_component.last_route == ShieldComponent.ROUTE_BODY:
				if next_attack == 0:
					_rear_normal_first_hits += 1
				elif next_attack == 1:
					_rear_normal_second_hits += 1
				else:
					_rear_normal_third_hits += 1
			_expect(
				boss.shield_component.boss_facing_at_contact == boss.facing_direction,
				"Contact snapshot did not retain Boss facing"
			)
			next_attack += 1
	_expect(_rear_normal_first_hits == 20, "Rear first Normal was not stable across 20 trials")
	_expect(
		_rear_normal_second_hits > 0 and _rear_normal_second_hits < 20,
		"Rear second Normal was not timing-dependent"
	)
	_expect(_rear_normal_third_hits == 0, "Rear third Normal was stable before Boss turn")


func _test_rear_dash_trials(player: Player, boss: FallenGateKnight) -> void:
	var dash: HitboxComponent = player.action_controller.dash_attack_hitbox
	var step: float = 1.0 / 60.0
	for trial: int in range(10):
		_prepare_rear_turn_trial(player, boss)
		var elapsed: float = 0.0
		while elapsed < 0.20:
			_advance_turn_only(boss, step)
			elapsed += step
		dash.begin_attack(820_000 + trial, 1, 1.0, player)
		_expect(dash.try_hit(boss.hurtbox), "Rear Dash trial contact was rejected")
		dash.end_attack()
		if boss.shield_component.last_route == ShieldComponent.ROUTE_BODY:
			_rear_dash_hits += 1
		_expect(not dash.try_hit(boss.hurtbox), "Rear Dash attack resolved twice")
	_expect(_rear_dash_hits == 10, "Rear Dash Attack was not stable across 10 trials")


func _test_pressure_cadence(player: Player, boss: FallenGateKnight) -> void:
	boss.health_component.max_health = 999
	boss.health_component.reset_to_full()
	boss.shield_component.reset_shield()
	boss.shield_component._shield_broken = true
	boss.current_phase = 2
	boss.current_state = FallenGateKnight.IDLE_UNSHIELDED
	boss.set_facing_direction(1.0)
	boss._interrupt_turn()
	boss._light_hit_reaction_cooldown = 0.0
	boss._heavy_hit_reaction_cooldown = 0.0
	boss.set_target(player)
	player.global_position = boss.global_position + Vector2(60.0, 0.0)
	var normal: HitboxComponent = player.action_controller.attack_hitbox
	var step: float = 1.0 / 60.0
	var elapsed: float = 0.0
	var next_hit_time: float = 0.05
	var combo_step: int = 0
	var attack_animation_remaining: float = 0.0
	var tracked_animation: StringName = &""
	while elapsed < 10.0:
		boss._combat_clock += step
		boss._attack_gap_remaining = maxf(0.0, boss._attack_gap_remaining - step)
		var state_before: StringName = boss.current_state
		if boss.current_state in FallenGateKnight.ATTACK_STATES:
			if tracked_animation != boss.animated_sprite.animation:
				tracked_animation = boss.animated_sprite.animation
				attack_animation_remaining = boss._get_animation_duration(tracked_animation)
			attack_animation_remaining -= step
			boss._process_attack_motion(step)
			if attack_animation_remaining <= 0.0:
				boss._on_animation_finished()
				if boss.current_state not in FallenGateKnight.ATTACK_STATES:
					_pressure_attacks_completed += 1
				tracked_animation = &""
		elif boss.current_state in [FallenGateKnight.GUARD_RECOVERY, FallenGateKnight.RECOVERY]:
			boss._process_post_attack_gap(step)
		elif boss.current_state in [
			FallenGateKnight.BOSS_INTRO, FallenGateKnight.HURT_SHIELDED,
			FallenGateKnight.HURT_UNSHIELDED,
		]:
			boss._process_timed_state(step)
		elif boss.current_state in [FallenGateKnight.TURN_SHIELDED, FallenGateKnight.TURN_UNSHIELDED]:
			boss._process_turn_state(step)
			if boss._turn_commit_queued:
				boss._commit_turn()
		elif boss.current_state in [FallenGateKnight.IDLE_SHIELDED, FallenGateKnight.IDLE_UNSHIELDED]:
			boss._process_idle(step)
		elif boss.current_state in [FallenGateKnight.APPROACH_SHIELDED, FallenGateKnight.APPROACH_UNSHIELDED]:
			boss._process_approach(step)
		if state_before not in FallenGateKnight.ATTACK_STATES and boss.current_state in FallenGateKnight.ATTACK_STATES:
			_pressure_attacks_started += 1
		if elapsed + 0.00001 >= next_hit_time:
			normal.begin_attack(830_000 + combo_step, 1, 1.0, player)
			_expect(normal.try_hit(boss.hurtbox), "Pressure Normal contact was rejected")
			normal.end_attack()
			combo_step += 1
			# Three starts are 0.32s apart; the forced 0.34s recovery follows frame four.
			next_hit_time += 0.32 if combo_step % 3 != 0 else 0.54
		elapsed += step
		boss._light_hit_reaction_cooldown = maxf(0.0, boss._light_hit_reaction_cooldown - step)
		boss._heavy_hit_reaction_cooldown = maxf(0.0, boss._heavy_hit_reaction_cooldown - step)
	_expect(_pressure_attacks_started > 0, "Boss never started an attack under ten-second J pressure")
	_expect(_pressure_attacks_completed > 0, "Boss never completed an attack under ten-second J pressure")
	boss.health_component.max_health = boss.config.max_health
	boss.reset_boss()


func _prepare_rear_turn_trial(player: Player, boss: FallenGateKnight) -> void:
	boss.health_component.max_health = boss.config.max_health
	boss.health_component.reset_to_full()
	boss.shield_component.reset_shield()
	boss.current_phase = 1
	boss.current_state = FallenGateKnight.APPROACH_SHIELDED
	boss.set_facing_direction(-1.0)
	boss._interrupt_turn()
	boss._turn_cooldown_timer = 0.0
	boss._light_hit_reaction_cooldown = 0.0
	boss._heavy_hit_reaction_cooldown = 0.0
	boss._attack_gap_remaining = 0.0
	boss._attack_gap_source_id = 0
	boss._combat_clock = 0.0
	boss.set_target(player)
	player.global_position = boss.global_position + Vector2(55.0, 0.0)


func _advance_turn_only(boss: FallenGateKnight, delta: float) -> void:
	if boss.current_state in [FallenGateKnight.TURN_SHIELDED, FallenGateKnight.TURN_UNSHIELDED]:
		boss._process_turn_state(delta)
		if boss._turn_commit_queued:
			boss._commit_turn()
	else:
		boss._process_turn_request(delta)


func _wait_physics_frames(count: int) -> void:
	for _index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	print(
		"REAR_NORMAL_20: first=%d second=%d third=%d | REAR_DASH_10: %d | PRESSURE_10S: started=%d completed=%d"
		% [
			_rear_normal_first_hits, _rear_normal_second_hits, _rear_normal_third_hits,
			_rear_dash_hits, _pressure_attacks_started, _pressure_attacks_completed,
		]
	)
	if _failures.is_empty():
		print("RAVENFANG_BOSS_PRESSURE_TEST: PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("RAVENFANG_BOSS_PRESSURE_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
