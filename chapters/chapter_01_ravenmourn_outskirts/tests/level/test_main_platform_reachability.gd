extends SceneTree

## Saved F5 Main traversal audit plus real Player/physics landing checks.

const MAIN_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn")
const MAIN_PATH: String = "res://scenes/cinematics/opening_cinematic.tscn"
const DOUBLE_JUMP_RISE: float = 167.10
const CHALLENGE_LIMIT: float = DOUBLE_JUMP_RISE * 0.90
const MINIMUM_SAFE_WIDTH: float = 48.0
const PLATFORM_PATHS: Array[NodePath] = [
	NodePath("World/PlatformA"),
	NodePath("World/PlatformB"),
	NodePath("World/PlatformC"),
	NodePath("World/PlatformD"),
	NodePath("World/GargoylePerch"),
]
const EXPECTED_TOPS: Array[float] = [508.0, 500.0, 504.0, 508.0, 492.0]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "") == MAIN_PATH,
		"F5 does not resolve to the authored opening before Main"
	)
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	var player: Player = main.get_node_or_null("World/Player") as Player
	_expect(player != null, "Main Player is missing")
	if player == null:
		_finish(main)
		return
	await _wait_physics_frames(8)
	_disable_encounters(main)
	_test_saved_platform_geometry(main)
	_test_enemy_platform_alignment(main)
	for index: int in range(PLATFORM_PATHS.size()):
		var platform: StaticBody2D = main.get_node_or_null(PLATFORM_PATHS[index]) as StaticBody2D
		if platform != null:
			await _test_solid_ceiling_and_landing(player, platform, EXPECTED_TOPS[index])
	var dash_platform: StaticBody2D = main.get_node_or_null("World/PlatformA") as StaticBody2D
	if dash_platform != null:
		await _test_high_speed_side_blocking(player, dash_platform)
	_finish(main)


func _test_saved_platform_geometry(main: Node2D) -> void:
	var floor: StaticBody2D = main.get_node_or_null("World/Floor") as StaticBody2D
	_expect(floor != null, "Main Floor is missing")
	var floor_top: float = _surface_top(floor)
	_expect(is_equal_approx(floor_top, 640.0), "Main Floor top changed unexpectedly")
	for index: int in range(PLATFORM_PATHS.size()):
		var platform: StaticBody2D = main.get_node_or_null(PLATFORM_PATHS[index]) as StaticBody2D
		_expect(platform != null, "%s is missing" % PLATFORM_PATHS[index])
		if platform == null:
			continue
		var collision: CollisionShape2D = platform.get_node_or_null("CollisionShape2D") as CollisionShape2D
		var shape: RectangleShape2D = collision.shape as RectangleShape2D if collision != null else null
		_expect(collision != null and shape != null, "%s lacks rectangular collision" % platform.name)
		if collision == null or shape == null:
			continue
		var top_y: float = _surface_top(platform)
		var rise: float = floor_top - top_y
		_expect(is_equal_approx(top_y, EXPECTED_TOPS[index]), "%s top surface mismatch" % platform.name)
		_expect(rise <= CHALLENGE_LIMIT, "%s exceeds the 90%% stable double-jump limit" % platform.name)
		_expect(shape.size.x >= MINIMUM_SAFE_WIDTH, "%s is narrower than the safe landing width" % platform.name)
		_expect(not collision.one_way_collision, "%s is not a full solid surface" % platform.name)


func _test_enemy_platform_alignment(main: Node2D) -> void:
	var crossbow_paths: Array[NodePath] = [
		NodePath("World/Encounters/ApproachOptional01/Enemies/ApproachCrossbowman02"),
	]
	var platform_paths: Array[NodePath] = [
		NodePath("World/PlatformD"),
	]
	for index: int in range(crossbow_paths.size()):
		var enemy: FallenCrossbowman = main.get_node_or_null(crossbow_paths[index]) as FallenCrossbowman
		var platform: StaticBody2D = main.get_node_or_null(platform_paths[index]) as StaticBody2D
		_expect(enemy != null and platform != null, "Crossbow platform binding is incomplete")
		if enemy == null or platform == null:
			continue
		var shape: RectangleShape2D = _surface_shape(platform)
		_expect(is_equal_approx(enemy.global_position.y, _surface_top(platform) - 30.0), "%s does not stand on its platform" % enemy.name)
		_expect(absf(enemy.global_position.x - platform.global_position.x) <= shape.size.x * 0.5 - 16.0, "%s lacks edge safety margin" % enemy.name)
	var perch: StaticBody2D = main.get_node_or_null("World/GargoylePerch") as StaticBody2D
	var perch_shape: RectangleShape2D = _surface_shape(perch)
	for gargoyle_path: NodePath in [
		NodePath("World/Encounters/ForestEncounter03/Enemies/ForestGargoyle01"),
	]:
		var gargoyle: GargoyleSentinel = main.get_node_or_null(gargoyle_path) as GargoyleSentinel
		_expect(gargoyle != null, "%s is missing" % gargoyle_path)
		if gargoyle != null:
			_expect(absf(gargoyle.global_position.x - perch.global_position.x) <= perch_shape.size.x * 0.5 - 16.0, "%s starts outside the perch" % gargoyle.name)
			_expect(gargoyle.global_position.y < _surface_top(perch) - 48.0, "%s lacks dive clearance" % gargoyle.name)


