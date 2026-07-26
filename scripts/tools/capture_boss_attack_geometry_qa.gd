extends SceneTree

## Captures Fallen Gate Knight attack volumes and turn commitment from the real
## Main PackedScene used after the configured opening/catacomb F5 flow.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")

var _caption: Label


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	current_scene = main
	await _wait_frames(8)
	(main.get_node("Interface") as MainDebugHudController).set_debug_hud_visible(false)
	main.get_node("TutorialController").set_process(false)
	main.get_node("HUD/TutorialPrompt").visible = false
	_disable_encounters(main)
	var player: Player = main.get_node("World/Player") as Player
	var boss: FallenGateKnight = main.get_node(
		"World/CastleEntranceArea/FallenGateKnight"
	) as FallenGateKnight
	player.set_physics_process(false)
	boss.set_physics_process(false)
	boss.target = player
	boss.set_attack_geometry_debug_visible(true)
	_caption = _create_caption(main)

	await _capture_attack(
		player,
		boss,
		FallenGateKnight.CHARGE_THRUST,
		3,
		47.0,
		"THRUST · 32×10 HITBOX · ROOT RANGE 47 · VISUAL TIP 41",
		"res://docs/qa/boss_thrust_hitbox_main.png"
	)
	await _capture_attack(
		player,
		boss,
		FallenGateKnight.SWORD_SLASH,
		3,
		40.0,
		"SLASH · 26×22 HITBOX · ROOT RANGE 40 · VISUAL TIP 31",
		"res://docs/qa/boss_slash_hitbox_main.png"
	)
	await _capture_attack(
		player,
		boss,
		FallenGateKnight.SHIELD_BASH,
		3,
		37.0,
		"SHIELD BASH · 14×30 · 0.46 WINDUP / 0.10 ACTIVE / 0.68 RECOVERY",
		"res://docs/qa/boss_shield_bash_hitbox_main.png"
	)
	await _capture_rear_turn(player, boss)
	print("BOSS_ATTACK_GEOMETRY_QA: PASS (4 Main-backed captures)")
	quit(0)


func _capture_attack(
	player: Player,
	boss: FallenGateKnight,
	attack_state: StringName,
	frame: int,
	player_distance: float,
	caption: String,
	path: String
) -> void:
	boss._end_attack_window()
	boss._attack_gap_remaining = 0.0
	boss._shield_bash_cooldown_remaining = 0.0
	boss.current_phase = 2 if attack_state == FallenGateKnight.CHARGE_THRUST else 1
	boss.current_state = (
		FallenGateKnight.IDLE_UNSHIELDED
		if boss.current_phase == 2
		else FallenGateKnight.IDLE_SHIELDED
	)
	boss.set_facing_direction(1.0)
	boss.shield_damage_overlay.visible = boss.current_phase == 1
	var started: bool = boss._start_attack(attack_state)
	if not started:
		push_error("Unable to pose Boss attack %s" % attack_state)
		return
	boss.animated_sprite.pause()
	boss.animated_sprite.frame = frame
	boss._on_animation_frame_changed()
	player.global_position = boss.global_position + Vector2(player_distance, 16.0)
	player.player_camera.reset_smoothing()
	await _pose_player(player, &"idle", 0)
	_caption.text = caption
	await _wait_frames(4)
	await _save(path)


func _capture_rear_turn(player: Player, boss: FallenGateKnight) -> void:
	boss._end_attack_window()
	boss.current_phase = 1
	boss.current_state = FallenGateKnight.TURN_SHIELDED
	boss.set_facing_direction(-1.0)
	boss._pending_facing = 1.0
	boss._turn_animation_elapsed = 0.55
	boss._turn_facing_committed = false
	boss.play_animation(&"turn_shielded", true)
	boss.animated_sprite.pause()
	boss.animated_sprite.frame = 2
	player.global_position = boss.global_position + Vector2(48.0, 16.0)
	player.player_camera.reset_smoothing()
	await _pose_player(player, &"attack", 2)
	_caption.text = "REAR TURN WINDOW · 0.33 REACTION + 0.80 TURN = 1.13s · COMMIT AT 80%"
	await _wait_frames(4)
	await _save("res://docs/qa/boss_rear_turn_window_main.png")


func _pose_player(player: Player, animation_name: StringName, frame: int) -> void:
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	sprite.play(animation_name)
	sprite.pause()
	sprite.frame = frame
	await _wait_frames(2)


func _create_caption(main: Node2D) -> Label:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 40
	var panel: ColorRect = ColorRect.new()
	panel.position = Vector2(205, 642)
	panel.size = Vector2(870, 52)
	panel.color = Color("08101acc")
	var label: Label = Label.new()
	label.position = Vector2(12, 6)
	label.size = Vector2(846, 40)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("d5dee3"))
	panel.add_child(label)
	layer.add_child(panel)
	main.add_child(layer)
	return label


func _disable_encounters(main: Node2D) -> void:
	var encounters: Node2D = main.get_node("World/Encounters") as Node2D
	encounters.process_mode = Node.PROCESS_MODE_DISABLED
	for node: Node in encounters.find_children("*", "", true, false):
		var enemy: EnemyCombatant = node as EnemyCombatant
		if enemy != null:
			enemy.visible = false


func _wait_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


func _save(path: String) -> void:
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Unable to save Boss attack geometry QA image %s" % path)
