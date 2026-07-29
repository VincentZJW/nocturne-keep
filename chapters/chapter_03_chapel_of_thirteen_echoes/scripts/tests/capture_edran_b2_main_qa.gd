extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const OUTPUT: String = "res://docs/qa/chapter_03_boss_b2"

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
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("cannot launch MainBootstrap")
		return
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		_fail("formal Chapter III route did not load")
		return
	var controller: Chapter03RoomTransitionController = route.transition_controller
	for _index: int in range(600):
		await process_frame
		if controller.active_room_id == &"CH3_BOSS":
			var candidate: Chapter03BossSanctumRoom = controller.active_room as Chapter03BossSanctumRoom
			if candidate != null and candidate.boss.current_state != ThirteenthPontiffEdran.State.DORMANT:
				break
	var room: Chapter03BossSanctumRoom = controller.active_room as Chapter03BossSanctumRoom
	if room == null or room.boss.current_state == ThirteenthPontiffEdran.State.DORMANT:
		_fail("saved Main Boss did not activate")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var player: Player = controller.player
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(1480.0, 584.0)
	player.velocity = Vector2.ZERO
	if player.player_camera != null:
		player.player_camera.reset_smoothing()
	await _frames(12)
	_save("01_edran_phase_01_idle_main.png")
	if not room.boss.debug_force_attack(&"pontifical_sweep"):
		_fail("cannot force pontifical sweep")
		return
	await create_timer(room.boss.config.sweep_windup + 0.035).timeout
	_save("02_edran_pontifical_sweep_active_main.png")
	await create_timer(room.boss.config.sweep_active + room.boss.config.sweep_recovery + 0.08).timeout
	room.boss.health_component.set_current_health(room.boss.config.phase_transition_health)
	await _frames(8)
	_save("03_edran_b4_boundary_main.png")
	debug.reset_to_defaults()
	print("EDRAN_B2_MAIN_QA | PASS captures=%d route=MainBootstrap boss=Phase1 transition=B4_pending" % _captures)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _index: int in range(720):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE:
			return current_scene as Chapter03Route
	return null


func _frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


func _save(file_name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var path: String = "%s/%s" % [OUTPUT, file_name]
	if image.save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("cannot save %s" % path)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("EDRAN_B2_MAIN_QA | %s" % message)
	quit(1)
