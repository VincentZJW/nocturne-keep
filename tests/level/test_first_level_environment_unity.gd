extends SceneTree

## Configured-Main contract for the complete first-level visual progression.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	for frame_index: int in range(5):
		await physics_frame
	_test_progression_layers(main)
	_test_gameplay_geometry_preserved(main)
	_test_gate_and_camera_contract(main)
	main.queue_free()
	for frame_index: int in range(4):
		await process_frame
	_finish()


func _test_progression_layers(main: Node2D) -> void:
	var visual_paths: Array[String] = [
		"World/DarkForestOutskirtsArt",
		"World/CastleFrontierTransitionArt",
		"World/OutskirtsSurfaceDetails",
		"World/LateLevelApproachArt",
		"World/LateLevelSurfaceDetails",
		"World/BossCastleBackdrop",
		"World/CastleEntranceArea/WoodenBridge/DetailedBridgeArt",
		"World/CastleEntranceArea/Moat/MoatAtmosphere",
		"World/CastleEntranceArea/CastleGate/GateVisual/DetailedGateArt",
	]
	for visual_path: String in visual_paths:
		_expect(main.has_node(visual_path), "Configured Main lacks environment layer %s" % visual_path)
		if main.has_node(visual_path):
			var visual_node: Node = main.get_node(visual_path)
			_expect(
				visual_node.find_children("*", "CollisionObject2D", true, false).is_empty(),
				"Visual layer unexpectedly owns collision: %s" % visual_path
			)
	_expect(not main.has_node("FarKeep"), "Obsolete coarse FarKeep silhouette still ships in Main")
	var forest: DarkForestOutskirtsArt = main.get_node("World/DarkForestOutskirtsArt") as DarkForestOutskirtsArt
	var transition: CastleFrontierTransitionArt = main.get_node(
		"World/CastleFrontierTransitionArt"
	) as CastleFrontierTransitionArt
	var details: OutskirtsSurfaceDetails = main.get_node(
		"World/OutskirtsSurfaceDetails"
	) as OutskirtsSurfaceDetails
	_expect(forest != null and transition != null and details != null, "Typed early/middle renderers are not active")


func _test_gameplay_geometry_preserved(main: Node2D) -> void:
	var expected_platforms: Dictionary[String, Vector2] = {
		"World/PlatformA": Vector2(220.0, 24.0),
		"World/PlatformB": Vector2(190.0, 24.0),
		"World/PlatformC": Vector2(220.0, 24.0),
		"World/PlatformD": Vector2(220.0, 24.0),
		"World/GargoylePerch": Vector2(240.0, 24.0),
	}
	for platform_path: String in expected_platforms:
		var collision: CollisionShape2D = main.get_node(
			"%s/CollisionShape2D" % platform_path
		) as CollisionShape2D
		var shape: RectangleShape2D = collision.shape as RectangleShape2D
		_expect(shape.size == expected_platforms[platform_path], "Environment pass changed %s geometry" % platform_path)
	var encounters: Node2D = main.get_node("World/Encounters") as Node2D
	_expect(encounters.get_child_count() == 7, "Environment pass changed the seven encounter groups")
	var normal_enemy_count: int = 0
	for encounter_node: Node in encounters.get_children():
		var encounter: EncounterGroup = encounter_node as EncounterGroup
		if encounter != null:
			normal_enemy_count += encounter.get_enemies().size()
	_expect(normal_enemy_count == 18, "Environment pass changed the 18-enemy roster")


func _test_gate_and_camera_contract(main: Node2D) -> void:
	var gate_collision: CollisionShape2D = main.get_node(
		"World/CastleEntranceArea/CastleGate/GateCollision"
	) as CollisionShape2D
	var gate_shape: RectangleShape2D = gate_collision.shape as RectangleShape2D
	_expect(gate_shape.size == Vector2(48.0, 260.0), "Wider visual gate changed physical gate geometry")
	var gate_art: RavenmournGateArt = main.get_node(
		"World/CastleEntranceArea/CastleGate/GateVisual/DetailedGateArt"
	) as RavenmournGateArt
	_expect(gate_art != null, "Wider moving Gothic gate art is not active")
	_expect(is_equal_approx(RavenmournGateArt.GATE_VISUAL_WIDTH, 88.0), "Gate visual is not the approved wider 88 px")
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	_expect(is_equal_approx(room.castle_gate_controller.gate_open_duration, 1.2), "Gate opening weight changed")
	var camera: Camera2D = main.get_node("World/Player/Camera2D") as Camera2D
	_expect(camera.limit_left == 0 and camera.limit_right == 6600, "Main camera limits changed")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("FIRST_LEVEL_ENVIRONMENT_UNITY_TEST: PASS (forest, frontier, approach, fortress, geometry preservation)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("FIRST_LEVEL_ENVIRONMENT_UNITY_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
