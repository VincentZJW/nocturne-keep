extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
const OUTPUT_DIR: String = "res://docs/qa/gargoyle_duchess_gi/main_music"
const PHASE_01: StringName = &"CH2_BOSS_MUSIC_PHASE_01"
const PHASE_02: StringName = &"CH2_BOSS_MUSIC_PHASE_02"
const STINGER: StringName = &"CH2_BOSS_MUSIC_TRANSITION_STINGER"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	Engine.time_scale = 5.0
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	var manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	if config == null or manager == null:
		_fail("Required autoload is missing")
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = PHASE_01
	config.debug_skip_chapter_intro = true
	config.debug_reset_chapter_state_on_run = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("MainBootstrap could not start")
		return
	var level: Node = await _wait_for_level(480)
	if level == null:
		_fail("SilentCourt did not load through MainBootstrap")
		return
	var boss: HollowDuchess = level.get_node_or_null("GameplayWorld/BossArea/HollowDuchess") as HollowDuchess
	var controller: HollowDuchessRoomController = level.get_node_or_null("ChapterSystems/HollowDuchessRoomController") as HollowDuchessRoomController
	var player: Player = level.get_node_or_null("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player") as Player
	if boss == null or controller == null or player == null:
		_fail("Formal Boss composition is incomplete")
		return
	player.hurtbox.set_invulnerable(true)
	if not await _wait_for_track(manager, PHASE_01, 600):
		_fail("Phase 1 did not start")
		return
	await _focus(player, boss)
	await _save("01_phase_01_waltz_main.png")
	boss.debug_set_health(121)
	if not await _wait_for_stinger(manager, 600):
		_fail("Transition Stinger did not start")
		return
	await _focus(player, boss)
	await _save("02_transition_stinger_main.png")
	if not await _wait_for_track(manager, PHASE_02, 600):
		_fail("Phase 2 did not start")
		return
	await _focus(player, boss)
	await _save("03_phase_02_unmasked_main.png")

	controller._on_player_respawned(Vector2.ZERO)
	await process_frame
	if not controller.begin_encounter_from_entrance():
		_fail("Retry encounter did not restart")
		return
	if not await _wait_for_track(manager, PHASE_01, 360):
		_fail("Retry did not return to Phase 1")
		return
	await _save("04_retry_phase_01_main.png")
	controller._on_boss_defeated()
	manager._update_debug_overlay()
	await _save("05_death_fade_started_main.png")

	config.reset_to_defaults()
	manager.set_debug_overlay_enabled(false)
	manager.stop_music()
	Engine.time_scale = 1.0
	print("HOLLOW_DUCHESS_MUSIC_GI_CAPTURE: PASS captures=%d p1=96bpm p2=120bpm stinger=%s main=%s" % [
		_captures, STINGER, level.scene_file_path,
	])
	current_scene.queue_free()
	current_scene = null
	for _frame: int in range(24):
		await process_frame
	quit(0)


func _wait_for_level(maximum_frames: int) -> Node:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL_PATH:
			return current_scene
	return null


func _wait_for_track(manager: MusicManagerService, track_id: StringName, maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if manager.get_current_track_id() == track_id:
			return true
	return false


func _wait_for_stinger(manager: MusicManagerService, maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if manager.get_current_stinger_id() == STINGER:
			return true
	return false


func _focus(player: Player, boss: HollowDuchess) -> void:
	player.global_position = boss.global_position + Vector2(-170.0, -28.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	for _frame: int in range(10):
		await process_frame


func _save(file_name: String) -> void:
	var manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	if manager != null:
		manager._update_debug_overlay()
	await RenderingServer.frame_post_draw
	var path: String = "%s/%s" % [OUTPUT_DIR, file_name]
	if root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("Could not save %s" % path)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("HOLLOW_DUCHESS_MUSIC_GI_CAPTURE: %s" % message)
	quit(1)
