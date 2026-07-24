extends SceneTree

## Saved F5 Main traversal audit plus real Player/physics landing checks.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const MAIN_PATH: String = "res://scenes/main/main.tscn"
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
		"F5 does not resolve to the audited Main scene"
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
			await _test_double_jump_landing(player, platform, EXPECTED_TOPS[index])
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
		_expect(collision.one_way_collision, "%s is not a downward-facing one-way surface" % platform.name)


func _test_enemy_platform_alignment(main: Node2D) -> void:
	var crossbow_paths: Array[NodePath] = [
		NodePath("World/Encounters/EncounterGroup04/Enemies/FallenCrossbowman01"),
		NodePath("World/Encounters/EncounterGroup06/Enemies/FallenCrossbowman02"),
		NodePath("World/Encounters/EncounterGroup07/Enemies/FallenCrossbowman03"),
	]
	var platform_paths: Array[NodePath] = [
		NodePath("World/PlatformB"), NodePath("World/PlatformC"), NodePath("World/PlatformD"),
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
		NodePath("World/Encounters/EncounterGroup05/Enemies/GargoyleSentinel01"),
		NodePath("World/Encounters/EncounterGroup05/Enemies/GargoyleSentinel02"),
	]:
		var gargoyle: GargoyleSentinel = main.get_node_or_null(gargoyle_path) as GargoyleSentinel
		_expect(gargoyle != null, "%s is missing" % gargoyle_path)
		if gargoyle != null:
			_expect(absf(gargoyle.global_position.x - perch.global_position.x) <= perch_shape.size.x * 0.5 - 16.0, "%s starts outside the perch" % gargoyle.name)
			_expect(gargoyle.global_position.y < _surface_top(perch) - 48.0, "%s lacks dive clearance" % gargoyle.name)


func _test_double_jump_landing(player: Player, platform: StaticBody2D, top_y: float) -> void:
	player.action_controller.cancel_all_actions()
	player.velocity = Vector2.ZERO
	player.global_position = Vector2(platform.global_position.x, 612.0)
	player.debug_enable_double_jump = true
	await _wait_physics_frames(5)
	await _tap_action(Player.JUMP_ACTION)
	var left_floor: bool = false
	var second_jump_sent: bool = false
	var landed_on_target: bool = false
	for frame_index: int in range(240):
		await physics_frame
		left_floor = left_floor or not player.is_on_floor()
		if left_floor and not second_jump_sent and player.velocity.y >= -10.0:
			second_jump_sent = true
			await _tap_action(Player.JUMP_ACTION)
		if left_floor and player.is_on_floor():
			var foot_y: float = _player_foot_y(player)
			if absf(foot_y - top_y) <= 1.5:
				landed_on_target = true
			break
	_expect(second_jump_sent, "%s double jump was not triggered" % platform.name)
	_expect(landed_on_target, "%s was not landed on through real Player physics" % platform.name)
	Input.action_release(Player.JUMP_ACTION)


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
		print("MAIN_PLATFORM_REACHABILITY_TEST: PASS (5 surfaces, one-way collision, enemies aligned, real double-jump landings)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("MAIN_PLATFORM_REACHABILITY_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
