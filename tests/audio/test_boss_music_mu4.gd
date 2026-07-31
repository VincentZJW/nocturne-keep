extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const CH2_PHASE_01: StringName = &"CH2_BOSS_MUSIC_PHASE_01"
const CH2_PHASE_02: StringName = &"CH2_BOSS_MUSIC_PHASE_02"
const CH3_PHASE_01: StringName = &"CH3_BOSS_MUSIC_PHASE_01"
const CH3_PHASE_02: StringName = &"CH3_BOSS_MUSIC_PHASE_02"

var _failures: Array[String] = []


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
	await _test_shared_dialogue_duck(manager)
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"CH3_BOSS_MUSIC_TRANSITION"
	config.debug_skip_chapter_intro = true
	config.debug_reset_chapter_state_on_run = true
	_expect(change_scene_to_file(BOOTSTRAP) == OK, "MainBootstrap could not start")
	var route: Chapter03Route = await _wait_for_route(420)
	_expect(route != null, "Formal Main route did not reach Chapter III")
	if route == null:
		await _cleanup(manager, config)
		return
	var first_room: Chapter03BossSanctumRoom = await _wait_for_boss_room(route, 300)
	_expect(first_room != null, "Formal Boss room did not load")
	if first_room == null:
		await _cleanup(manager, config)
		return
	first_room._on_dialogue_started()
	_expect(is_equal_approx(manager.get_dialogue_duck_db(), 6.0), "Edran dialogue did not apply 6 dB Duck")
	first_room._on_dialogue_finished()
	_expect(is_zero_approx(manager.get_dialogue_duck_db()), "Edran dialogue did not restore Duck")
	await _wait_for_track(manager, CH3_PHASE_02, 900)
	_expect(manager.get_current_track_id() == CH3_PHASE_02, "Phase transition did not reach Phase 2")
	_expect(manager.get_dialogue_duck_db() >= 0.0, "Dialogue Duck state is invalid")

	# Formal retry reloads the saved Boss room, clears the one-shot transition guard
	# and starts a fresh Phase 1 without preserving Phase 2 playback.
	route.transition_controller._on_player_respawned(Vector2.ZERO)
	var second_room: Chapter03BossSanctumRoom = await _wait_for_reloaded_boss_room(
		route, first_room, 360
	)
	_expect(second_room != null, "Boss room did not reload on retry")
	if second_room != null:
		await _wait_for_track(manager, CH3_PHASE_01, 180)
		_expect(manager.get_current_track_id() == CH3_PHASE_01, "Retry did not restart Phase 1")
		_expect(not second_room.boss.is_phase_02(), "Retry preserved Phase 2 Boss state")
		_expect(
			not manager.is_phase_switch_used(&"CH3_EDRAN_PHASE_02_ONCE"),
			"Retry did not clear the Phase 2 one-shot guard"
		)
		second_room._on_death_sequence_started()
		_expect(manager.get_current_track_id().is_empty(), "Death did not begin the 1.5 s fade")
		for _frame: int in range(90):
			await process_frame
		_expect(manager.get_active_player_count() == 0, "Death fade left a playing deck")

	_expect(
		route.transition_controller.request_room_change(&"CH3_POST_BOSS", &"EntryWest"),
		"Reward room transition was rejected"
	)
	await _wait_for_room_id(route, &"CH3_POST_BOSS", 180)
	_expect(manager.get_current_track_id().is_empty(), "Reward state retained Boss music")
	_expect(manager.get_active_player_count() == 0, "Reward state retained a playing Boss deck")
	_expect(
		route.transition_controller.request_room_change(&"CH3_UNDERKEEP_DESCENT", &"EntryWest"),
		"Chapter-exit room transition was rejected"
	)
	await _wait_for_room_id(route, &"CH3_UNDERKEEP_DESCENT", 180)
	_expect(manager.get_current_track_id().is_empty(), "Chapter exit retained Boss music")
	_expect(manager.get_active_player_count() == 0, "Chapter exit retained a playing Boss deck")
	await _cleanup(manager, config)


func _test_shared_dialogue_duck(manager: MusicManagerService) -> void:
	manager.stop_music()
	var bus_index: int = AudioServer.get_bus_index(&"Music")
	var base_db: float = AudioServer.get_bus_volume_db(bus_index)
	_expect(manager.play_music(CH2_PHASE_01, 0.0, true), "Shared Duck test could not start Phase 1")
	manager.duck_for_dialogue(6.0, 0.0)
	_expect(is_equal_approx(manager.get_dialogue_duck_db(), 6.0), "Dialogue Duck amount is not 6 dB")
	_expect(
		absf(AudioServer.get_bus_volume_db(bus_index) - (base_db - 6.0)) < 0.05,
		"Music Bus did not attenuate by 6 dB"
	)
	_expect(manager.crossfade_to(CH2_PHASE_02, 0.05), "Crossfade under Duck failed")
	for _frame: int in range(20):
		await process_frame
	_expect(manager.get_current_track_id() == CH2_PHASE_02, "Duck cancelled the crossfade")
	_expect(manager.get_active_player_count() == 1, "Crossfade under Duck leaked a deck")
	_expect(is_equal_approx(manager.get_dialogue_duck_db(), 6.0), "Crossfade cleared Dialogue Duck")
	manager.restore_after_dialogue(0.0)
	_expect(is_equal_approx(AudioServer.get_bus_volume_db(bus_index), base_db), "Duck did not restore Music Bus")
	manager.stop_music()


func _wait_for_route(maximum_frames: int) -> Chapter03Route:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE_PATH:
			return current_scene as Chapter03Route
	return null


func _wait_for_boss_room(route: Chapter03Route, maximum_frames: int) -> Chapter03BossSanctumRoom:
	for _frame: int in range(maximum_frames):
		await process_frame
		var room: Chapter03BossSanctumRoom = (
			route.transition_controller.active_room as Chapter03BossSanctumRoom
		)
		if room != null:
			return room
	return null


func _wait_for_reloaded_boss_room(
	route: Chapter03Route, previous_room: Chapter03BossSanctumRoom, maximum_frames: int
) -> Chapter03BossSanctumRoom:
	for _frame: int in range(maximum_frames):
		await process_frame
		var room: Chapter03BossSanctumRoom = (
			route.transition_controller.active_room as Chapter03BossSanctumRoom
		)
		if room != null and room != previous_room:
			return room
	return null


func _wait_for_track(
	manager: MusicManagerService, track_id: StringName, maximum_frames: int
) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if manager.get_current_track_id() == track_id:
			return
	_failures.append("Timed out waiting for track %s" % track_id)


func _wait_for_room_id(route: Chapter03Route, room_id: StringName, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if (
			route.transition_controller.active_room_id == room_id
			and not route.transition_controller._transitioning
		):
			return
	_failures.append("Timed out waiting for room %s" % room_id)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _cleanup(manager: MusicManagerService, config: DebugRunConfigState) -> void:
	config.reset_to_defaults()
	manager.set_debug_overlay_enabled(false)
	manager.stop_music()
	manager.clear_all_phase_switch_guards()
	Engine.time_scale = 1.0
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	for _frame: int in range(16):
		await process_frame
	manager.queue_free()
	for _frame: int in range(8):
		await process_frame
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("BOSS_MUSIC_MU4: PASS duck=6dB crossfade_safe=1 death=1.5 retry=p1 reward=silent exit=silent main=Bootstrap")
		quit(0)
		return
	for failure: String in _failures:
		push_error("BOSS_MUSIC_MU4: %s" % failure)
	quit(1)
