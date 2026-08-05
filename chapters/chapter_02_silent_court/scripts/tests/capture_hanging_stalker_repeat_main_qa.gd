extends SceneTree

## MainBootstrap proof that a Hanging Stalker re-arms after returning to its
## ceiling anchor while the same Player remains inside the encounter.

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
const OUTPUT_DIR: String = "res://docs/qa/cross_chapter_critical_bugfix/chapter_02_main"
const STALKER_PATH: NodePath = NodePath(
	"GameplayWorld/Enemies/EncounterE08/EncounterE08_01_HangingStalker"
)

var _capture_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_fail("missing DebugRunConfig")
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_START"
	config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP_PATH) != OK:
		_fail("could not launch MainBootstrap")
		return
	var level: SilentCourtLevel = await _wait_for_level()
	if level == null:
		_fail("Silent Court did not load through MainBootstrap")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var player: Player = level.get_node(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player"
	) as Player
	var stalker: HangingStalker = level.get_node_or_null(STALKER_PATH) as HangingStalker
	if player == null or stalker == null:
		_fail("formal EncounterE08 player or Hanging Stalker is missing")
		return
	player.hurtbox.set_invulnerable(true)
	# Keep the actor on the authored upper-platform height so the formal
	# DetectionArea, rather than a test-only direct target assignment, engages.
	player.global_position = Vector2(5780.0, -510.0)
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	level.configure_camera_for_world_y(player.global_position.y)
	player.player_camera.reset_smoothing()
	if not await _wait_for_state(stalker, HangingStalker.ALERT_TELEGRAPH, 240):
		_fail("first telegraph did not start")
		return
	await _save("01_hanging_stalker_first_telegraph_main.png")
	var attack_cycle: int = 1
	var previous_state: StringName = stalker.get_state_name()
	var captured_return: bool = false
	for _frame: int in range(3200):
		await physics_frame
		var current_state: StringName = stalker.get_state_name()
		if current_state == HangingStalker.RETURN_TO_ANCHOR and not captured_return:
			captured_return = true
			await _save("02_hanging_stalker_return_to_ceiling_main.png")
		if current_state == HangingStalker.ALERT_TELEGRAPH and previous_state != current_state:
			attack_cycle += 1
			if attack_cycle == 2:
				await _save("03_hanging_stalker_second_telegraph_main.png")
			if attack_cycle < 5:
				previous_state = stalker.get_state_name()
				continue
			await _save("04_hanging_stalker_fifth_telegraph_main.png")
			config.reset_to_defaults()
			print(
				"CH2 HANGING STALKER MAIN QA | PASS captures=%d attack_cycles=%d ceiling_y=%.1f"
				% [_capture_count, attack_cycle, stalker.ceiling_anchor.y]
			)
			call_deferred("_clean_exit", 0)
			return
		previous_state = current_state
	_fail("Hanging Stalker did not complete five attack cycles within 3200 physics frames")


func _wait_for_level() -> SilentCourtLevel:
	for _frame: int in range(480):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL_PATH:
			return current_scene as SilentCourtLevel
	return null


func _wait_for_state(stalker: HangingStalker, state: StringName, frame_limit: int) -> bool:
	for _frame: int in range(frame_limit):
		await physics_frame
		if stalker.get_state_name() == state:
			return true
	return false


func _save(file_name: String) -> void:
	for _frame: int in range(4):
		await process_frame
	var image: Image = root.get_texture().get_image()
	var path: String = OUTPUT_DIR.path_join(file_name)
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_fail("could not save %s: %s" % [path, error_string(error)])
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("CH2 HANGING STALKER MAIN QA | %s" % message)
	call_deferred("_clean_exit", 1)


func _clean_exit(code: int) -> void:
	# Release the formal Main tree synchronously after the capture coroutine has
	# returned. Silent Court preloads its outbound transition asynchronously, so
	# first let that request settle instead of orphaning its result during exit.
	for _frame: int in range(120):
		await process_frame
	if current_scene != null:
		current_scene.free()
		current_scene = null
	for _frame: int in range(30):
		await process_frame
	quit(code)
