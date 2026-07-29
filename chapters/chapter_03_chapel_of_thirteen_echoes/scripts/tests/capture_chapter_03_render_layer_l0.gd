extends SceneTree

## Read-only visual evidence for the Chapter III L0 layer audit. The runner enters
## the real MainBootstrap route, moves the persistent Player to four suspect
## overlaps, and saves the current rendered result without changing scene data.

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIRECTORY: String = "res://docs/qa/chapter_03_render_layer_l0"

var _capture_count: int = 0


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
	config.debug_start_spawn_id = &"chapter_03_start"
	if change_scene_to_file(BOOTSTRAP_PATH) != OK:
		_fail("unable to load MainBootstrap")
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
	await _place_and_capture(player, Vector2(1468, 584), "01_vestibule_nave_door_current.png")
	if not await _swap_and_wait(controller, &"CH3_NAVE_ENTRY"):
		return
	await _place_and_capture(player, Vector2(2180, 584), "05_nave_choir_door_extra.png")
	if not await _swap_and_wait(controller, &"CH3_CHOIR_GALLERY"):
		return
	await _place_and_capture(player, Vector2(2304, 584), "06_choir_checkpoint_door_extra.png")
	if not await _swap_and_wait(controller, &"CH3_BOSS_CHECKPOINT"):
		return
	await _place_and_capture(player, Vector2(298, 584), "02_last_vigil_checkpoint_current.png")
	await _place_and_capture(player, Vector2(790, 584), "07_checkpoint_confession_door_extra.png")
	if not await _swap_and_wait(controller, &"CH3_BOSS_ANTE"):
		return
	await _place_and_capture(player, Vector2(214, 584), "03_thirteen_confessions_checkpoint_current.png")
	await _place_and_capture(player, Vector2(1472, 584), "04_thirteenth_echo_gate_current.png")
	if not await _swap_and_wait(controller, &"CH3_UNDERKEEP_DESCENT"):
		return
	await _place_and_capture(player, Vector2(1040, 584), "08_underkeep_shallow_water_extra.png")
	config.reset_to_defaults()
	print("CH3_LAYER_L0_CAPTURE PASS captures=%d main_bootstrap=true" % _capture_count)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _frame: int in range(420):
		await process_frame
		var route: Chapter03Route = current_scene as Chapter03Route
		if route != null:
			return route
	return null


func _swap_and_wait(
	controller: Chapter03RoomTransitionController,
	room_id: StringName
) -> bool:
	if not controller._swap_room(room_id, &"EntryWest"):
		_fail("unable to load room %s" % room_id)
		return false
	for _frame: int in range(12):
		await process_frame
	return true


func _place_and_capture(player: Player, target: Vector2, file_name: String) -> void:
	player.global_position = target
	player.velocity = Vector2.ZERO
	if player.player_camera != null:
		player.player_camera.reset_smoothing()
	for _frame: int in range(12):
		await process_frame
	var image: Image = root.get_texture().get_image()
	var path: String = OUTPUT_DIRECTORY.path_join(file_name)
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_fail("unable to save %s: %s" % [path, error_string(error)])
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("CH3_LAYER_L0_CAPTURE: %s" % message)
	quit(1)
