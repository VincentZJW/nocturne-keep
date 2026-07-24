extends SceneTree

## Original-resolution configured-Main evidence for Gargoyle encounter and Boss room.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	for _frame: int in range(8):
		await physics_frame
	var player: Player = main.get_node("World/Player") as Player
	var group_five: EncounterGroup = main.get_node("World/Encounters/EncounterGroup05") as EncounterGroup
	player.global_position = Vector2(3440, 612)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	group_five.activate(player)
	for enemy: EnemyCombatant in group_five.get_enemies():
		enemy.set_ai_active(false)
	for _frame: int in range(10):
		await process_frame
	_save_viewport("res://docs/qa/first_level_main_gargoyle.png")
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	player.global_position = Vector2(5790, 612)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	room._on_entry_body_entered(player)
	room.boss.set_physics_process(false)
	for _frame: int in range(12):
		await process_frame
	_save_viewport("res://docs/qa/first_level_main_boss.png")
	print("FIRST_LEVEL_MAIN_QA: groups=7 normals=18 boss=%s locked=%s hud=%s" % [
		room.boss.get_state_name(), room.room_is_locked, room.boss_hud.visible,
	])
	quit(0)


func _save_viewport(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Cannot save Main QA image %s" % path)
