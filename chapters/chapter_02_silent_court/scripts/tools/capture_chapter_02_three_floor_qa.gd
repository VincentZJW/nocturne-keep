extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIR: String = "res://docs/qa/chapter_02_three_floor"
const CAPTURES: Array[Dictionary] = [
	{"file": "01_floor_1_castle_gate_interior.png", "position": Vector2(640, 584), "limits": Vector2i(0, 720)},
	{"file": "02_floor_1_grey_banner_corridor.png", "position": Vector2(2200, 584), "limits": Vector2i(0, 720)},
	{"file": "03_floor_1_last_banquet_layering.png", "position": Vector2(5200, 584), "limits": Vector2i(0, 720)},
	{"file": "04_grand_service_stair.png", "position": Vector2(6200, 168), "limits": Vector2i(-900, 720)},
	{"file": "05_floor_2_royal_portrait_gallery.png", "position": Vector2(6200, -316), "limits": Vector2i(-900, -180)},
	{"file": "06_floor_2_blood_candle_chapel.png", "position": Vector2(2700, -316), "limits": Vector2i(-900, -180)},
	{"file": "07_floor_2_servant_upper_passage.png", "position": Vector2(800, -316), "limits": Vector2i(-900, -180)},
	{"file": "08_servant_side_stair.png", "position": Vector2(1200, -700), "limits": Vector2i(-1800, -180)},
	{"file": "09_floor_3_landing.png", "position": Vector2(600, -1216), "limits": Vector2i(-1800, -1080)},
	{"file": "10_floor_3_upper_court_gallery.png", "position": Vector2(1600, -1216), "limits": Vector2i(-1800, -1080)},
	{"file": "11_silent_ballroom_antechamber.png", "position": Vector2(2400, -1216), "limits": Vector2i(-1800, -1080)},
	{"file": "12_silent_ballroom_boss_room.png", "position": Vector2(5700, -1216), "limits": Vector2i(-1800, -1080)},
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
	config.debug_start_spawn_id = &"CH2_FLOOR_1_START"
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
	var player: Player = level.get_node_or_null(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player"
	) as Player
	if player == null:
		_failures.append("Main Player missing")
		_finish()
		return
	_validate_live_layers(level, player)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.hurtbox.set_invulnerable(true)
	for capture: Dictionary in CAPTURES:
		player.global_position = capture["position"] as Vector2
		player.velocity = Vector2.ZERO
		var limits: Vector2i = capture["limits"] as Vector2i
		level._configure_camera(limits.x, limits.y)
		player.player_camera.reset_smoothing()
		await _wait_frames(18)
		print("CH2_CAPTURE %s player=%s camera=%s limits=%s" % [
			String(capture["file"]), player.global_position, player.player_camera.get_screen_center_position(), limits,
		])
		var output_path: String = "%s/%s" % [OUTPUT_DIR, String(capture["file"])]
		var error: Error = root.get_viewport().get_texture().get_image().save_png(output_path)
		if error != OK:
			_failures.append("failed to save %s: %s" % [output_path, error_string(error)])
	_finish()


func _validate_live_layers(level: SilentCourtLevel, player: Player) -> void:
	var rooms: Node2D = level.get_node_or_null("GameplayWorld/Geometry/Rooms") as Node2D
	var enemies: Node2D = level.get_node_or_null("GameplayWorld/Enemies") as Node2D
	if rooms == null or enemies == null:
		_failures.append("GameplayWorld layer composition is incomplete")
		return
	if player.z_index != 12 or player.z_as_relative:
		_failures.append("Player layer is not absolute z=12")
	if enemies.z_index != 10 or enemies.z_as_relative:
		_failures.append("Enemies layer is not absolute z=10")
	if level.y_sort_enabled or enemies.y_sort_enabled:
		_failures.append("Unexpected YSort is enabled")
	var encounter_runtime: Chapter02EncounterRuntime = level.get_node_or_null(
		"ChapterSystems/Chapter02EncounterRuntime"
	) as Chapter02EncounterRuntime
	if encounter_runtime == null or encounter_runtime.get_encounter_count() != 15:
		_failures.append("Encounter runtime count mismatch")
	elif encounter_runtime.get_enemy_count() != 38:
		_failures.append("Enemy runtime count mismatch")
	print("CH2_LAYER_AUDIT player=%s z=%d enemy_parent=%s z=%d rooms=%s ysort=false" % [
		player.get_path(), player.z_index, enemies.get_path(), enemies.z_index, rooms.get_path(),
	])


func _wait_for_level() -> SilentCourtLevel:
	for _frame: int in range(240):
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
		print("CH2_THREE_FLOOR_MAIN_QA: PASS captures=%d encounters=15 enemies=38" % CAPTURES.size())
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH2_THREE_FLOOR_MAIN_QA: %s" % failure)
	quit(1)
