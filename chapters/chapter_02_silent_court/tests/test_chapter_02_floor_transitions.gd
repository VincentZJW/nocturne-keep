extends SceneTree

const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_failures.append("DebugRunConfig is missing")
		_finish()
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_FLOOR_1_START"
	var packed: PackedScene = load(LEVEL_PATH) as PackedScene
	var level: SilentCourtLevel = packed.instantiate() as SilentCourtLevel if packed != null else null
	if level == null:
		_failures.append("Unable to instantiate Silent Court")
		_finish()
		return
	root.add_child(level)
	await process_frame
	for child: Node in level.get_node("GameplayWorld/Enemies").find_children("*", "CharacterBody2D", true, false):
		var enemy: CharacterBody2D = child as CharacterBody2D
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		enemy.collision_layer = 0
		enemy.collision_mask = 0
	var controller: Chapter02FloorTransitionController = level.get_node(
		"ChapterSystems/FloorTransitionController"
	) as Chapter02FloorTransitionController
	controller.fade_out_duration = 0.01
	controller.blackout_hold_duration = 0.01
	controller.fade_in_duration = 0.01
	await _verify_transition(
		level,
		controller,
		level.get_node("TransitionAreas/Floor1ToFloor2") as Chapter02FloorTransition,
		&"CH2_FLOOR_2_START",
		Vector2i(-900, -180)
	)
	await _verify_transition(
		level,
		controller,
		level.get_node("TransitionAreas/Floor2ToFloor3") as Chapter02FloorTransition,
		&"CH2_FLOOR_3_START",
		Vector2i(-1800, -1080)
	)
	_expect(_count_players(level) == 1, "Floor transition duplicated Player")
	_expect(_count_stamina_huds(level) == 1, "Floor transition duplicated HUD")
	level.queue_free()
	await process_frame
	config.reset_to_defaults()
	_finish()


func _verify_transition(
	level: SilentCourtLevel,
	controller: Chapter02FloorTransitionController,
	transition: Chapter02FloorTransition,
	destination_id: StringName,
	expected_limits: Vector2i
) -> void:
	var player: Player = level.player
	var destination: Marker2D = level.get_node("PlayerSpawnPoints/%s" % destination_id) as Marker2D
	_expect(controller.request_transition(transition), "Transition did not start: %s" % transition.transition_id)
	_expect(not controller.request_transition(transition), "Transition accepted a duplicate request")
	_expect(player.get_input_profile() == Player.InputProfile.LOCKED, "Player input was not locked")
	_expect(player.hurtbox.is_invulnerable, "Player was not protected during blackout")
	var frames: int = 0
	while controller.is_transitioning() and frames < 120:
		await process_frame
		frames += 1
	_expect(not controller.is_transitioning(), "Transition timed out: %s" % transition.transition_id)
	_expect(
		player.global_position.distance_to(destination.global_position) < 4.0,
		"Wrong destination: %s actual=%s expected=%s velocity=%s life=%s move=%s" % [
			destination_id,
			player.global_position,
			destination.global_position,
			player.velocity,
			player.get_life_state_name(),
			player.get_movement_state_name(),
		]
	)
	_expect(player.get_input_profile() == Player.InputProfile.FULL, "Player input was not restored")
	_expect(not player.hurtbox.is_invulnerable, "Temporary transition invulnerability was not cleared")
	_expect(player.player_camera.limit_top == expected_limits.x, "Camera top mismatch at %s" % destination_id)
	_expect(player.player_camera.limit_bottom == expected_limits.y, "Camera bottom mismatch at %s" % destination_id)


func _count_players(node: Node) -> int:
	var count: int = 1 if node is Player else 0
	for child: Node in node.get_children():
		count += _count_players(child)
	return count


func _count_stamina_huds(node: Node) -> int:
	var count: int = 1 if node is PlayerStaminaHud else 0
	for child: Node in node.get_children():
		count += _count_stamina_huds(child)
	return count


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CH2_FLOOR_TRANSITION_TEST: PASS transitions=2 player=1 hud=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH2_FLOOR_TRANSITION_TEST: %s" % failure)
	quit(1)
