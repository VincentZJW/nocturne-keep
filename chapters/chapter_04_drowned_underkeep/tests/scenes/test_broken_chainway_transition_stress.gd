extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"

var _failures: PackedStringArray = []
var _transition_count: int = 0
var _checkpoint_reload_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	_check(debug != null, "DebugRunConfig missing")
	if debug == null:
		_finish()
		return
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_AREA_03"
	debug.debug_skip_chapter_intro = true
	_check(change_scene_to_file(BOOTSTRAP) == OK, "MainBootstrap launch failed")
	var level: Node = await _wait_for_level()
	_check(level != null, "Chapter IV did not load through MainBootstrap")
	if level == null:
		debug.reset_to_defaults()
		_finish()
		return
	var controller: Chapter04RoomTransitionController = level.get_node("RoomTransitionController") as Chapter04RoomTransitionController
	var player: Player = level.get_node("ChapterRuntime/Player") as Player
	player.hurtbox.set_invulnerable(true)
	for repetition: int in range(10):
		if controller.active_room_id != &"CH4_AREA_03":
			_check(controller._swap_room(&"CH4_AREA_03", &"EntryWest"), "Cycle %d could not reload Broken Chainway" % (repetition + 1))
			await process_frame
		var exit_east: Chapter04RoomExit = controller.active_room.get_node("Transitions/ExitEast") as Chapter04RoomExit
		_check(exit_east.requires_interaction, "Cycle %d exit lost its interaction gate" % (repetition + 1))
		exit_east._on_body_entered(player)
		var event: InputEventAction = InputEventAction.new()
		event.action = &"interact"
		event.pressed = true
		exit_east._unhandled_input(event)
		for _frame: int in range(180):
			await process_frame
			if not controller.is_transitioning() and controller.active_room_id == &"CH4_AREA_04":
				break
		_check(controller.active_room_id == &"CH4_AREA_04", "Cycle %d did not reach CH4_AREA_04" % (repetition + 1))
		_transition_count += 1
	for repetition: int in range(5):
		_check(controller._swap_room(&"CH4_AREA_12", &"EntryWest"), "Checkpoint reload %d could not enter area 12" % (repetition + 1))
		await physics_frame
		var checkpoint: Chapter04Checkpoint = controller.active_room.get_node("Gameplay/Checkpoint") as Chapter04Checkpoint
		var marker: Marker2D = checkpoint.get_node("SpawnMarker") as Marker2D
		checkpoint._on_body_entered(player)
		await process_frame
		_check(controller.respawn_anchor.global_position == marker.global_position, "Checkpoint reload %d did not update respawn anchor" % (repetition + 1))
		_check(controller._swap_room(&"CH4_AREA_11", &"EntryWest"), "Checkpoint reload %d could not leave area 12" % (repetition + 1))
		await process_frame
		_checkpoint_reload_count += 1
	debug.reset_to_defaults()
	unload_current_scene()
	for _frame: int in range(8):
		await process_frame
	_finish()


func _wait_for_level() -> Node:
	for _frame: int in range(480):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print(
			"BROKEN CHAINWAY TRANSITION STRESS | PASS transitions=%d checkpoint_reloads=%d"
			% [_transition_count, _checkpoint_reload_count]
		)
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)
