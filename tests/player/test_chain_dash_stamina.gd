extends SceneTree

## Deterministic chained Ground Dash, stamina, Air Dash, Dash Attack, HUD, and collision tests.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")

var _failures: Array[String] = []
var _ground_dash_starts: int = 0
var _insufficient_events: int = 0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_validate_configuration()
	_test_stamina_component_contract()
	await _test_four_segment_ground_chain_and_wall()
	await _test_held_shift_does_not_repeat()
	await _test_air_dash_and_dash_attack_costs()
	await _test_hud_binding()
	_release_inputs()
	_finish()


func _validate_configuration() -> void:
	var config: PlayerActionPrototypeConfig = load(
		"res://resources/player/player_action_prototype_config.tres"
	) as PlayerActionPrototypeConfig
	_expect(config != null, "Action configuration is missing")
	if config != null:
		_expect(is_equal_approx(config.dash_speed, 480.0), "Dash speed is not 480")
		_expect(is_equal_approx(config.dash_duration, 0.18), "Dash duration is not 0.18")
		_expect(is_equal_approx(config.dash_input_buffer_time, 0.10), "Dash buffer is not 0.10")
		_expect(is_equal_approx(config.dash_min_interval, 0.03), "Dash minimum interval is not 0.03")
	var frames: SpriteFrames = load("res://resources/player/player_sprite_frames.tres") as SpriteFrames
	for animation_name: StringName in [&"dash_start", &"dash_loop", &"dash_end"]:
		_expect(frames != null and frames.has_animation(animation_name), "Missing %s animation" % animation_name)
	if frames != null:
		_expect(frames.get_frame_count(&"dash_start") == 2, "dash_start is not two frames")
		_expect(frames.get_frame_count(&"dash_loop") == 3, "dash_loop is not three frames")
		_expect(frames.get_frame_count(&"dash_end") == 2, "dash_end is not two frames")
		_expect(frames.get_animation_loop(&"dash_loop"), "dash_loop is not looping")


func _test_stamina_component_contract() -> void:
	var stamina: PlayerStaminaComponent = PlayerStaminaComponent.new()
	get_root().add_child(stamina)
	_expect(is_equal_approx(stamina.current_stamina, 100.0), "Stamina did not initialize full")
	_expect(stamina.try_consume_dash(), "First stamina charge was rejected")
	_expect(is_equal_approx(stamina.current_stamina, 75.0), "Dash did not cost 25 stamina")
	stamina.advance(0.59, false)
	_expect(is_equal_approx(stamina.current_stamina, 75.0), "Stamina regenerated before 0.60 seconds")
	stamina.advance(0.02, false)
	_expect(stamina.current_stamina > 75.0, "Stamina did not regenerate after delay")
	var before_block: float = stamina.current_stamina
	stamina.advance(1.0, true)
	_expect(is_equal_approx(stamina.current_stamina, before_block), "Blocked Dash state regenerated stamina")
	stamina.queue_free()


func _test_four_segment_ground_chain_and_wall() -> void:
	var world: Node2D = _create_world(true)
	var player: Player = _spawn_player(world)
	player.stamina_component.stamina_regen_rate = 0.0
	_ground_dash_starts = 0
	_insufficient_events = 0
	player.action_controller.action_started.connect(_on_action_started)
	player.stamina_component.stamina_insufficient.connect(_on_stamina_insufficient)
	await _wait_physics_frames(5)
	await _tap_action(PlayerScript.DASH_ACTION)
	_expect(player.action_controller.get_current_dash_number() == 1, "First Ground Dash did not start")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 75.0), "First Dash charge is wrong")
	for target_dash: int in range(2, 5):
		await _wait_physics_frames(5)
		await _tap_action(PlayerScript.DASH_ACTION)
		await _wait_for_dash_number(player.action_controller, target_dash, 12)
	_expect(_ground_dash_starts == 4, "Four independent Shift edges did not produce four Dash starts")
	_expect(is_zero_approx(player.stamina_component.current_stamina), "Four Dashes did not consume full stamina")
	await _wait_physics_frames(5)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_until_action_finished(player.action_controller, 30)
	_expect(_ground_dash_starts == 4, "A fifth zero-stamina Dash incorrectly started")
	_expect(_insufficient_events == 1, "Rejected fifth Dash did not emit one insufficient event")
	_expect(is_zero_approx(player.stamina_component.current_stamina), "Rejected Dash changed stamina")
	_expect(player.position.x <= 118.5, "Chained Dash bypassed CharacterBody2D wall collision")
	_cleanup_world(world)
	await process_frame


