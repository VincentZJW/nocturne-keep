extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const OUTPUT: String = "res://docs/qa/chapter_04_scene_production/s3/main"
const CAPTURES: Array[Dictionary] = [
	{"room": &"CH4_AREA_00", "x": 800.0, "file": "00_drowned_threshold_main.png"},
	{"room": &"CH4_AREA_01", "x": 960.0, "file": "01_flooded_intake_main.png"},
	{"room": &"CH4_AREA_02", "x": 1024.0, "file": "02_rusted_cellblock_main.png"},
	{"room": &"CH4_AREA_03", "x": 1024.0, "file": "03_broken_chainway_main.png"},
	{"room": &"CH4_AREA_04", "x": 1180.0, "file": "04_harpoon_watch_gallery_main.png"},
	{"room": &"CH4_AREA_05", "x": 1088.0, "file": "05_cistern_of_the_changed_main.png"},
	{"room": &"CH4_AREA_06", "x": 760.0, "file": "06_dry_gaolers_cell_main.png"},
	{"room": &"CH4_AREA_07", "x": 960.0, "file": "07_leech_sluice_main.png"},
	{"room": &"CH4_AREA_08", "x": 1088.0, "file": "08_gaolers_workshop_main.png"},
	{"room": &"CH4_AREA_09", "x": 1088.0, "file": "09_soul_cage_registry_main.png"},
	{"room": &"CH4_AREA_10", "x": 1152.0, "file": "10_floodgate_engine_hall_main.png"},
	{"room": &"CH4_AREA_11", "x": 1152.0, "file": "11_final_lock_approach_main.png"},
	{"room": &"CH4_AREA_12", "x": 760.0, "file": "12_last_gaol_checkpoint_main.png"},
	{"room": &"CH4_AREA_13", "x": 896.0, "file": "13_soul_lock_antechamber_main.png"},
	{"room": &"CH4_AREA_14", "x": 1152.0, "file": "14_core_of_drowned_gaol_main.png"},
	{"room": &"CH4_AREA_15", "x": 960.0, "file": "15_broken_soul_reservoir_main.png"},
	{"room": &"CH4_AREA_16", "x": 1200.0, "file": "16_hall_of_drowned_memories_main.png"},
]

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
	var controller: Node = level.get_node("RoomTransitionController")
	var player: Player = level.get_node("ChapterRuntime/Player") as Player
	player.hurtbox.set_invulnerable(true)
	for capture: Dictionary in CAPTURES:
		var room_id: StringName = capture["room"] as StringName
		if controller.get("active_room_id") != room_id:
			if not bool(controller.call("_swap_room", room_id, &"EntryWest")):
				_fail("room swap failed: %s" % room_id)
				return
		var room: Chapter04Room = controller.get("active_room") as Chapter04Room
		player.global_position = Vector2(float(capture["x"]), 592.0)
		player.velocity = Vector2.ZERO
		player.player_camera.reset_smoothing()
		for _frame: int in 18:
			await process_frame
		_save(str(capture["file"]))
		if room == null:
			_fail("active room vanished during capture")
			return
	debug.reset_to_defaults()
	print("CH4 S3 MAIN CAPTURE | PASS captures=%d path=%s" % [_captures, OUTPUT])
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


func _save(file_name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var path: String = "%s/%s" % [OUTPUT, file_name]
	if image == null or image.save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("unable to save %s" % path)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("CH4 S3 MAIN CAPTURE: %s" % message)
	quit(1)
