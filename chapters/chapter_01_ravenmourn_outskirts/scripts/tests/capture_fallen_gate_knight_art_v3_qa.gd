extends SceneTree

## Screenshot evidence from the actual F5 route:
## MainBootstrap -> Chapter I -> saved FallenGateKnight instance on the bridge.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
const OUTPUT: String = "res://docs/qa/fallen_gate_knight_art_v3"

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
	boss.set_ai_active(false)
	boss.visible = true
	boss.modulate = Color.WHITE

	boss.current_phase = 1
	boss.shield_component.shield_current_health = 100
	boss._update_shield_visual(100)
	_freeze_boss(boss, &"idle_shielded", 0)
	await _frames(6)
	_save("01_phase_1_main.png")

	boss.shield_component.shield_current_health = 66
	boss._update_shield_visual(66)
	_freeze_boss(boss, &"idle_shielded", 1)
	await _frames(3)
	_save("02_shield_66_main.png")

	boss.shield_component.shield_current_health = 33
	boss._update_shield_visual(33)
	_freeze_boss(boss, &"idle_shielded", 2)
	await _frames(3)
	_save("03_shield_33_main.png")

	boss.shield_damage_overlay.visible = false
	_freeze_boss(boss, &"shield_break", 3)
	await _frames(3)
	_save("04_shield_break_main.png")

	_freeze_boss(boss, &"phase_transition", 3)
	await _frames(3)
	_save("05_phase_transition_main.png")

	boss.current_phase = 2
	_freeze_boss(boss, &"idle_unshielded", 0)
	await _frames(3)
	_save("06_phase_2_main.png")

	_freeze_boss(boss, &"charge_thrust", 3)
	await _frames(3)
	_save("07_greatsword_attack_main.png")

	_freeze_boss(boss, &"death", 5)
	await _frames(3)
	_save("08_death_main.png")
	_write_old_new_comparison()

	debug.reset_to_defaults()
	print("FALLEN_GATE_KNIGHT_ART_V3_MAIN_QA: PASS route=MainBootstrap spawn=boss_checkpoint captures=%d" % _capture_count)
	quit(0)


func _freeze_boss(boss: FallenGateKnight, animation: StringName, frame: int) -> void:
	boss.play_animation(animation, true)
	boss.animated_sprite.pause()
	boss.animated_sprite.frame = mini(frame, boss.animated_sprite.sprite_frames.get_frame_count(animation) - 1)


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
	var image: Image = root.get_texture().get_image()
	var path: String = OUTPUT + "/" + file_name
	if image.save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("cannot save %s" % path)
		return
	_capture_count += 1


func _write_old_new_comparison() -> void:
	var old_path: String = "res://docs/qa/chapter_01_enemy_art_rework/24_fallen_gate_knight_main_phase_1.png"
	var new_path: String = OUTPUT + "/01_phase_1_main.png"
	var old_image: Image = Image.load_from_file(ProjectSettings.globalize_path(old_path))
	var new_image: Image = Image.load_from_file(ProjectSettings.globalize_path(new_path))
	if old_image.is_empty() or new_image.is_empty():
		_fail("cannot build old/new comparison")
		return
	old_image.resize(1280, 720, Image.INTERPOLATE_NEAREST)
	new_image.resize(1280, 720, Image.INTERPOLATE_NEAREST)
	var comparison: Image = Image.create(2560, 720, false, Image.FORMAT_RGBA8)
	comparison.fill(Color("0b0e14"))
	comparison.blit_rect(old_image, Rect2i(0, 0, 1280, 720), Vector2i.ZERO)
	comparison.blit_rect(new_image, Rect2i(0, 0, 1280, 720), Vector2i(1280, 0))
	var output_path: String = OUTPUT + "/09_old_left_new_right_main.png"
	if comparison.save_png(ProjectSettings.globalize_path(output_path)) != OK:
		_fail("cannot save old/new comparison")
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("FALLEN_GATE_KNIGHT_ART_V3_MAIN_QA: %s" % message)
	quit(1)