func _test_held_shift_does_not_repeat() -> void:
	var world: Node2D = _create_world(false)
	var player: Player = _spawn_player(world)
	player.stamina_component.stamina_regen_rate = 0.0
	_ground_dash_starts = 0
	player.action_controller.action_started.connect(_on_action_started)
	await _wait_physics_frames(5)
	Input.action_press(PlayerScript.DASH_ACTION)
	await _wait_physics_frames(45)
	Input.action_release(PlayerScript.DASH_ACTION)
	await physics_frame
	_expect(_ground_dash_starts == 1, "Holding Shift automatically repeated Ground Dash")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 75.0), "Held Shift consumed more than one Dash charge")
	_cleanup_world(world)
	await process_frame


func _test_air_dash_and_dash_attack_costs() -> void:
	var world: Node2D = _create_world(false)
	var player: Player = _spawn_player(world)
	player.stamina_component.stamina_regen_rate = 0.0
	await _wait_physics_frames(5)
	await _tap_action(PlayerScript.JUMP_ACTION)
	await _wait_physics_frames(4)
	await _tap_action(PlayerScript.DASH_ACTION)
	_expect(player.action_controller.is_air_dash_active(), "Air Dash did not start")
	_expect(not player.air_dash_available, "Air Dash qualification was not consumed")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 75.0), "Air Dash did not cost 25")
	await _tap_action(PlayerScript.DASH_ACTION)
	_expect(is_equal_approx(player.stamina_component.current_stamina, 75.0), "Second airborne Shift consumed stamina")
	await _tap_action(PlayerScript.ATTACK_ACTION)
	_expect(player.action_controller.is_dash_attack_active(), "Air Dash did not transition to Dash Attack")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 75.0), "Dash Attack charged stamina twice")
	await _wait_until_action_finished(player.action_controller, 40)
	await _wait_until_grounded(player, 180)
	_expect(player.air_dash_available, "Landing did not restore Air Dash qualification")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 75.0), "Landing refilled stamina")
	_cleanup_world(world)
	await process_frame


func _test_hud_binding() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	get_root().add_child(main)
	await process_frame
	var stamina: PlayerStaminaComponent = main.get_node("World/Player/StaminaComponent") as PlayerStaminaComponent
	var bar: ProgressBar = main.get_node("HUD/StaminaContainer/StaminaBar") as ProgressBar
	var value_label: Label = main.get_node("HUD/StaminaContainer/StaminaValue") as Label
	_expect(stamina != null and bar != null and value_label != null, "Functional stamina HUD nodes are missing")
	if stamina != null and bar != null and value_label != null:
		stamina.try_consume_dash()
		await process_frame
		_expect(is_equal_approx(bar.value, 75.0), "HUD bar did not follow stamina signal")
		_expect(value_label.text == "075 / 100", "HUD numeric stamina is out of sync")
	main.queue_free()
	await process_frame


func _create_world(include_wall: bool) -> Node2D:
	var world: Node2D = Node2D.new()
	var floor: StaticBody2D = StaticBody2D.new()
	var floor_collision: CollisionShape2D = CollisionShape2D.new()
	var floor_shape: RectangleShape2D = RectangleShape2D.new()
	floor_shape.size = Vector2(2200.0, 40.0)
	floor_collision.position = Vector2(0.0, 300.0)
	floor_collision.shape = floor_shape
	floor.add_child(floor_collision)
	world.add_child(floor)
	if include_wall:
		var wall: StaticBody2D = StaticBody2D.new()
		var wall_collision: CollisionShape2D = CollisionShape2D.new()
		var wall_shape: RectangleShape2D = RectangleShape2D.new()
		wall_shape.size = Vector2(20.0, 240.0)
		wall_collision.position = Vector2(140.0, 210.0)
		wall_collision.shape = wall_shape
		wall.add_child(wall_collision)
		world.add_child(wall)
	get_root().add_child(world)
	return world


func _spawn_player(world: Node2D) -> Player:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	player.position = Vector2(0.0, 252.0)
	world.add_child(player)
	return player


func _tap_action(action_name: StringName) -> void:
	Input.action_press(action_name)
	await physics_frame
	Input.action_release(action_name)
	await physics_frame


func _wait_for_dash_number(actions: PlayerActionController, target: int, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		if actions.get_current_dash_number() == target:
			return
		await physics_frame
	_failures.append("Ground Dash chain did not reach segment %d" % target)


func _wait_until_action_finished(actions: PlayerActionController, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if not actions.is_action_active():
			return
	_failures.append("Action did not finish within test budget")


func _wait_until_grounded(player: Player, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if player.is_on_floor():
			return
	_failures.append("Player did not land within test budget")


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _on_action_started(action_name: StringName) -> void:
	if action_name == &"ground_dash":
		_ground_dash_starts += 1


func _on_stamina_insufficient() -> void:
	_insufficient_events += 1


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
		print("CHAIN_DASH_STAMINA_TEST: PASS (edge chaining, four charges, air limit, HUD, collision)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CHAIN_DASH_STAMINA_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
