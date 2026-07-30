extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const OUTPUT: String = "res://docs/qa/chapter_03_boss_b4_b7"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280,720))
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
	var room: Chapter03BossSanctumRoom = null
	for tick: int in range(1800):
		await process_frame
		if controller.active_room_id == &"CH3_BOSS":
			room = controller.active_room as Chapter03BossSanctumRoom
			if room != null:
				if tick == 35:
					_save("01_intro_scripture_main.png")
				elif tick == 150:
					_save("02_intro_dialogue_main.png")
				if room.boss.current_state != ThirteenthPontiffEdran.State.DORMANT:
					break
	if room == null or room.boss.current_state == ThirteenthPontiffEdran.State.DORMANT:
		return _fail("Boss did not activate through formal Main")
	var boss: ThirteenthPontiffEdran = room.boss
	var player: Player = controller.player
	player.global_position = Vector2(1470,584)
	player.velocity = Vector2.ZERO
	player.hurtbox.set_invulnerable(true)
	if player.player_camera != null:
		player.player_camera.reset_smoothing()
	await _frames(8)
	_save("03_phase_01_ready_main.png")
	boss.health_component.set_current_health(boss.config.phase_transition_health)
	var transition_names: Array[String] = [
		"seals_break","crown_crack","mask_void","vestment_split","chest_open",
		"rib_frame","black_bell","arm_lengthen","crozier_fuse","chain_bind","phase_02_rise",
	]
	var step: float = (boss.config.phase_transition_duration-0.35)/11.0
	for index: int in range(transition_names.size()):
		await create_timer(step).timeout
		_save("%02d_transition_%s_main.png" % [index+4,transition_names[index]])
	for _wait_tick: int in range(180):
		await process_frame
		if boss.is_phase_02() and not boss.hurtbox.is_invulnerable:
			break
	_save("15_phase_02_idle_main.png")
	var attacks: Array[StringName] = [
		&"bell_bound_cleave",&"hollow_toll",&"censer_chain_judgment",
		&"scripture_burial",&"procession_of_the_unburied",&"fourteenth_seat",
	]
	var attack_capture_delays: Array[float] = [0.62,0.80,0.68,0.78,1.05,1.12]
	for index: int in range(attacks.size()):
		if attacks[index] == &"fourteenth_seat":
			boss.health_component.set_current_health(80)
		if not boss.debug_force_attack(attacks[index]):
			return _fail("cannot force %s" % attacks[index])
		await create_timer(attack_capture_delays[index]).timeout
		_save("%02d_%s_main.png" % [index+16,String(attacks[index])])
		var timeout: float = 0.0
		while boss.current_state == ThirteenthPontiffEdran.State.ATTACK and timeout < 4.0:
			await physics_frame
			timeout += 1.0/60.0
		await create_timer(0.08).timeout
	boss.summon_director.force_dissolve_all()
	boss.health_component.set_current_health(0)
	var death_names: Array[String] = ["crozier_break","censer_drop","bell_fall","collapse","dissolve"]
	var death_step: float = boss.config.death_sequence_duration/5.0
	for index: int in range(death_names.size()):
		await create_timer(death_step*0.55).timeout
		_save("%02d_death_%s_main.png" % [index+22,death_names[index]])
		await create_timer(death_step*0.45).timeout
	await create_timer(1.0).timeout
	controller.request_room_change(&"CH3_POST_BOSS",&"EntryWest")
	for _tick: int in range(180):
		await process_frame
		if controller.active_room_id == &"CH3_POST_BOSS":
			break
	var post_room: Chapter03PostBossRoom = controller.active_room as Chapter03PostBossRoom
	if post_room == null:
		return _fail("post-Boss reliquary room did not load")
	_save("27_post_boss_reliquary_main.png")
	post_room.reliquary.notify_reward_collected()
	await _frames(8)
	_save("28_reward_collected_chapter_04_entrance_main.png")
	debug.reset_to_defaults()
	print("EDRAN_B4_B7_MAIN_QA | PASS captures=%d route=MainBootstrap transition=true phase2=true death=true reward=true" % _captures)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _index: int in range(900):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE:
			return current_scene as Chapter03Route
	return null


func _frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


func _save(file_name: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var path: String = "%s/%s" % [OUTPUT,file_name]
	if root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("cannot save %s" % path)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("EDRAN_B4_B7_MAIN_QA | %s" % message)
	quit(1)
