extends SceneTree

const BOOTSTRAP_SCENE_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIRECTORY: String = "res://docs/qa/main_bootstrap_startup"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_absolute: String = ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(output_absolute)
	if directory_error != OK:
		_failures.append("Could not create QA output directory: %s" % error_string(directory_error))
		_finish()
		return
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_failures.append("DebugRunConfig Autoload is missing")
		_finish()
		return

	config.reset_to_defaults()
	await _load_bootstrap()
	await _wait_for_scene("OpeningCinematic", 60)
	var opening: OpeningCinematicController = current_scene as OpeningCinematicController
	if opening == null:
		_failures.append("Formal Bootstrap did not reach OpeningCinematic")
		_finish()
		return
	await create_timer(1.4).timeout
	await _save_viewport("formal_01_opening_cinematic.png")

	opening.transition_duration = 0.08
	opening.finish_cinematic(true)
	await _wait_for_scene("VeilboundCatacomb", 120)
	if not current_scene is VeilboundCatacombController:
		_failures.append("Opening skip did not reach VeilboundCatacomb")
		_finish()
		return
	await create_timer(1.6).timeout
	await _save_viewport("formal_02_veilbound_catacomb.png")

	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_START"
	await _load_bootstrap()
	await _wait_for_scene("SilentCourt", 120)
	if not current_scene is SilentCourtLevel:
		_failures.append("Debug Bootstrap did not reach SilentCourt")
		_finish()
		return
	await create_timer(0.8).timeout
	await _save_viewport("debug_03_chapter_02_silent_court.png")
	config.reset_to_defaults()
	_finish()


func _load_bootstrap() -> void:
	var error: Error = change_scene_to_file(BOOTSTRAP_SCENE_PATH)
	if error != OK:
		_failures.append("Could not load MainBootstrap: %s" % error_string(error))
		return
	await process_frame


func _wait_for_scene(scene_name: String, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.name == scene_name:
			return
	_failures.append("Timed out waiting for scene %s" % scene_name)


func _save_viewport(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = root.get_viewport().get_texture().get_image()
	var output_path: String = "%s/%s" % [OUTPUT_DIRECTORY, file_name]
	var save_error: Error = image.save_png(output_path)
	if save_error != OK:
		_failures.append("Could not save %s: %s" % [output_path, error_string(save_error)])
		return
	print("STARTUP_QA_CAPTURE: %s" % output_path)


func _finish() -> void:
	if _failures.is_empty():
		print("MAIN_BOOTSTRAP_QA: PASS (Opening, Catacomb, Debug Chapter II)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("MAIN_BOOTSTRAP_QA: FAIL (%d issues)" % _failures.size())
	quit(1)
