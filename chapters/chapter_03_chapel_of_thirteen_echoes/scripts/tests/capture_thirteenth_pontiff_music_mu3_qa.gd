extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const OUTPUT_DIR: String = "res://docs/qa/boss_music/mu3"
const PHASE_02: StringName = &"CH3_BOSS_MUSIC_PHASE_02"

var _captures: int = 0
var _black_bell_seen: bool = false


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
	var room: Chapter03BossSanctumRoom = await _wait_for_room(route, 300)
	if room == null:
		_fail("Formal Boss room did not load")
		return
	room.boss.phase_transition_stage_reached.connect(_on_stage)
	if not await _wait_for_active_transition(room.boss, 960):
		_fail("Formal transition did not begin")
		return
	await _save_viewport("01_phase_01_transition_attenuation_main.png")
	if not await _wait_for_black_bell(420):
		_fail("Black-bell presentation event did not occur")
		return
	await _save_viewport("02_black_bell_crossfade_main.png")
	if not await _wait_for_phase_02(room.boss, manager, 480):
		_fail("Phase 2 score did not settle")
		return
	await _save_viewport("03_phase_02_bell_bound_combat_main.png")
	config.reset_to_defaults()
	manager.set_debug_overlay_enabled(false)
	manager.stop_music()
	Engine.time_scale = 1.0
	print("THIRTEENTH_PONTIFF_MUSIC_MU3_CAPTURE: PASS captures=%d main=%s track=%s" % [_captures, route.scene_file_path, PHASE_02])
	current_scene.queue_free()
	current_scene = null
	for _frame: int in range(6):
		await process_frame
	quit(0)


func _wait_for_route(maximum_frames: int) -> Chapter03Route:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE_PATH:
			return current_scene as Chapter03Route
	return null


func _wait_for_room(route: Chapter03Route, maximum_frames: int) -> Chapter03BossSanctumRoom:
	for _frame: int in range(maximum_frames):
		await process_frame
		var room: Chapter03BossSanctumRoom = route.transition_controller.active_room as Chapter03BossSanctumRoom
		if room != null:
			return room
	return null


func _wait_for_active_transition(boss: ThirteenthPontiffEdran, maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.current_state == ThirteenthPontiffEdran.State.PHASE_TRANSITION:
			return true
	return false


func _wait_for_black_bell(maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if _black_bell_seen:
			return true
	return false


func _wait_for_phase_02(boss: ThirteenthPontiffEdran, manager: MusicManagerService, maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.is_phase_02() and manager.get_current_track_id() == PHASE_02 and manager.get_active_player_count() == 1:
			return true
	return false


func _on_stage(stage_name: StringName) -> void:
	if stage_name == &"black_bell_reveal":
		_black_bell_seen = true


func _save_viewport(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var output: String = "%s/%s" % [OUTPUT_DIR, file_name]
	var image: Image = root.get_texture().get_image()
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("Could not save %s" % output)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("THIRTEENTH_PONTIFF_MUSIC_MU3_CAPTURE: %s" % message)
	quit(1)
