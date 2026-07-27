extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIR: String = "res://docs/qa/chapter_02_floor_transitions"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_failures.append("missing DebugRunConfig")
		_finish()
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_FLOOR_1_BANQUET"
	config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_failures.append("failed to start MainBootstrap")
		_finish()
		return
	var level: SilentCourtLevel = await _wait_for_level()
	if level == null:
		_failures.append("Silent Court did not load")
		_finish()
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var player: Player = level.player
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(6540, 584)
	level.configure_camera_for_world_y(player.global_position.y)
	await _capture("01_floor_1_short_grand_stair.png")
	var controller: Chapter02FloorTransitionController = level.get_node(
		"ChapterSystems/FloorTransitionController"
	) as Chapter02FloorTransitionController
	var first: Chapter02FloorTransition = level.get_node(
		"TransitionAreas/Floor1ToFloor2"
	) as Chapter02FloorTransition
	controller.request_transition(first)
	await _wait_for_blackout(controller)
	await _capture("02_floor_transition_blackout.png", 1)
	await _wait_for_transition(controller)
	await _capture("03_floor_2_landing.png")
	player.global_position = Vector2(720, -316)
	player.velocity = Vector2.ZERO
	level.configure_camera_for_world_y(player.global_position.y)
	await _capture("04_floor_2_short_servant_stair.png")
	var second: Chapter02FloorTransition = level.get_node(
		"TransitionAreas/Floor2ToFloor3"
	) as Chapter02FloorTransition
	controller.request_transition(second)
	await _wait_for_transition(controller)
	await _capture("05_floor_3_landing.png")
	_finish()


func _wait_for_blackout(controller: Chapter02FloorTransitionController) -> void:
	for _frame: int in range(120):
		await process_frame
		if controller.fade_rect.visible and controller.fade_rect.modulate.a >= 0.98:
			return
	_failures.append("blackout did not become opaque")


func _wait_for_transition(controller: Chapter02FloorTransitionController) -> void:
	for _frame: int in range(180):
		await process_frame
		if not controller.is_transitioning():
			return
	_failures.append("floor transition timed out")


func _capture(file_name: String, settle_frames: int = 14) -> void:
	for _frame: int in range(settle_frames):
		await process_frame
	var path: String = "%s/%s" % [OUTPUT_DIR, file_name]
	var error: Error = root.get_viewport().get_texture().get_image().save_png(path)
	if error != OK:
		_failures.append("failed to save %s: %s" % [path, error_string(error)])


func _wait_for_level() -> SilentCourtLevel:
	for _frame: int in range(240):
		await process_frame
		var level: SilentCourtLevel = current_scene as SilentCourtLevel
		if level != null:
			return level
	return null


func _finish() -> void:
	if _failures.is_empty():
		print("CH2_FLOOR_TRANSITION_MAIN_QA: PASS captures=5 transitions=2")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH2_FLOOR_TRANSITION_MAIN_QA: %s" % failure)
	quit(1)
