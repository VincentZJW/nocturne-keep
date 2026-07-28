extends SceneTree

## Graphical frame-time probe for the exact MainBootstrap Chapter II route.
## It is intentionally deterministic and produces measurements rather than feel claims.

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var debug_config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug_config == null:
		_fail("missing DebugRunConfig")
		return
	debug_config.debug_chapter_start_enabled = true
	debug_config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	debug_config.debug_start_spawn_id = &"CH2_START"
	debug_config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP_PATH) != OK:
		_fail("could not start MainBootstrap")
		return
	var level: Node = await _wait_for_scene_path(LEVEL_PATH, 360)
	if level == null:
		_fail("SilentCourt did not load through MainBootstrap")
		return
	var player: Player = level.get_node_or_null(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player"
	) as Player
	var floor_controller: Chapter02FloorTransitionController = level.get_node_or_null(
		"ChapterSystems/FloorTransitionController"
	) as Chapter02FloorTransitionController
	var first_transition: Chapter02FloorTransition = level.get_node_or_null(
		"TransitionAreas/Floor1ToFloor2"
	) as Chapter02FloorTransition
	var second_transition: Chapter02FloorTransition = level.get_node_or_null(
		"TransitionAreas/Floor2ToFloor3"
	) as Chapter02FloorTransition
	var room_controller: HollowDuchessRoomController = level.get_node_or_null(
		"ChapterSystems/HollowDuchessRoomController"
	) as HollowDuchessRoomController
	var boss: HollowDuchess = level.get_node_or_null(
		"GameplayWorld/BossArea/HollowDuchess"
	) as HollowDuchess
	var reward_controller: Chapter02To03TransitionController = level.get_node_or_null(
		"ChapterSystems/Chapter02To03TransitionController"
	) as Chapter02To03TransitionController
	var gate: BallroomMirrorGate = level.get_node_or_null(
		"GameplayWorld/BossArea/BallroomMirrorGate"
	) as BallroomMirrorGate
	if (
		player == null or floor_controller == null or first_transition == null
		or second_transition == null or room_controller == null or boss == null
		or reward_controller == null or gate == null
	):
		_fail("Chapter II benchmark composition is incomplete")
		return
	player.hurtbox.set_invulnerable(true)
	_measure_passage_instantiation(reward_controller.transition_data.passage_scene_path)
	for _frame: int in range(30):
		await process_frame
	await _sample_fixed("floor_1_idle", 120)
	if not floor_controller.request_transition(first_transition):
		_fail("floor 1 transition did not start")
		return
	await _sample_until("floor_1_to_2", func() -> bool: return not floor_controller.is_transitioning(), 180)
	if not floor_controller.request_transition(second_transition):
		_fail("floor 2 transition did not start")
		return
	await _sample_until("floor_2_to_3", func() -> bool: return not floor_controller.is_transitioning(), 180)
	player.global_position = Vector2(3800.0, -1216.0)
	player.velocity = Vector2.ZERO
	if player.player_camera != null:
		player.player_camera.reset_smoothing()
	room_controller._on_activation_body_entered(player)
	await _sample_until(
		"boss_intro",
		func() -> bool: return room_controller.encounter_started and boss.get_state_name() == &"Idle",
		600
	)
	boss.debug_set_health(121)
	await _sample_until(
		"phase_1_to_2",
		func() -> bool: return boss.get_phase() == 2 and boss.get_state_name() == &"Idle",
		600
	)
	boss.debug_set_health(0)
	await _sample_until(
		"boss_death_to_reliquary",
		func() -> bool: return reward_controller.get_reward_pickup() != null,
		720
	)
	var reward: WeaponPickup = reward_controller.get_reward_pickup()
	if reward == null or not reward.collect():
		_fail("reliquary reward could not be collected")
		return
	await _sample_until("reliquary_to_mirror", func() -> bool: return gate.is_revealed(), 360)
	gate.passage_requested.emit()
	await _sample_until(
		"chapter_2_to_passage",
		func() -> bool:
			var manager: SceneTransitionManagerState = root.get_node(
				"SceneTransitionManager"
			) as SceneTransitionManagerState
			return (
				current_scene != null and current_scene is RoyalChapelPassage
				and not manager.is_transitioning()
			),
		420
	)
	var passage: RoyalChapelPassage = current_scene as RoyalChapelPassage
	if passage == null:
		_fail("RoyalChapelPassage did not load")
		return
	passage.debug_enter_chapter_three()
	await _sample_until(
		"passage_to_chapter_3",
		func() -> bool: return current_scene is Chapter03EntryPlaceholder,
		420
	)
	var transition_manager: SceneTransitionManagerState = root.get_node(
		"SceneTransitionManager"
	) as SceneTransitionManagerState
	await _sample_until(
		"incremental_scene_retirement",
		func() -> bool: return not transition_manager.is_scene_retirement_in_progress(),
		420
	)
	debug_config.reset_to_defaults()
	print("CH2_STAGE_A_BENCHMARK: PASS")
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
		for _frame: int in range(8):
			await process_frame
	quit(0)


