extends SceneTree

## Original-resolution evidence from the configured F5 Main Boss instance.

const MAIN_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	for _frame: int in range(8):
		await physics_frame
	_disable_normal_encounters(main)
	var player: Player = main.get_node("World/Player") as Player
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	var boss: FallenGateKnight = room.boss
	player.global_position = Vector2(5790, 612)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	room._on_entry_body_entered(player)
	boss.set_physics_process(false)
	await _wait_process_frames(8)
	_save_viewport("res://docs/qa/fallen_gate_knight_shield_10_main.png")

	var normal: HitboxComponent = player.action_controller.attack_hitbox
	player.global_position = boss.global_position + Vector2(-55.0, 0.0)
	for hit_index: int in range(4):
		normal.begin_attack(95_000 + hit_index, 1, 1.0, player)
		normal.try_hit(boss.hurtbox)
		normal.end_attack()
	boss.current_state = FallenGateKnight.IDLE_SHIELDED
	boss.play_animation(&"idle_shielded", true)
	await _wait_process_frames(6)
	_save_viewport("res://docs/qa/fallen_gate_knight_shield_damaged_main.png")

	boss.current_state = FallenGateKnight.APPROACH_SHIELDED
	boss.set_facing_direction(-1.0)
	boss._interrupt_turn()
	boss._turn_cooldown_timer = 0.0
	player.global_position = boss.global_position + Vector2(120.0, 0.0)
	boss._process_turn_request(0.08)
	boss.animated_sprite.pause()
	boss.animated_sprite.frame = 1
	await _wait_process_frames(6)
	_save_viewport("res://docs/qa/fallen_gate_knight_turn_main.png")
	print("FALLEN_GATE_KNIGHT_QA: node=%s shield=%d/%d visual=%s state=%s turn_frame=%d" % [
		boss.get_path(), boss.shield_component.shield_current_health,
		boss.shield_component.shield_max_health, boss._get_shield_visual_state(),
		boss.get_state_name(), boss.animated_sprite.frame,
	])
	quit(0)


func _disable_normal_encounters(main: Node2D) -> void:
	var encounters: Node2D = main.get_node("World/Encounters") as Node2D
	encounters.process_mode = Node.PROCESS_MODE_DISABLED
	for enemy: Node in get_nodes_in_group("enemies"):
		var combatant: EnemyCombatant = enemy as EnemyCombatant
		if combatant != null:
			combatant.set_ai_active(false)


func _wait_process_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _save_viewport(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Cannot save Fallen Gate Knight QA image %s" % path)
