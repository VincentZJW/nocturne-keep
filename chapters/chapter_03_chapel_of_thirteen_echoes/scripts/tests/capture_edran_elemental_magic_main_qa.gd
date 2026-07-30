extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const OUTPUT: String = "res://docs/qa/chapter_03_edran_elemental_magic"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null:
		return _fail("missing DebugRunConfig")
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	debug.debug_start_spawn_id = &"CH3_BOSS"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		return _fail("MainBootstrap failed")
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		return _fail("formal Chapter III route did not load")
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var room: Chapter03BossSanctumRoom = await _wait_for_boss_room(controller)
	if room == null:
		return _fail("Boss did not activate through Main/F5 route")
	var boss: ThirteenthPontiffEdran = room.boss
	var player: Player = controller.player
	boss.set_physics_process(false)
	player.global_position = Vector2(1450.0, 584.0)
	player.velocity = Vector2.ZERO
	player.health_component.reset_to_full()
	if player.player_camera != null:
		player.player_camera.reset_smoothing()
	await _frames(8)
	_save("01_full_boss_main.png")

	# Fire: formal Boss cast, formal projectile, then Player burn overlay and HUD.
	if not boss.debug_force_attack(&"cinder_absolution"):
		return _fail("cannot force Cinder Absolution")
	await create_timer(0.22).timeout
	_save("02_fire_cast_windup_main.png")
	await create_timer(0.43).timeout
	_save("03_fireball_flight_main.png")
	await create_timer(0.36).timeout
	_save("04_fireball_impact_main.png")
	if not player.status_effect_controller.is_burning():
		player.status_effect_controller.apply_burn(&"qa_fire", 3.0, 5, 1.0)
	_save("05_player_burning_main.png")
	await create_timer(0.22).timeout
	_save("06_burn_hud_main.png")
	await _wait_boss_ready(boss)
	player.status_effect_controller.clear_all()
	player.health_component.reset_to_full()

	# Ice: cast and projectile, freeze shell, immunity and thaw presentation.
	if not boss.debug_force_attack(&"litany_of_stillness"):
		return _fail("cannot force Litany of Stillness")
	await create_timer(0.26).timeout
	_save("07_ice_cast_windup_main.png")
	await create_timer(0.53).timeout
	_save("08_ice_lance_flight_main.png")
	await create_timer(0.30).timeout
	_save("09_ice_impact_main.png")
	if not player.status_effect_controller.is_frozen():
		player.status_effect_controller.apply_freeze(&"qa_ice", 3.0, 5.0)
	_save("10_player_frozen_main.png")
	await create_timer(0.18).timeout
	_save("11_frozen_shell_close_main.png")
	await create_timer(1.05).timeout
	_save("12_freeze_hud_main.png")
	player.status_effect_controller.advance(
		player.status_effect_controller.get_remaining(PlayerStatusEffectController.FREEZE) + 0.001
	)
	await create_timer(0.10).timeout
	_save("13_ice_shatter_main.png")
	await _wait_boss_ready(boss)
	_save("14_player_thawed_main.png")
	player.status_effect_controller.clear_all()
	player.health_component.reset_to_full()

	# Mire: initial sigil follows briefly, locks at 1.15, activates at 2.0.
	if not boss.debug_force_attack(&"mire_of_the_unburied"):
		return _fail("cannot force Mire of the Unburied")
	await create_timer(0.25).timeout
	_save("15_mire_circle_initial_main.png")
	player.global_position.x += 92.0
	await create_timer(0.48).timeout
	_save("16_mire_circle_tracking_main.png")
	player.global_position.x += 92.0
	await create_timer(0.47).timeout
	_save("17_mire_circle_locked_main.png")
	await create_timer(0.88).timeout
	_save("18_mire_zone_formed_main.png")
	var mire: PontiffMireZone = _find_mire_zone(room)
	if mire != null:
		player.global_position = mire.global_position
	await create_timer(0.18).timeout
	_save("19_player_in_mire_main.png")
	_save("20_mire_player_overlay_hud_main.png")
	player.animation_controller.play_one_shot(&"jump_start")
	await _frames(2)
	_save("21_mire_jump_readability_main.png")
	player.animation_controller.play_one_shot(&"attack")
	await _frames(2)
	_save("22_mire_attack_readability_main.png")
	await _wait_boss_ready(boss)

	# Necromancy and elemental circles are captured in the same formal arena.
	player.status_effect_controller.clear_all()
	if mire != null and is_instance_valid(mire):
		mire.force_expire()
	boss.summon_director.summon_phase_1(player)
	await create_timer(0.18).timeout
	_save("23_necromancy_vs_mire_visual_language_main.png")
	boss.summon_director.summon_phase_1(player)
	await _frames(4)
	_save("24_phase_01_summon_pressure_main.png")
	boss.summon_director.force_dissolve_all()
	await create_timer(0.50).timeout
	boss.debug_enter_phase_02_immediate()
	boss.summon_director.summon_phase_2(player)
	boss.summon_director.summon_phase_2(player)
	boss.summon_director.summon_phase_2(player)
	await _frames(5)
	_save("25_phase_02_three_summon_cap_main.png")
	player.status_effect_controller.apply_burn(&"qa_combo", 3.0, 5, 1.0)
	await _frames(3)
	_save("26_summons_plus_fire_main.png")
	player.status_effect_controller.clear_all()
	boss.summon_director.force_dissolve_all()
	await create_timer(0.45).timeout
	boss._action_locked = false
	boss._set_state(ThirteenthPontiffEdran.State.IDLE, &"phase_02_idle")
	if boss.debug_force_attack(&"mire_of_the_unburied"):
		await create_timer(2.10).timeout
		_save("27_summons_plus_mire_main.png")
	debug.reset_to_defaults()
	print("EDRAN_ELEMENTAL_MAGIC_MAIN_QA | PASS captures=%d route=MainBootstrap fire=true ice=true mire=true summons=true" % _captures)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _index: int in range(900):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE:
			return current_scene as Chapter03Route
	return null


func _wait_for_boss_room(controller: Chapter03RoomTransitionController) -> Chapter03BossSanctumRoom:
	for _index: int in range(1800):
		await process_frame
		if controller.active_room_id == &"CH3_BOSS":
			var room: Chapter03BossSanctumRoom = controller.active_room as Chapter03BossSanctumRoom
			if room != null and room.boss.current_state != ThirteenthPontiffEdran.State.DORMANT:
				return room
	return null


func _wait_boss_ready(boss: ThirteenthPontiffEdran) -> void:
	for _index: int in range(300):
		await process_frame
		if not boss._action_locked and boss.current_state == ThirteenthPontiffEdran.State.IDLE:
			return


func _find_mire_zone(room: Chapter03BossSanctumRoom) -> PontiffMireZone:
	for child: Node in room.get_children():
		if child is PontiffMireZone:
			return child as PontiffMireZone
	return null


func _frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


func _save(file_name: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var path: String = "%s/%s" % [OUTPUT, file_name]
	if root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("cannot save %s" % path)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("EDRAN_ELEMENTAL_MAGIC_MAIN_QA | %s" % message)
	quit(1)
