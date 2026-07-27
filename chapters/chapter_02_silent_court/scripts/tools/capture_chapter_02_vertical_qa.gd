extends SceneTree

const BOOTSTRAP_SCENE_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIRECTORY: String = "res://docs/qa/chapter_02_vertical_graybox"
const CAPTURES: Array[Dictionary] = [
	{"name": "01_grey_banner_upper_corridor.png", "position": Vector2(4608.0, 382.0)},
	{"name": "02_banquet_double_level.png", "position": Vector2(9216.0, 360.0)},
	{"name": "03_chapel_three_tiers.png", "position": Vector2(17536.0, 232.0)},
	{"name": "04_servant_passage_levels.png", "position": Vector2(21120.0, 412.0)},
	{"name": "05_antechamber_boss_buffer.png", "position": Vector2(27032.0, 584.0)},
	{"name": "06_ballroom_flat_lane.png", "position": Vector2(29824.0, 584.0)},
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var configured_main: String = String(ProjectSettings.get_setting("application/run/main_scene", ""))
	if configured_main != BOOTSTRAP_SCENE_PATH:
		_failures.append("Configured F5 Main is not MainBootstrap: %s" % configured_main)
		_finish()
		return
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_failures.append("DebugRunConfig Autoload is missing")
		_finish()
		return
	var output_absolute: String = ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(output_absolute)
	if directory_error != OK:
		_failures.append("Could not create QA directory: %s" % error_string(directory_error))
		_finish()
		return
	config.reset_to_defaults()
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_START"
	var load_error: Error = change_scene_to_file(BOOTSTRAP_SCENE_PATH)
	if load_error != OK:
		_failures.append("Could not load MainBootstrap: %s" % error_string(load_error))
		_finish()
		return
	await _wait_for_silent_court()
	var level: SilentCourtLevel = current_scene as SilentCourtLevel
	if level == null:
		_finish()
		return
	var player: Player = level.get_node_or_null("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player") as Player
	if player == null:
		_failures.append("Bootstrap Chapter II has no production Player")
		_finish()
		return
	for capture: Dictionary in CAPTURES:
		player.global_position = capture["position"] as Vector2
		player.velocity = Vector2.ZERO
		await physics_frame
		await create_timer(0.35).timeout
		await _save_viewport(String(capture["name"]))
	config.reset_to_defaults()
	_finish()


func _wait_for_silent_court() -> void:
	for _frame: int in range(180):
		await process_frame
		if current_scene is SilentCourtLevel:
			return
	_failures.append("MainBootstrap Debug route did not reach SilentCourt")


func _save_viewport(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = root.get_viewport().get_texture().get_image()
	var output_path: String = "%s/%s" % [OUTPUT_DIRECTORY, file_name]
	var save_error: Error = image.save_png(output_path)
	if save_error != OK:
		_failures.append("Could not save %s: %s" % [output_path, error_string(save_error)])
		return
	print("CH2_VERTICAL_QA_CAPTURE: %s" % output_path)


func _finish() -> void:
	if _failures.is_empty():
		print("CH2_VERTICAL_MAIN_QA: PASS captures=%d" % CAPTURES.size())
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CH2_VERTICAL_MAIN_QA: FAIL issues=%d" % _failures.size())
	quit(1)
