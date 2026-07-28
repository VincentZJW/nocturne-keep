extends SceneTree

## Captures one shared-Player route per process to keep renderer teardown clean.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const CATACOMB: String = "res://scenes/levels/veilbound_catacomb.tscn"
const OUTPUT_ROOT: String = "res://docs/qa/core_character_art_rework/stage_2"

var _config: DebugRunConfigState


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	var target: String = _read_target()
	if target == "chapter_02":
		await _capture_chapter(
			ChapterRegistry.CHAPTER_02_SILENT_COURT,
			&"CH2_FLOOR_1_START",
			ChapterRegistry.CHAPTER_02_SCENE_PATH,
			"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player",
			"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/HUD",
			"20_chapter_02_shared_player.png"
		)
	elif target == "chapter_03":
		await _capture_chapter(
			ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES,
			&"CH3_BELLCHAIN_TEST",
			ChapterRegistry.CHAPTER_03_SCENE_PATH,
			"GameplayWorld/ChapterRuntime/Player",
			"GameplayWorld/ChapterRuntime/HUD",
			"21_chapter_03_shared_player.png"
		)
	elif target == "prologue":
		await _capture_prologue()
	else:
		_fail("expected --qa-target=chapter_02, chapter_03 or prologue")
		return
	if _config != null:
		_config.reset_to_defaults()
	await _release_current_scene()
	print("PLAYER_STAGE_2_SHARED_QA: PASS target=%s" % target)
	quit(0)


func _capture_chapter(
		chapter_id: StringName,
		spawn_id: StringName,
		expected_path: String,
		player_path: String,
		hud_path: String,
		file_name: String
	) -> void:
	_config = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if _config == null:
		_fail("missing DebugRunConfig")
		return
	_config.debug_chapter_start_enabled = true
	_config.debug_start_chapter_id = chapter_id
	_config.debug_start_spawn_id = spawn_id
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("unable to load Bootstrap")
		return
	var level: Node2D = await _wait_for_scene(expected_path)
	if level == null:
		_fail("chapter did not load through Bootstrap: %s" % expected_path)
		return
	var player: Player = level.get_node_or_null(player_path) as Player
	if player == null:
		_fail("shared Player missing: %s" % player_path)
		return
	var hud: CanvasLayer = level.get_node_or_null(hud_path) as CanvasLayer
	if hud != null:
		hud.visible = false
	player.set_physics_process(false)
	player.player_camera.zoom = Vector2(2.0, 2.0)
	player.player_camera.reset_smoothing()
	await _pose(player, &"ready_idle", 1)
	await _save(file_name)


func _capture_prologue() -> void:
	if change_scene_to_file(CATACOMB) != OK:
		_fail("unable to load formal Veilbound Catacomb")
		return
	var level: Node2D = await _wait_for_scene(CATACOMB)
	var catacomb: VeilboundCatacombController = level as VeilboundCatacombController
	if catacomb == null:
		_fail("formal Veilbound Catacomb did not load")
		return
	catacomb.set_process(false)
	catacomb.player.set_physics_process(false)
	if catacomb._active_tween != null and catacomb._active_tween.is_valid():
		catacomb._active_tween.kill()
	catacomb.fade_rect.modulate.a = 0.0
	catacomb.skip_panel.visible = false
	catacomb.dialogue_ui.hide_dialogue()
	catacomb.gameplay_hud_root.visible = false
	catacomb.candle_warden.visible = false
	catacomb.revival_art.visible = true
	catacomb.player_visual.visible = false
	catacomb.revival_art.soul_visible = true
	catacomb.revival_art.soul_alpha = 0.9
	catacomb.revival_art.soul_offset = Vector2(0.0, -42.0)
	catacomb.revival_art.set_pose(RevivalPlayerArt.Pose.SIT_UP)
	await _save("22_prologue_revival_shared_identity.png")


func _read_target() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--qa-target="):
			return argument.trim_prefix("--qa-target=")
	return ""


func _wait_for_scene(expected_path: String) -> Node2D:
	for _frame: int in range(360):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == expected_path:
			return current_scene as Node2D
	return null


func _pose(player: Player, animation_name: StringName, frame_index: int) -> void:
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	sprite.play(animation_name)
	sprite.pause()
	sprite.frame = frame_index
	for _frame: int in range(6):
		await process_frame


func _save(file_name: String) -> void:
	for _frame: int in range(3):
		await process_frame
	var image: Image = root.get_texture().get_image()
	var path: String = OUTPUT_ROOT.path_join(file_name)
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_fail("unable to save %s" % path)


func _release_current_scene() -> void:
	var old_scene: Node = current_scene
	current_scene = null
	if old_scene != null and is_instance_valid(old_scene):
		old_scene.queue_free()
	for _frame: int in range(12):
		await process_frame


func _fail(message: String) -> void:
	push_error("PLAYER_STAGE_2_SHARED_QA: %s" % message)
	if _config != null:
		_config.reset_to_defaults()
	quit(1)
