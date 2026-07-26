extends SceneTree

## Deterministic response, single-entry buffer, repeat, and compressed timing tests.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")

var _failures: Array[String] = []
var _attack_started_count: int = 0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_validate_configuration()
	await _test_immediate_response_and_complete_frames()
	await _test_early_buffer_and_single_consumption()
	await _test_deliberate_repeated_chains()
	await _test_movement_and_facing_lock()
	await _test_dash_attack_duration()
	_release_inputs()
	_finish()


func _validate_configuration() -> void:
	var config: PlayerActionPrototypeConfig = load(
		"res://resources/player/player_action_prototype_config.tres"
	) as PlayerActionPrototypeConfig
	_expect(config != null, "Player action configuration is missing")
	if config != null:
		_expect(config.maximum_normal_combo == 3, "Normal Attack combo is not capped at three")
		_expect(is_equal_approx(config.attack_buffer_time, 0.08), "Attack buffer is not 0.08 seconds")
		_expect(is_equal_approx(config.attack_chain_window_start, 0.10), "Attack chain window does not start at 0.10 seconds")
		_expect(is_equal_approx(config.attack_chain_window_end, 0.20), "Attack chain window does not end at 0.20 seconds")
		_expect(is_equal_approx(config.minimum_attack_interval, 0.32), "Minimum Attack interval is not 0.32 seconds")
		_expect(is_equal_approx(config.attack_chain_recovery_duration, 0.12), "Attack chain recovery is not 0.12 seconds")
		_expect(is_equal_approx(config.combo_end_recovery, 0.34), "Combo end recovery is not 0.34 seconds")
		_expect(
			is_equal_approx(config.dash_attack_move_duration + config.dash_attack_recovery_duration, 0.25),
			"Dash Attack movement duration is not 0.25 seconds"
		)
	var frames: SpriteFrames = load("res://resources/player/player_sprite_frames.tres") as SpriteFrames
	_expect(frames != null, "Player SpriteFrames resource is missing")
	if frames != null:
		_expect(frames.get_frame_count(&"attack") == 4, "Attack is not four frames")
		_expect(is_equal_approx(frames.get_animation_speed(&"attack"), 20.0), "Attack is not 20 FPS")
		_expect(not frames.get_animation_loop(&"attack"), "Attack unexpectedly loops")
		_expect(frames.get_frame_count(&"dash_attack") == 5, "Dash Attack is not five frames")
		_expect(is_equal_approx(frames.get_animation_speed(&"dash_attack"), 20.0), "Dash Attack is not 20 FPS")
		_expect(not frames.get_animation_loop(&"dash_attack"), "Dash Attack unexpectedly loops")
	_expect(PlayerAnimationController.ATTACK_HIT_FRAMES == [1, 2], "Attack metadata is not frames 02/03")
	_expect(PlayerAnimationController.DASH_ATTACK_HIT_FRAMES == [2, 3], "Dash Attack metadata is not frames 03/04")


func _test_immediate_response_and_complete_frames() -> void:
	var world: Node2D = _create_world()
	var player: Player = _spawn_player(world)
	var actions: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	await _wait_physics_frames(4)
	var accepted: bool = actions.try_start_actions(true, false, true, 0.0, false)
	_expect(accepted, "Immediate Attack request was rejected")
	_expect(actions.get_action_name() == &"attack", "J did not start Attack on its first physics edge")
	_expect(sprite.animation == &"attack" and sprite.frame == 0, "Immediate Attack did not begin at frame 01")
	_expect(not actions.is_attack_buffered(), "Initial J was retained as a chained Attack")
	for frame_index: int in [1, 2, 3]:
		sprite.frame = frame_index
		sprite.frame_changed.emit()
		_expect(actions.get_action_name() == &"attack", "Attack state ended before frame %02d" % (frame_index + 1))
	_expect(sprite.frame == 3, "Single Attack did not reach attack_04")
	actions.advance(0.20)
	var measured_response: float = actions.get_attack_input_to_hit_time()
	_expect(
		measured_response >= 0.049 and measured_response <= 0.051,
		"Input-to-attack_02 latency is outside the expected ~0.05s range: %.4f" % measured_response
	)
	sprite.animation_finished.emit()
	_expect(actions.get_action_state_name() == &"AttackRecovery", "Single Attack skipped its minimum recovery beat")
	actions.advance(0.06)
	_expect(actions.is_action_active(), "Single Attack recovery ended too early")
	actions.advance(0.061)
	_expect(not actions.is_action_active(), "Single Attack did not end after the 0.12s recovery")
	_cleanup_world(world)
	await process_frame


