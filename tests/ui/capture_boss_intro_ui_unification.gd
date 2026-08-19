extends SceneTree

## Captures the saved MainBootstrap route for the Chapter II-IV Boss UI
## comparison. Run once per chapter with `-- ch2`, `-- ch3`, or `-- ch4`.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIR: String = "res://docs/qa/boss_intro_ui_unification"
const CH2_LEVEL: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
const CH3_ROUTE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const CH4_LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"

var _capture_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var chapter: String = args[0].to_lower() if not args.is_empty() else ""
	match chapter:
		"ch2":
			await _capture_chapter_two()
		"ch3":
			await _capture_chapter_three()
		"ch4":
			await _capture_chapter_four()
		_:
			return _fail("expected user argument ch2, ch3, or ch4")
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug != null:
		debug.reset_to_defaults()
	print("BOSS_INTRO_UI_CAPTURE: PASS chapter=%s captures=%d route=MainBootstrap" % [chapter, _capture_count])
	quit(0)


func _capture_chapter_two() -> void:
	_configure_debug(ChapterRegistry.CHAPTER_02_SILENT_COURT, &"CH2_BOSS")
	if change_scene_to_file(BOOTSTRAP) != OK:
		return _fail("CH2 MainBootstrap start failed")
	var level: Node = await _wait_for_scene(CH2_LEVEL, 900)
	if level == null:
		return _fail("CH2 formal level did not load")
	var player: Player = level.get_node_or_null(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player"
	) as Player
	var boss: HollowDuchess = level.get_node_or_null(
		"GameplayWorld/BossArea/HollowDuchess"
	) as HollowDuchess
	var controller: HollowDuchessRoomController = level.get_node_or_null(
		"ChapterSystems/HollowDuchessRoomController"
	) as HollowDuchessRoomController
	if player == null or boss == null or controller == null:
		return _fail("CH2 formal Boss composition is incomplete")
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(3800.0, -1216.0)
	player.velocity = Vector2.ZERO
	controller._on_activation_body_entered(player)
	if not await _wait_visible(controller.dialogue_panel, 600):
		return _fail("CH2 Dialogue panel never appeared")
	await _settle(3)
	_save("ch2_01_dialogue.png")
	if not await _wait_visible(controller.intro_card, 900):
		return _fail("CH2 Boss name reveal never appeared")
	await _settle(5)
	_save("ch2_02_boss_name.png")
	if not await _wait_visible(controller.boss_hud, 600):
		return _fail("CH2 Boss HUD never appeared")
	await _settle(3)
	_save("ch2_03_hp_bar.png")
	boss.debug_set_health(121)
	if not await _wait_visible(controller.phase_title, 1200):
		return _fail("CH2 Phase II title never appeared")
	await _settle(4)
	_save("ch2_04_phase_02.png")


func _capture_chapter_three() -> void:
	_configure_debug(ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES, &"CH3_BOSS")
	if change_scene_to_file(BOOTSTRAP) != OK:
		return _fail("CH3 MainBootstrap start failed")
	var route: Chapter03Route = await _wait_for_scene(CH3_ROUTE, 900) as Chapter03Route
	if route == null:
		return _fail("CH3 formal route did not load")
	var room: Chapter03BossSanctumRoom = null
	for _frame: int in range(900):
		await process_frame
		if route.transition_controller.active_room_id == &"CH3_BOSS":
			room = route.transition_controller.active_room as Chapter03BossSanctumRoom
			if room != null:
				break
	if room == null:
		return _fail("CH3 formal Boss room did not load")
	var sanctum: Chapter03BossSanctum = room.sanctum
	if not await _wait_visible(sanctum.dialogue_panel, 1200):
		return _fail("CH3 Dialogue panel never appeared")
	await _settle(3)
	_save("ch3_01_dialogue_reference.png")
	if not await _wait_visible(sanctum.boss_title, 1200):
		return _fail("CH3 Boss name reveal never appeared")
	await _settle(5)
	_save("ch3_02_boss_name_reference.png")
	var boss_hud: CanvasLayer = room.boss.get_node("BossHud") as CanvasLayer
	var boss_hud_panel: Control = boss_hud.get_node("Panel") as Control
	if not await _wait_visible(boss_hud_panel, 900):
		return _fail("CH3 Boss HUD never appeared")
	await _settle(3)
	_save("ch3_03_hp_bar_reference.png")
	room.boss.debug_force_phase_02()
	if not await _wait_visible(sanctum.phase_title, 1500):
		return _fail("CH3 Phase II title never appeared")
	await _settle(4)
	_save("ch3_04_phase_02_reference.png")


func _capture_chapter_four() -> void:
	_configure_debug(ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP, &"CH4_BOSS_PHASE_01")
	if change_scene_to_file(BOOTSTRAP) != OK:
		return _fail("CH4 MainBootstrap start failed")
	var level: Node = await _wait_for_scene(CH4_LEVEL, 900)
	if level == null:
		return _fail("CH4 formal level did not load")
	var transitions: Chapter04RoomTransitionController = level.get_node(
		"RoomTransitionController"
	) as Chapter04RoomTransitionController
	var room: Node = null
	for _frame: int in range(900):
		await process_frame
		if transitions.active_room_id == &"CH4_AREA_14":
			room = transitions.active_room
			if room != null:
				break
	if room == null:
		return _fail("CH4 formal Boss room did not load")
	var flow: Chapter04BossRoomController = room.get_node("BossRoomController") as Chapter04BossRoomController
	var boss: SoulGaolerOrmund = room.get_node("Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
	if not await _wait_visible(flow._dialogue_panel, 600):
		return _fail("CH4 Dialogue panel never appeared")
	await _settle(3)
	_save("ch4_01_dialogue.png")
	if not await _wait_visible(flow._boss_title, 1200):
		return _fail("CH4 Boss name reveal never appeared")
	await _settle(5)
	_save("ch4_02_boss_name.png")
	if not await _wait_visible(flow._boss_panel, 600):
		return _fail("CH4 Boss HUD never appeared")
	await _settle(3)
	_save("ch4_03_hp_bar.png")
	boss.health_component.set_current_health(roundi(boss.health_component.max_health * 0.5))
	boss.complete_debug_phase_transition()
	if not await _wait_visible(flow._phase_title, 900):
		return _fail("CH4 Phase II title never appeared")
	await _settle(4)
	_save("ch4_04_phase_02.png")


func _configure_debug(chapter_id: StringName, spawn_id: StringName) -> void:
	var debug: DebugRunConfigState = root.get_node("DebugRunConfig") as DebugRunConfigState
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = chapter_id
	debug.debug_start_spawn_id = spawn_id
	debug.debug_reset_chapter_state_on_run = true
	debug.debug_skip_chapter_intro = true


func _wait_for_scene(path: String, maximum_frames: int) -> Node:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == path:
			return current_scene
	return null


func _wait_visible(control: CanvasItem, maximum_frames: int) -> bool:
	if control == null:
		return false
	for _frame: int in range(maximum_frames):
		await process_frame
		if is_instance_valid(control) and control.visible and control.modulate.a > 0.12:
			return true
	return false


func _settle(frames: int) -> void:
	for _frame: int in range(frames):
		await process_frame
	await RenderingServer.frame_post_draw


func _save(file_name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var path: String = "%s/%s" % [OUTPUT_DIR, file_name]
	if image.save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("could not save %s" % path)
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("BOSS_INTRO_UI_CAPTURE: %s" % message)
	quit(1)
