extends SceneTree

## Original-resolution evidence from the configured F5 Main environment and gate flow.

const MAIN_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	current_scene = main
	for frame_index: int in range(8):
		await physics_frame
	var player: Player = main.get_node("World/Player") as Player
	var debug_controller: MainDebugHudController = main.get_node("Interface") as MainDebugHudController
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	debug_controller.set_debug_hud_visible(false)
	_disable_encounters(main)

	player.global_position = Vector2(4870.0, 612.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	await _wait_frames(12)
	_save_viewport("res://docs/qa/ravenmourn_approach_main.png")

	player.global_position = Vector2(5980.0, 612.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	room._on_entry_body_entered(player)
	room.boss.set_physics_process(false)
	await _wait_frames(12)
	_save_viewport("res://docs/qa/ravenmourn_boss_bridge_main.png")

	room.boss.health_component.take_damage(room.boss.health_component.current_health)
	room.boss.animated_sprite.animation_finished.emit()
	room.castle_gate_controller.advance(1.3)
	player.global_position = Vector2(6250.0, 612.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	await _wait_frames(12)
	_save_viewport("res://docs/qa/ravenmourn_gate_open_main.png")
	var arch_present: bool = main.has_node("World/RavenmournArchway")
	var gate_open: bool = room.castle_gate_controller.is_gate_open()
	var transition_target: String = room.entrance_transition.target_scene_path
	room.entrance_transition.fade_duration = 0.2
	room._on_castle_entrance_body_entered(player)
	await create_timer(0.35, true, false, true).timeout
	var threshold_loaded: bool = current_scene != null and current_scene.name == "RavenmournThreshold"
	print("RAVENMOURN_ENVIRONMENT_QA: main=%s arch=%s gate_open=%s transition=%s" % [
		ProjectSettings.get_setting("application/run/main_scene"),
		arch_present,
		gate_open,
		transition_target,
	])
	print("RAVENMOURN_THRESHOLD_QA: loaded=%s" % threshold_loaded)
	quit(0)


func _disable_encounters(main: Node2D) -> void:
	var encounters: Node2D = main.get_node("World/Encounters") as Node2D
	encounters.process_mode = Node.PROCESS_MODE_DISABLED
	for enemy_node: Node in get_nodes_in_group("enemies"):
		var combatant: EnemyCombatant = enemy_node as EnemyCombatant
		if combatant != null:
			combatant.set_ai_active(false)


func _wait_frames(count: int) -> void:
	for frame_index: int in range(count):
		await process_frame


func _save_viewport(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Cannot save Ravenmourn environment QA image %s" % path)
