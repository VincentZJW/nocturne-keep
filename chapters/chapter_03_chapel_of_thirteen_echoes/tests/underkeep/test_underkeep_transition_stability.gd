extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const CH4: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const ROOM_TIMEOUT_FRAMES: int = 240
const SCENE_TIMEOUT_FRAMES: int = 360

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var started_ms: int = Time.get_ticks_msec()
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null:
		return _fail_now("missing DebugRunConfig")
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	debug.debug_start_spawn_id = &"CH3_UNDERKEEP_DESCENT"
	if change_scene_to_file(BOOTSTRAP) != OK:
		return _fail_now("MainBootstrap failed")
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		return _fail_now("initial direct start failed")
	var controller: Chapter03RoomTransitionController = route.transition_controller
	for cycle: int in range(10):
		_expect(controller.request_room_change(&"CH3_POST_BOSS", &"EntryWest"), "post-boss transition %d accepted" % cycle)
		await _wait_for_room(controller, &"CH3_POST_BOSS")
		_expect(controller.active_room_id == &"CH3_POST_BOSS", "post-boss transition %d completed" % cycle)
		_expect(controller.request_room_change(&"CH3_UNDERKEEP_DESCENT", &"EntryWest"), "underkeep return %d accepted" % cycle)
		await _wait_for_room(controller, &"CH3_UNDERKEEP_DESCENT")
		_expect(controller.active_room_id == &"CH3_UNDERKEEP_DESCENT", "underkeep return %d completed" % cycle)
		_expect(controller.active_room.get_node_or_null("UnderkeepDescent/OssuaryStairs") == null, "placeholder absent after room cycle %d" % cycle)
	var manager: SceneTransitionManagerState = root.get_node_or_null("SceneTransitionManager") as SceneTransitionManagerState
	if manager == null:
		return _fail_now("SceneTransitionManager missing")
	for cycle: int in range(10):
		_expect(manager.transition_to_chapter(ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP, &"CH4_START", 0.01, 0.01), "Chapter IV transition %d accepted" % cycle)
		var chapter_four: DrownedUnderkeepRoute = await _wait_for_chapter_four(manager)
		_expect(chapter_four != null, "Chapter IV transition %d completed" % cycle)
		if chapter_four == null:
			break
		_expect(chapter_four.get_node_or_null("ChapterRuntime/Player") is Player, "Chapter IV Player unique on cycle %d" % cycle)
		_expect(chapter_four.get_node_or_null("ChapterRuntime/HUD") is CanvasLayer, "Chapter IV HUD unique on cycle %d" % cycle)
		_expect(manager.transition_to_chapter(ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES, &"CH3_UNDERKEEP_DESCENT", 0.01, 0.01), "Chapter III direct reload %d accepted" % cycle)
		route = await _wait_for_route_and_transition(manager)
		_expect(route != null, "Chapter III direct reload %d completed" % cycle)
		if route == null:
			break
		controller = route.transition_controller
		_expect(controller.active_room_id == &"CH3_UNDERKEEP_DESCENT", "direct reload %d restores underkeep room" % cycle)
		var water: Node = controller.active_room.get_node_or_null("UnderkeepDescent/WaterLayers")
		_expect(water != null and water.get_child_count() >= 12, "water layers survive reload %d" % cycle)
	debug.reset_to_defaults()
	var elapsed_ms: int = Time.get_ticks_msec() - started_ms
	if _failures > 0:
		push_error("UNDERKEEP_STABILITY_TEST FAIL count=%d elapsed_ms=%d" % [_failures, elapsed_ms])
		quit(1)
		return
	print("UNDERKEEP_STABILITY_TEST PASS room_roundtrips=10 postboss_entries=10 chapter4_entries=10 direct_reloads=10 elapsed_ms=%d" % elapsed_ms)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _index: int in range(SCENE_TIMEOUT_FRAMES):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE:
			var route: Chapter03Route = current_scene as Chapter03Route
			if route != null and route.transition_controller.active_room_id == &"CH3_UNDERKEEP_DESCENT":
				return route
	return null


func _wait_for_room(controller: Chapter03RoomTransitionController, room_id: StringName) -> void:
	for _index: int in range(ROOM_TIMEOUT_FRAMES):
		await process_frame
		if controller.active_room_id == room_id and not controller.fade_rect.visible:
			return


func _wait_for_chapter_four(manager: SceneTransitionManagerState) -> DrownedUnderkeepRoute:
	for _index: int in range(SCENE_TIMEOUT_FRAMES):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == CH4 and not manager.is_transitioning():
			return current_scene as DrownedUnderkeepRoute
	return null


func _wait_for_route_and_transition(manager: SceneTransitionManagerState) -> Chapter03Route:
	for _index: int in range(SCENE_TIMEOUT_FRAMES):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE and not manager.is_transitioning():
			var route: Chapter03Route = current_scene as Chapter03Route
			if route != null and route.transition_controller.active_room_id == &"CH3_UNDERKEEP_DESCENT":
				return route
	return null


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("UNDERKEEP_STABILITY_TEST: %s" % message)


func _fail_now(message: String) -> void:
	push_error("UNDERKEEP_STABILITY_TEST: %s" % message)
	quit(1)
