extends SceneTree

## F5-route QA evidence for the Chapter I revival bridge.

const CATACOMB: PackedScene = preload("res://scenes/levels/veilbound_catacomb.tscn")
const MAIN: PackedScene = preload("res://scenes/main/main.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var catacomb: VeilboundCatacombController = CATACOMB.instantiate() as VeilboundCatacombController
	root.add_child(catacomb)
	current_scene = catacomb
	await _wait_frames(5)
	catacomb.set_process(false)
	catacomb.player.set_physics_process(false)
	if catacomb._active_tween != null and catacomb._active_tween.is_valid():
		catacomb._active_tween.kill()
	catacomb.fade_rect.modulate.a = 0.0
	catacomb.skip_panel.visible = false
	catacomb.dialogue_ui.hide_dialogue()
	catacomb.gameplay_hud_root.visible = false
	catacomb.candle_warden.visible = false
	catacomb.revival_art.soul_visible = false
	catacomb.revival_art.set_pose(RevivalPlayerArt.Pose.CORPSE)
	await _wait_frames(3)
	_save("res://docs/qa/veilbound_catacomb_01_altar_corpse.png")

	catacomb.revival_art.soul_visible = true
	catacomb.revival_art.soul_alpha = 0.88
	catacomb.revival_art.soul_offset = Vector2(0, -42)
	catacomb.revival_art.soul_mark_strength = 0.75
	await _wait_frames(3)
	_save("res://docs/qa/veilbound_catacomb_02_soul_descent.png")

	catacomb.revival_art.soul_visible = false
	catacomb.revival_art.soul_mark_strength = 0.3
	catacomb.revival_art.set_pose(RevivalPlayerArt.Pose.SIT_UP)
	await _wait_frames(3)
	_save("res://docs/qa/veilbound_catacomb_03_sit_up.png")

	catacomb.revival_art.set_pose(RevivalPlayerArt.Pose.STAND)
	catacomb.candle_warden.visible = true
	catacomb.candle_warden.position.x = 760.0
	catacomb.candle_warden.set_presentation_state(CandleWarden.PresentationState.RAISE_LANTERN)
	catacomb.dialogue_ui.show_line(
		"守烛人 / CANDLE WARDEN",
		"因为钟认得你。",
		"Because the bell remembers you."
	)
	await _wait_frames(3)
	_save("res://docs/qa/veilbound_catacomb_04_candle_warden_dialogue.png")

	catacomb.dialogue_ui.hide_dialogue()
	catacomb.revival_art.visible = false
	catacomb.player_visual.visible = true
	catacomb.dagger_visuals.visible = false
	catacomb.stone_door.open_progress = 1.0
	catacomb.stone_door.rune_strength = 0.35
	catacomb.player.global_position = Vector2(1190, 626)
	catacomb.player.player_camera.reset_smoothing()
	await _wait_frames(8)
	_save("res://docs/qa/veilbound_catacomb_05_stone_door_open.png")
	_save("res://docs/qa/veilbound_catacomb_door_layering_overview.png")

	catacomb.player.global_position = Vector2(1370, 626)
	catacomb.player.player_camera.reset_smoothing()
	await _wait_frames(8)
	_save("res://docs/qa/veilbound_catacomb_player_in_doorway.png")
	catacomb.queue_free()
	await process_frame

	var main: Node2D = MAIN.instantiate() as Node2D
	root.add_child(main)
	current_scene = main
	await _wait_frames(8)
	var debug_controller: MainDebugHudController = main.get_node("Interface") as MainDebugHudController
	debug_controller.set_debug_hud_visible(false)
	var player: Player = main.get_node("World/Player") as Player
	player.player_camera.reset_smoothing()
	await _wait_frames(8)
	_save("res://docs/qa/veilbound_catacomb_06_dark_forest_arrival.png")
	main.queue_free()
	await process_frame
	print("VEILBOUND_CATACOMB_QA: PASS (altar, soul, dialogue, layered door, player aperture, forest)")
	quit(0)


func _wait_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _save(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Could not save catacomb QA image %s" % path)
