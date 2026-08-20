extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const OUTPUT: String = "res://docs/qa/chapter_03_edran_phase_02_forced_opening"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null:
		_fail("missing DebugRunConfig")
		return
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	debug.debug_start_spawn_id = &"CH3_BOSS"
	debug.debug_skip_chapter_intro = true
	debug.debug_reset_chapter_state_on_run = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("MainBootstrap failed")
		return
	var route: Chapter03Route = await _wait_for_route(900)
	if route == null:
		_fail("formal Chapter III route did not load")
		return
	var room: Chapter03BossSanctumRoom = await _wait_for_room(route, 900)
	if room == null:
		_fail("formal Boss room did not load")
		return
	var boss: ThirteenthPontiffEdran = room.boss
	var player: Player = route.transition_controller.player
	for _frame: int in range(1800):
		await process_frame
		if boss.current_state != ThirteenthPontiffEdran.State.DORMANT:
			break
	if boss.current_state == ThirteenthPontiffEdran.State.DORMANT:
		_fail("Edran did not complete the formal intro and activate")
		return
	player.hurtbox.set_invulnerable(true)
	player.health_component.set_current_health(60)
	boss.health_component.set_current_health(boss.config.phase_transition_health)
	if not await _wait_until(func() -> bool: return room.sanctum.dialogue_panel.visible, 900):
		_fail("Phase 2 dialogue did not become visible")
		return
	await _capture("01_phase_02_dialogue_hp_60.png")
	if not await _wait_until(func() -> bool: return boss.current_state == ThirteenthPontiffEdran.State.GRAVITY_SPELL_WINDUP, 1200):
		_fail("forced gravity windup did not start")
		return
	await _capture("02_forced_gravity_windup.png")
	if not await _wait_until(func() -> bool: return boss.current_state == ThirteenthPontiffEdran.State.GRAVITY_FINAL_SEAL, 360):
		_fail("Final Seal did not start")
		return
	await _capture("03_gravity_final_seal_hp_60.png")
	if not await _wait_until(func() -> bool: return boss.current_state == ThirteenthPontiffEdran.State.GRAVITY_SPELL_RECOVERY, 360):
		_fail("gravity recovery did not start")
		return
	if player.health_component.current_health != 50:
		_fail("formal HP settlement was %d instead of 50" % player.health_component.current_health)
		return
	await _capture("04_gravity_resolved_hp_50.png")
	if not await _wait_until(func() -> bool: return boss.is_phase_02_normal_ai_enabled(), 600):
		_fail("normal Phase 2 AI did not begin after recovery")
		return
	await _capture("05_phase_02_normal_ai_after_gravity.png")
	debug.reset_to_defaults()
	var music_manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	if music_manager != null:
		music_manager.stop_music()
	if current_scene != null:
		current_scene.free()
		current_scene = null
	for _frame: int in range(10):
		await process_frame
	print("EDRAN_PHASE2_FORCED_OPENING_QA | PASS captures=%d route=MainBootstrap hp=60to50 dialogue_clear=true normal_ai_gated=true" % _captures)
	quit(0)


func _wait_for_route(maximum_frames: int) -> Chapter03Route:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE:
			return current_scene as Chapter03Route
	return null


func _wait_for_room(
	route: Chapter03Route, maximum_frames: int
) -> Chapter03BossSanctumRoom:
	for _frame: int in range(maximum_frames):
		await process_frame
		var room: Chapter03BossSanctumRoom = (
			route.transition_controller.active_room as Chapter03BossSanctumRoom
		)
		if room != null:
			return room
	return null


func _wait_until(predicate: Callable, maximum_frames: int) -> bool:
	for _frame: int in range(maximum_frames):
		await process_frame
		if bool(predicate.call()):
			return true
	return false


func _capture(file_name: String) -> void:
	for _frame: int in range(2):
		await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var path: String = "%s/%s" % [OUTPUT, file_name]
	var error: Error = root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_fail("cannot save %s: %s" % [path, error_string(error)])
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("EDRAN_PHASE2_FORCED_OPENING_QA | %s" % message)
	quit(1)
