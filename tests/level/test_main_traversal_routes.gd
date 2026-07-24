extends SceneTree

## Three spawn-to-route runs using real Input actions and no position teleport after spawn.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_mainline_without_air_dash()
	await _test_mobility_crossbow_route()
	await _test_novice_timing_gargoyle_route()
	_finish()


func _test_mainline_without_air_dash() -> void:
	var main: Node2D = await _spawn_main_for_traversal()
	var player: Player = main.get_node("World/Player") as Player
	Input.action_press(Player.MOVE_RIGHT_ACTION)
	var bridge_jump_started: bool = false
	var bridge_jump_released: bool = false
	for frame_index: int in range(2200):
		await physics_frame
		if not bridge_jump_started and player.global_position.x >= 5470.0:
			Input.action_press(Player.JUMP_ACTION)
			bridge_jump_started = true
		elif bridge_jump_started and not bridge_jump_released:
			Input.action_release(Player.JUMP_ACTION)
			bridge_jump_released = true
		if player.global_position.x >= 5740.0:
			break
	Input.action_release(Player.MOVE_RIGHT_ACTION)
	Input.action_release(Player.JUMP_ACTION)
	_expect(player.global_position.x >= 5740.0, "No-Air-Dash mainline did not reach the bridge Boss entry")
	_expect(bridge_jump_started, "Mainline did not issue the near-bank bridge-entry jump")
	var groups: Array[Node] = main.get_node("World/Encounters").get_children()
	for group_node: Node in groups:
		var group: EncounterGroup = group_node as EncounterGroup
		if group != null:
			_expect(group.is_activated, "%s was not entered on the floor mainline" % group.name)
	_cleanup_main(main)


func _test_mobility_crossbow_route() -> void:
	var main: Node2D = await _spawn_main_for_traversal()
	var player: Player = main.get_node("World/Player") as Player
	await _move_to_floor_x(player, 2650.0)
	await _perform_double_jump_to_surface(player, 2780.0, 500.0, 0.0, false)
	_expect(absf(_player_foot_y(player) - 500.0) <= 1.5, "Route 2 did not land on PlatformB")
	await _move_to_floor_x(player, 4280.0)
	await _perform_double_jump_to_surface(player, 4420.0, 504.0, 0.0, true)
	_expect(absf(_player_foot_y(player) - 504.0) <= 1.5, "Route 2 double-jump + Air Dash did not land on PlatformC")
	await _move_to_floor_x(player, 5020.0)
	await _perform_double_jump_to_surface(player, 5160.0, 508.0, 0.0, false)
	_expect(absf(_player_foot_y(player) - 508.0) <= 1.5, "Route 2 did not land on PlatformD")
	_cleanup_main(main)


func _test_novice_timing_gargoyle_route() -> void:
	var main: Node2D = await _spawn_main_for_traversal()
	var player: Player = main.get_node("World/Player") as Player
	await _move_to_floor_x(player, 3410.0)
	await _perform_double_jump_to_surface(player, 3560.0, 492.0, 50.0, false)
	_expect(absf(_player_foot_y(player) - 492.0) <= 1.5, "Delayed novice double jump did not land on GargoylePerch")
	_cleanup_main(main)


func _spawn_main_for_traversal() -> Node2D:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	await _wait_physics_frames(8)
	var player: Player = main.get_node("World/Player") as Player
	player.hurtbox.set_enabled(false)
	for group_node: Node in main.get_node("World/Encounters").get_children():
		var group: EncounterGroup = group_node as EncounterGroup
		if group == null:
			continue
		for enemy: EnemyCombatant in group.get_enemies():
			enemy.collision_layer = 0
			enemy.collision_mask = 0
			enemy.set_ai_active(false)
	return main


