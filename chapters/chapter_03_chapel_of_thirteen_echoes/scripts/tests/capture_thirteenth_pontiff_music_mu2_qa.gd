extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const OUTPUT_DIR: String = "res://docs/qa/boss_music/mu2"
const TRACK_ID: StringName = &"CH3_BOSS_MUSIC_PHASE_01"

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
	config.debug_start_spawn_id = &"CH3_BOSS_MUSIC_PHASE_01"
	config.debug_skip_chapter_intro = true
	config.debug_reset_chapter_state_on_run = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("Could not start MainBootstrap")
		return
	var route: Chapter03Route = await _wait_for_route(420)
	if route == null:
		_fail("Chapter03Route did not load through MainBootstrap")
		return
	var room: Chapter03BossSanctumRoom = await _wait_for_room(route, 300)
	if room == null:
		_fail("Formal Boss room did not load")
		return
	if not await _wait_for_track(manager, 240):
		_fail("Phase 1 track did not start in the formal intro")
		return
	await _save_viewport("01_ch3_phase_01_intro_main.png")
	if not await _wait_for_activation(room.boss, 720):
		_fail("Edran did not activate after the formal intro")
		return
	var player: Player = get_first_node_in_group("player") as Player
	if player != null:
		player.hurtbox.set_invulnerable(true)
		player.global_position = room.boss.global_position + Vector2(-180.0, -24.0)
		player.velocity = Vector2.ZERO
		player.player_camera.reset_smoothing()
	for _frame: int in range(12):
		await process_frame
	await _save_viewport("02_ch3_phase_01_combat_main.png")
	room.boss.debug_force_phase_02()
	for _frame: int in range(240):
		await process_frame
		if room.boss.current_state == ThirteenthPontiffEdran.State.PHASE_TRANSITION:
			break
	await _save_viewport("03_ch3_phase_01_yield_main.png")
	config.reset_to_defaults()
	manager.set_debug_overlay_enabled(false)
	manager.stop_music()
	Engine.time_scale = 1.0
	print("THIRTEENTH_PONTIFF_MUSIC_MU2_CAPTURE: PASS captures=%d main=%s" % [_captures, route.scene_file_path])
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


func _wait_for_track(manager: MusicManagerService, maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if manager.get_current_track_id() == TRACK_ID:
			return true
	return false


func _wait_for_activation(boss: ThirteenthPontiffEdran, maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.current_state != ThirteenthPontiffEdran.State.DORMANT:
			return true
	return false


func _save_viewport(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var output: String = "%s/%s" % [OUTPUT_DIR, file_name]
	var image: Image = root.get_texture().get_image()
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("Could not save %s" % output)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("THIRTEENTH_PONTIFF_MUSIC_MU2_CAPTURE: %s" % message)
	quit(1)
