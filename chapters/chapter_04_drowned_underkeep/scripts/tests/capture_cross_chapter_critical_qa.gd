extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const OUTPUT: String = "res://docs/qa/cross_chapter_critical_bugfix/chapter_04_main"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null:
		_fail("DebugRunConfig missing")
		return
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_AREA_03"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("MainBootstrap launch failed")
		return
	var level: Node = await _wait_level()
	if level == null:
		_fail("formal Chapter IV level did not load")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var controller: Chapter04RoomTransitionController = level.get_node("RoomTransitionController") as Chapter04RoomTransitionController
	var player: Player = level.get_node("ChapterRuntime/Player") as Player
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(1995.0, 592.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	for _frame: int in 8:
		await physics_frame
	var exit_east: Chapter04RoomExit = controller.active_room.get_node("Transitions/ExitEast") as Chapter04RoomExit
	var prompt: Label = exit_east.get_node("Prompt") as Label
	if not prompt.visible:
		_fail("Broken Chainway interaction prompt did not appear")
		return
	_save("01_broken_chainway_visible_exit_prompt_main.png")
	var event: InputEventAction = InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	exit_east._unhandled_input(event)
	for _frame: int in 180:
		await process_frame
		if not controller.is_transitioning() and controller.active_room_id == &"CH4_AREA_04":
			break
	if controller.active_room_id != &"CH4_AREA_04":
		_fail("Broken Chainway interact did not enter the next room")
		return
	_save("02_broken_chainway_destination_main.png")
	if not controller.call("_swap_room", &"CH4_AREA_02", &"EntryWest"):
		_fail("unable to load formal Chapter IV combat room")
		return
	await process_frame
	var spawner: Chapter04EncounterSpawner = controller.active_room.get_node("EncounterSpawner") as Chapter04EncounterSpawner
	var groups: Array[EncounterGroup] = spawner.get_encounter_groups()
	for group: EncounterGroup in groups:
		group.activate(player)
		for enemy: EnemyCombatant in group.get_enemies():
			enemy.set_ai_active(false)
	player.global_position = Vector2(1030.0, 592.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	for _frame: int in 12:
		await process_frame
	_save("03_chainbound_and_scaled_shield_main.png")
	if not controller.call("_swap_room", &"CH4_AREA_14", &"EntryWest"):
		_fail("unable to load formal Ormund room")
		return
	await process_frame
	var boss: SoulGaolerOrmund = controller.active_room.get_node_or_null("Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
	if boss == null:
		_fail("formal Boss room does not contain Ormund")
		return
	player.global_position = Vector2(1320.0, 592.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	boss.set_target(player)
	for _frame: int in 90:
		await process_frame
	_save("04_ormund_formal_boss_room_phase_01_main.png")
	boss.health_component.set_current_health(308)
	for _frame: int in 110:
		await process_frame
	_save("05_ormund_formal_boss_room_phase_02_main.png")
	debug.reset_to_defaults()
	print("CROSS CHAPTER CRITICAL QA CH4 MAIN | PASS captures=%d room=%s" % [_captures, controller.active_room_id])
	unload_current_scene()
	for _frame: int in 8:
		await process_frame
	quit(0)


func _wait_level() -> Node:
	for _frame: int in 480:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _save(file_name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var path: String = "%s/%s" % [OUTPUT, file_name]
	if image == null or image.save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("unable to save %s" % path)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("CROSS CHAPTER CRITICAL QA CH4 MAIN: %s" % message)
	quit(1)
