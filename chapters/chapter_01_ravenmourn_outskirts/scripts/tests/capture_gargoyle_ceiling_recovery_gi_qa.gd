extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL_PATH: String = "res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
const OUTPUT_DIR: String = "res://docs/qa/gargoyle_duchess_gi/main_gargoyle"

var _captures: int = 0
var _debug_label: Label


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_fail("DebugRunConfig is missing")
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS
	config.debug_start_spawn_id = &"CH1_GARGOYLE_HEIGHT_TEST"
	config.debug_skip_chapter_intro = true
	config.debug_reset_chapter_state_on_run = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("MainBootstrap could not start")
		return
	var level: Node2D = await _wait_for_level(480)
	if level == null:
		_fail("Chapter I did not load through MainBootstrap")
		return
	var player: Player = level.get_node_or_null("World/Player") as Player
	var gargoyle: GargoyleSentinel = level.get_node_or_null(
		"World/Encounters/ForestEncounter03/Enemies/ForestGargoyle01"
	) as GargoyleSentinel
	if player == null or gargoyle == null:
		_fail("Formal Player/Gargoyle instance is missing")
		return
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(3370.0, 610.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	gargoyle.set_ai_active(true)
	gargoyle.set_target(player)
	if gargoyle.current_state == gargoyle.DORMANT:
		gargoyle.animated_sprite.animation_finished.emit()
	for _frame: int in range(12):
		await process_frame
	gargoyle.set_physics_process(false)
	_create_debug_overlay(level)

	for cycle: int in range(1, 11):
		gargoyle.cooldown_timer = 0.0
		gargoyle._enter_dive_windup()
		gargoyle._process_windup(gargoyle.config.dive_windup + 0.01)
		_update_debug(gargoyle, cycle, "ATTACK")
		if cycle == 1:
			await _save("01_first_attack_main.png")
		gargoyle.global_position = Vector2(3450.0, gargoyle.world_bounds.get_safe_flight_top_y() - 10.0)
		gargoyle.velocity = Vector2(0.0, -320.0)
		gargoyle._enforce_flight_bounds()
		_update_debug(gargoyle, cycle, "TOP_REACHED")
		if cycle == 1:
			await _save("02_top_reached_main.png")
		gargoyle.global_position = gargoyle.global_position.lerp(gargoyle.return_target, 0.55)
		gargoyle._process_return(0.0)
		_update_debug(gargoyle, cycle, "RETURN")
		if cycle == 1:
			await _save("03_safe_return_main.png")
		gargoyle.global_position = gargoyle.return_target
		gargoyle._process_return(0.0)
		gargoyle._process_hover_recover(gargoyle.config.ceiling_recovery_wait + 0.01)
		_update_debug(gargoyle, cycle, "REACQUIRED")
		if cycle == 1:
			await _save("04_hover_anchor_main.png")
		elif cycle == 2:
			await _save("05_second_attack_ready_main.png")
		elif cycle == 5:
			await _save("06_fifth_cycle_main.png")
		elif cycle == 10:
			await _save("07_tenth_cycle_main.png")

	config.reset_to_defaults()
	print("GARGOYLE_CEILING_GI_CAPTURE: PASS captures=%d cycles=%d top=%d main=%s" % [
		_captures, gargoyle.attack_cycle_count, gargoyle.ceiling_recovery_count, level.scene_file_path,
	])
	current_scene.queue_free()
	current_scene = null
	for _frame: int in range(20):
		await process_frame
	quit(0)


func _wait_for_level(maximum_frames: int) -> Node2D:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL_PATH:
			return current_scene as Node2D
	return null


func _create_debug_overlay(level: Node) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 130
	level.add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(320.0, 92.0)
	panel.custom_minimum_size = Vector2(640.0, 54.0)
	layer.add_child(panel)
	_debug_label = Label.new()
	_debug_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_debug_label.add_theme_font_size_override("font_size", 12)
	panel.add_child(_debug_label)


func _update_debug(gargoyle: GargoyleSentinel, cycle: int, event_name: String) -> void:
	_debug_label.text = "CH1_GARGOYLE_HEIGHT_TEST | %s | LOOP %02d\n%s" % [event_name, cycle, gargoyle.get_debug_summary()]


func _save(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var path: String = "%s/%s" % [OUTPUT_DIR, file_name]
	if root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("Could not save %s" % path)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("GARGOYLE_CEILING_GI_CAPTURE: %s" % message)
	quit(1)
