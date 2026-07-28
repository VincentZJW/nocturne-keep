extends SceneTree

## Captures the rebuilt Candle Warden inside the formal Main-routed Prologue scene.

const CATACOMB: String = "res://scenes/levels/veilbound_catacomb.tscn"
const OUTPUT_ROOT: String = "res://docs/qa/core_character_art_rework/stage_3"

var _catacomb: VeilboundCatacombController


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	if change_scene_to_file(CATACOMB) != OK:
		_fail("unable to load formal Veilbound Catacomb")
		return
	for _frame: int in range(24):
		await process_frame
	_catacomb = current_scene as VeilboundCatacombController
	if _catacomb == null:
		_fail("formal Main-routed Prologue did not load")
		return
	_prepare_composition()
	await _capture_pose(
		CandleWarden.PresentationState.RISING,
		3,
		"守烛人从祭坛阴影中起身。",
		"The Candle Warden rises from the altar shadow.",
		"01_main_prologue_warden_rising.png"
	)
	await _capture_pose(
		CandleWarden.PresentationState.LANTERN_IDLE,
		2,
		"七年。",
		"Seven years.",
		"02_main_prologue_lantern_idle.png"
	)
	await _capture_pose(
		CandleWarden.PresentationState.TALK_EMPHASIS,
		2,
		"钥匙还记得它所守护的门。",
		"The key still remembers the door it guarded.",
		"03_main_prologue_talk_emphasis.png"
	)
	await _capture_pose(
		CandleWarden.PresentationState.GESTURE_POINT,
		2,
		"沿着石门后的路走。",
		"Take the road beyond the stone door.",
		"04_main_prologue_point.png"
	)
	await _capture_pose(
		CandleWarden.PresentationState.GESTURE_WARN,
		2,
		"不要回应第十四声钟。",
		"Do not answer the fourteenth bell.",
		"05_main_prologue_warn.png"
	)
	await _capture_pose(
		CandleWarden.PresentationState.OFFER_KEY,
		2,
		"守烛人的钥匙。",
		"The Candle Warden's key.",
		"06_main_prologue_offer_key.png"
	)
	_catacomb.dialogue_ui.hide_dialogue()
	_catacomb.stone_door.open_progress = 0.72
	_catacomb.stone_door.rune_strength = 0.8
	await _capture_pose(
		CandleWarden.PresentationState.OPEN_DOOR,
		3,
		"",
		"",
		"07_main_prologue_open_door.png"
	)
	_catacomb.candle_warden.pulse_soul_flame(1.35, 0.5)
	await _capture_pose(
		CandleWarden.PresentationState.RAISE_LANTERN,
		2,
		"因为钟认得你。",
		"Because the bell remembers you.",
		"08_main_prologue_soul_lantern.png"
	)
	print("CANDLE_WARDEN_STAGE_3_MAIN_QA: PASS (8 formal Prologue captures)")
	quit(0)


func _prepare_composition() -> void:
	_catacomb.set_process(false)
	_catacomb.player.set_physics_process(false)
	if _catacomb._active_tween != null and _catacomb._active_tween.is_valid():
		_catacomb._active_tween.kill()
	if _catacomb._camera_tween != null and _catacomb._camera_tween.is_valid():
		_catacomb._camera_tween.kill()
	_catacomb.fade_rect.modulate.a = 0.0
	_catacomb.skip_panel.visible = false
	_catacomb.gameplay_hud_root.visible = false
	_catacomb.objective_ui.visible = false
	_catacomb.interaction_prompt.visible = false
	_catacomb.revival_art.visible = true
	_catacomb.revival_art.soul_visible = false
	_catacomb.revival_art.set_pose(RevivalPlayerArt.Pose.STAND)
	_catacomb.player_visual.visible = false
	_catacomb.candle_warden.visible = true
	_catacomb.candle_warden.restore_from_shadow()
	_catacomb.candle_warden.position = Vector2(760, 649)
	_catacomb.candle_warden.facing_left = true
	_catacomb.player_camera.position = Vector2(82, -5)
	_catacomb.player_camera.zoom = Vector2(1.35, 1.35)
	_catacomb.player_camera.reset_smoothing()


func _capture_pose(
		state: CandleWarden.PresentationState,
		frame_index: int,
		line_zh: String,
		line_en: String,
		file_name: String
	) -> void:
	_catacomb.candle_warden.set_presentation_state(state)
	var body: AnimatedSprite2D = _catacomb.candle_warden.body
	body.pause()
	body.frame = mini(frame_index, body.sprite_frames.get_frame_count(body.animation) - 1)
	_catacomb.candle_warden.call("_sync_lantern_anchor")
	if line_zh.is_empty():
		_catacomb.dialogue_ui.hide_dialogue()
	else:
		_catacomb.dialogue_ui.show_line("守烛人 / CANDLE WARDEN", line_zh, line_en)
	for _frame: int in range(8):
		await process_frame
	var image: Image = root.get_texture().get_image()
	var output_path: String = OUTPUT_ROOT.path_join(file_name)
	var error: Error = image.save_png(ProjectSettings.globalize_path(output_path))
	if error != OK:
		_fail("could not save %s" % output_path)


func _fail(message: String) -> void:
	push_error("CANDLE_WARDEN_STAGE_3_MAIN_QA: %s" % message)
	quit(1)