func _move_to_floor_x(player: Player, target_x: float) -> void:
	if not player.is_on_floor() or _player_foot_y(player) < 620.0:
		Input.action_press(Player.MOVE_RIGHT_ACTION)
		for frame_index: int in range(240):
			await physics_frame
			if player.is_on_floor() and _player_foot_y(player) >= 639.0:
				break
		Input.action_release(Player.MOVE_RIGHT_ACTION)
	for frame_index: int in range(1800):
		var difference: float = target_x - player.global_position.x
		if absf(difference) <= 3.0 and absf(player.velocity.x) <= 8.0:
			break
		if difference > 3.0:
			Input.action_release(Player.MOVE_LEFT_ACTION)
			Input.action_press(Player.MOVE_RIGHT_ACTION)
		elif difference < -3.0:
			Input.action_release(Player.MOVE_RIGHT_ACTION)
			Input.action_press(Player.MOVE_LEFT_ACTION)
		else:
			Input.action_release(Player.MOVE_LEFT_ACTION)
			Input.action_release(Player.MOVE_RIGHT_ACTION)
		await physics_frame
	Input.action_release(Player.MOVE_LEFT_ACTION)
	Input.action_release(Player.MOVE_RIGHT_ACTION)
	await _wait_physics_frames(10)
	_expect(absf(player.global_position.x - target_x) <= 8.0, "Could not approach route target x=%.0f" % target_x)


func _perform_double_jump_to_surface(
	player: Player,
	target_x: float,
	target_top_y: float,
	second_jump_fall_velocity: float,
	use_air_dash: bool
) -> void:
	var start_x: float = player.global_position.x
	await _tap_action(Player.JUMP_ACTION)
	var second_jump_sent: bool = false
	var dash_sent: bool = false
	var left_floor: bool = false
	var cleared_platform_top: bool = false
	for frame_index: int in range(360):
		await physics_frame
		cleared_platform_top = cleared_platform_top or _player_foot_y(player) <= target_top_y - 8.0
		if cleared_platform_top:
			var horizontal_error: float = target_x - player.global_position.x
			if horizontal_error > 10.0:
				Input.action_release(Player.MOVE_LEFT_ACTION)
				Input.action_press(Player.MOVE_RIGHT_ACTION)
			elif horizontal_error < -10.0:
				Input.action_release(Player.MOVE_RIGHT_ACTION)
				Input.action_press(Player.MOVE_LEFT_ACTION)
			else:
				Input.action_release(Player.MOVE_LEFT_ACTION)
				Input.action_release(Player.MOVE_RIGHT_ACTION)
		left_floor = left_floor or not player.is_on_floor()
		if left_floor and not second_jump_sent and player.velocity.y >= second_jump_fall_velocity:
			second_jump_sent = true
			await _tap_action(Player.JUMP_ACTION)
		elif use_air_dash and cleared_platform_top and second_jump_sent and not dash_sent and player.velocity.y >= -10.0:
			dash_sent = true
			await _tap_action(Player.DASH_ACTION)
		if left_floor and player.is_on_floor():
			if absf(_player_foot_y(player) - target_top_y) <= 1.5:
				break
	_expect(second_jump_sent, "Route double jump was not accepted")
	_expect(not use_air_dash or dash_sent, "Route Air Dash was not accepted")
	_expect(absf(_player_foot_y(player) - target_top_y) <= 1.5, "Route missed target surface y=%.0f from x=%.0f" % [target_top_y, start_x])
	Input.action_release(Player.MOVE_RIGHT_ACTION)
	Input.action_release(Player.MOVE_LEFT_ACTION)
	Input.action_release(Player.JUMP_ACTION)
	Input.action_release(Player.DASH_ACTION)


func _player_foot_y(player: Player) -> float:
	var collision: CollisionShape2D = player.get_node("CollisionShape2D") as CollisionShape2D
	var shape: RectangleShape2D = collision.shape as RectangleShape2D
	return player.global_position.y + collision.position.y + shape.size.y * 0.5


func _tap_action(action_name: StringName) -> void:
	Input.action_press(action_name)
	await physics_frame
	Input.action_release(action_name)
	await physics_frame


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _cleanup_main(main: Node2D) -> void:
	for action: StringName in [Player.MOVE_LEFT_ACTION, Player.MOVE_RIGHT_ACTION, Player.JUMP_ACTION, Player.DASH_ACTION]:
		Input.action_release(action)
	main.queue_free()
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("MAIN_TRAVERSAL_ROUTES_TEST: PASS (mainline no Air Dash, mobility Crossbow route, novice-timing Gargoyle route; no teleport)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("MAIN_TRAVERSAL_ROUTES_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
