extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null:
		_fail("DebugRunConfig missing")
		return
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_START"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("MainBootstrap launch failed")
		return
	var level: Node = await _wait_for_level()
	if level == null:
		_fail("MainBootstrap did not resolve formal Chapter IV level")
		return
	var controller: Node = level.get_node_or_null("RoomTransitionController")
	var player: Player = level.get_node_or_null("ChapterRuntime/Player") as Player
	if controller == null or player == null:
		_fail("formal route controller or Player missing")
		return
	for index: int in 17:
		var room_id: StringName = StringName("CH4_AREA_%02d" % index)
		if index > 0 and not bool(controller.call("_swap_room", room_id, &"EntryWest")):
			_fail("unable to swap to %s" % room_id)
			return
		await process_frame
		var active_room: Chapter04Room = controller.get("active_room") as Chapter04Room
		if active_room == null or active_room.room_id != room_id:
			_fail("active room mismatch for %s" % room_id)
			return
		if player.player_camera == null or player.player_camera.limit_right != active_room.room_size.x:
			_fail("camera bounds mismatch for %s" % room_id)
			return
		if player.global_position != active_room.get_spawn(&"EntryWest").global_position:
			_fail("Player spawn mismatch for %s" % room_id)
			return
	var profile: ChapterStartProfile = ChapterRegistry.get_chapter(ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP)
	if profile.main_scene_path != LEVEL or profile.available_spawn_ids.size() != 23:
		_fail("Chapter IV profile does not expose formal S3 route")
		return
	debug.reset_to_defaults()
	print("CH4 S3 MAIN ROUTE | PASS bootstrap=%s rooms=17 final=%s" % [ProjectSettings.get_setting("application/run/main_scene"), controller.get("active_room_id")])
	unload_current_scene()
	for _frame: int in 4:
		await process_frame
	quit(0)


func _wait_for_level() -> Node:
	for _frame: int in 480:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _fail(message: String) -> void:
	push_error("CH4 S3 MAIN ROUTE: %s" % message)
	quit(1)
