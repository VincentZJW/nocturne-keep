extends SceneTree

const PHASE_01: StringName = &"CH2_BOSS_MUSIC_PHASE_01"
const PHASE_02: StringName = &"CH2_BOSS_MUSIC_PHASE_02"
const CH3_PHASE_01: StringName = &"CH3_BOSS_MUSIC_PHASE_01"
const GUARD: StringName = &"MU1_TEST_PHASE_SWITCH"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	_expect(manager != null, "MusicManager autoload is missing")
	if manager == null:
		_finish()
		return
	_expect(AudioServer.get_bus_index(&"Master") == 0, "Master bus is missing")
	_expect(AudioServer.get_bus_index(&"Music") >= 0, "Music bus is missing")
	_expect(AudioServer.get_bus_index(&"SFX") >= 0, "SFX bus is missing")
	_expect(AudioServer.get_bus_index(&"Ambient") >= 0, "Ambient bus is missing")
	_expect(AudioServer.get_bus_index(&"UI") >= 0, "UI bus is missing")
	_expect(manager.preload_track(PHASE_01), "Phase 1 definition is missing")
	_expect(manager.preload_track(PHASE_02), "Phase 2 definition is missing")
	_expect(manager.preload_track(CH3_PHASE_01), "Chapter III Phase 1 definition is missing")
	var deck_count: int = manager.find_children("MusicDeck*", "AudioStreamPlayer", false, false).size()
	_expect(deck_count == 2, "MusicManager must own exactly two reusable decks")

	manager.stop_music()
	_expect(manager.play_music(PHASE_01, 0.0), "Phase 1 did not start")
	_expect(not manager.play_music(PHASE_01, 0.0), "Repeated Phase 1 request restarted playback")
	_expect(manager.get_current_track_id() == PHASE_01, "Phase 1 id mismatch")
	_expect(manager.get_active_player_count() == 1, "Phase 1 must use one active player")
	manager.duck_for_dialogue(10.0, 0.0)
	manager.restore_after_dialogue(0.0)

	for iteration: int in range(20):
		manager.stop_music()
		await create_timer(0.02, true, false, true).timeout
		manager.clear_phase_switch_guard(GUARD)
		_expect(manager.play_music(PHASE_01, 0.0, true), "Cycle %d Phase 1 failed" % iteration)
		_expect(manager.phase_switch_once(GUARD, PHASE_02, 0.0), "Cycle %d Phase 2 failed" % iteration)
		_expect(not manager.phase_switch_once(GUARD, PHASE_02, 0.0), "Cycle %d switched twice" % iteration)
		_expect(manager.get_current_track_id() == PHASE_02, "Cycle %d track id mismatch" % iteration)
		_expect(manager.get_active_player_count() == 1, "Cycle %d leaked a playing deck" % iteration)
	manager.stop_music()
	await create_timer(0.10, true, false, true).timeout
	manager.clear_phase_switch_guard(GUARD)
	manager.queue_free()
	for _frame: int in range(5):
		await process_frame
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("MUSIC_MANAGER_MU1_TEST: PASS buses=5 decks=2 transitions=20 duplicate_guard=PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error("MUSIC_MANAGER_MU1_TEST: %s" % failure)
	quit(1)
