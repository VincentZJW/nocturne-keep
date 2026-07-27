extends SceneTree

## Original-resolution QA evidence for the authored opening and F5 Main flow.

const OPENING: PackedScene = preload("res://scenes/cinematics/opening_cinematic.tscn")
const MAIN: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	await _capture_opening_shots()
	await _capture_main_regions()
	print("CHAPTER_ONE_QA: PASS (opening 2, tutorial, shield, mixed, Boss, gate)")
	quit(0)


func _capture_opening_shots() -> void:
	var opening: OpeningCinematicController = OPENING.instantiate() as OpeningCinematicController
	opening.scene_change_enabled = false
	root.add_child(opening)
	current_scene = opening
	await _wait_frames(5)
	opening._kill_timeline_tweens()
	opening.fade_rect.modulate.a = 0.0
	opening.show_shot_for_qa(1)
	await _wait_frames(3)
	_save_viewport("res://docs/qa/chapter_01_opening_black_bell.png")
	opening.show_shot_for_qa(5)
	await _wait_frames(3)
	_save_viewport("res://docs/qa/chapter_01_opening_awakening.png")
	opening.queue_free()
	await process_frame


func _capture_main_regions() -> void:
	var main: Node2D = MAIN.instantiate() as Node2D
	root.add_child(main)
	current_scene = main
	await _wait_frames(8)
	var player: Player = main.get_node("World/Player") as Player
	var debug_controller: MainDebugHudController = main.get_node("Interface") as MainDebugHudController
	var tutorial: TutorialController = main.get_node("TutorialController") as TutorialController
	debug_controller.set_debug_hud_visible(false)
	_disable_all_enemy_ai(main)
	await _capture_at(player, Vector2(620, 612), "res://docs/qa/chapter_01_tutorial_area.png")
	tutorial.current_step = TutorialController.Step.SHIELD
	tutorial._show_current_prompt()
	_set_visible_groups(main, [&"TutorialEncounter05"])
	await _capture_at(player, Vector2(2100, 612), "res://docs/qa/chapter_01_shield_tutorial.png")
	tutorial.prompt_ui.hide_prompt()
	tutorial.prompt_ui.visible = false
	_set_visible_groups(main, [&"OutskirtsEncounter02", &"OutskirtsEncounter03", &"OutskirtsOptional01"])
	await _capture_at(player, Vector2(4280, 612), "res://docs/qa/chapter_01_mixed_encounter.png")
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	player.global_position = Vector2(5900, 612)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	room._on_entry_body_entered(player)
	room.boss.set_physics_process(false)
	await _wait_frames(10)
	_save_viewport("res://docs/qa/chapter_01_boss_bridge.png")
	room.castle_gate_controller.open_gate()
	await _wait_frames(80)
	player.global_position = Vector2(6380, 612)
	player.player_camera.reset_smoothing()
	await _wait_frames(8)
	_save_viewport("res://docs/qa/chapter_01_gate_entry.png")
	main.queue_free()


func _disable_all_enemy_ai(main: Node2D) -> void:
	var encounters: Node2D = main.get_node("World/Encounters") as Node2D
	for node: Node in encounters.get_children():
		var group: EncounterGroup = node as EncounterGroup
		if group == null:
			continue
		for enemy: EnemyCombatant in group.get_enemies():
			enemy.set_ai_active(false)


func _set_visible_groups(main: Node2D, visible_names: Array[StringName]) -> void:
	var encounters: Node2D = main.get_node("World/Encounters") as Node2D
	for node: Node in encounters.get_children():
		var group: EncounterGroup = node as EncounterGroup
		if group == null:
			continue
		var should_show: bool = group.encounter_name in visible_names
		for enemy: EnemyCombatant in group.get_enemies():
			enemy.visible = should_show


func _capture_at(player: Player, position: Vector2, path: String) -> void:
	player.global_position = position
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	await _wait_frames(10)
	_save_viewport(path)


func _wait_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _save_viewport(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Could not save Chapter I QA image %s" % path)
