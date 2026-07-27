extends SceneTree

## Original-resolution evidence from three regions of the configured F5 Main scene.

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

	await _capture_region(
		player,
		Vector2(720.0, 612.0),
		"res://docs/qa/dark_forest_outskirts_main.png"
	)
	await _capture_region(
		player,
		Vector2(3020.0, 612.0),
		"res://docs/qa/castle_frontier_transition_main.png"
	)
	player.global_position = Vector2(5980.0, 612.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	room._on_entry_body_entered(player)
	room.boss.set_physics_process(false)
	await _wait_frames(12)
	_save_viewport("res://docs/qa/gothic_spired_castle_boss_main.png")
	print("FIRST_LEVEL_ENVIRONMENT_UNITY_QA: main=%s early=DarkForest middle=CastleFrontier boss=GothicSpiredCastle" % [
		ProjectSettings.get_setting("application/run/main_scene"),
	])
	quit(0)


func _disable_encounters(main: Node2D) -> void:
	var encounters: Node2D = main.get_node("World/Encounters") as Node2D
	encounters.process_mode = Node.PROCESS_MODE_DISABLED
	for enemy_node: Node in get_nodes_in_group("enemies"):
		var combatant: EnemyCombatant = enemy_node as EnemyCombatant
		if combatant != null:
			combatant.set_ai_active(false)


func _capture_region(player: Player, position: Vector2, path: String) -> void:
	player.global_position = position
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	await _wait_frames(12)
	_save_viewport(path)


func _wait_frames(count: int) -> void:
	for frame_index: int in range(count):
		await process_frame


func _save_viewport(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Cannot save first-level environment QA image %s" % path)
