extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const OUTPUT: String = "res://docs/qa/chapter_04_scene_production/s5/main"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
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
		_fail("formal Chapter IV level did not load")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var controller: Chapter04RoomTransitionController = level.get_node("RoomTransitionController") as Chapter04RoomTransitionController
	var player: Player = level.get_node("ChapterRuntime/Player") as Player
	var fade: ColorRect = level.get_node("ChapterRuntime/HUD/RoomFade") as ColorRect
	player.hurtbox.set_invulnerable(true)
	if not controller.call("_swap_room", &"CH4_AREA_03", &"EntryWest"):
		_fail("unable to prepare transition source room")
		return
	player.global_position = Vector2(1680.0, 592.0)
	player.player_camera.reset_smoothing()
	for _frame: int in 18:
		await process_frame
	_save("01_area03_before_transition_main.png")
	if not controller.request_room_change(&"CH4_AREA_04", &"EntryWest"):
		_fail("formal request_room_change was rejected")
		return
	for _frame: int in 120:
		await process_frame
		if fade.visible and fade.modulate.a >= 0.95:
			_save("02_fade_covers_atomic_swap_main.png")
			break
	for _frame: int in 180:
		await process_frame
		if not controller.is_transitioning():
			break
	if controller.is_transitioning() or controller.active_room_id != &"CH4_AREA_04":
		_fail("formal transition did not complete")
		return
	for _frame: int in 18:
		await process_frame
	_save("03_area04_after_transition_main.png")
	var metrics: Dictionary = controller.get_transition_metrics()
	debug.reset_to_defaults()
	print("CH4 S5 MAIN CAPTURE | PASS captures=%d room=%s wait_us=%d instantiate_us=%d transition_us=%d path=%s" % [
		_captures,
		controller.active_room_id,
		int(metrics.get("resource_wait_usec", 0)),
		int(metrics.get("instantiation_usec", 0)),
		int(metrics.get("transition_usec", 0)),
		OUTPUT,
	])
	unload_current_scene()
	for _frame: int in 8:
		await process_frame
	quit(0)


func _wait_for_level() -> Node:
	for _frame: int in 480:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _save(file_name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var path: String = "%s/%s" % [OUTPUT, file_name]
	if image == null or image.save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("unable to save %s" % path)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("CH4 S5 MAIN CAPTURE: %s" % message)
	quit(1)
