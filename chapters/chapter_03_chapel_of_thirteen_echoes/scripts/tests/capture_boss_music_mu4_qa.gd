extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const OUTPUT_DIR: String = "res://docs/qa/boss_music/mu4"
const PHASE_01: StringName = &"CH3_BOSS_MUSIC_PHASE_01"
const PHASE_02: StringName = &"CH3_BOSS_MUSIC_PHASE_02"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	Engine.time_scale = 4.0
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	var manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	if config == null or manager == null:
		_fail("Required autoload is missing")
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"CH3_BOSS_MUSIC_TRANSITION"
	config.debug_skip_chapter_intro = true
	config.debug_reset_chapter_state_on_run = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("Could not start MainBootstrap")
		return
	var route: Chapter03Route = await _wait_for_route(480)
	if route == null:
		_fail("Chapter03Route did not load")
		return
	var first_room: Chapter03BossSanctumRoom = await _wait_for_room(route, null, 360)
	if first_room == null:
		_fail("Formal Boss room did not load")
		return
	if not await _wait_for_transition_duck(first_room.boss, manager, 1200):
		_fail("Formal transition dialogue did not apply Duck")
		return
	await _save_viewport("01_dialogue_duck_transition_main.png")
	print("BOSS_MUSIC_MU4_CAPTURE: dialogue evidence saved")
	if not await _wait_for_track(manager, PHASE_02, 600):
		_fail("Phase 2 score did not start")
		return
	if not await _wait_for_phase_02_control(first_room.boss, 600):
		_fail("Phase 2 protected transition did not finish")
		return
	# The focused headless test drives the public respawn signal.  The graphical
	# evidence reconstructs the same saved room synchronously to avoid capturing
	# inside the route fade.
	manager.stop_music()
	manager.clear_phase_switch_guard(&"CH3_EDRAN_PHASE_02_ONCE")
	if not route.transition_controller._swap_room(&"CH3_BOSS", &"EntryWest"):
		_fail("Retry room reconstruction failed")
		return
	var retry_room: Chapter03BossSanctumRoom = (
		route.transition_controller.active_room as Chapter03BossSanctumRoom
	)
	if retry_room != null:
		retry_room.sanctum.skip_intro_to_combat_state()
	await process_frame
	await process_frame
	if retry_room == null or not await _wait_for_track(manager, PHASE_01, 240):
		_fail("Retry did not rebuild Phase 1")
		return
	await _save_viewport("02_retry_phase_01_main.png")
	print("BOSS_MUSIC_MU4_CAPTURE: retry evidence saved")
	retry_room._on_death_sequence_started()
	# The exact 1.50-second deck completion is asserted in the focused lifecycle
	# test.  Finish it immediately here so the graphical runner does not spend
	# wall-clock time inside a background macOS render window.
	manager.stop_music()
	if not route.transition_controller._swap_room(&"CH3_POST_BOSS", &"EntryWest"):
		_fail("Reward transition was rejected")
		return
	await process_frame
	await _save_viewport("03_reward_silent_main.png")
	print("BOSS_MUSIC_MU4_CAPTURE: reward evidence saved")
	config.reset_to_defaults()
	manager.set_debug_overlay_enabled(false)
	manager.stop_music()
	Engine.time_scale = 1.0
	print("BOSS_MUSIC_MU4_CAPTURE: PASS captures=%d main=%s" % [_captures, route.scene_file_path])
	current_scene.queue_free()
	current_scene = null
	for _frame: int in range(12):
		await process_frame
	quit(0)


func _wait_for_route(maximum_frames: int) -> Chapter03Route:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE_PATH:
			return current_scene as Chapter03Route
	return null


func _wait_for_room(
	route: Chapter03Route, previous: Chapter03BossSanctumRoom, maximum_frames: int
) -> Chapter03BossSanctumRoom:
	for _frame: int in range(maximum_frames):
		await process_frame
		var room: Chapter03BossSanctumRoom = (
			route.transition_controller.active_room as Chapter03BossSanctumRoom
		)
		if room != null and room != previous:
			return room
	return null


func _wait_for_transition_duck(
	boss: ThirteenthPontiffEdran, manager: MusicManagerService, maximum_frames: int
) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if (
			boss.current_state == ThirteenthPontiffEdran.State.PHASE_TRANSITION
			and manager.get_dialogue_duck_db() >= 5.9
		):
			return true
	return false


func _wait_for_track(
	manager: MusicManagerService, track_id: StringName, maximum_frames: int
) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if manager.get_current_track_id() == track_id:
			return true
	return false


func _wait_for_phase_02_control(boss: ThirteenthPontiffEdran, maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if (
			boss.is_phase_02()
			and boss.current_state != ThirteenthPontiffEdran.State.PHASE_TRANSITION
		):
			return true
	return false


func _save_viewport(file_name: String) -> void:
	var manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	if manager != null:
		manager._update_debug_overlay()
	await RenderingServer.frame_post_draw
	var output: String = "%s/%s" % [OUTPUT_DIR, file_name]
	var image: Image = root.get_texture().get_image()
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("Could not save %s" % output)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("BOSS_MUSIC_MU4_CAPTURE: %s" % message)
	quit(1)
