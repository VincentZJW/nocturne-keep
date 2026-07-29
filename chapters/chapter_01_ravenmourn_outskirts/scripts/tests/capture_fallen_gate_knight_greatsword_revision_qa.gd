extends SceneTree

## Actual MainBootstrap -> Chapter I -> boss_checkpoint evidence for the
## Gatewarden Greatsword revision. This does not alter saved DebugRunConfig.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
const OUTPUT: String = "res://docs/qa/fallen_gate_knight_greatsword_revision"

var _capture_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null:
		_fail("missing DebugRunConfig")
		return
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS
	debug.debug_start_spawn_id = &"boss_checkpoint"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("cannot launch MainBootstrap")
		return
	var level: Node = await _wait_for_level()
	if level == null:
		_fail("Chapter I did not load from MainBootstrap")
		return
	var player: Player = level.get_node_or_null("World/Player") as Player
	var boss: FallenGateKnight = level.get_node_or_null(
		"World/CastleEntranceArea/FallenGateKnight"
	) as FallenGateKnight
	var room: BossRoomController = level.get_node_or_null("BossRoomController") as BossRoomController
	if player == null or boss == null or room == null:
		_fail("saved Main Boss composition is incomplete")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var interface: MainDebugHudController = level.get_node_or_null("Interface") as MainDebugHudController
	if interface != null:
		interface.set_debug_hud_visible(false)
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(5850.0, 612.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	room._on_entry_body_entered(player)
	var tutorial: Node = level.get_node_or_null("TutorialController")
	if tutorial != null:
		tutorial.set_process(false)
	var tutorial_prompt: CanvasItem = level.get_node_or_null("HUD/TutorialPrompt") as CanvasItem
	if tutorial_prompt != null:
		tutorial_prompt.visible = false
	boss.set_ai_active(false)
	boss.visible = true
	boss.modulate = Color.WHITE

	boss.current_phase = 1
	boss.shield_component.shield_current_health = 100
	boss._update_shield_visual(100)
	_freeze_boss(boss, &"idle_shielded", 0)
	await _frames(8)
	_save("01_phase_1_idle_with_player_main.png")

	_freeze_boss(boss, &"sword_slash", 2)
	await _frames(3)
	_save("02_phase_1_sword_slash_main.png")

	_freeze_boss(boss, &"heavy_overhead", 4)
	await _frames(3)
	_save("03_phase_1_heavy_overhead_main.png")

	boss.shield_damage_overlay.visible = false
	boss.current_phase = 2
	_freeze_boss(boss, &"idle_unshielded", 0)
	await _frames(3)
	_save("04_phase_2_two_handed_idle_main.png")

	_freeze_boss(boss, &"charge_thrust", 3)
	await _frames(3)
	_save("05_phase_2_charge_thrust_main.png")

	_freeze_boss(boss, &"combo_slash_1", 2)
	await _frames(3)
	_save("06_phase_2_combo_slash_main.png")

	_freeze_boss(boss, &"death", 5)
	await _frames(3)
	_save("07_death_sword_placement_main.png")
	_write_before_after_comparison()

	debug.reset_to_defaults()
	print(
		"FALLEN_GATE_KNIGHT_GREATSWORD_MAIN_QA: PASS "
		+ "route=MainBootstrap spawn=boss_checkpoint captures=%d" % _capture_count
	)
	quit(0)


func _freeze_boss(boss: FallenGateKnight, animation: StringName, frame: int) -> void:
	boss.play_animation(animation, true)
	boss.animated_sprite.pause()
	boss.animated_sprite.frame = mini(
		frame, boss.animated_sprite.sprite_frames.get_frame_count(animation) - 1
	)


func _wait_for_level() -> Node:
	for _index: int in range(420):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


func _save(file_name: String) -> void:
	var prompt: CanvasItem = current_scene.get_node_or_null("HUD/TutorialPrompt") as CanvasItem
	if prompt != null:
		prompt.visible = false
	var image: Image = root.get_texture().get_image()
	var path: String = OUTPUT + "/" + file_name
	if image.save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("cannot save %s" % path)
		return
	_capture_count += 1


func _write_before_after_comparison() -> void:
	var old_path: String = "res://docs/qa/fallen_gate_knight_art_v3/01_phase_1_main.png"
	var new_path: String = OUTPUT + "/01_phase_1_idle_with_player_main.png"
	var old_image: Image = Image.load_from_file(ProjectSettings.globalize_path(old_path))
	var new_image: Image = Image.load_from_file(ProjectSettings.globalize_path(new_path))
	if old_image.is_empty() or new_image.is_empty():
		_fail("cannot build before/after comparison")
		return
	old_image.resize(1280, 720, Image.INTERPOLATE_NEAREST)
	new_image.resize(1280, 720, Image.INTERPOLATE_NEAREST)
	var comparison: Image = Image.create(2560, 720, false, Image.FORMAT_RGBA8)
	comparison.fill(Color("0b0e14"))
	comparison.blit_rect(old_image, Rect2i(0, 0, 1280, 720), Vector2i.ZERO)
	comparison.blit_rect(new_image, Rect2i(0, 0, 1280, 720), Vector2i(1280, 0))
	var output_path: String = OUTPUT + "/08_before_left_after_right_main.png"
	if comparison.save_png(ProjectSettings.globalize_path(output_path)) != OK:
		_fail("cannot save before/after comparison")
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("FALLEN_GATE_KNIGHT_GREATSWORD_MAIN_QA: %s" % message)
	quit(1)
