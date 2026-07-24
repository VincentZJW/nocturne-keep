extends SceneTree

## Reproducible 60 Hz movement-envelope measurements for level-design documentation.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_measure")


func _measure() -> void:
	var standing_single_jump: Dictionary = await _measure_jump(false, false)
	var standing_double_jump: Dictionary = await _measure_jump(true, false)
	var single_jump: Dictionary = await _measure_jump(false, true)
	var double_jump: Dictionary = await _measure_jump(true, true)
	var single_air_dash: Dictionary = await _measure_jump_with_one_air_dash(false)
	var double_air_dash: Dictionary = await _measure_jump_with_one_air_dash(true)
	var air_dash: Dictionary = await _measure_four_air_dashes()
	if not _failures.is_empty():
		for failure: String in _failures:
			push_error(failure)
		print("PLAYER_LEVEL_METRICS: FAIL (%d issues)" % _failures.size())
		quit(1)
		return
	var metrics_message: String = (
		"PLAYER_LEVEL_METRICS: PASS physics_fps=%d standing_single_rise=%.2f "
		+ "standing_double_rise=%.2f single_jump_range=%.2f single_jump_rise=%.2f "
		+ "double_jump_range=%.2f double_jump_rise=%.2f single_plus_air_dash=%.2f "
		+ "double_plus_air_dash=%.2f four_air_dash_range=%.2f "
		+ "four_air_dash_total_to_landing=%.2f foot_offset=%.2f "
		+ "platform_center_to_safe_edge=%.2f minimum_safe_landing_width=%.2f"
	) % [
			Engine.physics_ticks_per_second,
			standing_single_jump["rise"],
			standing_double_jump["rise"],
			single_jump["range"],
			single_jump["rise"],
			double_jump["range"],
			double_jump["rise"],
			single_air_dash["range"],
			double_air_dash["range"],
			air_dash["dash_range"],
			air_dash["landing_range"],
			28.0,
			98.0,
			48.0,
		]
	print(metrics_message)
	quit(0)


func _measure_jump(use_double_jump: bool, move_forward: bool) -> Dictionary:
	var world: Node2D = _create_world()
	var player: Player = _spawn_player(world, use_double_jump)
	await _wait_physics_frames(5)
	var start_position: Vector2 = player.position
	var minimum_y: float = start_position.y
	var second_jump_sent: bool = false
	if move_forward:
		Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	await _tap_action(PlayerScript.JUMP_ACTION)
	var left_floor: bool = false
	for frame_index: int in range(300):
		await physics_frame
		left_floor = left_floor or not player.is_on_floor()
		minimum_y = minf(minimum_y, player.position.y)
		if (
			use_double_jump
			and left_floor
			and not second_jump_sent
			and player.velocity.y >= -10.0
		):
			second_jump_sent = true
			await _tap_action(PlayerScript.JUMP_ACTION)
		if left_floor and player.is_on_floor():
			break
	if move_forward:
		Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	if not left_floor or not player.is_on_floor():
		_failures.append("Jump measurement did not return to the floor")
	if use_double_jump and not second_jump_sent:
		_failures.append("Double-jump measurement did not trigger its air jump")
	var result: Dictionary = {
		"range": player.position.x - start_position.x,
		"rise": start_position.y - minimum_y,
	}
	_cleanup_world(world)
	await process_frame
	return result


func _measure_jump_with_one_air_dash(use_double_jump: bool) -> Dictionary:
	var world: Node2D = _create_world()
	var player: Player = _spawn_player(world, use_double_jump)
	await _wait_physics_frames(5)
	var start_position: Vector2 = player.position
	var minimum_y: float = start_position.y
	var second_jump_sent: bool = false
	var dash_sent: bool = false
	var left_floor: bool = false
	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	await _tap_action(PlayerScript.JUMP_ACTION)
	for frame_index: int in range(360):
		await physics_frame
		left_floor = left_floor or not player.is_on_floor()
		minimum_y = minf(minimum_y, player.position.y)
		if (
			use_double_jump
			and left_floor
			and not second_jump_sent
			and player.velocity.y >= -10.0
		):
			second_jump_sent = true
			await _tap_action(PlayerScript.JUMP_ACTION)
		elif (
			left_floor
			and not dash_sent
			and player.velocity.y >= -10.0
			and (not use_double_jump or second_jump_sent)
		):
			dash_sent = true
			await _tap_action(PlayerScript.DASH_ACTION)
		if left_floor and player.is_on_floor():
			break
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	if not dash_sent:
		_failures.append("One-Air-Dash measurement did not trigger Dash")
	if use_double_jump and not second_jump_sent:
		_failures.append("Double-jump plus Air Dash measurement missed air jump")
	if not player.is_on_floor():
		_failures.append("One-Air-Dash measurement did not return to the floor")
	var result: Dictionary = {
		"range": player.position.x - start_position.x,
		"rise": start_position.y - minimum_y,
	}
	_cleanup_world(world)
	await process_frame
	return result


func _measure_four_air_dashes() -> Dictionary:
	var world: Node2D = _create_world()
	var player: Player = _spawn_player(world, true)
	await _wait_physics_frames(5)
	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	await _tap_action(PlayerScript.JUMP_ACTION)
	await _wait_physics_frames(3)
	var takeoff_x: float = player.position.x
	await _tap_action(PlayerScript.DASH_ACTION)
	var dash_start_x: float = player.position.x
	for target_dash_number: int in range(2, 5):
		while (
			player.action_controller.is_dash_active()
			and player.action_controller.get_dash_motion_remaining() > 0.08
		):
			await physics_frame
		await _tap_action(PlayerScript.DASH_ACTION)
		for wait_frame: int in range(20):
			if player.action_controller.get_current_dash_number() >= target_dash_number:
				break
			await physics_frame
		if player.action_controller.get_current_dash_number() < target_dash_number:
			_failures.append("Four-dash metric missed Air Dash segment %d" % target_dash_number)
			break
	while player.action_controller.is_action_active():
		await physics_frame
	var dash_end_x: float = player.position.x
	for frame_index: int in range(300):
		await physics_frame
		if player.is_on_floor():
			break
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	if not player.is_on_floor():
		_failures.append("Four-dash measurement did not return to the floor")
	var result: Dictionary = {
		"dash_range": dash_end_x - dash_start_x,
		"landing_range": player.position.x - takeoff_x,
	}
	_cleanup_world(world)
	await process_frame
	return result


func _create_world() -> Node2D:
	var world: Node2D = Node2D.new()
	var floor: StaticBody2D = StaticBody2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(8000.0, 40.0)
	collision.position = Vector2(0.0, 300.0)
	collision.shape = shape
	floor.add_child(collision)
	world.add_child(floor)
	get_root().add_child(world)
	return world


func _spawn_player(world: Node2D, double_jump_enabled: bool) -> Player:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	player.position = Vector2(0.0, 252.0)
	player.debug_enable_double_jump = double_jump_enabled
	player.has_double_jump = false
	world.add_child(player)
	player.stamina_component.stamina_regen_rate = 0.0
	return player


func _tap_action(action_name: StringName) -> void:
	Input.action_press(action_name)
	await physics_frame
	Input.action_release(action_name)
	await physics_frame


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _cleanup_world(world: Node2D) -> void:
	for action_name: StringName in [
		PlayerScript.MOVE_RIGHT_ACTION,
		PlayerScript.JUMP_ACTION,
		PlayerScript.DASH_ACTION,
	]:
		Input.action_release(action_name)
	world.queue_free()
