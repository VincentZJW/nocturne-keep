extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const COMBAT_INDICES: Array[int] = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11]


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
		_fail("MainBootstrap did not resolve Chapter IV")
		return
	var controller: Node = level.get_node_or_null("RoomTransitionController")
	if controller == null:
		_fail("formal room transition controller missing")
		return
	var total_enemies: int = 0
	var total_groups: int = 0
	for room_index: int in 17:
		var room_id: StringName = StringName("CH4_AREA_%02d" % room_index)
		if room_index > 0 and not bool(controller.call("_swap_room", room_id, &"EntryWest")):
			_fail("unable to load %s through Main" % room_id)
			return
		await process_frame
		var room: Chapter04Room = controller.get("active_room") as Chapter04Room
		if room == null:
			_fail("Main active room missing for %s" % room_id)
			return
		var spawner: Chapter04EncounterSpawner = room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
		if room_index in COMBAT_INDICES:
			if spawner == null or spawner.manifest == null:
				_fail("Main combat room %s lacks formal encounter data" % room_id)
				return
			total_enemies += spawner.get_total_enemy_count()
			total_groups += spawner.manifest.encounter_count()
		else:
			if spawner != null:
				_fail("Main support room %s unexpectedly owns ordinary encounters" % room_id)
				return
	if total_enemies != 46 or total_groups != 20:
		_fail("Main encounter totals mismatch: groups=%d enemies=%d" % [total_groups, total_enemies])
		return
	debug.reset_to_defaults()
	print("CH4 S4 MAIN ENCOUNTERS | PASS bootstrap=%s rooms=10 groups=20 enemies=46" % ProjectSettings.get_setting("application/run/main_scene"))
	unload_current_scene()
	for _frame: int in 12:
		await process_frame
	for _frame: int in 4:
		await physics_frame
	await create_timer(0.5, true, false, true).timeout
	quit(0)


func _wait_for_level() -> Node:
	for _frame: int in 480:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _fail(message: String) -> void:
	push_error("CH4 S4 MAIN ENCOUNTERS: %s" % message)
	quit(1)
