extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const OUTPUT: String = "res://docs/qa/chapter_04_soul_lock_twin_keys"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var debug: DebugRunConfigState = root.get_node("DebugRunConfig") as DebugRunConfigState
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_AREA_15"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		return _fail("MainBootstrap failed")
	var level: Node = await _wait_for_level()
	if level == null:
		return _fail("Chapter IV did not load")
	var session: ChapterSessionState = root.get_node("ChapterSession") as ChapterSessionState
	session.set_story_flag(&"ch4_boss_defeated", true)
	session.set_story_flag(&"ch4_reward_unlocked", true)
	var controller: Chapter04RoomTransitionController = level.get_node(
		"RoomTransitionController"
	) as Chapter04RoomTransitionController
	if not controller._swap_room(&"CH4_AREA_15", &"EntryWest"):
		return _fail("Area 15 reload failed")
	await _settle(8)
	var player: Player = controller.player
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(890, 592)
	var reward: Chapter04RewardController = controller.active_room.get_node(
		"RewardController"
	) as Chapter04RewardController
	_save("01_water_settle.png")
	for stage_data: Array in [
		[&"soul_release", "02_soul_release.png", 2.0],
		[&"chain_pull", "03_chain_pull.png", 2.0],
		[&"reliquary_rise", "04_reliquary_rise.png", 2.0],
		[&"lockbreaker_forms", "05_lockbreaker_forms.png", 2.0],
		[&"soulseal_forms", "06_soulseal_forms.png", 2.0],
		[&"claimable", "07_claimable.png", 3.0],
	]:
		if not await _wait_for_stage(reward, stage_data[0] as StringName, stage_data[2] as float):
			return
		_save(stage_data[1] as String)
	if not reward.collect_for_qa():
		return _fail("reward collection failed")
	await _settle(4)
	_save("08_obtained_and_equipped.png")
	player.animation_controller.play_one_shot(&"attack_1")
	await _settle(2)
	_save("09_equipped_attack.png")
	var equipment: PlayerEquipmentManager = root.get_node("EquipmentManager") as PlayerEquipmentManager
	if (
		equipment.equipped_weapon_id != &"soul_lock_twin_keys"
		or equipment.get_normal_attack_damage() != 16
		or equipment.get_dash_attack_damage() != 32
	):
		return _fail("runtime equipment contract mismatch")
	debug.reset_to_defaults()
	print("SOUL LOCK MAIN QA CAPTURE | PASS captures=%d output=%s" % [_captures, OUTPUT])
	quit(0)


func _wait_for_level() -> Node:
	for _frame: int in 600:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _wait_for_stage(
	reward: Chapter04RewardController, stage: StringName, timeout_seconds: float
) -> bool:
	var deadline: int = Time.get_ticks_msec() + roundi(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if reward.get_current_stage() == stage:
			await RenderingServer.frame_post_draw
			return true
	_fail("reward stage timed out: %s" % stage)
	return false


func _settle(frames: int) -> void:
	for _frame: int in frames:
		await process_frame
	await RenderingServer.frame_post_draw


func _save(file_name: String) -> void:
	var viewport_texture: ViewportTexture = root.get_viewport().get_texture()
	var image: Image = viewport_texture.get_image() if viewport_texture != null else null
	if image == null:
		_fail("viewport image unavailable for %s" % file_name)
		return
	var error: Error = image.save_png(ProjectSettings.globalize_path("%s/%s" % [OUTPUT, file_name]))
	if error != OK:
		_fail("unable to save %s" % file_name)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("SOUL LOCK MAIN QA CAPTURE: %s" % message)
	quit(1)
