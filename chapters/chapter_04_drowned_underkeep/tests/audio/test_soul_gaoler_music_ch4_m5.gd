extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const BOSS_SCENE: PackedScene = preload("res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn")
const PHASE_01: StringName = &"CH4_BOSS_SOUL_GAOLER_PHASE_01"
const PHASE_02: StringName = &"CH4_BOSS_SOUL_GAOLER_PHASE_02"
const TRANSITION: StringName = &"CH4_BOSS_SOUL_GAOLER_TRANSITION"
const PHASE_01_SCORE: String = "res://chapters/chapter_04_drowned_underkeep/assets/audio/music/boss/soul_gaoler_ormund/source/soul_gaoler_phase_01_submerged_chains_score.json"
const PHASE_02_SCORE: String = "res://chapters/chapter_04_drowned_underkeep/assets/audio/music/boss/soul_gaoler_ormund/source/soul_gaoler_phase_02_broken_cage_score.json"
const GAOLER_THEME: Array[int] = [50, 48, 46, 45, 39]
const SOUL_THEME: Array[int] = [65, 68, 67, 65, 64, 63, 62]
const UNDERTOW_THEME: Array[int] = [57, 55, 51, 50]

var _failures: Array[String] = []
var _transition_cues: Array[StringName] = []
var _stinger_starts: int = 0
var _phase_two_crossfades: int = 0
var _formal_dwell_seconds: float = 0.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var dwell_override: String = OS.get_environment("CH4_MELODY_MAIN_DWELL_SECONDS")
	if dwell_override.is_valid_float():
		_formal_dwell_seconds = maxf(0.0, dwell_override.to_float())
	var manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	_expect(manager != null and debug != null, "Required audio/debug Autoload is missing")
	if manager == null or debug == null:
		_finish()
		return
	_validate_definitions()
	_validate_melody_contracts()
	manager.transition_stinger_started.connect(_on_stinger_started)
	manager.crossfade_started.connect(_on_crossfade_started)

	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_BOSS_PHASE_01"
	debug.debug_skip_chapter_intro = true
	debug.debug_reset_chapter_state_on_run = true
	_expect(ProjectSettings.get_setting("application/run/main_scene") == BOOTSTRAP, "F5 authority must remain MainBootstrap")
	_expect(change_scene_to_file(BOOTSTRAP) == OK, "MainBootstrap could not start")
	var level: DrownedUnderkeepRoute = await _wait_for_level(600)
	_expect(level != null, "Main did not reach Chapter IV")
	if level == null:
		await _cleanup(manager, debug)
		return
	var room_controller: Chapter04RoomTransitionController = level.get_node("RoomTransitionController") as Chapter04RoomTransitionController
	var room: Node = await _wait_for_boss_room(room_controller, 300)
	_expect(room != null, "Formal Boss room did not load")
	if room == null:
		await _cleanup(manager, debug)
		return
	var flow: Chapter04BossRoomController = room.get_node("BossRoomController") as Chapter04BossRoomController
	var boss: SoulGaolerOrmund = room.get_node("Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
	boss.phase_transition_cue.connect(_on_transition_cue)
	await process_frame
	_expect(manager.get_current_track_id() == PHASE_01, "Formal intro did not start Phase 1")
	_expect(is_equal_approx(manager.get_dialogue_duck_db(), 6.0), "Formal intro did not apply the 6 dB dialogue Duck")
	flow.skip_intro_for_qa()
	await process_frame
	_expect(manager.get_current_track_id() == PHASE_01, "Phase 1 formal Main cue did not start")
	_expect(manager.get_dialogue_duck_db() == 0.0, "QA combat start retained dialogue Duck")
	if _formal_dwell_seconds > 0.0:
		boss.set_physics_process(false)
		await _dwell_formal_track(manager, PHASE_01, _formal_dwell_seconds, "Phase 1")
		boss.set_physics_process(true)

	# One real-time transition validates the authored 9.23-second bridge against
	# the five named Boss-animation sync points.
	boss.health_component.set_current_health(roundi(boss.health_component.max_health * 0.50))
	_expect(boss.is_physics_processing(), "Formal Main Boss physics was disabled at transition start")
	await _wait_for_phase_two(boss, manager, 12.0)
	_expect(boss.phase == 2, "Boss did not complete the real-time Phase 2 transition")
	_expect(manager.get_current_track_id() == PHASE_02, "Phase 2 music did not replace Phase 1")
	_expect(_transition_cues == SoulGaolerOrmund.PHASE_TRANSITION_CUES, "Transition cue order/count drifted: %s" % [str(_transition_cues)])
	_expect(_stinger_starts == 1, "Transition stinger started %d times" % _stinger_starts)
	_expect(_phase_two_crossfades == 1, "Phase 2 crossfade started %d times" % _phase_two_crossfades)
	_expect(flow.get_last_music_sync_cue() == &"final_iron_impact", "Controller did not retain the final sync cue")
	boss.health_component.set_current_health(0)
	await create_timer(2.25, true, false, true).timeout
	_expect(manager.get_current_track_id().is_empty(), "Boss death did not clear the current music id")
	_expect(manager.get_total_audio_player_count() == 0, "Boss death did not finish the 2.0-second deck/stinger fade")

	# Ten formal Boss-scene combat lifecycles guard against stale phase state.
	for run_index: int in range(10):
		var isolated_boss: SoulGaolerOrmund = BOSS_SCENE.instantiate() as SoulGaolerOrmund
		root.add_child(isolated_boss)
		await process_frame
		isolated_boss.health_component.set_current_health(roundi(isolated_boss.health_component.max_health * 0.50))
		await process_frame
		_expect(isolated_boss.current_state == isolated_boss.PHASE_TRANSITION, "Boss cycle %d missed transition" % run_index)
		isolated_boss.complete_debug_phase_transition()
		_expect(isolated_boss.phase == 2, "Boss cycle %d did not reach Phase 2" % run_index)
		isolated_boss.health_component.set_current_health(0)
		await process_frame
		_expect(isolated_boss.is_dead(), "Boss cycle %d did not enter death" % run_index)
		isolated_boss.queue_free()
		await process_frame

	# Twenty guarded transition calls prove one input/event cannot retrigger the
	# stinger/crossfade path or leak audio decks.
	manager.stop_music()
	for index: int in range(20):
		var guard_id: StringName = StringName("CH4_M5_TRANSITION_%02d" % index)
		manager.play_music(PHASE_01, 0.0, true)
		_expect(manager.phase_switch_once(guard_id, PHASE_02, 0.0), "Transition guard cycle %d did not switch" % index)
		_expect(not manager.phase_switch_once(guard_id, PHASE_02, 0.0), "Transition guard cycle %d switched twice" % index)
		_expect(manager.get_current_track_id() == PHASE_02, "Transition guard cycle %d selected wrong track" % index)
		_expect(manager.get_active_player_count() == 1, "Transition guard cycle %d leaked a deck" % index)
	manager.stop_music()

	# Reload Main through the advertised direct Phase 2 debug spawn.
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	for _frame: int in range(12):
		await process_frame
	debug.debug_start_spawn_id = &"CH4_BOSS_PHASE_02"
	debug.debug_reset_chapter_state_on_run = true
	_expect(change_scene_to_file(BOOTSTRAP) == OK, "Direct Phase 2 Main start failed")
	level = await _wait_for_level(600)
	_expect(level != null, "Direct Phase 2 Main did not reach Chapter IV")
	if level != null:
		room_controller = level.get_node("RoomTransitionController") as Chapter04RoomTransitionController
		room = await _wait_for_boss_room(room_controller, 300)
		boss = room.get_node_or_null("Enemies/SoulGaolerOrmund") as SoulGaolerOrmund if room != null else null
		_expect(boss != null and boss.phase == 2, "CH4_BOSS_PHASE_02 did not create a true Phase 2 Boss")
		_expect(manager.get_current_track_id() == PHASE_02, "Direct Phase 2 start did not select Phase 2 music")
		if boss != null and _formal_dwell_seconds > 0.0:
			boss.set_physics_process(false)
			await _dwell_formal_track(manager, PHASE_02, _formal_dwell_seconds, "Phase 2")
			boss.set_physics_process(true)
	await _cleanup(manager, debug)


func _validate_definitions() -> void:
	var p1: MusicTrackDefinition = MusicManagerService.REGISTRY.find_track(PHASE_01)
	var p2: MusicTrackDefinition = MusicManagerService.REGISTRY.find_track(PHASE_02)
	var bridge: MusicTrackDefinition = MusicManagerService.REGISTRY.find_track(TRANSITION)
	_expect(p1 != null and p2 != null and bridge != null, "Chapter IV music registry is incomplete")
	if p1 != null:
		_expect(p1.loops and is_equal_approx(p1.bpm, 78.0), "Phase 1 loop/BPM contract drifted")
		_expect(absf(p1.loop_end_seconds - 184.615375) < 0.002, "Phase 1 duration drifted")
	if p2 != null:
		_expect(p2.loops and is_equal_approx(p2.bpm, 104.0), "Phase 2 loop/BPM contract drifted")
		_expect(absf(p2.loop_end_seconds - 166.153854) < 0.002, "Phase 2 duration drifted")
	if bridge != null:
		_expect(not bridge.loops and is_equal_approx(bridge.bpm, 104.0), "Transition loop/BPM contract drifted")
		_expect(bridge.stream != null and absf(bridge.stream.get_length() - 9.230771) < 0.03, "Transition duration drifted")


func _validate_melody_contracts() -> void:
	var phase_one: Dictionary = _load_score(PHASE_01_SCORE)
	var phase_two: Dictionary = _load_score(PHASE_02_SCORE)
	_expect(not phase_one.is_empty() and not phase_two.is_empty(), "Formal Chapter IV score JSON is missing")
	if phase_one.is_empty() or phase_two.is_empty():
		return
	for score: Dictionary in [phase_one, phase_two]:
		_expect(_numeric_array_matches(score.get("gaoler_motif", []) as Array, GAOLER_THEME), "Gaoler theme identity drifted")
		_expect(_numeric_array_matches(score.get("soul_prison_theme", []) as Array, SOUL_THEME), "Soul Prison theme identity drifted")
		_expect(_numeric_array_matches(score.get("undertow_motif", []) as Array, UNDERTOW_THEME), "Undertow motif identity drifted")
		var variations: Array = score.get("gaoler_theme_variations", []) as Array
		_expect(variations.size() >= 6, "Gaoler theme has fewer than six authored variations")
	var p1_sections: Dictionary = phase_one.get("sections", {}) as Dictionary
	var p2_sections: Dictionary = phase_two.get("sections", {}) as Dictionary
	_expect(p1_sections.size() == 8 and p1_sections.has("E_The_Empty_Cell"), "Phase 1 rich-form section contract drifted")
	_expect(p2_sections.size() == 7 and p2_sections.has("E2_Chains_Against_Souls"), "Phase 2 rich-form section contract drifted")
	_expect(p1_sections.has("B_The_Prisoners") and p1_sections.has("C_The_Flood"), "Phase 1 theme-absence regions are missing")
	_expect(p2_sections.has("C2_Undertow_Hunt") and p2_sections.has("Final_Lock"), "Phase 2 Undertow/Final Lock regions are missing")


func _load_score(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}


func _numeric_array_matches(actual: Array, expected: Array[int]) -> bool:
	if actual.size() != expected.size():
		return false
	for index: int in range(expected.size()):
		if int(actual[index]) != expected[index]:
			return false
	return true


func _wait_for_level(maximum_frames: int) -> DrownedUnderkeepRoute:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene as DrownedUnderkeepRoute
	return null


func _wait_for_boss_room(controller: Chapter04RoomTransitionController, maximum_frames: int) -> Node:
	for _frame: int in range(maximum_frames):
		await process_frame
		if controller != null and controller.active_room_id == &"CH4_AREA_14":
			return controller.active_room
	return null


func _wait_for_phase_two(boss: SoulGaolerOrmund, manager: MusicManagerService, maximum_seconds: float) -> void:
	var deadline_ms: int = Time.get_ticks_msec() + roundi(maximum_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline_ms:
		await process_frame
		if boss.phase == 2 and manager.get_current_track_id() == PHASE_02:
			return
	_failures.append(
		"Timed out waiting for real-time Phase 2 bridge: state=%s timer=%.3f physics=%s phase=%d track=%s" % [
			boss.current_state,
			boss.state_timer,
			boss.is_physics_processing(),
			boss.phase,
			manager.get_current_track_id(),
		]
	)


func _dwell_formal_track(manager: MusicManagerService, expected_track: StringName, duration_seconds: float, label: String) -> void:
	var started_ms: int = Time.get_ticks_msec()
	var deadline_ms: int = Time.get_ticks_msec() + roundi(duration_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline_ms:
		await create_timer(0.25, true, false, true).timeout
		if manager.get_current_track_id() != expected_track:
			_failures.append("%s changed track during %.1f-second formal-room dwell" % [label, duration_seconds])
			return
		var player_count: int = manager.get_active_player_count()
		if player_count < 1 or player_count > 2:
			_failures.append("%s formal-room dwell changed active deck count to %d" % [label, player_count])
			return
		# Main can enter the dwell while its authored intro-to-combat fade still
		# overlaps two decks.  It must settle to one deck after that grace period.
		if Time.get_ticks_msec() - started_ms > 3000 and player_count != 1:
			_failures.append("%s formal-room dwell did not settle to one active deck" % label)
			return


func _on_transition_cue(cue_name: StringName, _elapsed_seconds: float) -> void:
	_transition_cues.append(cue_name)


func _on_stinger_started(track_id: StringName) -> void:
	if track_id == TRANSITION:
		_stinger_starts += 1


func _on_crossfade_started(_from_id: StringName, to_id: StringName, _duration: float) -> void:
	if to_id == PHASE_02:
		_phase_two_crossfades += 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _cleanup(manager: MusicManagerService, debug: DebugRunConfigState) -> void:
	debug.reset_to_defaults()
	manager.set_debug_overlay_enabled(false)
	manager.stop_music()
	manager.clear_all_phase_switch_guards()
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	for _frame: int in range(12):
		await process_frame
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("SOUL_GAOLER_MUSIC_CH4_M5: PASS main=Bootstrap real_bridge=1 boss_cycles=10 transition_cycles=20 direct_phase2=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("SOUL_GAOLER_MUSIC_CH4_M5: %s" % failure)
	quit(1)
