extends SceneTree

## Deterministic M1.5 Dash Attack input, state, motion, recovery, and boundary tests.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")
const Concept: Script = preload("res://scripts/tools/pixel_character_generator.gd")
const DASH_ATTACK_PATH: String = "res://assets/sprites/player/assassin/dash_attack/dash_attack_03.png"

var _failures: Array[String] = []
var _started_actions: Array[StringName] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_validate_configuration_and_art()
	await _test_standalone_and_dash_transition()
	await _test_near_simultaneous_inputs()
	await _test_late_input_and_repeat_guard()
	await _test_air_dash_attack()
	await _test_left_facing_and_wall_collision()
	await _test_debug_overlay()
	_release_inputs()
	_finish()


func _validate_configuration_and_art() -> void:
	_expect(PlayerScript.DASH_ACTION == &"dash", "Dash does not use the dash Input Map action")
	_expect(PlayerScript.ATTACK_ACTION == &"attack", "Attack does not use the attack Input Map action")
	_expect(not InputMap.has_action(&"player_attack"), "Deprecated player_attack Input Map alias exists")
	var config: PlayerActionPrototypeConfig = load(
		"res://resources/player/player_action_prototype_config.tres"
	) as PlayerActionPrototypeConfig
	_expect(config != null, "Action prototype configuration is missing")
	if config != null:
		_expect(is_equal_approx(config.dash_attack_input_window, 0.18), "Combination window is not 0.18 seconds")
		_expect(is_equal_approx(config.attack_buffer_time, 0.10), "Attack buffer is not 0.10 seconds")
		_expect(is_equal_approx(config.dash_attack_speed, 320.0), "Dash Attack speed is not centralized")
		_expect(
			is_equal_approx(config.dash_attack_move_duration + config.dash_attack_recovery_duration, 0.25),
			"Dash Attack movement/recovery does not match five frames at 20 FPS"
		)
	var sprite_frames: SpriteFrames = load(
		"res://resources/player/player_sprite_frames.tres"
	) as SpriteFrames
	_expect(sprite_frames != null and sprite_frames.has_animation(&"dash_attack"), "dash_attack animation is missing")
	if sprite_frames != null and sprite_frames.has_animation(&"dash_attack"):
		_expect(sprite_frames.get_frame_count(&"dash_attack") == 5, "dash_attack frame count is not five")
		_expect(is_equal_approx(sprite_frames.get_animation_speed(&"dash_attack"), 20.0), "dash_attack FPS is not 20")
		_expect(not sprite_frames.get_animation_loop(&"dash_attack"), "dash_attack unexpectedly loops")
	var core: Image = Image.load_from_file(ProjectSettings.globalize_path(DASH_ATTACK_PATH))
	_expect(core != null and core.get_size() == Vector2i(64, 64), "Dash Attack core is not 64x64")
	if core != null:
		_expect(_color_count(core, Concept.PALE_STEEL, Rect2i(53, 27, 11, 6)) >= 4, "Upper thrust blade is unreadable")
		_expect(_color_count(core, Concept.PALE_STEEL, Rect2i(52, 33, 12, 6)) >= 3, "Lower thrust blade is unreadable")
		_expect(_visible_right(core) >= 62, "Dash Attack core lacks a forward arrow point")
	for frame_index: int in [2, 3]:
		_expect(frame_index in PlayerAnimationController.DASH_ATTACK_HIT_FRAMES, "Future hit-window frame missing")


