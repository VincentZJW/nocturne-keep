extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIR: String = "res://docs/qa/chapter_02_phase_2_enemies"
const PROTOTYPES: Array[Dictionary] = [
	{"name": "hollow_retainer", "path": "Phase2EnemyPrototypeShowcase/HollowRetainerPrototype", "offset": Vector2(-42, 0), "frames": 45},
	{"name": "court_halberdier", "path": "Phase2EnemyPrototypeShowcase/CourtHalberdierPrototype", "offset": Vector2(-72, 0), "frames": 55},
	{"name": "mourning_armor", "path": "Phase2EnemyPrototypeShowcase/MourningArmorPrototype", "offset": Vector2(-56, 0), "frames": 60},
	{"name": "hanging_stalker", "path": "Phase2EnemyPrototypeShowcase/HangingStalkerPrototype", "offset": Vector2(-48, 414), "frames": 40},
	{"name": "blood_candle_acolyte", "path": "Phase2EnemyPrototypeShowcase/BloodCandleAcolytePrototype", "offset": Vector2(-180, 0), "frames": 60},
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		push_error("CH2_PHASE2_MAIN_QA: missing DebugRunConfig")
		quit(1)
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_START"
	var error: Error = change_scene_to_file(BOOTSTRAP)
	if error != OK:
		push_error("CH2_PHASE2_MAIN_QA: failed to load Bootstrap")
		quit(1)
		return
	var level: Node = await _wait_for_level()
	if level == null:
		push_error("CH2_PHASE2_MAIN_QA: SilentCourt did not load through Bootstrap")
		quit(1)
		return
	var player: Player = level.get_node_or_null("ChapterRuntime/Player") as Player
	if player == null:
		push_error("CH2_PHASE2_MAIN_QA: Main Player missing")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var captured: int = 0
	for entry: Dictionary in PROTOTYPES:
		var enemy: EnemyCombatant = level.get_node_or_null(entry["path"] as String) as EnemyCombatant
		if enemy == null:
			push_error("CH2_PHASE2_MAIN_QA: missing %s" % entry["path"])
			quit(1)
			return
		player.global_position = enemy.global_position + (entry["offset"] as Vector2)
		player.velocity = Vector2.ZERO
		player.player_camera.reset_smoothing()
		for _frame: int in range(int(entry["frames"])):
			await process_frame
		var output: String = "%s/main_%s.png" % [OUTPUT_DIR, entry["name"]]
		var image: Image = root.get_texture().get_image()
		var save_error: Error = image.save_png(ProjectSettings.globalize_path(output))
		if save_error != OK:
			push_error("CH2_PHASE2_MAIN_QA: failed to save %s" % output)
			quit(1)
			return
		captured += 1
	print("CH2_PHASE2_MAIN_QA: PASS captures=%d main=%s" % [captured, level.scene_file_path])
	config.reset_to_defaults()
	quit(0)


func _wait_for_level() -> Node:
	for _frame: int in range(180):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn":
			return current_scene
	return null
