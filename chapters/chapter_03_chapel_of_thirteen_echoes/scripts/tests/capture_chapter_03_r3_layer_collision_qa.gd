extends SceneTree

const BOOTSTRAP := "res://scenes/bootstrap/main_bootstrap.tscn"
const QA_ROOT := "res://docs/qa"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var collision_capture: bool = OS.has_environment("CH3_R3_COLLISION_CAPTURE")
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		push_error("R3 capture requires DebugRunConfig")
		quit(1)
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"chapter_03_start"
	var error: Error = change_scene_to_file(BOOTSTRAP)
	if error != OK:
		push_error("Unable to load MainBootstrap for R3 capture: %s" % error_string(error))
		quit(1)
		return
	await create_timer(1.0).timeout
	var route: Chapter03Route = current_scene as Chapter03Route
	if route == null:
		push_error("MainBootstrap did not route to Chapter03Route")
		config.reset_to_defaults()
		quit(1)
		return
	var controller: Chapter03RoomTransitionController = route.get_node("RoomTransitionController")
	var player: Player = controller.player
	debug_collisions_hint = false
	player.set_input_profile(Player.InputProfile.LOCKED)
	if player.hurtbox != null:
		player.hurtbox.set_invulnerable(true)
	_place_player(player, Vector2(1700, 604))
	await create_timer(0.25).timeout
	if collision_capture:
		await _capture("chapter_03_r3_stair_visible_collisions_main.png")
	else:
		await _capture("chapter_03_r3_vestibule_stair_main.png")

	controller.request_room_change(&"CH3_NAVE_ENTRY", &"EntryWest")
	await create_timer(0.8).timeout
	_place_player(player, Vector2(600, 522))
	await create_timer(0.25).timeout
	if not collision_capture:
		await _capture("chapter_03_r3_nave_platform_main.png")

	controller.request_room_change(&"CH3_CHOIR_GALLERY", &"EntryWest")
	await create_timer(0.8).timeout
	_place_player(player, Vector2(1808, 402))
	await create_timer(0.25).timeout
	if collision_capture:
		await _capture("chapter_03_r3_visible_collisions_main.png")
	else:
		await _capture("chapter_03_r3_choir_layers_main.png")
	config.reset_to_defaults()
	print(
		"CH3_R3_CAPTURE PASS mode=%s main_route=true"
		% ("visible_collisions" if collision_capture else "normal")
	)
	quit()


func _place_player(player: Player, target: Vector2) -> void:
	player.global_position = target
	player.velocity = Vector2.ZERO
	if player.player_camera != null:
		player.player_camera.reset_smoothing()


func _capture(file_name: String) -> void:
	await process_frame
	await process_frame
	var image: Image = root.get_viewport().get_texture().get_image()
	var path: String = QA_ROOT + "/" + file_name
	var error: Error = image.save_png(path)
	assert(error == OK, "Failed to save %s" % path)
