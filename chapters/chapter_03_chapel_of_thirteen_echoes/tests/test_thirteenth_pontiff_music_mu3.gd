extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const PHASE_01: StringName = &"CH3_BOSS_MUSIC_PHASE_01"
const PHASE_02: StringName = &"CH3_BOSS_MUSIC_PHASE_02"

var _failures: Array[String] = []
var _black_bell_count: int = 0
var _phase_02_crossfade_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 20.0
	var manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	_expect(manager != null and config != null, "Required autoload is missing")
	if manager == null or config == null:
		_finish()
		return
	manager.crossfade_started.connect(_on_crossfade_started)
	var definition: MusicTrackDefinition = MusicManagerService.REGISTRY.find_track(PHASE_02)
	_expect(definition != null, "Phase 2 definition is not registered")
	if definition != null:
		_expect(is_equal_approx(definition.bpm, 124.0), "Phase 2 BPM is not 124 dotted-quarter")
		_expect(definition.beats_per_bar == 6 and definition.beat_unit == 8, "Phase 2 meter is not 6/8")
		_expect(definition.loops, "Phase 2 score must loop")
		_expect(absf(definition.loop_end_seconds - 125.806458) < 0.002, "Phase 2 loop length drifted")

	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"CH3_BOSS_MUSIC_TRANSITION"
	config.debug_skip_chapter_intro = true
	config.debug_reset_chapter_state_on_run = true
	_expect(change_scene_to_file(BOOTSTRAP) == OK, "MainBootstrap could not start")
	var route: Chapter03Route = await _wait_for_route(420)
	_expect(route != null, "Main route did not reach Chapter03Route")
	if route == null:
		await _cleanup(manager, config)
		return
	var room: Chapter03BossSanctumRoom = await _wait_for_room(route, 300)
	_expect(room != null, "Formal Boss room did not load")
	if room == null:
		await _cleanup(manager, config)
		return
	room.boss.phase_transition_stage_reached.connect(_on_transition_stage)
	_expect(manager.is_debug_overlay_enabled(), "Music overlay is not enabled")
	_expect(manager.get_current_track_id() == PHASE_01, "Intro did not begin on Phase 1")
	await _wait_for_phase_02(room.boss, manager, 900)
	_expect(_black_bell_count == 1, "Black-bell reveal emitted %d times" % _black_bell_count)
	_expect(_phase_02_crossfade_count == 1, "Formal Phase 2 crossfade occurred %d times" % _phase_02_crossfade_count)
	_expect(manager.get_current_track_id() == PHASE_02, "Black-bell reveal did not select Phase 2")
	for _frame: int in range(40):
		await process_frame
	_expect(manager.get_active_player_count() == 1, "Crossfade did not settle to one reusable deck")

	# Exercise the one-shot contract twenty additional times without reloading gameplay.
	for index: int in range(20):
		var guard_id: StringName = StringName("MU3_GUARD_%02d" % index)
		manager.play_music(PHASE_01, 0.0, true)
		_expect(manager.phase_switch_once(guard_id, PHASE_02, 0.0), "Cycle %d did not switch" % index)
		_expect(not manager.phase_switch_once(guard_id, PHASE_02, 0.0), "Cycle %d switched twice" % index)
		_expect(manager.get_current_track_id() == PHASE_02, "Cycle %d selected the wrong track" % index)
		_expect(manager.get_active_player_count() == 1, "Cycle %d leaked a deck" % index)
	await _cleanup(manager, config)


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


func _wait_for_phase_02(boss: ThirteenthPontiffEdran, manager: MusicManagerService, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.is_phase_02() and manager.get_current_track_id() == PHASE_02:
			return
	_failures.append("Timed out waiting for formal Phase 2 music transition")


func _on_transition_stage(stage_name: StringName) -> void:
	if stage_name == &"black_bell_reveal":
		_black_bell_count += 1


func _on_crossfade_started(_from_id: StringName, to_id: StringName, _duration: float) -> void:
	if to_id == PHASE_02:
		_phase_02_crossfade_count += 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _cleanup(manager: MusicManagerService, config: DebugRunConfigState) -> void:
	config.reset_to_defaults()
	if manager.crossfade_started.is_connected(_on_crossfade_started):
		manager.crossfade_started.disconnect(_on_crossfade_started)
	manager.set_debug_overlay_enabled(false)
	manager.stop_music()
	manager.clear_all_phase_switch_guards()
	Engine.time_scale = 1.0
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	for _frame: int in range(12):
		await process_frame
	manager.queue_free()
	for _frame: int in range(8):
		await process_frame
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("THIRTEENTH_PONTIFF_MUSIC_MU3: PASS black_bell=1 phase2=1 guard_cycles=20 players=1 main=Bootstrap")
		quit(0)
		return
	for failure: String in _failures:
		push_error("THIRTEENTH_PONTIFF_MUSIC_MU3: %s" % failure)
	quit(1)
