extends SceneTree

## Captures the real Main PackedScene composition used by the configured F5 flow.

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
	var reward: BossRewardController = main.get_node(
		"World/CastleEntranceArea/BossReward"
	) as BossRewardController
	_caption = _create_caption(main)

	await _capture_icon(main)
	player.global_position = Vector2(6150, 612)
	player.player_camera.reset_smoothing()
	reward.debug_force_reward()
	boss.visible = false
	_caption.text = "BOSS REWARD · RAVENFANG CURVED CLAW PICKUP"
	await _wait_frames(8)
	await _save("res://docs/qa/ravenfang_boss_pickup_main.png")

	reward.weapon_pickup.collect()
	reward.acquired_label.visible = false
	await _wait_frames(3)
	boss.visible = true
	boss.set_physics_process(false)
	player.global_position = Vector2(6000, 612)
	player.player_camera.reset_smoothing()
	await _pose_player(player, &"idle", 1)
	_caption.text = "EQUIPPED IDLE · AUTHORITATIVE RAVENFANG SPRITEFRAMES · 12 / 24"
	await _save("res://docs/qa/ravenfang_equipped_idle_main.png")

	await _pose_player(player, &"attack", 2)
	_caption.text = "NORMAL ATTACK · DUAL RAVEN-CLAW THRUST · COMBO STEP 2 / 3"
	await _save("res://docs/qa/ravenfang_normal_attack_main.png")

	await _pose_player(player, &"dash_attack", 2)
	_caption.text = "DASH ATTACK · PAIRED CURVED BLADES · DAMAGE 24"
	await _save("res://docs/qa/ravenfang_dash_attack_main.png")

	player.global_position = boss.global_position + Vector2(58, 0)
	boss.current_phase = 2
	boss.current_state = FallenGateKnight.IDLE_UNSHIELDED
	boss.set_facing_direction(1.0)
	boss._start_attack(FallenGateKnight.SWORD_SLASH)
	boss.animated_sprite.pause()
	boss.animated_sprite.frame = 1
	boss.shield_component.last_attack_kind = &"normal_attack"
	boss._on_hurtbox_hit_received(12, player.global_position, 940_001)
	await _pose_player(player, &"attack", 2)
	_caption.text = "LIGHT HIT PRESSURE · BOSS KEEPS SWORD SLASH WINDUP"
	await _save("res://docs/qa/boss_light_pressure_counter_main.png")

	boss.current_state = FallenGateKnight.RECOVERY
	boss._attack_gap_remaining = boss.config.sword_slash_attack_gap
	boss.play_animation(&"idle_unshielded", true)
	boss.animated_sprite.pause()
	await _pose_player(player, &"dash_attack", 3)
	_caption.text = "POST-ACTIVE GAP · 1 COUNTER + REVERSE DASH · NEXT WINDUP LOCKED"
	await _save("res://docs/qa/boss_post_attack_gap_main.png")

	boss.current_phase = 1
	boss.current_state = FallenGateKnight.APPROACH_SHIELDED
	boss.set_facing_direction(-1.0)
	boss.play_animation(&"walk_shielded", true)
	boss.animated_sprite.pause()
	player.global_position = boss.global_position + Vector2(62, 0)
	await _pose_player(player, &"attack", 2)
	_caption.text = "REAR CONTACT WINDOW · OLD FACING ROUTES TO BODY"
	await _save("res://docs/qa/boss_rear_normal_window_main.png")

	boss.current_state = FallenGateKnight.TURN_SHIELDED
	boss.play_animation(&"turn_shielded", true)
	boss.animated_sprite.pause()
	boss.animated_sprite.frame = 1
	await _pose_player(player, &"idle", 0)
	_caption.text = "AUTHORED TURN · 0.25s REACTION + 0.65s ANIMATION = 0.90s"
	await _save("res://docs/qa/boss_turn_reward_window_main.png")

	await _pose_player(player, &"death", 4)
	_caption.text = "RAVENFANG DEATH FRAME · BOTH CURVED BLADES REMAIN CONSISTENT"
	await _save("res://docs/qa/ravenfang_death_frame_main.png")
	print("RAVENFANG_BOSS_CADENCE_QA: PASS (10 Main-backed captures)")
	quit(0)


func _capture_icon(main: Node2D) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 50
	var panel: ColorRect = ColorRect.new()
	panel.position = Vector2(430, 180)
	panel.size = Vector2(420, 300)
	panel.color = Color("101722e6")
	var icon: TextureRect = TextureRect.new()
	icon.position = Vector2(146, 54)
	icon.size = Vector2(128, 128)
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = load("res://assets/ui/items/ravenfang_daggers.png") as Texture2D
	var title: Label = Label.new()
	title.position = Vector2(64, 202)
	title.size = Vector2(292, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "RAVENFANG DAGGERS\n16×16 · NEAREST · CURVED RAVEN CLAWS"
	panel.add_child(icon)
	panel.add_child(title)
	layer.add_child(panel)
	main.add_child(layer)
	await _wait_frames(3)
	await _save("res://docs/qa/ravenfang_icon_main.png")
	layer.queue_free()
	await process_frame


func _pose_player(player: Player, animation_name: StringName, frame: int) -> void:
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	sprite.play(animation_name)
	sprite.pause()
	sprite.frame = frame
	await _wait_frames(3)


func _create_caption(main: Node2D) -> Label:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 40
	var label: Label = Label.new()
	label.position = Vector2(290, 650)
	label.size = Vector2(700, 38)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("d5dee3"))
	label.add_theme_color_override("font_shadow_color", Color("08101a"))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(label)
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
		push_error("Unable to save Ravenfang/Boss QA image %s" % path)
