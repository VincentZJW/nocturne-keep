extends SceneTree

const BOOTSTRAP: PackedScene = preload("res://scenes/bootstrap/main_bootstrap.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	var session: ChapterSessionState = root.get_node_or_null("ChapterSession") as ChapterSessionState
	_expect(config != null, "DebugRunConfig Autoload is missing")
	_expect(session != null, "ChapterSession Autoload is missing")
	if config == null or session == null:
		_finish()
		return

	config.reset_to_defaults()
	session.mark_opening_completed()
	var formal_bootstrap: MainBootstrap = BOOTSTRAP.instantiate() as MainBootstrap
	formal_bootstrap.auto_start = false
	root.add_child(formal_bootstrap)
	current_scene = formal_bootstrap
	_expect(
		formal_bootstrap.get_selected_start_scene_path() == MainBootstrap.DEFAULT_OPENING_SCENE_PATH,
		"Disabled Debug start did not select Opening"
	)
	formal_bootstrap.start_startup_flow()
	await _wait_for_scene("OpeningCinematic", 30)
	_expect(current_scene is OpeningCinematicController, "Formal Bootstrap did not load Opening")
	_expect(not session.opening_completed, "Formal Bootstrap did not reset Opening story state")
	_expect(not session.is_debug_run, "Formal Bootstrap marked the session as Debug")
	var opening: OpeningCinematicController = current_scene as OpeningCinematicController
	if opening != null:
		var accelerated_timeline: OpeningCinematicTimeline = (
			opening.timeline.duplicate(true) as OpeningCinematicTimeline
		)
		for index: int in range(accelerated_timeline.shot_durations.size()):
			accelerated_timeline.shot_durations[index] = 0.01
		opening.timeline = accelerated_timeline
		opening.transition_duration = 0.01
		opening.show_shot_for_qa(0)
		await _wait_for_scene("VeilboundCatacomb", 180)
		_expect(current_scene is VeilboundCatacombController, "Natural Opening completion did not load Catacomb")
		_expect(session.opening_completed, "Natural Opening completion did not set its story flag")
	if current_scene != null:
		current_scene.queue_free()
	await process_frame

	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_START"
	var debug_bootstrap: MainBootstrap = BOOTSTRAP.instantiate() as MainBootstrap
	debug_bootstrap.auto_start = false
	root.add_child(debug_bootstrap)
	current_scene = debug_bootstrap
	_expect(
		debug_bootstrap.get_selected_start_scene_path() == ChapterRegistry.CHAPTER_02_SCENE_PATH,
		"Enabled Chapter II Debug start did not select Silent Court"
	)
	debug_bootstrap.start_startup_flow()
	await _wait_for_scene("SilentCourt", 60)
	_expect(current_scene is SilentCourtLevel, "Debug Bootstrap did not load Chapter II")
	_expect(session.is_debug_run, "Debug Bootstrap did not mark the runtime session")
	if current_scene != null:
		current_scene.queue_free()
	await process_frame
	config.reset_to_defaults()
	# Allow scene-local Catacomb timers created during the natural transition to expire.
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
		print("MAIN_BOOTSTRAP_FLOW_TEST: PASS (formal Opening + Debug Chapter II)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("MAIN_BOOTSTRAP_FLOW_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
