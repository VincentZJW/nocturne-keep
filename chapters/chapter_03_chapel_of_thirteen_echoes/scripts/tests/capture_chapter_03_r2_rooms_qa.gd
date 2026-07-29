extends SceneTree

const BOOTSTRAP := "res://scenes/bootstrap/main_bootstrap.tscn"
const QA_ROOT := "res://docs/qa"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		push_error("R2 capture requires DebugRunConfig")
		quit(1)
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"chapter_03_start"
	var error: Error = change_scene_to_file(BOOTSTRAP)
	if error != OK:
		push_error("Unable to load R2 route: %s" % error_string(error))
		quit(1)
		return
	await create_timer(1.0).timeout
	await _capture("chapter_03_r2_vestibule_main.png")
	var route: Chapter03Route = current_scene as Chapter03Route
	if route == null:
		push_error("MainBootstrap did not route to Chapter03Route")
		config.reset_to_defaults()
		quit(1)
		return
	var controller: Chapter03RoomTransitionController = route.get_node("RoomTransitionController")
	controller.request_room_change(&"CH3_NAVE_ENTRY", &"EntryWest")
	await create_timer(0.8).timeout
	await _capture("chapter_03_r2_nave_main.png")
	controller.request_room_change(&"CH3_CHOIR_GALLERY", &"EntryWest")
	await create_timer(0.8).timeout
	await _capture("chapter_03_r2_choir_main.png")
	config.reset_to_defaults()
	print("CH3_R2_CAPTURE PASS images=3")
	quit()


func _capture(file_name: String) -> void:
	await process_frame
	await process_frame
	var image: Image = root.get_viewport().get_texture().get_image()
	var path: String = QA_ROOT + "/" + file_name
	var error: Error = image.save_png(path)
	assert(error == OK, "Failed to save %s" % path)
