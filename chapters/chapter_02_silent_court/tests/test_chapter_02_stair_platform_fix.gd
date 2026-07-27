extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const TRANSITION_RUNS: int = 10
const EXPECTED_GROUND: int = 22
const EXPECTED_PLATFORM: int = 11
const EXPECTED_AIR: int = 5

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_failures.append("DebugRunConfig is missing")
		_finish()
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_START"
	config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_failures.append("MainBootstrap failed to start")
		_finish()
		return
	var level: SilentCourtLevel = await _wait_for_level()
	if level == null:
		_failures.append("SilentCourt did not load through MainBootstrap")
		_finish()
		return
	_test_terminal_composition(level)
	await _test_transition_stress(level)
	await _test_platform_enemies(level)
	_finish()


func _test_terminal_composition(level: SilentCourtLevel) -> void:
	_expect(level.get_node_or_null("GameplayWorld/Geometry/GrandServiceStairTerminal/HeavyWoodDoor") is Polygon2D, "Grand stair door is missing")
	_expect(level.get_node_or_null("GameplayWorld/Geometry/GrandServiceStairTerminal/Geometry/EndWall") is StaticBody2D, "Grand stair terminal is not physically closed")
	_expect(level.get_node_or_null("GameplayWorld/Geometry/ServantSideStairTerminal/NarrowWoodDoor") is Polygon2D, "Servant stair door is missing")
	_expect(level.get_node_or_null("GameplayWorld/Geometry/ServantSideStairTerminal/Geometry/EndWall") is StaticBody2D, "Servant stair terminal is not physically closed")
	_expect(level.get_node_or_null("GameplayWorld/Geometry/Floor2ArrivalVestibule/Geometry") is StaticBody2D, "Floor 2 arrival wall is missing")
	_expect(level.get_node_or_null("GameplayWorld/Geometry/Floor3ArrivalVestibule/Geometry") is StaticBody2D, "Floor 3 arrival wall is missing")
	var runtime: Chapter02EncounterRuntime = level.get_node(
		"ChapterSystems/Chapter02EncounterRuntime"
	) as Chapter02EncounterRuntime
	var counts: Dictionary = runtime.get_placement_counts()
	_expect(int(counts.get("GROUND", -1)) == EXPECTED_GROUND, "Ground spawn count mismatch")
	_expect(int(counts.get("PLATFORM", -1)) == EXPECTED_PLATFORM, "Platform spawn count mismatch")
	_expect(int(counts.get("CEILING_AIR", -1)) == EXPECTED_AIR, "Air spawn count mismatch")


func _test_transition_stress(level: SilentCourtLevel) -> void:
	var controller: Chapter02FloorTransitionController = level.get_node(
		"ChapterSystems/FloorTransitionController"
	) as Chapter02FloorTransitionController
	controller.fade_out_duration = 0.01
	controller.blackout_hold_duration = 0.0
	controller.fade_in_duration = 0.01
	var first: Chapter02FloorTransition = level.get_node(
		"TransitionAreas/Floor1ToFloor2"
	) as Chapter02FloorTransition
	var second: Chapter02FloorTransition = level.get_node(
		"TransitionAreas/Floor2ToFloor3"
	) as Chapter02FloorTransition
	var floor_two: Marker2D = level.get_node("PlayerSpawnPoints/CH2_FLOOR_2_START") as Marker2D
	var floor_three: Marker2D = level.get_node("PlayerSpawnPoints/CH2_FLOOR_3_START") as Marker2D
	for run_index: int in range(TRANSITION_RUNS):
		_expect(controller.request_transition(first), "Floor 1 transition request failed on run %d" % (run_index + 1))
		await _wait_for_transition(controller)
		_expect(level.player.global_position.distance_to(floor_two.global_position) < 1.0, "Floor 2 landing mismatch on run %d" % (run_index + 1))
		_expect(level.player.player_camera.limit_left == 64, "Floor 2 camera limit was not applied before fade-in")
		_expect(controller.request_transition(second), "Floor 2 transition request failed on run %d" % (run_index + 1))
		await _wait_for_transition(controller)
		_expect(level.player.global_position.distance_to(floor_three.global_position) < 1.0, "Floor 3 landing mismatch on run %d" % (run_index + 1))
		_expect(level.player.player_camera.limit_left == 0, "Floor 3 camera limit was not applied before fade-in")


func _test_platform_enemies(level: SilentCourtLevel) -> void:
	var runtime: Chapter02EncounterRuntime = level.get_node(
		"ChapterSystems/Chapter02EncounterRuntime"
	) as Chapter02EncounterRuntime
	runtime.set_process(false)
	level.player.global_position = Vector2(-1000.0, -2500.0)
	level.player.velocity = Vector2.ZERO
	var enemies: Array[GroundEnemyBase] = []
	for node: Node in level.get_node("GameplayWorld/Enemies").find_children("*", "CharacterBody2D", true, false):
		var enemy: GroundEnemyBase = node as GroundEnemyBase
		if enemy != null and String(enemy.get_meta("placement", "")) == "PLATFORM":
			enemies.append(enemy)
			enemy.set_ai_active(true)
	_expect(enemies.size() == EXPECTED_PLATFORM, "Instantiated platform enemy count mismatch: %d" % enemies.size())
	for _frame: int in range(240):
		await physics_frame
	for enemy: GroundEnemyBase in enemies:
		if not is_instance_valid(enemy):
			_failures.append("Platform enemy was unexpectedly removed")
			continue
		var spawn_path: NodePath = enemy.get_meta("spawn_path", NodePath()) as NodePath
		var spawn: Chapter02EnemySpawnPoint = root.get_node_or_null(spawn_path) as Chapter02EnemySpawnPoint
		_expect(spawn != null, "Platform enemy lost its authored SpawnPoint")
		if spawn == null:
			continue
		_expect(enemy.has_movement_bounds(), "%s has no runtime movement bounds" % enemy.name)
		_expect(enemy.global_position.x >= spawn.platform_left_bound - 2.0, "%s crossed its left platform bound" % enemy.name)
		_expect(enemy.global_position.x <= spawn.platform_right_bound + 2.0, "%s crossed its right platform bound" % enemy.name)
		_expect(enemy.is_on_floor(), "%s did not settle on its platform" % enemy.name)
		_expect(absf(enemy.global_position.y + 28.0 - spawn.global_position.y) <= 4.0, "%s foot position does not match its platform" % enemy.name)
		enemy.set_ai_active(false)
	await physics_frame


func _wait_for_transition(controller: Chapter02FloorTransitionController) -> void:
	for _frame: int in range(120):
		await process_frame
		if not controller.is_transitioning():
			return
	_failures.append("Floor transition timed out")


func _wait_for_level() -> SilentCourtLevel:
	for _frame: int in range(300):
		await process_frame
		var level: SilentCourtLevel = current_scene as SilentCourtLevel
		if level != null:
			return level
	return null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	var exit_code: int = 0
	if _failures.is_empty():
		print("CH2_STAIR_PLATFORM_FIX_TEST: PASS transitions=20 ground=22 platform=11 air=5 bounded=11")
	else:
		exit_code = 1
		for failure: String in _failures:
			push_error("CH2_STAIR_PLATFORM_FIX_TEST: %s" % failure)
	if current_scene != null:
		current_scene.free()
		await process_frame
	quit(exit_code)
