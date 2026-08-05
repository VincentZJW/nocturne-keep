extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const OUTPUT: String = "res://docs/qa/chapter_04_q4_boss_flow"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var debug: DebugRunConfigState = root.get_node("DebugRunConfig") as DebugRunConfigState
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_AREA_13"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		return _fail("MainBootstrap failed")
	var level: Node = await _wait_for_level()
	if level == null:
		return _fail("Chapter IV did not load")
	var controller: Chapter04RoomTransitionController = level.get_node("RoomTransitionController") as Chapter04RoomTransitionController
	var player: Player = controller.player
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(1540, 592)
	await _settle(12)
	_save("01_main_soul_lock_gate_closed.png")

	if not controller._swap_room(&"CH4_AREA_14", &"EntryWest"):
		return _fail("unable to capture Boss room")
	await _settle(8)
	var room: Node = controller.active_room
	var boss: SoulGaolerOrmund = room.get_node("Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
	var flow: Chapter04BossRoomController = room.get_node("BossRoomController") as Chapter04BossRoomController
	player.global_position = Vector2(1180, 592)
	await _settle(4)
	_save("02_main_ormund_intro_dialogue.png")
	flow.skip_intro_for_qa()
	boss.global_position = Vector2(1510, 590)
	await _settle(6)
	_save("03_main_ormund_phase_01_hud.png")
	boss.set_target(player)
	boss.set_facing_direction(-1.0)
	boss._start_action(&"halberd_sweep")
	boss._begin_active()
	await _settle(3)
	_save("04_main_ormund_phase_01_attack.png")
	boss._on_attack_cancelled()
	boss.health_component.set_current_health(roundi(boss.health_component.max_health * 0.5))
	boss.complete_debug_phase_transition()
	await _settle(5)
	_save("05_main_ormund_phase_02.png")
	boss._start_action(&"chainstorm_cleave")
	boss._begin_active()
	await _settle(3)
	_save("06_main_ormund_phase_02_attack.png")
	boss.health_component.set_current_health(0)
	await create_timer(0.62).timeout
	_save("07_main_ormund_death_collapse.png")
	await create_timer(0.72).timeout
	_save("08_main_ormund_soul_release.png")
	await create_timer(1.6).timeout

	if not controller._swap_room(&"CH4_AREA_15", &"EntryWest"):
		return _fail("unable to capture reward room")
	await _settle(8)
	player.global_position = Vector2(900, 592)
	await _settle(6)
	_save("09_main_broken_chain_reliquary.png")
	var reward: Chapter04RewardController = controller.active_room.get_node("RewardController") as Chapter04RewardController
	reward.collect_for_qa()
	await _settle(4)
	_save("10_main_reliquary_collected_exit_unlocked.png")

	if not controller._swap_room(&"CH4_AREA_16", &"EntryWest"):
		return _fail("unable to capture memory hall")
	await _settle(8)
	player.global_position = Vector2(1080, 592)
	await _settle(6)
	_save("11_main_hall_of_drowned_memories.png")
	player.global_position = Vector2(1990, 592)
	await _settle(6)
	_save("12_main_chapter_five_memory_exit.png")

	var ch5: ChapterStartProfile = ChapterRegistry.get_chapter(ChapterRegistry.CHAPTER_05_NIGHT_REPEATED)
	root.get_node("ChapterSession").set_transition_target(ChapterRegistry.CHAPTER_05_NIGHT_REPEATED, &"CH5_START")
	if change_scene_to_file(ch5.main_scene_path) != OK:
		return _fail("unable to capture Chapter V placeholder")
	for _frame: int in 90:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ch5.main_scene_path:
			break
	await _settle(8)
	_save("13_main_chapter_five_placeholder_ch5_start.png")
	debug.reset_to_defaults()
	print("CH4 Q4/BOSS MAIN QA CAPTURE | PASS captures=%d output=%s" % [_captures, OUTPUT])
	quit(0)


func _wait_for_level() -> Node:
	for _frame: int in 600:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _settle(frames: int) -> void:
	for _frame: int in frames:
		await process_frame
	await create_timer(0.05).timeout
	await RenderingServer.frame_post_draw


func _save(file_name: String) -> void:
	var viewport_texture: ViewportTexture = root.get_viewport().get_texture()
	if viewport_texture == null:
		_fail("viewport texture unavailable for %s" % file_name)
		return
	var image: Image = viewport_texture.get_image()
	if image == null:
		_fail("viewport image unavailable for %s" % file_name)
		return
	var error: Error = image.save_png(ProjectSettings.globalize_path("%s/%s" % [OUTPUT, file_name]))
	if error != OK:
		_fail("unable to save %s" % file_name)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("CH4 Q4/BOSS MAIN QA CAPTURE: %s" % message)
	quit(1)
