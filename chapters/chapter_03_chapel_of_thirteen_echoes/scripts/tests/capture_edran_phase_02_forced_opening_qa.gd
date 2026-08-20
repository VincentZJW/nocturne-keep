extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const OUTPUT: String = "res://docs/qa/chapter_03_weight_of_absolution_art_rework"

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
	# Keep caster and target in one Main/F5-equivalent camera composition so the
	# evidence proves both halves of the ritual presentation.
	boss.global_position = player.global_position + Vector2(300.0, 0.0)
	boss.velocity = Vector2.ZERO
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
	boss.global_position = player.global_position + Vector2(300.0, 0.0)
	boss.velocity = Vector2.ZERO
	await _wait_seconds(0.78)
	await _capture("02_weight_cast_ritual.png")
	if not await _wait_until(func() -> bool: return boss.current_state == ThirteenthPontiffEdran.State.GRAVITY_FINAL_SEAL, 360):
		_fail("Final Seal did not start")
		return
	await _wait_seconds(0.12)
	await _capture("03_thirteenth_bell_and_judgment_seal.png")
	if not await _wait_until(func() -> bool: return boss.current_state == ThirteenthPontiffEdran.State.GRAVITY_SPELL_RECOVERY, 360):
		_fail("gravity recovery did not start")
		return
	if player.health_component.current_health != 50:
		_fail("formal HP settlement was %d instead of 50" % player.health_component.current_health)
		return
	await _wait_frames(3)
	await _capture("04_final_judgment_hp_50.png")
	if not await _wait_until(func() -> bool: return boss.is_phase_02_normal_ai_enabled(), 600):
		_fail("normal Phase 2 AI did not begin after recovery")
		return
	await _capture("05_phase_02_recovery_complete.png")
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


func _wait_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await process_frame


func _wait_seconds(duration: float) -> void:
	await create_timer(duration).timeout


func _capture(file_name: String) -> void:
	# Main-loop QA scripts can run with the headless display driver, where
	# RenderingServer.frame_post_draw is not guaranteed to be emitted.
	for _frame: int in range(3):
		await process_frame
	RenderingServer.force_draw(false)
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
