extends SceneTree

## Continuous Air Dash stamina, direction, gravity, edge input, and collision regressions.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")

var _failures: Array[String] = []
var _air_dash_starts: int = 0
var _animations_seen: Array[StringName] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_four_air_dash_chain_and_direction_change()
	await _test_shared_ground_air_stamina_pool()
	await _test_held_shift_and_air_wall_collision()
	await _test_airborne_regeneration_block_and_ground_delay()
	_release_inputs()
	_finish()


func _test_four_air_dash_chain_and_direction_change() -> void:
	var world: Node2D = _create_world(10000.0, false)
	var player: Player = _spawn_player(world, Vector2(0.0, 100.0))
	player.stamina_component.stamina_regen_rate = 0.0
	_air_dash_starts = 0
	_animations_seen.clear()
	player.action_controller.action_started.connect(_on_action_started)
	player.animation_controller.animation_changed.connect(_on_animation_changed)
	await _wait_physics_frames(3)
	await _tap_action(PlayerScript.DASH_ACTION)
	_expect(player.action_controller.is_air_dash_active(), "First airborne Shift did not start Air Dash")
	_expect(player.action_controller.get_current_dash_number() == 1, "First Air Dash number is wrong")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 75.0), "First Air Dash did not cost 25")
	_expect(player.animation_controller.animated_sprite.animation == &"air_dash_start", "Air chain did not begin at air_dash_start")

	Input.action_press(PlayerScript.MOVE_LEFT_ACTION)
	await _wait_physics_frames(5)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_for_dash_number(player.action_controller, 2, 14)
	_expect(player.action_controller.get_dash_direction() < 0.0, "Second Air Dash did not select left")
	_expect(player.velocity.x < 0.0, "Second Air Dash velocity contradicts left direction")
	_expect(player.animation_controller.animated_sprite.flip_h, "Second Air Dash facing contradicts left direction")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 50.0), "Second Air Dash cost is wrong")

	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	await _wait_physics_frames(3)
	_expect(player.action_controller.get_dash_direction() < 0.0, "Current Air Dash turned without a new Dash segment")
	_expect(player.velocity.x < 0.0 and player.animation_controller.animated_sprite.flip_h, "Locked Air Dash changed velocity/facing mid-segment")
	await _wait_physics_frames(2)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_for_dash_number(player.action_controller, 3, 14)
	_expect(player.action_controller.get_dash_direction() > 0.0, "Third Air Dash did not reselect right")
	_expect(player.velocity.x > 0.0 and not player.animation_controller.animated_sprite.flip_h, "Third Air Dash right direction is inconsistent")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 25.0), "Third Air Dash cost is wrong")

	await _wait_physics_frames(5)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_for_dash_number(player.action_controller, 4, 14)
	_expect(is_zero_approx(player.stamina_component.current_stamina), "Four Air Dashes did not consume full stamina")
	await _wait_physics_frames(5)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_until_action_finished(player.action_controller, 30)
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	_expect(_air_dash_starts == 4, "A fifth zero-stamina Air Dash incorrectly started")
	_expect(_animations_seen.count(&"air_dash_start") == 1, "Air Dash chain replayed its start phase")
	_expect(_animations_seen.count(&"air_dash_end") == 1, "Air Dash chain did not use one final end phase")
	_expect(_animations_seen.has(&"air_dash_loop"), "Air Dash chain never entered its loop phase")
	_expect(player.velocity.y > 0.0, "Gravity did not resume after the Air Dash end phase")
	_cleanup_world(world)
	await process_frame


func _test_shared_ground_air_stamina_pool() -> void:
	var world: Node2D = _create_world(300.0, false)
	var player: Player = _spawn_player(world, Vector2(0.0, 252.0))
	player.stamina_component.stamina_regen_rate = 0.0
	await _wait_physics_frames(5)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_physics_frames(5)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_for_dash_number(player.action_controller, 2, 14)
	await _wait_until_action_finished(player.action_controller, 30)
	_expect(is_equal_approx(player.stamina_component.current_stamina, 50.0), "Two Ground Dashes did not spend half of the shared pool")
	await _tap_action(PlayerScript.JUMP_ACTION)
	await _wait_physics_frames(4)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_physics_frames(5)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_for_dash_number(player.action_controller, 2, 14)
	_expect(is_zero_approx(player.stamina_component.current_stamina), "Two Ground plus two Air Dashes did not consume the shared pool")
	await _wait_until_action_finished(player.action_controller, 30)
	await _tap_action(PlayerScript.DASH_ACTION)
	_expect(not player.action_controller.is_action_active(), "Shared-pool fifth Dash incorrectly started")
	_expect(is_zero_approx(player.stamina_component.current_stamina), "Rejected shared-pool Dash changed stamina")
	_cleanup_world(world)
	await process_frame


