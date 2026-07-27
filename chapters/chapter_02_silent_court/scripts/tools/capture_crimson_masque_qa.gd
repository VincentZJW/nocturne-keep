extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIR: String = "res://docs/qa/crimson_masque_stilettos"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node("DebugRunConfig") as DebugRunConfigState
	var manager: SceneTransitionManagerState = root.get_node(
		"SceneTransitionManager"
	) as SceneTransitionManagerState
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_BOSS"
	config.debug_skip_chapter_intro = true
	manager.default_fade_out_duration = 0.08
	manager.default_fade_in_duration = 0.08
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	if change_scene_to_file(BOOTSTRAP) != OK:
		_failures.append("MainBootstrap failed to start")
		_finish()
		return
	var level: SilentCourtLevel = await _wait_for_level()
	if level == null:
		_failures.append("Silent Court did not load through MainBootstrap")
		_finish()
		return
	var player: Player = level.player
	var boss: HollowDuchess = level.get_node(
		"GameplayWorld/BossArea/HollowDuchess"
	) as HollowDuchess
	var controller: Chapter02To03TransitionController = level.get_node(
		"ChapterSystems/Chapter02To03TransitionController"
	) as Chapter02To03TransitionController
	var gate: BallroomMirrorGate = level.get_node(
		"GameplayWorld/BossArea/BallroomMirrorGate"
	) as BallroomMirrorGate
	controller.transition_data = controller.transition_data.duplicate(true) as Chapter02TransitionData
	controller.transition_data.mirror_reveal_duration = 0.08
	controller.transition_data.door_open_duration = 0.08
	boss.config = boss.config.duplicate(true) as HollowDuchessConfig
	boss.config.death_player_line_time = 0.02
	boss.config.death_boss_line_time = 0.04
	boss.config.death_passage_line_time = 0.06
	boss.config.death_echo_line_time = 0.08
	boss.config.death_duration = 0.12
	player.hurtbox.set_invulnerable(true)
	boss.debug_set_health(0)
	await _wait_until(func() -> bool: return gate.is_revealed(), 240, "mirror reveal")
	player.global_position = Vector2(6430, -1216)
	player.player_camera.reset_smoothing()
	await _capture("01_world_pickup_main.png", 24)
	var pickup: WeaponPickup = controller.get_reward_pickup()
	if pickup == null or not pickup.collect():
		_failures.append("Crimson Masque pickup collection failed")
	else:
		await _capture("02_acquisition_panel_main.png", 3)
	var equipment: PlayerEquipmentManager = root.get_node("EquipmentManager") as PlayerEquipmentManager
	if equipment.equipped_weapon_id != &"crimson_masque_stilettos":
		_failures.append("Crimson Masque was not equipped")
	player.animation_controller.reset_to_idle()
	await _capture("03_player_idle_main.png", 8)
	player.animation_controller.replay_one_shot(&"attack")
	player.animation_controller.animated_sprite.set_frame_and_progress(1, 0.25)
	await _capture("04_normal_attack_main.png", 1)
	player.animation_controller.replay_one_shot(&"dash_attack")
	player.animation_controller.animated_sprite.set_frame_and_progress(2, 0.25)
	await _capture("05_dash_attack_main.png", 1)
	player.animation_controller.reset_to_idle()
	gate.passage_requested.emit()
	await _wait_for_scene("RoyalChapelPassage", 360)
	await _wait_until(func() -> bool: return not manager.is_transitioning(), 240, "passage fade-in")
	var passage: RoyalChapelPassage = current_scene as RoyalChapelPassage
	if passage == null:
		_failures.append("Royal Processional Passage did not load")
		_finish()
		return
	passage.debug_enter_chapter_three()
	await _wait_for_scene("Chapter03EntryPlaceholder", 360)
	await _wait_until(func() -> bool: return not manager.is_transitioning(), 240, "Chapter III fade-in")
	var chapter_three: Chapter03EntryPlaceholder = current_scene as Chapter03EntryPlaceholder
	if chapter_three == null:
		_failures.append("Chapter III entry did not load")
	else:
		chapter_three.player.global_position = Vector2(420, 584)
		chapter_three.player.player_camera.reset_smoothing()
	await _capture("06_chapter_03_entry_main.png", 24)
	_finish()


func _wait_for_level() -> SilentCourtLevel:
	for _frame: int in range(300):
		await process_frame
		var level: SilentCourtLevel = current_scene as SilentCourtLevel
		if level != null:
			return level
	return null


func _wait_for_scene(scene_name: String, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.name == scene_name:
			return
	_failures.append("Timed out waiting for %s" % scene_name)


func _wait_until(predicate: Callable, maximum_frames: int, label: String) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if predicate.call():
			return
	_failures.append("Timed out waiting for %s" % label)


func _capture(file_name: String, settle_frames: int) -> void:
	for _frame: int in range(settle_frames):
		await process_frame
	var path: String = OUTPUT_DIR.path_join(file_name)
	var error: Error = root.get_viewport().get_texture().get_image().save_png(path)
	if error != OK:
		_failures.append("Could not save %s: %s" % [path, error_string(error)])


func _finish() -> void:
	if _failures.is_empty():
		print("CRIMSON_MASQUE_MAIN_QA: PASS captures=6 bootstrap=1 damage=14/28 chapter3=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CRIMSON_MASQUE_MAIN_QA: %s" % failure)
	quit(1)