func _test_early_buffer_and_single_consumption() -> void:
	var world: Node2D = _create_world()
	var player: Player = _spawn_player(world)
	var actions: PlayerActionController = player.action_controller
	_attack_started_count = 0
	actions.action_started.connect(_on_action_started)
	await _wait_physics_frames(4)
	actions.try_start_actions(true, false, true, 0.0, false)
	_expect(_attack_started_count == 1, "Initial Attack emitted the wrong start count")
	# Pressing before frame 03 is ignored; one legal input is latched once.
	actions.try_start_actions(true, false, true, 0.0, false)
	_expect(not actions.is_attack_buffered(), "Early repeat J was incorrectly buffered")
	_expect(_attack_started_count == 1, "Early repeat J restarted Attack")
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	sprite.frame = 1
	sprite.frame_changed.emit()
	actions.advance(0.099)
	_expect(not actions.can_chain_attack(), "Attack chain window opened before 0.10 seconds")
	actions.try_start_actions(true, false, true, 0.0, false)
	_expect(not actions.is_attack_buffered(), "Pre-window J was retained")
	actions.advance(0.001)
	sprite.frame = 2
	sprite.frame_changed.emit()
	_expect(actions.can_chain_attack(), "Attack did not open its 0.10-0.20s chain window")
	actions.try_start_actions(true, false, true, 0.0, false)
	_expect(actions.is_attack_buffered(), "In-window J was not buffered")
	_expect(_attack_started_count == 1, "In-window J restarted Attack before recovery")
	actions.advance(0.10)
	sprite.frame = 3
	sprite.animation_finished.emit()
	_expect(actions.get_action_state_name() == &"AttackRecovery", "Buffered Attack skipped recovery")
	actions.advance(0.119)
	_expect(_attack_started_count == 1, "Buffered Attack restarted before 0.12s interval recovery")
	actions.advance(0.002)
	_expect(_attack_started_count == 2, "Buffered Attack was not consumed after recovery")
	_expect(not actions.is_attack_buffered(), "Consumed Attack buffer was not cleared")
	sprite.frame = 3
	sprite.animation_finished.emit()
	actions.advance(0.121)
	_expect(_attack_started_count == 2, "One buffered press was consumed more than once")
	_cleanup_world(world)
	await process_frame


func _test_deliberate_repeated_chains() -> void:
	var world: Node2D = _create_world()
	var player: Player = _spawn_player(world)
	var actions: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	_attack_started_count = 0
	actions.action_started.connect(_on_action_started)
	await _wait_physics_frames(4)
	actions.try_start_actions(true, false, true, 0.0, false)
	for chain_index: int in range(2):
		sprite.frame = 1
		sprite.frame_changed.emit()
		_expect(sprite.frame >= 1, "Attack %d never reached attack_02" % (chain_index + 1))
		sprite.frame = 2
		sprite.frame_changed.emit()
		actions.advance(0.10)
		_expect(actions.can_chain_attack(), "Attack %d never opened its legal chain window" % (chain_index + 1))
		actions.try_start_actions(true, false, true, 0.0, false)
		_expect(_attack_started_count == chain_index + 1, "Chain restarted before current Attack completed")
		actions.advance(0.10)
		sprite.frame = 3
		sprite.animation_finished.emit()
		actions.advance(0.119)
		_expect(_attack_started_count == chain_index + 1, "Chain skipped the minimum recovery beat")
		actions.advance(0.002)
		_expect(
			_attack_started_count == chain_index + 2,
			"Chain %d did not restart exactly once after recovery" % (chain_index + 1)
		)
		_expect(sprite.animation == &"attack", "Chained Attack lost its animation")
	_expect(actions.get_normal_combo_step() == 3, "Third Attack did not report combo step three")
	sprite.frame = 2
	sprite.frame_changed.emit()
	actions.advance(0.10)
	actions.try_start_actions(true, false, true, 0.0, false)
	_expect(not actions.is_attack_buffered(), "Third Attack accepted an illegal fourth-chain buffer")
	actions.advance(0.10)
	sprite.frame = 3
	sprite.animation_finished.emit()
	_expect(actions.get_action_state_name() == &"AttackRecovery", "Third Attack skipped mandatory recovery")
	actions.advance(0.339)
	_expect(actions.is_action_active(), "Mandatory combo-end recovery ended too early")
	actions.advance(0.002)
	_expect(_attack_started_count == 3, "Rapid chain escaped the three-Attack cap")
	_expect(not actions.is_action_active(), "Third Attack did not finish after mandatory recovery")
	_cleanup_world(world)
	await process_frame


