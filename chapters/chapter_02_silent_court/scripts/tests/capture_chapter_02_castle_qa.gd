extends SceneTree

## Captures the saved MainBootstrap Chapter II route after formal castle-art integration.

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
const OUTPUT_DIR: String = "res://docs/qa/chapter_02_castle_polish"

var _capture_count: int = 0
var _title_requested: bool = false


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
	var level: SilentCourtLevel = await _wait_for_level()
	if level == null:
		_fail("SilentCourt did not load through MainBootstrap")
		return
	var player: Player = level.get_node(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player"
	) as Player
	var floor_controller: Chapter02FloorTransitionController = level.get_node(
		"ChapterSystems/FloorTransitionController"
	) as Chapter02FloorTransitionController
	var first_transition: Chapter02FloorTransition = level.get_node(
		"TransitionAreas/Floor1ToFloor2"
	) as Chapter02FloorTransition
	var second_transition: Chapter02FloorTransition = level.get_node(
		"TransitionAreas/Floor2ToFloor3"
	) as Chapter02FloorTransition
	var threshold: DuchessBossThresholdTransition = level.get_node(
		"ChapterSystems/DuchessBossThresholdTransition"
	) as DuchessBossThresholdTransition
	var room_controller: HollowDuchessRoomController = level.get_node(
		"ChapterSystems/HollowDuchessRoomController"
	) as HollowDuchessRoomController
	var boss: HollowDuchess = level.get_node("GameplayWorld/BossArea/HollowDuchess") as HollowDuchess
	var intro_card: Control = level.get_node(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/HUD/DuchessIntroCard"
	) as Control
	var presentation: DuchessEncounterPresentation = level.get_node(
		"GameplayWorld/BossArea/DuchessEncounterPresentation"
	) as DuchessEncounterPresentation
	presentation.title_requested.connect(_on_title_requested)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	player.hurtbox.set_invulnerable(true)

	await _place_and_capture(level, player, Vector2(3500, 584), "01_old_armory_stilettos_main.png")
	await _place_and_capture(level, player, Vector2(4000, 584), "02_old_armory_armaments_main.png")
	await _place_and_capture(level, player, Vector2(4850, 584), "03_last_banquet_hall_main.png")
	await _place_and_capture(level, player, Vector2(5850, 584), "04_last_banquet_remnants_main.png")
	await _place_and_capture(level, player, Vector2(4400, -316), "05_royal_portrait_gallery_main.png")
	await _place_and_capture(level, player, Vector2(5900, -316), "06_royal_portrait_people_main.png")
	await _place_and_capture(level, player, Vector2(2300, -316), "07_blood_candle_chapel_main.png")
	await _place_and_capture(level, player, Vector2(3450, -316), "08_blood_candle_arches_main.png")
	await _place_and_capture(level, player, Vector2(1550, -1216), "09_ballroom_antechamber_main.png")
	# The same saved controller used by F5 performs both floor relocations under blackout.
	if not floor_controller.request_transition(first_transition):
		_fail("floor 1 transition did not start")
		return
	await _wait_floor_transition(floor_controller)
	await _settle_camera(player, 5)
	_save_viewport("10_floor_1_to_2_transition_main.png")
	if not floor_controller.request_transition(second_transition):
		_fail("floor 2 transition did not start")
		return
	await _wait_floor_transition(floor_controller)
	await _settle_camera(player, 5)
	_save_viewport("11_floor_2_to_3_transition_main.png")
	await _place_and_capture(level, player, Vector2(2580, -1216), "12_boss_threshold_door_main.png")

	if not threshold.request_entry():
		_fail("formal Boss threshold rejected QA entry")
		return
	await _wait_for_fade_alpha(level, 0.55)
	_save_viewport("13_boss_fade_out_main.png")
	await _wait_for_stage(threshold, &"blackout")
	_save_viewport("14_boss_blackout_main.png")
	await _wait_threshold_complete(threshold)
	await _wait_process_frames(3)
	_save_viewport("15_boss_room_arrival_main.png")
	await _wait_for_visible_dialogue(level)
	_save_viewport("16_boss_cold_open_dialogue_main.png")
	await _wait_for_title(intro_card, 9000)
	_save_viewport("17_boss_title_main.png")
	await _wait_for_boss_state(boss, &"Idle", 540)
	await _wait_process_frames(3)
	_save_viewport("18_boss_combat_start_main.png")
	boss.debug_set_health(0)
	await _wait_for_room_clear(room_controller, 6000)
	await _place_and_capture(level, player, Vector2(5550, -1216), "19_crimson_masque_reliquary_main.png")

	debug_config.reset_to_defaults()
	print(
		"CHAPTER_02_CASTLE_MAIN_QA: PASS captures=%d rooms=6 threshold=fade/relocate/dialogue/title/combat reliquary=1 transitions=2 main=%s"
		% [_capture_count, level.scene_file_path]
	)
	current_scene.queue_free()
	current_scene = null
	await _wait_process_frames(8)
	quit(0)


