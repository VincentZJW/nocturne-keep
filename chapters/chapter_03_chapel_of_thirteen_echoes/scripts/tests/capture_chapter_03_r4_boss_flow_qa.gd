extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const QA_ROOT: String = "res://docs/qa"

var _capture_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		push_error("R4 capture requires DebugRunConfig")
		quit(1)
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"CH3_BOSS_CHECKPOINT"
	var error: Error = change_scene_to_file(BOOTSTRAP)
	if error != OK:
		push_error("Unable to load MainBootstrap for R4 capture: %s" % error_string(error))
		config.reset_to_defaults()
		quit(1)
		return
	await create_timer(1.0).timeout
	var route: Chapter03Route = current_scene as Chapter03Route
	if route == null:
		push_error("MainBootstrap did not resolve to Chapter03Route")
		config.reset_to_defaults()
		quit(1)
		return
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var player: Player = controller.player
	player.set_input_profile(Player.InputProfile.LOCKED)
	_place_player(player, Vector2(298, 584))
	await create_timer(0.3).timeout
	await _capture("chapter_03_r4_checkpoint_main.png")

	controller.request_room_change(&"CH3_BOSS_ANTE", &"EntryWest")
	await create_timer(0.75).timeout
	var gate: Chapter03BossGate = controller.active_room.get_node("BossGate") as Chapter03BossGate
	_place_player(player, Vector2(1222, 584))
	gate._on_trigger_body_entered(player)
	await create_timer(0.25).timeout
	await _capture("chapter_03_r4_boss_gate_prompt_main.png")
	gate.run_sequence_for_player(player)
	await create_timer(0.48).timeout
	await _capture("chapter_03_r4_boss_gate_ritual_main.png")

	var timeout: float = 0.0
	while controller.active_room_id != &"CH3_BOSS" and timeout < 4.0:
		await create_timer(0.05).timeout
		timeout += 0.05
	if controller.active_room_id != &"CH3_BOSS":
		push_error("R4 capture did not reach Boss Sanctum")
		config.reset_to_defaults()
		quit(1)
		return
	var sanctum: Chapter03BossSanctum = controller.active_room.get_node(
		"BossSanctum"
	) as Chapter03BossSanctum
	timeout = 0.0
	while not sanctum.boss_title.visible and timeout < 5.0:
		await create_timer(0.05).timeout
		timeout += 0.05
	await create_timer(0.22).timeout
	await _capture("chapter_03_r4_boss_intro_title_main.png")
	while not sanctum.is_intro_complete() and timeout < 8.0:
		await create_timer(0.05).timeout
		timeout += 0.05
	_place_player(player, Vector2(1180, 584))
	await create_timer(0.3).timeout
	await _capture("chapter_03_r4_sanctum_main.png")
	config.reset_to_defaults()
	print("CH3_R4_CAPTURE PASS images=%d route=MainBootstrap" % _capture_count)
	quit(0)


func _place_player(player: Player, target: Vector2) -> void:
	player.global_position = target
	player.velocity = Vector2.ZERO
	if player.player_camera != null:
		player.player_camera.reset_smoothing()


func _capture(file_name: String) -> void:
	await process_frame
	await process_frame
	var image: Image = root.get_viewport().get_texture().get_image()
	var error: Error = image.save_png(QA_ROOT + "/" + file_name)
	assert(error == OK, "Failed to save %s" % file_name)
	_capture_count += 1
