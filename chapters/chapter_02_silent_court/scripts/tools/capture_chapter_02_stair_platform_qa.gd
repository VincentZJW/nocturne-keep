extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIR: String = "res://docs/qa/chapter_02_stair_platform_fix"
const CAPTURES: Array[Dictionary] = [
	{"file": "01_floor_1_terminal_wall.png", "position": Vector2(6500.0, 529.0)},
	{"file": "02_floor_1_transition_entrance.png", "position": Vector2(6740.0, 420.0)},
	{"file": "03_floor_2_arrival.png", "position": Vector2(6840.0, -316.0)},
	{"file": "04_floor_2_terminal_wall.png", "position": Vector2(600.0, -374.0)},
	{"file": "05_floor_3_arrival.png", "position": Vector2(384.0, -1216.0)},
	{"file": "06_banquet_platform_enemy.png", "position": Vector2(5000.0, 584.0)},
	{"file": "07_chapel_platform_enemies.png", "position": Vector2(3000.0, -316.0)},
	{"file": "08_antechamber_platform_enemies.png", "position": Vector2(1300.0, -1216.0)},
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_failures.append("missing DebugRunConfig")
		_finish()
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_START"
	config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_failures.append("failed to start MainBootstrap")
		_finish()
		return
	var level: SilentCourtLevel = await _wait_for_level()
	if level == null:
		_failures.append("SilentCourt did not load through MainBootstrap")
		_finish()
		return
	_validate_main(level)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var player: Player = level.player
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.hurtbox.set_invulnerable(true)
	for transition: Node in level.get_node("TransitionAreas").get_children():
		var area: Area2D = transition as Area2D
		if area != null:
			area.set_deferred("monitoring", false)
	for capture: Dictionary in CAPTURES:
		player.global_position = capture["position"] as Vector2
		player.velocity = Vector2.ZERO
		level.configure_camera_for_world_y(player.global_position.y)
		player.player_camera.reset_smoothing()
		await _wait_frames(30)
		var output_path: String = "%s/%s" % [OUTPUT_DIR, String(capture["file"])]
		var error: Error = root.get_viewport().get_texture().get_image().save_png(output_path)
		if error != OK:
			_failures.append("failed to save %s: %s" % [output_path, error_string(error)])
		else:
			print("CH2_STAIR_PLATFORM_CAPTURE %s player=%s camera=%s" % [
				String(capture["file"]),
				player.global_position,
				player.player_camera.get_screen_center_position(),
			])
	_finish()


func _validate_main(level: SilentCourtLevel) -> void:
	if ProjectSettings.get_setting("application/run/main_scene", "") != BOOTSTRAP:
		_failures.append("run/main_scene is not MainBootstrap")
	if level.scene_file_path != "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn":
		_failures.append("MainBootstrap loaded an unexpected Chapter II scene")
	var runtime: Chapter02EncounterRuntime = level.get_node_or_null(
		"ChapterSystems/Chapter02EncounterRuntime"
	) as Chapter02EncounterRuntime
	if runtime == null:
		_failures.append("Chapter02EncounterRuntime is missing")
		return
	var counts: Dictionary = runtime.get_placement_counts()
	if runtime.get_enemy_count() != 38:
		_failures.append("Main enemy count is not 38")
	if int(counts.get("PLATFORM", -1)) != 11:
		_failures.append("Main platform enemy count is not 11")


func _wait_for_level() -> SilentCourtLevel:
	for _frame: int in range(300):
		await process_frame
		var level: SilentCourtLevel = current_scene as SilentCourtLevel
		if level != null:
			return level
	return null


func _wait_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _finish() -> void:
	if _failures.is_empty():
		print("CH2_STAIR_PLATFORM_MAIN_QA: PASS captures=8 bootstrap=1 enemies=38 platform=11")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH2_STAIR_PLATFORM_MAIN_QA: %s" % failure)
	quit(1)