func _place_and_capture(
		level: SilentCourtLevel,
		player: Player,
		position: Vector2,
		file_name: String
	) -> void:
	player.global_position = position
	player.velocity = Vector2.ZERO
	level.configure_camera_for_world_y(position.y)
	await _settle_camera(player, 8)
	_save_viewport(file_name)


func _wait_for_level() -> SilentCourtLevel:
	for _frame: int in range(360):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL_PATH:
			return current_scene as SilentCourtLevel
	return null


func _wait_for_fade_alpha(level: SilentCourtLevel, minimum_alpha: float) -> void:
	var fade: ColorRect = level.get_node(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/HUD/FloorTransitionFade"
	) as ColorRect
	for _frame: int in range(90):
		await process_frame
		if fade.visible and fade.modulate.a >= minimum_alpha:
			return
	_fail("Boss fade-out alpha did not advance")


func _wait_for_stage(controller: DuchessBossThresholdTransition, stage: StringName) -> void:
	for _frame: int in range(90):
		await process_frame
		if controller.get_transition_stage() == stage:
			return
	_fail("Boss threshold did not reach %s" % stage)


func _wait_threshold_complete(controller: DuchessBossThresholdTransition) -> void:
	for _frame: int in range(120):
		await process_frame
		if not controller.is_transitioning():
			return
	_fail("Boss threshold transition timed out")


func _wait_for_visible_dialogue(level: SilentCourtLevel) -> void:
	var label: Label = level.get_node(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/HUD/DuchessDialogue"
	) as Label
	for _frame: int in range(180):
		await process_frame
		if label.visible and label.text.contains("七年了"):
			return
	_fail("First Boss dialogue did not appear")


func _wait_for_title(control: Control, timeout_msec: int) -> void:
	var deadline_msec: int = Time.get_ticks_msec() + timeout_msec
	while Time.get_ticks_msec() < deadline_msec:
		await process_frame
		if _title_requested and control.visible:
			return
	_fail("Boss title did not appear")


func _on_title_requested(_title: String, _subtitle: String) -> void:
	_title_requested = true


func _wait_for_boss_state(boss: HollowDuchess, state_name: StringName, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.get_state_name() == state_name:
			return
	_fail("Boss did not reach %s" % state_name)


func _wait_for_room_clear(controller: HollowDuchessRoomController, timeout_msec: int) -> void:
	var deadline_msec: int = Time.get_ticks_msec() + timeout_msec
	while Time.get_ticks_msec() < deadline_msec:
		await process_frame
		if controller.room_is_cleared:
			return
	_fail("Boss defeat did not reveal the reliquary")


func _wait_floor_transition(controller: Chapter02FloorTransitionController) -> void:
	for _frame: int in range(180):
		await process_frame
		if not controller.is_transitioning():
			return
	_fail("Floor transition timed out")


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
	push_error("CHAPTER_02_CASTLE_MAIN_QA: %s" % message)
	quit(1)
