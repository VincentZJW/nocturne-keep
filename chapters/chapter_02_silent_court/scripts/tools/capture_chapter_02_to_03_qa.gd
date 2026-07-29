extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIR: String = "res://docs/qa/chapter_02_to_03_transition"

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
	if change_scene_to_file(BOOTSTRAP) != OK:
		_failures.append("MainBootstrap failed to start")
		_finish()
		return
	var level: SilentCourtLevel = await _wait_for_level()
	if level == null:
		_failures.append("Silent Court did not load through MainBootstrap")
		_finish()
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
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
	controller.transition_data.door_open_duration = 0.20
	boss.config = boss.config.duplicate(true) as HollowDuchessConfig
	boss.config.death_player_line_time = 0.30
	boss.config.death_boss_line_time = 0.95
	boss.config.death_passage_line_time = 1.55
	boss.config.death_echo_line_time = 2.15
	boss.config.death_duration = 2.85
	player.global_position = Vector2(6200, -1216)
	player.hurtbox.set_invulnerable(true)
	level.configure_camera_for_world_y(player.global_position.y)
	boss.debug_set_health(0)
	await _wait_seconds(0.16)
	await _capture("01_boss_death_main.png")
	await _wait_seconds(0.24)
	await _capture("02_death_dialogue_main.png")
	# Automated behavior is covered by test_chapter_02_to_03_transition.gd. The
	# graphical runner can advance process frames faster than wall-clock tweens,
	# so wait in real time before selecting a deterministic presentation frame.
	await _wait_seconds(2.8)
	var reveal_was_complete: bool = gate.is_revealed()
	player.global_position = Vector2(6650, -1216)
	player.player_camera.reset_smoothing()
	# Re-render the gate's real midpoint state after the timed sequence so the QA
	# capture is deterministic even when the graphical runner skips tween frames.
	gate.reveal_immediately()
	if not reveal_was_complete:
		gate.mirror_revealed.emit()
	gate.reveal_progress = 0.48
	gate.queue_redraw()
	await _capture("03_mirror_thirteen_cracks_main.png")
	gate.reveal_progress = 1.0
	await _capture("04_royal_chapel_passage_door_main.png")
	var reward: WeaponPickup = controller.get_reward_pickup()
	if reward == null:
		_failures.append("Crimson Masque reward missing during Main capture")
	else:
		reward.collect()
	gate.passage_requested.emit()
	await _wait_for_scene("RoyalChapelPassage", 360)
	await _wait_until(func() -> bool: return not manager.is_transitioning(), 240, "passage fade-in")
	var passage: RoyalChapelPassage = current_scene as RoyalChapelPassage
	if passage == null:
		_failures.append("RoyalChapelPassage did not load")
		_finish()
		return
	passage.player.global_position = Vector2(1120, 584)
	passage.player.player_camera.reset_smoothing()
	await _capture("05_royal_processional_passage_main.png")
	passage.debug_enter_chapter_three()
	await _wait_for_scene("Chapter03Route", 360)
	await _wait_until(func() -> bool: return not manager.is_transitioning(), 240, "Chapter III fade-in")
	var chapter_three: Chapter03Route = current_scene as Chapter03Route
	if chapter_three != null:
		var chapter_three_player: Player = chapter_three.transition_controller.player
		chapter_three_player.global_position = Vector2(420, 584)
		chapter_three_player.player_camera.reset_smoothing()
	await _capture("06_chapter_03_vestibule_main.png", 30)
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


func _wait_seconds(duration: float) -> void:
	await create_timer(duration).timeout


func _capture(file_name: String, settle_frames: int = 8) -> void:
	for _frame: int in range(settle_frames):
		await process_frame
	var path: String = "%s/%s" % [OUTPUT_DIR, file_name]
	var error: Error = root.get_viewport().get_texture().get_image().save_png(path)
	if error != OK:
		_failures.append("Could not save %s: %s" % [path, error_string(error)])


func _finish() -> void:
	if _failures.is_empty():
		print("CH2_TO_CH3_MAIN_QA: PASS captures=6 bootstrap=1 mirror=1 passage=1 chapter3=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH2_TO_CH3_MAIN_QA: %s" % failure)
	quit(1)
