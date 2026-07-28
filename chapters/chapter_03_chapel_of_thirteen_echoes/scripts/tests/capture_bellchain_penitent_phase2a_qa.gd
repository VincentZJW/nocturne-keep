extends SceneTree

## Captures the same Bootstrap -> Chapter III route used by F5.

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn"
)
const OUTPUT_DIR: String = "res://docs/qa/chapter_03_enemy_phase_02a"

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
	debug_config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	debug_config.debug_start_spawn_id = &"CH3_BELLCHAIN_TEST"
	debug_config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP_PATH) != OK:
		_fail("could not launch MainBootstrap")
		return
	var level: Node = await _wait_for_level()
	if level == null:
		_fail("Chapter III did not load through MainBootstrap")
		return
	var player: Player = level.get_node_or_null(
		"GameplayWorld/ChapterRuntime/Player"
	) as Player
	var encounter: EncounterGroup = level.get_node_or_null(
		"GameplayWorld/Phase2AEncounter"
	) as EncounterGroup
	var enemy: BellchainPenitent = level.get_node_or_null(
		"GameplayWorld/Phase2AEncounter/Enemies/BellchainPenitent"
	) as BellchainPenitent
	if player == null or encounter == null or enemy == null:
		_fail("Chapter III Phase2A Main composition incomplete")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(970, 584)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	encounter.activate(player)
	enemy.set_target(player)
	await _wait_process_frames(8)
	_save_viewport("01_bellchain_solo_encounter_main.png")

	await _capture_action(
		enemy, &"chain_lash", 11, 0.42, 0.12, 0.52,
		&"chain_lashActive", "02_chain_lash_active_main.png"
	)
	await _capture_action(
		enemy, &"bell_slam", 13, 0.62, 0.14, 0.76,
		&"bell_slamActive", "03_bell_slam_active_main.png"
	)
	await _capture_action(
		enemy, &"chain_pull", 8, 0.48, 0.10, 0.60,
		&"chain_pullActive", "04_short_chain_pull_active_main.png"
	)
	var dash_hit: HitboxComponent = HitboxComponent.new()
	dash_hit.attack_kind = &"dash_attack"
	enemy._on_hit_resolving(dash_hit)
	enemy._on_hit_resolving(dash_hit)
	dash_hit.free()
	await _wait_for_state(enemy, &"Stagger", 12)
	await _capture_frozen(enemy, "05_poise_stagger_main.png")

	debug_config.reset_to_defaults()
	print(
		(
			"BELLCHAIN_PHASE2A_MAIN_QA: PASS captures=%d route=MainBootstrap "
			+ "spawn=CH3_BELLCHAIN_TEST attacks=3 stagger=1 main=%s"
		)
		% [_capture_count, level.scene_file_path]
	)
	quit(0)


func _capture_action(
	enemy: BellchainPenitent,
	action: StringName,
	damage: int,
	windup: float,
	active_duration: float,
	recovery: float,
	active_state: StringName,
	file_name: String
) -> void:
	enemy._on_attack_cancelled()
	enemy._start_attack(action, damage, windup, active_duration, recovery)
	if not await _wait_for_state(enemy, active_state, 90):
		_fail("%s never reached %s" % [action, active_state])
		return
	await _capture_frozen(enemy, file_name)
	enemy._on_attack_cancelled()
	enemy._enter_approach()


func _capture_frozen(enemy: BellchainPenitent, file_name: String) -> void:
	enemy.set_physics_process(false)
	await _wait_process_frames(2)
	_save_viewport(file_name)
	enemy.set_physics_process(true)


func _wait_for_level() -> Node:
	for _frame: int in range(360):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL_PATH:
			return current_scene
	return null


func _wait_for_state(enemy: BellchainPenitent, state_name: StringName, frames: int) -> bool:
	for _frame: int in range(frames):
		await physics_frame
		if enemy.get_state_name() == state_name:
			return true
	return false


func _wait_process_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _save_viewport(file_name: String) -> void:
	var output_path: String = "%s/%s" % [OUTPUT_DIR, file_name]
	var image: Image = root.get_texture().get_image()
	var save_error: Error = image.save_png(ProjectSettings.globalize_path(output_path))
	if save_error != OK:
		_fail("could not save %s: %s" % [output_path, error_string(save_error)])
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("BELLCHAIN_PHASE2A_MAIN_QA: %s" % message)
	quit(1)
