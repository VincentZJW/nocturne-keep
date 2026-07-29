extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const OUTPUT: String = "res://docs/qa/chapter_03_edran_art_rework"

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
	debug.debug_start_spawn_id = &"CH3_BOSS_SUMMON_TEST"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("cannot launch MainBootstrap")
		return
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		_fail("formal Chapter III route did not load")
		return
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var room: Chapter03BossSanctumRoom
	for _index: int in range(720):
		await process_frame
		if controller.active_room_id == &"CH3_BOSS":
			room = controller.active_room as Chapter03BossSanctumRoom
			if room != null and room.boss.current_state != ThirteenthPontiffEdran.State.DORMANT:
				break
	if room == null or room.boss.current_state == ThirteenthPontiffEdran.State.DORMANT:
		_fail("formal Main Boss did not activate")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var player: Player = controller.player
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(1460.0, 584.0)
	player.velocity = Vector2.ZERO
	if player.player_camera != null:
		player.player_camera.reset_smoothing()
	await _frames(12)
	_save("01_edran_crozier_idle_main.png")

	if not room.boss.debug_force_attack(&"pontifical_sweep"):
		_fail("cannot force pontifical_sweep")
		return
	await create_timer(room.boss.config.sweep_windup + 0.04).timeout
	_save("02_edran_crozier_sweep_main.png")
	await create_timer(room.boss.config.sweep_active + room.boss.config.sweep_recovery + 0.12).timeout

	if not room.boss.debug_force_attack(&"crozier_thrust"):
		_fail("cannot force crozier_thrust")
		return
	await create_timer(room.boss.config.thrust_windup + 0.04).timeout
	_save("03_edran_crozier_thrust_main.png")
	await create_timer(room.boss.config.thrust_active + room.boss.config.thrust_recovery + 0.12).timeout

	if not room.boss.summon_director.summon_phase_1(player):
		_fail("cannot summon first production actor")
		return
	await create_timer(1.58).timeout
	var summons: Array[EdranBossSummon] = room.boss.summon_director.get_active_summons()
	var penitent: EdranBossSummon = _find_summon(summons, &"ossuary_penitent")
	var husk: EdranBossSummon = _find_summon(summons, &"choir_husk")
	if penitent != null:
		penitent.global_position = Vector2(1535.0, 584.0)
		penitent.sprite.play(&"idle")
		await _frames(3)
		_save("04_ossuary_penitent_idle_main.png")
		penitent.sprite.play(&"claw_active")
		await _frames(3)
		_save("05_ossuary_penitent_claw_main.png")
	else:
		_save("04_first_summon_idle_main.png")

	if not room.boss.summon_director.summon_phase_1(player):
		_fail("cannot summon second production actor")
		return
	await create_timer(1.58).timeout
	summons = room.boss.summon_director.get_active_summons()
	penitent = _find_summon(summons, &"ossuary_penitent")
	husk = _find_summon(summons, &"choir_husk")
	if penitent != null:
		penitent.global_position = Vector2(1388.0, 584.0)
		penitent.sprite.play(&"idle")
	if husk != null:
		husk.global_position = Vector2(1562.0, 570.0)
		husk.sprite.play(&"idle")
		await _frames(3)
		_save("06_choir_husk_idle_main.png")
		husk.sprite.play(&"shoot")
		await _frames(3)
		_save("07_choir_husk_cast_main.png")
	await _frames(3)
	_save("08_edran_mixed_summons_main.png")

	debug.reset_to_defaults()
	print("EDRAN_ART_REWORK_MAIN_QA | PASS captures=%d route=MainBootstrap boss=true summons=2" % _captures)
	quit(0)


func _find_summon(summons: Array[EdranBossSummon], kind: StringName) -> EdranBossSummon:
	for summon: EdranBossSummon in summons:
		if summon.config.actor_kind == kind:
			return summon
	return null


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
	push_error("EDRAN_ART_REWORK_MAIN_QA | %s" % message)
	quit(1)