func _test_solid_ceiling_and_landing(player: Player, platform: StaticBody2D, top_y: float) -> void:
	player.action_controller.cancel_all_actions()
	player.velocity = Vector2.ZERO
	player.global_position = Vector2(platform.global_position.x, 612.0)
	player.debug_enable_double_jump = true
	await _wait_physics_frames(5)
	await _tap_action(Player.JUMP_ACTION)
	var first_ceiling_hit: bool = false
	var minimum_root_y: float = player.global_position.y
	for frame_index: int in range(120):
		await physics_frame
		minimum_root_y = minf(minimum_root_y, player.global_position.y)
		if player.is_on_ceiling():
			first_ceiling_hit = true
			break
	var expected_ceiling_root_y: float = top_y + 24.0 + 24.0
	_expect(first_ceiling_hit, "%s underside did not report a ceiling collision" % platform.name)
	_expect(minimum_root_y >= expected_ceiling_root_y - 1.5, "%s single jump penetrated the underside" % platform.name)
	_expect(player.velocity.y >= 0.0, "%s retained upward velocity after ceiling impact" % platform.name)
	await _tap_action(Player.JUMP_ACTION)
	for frame_index: int in range(8):
		await physics_frame
		minimum_root_y = minf(minimum_root_y, player.global_position.y)
	_expect(minimum_root_y >= expected_ceiling_root_y - 1.5, "%s double jump penetrated the underside" % platform.name)
	player.action_controller.cancel_all_actions()
	player.velocity = Vector2.ZERO
	player.global_position = Vector2(platform.global_position.x, top_y - 100.0)
	for frame_index: int in range(120):
		await physics_frame
		if player.is_on_floor():
			break
	_expect(player.is_on_floor(), "%s top did not support the Player" % platform.name)
	_expect(absf(_player_foot_y(player) - top_y) <= 1.5, "%s top landing baseline is misaligned" % platform.name)
	Input.action_release(Player.JUMP_ACTION)


func _test_high_speed_side_blocking(player: Player, platform: StaticBody2D) -> void:
	var shape: RectangleShape2D = _surface_shape(platform)
	var platform_left: float = platform.global_position.x - shape.size.x * 0.5
	var maximum_root_x: float = platform_left - 12.0
	for use_attack: bool in [false, true]:
		player.action_controller.cancel_all_actions()
		player.stamina_component.reset_to_full()
		player.velocity = Vector2.ZERO
		player.global_position = Vector2(platform_left - 76.0, platform.global_position.y)
		Input.action_press(Player.MOVE_RIGHT_ACTION)
		Input.action_press(Player.DASH_ACTION)
		if use_attack:
			Input.action_press(Player.ATTACK_ACTION)
		await physics_frame
		Input.action_release(Player.DASH_ACTION)
		Input.action_release(Player.ATTACK_ACTION)
		var furthest_x: float = player.global_position.x
		for frame_index: int in range(16):
			await physics_frame
			furthest_x = maxf(furthest_x, player.global_position.x)
		Input.action_release(Player.MOVE_RIGHT_ACTION)
		_expect(
			furthest_x <= maximum_root_x + 1.5,
			"%s crossed PlatformA solid side" % ("Dash Attack" if use_attack else "Air Dash")
		)


func _disable_encounters(main: Node2D) -> void:
	var encounters: Node2D = main.get_node_or_null("World/Encounters") as Node2D
	if encounters != null:
		encounters.process_mode = Node.PROCESS_MODE_DISABLED
	for enemy: Node in get_nodes_in_group("enemies"):
		var combatant: EnemyCombatant = enemy as EnemyCombatant
		if combatant != null:
			combatant.set_ai_active(false)


func _surface_top(body: StaticBody2D) -> float:
	var collision: CollisionShape2D = body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var shape: RectangleShape2D = collision.shape as RectangleShape2D
	return body.global_position.y + collision.position.y - shape.size.y * 0.5


func _surface_shape(body: StaticBody2D) -> RectangleShape2D:
	var collision: CollisionShape2D = body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	return collision.shape as RectangleShape2D


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


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish(main: Node2D) -> void:
	main.queue_free()
	if _failures.is_empty():
		print("MAIN_PLATFORM_REACHABILITY_TEST: PASS (5 solid surfaces, jump/double-jump underside blocking, Dash side blocking, top landings)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("MAIN_PLATFORM_REACHABILITY_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
