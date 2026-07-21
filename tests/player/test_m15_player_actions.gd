extends SceneTree

## M1.5 asset audit and deterministic double-jump, Dash, and Attack prototype tests.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const PREVIEW_SCENE: PackedScene = preload("res://scenes/tools/player_animation_preview.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")
const SPRITE_FRAMES_PATH: String = "res://resources/player/player_sprite_frames.tres"

var _failures: Array[String] = []
var _double_jump_events: int = 0
var _action_started_events: Array[StringName] = []
var _action_finished_events: Array[StringName] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_validate_inputs_and_assets()
	await _validate_preview_controls()
	await _test_double_jump_contract()
	await _test_dash_contract()
	await _test_attack_contract()
	_release_all_inputs()
	_finish()


func _validate_inputs_and_assets() -> void:
	for action_name: StringName in [PlayerScript.DASH_ACTION, PlayerScript.ATTACK_ACTION]:
		_expect(InputMap.has_action(action_name), "Missing M1.5 input action: %s" % action_name)
		_expect(not InputMap.action_get_events(action_name).is_empty(), "Input action has no events: %s" % action_name)
	_expect(_action_has_physical_key(PlayerScript.DASH_ACTION, KEY_SHIFT), "Dash is not mapped to physical Shift")
	_expect(_action_has_physical_key(PlayerScript.ATTACK_ACTION, KEY_J), "Attack is not mapped to physical J")
	for frame_index: int in range(1, 7):
		var path: String = "res://assets/sprites/player/assassin/attack/attack_%02d.png" % frame_index
		_expect(ResourceLoader.exists(path), "Missing Attack frame: %s" % path)
	for frame_index: int in range(1, 6):
		var path: String = "res://assets/sprites/player/assassin/dash/dash_%02d.png" % frame_index
		_expect(ResourceLoader.exists(path), "Missing Dash frame: %s" % path)
	var sprite_frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	_expect(sprite_frames != null, "Player SpriteFrames resource is unreadable")
	if sprite_frames == null:
		return
	_expect(sprite_frames.has_animation(&"attack"), "SpriteFrames lacks attack")
	_expect(sprite_frames.get_frame_count(&"attack") == 6, "Attack frame count is not six")
	_expect(is_equal_approx(sprite_frames.get_animation_speed(&"attack"), 12.0), "Attack FPS is not 12")
	_expect(not sprite_frames.get_animation_loop(&"attack"), "Attack unexpectedly loops")
	_expect(sprite_frames.has_animation(&"dash"), "SpriteFrames lacks dash")
	_expect(sprite_frames.get_frame_count(&"dash") == 5, "Dash frame count is not five")
	_expect(is_equal_approx(sprite_frames.get_animation_speed(&"dash"), 20.0), "Dash FPS is not 20")
	_expect(not sprite_frames.get_animation_loop(&"dash"), "Dash unexpectedly loops")
	_expect(PlayerScript.DOUBLE_JUMP_ANIMATION == &"double_jump", "Future double_jump name is not reserved")