func _test_held_shift_and_air_wall_collision() -> void:
	var world: Node2D = _create_world(10000.0, true)
	var player: Player = _spawn_player(world, Vector2(0.0, 100.0))
	player.stamina_component.stamina_regen_rate = 0.0
	_air_dash_starts = 0
	player.action_controller.action_started.connect(_on_action_started)
	await _wait_physics_frames(3)
	Input.action_press(PlayerScript.DASH_ACTION)
	await _wait_physics_frames(40)
	Input.action_release(PlayerScript.DASH_ACTION)
	await physics_frame
	_expect(_air_dash_starts == 1, "Holding Shift automatically repeated Air Dash")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 75.0), "Held Shift consumed more than one Air Dash charge")
	_expect(player.position.x <= 118.5, "Air Dash bypassed CharacterBody2D wall collision")
	_cleanup_world(world)
	await process_frame


func _test_airborne_regeneration_block_and_ground_delay() -> void:
	var world: Node2D = _create_world(10000.0, false)
	var player: Player = _spawn_player(world, Vector2(0.0, 100.0))
	await _wait_physics_frames(3)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_until_action_finished(player.action_controller, 30)
	await _wait_physics_frames(120)
	_expect(not player.is_on_floor(), "Air regeneration test unexpectedly landed")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 75.0), "Stamina regenerated while airborne")
	_expect(is_equal_approx(player.stamina_component.stamina_regen_timer, 0.60), "Airborne time advanced regeneration delay")
	_cleanup_world(world)
	await process_frame

	world = _create_world(300.0, false)
	player = _spawn_player(world, Vector2(0.0, 252.0))
	await _wait_physics_frames(5)
	await _tap_action(PlayerScript.JUMP_ACTION)
	await _wait_physics_frames(4)
	await _tap_action(PlayerScript.DASH_ACTION)
	await _wait_until_action_finished(player.action_controller, 30)
	await _wait_until_grounded(player, 180)
	var stamina_at_landing: float = player.stamina_component.current_stamina
	_expect(is_equal_approx(stamina_at_landing, 75.0), "Landing immediately refilled stamina")
	await _wait_physics_frames(34)
	_expect(is_equal_approx(player.stamina_component.current_stamina, stamina_at_landing), "Ground stamina regenerated before 0.60 seconds")
	await _wait_physics_frames(4)
	_expect(player.stamina_component.current_stamina > stamina_at_landing, "Ground stamina did not regenerate after delay")
	_cleanup_world(world)
	await process_frame


func _create_world(floor_y: float, include_wall: bool) -> Node2D:
	var world: Node2D = Node2D.new()
	var floor: StaticBody2D = StaticBody2D.new()
	var floor_collision: CollisionShape2D = CollisionShape2D.new()
	var floor_shape: RectangleShape2D = RectangleShape2D.new()
	floor_shape.size = Vector2(4000.0, 40.0)
	floor_collision.position = Vector2(0.0, floor_y)
	floor_collision.shape = floor_shape
	floor.add_child(floor_collision)
	world.add_child(floor)
	if include_wall:
		var wall: StaticBody2D = StaticBody2D.new()
		var wall_collision: CollisionShape2D = CollisionShape2D.new()
		var wall_shape: RectangleShape2D = RectangleShape2D.new()
		wall_shape.size = Vector2(20.0, 1000.0)
		wall_collision.position = Vector2(140.0, 100.0)
		wall_collision.shape = wall_shape
		wall.add_child(wall_collision)
		world.add_child(wall)
	get_root().add_child(world)
	return world


func _spawn_player(world: Node2D, spawn_position: Vector2) -> Player:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	player.position = spawn_position
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
	_failures.append("Air Dash chain did not reach segment %d" % target)


func _wait_until_action_finished(actions: PlayerActionController, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if not actions.is_action_active():
			return
	_failures.append("Air Dash action did not finish")


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
	if action_name == &"air_dash":
		_air_dash_starts += 1


func _on_animation_changed(animation_name: StringName) -> void:
	_animations_seen.append(animation_name)


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
		print("CONTINUOUS_AIR_DASH_TEST: PASS (four Air segments, mixed pool, direction, gravity, collision)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CONTINUOUS_AIR_DASH_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
