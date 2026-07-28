extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const RUNS: int = 3
const MAX_SEGMENT_FRAMES: int = 900

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 3.0
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_failures.append("missing DebugRunConfig")
		_finish()
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_FLOOR_1_START"
	for run_index: int in range(RUNS):
		if change_scene_to_file(BOOTSTRAP) != OK:
			_failures.append("run %d failed to start Bootstrap" % (run_index + 1))
			break
		var level: SilentCourtLevel = await _wait_for_level()
		if level == null:
			_failures.append("run %d failed to load SilentCourt" % (run_index + 1))
			break
		var player: Player = level.player
		_prepare_route(level, player)
		var elapsed_frames: int = 0
		elapsed_frames += await _move_until(player, &"player_move_right", func() -> bool: return player.global_position.x >= 7000.0 and player.global_position.y <= -250.0)
		elapsed_frames += await _move_until(player, &"player_move_left", func() -> bool: return player.global_position.x <= 260.0 and player.global_position.y <= -1150.0)
		elapsed_frames += await _move_until(player, &"player_move_right", func() -> bool: return player.global_position.x >= 5700.0 and player.global_position.y <= -1150.0)
		if player.global_position.x < 5700.0 or player.global_position.y > -1150.0:
			_failures.append("run %d route incomplete at %s" % [run_index + 1, player.global_position])
			break
		print("CH2_ROUTE_RUN %d PASS simulated=%.2fs final=%s" % [run_index + 1, float(elapsed_frames) * Engine.time_scale / 60.0, player.global_position])
	_finish()


func _prepare_route(level: SilentCourtLevel, player: Player) -> void:
	player.hurtbox.set_invulnerable(true)
	for child: Node in level.get_node("GameplayWorld/Enemies").find_children("*", "CharacterBody2D", true, false):
		var body: CharacterBody2D = child as CharacterBody2D
		body.process_mode = Node.PROCESS_MODE_DISABLED
		body.collision_layer = 0
		body.collision_mask = 0
	var activation: Area2D = level.get_node("GameplayWorld/BossArea/BossActivationArea") as Area2D
	activation.monitoring = false
	var threshold: DuchessBossThresholdTransition = level.get_node(
		"ChapterSystems/DuchessBossThresholdTransition"
	) as DuchessBossThresholdTransition
	threshold.set_enabled_for_test(false)
	var boss: CharacterBody2D = level.get_node("GameplayWorld/BossArea/HollowDuchess") as CharacterBody2D
	boss.process_mode = Node.PROCESS_MODE_DISABLED
	boss.collision_layer = 0
	boss.collision_mask = 0


func _move_until(player: Player, action: StringName, completed: Callable) -> int:
	Input.action_press(action)
	var jump_cooldown: int = 0
	var frame_count: int = 0
	while frame_count < MAX_SEGMENT_FRAMES and not completed.call():
		await physics_frame
		frame_count += 1
		jump_cooldown = maxi(0, jump_cooldown - 1)
		if absf(player.velocity.x) < 12.0 and jump_cooldown == 0:
			Input.action_press(&"player_jump")
			await physics_frame
			Input.action_release(&"player_jump")
			frame_count += 1
			jump_cooldown = 26
	Input.action_release(action)
	if frame_count >= MAX_SEGMENT_FRAMES:
		_failures.append("route segment timed out at %s floor=%s normal=%s slides=%d" % [
			player.global_position, player.is_on_floor(), player.get_floor_normal(), player.get_slide_collision_count(),
		])
		for collision_index: int in range(player.get_slide_collision_count()):
			var collision: KinematicCollision2D = player.get_slide_collision(collision_index)
			print("CH2_ROUTE_COLLISION collider=%s normal=%s position=%s" % [collision.get_collider(), collision.get_normal(), collision.get_position()])
	return frame_count


func _wait_for_level() -> SilentCourtLevel:
	for _frame: int in range(240):
		await process_frame
		var level: SilentCourtLevel = current_scene as SilentCourtLevel
		if level != null:
			return level
	return null


func _finish() -> void:
	Input.action_release(&"player_move_left")
	Input.action_release(&"player_move_right")
	Input.action_release(&"player_jump")
	Engine.time_scale = 1.0
	if _failures.is_empty():
		print("CH2_THREE_FLOOR_ROUTE_TEST: PASS runs=3 softlocks=0")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH2_THREE_FLOOR_ROUTE_TEST: %s" % failure)
	quit(1)
