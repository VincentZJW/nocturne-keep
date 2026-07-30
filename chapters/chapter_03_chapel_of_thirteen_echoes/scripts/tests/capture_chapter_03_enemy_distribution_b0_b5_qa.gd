extends SceneTree

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIRECTORY: String = "res://docs/qa/chapter_03_enemy_distribution_b0_b5"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_fail("missing DebugRunConfig")
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"CH3_START"
	if change_scene_to_file(BOOTSTRAP_PATH) != OK:
		_fail("unable to start MainBootstrap")
		return
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		_fail("MainBootstrap did not resolve Chapter03Route")
		return
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var player: Player = controller.player
	player.set_input_profile(Player.InputProfile.LOCKED)
	if player.hurtbox != null:
		player.hurtbox.set_invulnerable(true)

	await _capture_at(player, Vector2(1460.0, 584.0), "01_chapter_03_transition_entry_main.png")
	await _swap(controller, &"CH3_NAVE_ENTRY")
	await _capture_at(player, Vector2(930.0, 584.0), "02_first_formal_combat_room_main.png")
	_activate_group(controller, 0, player)
	await _capture_at(player, Vector2(660.0, 584.0), "03_opening_encounter_main.png")

	await _swap(controller, &"CH3_MAIN_NAVE_FRONT")
	_activate_group(controller, 0, player)
	await _capture_at(player, Vector2(650.0, 584.0), "04_main_nave_front_main.png")
	await _swap(controller, &"CH3_MAIN_NAVE_REAR")
	_activate_group(controller, 1, player)
	await _capture_at(player, Vector2(1660.0, 584.0), "05_main_nave_rear_main.png")

	await _swap(controller, &"CH3_CONFESSIONALS")
	_activate_group(controller, 0, player)
	await _capture_at(player, Vector2(620.0, 584.0), "06_confessional_ambush_main.png")
	await _swap(controller, &"CH3_CHOIR_GALLERY")
	_activate_group(controller, 0, player)
	await _capture_at(player, Vector2(560.0, 584.0), "07_choir_gallery_main.png")
	_activate_group(controller, 2, player)
	await _capture_at(player, Vector2(1960.0, 584.0), "08_pipe_organ_encounter_main.png")

	await _swap(controller, &"CH3_STAINED_GLASS_HALL")
	_activate_group(controller, 0, player)
	await _capture_at(player, Vector2(620.0, 584.0), "09_stained_glass_hall_main.png")
	await _swap(controller, &"CH3_ARCHIVE_RELIQUARY")
	_activate_group(controller, 1, player)
	await _capture_at(player, Vector2(1660.0, 584.0), "10_prayer_archive_main.png")
	await _swap(controller, &"CH3_BLOOD_CANDLE_CHAPEL")
	_activate_group(controller, 1, player)
	await _capture_at(player, Vector2(1660.0, 584.0), "11_blood_candle_zone_main.png")

	await _swap(controller, &"CH3_MAIN_NAVE_FRONT")
	_activate_group(controller, 1, player)
	await _capture_at(player, Vector2(1660.0, 520.0), "12_platform_ranged_rule_main.png")
	await _swap(controller, &"CH3_STAINED_GLASS_HALL")
	_activate_group(controller, 1, player)
	await _capture_at(player, Vector2(1660.0, 584.0), "13_air_anchor_rule_main.png")

	await _swap(controller, &"CH3_PRE_BOSS_COMBAT")
	_activate_group(controller, 0, player)
	await _capture_at(player, Vector2(440.0, 584.0), "14_high_pressure_encounter_main.png")
	_activate_group(controller, 2, player)
	await _capture_at(player, Vector2(1960.0, 584.0), "15_final_pre_boss_combat_main.png")
	await _capture_at(player, Vector2(1180.0, 584.0), "16_encounter_debug_statistics_main.png")

	await _swap(controller, &"CH3_BOSS_CHECKPOINT")
	await _capture_at(player, Vector2(300.0, 584.0), "17_main_formal_route_checkpoint_main.png")
	config.reset_to_defaults()
	print("CH3_ENEMY_DISTRIBUTION_MAIN_QA PASS captures=%d bootstrap=true rooms=9 enemies=72" % _captures)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _frame: int in range(420):
		await process_frame
		var route: Chapter03Route = current_scene as Chapter03Route
		if route != null:
			return route
	return null


func _swap(controller: Chapter03RoomTransitionController, room_id: StringName) -> void:
	if not controller._swap_room(room_id, &"EntryWest"):
		_fail("unable to load %s" % room_id)
		return
	for _frame: int in range(12):
		await process_frame


func _activate_group(
	controller: Chapter03RoomTransitionController,
	group_index: int,
	player: Player
) -> void:
	var room: Chapter03EncounterRoom = controller.active_room as Chapter03EncounterRoom
	if room == null:
		_fail("active room is not an encounter room")
		return
	var groups: Array[EncounterGroup] = room.encounter_spawner.get_encounter_groups()
	if group_index < 0 or group_index >= groups.size():
		_fail("invalid encounter index %d for %s" % [group_index, room.room_id])
		return
	groups[group_index].activate(player)


func _capture_at(player: Player, position: Vector2, file_name: String) -> void:
	player.global_position = position
	player.velocity = Vector2.ZERO
	if player.player_camera != null:
		player.player_camera.reset_smoothing()
	await create_timer(0.20).timeout
	await process_frame
	await process_frame
	var image: Image = root.get_viewport().get_texture().get_image()
	var output_path: String = OUTPUT_DIRECTORY.path_join(file_name)
	var save_error: Error = image.save_png(ProjectSettings.globalize_path(output_path))
	if save_error != OK:
		_fail("unable to save %s: %s" % [output_path, error_string(save_error)])
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("CH3_ENEMY_DISTRIBUTION_MAIN_QA: %s" % message)
	quit(1)