func _test_movement_and_facing_lock() -> void:
	var world: Node2D = _create_world()
	var player: Player = _spawn_player(world)
	var actions: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	await _wait_physics_frames(4)
	actions.try_start_actions(true, false, true, 0.0, false)
	var facing_change_accepted: bool = player.animation_controller.set_facing_left(true)
	_expect(actions.get_action_name() == &"attack", "Movement cancelled active Attack")
	_expect(sprite.animation == &"attack", "Movement animation overrode Attack")
	_expect(not sprite.flip_h, "Attack facing changed before completion")
	_expect(not facing_change_accepted, "Attack did not queue facing while locked")
	actions.try_start_actions(false, true, true, 0.0, false)
	_expect(actions.get_action_name() == &"attack", "Dash cancelled Attack despite the preserved policy")
	sprite.frame = 3
	sprite.animation_finished.emit()
	_expect(sprite.flip_h, "Queued left facing was not applied after Attack")
	_cleanup_world(world)
	await process_frame


func _test_dash_attack_duration() -> void:
	var world: Node2D = _create_world()
	var player: Player = _spawn_player(world)
	var actions: PlayerActionController = player.action_controller
	await _wait_physics_frames(4)
	actions.try_start_actions(true, true, true, 0.0, false)
	_expect(actions.is_dash_attack_active(), "Same-frame Shift/J did not start Dash Attack")
	_expect(is_equal_approx(actions.get_action_horizontal_velocity(), 320.0), "Dash Attack did not start at 320 px/s")
	actions.advance(0.15)
	_expect(is_equal_approx(actions.get_action_horizontal_velocity(), 320.0), "Dash Attack sustained phase ended early")
	actions.advance(0.05)
	_expect(is_equal_approx(actions.get_action_horizontal_velocity(), 160.0), "Dash Attack recovery did not decelerate linearly")
	actions.advance(0.05)
	_expect(is_zero_approx(actions.get_action_horizontal_velocity()), "Dash Attack still moves after 0.25 seconds")
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	sprite.frame = 4
	sprite.animation_finished.emit()
	_expect(not actions.is_action_active(), "Dash Attack did not finish after its fifth frame")
	_expect(actions.attack_hitbox != null, "Player AttackHitbox is missing after combat integration")
	_expect(actions.dash_attack_hitbox != null, "Player DashAttackHitbox is missing after combat integration")
	_expect(not actions.attack_hitbox.is_active, "AttackHitbox remained active after Dash Attack")
	_expect(not actions.dash_attack_hitbox.is_active, "DashAttackHitbox remained active after completion")
	_cleanup_world(world)
	await process_frame


func _create_world() -> Node2D:
	var world: Node2D = Node2D.new()
	var floor: StaticBody2D = StaticBody2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(2200.0, 40.0)
	collision.position = Vector2(0.0, 300.0)
	collision.shape = shape
	floor.add_child(collision)
	world.add_child(floor)
	get_root().add_child(world)
	return world


func _spawn_player(world: Node2D) -> Player:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	player.position = Vector2(0.0, 252.0)
	world.add_child(player)
	return player


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _on_action_started(action_name: StringName) -> void:
	if action_name == &"attack":
		_attack_started_count += 1


func _cleanup_world(world: Node2D) -> void:
	_release_inputs()
	world.queue_free()


func _release_inputs() -> void:
	for action_name: StringName in [
		PlayerScript.MOVE_LEFT_ACTION, PlayerScript.MOVE_RIGHT_ACTION,
		PlayerScript.JUMP_ACTION, PlayerScript.DASH_ACTION, PlayerScript.ATTACK_ACTION,
	]:
		Input.action_release(action_name)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("FAST_ATTACK_TEST: PASS (immediate response, single buffer, three-hit cap, 0.34s forced recovery, 0.25s Dash Attack)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("FAST_ATTACK_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
