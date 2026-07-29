extends SceneTree

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const QA_ROOT: String = "res://docs/qa"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		push_error("R5 Main capture requires DebugRunConfig")
		quit(1)
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"chapter_03_start"
	var error: Error = change_scene_to_file(BOOTSTRAP_PATH)
	if error != OK:
		push_error("R5 could not start MainBootstrap: %s" % error_string(error))
		config.reset_to_defaults()
		quit(1)
		return
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		push_error("MainBootstrap did not resolve the formal Chapter III route")
		config.reset_to_defaults()
		quit(1)
		return
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var player: Player = controller.player
	player.set_input_profile(Player.InputProfile.LOCKED)
	if player.hurtbox != null:
		player.hurtbox.set_invulnerable(true)

	_place_player(player, Vector2(1200, 584))
	await _settle()
	await _capture("chapter_03_r5_vestibule_main.png")

	await _change_room(controller, &"CH3_NAVE_ENTRY")
	_place_player(player, Vector2(600, 522))
	await _settle()
	await _capture("chapter_03_r5_nave_platform_combat_main.png")

	await _change_room(controller, &"CH3_CHOIR_GALLERY")
	_place_player(player, Vector2(1808, 402))
	await _stage_attack_frame(player)
	await _capture("chapter_03_r5_choir_platform_combat_main.png")
	player.action_controller.cancel_all_actions()

	await _change_room(controller, &"CH3_BOSS_CHECKPOINT")
	_place_player(player, Vector2(298, 584))
	var checkpoint: Chapter03RoomCheckpoint = controller.active_room.get_node(
		"CheckpointArea"
	) as Chapter03RoomCheckpoint
	checkpoint._on_body_entered(player)
	await _settle()
	await _capture("chapter_03_r5_checkpoint_main.png")

	await _change_room(controller, &"CH3_BOSS_ANTE")
	var gate: Chapter03BossGate = controller.active_room.get_node("BossGate") as Chapter03BossGate
	_place_player(player, Vector2(1222, 584))
	gate._on_trigger_body_entered(player)
	await _settle()
	await _capture("chapter_03_r5_boss_threshold_main.png")

	controller._swap_room(&"CH3_BOSS", &"EntryWest")
	await process_frame
	var boss_room: Chapter03BossSanctumRoom = controller.active_room as Chapter03BossSanctumRoom
	boss_room.sanctum.skip_intro_to_combat_state()
	_place_player(player, Vector2(1180, 584))
	await _settle()
	await _capture("chapter_03_r5_sanctum_boundary_main.png")

	controller._swap_room(&"CH3_POST_BOSS", &"EntryWest")
	await process_frame
	var post_room: Chapter03PostBossRoom = controller.active_room as Chapter03PostBossRoom
	_place_player(player, Vector2(660, 584))
	post_room.reliquary._on_body_entered(player)
	await _settle()
	await _capture("chapter_03_r5_post_boss_reward_boundary_main.png")

	controller._swap_room(&"CH3_UNDERKEEP_DESCENT", &"EntryWest")
	await process_frame
	var underkeep: Chapter03UnderkeepDescent = controller.active_room.get_node(
		"UnderkeepDescent"
	) as Chapter03UnderkeepDescent
	_place_player(player, Vector2(2100, 584))
	await _settle()
	underkeep._on_body_entered(player)
	var interact: InputEventAction = InputEventAction.new()
	interact.action = &"interact"
	interact.pressed = true
	interact.strength = 1.0
	underkeep._unhandled_input(interact)
	assert(underkeep.prompt.text.contains("PLANNED"), "Chapter IV boundary did not explain its planned state")
	await process_frame
	await process_frame
	await _capture("chapter_03_r5_chapter_04_planned_boundary_main.png")

	config.reset_to_defaults()
	print("CH3_R5_MAIN_CAPTURE PASS images=%d formal_route=true" % _captures)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _frame: int in range(360):
		await process_frame
		var route: Chapter03Route = current_scene as Chapter03Route
		if route != null:
			return route
	return null


func _change_room(
	controller: Chapter03RoomTransitionController,
	destination: StringName
) -> void:
	if not controller.request_room_change(destination, &"EntryWest"):
		push_error("R5 capture transition rejected: %s" % destination)
		quit(1)
		return
	for _frame: int in range(180):
		await process_frame
		if controller.active_room_id == destination and not controller.fade_rect.visible:
			return
	push_error("R5 capture transition timeout: %s" % destination)
	quit(1)


func _place_player(player: Player, target: Vector2) -> void:
	player.global_position = target
	player.velocity = Vector2.ZERO
	if player.player_camera != null:
		player.player_camera.reset_smoothing()


func _settle() -> void:
	await create_timer(0.25).timeout
	await process_frame
	await process_frame


func _stage_attack_frame(player: Player) -> void:
	await create_timer(0.05).timeout
	player.action_controller.try_start_actions(true, false, true, 1.0, false)
	await create_timer(0.06).timeout
	await process_frame


func _capture(file_name: String) -> void:
	var image: Image = root.get_viewport().get_texture().get_image()
	var error: Error = image.save_png(QA_ROOT + "/" + file_name)
	assert(error == OK, "Failed to save %s" % file_name)
	_captures += 1
