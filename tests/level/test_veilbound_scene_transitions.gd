extends SceneTree

## Executes real SceneTree changes for the configured Opening -> Catacomb -> Main route.

const OPENING: PackedScene = preload("res://scenes/cinematics/opening_cinematic.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var session: Node = root.get_node_or_null("ChapterSession")
	if session != null and session.has_method("reset_revival_state"):
		session.call("reset_revival_state")
	var opening: OpeningCinematicController = OPENING.instantiate() as OpeningCinematicController
	opening.transition_duration = 0.2
	root.add_child(opening)
	current_scene = opening
	await process_frame
	opening.finish_cinematic(true)
	await _wait_for_scene("VeilboundCatacomb", 90)
	var catacomb: VeilboundCatacombController = current_scene as VeilboundCatacombController
	_expect(catacomb != null, "Opening skip did not load Veilbound Catacomb")
	if catacomb == null:
		_finish()
		return
	catacomb.transition_duration = 0.2
	catacomb.skip_revival_for_test()
	catacomb.collect_daggers_for_test()
	catacomb.open_door_for_test()
	catacomb._on_exit_trigger_body_entered(catacomb.player)
	await _wait_for_scene("Main", 90)
	var main: Node2D = current_scene as Node2D
	_expect(main != null and main.name == "Main", "Catacomb exit did not load Main")
	if main != null:
		_expect(main.has_node("World/DarkForestTutorialSpawn"), "Transitioned Main lacks tutorial spawn")
		_expect(main.has_node("TutorialController"), "Transitioned Main lacks tutorial flow")
	_expect(session != null and bool(session.get("opening_completed")), "Opening completion was not recorded")
	_expect(session != null and bool(session.get("revival_completed")), "Revival completion was not recorded")
	_expect(session != null and bool(session.get("daggers_recovered")), "Dagger recovery was not recorded")
	_expect(session != null and bool(session.get("catacomb_exited")), "Catacomb exit was not recorded")
	if current_scene != null:
		current_scene.queue_free()
	await process_frame
	# Let the scene-local subtitle/tutorial timers expire before leak checking.
	await create_timer(2.6).timeout
	_finish()


func _wait_for_scene(scene_name: String, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.name == scene_name:
			return
	_failures.append("Timed out waiting for scene %s" % scene_name)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("VEILBOUND_SCENE_TRANSITIONS_TEST: PASS (Opening skip -> Catacomb skip -> Main tutorial)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("VEILBOUND_SCENE_TRANSITIONS_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
