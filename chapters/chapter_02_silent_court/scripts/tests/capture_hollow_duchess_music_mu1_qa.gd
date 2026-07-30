extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
const OUTPUT_DIR: String = "res://docs/qa/boss_music/mu1"
const PHASE_01: StringName = &"CH2_BOSS_MUSIC_PHASE_01"
const PHASE_02: StringName = &"CH2_BOSS_MUSIC_PHASE_02"

var _failures: Array[String] = []
var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	Engine.time_scale = 6.0
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
		_fail("Could not start MainBootstrap")
		return
	var level: Node = await _wait_for_level(360)
	if level == null:
		_fail("SilentCourt did not load through MainBootstrap")
		return
	var boss: HollowDuchess = level.get_node_or_null("GameplayWorld/BossArea/HollowDuchess") as HollowDuchess
	var player: Player = level.get_node_or_null(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player"
	) as Player
	if boss == null or player == null:
		_fail("Boss or player is missing")
		return
	player.hurtbox.set_invulnerable(true)
	if not await _wait_for_state_and_track(boss, &"Idle", PHASE_01, manager, 720):
		_fail("Phase 1 score did not start through the F5 route")
		return
	await _focus(player, boss)
	await _save_viewport("01_ch2_phase_01_music_main.png")
	boss.debug_set_health(121)
	if not await _wait_for_state(boss, &"PhaseTransition", 240):
		_fail("Boss did not enter PhaseTransition")
		return
	await _focus(player, boss)
	await _save_viewport("02_ch2_music_transition_main.png")
	if not await _wait_for_track(manager, PHASE_02, 480):
		_fail("Phase 2 reveal did not switch music")
		return
	await _focus(player, boss)
	await _save_viewport("03_ch2_phase_02_music_main.png")
	config.reset_to_defaults()
	manager.set_debug_overlay_enabled(false)
	manager.stop_music()
	Engine.time_scale = 1.0
	print("HOLLOW_DUCHESS_MUSIC_MU1_CAPTURE: PASS captures=%d main=%s track=%s" % [
		_captures, level.scene_file_path, PHASE_02,
	])
	current_scene.queue_free()
	current_scene = null
	for _frame: int in range(6):
		await process_frame
	quit(0)


func _wait_for_level(maximum_frames: int) -> Node:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL_PATH:
			return current_scene
	return null


func _wait_for_state_and_track(
	boss: HollowDuchess,
	state: StringName,
	track_id: StringName,
	manager: MusicManagerService,
	maximum_frames: int
) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.get_state_name() == state and manager.get_current_track_id() == track_id:
			return true
	return false


func _wait_for_state(boss: HollowDuchess, state: StringName, maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.get_state_name() == state:
			return true
	return false


func _wait_for_track(manager: MusicManagerService, track_id: StringName, maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if manager.get_current_track_id() == track_id:
			return true
	return false


func _focus(player: Player, boss: HollowDuchess) -> void:
	player.global_position = boss.global_position + Vector2(-150.0, -28.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	for _frame: int in range(10):
		await process_frame


func _save_viewport(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var output: String = "%s/%s" % [OUTPUT_DIR, file_name]
	var image: Image = root.get_texture().get_image()
	var save_error: Error = image.save_png(ProjectSettings.globalize_path(output))
	if save_error != OK:
		_failures.append("Could not save %s" % output)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("HOLLOW_DUCHESS_MUSIC_MU1_CAPTURE: %s" % message)
	quit(1)
