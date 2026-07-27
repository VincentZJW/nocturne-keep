extends SceneTree

## Captures the configured F5 route: MainBootstrap -> Chapter II -> CH2_BOSS.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
const OUTPUT_DIR: String = "res://docs/qa/chapter_02_hollow_duchess"

var _capture_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var debug_config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug_config == null:
		_fail("missing DebugRunConfig")
		return
	debug_config.debug_chapter_start_enabled = true
	debug_config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	debug_config.debug_start_spawn_id = &"CH2_BOSS"
	debug_config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("could not start MainBootstrap")
		return
	var level: Node = await _wait_for_level()
	if level == null:
		_fail("SilentCourt did not load through MainBootstrap")
		return
	var player: Player = level.get_node_or_null("ChapterRuntime/Player") as Player
	var boss: HollowDuchess = level.get_node_or_null("BossArea/HollowDuchess") as HollowDuchess
	var controller: HollowDuchessRoomController = level.get_node_or_null(
		"ChapterSystems/HollowDuchessRoomController"
	) as HollowDuchessRoomController
	if player == null or boss == null or controller == null:
		_fail("Main Boss composition is incomplete")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(28160.0, 584.0)
	player.velocity = Vector2.ZERO
	await _wait_physics_frames(4)
	if not controller.encounter_started:
		controller._on_activation_body_entered(player)
	player.global_position = Vector2(30620.0, 584.0)
	player.player_camera.reset_smoothing()
	await _wait_process_frames(8)
	_save_viewport("01_intro_main.png")
	await _wait_for_state(boss, &"Idle", 420)

	await _capture_attack(boss, player, &"rapier_thrust", &"RapierThrustActive", "02_rapier_thrust_main.png")
	await _capture_attack(boss, player, &"fan_slash", &"FanSlashActive", "03_fan_slash_main.png")
	await _capture_attack(boss, player, &"backstep_riposte", &"BackstepRiposteActive", "04_backstep_riposte_main.png")
	await _capture_attack(boss, player, &"side_step_cut", &"SideStepCutActive", "05_side_step_cut_main.png")

	boss.debug_set_health(121)
	await _wait_for_state(boss, &"PhaseTransition", 240)
	await _wait_process_frames(12)
	await _save_frozen_boss_frame(boss, "06_phase_transition_main.png")
	await _wait_for_phase(boss, 2, 240)
	await _capture_attack(boss, player, &"double_waltz_lunge", &"DoubleLungeHit1", "07_double_waltz_main.png")
	await _capture_attack(boss, player, &"phantom_dancer_sweep", &"PhantomDanceActive", "08_phantom_dance_main.png")

	boss.debug_set_health(50)
	await _capture_attack(boss, player, &"final_waltz_crossing", &"FinalWaltzActive", "09_final_waltz_main.png")
	boss.debug_set_health(0)
	await _wait_for_state(boss, &"Death", 120)
	await _wait_process_frames(24)
	await _save_frozen_boss_frame(boss, "10_death_main.png")
	debug_config.reset_to_defaults()
	print("HOLLOW_DUCHESS_MAIN_QA: PASS captures=%d main=%s" % [_capture_count, level.scene_file_path])
	quit(0)


func _capture_attack(
	boss: HollowDuchess,
	player: Player,
	attack_name: StringName,
	active_state: StringName,
	file_name: String
) -> void:
	player.global_position = boss.global_position + Vector2(-96.0, -28.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	await _wait_process_frames(3)
	if not boss.debug_force_attack(attack_name):
		_fail("could not force %s" % attack_name)
		return
	if not await _wait_for_state(boss, active_state, 360):
		_fail("%s never reached %s" % [attack_name, active_state])
		return
	await _save_frozen_boss_frame(boss, file_name)
	await _wait_for_attack_end(boss, 360)


func _save_frozen_boss_frame(boss: HollowDuchess, file_name: String) -> void:
	boss.set_physics_process(false)
	# The viewport texture lags one rendered frame behind the scene tree.
	await _wait_process_frames(2)
	_save_viewport(file_name)
	boss.set_physics_process(true)


func _wait_for_level() -> Node:
	for _frame: int in range(240):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL_PATH:
			return current_scene
	return null


func _wait_for_state(boss: HollowDuchess, state_name: StringName, frames: int) -> bool:
	for _frame: int in range(frames):
		await physics_frame
		if boss.get_state_name() == state_name:
			return true
	return false


func _wait_for_phase(boss: HollowDuchess, phase: int, frames: int) -> bool:
	for _frame: int in range(frames):
		await physics_frame
		if boss.get_phase() == phase:
			return true
	return false


func _wait_for_attack_end(boss: HollowDuchess, frames: int) -> void:
	for _frame: int in range(frames):
		await physics_frame
		if boss.get_current_attack().is_empty():
			return


func _wait_process_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _wait_physics_frames(count: int) -> void:
	for _frame: int in range(count):
		await physics_frame


func _save_viewport(file_name: String) -> void:
	var output: String = "%s/%s" % [OUTPUT_DIR, file_name]
	var image: Image = root.get_texture().get_image()
	var save_error: Error = image.save_png(ProjectSettings.globalize_path(output))
	if save_error != OK:
		_fail("failed to save %s" % output)
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("HOLLOW_DUCHESS_MAIN_QA: %s" % message)
	quit(1)
