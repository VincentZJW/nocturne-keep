extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const TRACK_ID: StringName = &"CH3_BOSS_MUSIC_PHASE_01"

var _failures: Array[String] = []
var _track_start_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 20.0
	var manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	_expect(manager != null and config != null, "Required MusicManager/DebugRunConfig autoload is missing")
	if manager == null or config == null:
		_finish()
		return
	manager.track_started.connect(_on_track_started)
	_expect(manager.preload_track(TRACK_ID), "Chapter III Phase 1 track is not registered")
	var definition: MusicTrackDefinition = MusicManagerService.REGISTRY.find_track(TRACK_ID)
	_expect(definition != null, "Track definition could not be resolved")
	if definition != null:
		_expect(is_equal_approx(definition.bpm, 92.0), "Track BPM is not 92 dotted-quarter")
		_expect(definition.beats_per_bar == 6 and definition.beat_unit == 8, "Track meter is not 6/8")
		_expect(definition.loops, "Track must loop")
		_expect(absf(definition.loop_end_seconds - 125.217396) < 0.002, "Loop length metadata drifted")

	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"CH3_BOSS_MUSIC_PHASE_01"
	config.debug_skip_chapter_intro = true
	config.debug_reset_chapter_state_on_run = true
	_expect(change_scene_to_file(BOOTSTRAP) == OK, "MainBootstrap could not start")
	var route: Chapter03Route = await _wait_for_route(360)
	_expect(route != null, "Main/F5 route did not reach Chapter03Route")
	if route == null:
		_cleanup(manager, config)
		return
	_expect(manager.is_debug_overlay_enabled(), "Music debug overlay is not enabled for MU2 entry")
	var room: Chapter03BossSanctumRoom = await _wait_for_boss_room(route, 300)
	_expect(room != null, "Formal Boss sanctum room did not load")
	if room == null:
		_cleanup(manager, config)
		return
	_expect(room.find_children("*", "AudioStreamPlayer", true, false).filter(
		func(node: Node) -> bool: return (node as AudioStreamPlayer).bus == &"Music"
	).is_empty(), "Boss room contains a duplicate scene-local Music player")
	_expect(manager.get_current_track_id() == TRACK_ID, "Boss intro did not select the Phase 1 score")
	_expect(manager.get_active_player_count() == 1, "Boss intro did not use exactly one persistent deck")
	await _wait_for_boss_activation(room.boss, 500)
	_expect(room.boss.current_state != ThirteenthPontiffEdran.State.DORMANT, "Boss did not activate after intro")
	_expect(manager.get_current_track_id() == TRACK_ID, "Combat did not retain the Phase 1 score")
	_expect(_track_start_count == 1, "Phase 1 score started %d times instead of once" % _track_start_count)
	for _frame: int in range(8):
		await process_frame
	_expect(absf(manager.get_current_volume_db() - -10.0) < 0.75, "Combat volume did not restore to -10 dB")

	room.boss.debug_force_phase_02()
	await _wait_for_transition(room.boss, 180)
	_expect(manager.get_current_track_id().is_empty(), "MU2 Phase 1 score did not yield at transition")
	for _frame: int in range(40):
		await process_frame
	_expect(manager.get_active_player_count() == 0, "Phase transition fade left a playing deck")
	_cleanup(manager, config)


func _wait_for_route(maximum_frames: int) -> Chapter03Route:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE_PATH:
			return current_scene as Chapter03Route
	return null


func _wait_for_boss_room(route: Chapter03Route, maximum_frames: int) -> Chapter03BossSanctumRoom:
	for _frame: int in range(maximum_frames):
		await process_frame
		var room: Chapter03BossSanctumRoom = route.transition_controller.active_room as Chapter03BossSanctumRoom
		if room != null:
			return room
	return null


func _wait_for_boss_activation(boss: ThirteenthPontiffEdran, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.current_state != ThirteenthPontiffEdran.State.DORMANT:
			return
	_failures.append("Timed out waiting for Boss activation")


func _wait_for_transition(boss: ThirteenthPontiffEdran, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.current_state == ThirteenthPontiffEdran.State.PHASE_TRANSITION:
			return
	_failures.append("Timed out waiting for Boss phase transition")


func _on_track_started(track_id: StringName) -> void:
	if track_id == TRACK_ID:
		_track_start_count += 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _cleanup(manager: MusicManagerService, config: DebugRunConfigState) -> void:
	config.reset_to_defaults()
	if manager.track_started.is_connected(_on_track_started):
		manager.track_started.disconnect(_on_track_started)
	manager.set_debug_overlay_enabled(false)
	manager.stop_music()
	Engine.time_scale = 1.0
	if current_scene != null:
		current_scene.free()
		current_scene = null
	for _frame: int in range(8):
		await process_frame
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("THIRTEENTH_PONTIFF_MUSIC_MU2: PASS main=Bootstrap track_once=1 meter=6/8 loop=125.217 intro_low=1 combat=-10 transition_fade=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("THIRTEENTH_PONTIFF_MUSIC_MU2: %s" % failure)
	quit(1)