func _sample_fixed(label: String, frame_count: int) -> void:
	var wall_samples: Array[float] = []
	var process_samples: Array[float] = []
	var previous_us: int = Time.get_ticks_usec()
	for _frame: int in range(frame_count):
		await process_frame
		var now_us: int = Time.get_ticks_usec()
		wall_samples.append(float(now_us - previous_us) / 1000.0)
		process_samples.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
		previous_us = now_us
	_print_metric(label, wall_samples, process_samples)


func _sample_until(label: String, finished: Callable, maximum_frames: int) -> void:
	var wall_samples: Array[float] = []
	var process_samples: Array[float] = []
	var previous_us: int = Time.get_ticks_usec()
	for _frame: int in range(maximum_frames):
		await process_frame
		var now_us: int = Time.get_ticks_usec()
		wall_samples.append(float(now_us - previous_us) / 1000.0)
		process_samples.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
		previous_us = now_us
		if finished.call():
			break
	_print_metric(label, wall_samples, process_samples)


func _print_metric(label: String, wall_samples: Array[float], process_samples: Array[float]) -> void:
	if wall_samples.is_empty():
		print("CH2_STAGE_A_METRIC %s samples=0" % label)
		return
	var wall_sorted: Array[float] = wall_samples.duplicate()
	var process_sorted: Array[float] = process_samples.duplicate()
	wall_sorted.sort()
	process_sorted.sort()
	var over_25_ms: int = 0
	for value: float in wall_samples:
		if value > 25.0:
			over_25_ms += 1
	print(
		"CH2_STAGE_A_METRIC %s frames=%d wall_avg=%.3f wall_p95=%.3f wall_max=%.3f over25=%d cpu_p95=%.3f cpu_max=%.3f"
		% [
			label,
			wall_samples.size(),
			_average(wall_samples),
			_percentile(wall_sorted, 0.95),
			wall_sorted[wall_sorted.size() - 1],
			over_25_ms,
			_percentile(process_sorted, 0.95),
			process_sorted[process_sorted.size() - 1],
		]
	)


func _average(values: Array[float]) -> float:
	var total: float = 0.0
	for value: float in values:
		total += value
	return total / float(values.size())


func _measure_passage_instantiation(scene_path: String) -> void:
	var packed: PackedScene = ResourceLoader.load(scene_path, "PackedScene") as PackedScene
	if packed == null:
		print("CH2_STAGE_A_INSTANTIATE passage=FAILED")
		return
	var start_us: int = Time.get_ticks_usec()
	var instance: Node = packed.instantiate()
	var elapsed_ms: float = float(Time.get_ticks_usec() - start_us) / 1000.0
	print("CH2_STAGE_A_INSTANTIATE passage_ms=%.3f" % elapsed_ms)
	instance.free()


func _percentile(sorted_values: Array[float], percentile: float) -> float:
	var index: int = clampi(int(ceil(float(sorted_values.size()) * percentile)) - 1, 0, sorted_values.size() - 1)
	return sorted_values[index]


func _wait_for_scene_path(path: String, maximum_frames: int) -> Node:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == path:
			return current_scene
	return null


func _fail(message: String) -> void:
	push_error("CH2_STAGE_A_BENCHMARK: %s" % message)
	quit(1)
