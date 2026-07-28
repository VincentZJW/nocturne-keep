extends SceneTree

## MainBootstrap-only evidence for Chapter II Stage A. Every capture comes from
## the same saved scene and nodes that F5 instantiates.

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
const OUTPUT_DIR: String = "res://docs/qa/chapter_02_stage_a"

var _capture_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var debug_config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug_config == null:
		_fail("missing DebugRunConfig")
		return
	debug_config.debug_chapter_start_enabled = true
	debug_config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	debug_config.debug_start_spawn_id = &"CH2_START"
	debug_config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP_PATH) != OK:
		_fail("could not start MainBootstrap")
		return
	var level: Node = await _wait_for_level()
	if level == null:
		_fail("SilentCourt did not load through MainBootstrap")
		return
	var player: Player = level.get_node_or_null(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player"
	) as Player
	var floor_controller: Chapter02FloorTransitionController = level.get_node_or_null(
		"ChapterSystems/FloorTransitionController"
	) as Chapter02FloorTransitionController
	var first_transition: Chapter02FloorTransition = level.get_node_or_null(
		"TransitionAreas/Floor1ToFloor2"
	) as Chapter02FloorTransition
	var second_transition: Chapter02FloorTransition = level.get_node_or_null(
		"TransitionAreas/Floor2ToFloor3"
	) as Chapter02FloorTransition
	var reward_controller: Chapter02To03TransitionController = level.get_node_or_null(
		"ChapterSystems/Chapter02To03TransitionController"
	) as Chapter02To03TransitionController
	var reliquary: DuchessReliquary = level.get_node_or_null(
		"GameplayWorld/BossArea/DuchessReliquary"
	) as DuchessReliquary
	if (
		player == null or floor_controller == null or first_transition == null
		or second_transition == null or reward_controller == null or reliquary == null
	):
		_fail("Stage A Main composition is incomplete")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	player.hurtbox.set_invulnerable(true)
	await _settle_camera(player, 6)
	_save_viewport("01_floor_1_main.png")
	if not floor_controller.request_transition(first_transition):
		_fail("Floor 1 transition did not start")
		return
	await _wait_floor_transition(floor_controller)
	await _settle_camera(player, 6)
	_save_viewport("02_floor_1_to_2_landing_main.png")
	if not floor_controller.request_transition(second_transition):
		_fail("Floor 2 transition did not start")
		return
	await _wait_floor_transition(floor_controller)
	await _settle_camera(player, 6)
	_save_viewport("03_floor_2_to_3_landing_main.png")
	player.global_position = Vector2(2520.0, -1216.0)
	player.velocity = Vector2.ZERO
	await _settle_camera(player, 8)
	_save_viewport("04_boss_entrance_fixed_main.png")
	player.global_position = Vector2(3100.0, -1216.0)
	player.velocity = Vector2.ZERO
	await _settle_camera(player, 8)
	_save_viewport("05_player_in_front_of_boss_door_main.png")
	reward_controller.debug_complete_boss_sequence()
	await _wait_for_reward(reward_controller)
	await _wait_process_frames(90)
	player.global_position = Vector2(5550.0, -1216.0)
	player.velocity = Vector2.ZERO
	await _settle_camera(player, 8)
	_save_viewport("06_player_in_front_of_reliquary_main.png")
	reliquary.interaction_area.body_entered.emit(player)
	await _wait_process_frames(3)
	if not reliquary.prompt.visible:
		_fail("Reliquary proximity prompt did not appear")
		return
	_save_viewport("07_reliquary_prompt_close_main.png")
	var first_flame_frame: int = reliquary.candle_flames.get_frame_index()
	_save_viewport("08_candle_flame_frame_a_main.png")
	await _wait_for_different_flame_frame(reliquary.candle_flames, first_flame_frame)
	_save_viewport("09_candle_flame_frame_b_main.png")
	var interact_event: InputEventAction = InputEventAction.new()
	interact_event.action = &"interact"
	interact_event.pressed = true
	reliquary._unhandled_input(interact_event)
	await _wait_process_frames(4)
	if not reliquary.is_collected or reliquary.weapon_display.visible or reliquary.prompt.visible:
		_fail("Reliquary did not clear after E interaction")
		return
	_save_viewport("10_reliquary_collected_main.png")
	debug_config.reset_to_defaults()
	print(
		"CH2_STAGE_A_MAIN_QA: PASS captures=%d layers=1 transitions=2 proximity=112 candle_frames=2 collected=1 main=%s"
		% [_capture_count, level.scene_file_path]
	)
	current_scene.queue_free()
	current_scene = null
	await _wait_process_frames(8)
	quit(0)


func _wait_for_level() -> Node:
	for _frame: int in range(360):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL_PATH:
			return current_scene
	return null


func _wait_floor_transition(controller: Chapter02FloorTransitionController) -> void:
	for _frame: int in range(180):
		await process_frame
		if not controller.is_transitioning():
			return
	_fail("Floor transition timed out")


func _wait_for_reward(controller: Chapter02To03TransitionController) -> void:
	for _frame: int in range(180):
		await process_frame
		if controller.get_reward_pickup() != null:
			return
	_fail("Reliquary reward did not appear")


func _wait_for_different_flame_frame(flames: ReliquaryCandleFlames, previous: int) -> void:
	for _frame: int in range(60):
		await process_frame
		if flames.get_frame_index() != previous:
			return
	_fail("Candle flame animation did not advance")


func _settle_camera(player: Player, frames: int) -> void:
	if player.player_camera != null:
		player.player_camera.reset_smoothing()
	await _wait_process_frames(frames)


func _wait_process_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _save_viewport(file_name: String) -> void:
	var output_path: String = "%s/%s" % [OUTPUT_DIR, file_name]
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(output_path))
	if error != OK:
		_fail("failed to save %s: %s" % [output_path, error_string(error)])
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("CH2_STAGE_A_MAIN_QA: %s" % message)
	quit(1)
