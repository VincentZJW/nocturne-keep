extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
const PHASE_01: StringName = &"CH2_BOSS_MUSIC_PHASE_01"
const PHASE_02: StringName = &"CH2_BOSS_MUSIC_PHASE_02"

var _failures: Array[String] = []
var _phase_01_started: int = 0
var _phase_02_started: int = 0


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
	manager.track_started.connect(_on_track_started)
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_BOSS_MUSIC_PHASE_02"
	config.debug_skip_chapter_intro = true
	config.debug_reset_chapter_state_on_run = true
	_expect(change_scene_to_file(BOOTSTRAP) == OK, "MainBootstrap could not start")
	var level: Node = await _wait_for_level(300)
	_expect(level != null, "Main/F5 route did not reach SilentCourt")
	if level == null:
		_finish()
		return
	var boss: HollowDuchess = level.get_node_or_null("GameplayWorld/BossArea/HollowDuchess") as HollowDuchess
	var presentation: DuchessEncounterPresentation = level.get_node_or_null(
		"GameplayWorld/BossArea/DuchessEncounterPresentation"
	) as DuchessEncounterPresentation
	var controller: HollowDuchessRoomController = level.get_node_or_null(
		"ChapterSystems/HollowDuchessRoomController"
	) as HollowDuchessRoomController
	_expect(boss != null and presentation != null and controller != null, "Boss music scene composition is incomplete")
	_expect(presentation.get_node_or_null("BrokenWaltzPlayer") == null, "Duplicate scene-local music player remains")
	_expect(manager.is_debug_overlay_enabled(), "Music debug entry did not show its overlay")
	if boss != null:
		await _wait_for_phase_two(boss, manager, 900)
	_expect(manager.get_current_track_id() == PHASE_02, "Phase 2 reveal did not select the Phase 2 score")
	_expect(manager.get_active_player_count() <= 2, "Crossfade created extra players")
	_expect(_phase_01_started == 1, "Phase 1 started %d times" % _phase_01_started)
	_expect(_phase_02_started == 1, "Phase 2 started %d times" % _phase_02_started)
	if controller != null:
		controller._on_player_respawned(Vector2.ZERO)
		await process_frame
		_expect(manager.get_current_track_id().is_empty(), "Retry did not stop Phase 2")
		_expect(controller.begin_encounter_from_entrance(), "Retry encounter did not restart")
		_expect(manager.get_current_track_id() == PHASE_01, "Retry did not restart from Phase 1")
		controller._on_boss_defeated()
		_expect(manager.get_current_track_id().is_empty(), "Boss defeat did not begin music fade-out")
	config.reset_to_defaults()
	if manager.track_started.is_connected(_on_track_started):
		manager.track_started.disconnect(_on_track_started)
	manager.set_debug_overlay_enabled(false)
	manager.stop_music()
	Engine.time_scale = 1.0
	if current_scene != null:
		current_scene.free()
		current_scene = null
	boss = null
	presentation = null
	controller = null
	level = null
	for _frame: int in range(10):
		await process_frame
	_finish()


func _wait_for_level(maximum_frames: int) -> Node:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL_PATH:
			return current_scene
	return null


func _wait_for_phase_two(boss: HollowDuchess, manager: MusicManagerService, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.get_phase() == 2 and manager.get_current_track_id() == PHASE_02:
			return
	_failures.append("Timed out waiting for Phase 2 music")


func _on_track_started(track_id: StringName) -> void:
	if track_id == PHASE_01:
		_phase_01_started += 1
	elif track_id == PHASE_02:
		_phase_02_started += 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("HOLLOW_DUCHESS_MUSIC_MU1_TEST: PASS main=Bootstrap p1=1 reveal=1 p2=1 overlay=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("HOLLOW_DUCHESS_MUSIC_MU1_TEST: %s" % failure)
	quit(1)
