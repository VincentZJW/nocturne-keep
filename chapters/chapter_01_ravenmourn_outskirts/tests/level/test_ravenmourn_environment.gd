extends SceneTree

## Saved-Main environment, text-free gate flow and placeholder-threshold contract.

const MAIN_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	for frame_index: int in range(4):
		await physics_frame
	_test_saved_main_art(main)
	_test_weighted_gate_and_transition(main)
	main.queue_free()
	for frame_index: int in range(4):
		await process_frame
	await create_timer(0.08, true, false, true).timeout
	_finish()


func _test_saved_main_art(main: Node2D) -> void:
	var required_paths: Array[String] = [
		"World/LateLevelApproachArt",
		"World/LateLevelSurfaceDetails",
		"World/BossCastleBackdrop",
		"World/RavenmournArchway",
		"World/CastleEntranceArea/Moat/MoatAtmosphere",
		"World/CastleEntranceArea/WoodenBridge/DetailedBridgeArt",
		"World/CastleEntranceArea/CastleGate/GateVisual/DetailedGateArt",
		"CastleEntranceTransition",
	]
	for required_path: String in required_paths:
		_expect(main.has_node(required_path), "Configured Main lacks %s" % required_path)
	var archway: Node2D = main.get_node("World/RavenmournArchway") as Node2D
	_expect(
		archway.find_children("*", "CollisionObject2D", true, false).is_empty(),
		"Ravenmourn wayfinding arch unexpectedly blocks passage"
	)
	var castle_name: Label = archway.get_node("CastleName") as Label
	_expect(castle_name.text == "RAVENMOURN CASTLE", "Ravenmourn nameplate mismatch")
	_expect(not main.has_node("HUD/LevelCompletePanel"), "Visible chapter-complete panel remains in Main")
	var bridge_collision: CollisionShape2D = main.get_node(
		"World/CastleEntranceArea/WoodenBridge/BridgeCollision"
	) as CollisionShape2D
	var bridge_shape: RectangleShape2D = bridge_collision.shape as RectangleShape2D
	_expect(bridge_shape.size == Vector2(800.0, 20.0), "Environment art changed bridge collision")
	var hazard_shape_node: CollisionShape2D = main.get_node(
		"World/CastleEntranceArea/Moat/MoatHazard/CollisionShape2D"
	) as CollisionShape2D
	var hazard_shape: RectangleShape2D = hazard_shape_node.shape as RectangleShape2D
	_expect(hazard_shape.size == Vector2(840.0, 104.0), "Environment art changed MoatHazard geometry")


func _test_weighted_gate_and_transition(main: Node2D) -> void:
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	var gate: CastleGateController = room.castle_gate_controller
	_expect(is_equal_approx(gate.gate_open_duration, 1.2), "Castle gate opening is not 1.20 seconds")
	_expect(gate.open_gate(), "Closed castle gate rejected opening")
	gate.advance(0.9)
	_expect(gate.gate_body.collision_layer == 1, "Castle gate collision released before visual clearance")
	gate.advance(0.4)
	_expect(gate.is_gate_open(), "Castle gate did not complete weighted opening")
	_expect(gate.gate_body.collision_layer == 0, "Castle gate retained collision after clearance")
	var transition: CastleEntranceTransition = room.entrance_transition
	_expect(is_equal_approx(transition.fade_duration, 0.55), "Entrance fade duration mismatch")
	_expect(
		transition.target_scene_path == "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn",
		"Entrance transition target mismatch"
	)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("RAVENMOURN_ENVIRONMENT_TEST: PASS (Main art, collision preservation, gate, text-free transition)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("RAVENMOURN_ENVIRONMENT_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