func _test_standalone_and_dash_transition() -> void:
	var world: Node2D = _create_world(2200.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	var actions: PlayerActionController = player.action_controller
	_connect_started(actions)
	await _wait_physics_frames(4)

	# Shift alone remains an ordinary Ground Dash.
	await _press_once(PlayerScript.DASH_ACTION)
	_expect(actions.is_ground_dash_active(), "Shift alone did not start Ground Dash")
	_expect(actions.is_dash_attack_input_window_open(), "Ground Dash combination window did not open")
	_expect(not actions.is_dash_attack_used(), "Ground Dash began with Dash Attack already used")
	await _wait_until_action_finished(actions, 30)
	_expect(not _started_actions.has(&"dash_attack"), "Shift alone incorrectly started Dash Attack")

	# A fresh Player avoids Dash cooldown and verifies Dash then J transition.
	_cleanup_world(world)
	await process_frame
	world = _create_world(2200.0)
	player = _spawn_player(world, Vector2(0, 252))
	actions = player.action_controller
	_connect_started(actions)
	await _wait_physics_frames(4)
	await _press_once(PlayerScript.DASH_ACTION)
	await _wait_physics_frames(2)
	await _press_once(PlayerScript.ATTACK_ACTION)
	_expect(actions.is_dash_attack_active(), "J inside Ground Dash did not enter Dash Attack")
	_expect(actions.is_dash_attack_used(), "Dash Attack did not consume the per-Dash use")
	_expect(player.animation_controller.animated_sprite.animation == &"dash_attack", "Wrong transition animation")
	_expect(absf(player.velocity.x) < 480.0, "Dash Attack incorrectly retained full Dash speed")
	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	await _wait_until_action_finished(actions, 40)
	await physics_frame
	_expect(player.animation_controller.animated_sprite.animation == &"run", "Ground Dash Attack did not recover to Run")
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	_cleanup_world(world)
	await process_frame


func _test_near_simultaneous_inputs() -> void:
	# The new immediate-response contract starts J now; Dash still cannot cancel Attack.
	var world: Node2D = _create_world(2200.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	var actions: PlayerActionController = player.action_controller
	_connect_started(actions)
	await _wait_physics_frames(4)
	await _press_once(PlayerScript.ATTACK_ACTION)
	_expect(actions.get_action_name() == &"attack", "J did not start normal Attack immediately")
	_expect(not actions.is_attack_buffered(), "Initial J was incorrectly stored as a future Attack")
	await _wait_physics_frames(3)
	await _press_once(PlayerScript.DASH_ACTION)
	_expect(actions.get_action_name() == &"attack", "Shift incorrectly cancelled active Attack")
	_expect(not actions.is_dash_attack_active(), "J-first input incorrectly became Dash Attack after Attack began")
	await _wait_until_action_finished(actions, 40)
	_cleanup_world(world)
	await process_frame

	# Exact same-frame input is also accepted directly.
	world = _create_world(2200.0)
	player = _spawn_player(world, Vector2(0, 252))
	actions = player.action_controller
	_connect_started(actions)
	await _wait_physics_frames(4)
	Input.action_press(PlayerScript.DASH_ACTION)
	Input.action_press(PlayerScript.ATTACK_ACTION)
	await physics_frame
	Input.action_release(PlayerScript.DASH_ACTION)
	Input.action_release(PlayerScript.ATTACK_ACTION)
	await physics_frame
	_expect(actions.is_dash_attack_active(), "Same-frame Shift/J did not start Dash Attack")
	_expect(_started_actions.count(&"dash_attack") == 1, "Same-frame chord started Dash Attack more than once")
	_cleanup_world(world)
	await process_frame


func _test_late_input_and_repeat_guard() -> void:
	var world: Node2D = _create_world(2200.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	var actions: PlayerActionController = player.action_controller
	_connect_started(actions)
	await _wait_physics_frames(4)
	await _press_once(PlayerScript.DASH_ACTION)
	await _wait_physics_frames(11)
	_expect(not actions.is_dash_attack_input_window_open(), "Dash Attack input window stayed open too long")
	await _press_once(PlayerScript.ATTACK_ACTION)
	_expect(not actions.is_dash_attack_active(), "Late J incorrectly entered Dash Attack")
	_expect(not actions.is_attack_buffered(), "Late Dash J leaked into a future normal Attack")
	await _wait_until_action_finished(actions, 20)
	_cleanup_world(world)
	await process_frame

	world = _create_world(2200.0)
	player = _spawn_player(world, Vector2(0, 252))
	actions = player.action_controller
	_connect_started(actions)
	await _wait_physics_frames(4)
	await _press_once(PlayerScript.DASH_ACTION)
	await _press_once(PlayerScript.ATTACK_ACTION)
	_expect(actions.is_dash_attack_active(), "Repeat-guard setup did not enter Dash Attack")
	for repeat_index: int in range(3):
		await _press_once(PlayerScript.ATTACK_ACTION)
		await _press_once(PlayerScript.DASH_ACTION)
	_expect(_started_actions.count(&"dash_attack") == 1, "Repeated input restarted Dash Attack")
	_expect(actions.is_dash_attack_active(), "Repeated input cancelled Dash Attack")
	await _wait_until_action_finished(actions, 40)
	_cleanup_world(world)
	await process_frame


func _test_air_dash_attack() -> void:
	var world: Node2D = _create_world(2600.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	var actions: PlayerActionController = player.action_controller
	_connect_started(actions)
	await _wait_physics_frames(4)
	await _press_once(PlayerScript.JUMP_ACTION)
	await _wait_physics_frames(5)
	await _press_once(PlayerScript.DASH_ACTION)
	_expect(actions.is_air_dash_active(), "Air Dash Attack setup did not enter Air Dash")
	await _press_once(PlayerScript.ATTACK_ACTION)
	_expect(actions.is_airborne_dash_attack_active(), "Air Dash J did not retain airborne Dash Attack origin")
	_expect(not player.air_dash_available, "Air Dash Attack restored Air Dash availability")
	_expect(is_zero_approx(player.velocity.y), "Air Dash Attack did not suspend vertical velocity")
	await _wait_until_action_finished(actions, 40)
	await _wait_physics_frames(2)
	_expect(player.get_movement_state_name() == &"fall", "Air Dash Attack did not recover to Fall")
	_expect(player.velocity.y > 0.0, "Gravity did not resume after Air Dash Attack")
	_expect(not player.air_dash_available, "Air Dash Attack completion refreshed Air Dash")
	await _press_once(PlayerScript.DASH_ACTION)
	_expect(not actions.is_dash_active(), "A second Air Dash started before landing")
	await _wait_until_grounded(player, 220)
	_expect(player.air_dash_available, "Landing did not restore Air Dash after Dash Attack")
	_cleanup_world(world)
	await process_frame


func _test_left_facing_and_wall_collision() -> void:
	var world: Node2D = _create_world(2200.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	var actions: PlayerActionController = player.action_controller
	await _wait_physics_frames(4)
	Input.action_press(PlayerScript.MOVE_LEFT_ACTION)
	await _wait_physics_frames(2)
	Input.action_press(PlayerScript.DASH_ACTION)
	Input.action_press(PlayerScript.ATTACK_ACTION)
	await physics_frame
	Input.action_release(PlayerScript.DASH_ACTION)
	Input.action_release(PlayerScript.ATTACK_ACTION)
	await physics_frame
	_expect(actions.is_dash_attack_active(), "Left chord did not start Dash Attack")
	_expect(actions.get_dash_direction() < 0.0 and player.velocity.x < 0.0, "Left Dash Attack moved right")
	_expect(player.animation_controller.animated_sprite.flip_h, "Left Dash Attack did not flip art")
	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	_cleanup_world(world)
	await process_frame

	world = _create_world(2200.0)
	_add_wall(world, 120.0)
	player = _spawn_player(world, Vector2(0, 252))
	actions = player.action_controller
	await _wait_physics_frames(4)
	Input.action_press(PlayerScript.DASH_ACTION)
	Input.action_press(PlayerScript.ATTACK_ACTION)
	await physics_frame
	Input.action_release(PlayerScript.DASH_ACTION)
	Input.action_release(PlayerScript.ATTACK_ACTION)
	await _wait_until_action_finished(actions, 40)
	_expect(player.position.x <= 98.5, "Dash Attack bypassed CharacterBody2D wall collision")
	_expect(player.find_children("*Hitbox*").is_empty(), "Dash Attack created an unauthorized Hitbox")
	_cleanup_world(world)
	await process_frame


func _test_debug_overlay() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	await process_frame
	await process_frame
	var debug_label: Label = main.get_node("Interface/Panel/ActionDebug") as Label
	var toggle: CheckButton = main.get_node("Interface/Panel/DebugToggle") as CheckButton
	_expect(debug_label.visible, "Action debug overlay is not initially visible in the test scene")
	for required_text: String in [
		"STATE", "COMBO WINDOW", "USED", "AIR DASH", "VX", "ATTACK FRAME",
		"BUFFERED", "TIMER", "CHAIN", "INPUT→HIT",
	]:
		_expect(debug_label.text.contains(required_text), "Debug overlay omits %s" % required_text)
	toggle.button_pressed = false
	await process_frame
	_expect(not debug_label.visible, "Action debug overlay cannot be disabled")
	main.queue_free()
	await process_frame


func _create_world(width: float) -> Node2D:
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


func _add_wall(world: Node2D, x_position: float) -> void:
	var wall: StaticBody2D = StaticBody2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(20.0, 240.0)
	collision.position = Vector2(x_position, 200.0)
	collision.shape = shape
	wall.add_child(collision)
	world.add_child(wall)


func _spawn_player(world: Node2D, position: Vector2) -> Player:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	player.position = position
	world.add_child(player)
	return player


func _connect_started(actions: PlayerActionController) -> void:
	_started_actions.clear()
	actions.action_started.connect(_on_action_started)


func _on_action_started(action_name: StringName) -> void:
	_started_actions.append(action_name)


func _press_once(action_name: StringName) -> void:
	Input.action_press(action_name)
	await physics_frame
	Input.action_release(action_name)
	await physics_frame


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _wait_until_action_finished(actions: PlayerActionController, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if not actions.is_action_active():
			return
	_failures.append("Player action did not finish within test budget")


func _wait_until_grounded(player: Player, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if player.is_on_floor():
			return
	_failures.append("Player did not land within test budget")


func _cleanup_world(world: Node2D) -> void:
	_release_inputs()
	world.queue_free()


func _release_inputs() -> void:
	for action_name: StringName in [
		PlayerScript.MOVE_LEFT_ACTION, PlayerScript.MOVE_RIGHT_ACTION, PlayerScript.JUMP_ACTION,
		PlayerScript.DASH_ACTION, PlayerScript.ATTACK_ACTION,
	]:
		Input.action_release(action_name)


func _color_count(image: Image, color: Color, area: Rect2i) -> int:
	var count: int = 0
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			if image.get_pixel(x, y) == color:
				count += 1
	return count


func _visible_right(image: Image) -> int:
	for x: int in range(image.get_width() - 1, -1, -1):
		for y: int in range(image.get_height()):
			if image.get_pixel(x, y).a > 0.0:
				return x
	return -1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("DASH_ATTACK_TEST: PASS (immediate J, transitions, air recovery, collision, debug HUD)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("DASH_ATTACK_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
