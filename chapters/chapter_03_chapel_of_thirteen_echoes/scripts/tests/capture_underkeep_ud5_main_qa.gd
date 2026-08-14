extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const CH4: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const OUTPUT: String = "res://docs/qa/chapter_03_underkeep_descent"

var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null:
		return _fail("missing DebugRunConfig")
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	debug.debug_start_spawn_id = &"CH3_UNDERKEEP_DESCENT"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		return _fail("MainBootstrap failed")
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		return _fail("formal Chapter III route did not load")
	var controller: Chapter03RoomTransitionController = route.transition_controller
	if controller.active_room_id != &"CH3_UNDERKEEP_DESCENT":
		return _fail("Main did not enter CH3_UNDERKEEP_DESCENT")
	var player: Player = controller.player
	var area: Chapter03UnderkeepDescent = controller.active_room.get_node("UnderkeepDescent") as Chapter03UnderkeepDescent
	player.hurtbox.set_invulnerable(true)
	_place_player(player, Vector2(330, 584))
	await _settle(18)
	_save("01_main_placeholder_location_recomposed.png")
	await _frames(10)
	_save("02_main_water_animation_frame_a.png")
	await _frames(12)
	_save("03_main_water_animation_frame_b.png")
	_place_player(player, Vector2(1050, 584))
	await _settle(10)
	area._on_water_body_entered(player)
	_save("04_main_shallow_water_idle.png")
	player.velocity.x = 150.0
	area._process(0.26)
	await _frames(2)
	_save("05_main_shallow_water_run_step.png")
	player.velocity = Vector2.ZERO
	area._on_player_landed()
	await _frames(2)
	_save("06_main_landing_ripple.png")
	player.action_controller.try_start_actions(false, true, true, 1.0, false)
	area._on_player_animation_changed(&"dash_loop")
	await _frames(2)
	_save("07_main_ground_dash_splash.png")
	player.action_controller.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	area._on_player_jump_performed(false)
	await _frames(2)
	_save("08_main_jump_takeoff_splash.png")
	player.action_controller.try_start_actions(true, false, true, 0.0, false)
	await _frames(2)
	_save("09_main_normal_attack_in_water.png")
	player.action_controller.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	player.stamina_component.reset_to_full()
	player.action_controller.try_start_actions(true, true, true, 1.0, false)
	area._on_player_animation_changed(&"dash_attack")
	await _frames(2)
	_save("10_main_dash_attack_in_water.png")
	player.action_controller.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	var drip: UnderkeepDripPoint = area.get_node("DripPoint02") as UnderkeepDripPoint
	drip._release_drop()
	await _frames(10)
	_save("11_main_drip_falling.png")
	await _frames(28)
	_save("12_main_drip_impact_ripple.png")
	_place_player(player, Vector2(1880, 584))
	await _settle(16)
	_save("13_main_half_submerged_props.png")
	debug_collisions_hint = true
	await _frames(3)
	_save("14_main_visible_collision_shapes.png")
	debug_collisions_hint = false
	_place_player(player, Vector2(2150, 584))
	await _settle(8)
	area._on_exit_body_entered(player)
	await _frames(2)
	_save("15_main_chapter_four_prompt.png")
	var interaction := InputEventAction.new()
	interaction.action = &"interact"
	interaction.pressed = true
	interaction.strength = 1.0
	area._unhandled_input(interaction)
	var manager: SceneTransitionManagerState = root.get_node("SceneTransitionManager") as SceneTransitionManagerState
	for _index: int in range(120):
		await process_frame
		if manager.get_fade_alpha() >= 0.50:
			break
	_save("16_main_fade_out.png")
	var chapter_four: DrownedUnderkeepRoute = await _wait_for_chapter_four()
	if chapter_four == null:
		return _fail("formal fade did not reach Chapter IV threshold")
	_save("17_main_chapter_four_fade_in.png")
	await _settle(12)
	_save("18_main_chapter_four_threshold.png")
	debug.reset_to_defaults()
	print("UNDERKEEP_UD5_MAIN_QA PASS captures=%d main_bootstrap=true water_fx=true chapter4=true" % _captures)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _index: int in range(900):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE:
			return current_scene as Chapter03Route
	return null


func _wait_for_chapter_four() -> DrownedUnderkeepRoute:
	for _index: int in range(900):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == CH4:
			return current_scene as DrownedUnderkeepRoute
	return null


func _place_player(player: Player, position_value: Vector2) -> void:
	player.global_position = position_value
	player.velocity = Vector2.ZERO
	if player.player_camera != null:
		player.player_camera.reset_smoothing()


func _settle(frame_count: int) -> void:
	await _frames(frame_count)
	await create_timer(0.08).timeout


func _frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


func _save(file_name: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path("%s/%s" % [OUTPUT, file_name]))
	if error != OK:
		_fail("cannot save %s" % file_name)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("UNDERKEEP_UD5_MAIN_QA %s" % message)
	quit(1)
