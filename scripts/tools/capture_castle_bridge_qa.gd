extends SceneTree

## Original-resolution evidence from the configured F5 Main collision and bridge sequence.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	for frame_index: int in range(8):
		await physics_frame
	_disable_normal_encounters(main)
	var player: Player = main.get_node("World/Player") as Player
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	var ceiling_hit: bool = await _capture_ceiling_collision(player)
	player.set_physics_process(true)
	player.global_position = Vector2(5790, 612)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	room._on_entry_body_entered(player)
	room.boss.set_physics_process(false)
	await _wait_process_frames(12)
	_save_viewport("res://docs/qa/castle_bridge_boss_fight.png")
	room.boss.health_component.take_damage(room.boss.health_component.current_health)
	room.boss.animated_sprite.animation_finished.emit()
	await create_timer(1.10, true, false, true).timeout
	player.global_position = Vector2(6310, 612)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	await _wait_process_frames(12)
	_save_viewport("res://docs/qa/castle_gate_open.png")
	print("CASTLE_BRIDGE_QA: ceiling=%s rear_open=%s gate_open=%s boss_bounds=%s" % [
		ceiling_hit,
		room.rear_barrier.collision_layer == 0,
		room.castle_gate_controller.is_gate_open(),
		room.boss.get_bridge_bounds(),
	])
	quit(0)


func _capture_ceiling_collision(player: Player) -> bool:
	player.global_position = Vector2(870, 612)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	Input.action_press(Player.JUMP_ACTION)
	await physics_frame
	Input.action_release(Player.JUMP_ACTION)
	var hit: bool = false
	for frame_index: int in range(120):
		await physics_frame
		if player.is_on_ceiling():
			hit = true
			player.set_physics_process(false)
			break
	await _wait_process_frames(8)
	_save_viewport("res://docs/qa/solid_platform_ceiling_collision.png")
	return hit


func _disable_normal_encounters(main: Node2D) -> void:
	var encounters: Node2D = main.get_node("World/Encounters") as Node2D
	encounters.process_mode = Node.PROCESS_MODE_DISABLED
	for enemy: Node in get_nodes_in_group("enemies"):
		var combatant: EnemyCombatant = enemy as EnemyCombatant
		if combatant != null:
			combatant.set_ai_active(false)


func _wait_process_frames(count: int) -> void:
	for frame_index: int in range(count):
		await process_frame


func _save_viewport(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Cannot save castle bridge QA image %s" % path)