func _validate_preview_controls() -> void:
	var preview: Control = PREVIEW_SCENE.instantiate() as Control
	get_root().add_child(preview)
	await process_frame
	var sprite: AnimatedSprite2D = preview.get_node("Player/VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	var dash_button: Button = preview.get_node("Margin/Layout/AnimationButtons/DashButton") as Button
	var attack_button: Button = preview.get_node("Margin/Layout/AnimationButtons/AttackButton") as Button
	dash_button.pressed.emit()
	await process_frame
	_expect(sprite.animation == &"dash" and sprite.is_playing(), "Preview Dash button did not play dash")
	attack_button.pressed.emit()
	await process_frame
	_expect(sprite.animation == &"attack" and sprite.is_playing(), "Preview Attack button did not play attack")
	preview.queue_free()
	await process_frame


func _test_double_jump_contract() -> void:
	var world: Node2D = _create_world_with_floor(1800.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	_double_jump_events = 0
	player.double_jump_performed.connect(_on_double_jump_performed)
	await _wait_physics_frames(4)
	_expect(not player.has_double_jump, "Formal double-jump ability should default false")
	_expect(player.debug_enable_double_jump, "Debug double-jump switch should be enabled in the trial scene")
	_expect(player.air_jumps_remaining == 1, "Landing/start did not provision one debug air jump")

	await _press_for_physics(PlayerScript.JUMP_ACTION)
	_expect(player.velocity.y < 0.0, "First ground jump failed")
	_expect(player.air_jumps_remaining == 1, "Ground jump consumed the air jump")
	await _wait_physics_frames(12)
	_expect(player.get_coyote_time_remaining() <= 0.0, "Coyote timer did not expire before air jump")
	await _press_for_physics(PlayerScript.DASH_ACTION)
	_expect(not player.action_controller.is_action_active(), "Airborne Dash was incorrectly accepted")
	await _press_for_physics(PlayerScript.JUMP_ACTION)
	_expect(_double_jump_events == 1, "Legal second jump did not use the independent air-jump path")
	_expect(player.air_jumps_remaining == 0, "Second jump did not consume the air jump")
	_expect(player.get_jump_buffer_remaining() <= 0.0, "Double jump did not consume the shared input buffer")
	var velocity_after_second_jump: float = player.velocity.y
	await _wait_physics_frames(2)
	await _press_for_physics(PlayerScript.JUMP_ACTION)
	_expect(_double_jump_events == 1, "A third airborne jump was incorrectly accepted")
	_expect(player.velocity.y > velocity_after_second_jump, "Rejected third jump reset upward velocity")

	await _wait_until_grounded(player, 180)
	_expect(player.air_jumps_remaining == 1, "Landing did not restore the air jump")
	_cleanup_world(world)
	await process_frame


func _test_dash_contract() -> void:
	var world: Node2D = _create_world_with_floor(2200.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	var action_controller: PlayerActionController = player.get_node("ActionController") as PlayerActionController
	var sprite: AnimatedSprite2D = player.get_node("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	_action_started_events.clear()
	_action_finished_events.clear()
	action_controller.action_started.connect(_on_action_started)
	action_controller.action_finished.connect(_on_action_finished)
	await _wait_physics_frames(4)

	await _press_for_physics(PlayerScript.DASH_ACTION)
	_expect(action_controller.is_dash_active(), "Ground Dash did not start")
	_expect(sprite.animation == &"dash", "Dash did not select its animation")
	_expect(is_equal_approx(player.velocity.x, 480.0), "Dash did not apply 480 px/s")
	Input.action_press(PlayerScript.MOVE_LEFT_ACTION)
	await _wait_physics_frames(5)
	_expect(not sprite.flip_h, "Dash facing changed while locked")
	_expect(is_equal_approx(player.velocity.x, 480.0), "Normal horizontal control overrode Dash motion")
	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	var observed_recovery_window: bool = false
	for frame_index: int in range(12):
		await physics_frame
		if action_controller.get_dash_motion_remaining() <= 0.0:
			observed_recovery_window = true
			if action_controller.is_dash_active():
				_expect(is_zero_approx(player.velocity.x), "Dash recovery frame still applied travel velocity")
			else:
				_expect(_action_finished_events.has(&"dash"), "Dash ended without a completion event")
			break
	_expect(observed_recovery_window, "Dash travel timer did not reach its recovery window")
	await _wait_until_action_finished(action_controller, 12)
	_expect(_action_finished_events.has(&"dash"), "Dash did not finish")
	_expect(_action_started_events.count(&"dash") == 1, "Dash started more than once")
	_expect(sprite.animation == &"idle", "Dash did not return to idle without movement input")

	await _press_for_physics(PlayerScript.DASH_ACTION)
	_expect(not action_controller.is_dash_active(), "Dash cooldown allowed an immediate restart")
	await _wait_physics_frames(15)
	await _press_for_physics(PlayerScript.DASH_ACTION)
	_expect(action_controller.is_dash_active(), "Dash did not restart after cooldown")
	_cleanup_world(world)
	await process_frame


func _test_attack_contract() -> void:
	var world: Node2D = _create_world_with_floor(1800.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	var action_controller: PlayerActionController = player.get_node("ActionController") as PlayerActionController
	var sprite: AnimatedSprite2D = player.get_node("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	_action_started_events.clear()
	_action_finished_events.clear()
	action_controller.action_started.connect(_on_action_started)
	action_controller.action_finished.connect(_on_action_finished)
	await _wait_physics_frames(4)

	Input.action_press(PlayerScript.ATTACK_ACTION)
	Input.action_press(PlayerScript.DASH_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(PlayerScript.ATTACK_ACTION)
	Input.action_release(PlayerScript.DASH_ACTION)
	_expect(action_controller.get_action_name() == &"attack", "Attack did not win simultaneous action priority")
	_expect(sprite.animation == &"attack", "Attack did not select its animation")
	Input.action_press(PlayerScript.MOVE_LEFT_ACTION)
	await _wait_physics_frames(8)
	_expect(sprite.animation == &"attack", "Movement animation overrode Attack")
	_expect(not sprite.flip_h, "Attack facing changed while locked")
	await _press_for_physics(PlayerScript.ATTACK_ACTION)
	_expect(_action_started_events.count(&"attack") == 1, "Repeated input restarted Attack")
	await _wait_until_action_finished(action_controller, 40)
	_expect(_action_finished_events.has(&"attack"), "Attack did not emit completion")
	_expect(sprite.frame == 5 or sprite.animation == &"run", "Attack did not reach frame six or resume locomotion")
	await process_frame
	_expect(sprite.animation == &"run", "Attack did not return to run with held movement input")
	_expect(sprite.flip_h, "Queued left facing was not applied after Attack")
	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	await _wait_physics_frames(10)
	await _press_for_physics(PlayerScript.ATTACK_ACTION)
	await _wait_until_action_finished(action_controller, 40)
	_expect(sprite.animation == &"idle", "Attack did not return to idle without movement input")
	_cleanup_world(world)
	await process_frame


func _create_world_with_floor(width: float) -> Node2D:
	var world: Node2D = Node2D.new()
	var floor: StaticBody2D = StaticBody2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(width, 40.0)
	collision.position = Vector2(0, 300)
	collision.shape = shape
	floor.add_child(collision)
	world.add_child(floor)
	get_root().add_child(world)
	return world


func _spawn_player(world: Node2D, position: Vector2) -> Player:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	player.position = position
	world.add_child(player)
	return player


func _press_for_physics(action_name: StringName) -> void:
	Input.action_press(action_name)
	await _wait_physics_frames(2)
	Input.action_release(action_name)
	await physics_frame


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _wait_until_grounded(player: Player, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if player.is_on_floor():
			return
	_failures.append("Player did not land within test budget")


func _wait_until_action_finished(action_controller: PlayerActionController, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if not action_controller.is_action_active():
			return
	_failures.append("Player action did not finish within test budget")


func _action_has_physical_key(action_name: StringName, keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		var key_event: InputEventKey = event as InputEventKey
		if key_event != null and key_event.physical_keycode == keycode:
			return true
	return false


func _on_double_jump_performed(_air_jumps_remaining: int) -> void:
	_double_jump_events += 1


func _on_action_started(action_name: StringName) -> void:
	_action_started_events.append(action_name)


func _on_action_finished(action_name: StringName) -> void:
	_action_finished_events.append(action_name)


func _cleanup_world(world: Node2D) -> void:
	_release_all_inputs()
	world.queue_free()


func _release_all_inputs() -> void:
	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	Input.action_release(PlayerScript.JUMP_ACTION)
	Input.action_release(PlayerScript.DASH_ACTION)
	Input.action_release(PlayerScript.ATTACK_ACTION)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("M15_PLAYER_ACTION_TEST: PASS (assets, preview, double jump, dash, attack)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("M15_PLAYER_ACTION_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
