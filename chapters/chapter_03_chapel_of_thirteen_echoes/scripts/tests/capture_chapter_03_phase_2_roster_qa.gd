extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn"
const OUTPUT: String = "res://docs/qa/chapter_03_enemy_phase_02"
var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null: return _fail("DebugRunConfig missing")
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	debug.debug_start_spawn_id = &"CH3_EXECUTIONER_TEST"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK: return _fail("Bootstrap launch failed")
	var level: Node = await _wait_level()
	if level == null: return _fail("Main did not route to Chapter III")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var player: Player = level.get_node("GameplayWorld/ChapterRuntime/Player") as Player
	player.hurtbox.set_invulnerable(true)
	var executioner: Chapter03SpecialistEnemy = level.get_node("GameplayWorld/Phase2BEncounter/Enemies/CenserExecutioner") as Chapter03SpecialistEnemy
	var chorister: Chapter03SpecialistEnemy = level.get_node("GameplayWorld/Phase2CDEEncounter/Enemies/SilentChorister") as Chapter03SpecialistEnemy
	var seraph: Chapter03SpecialistEnemy = level.get_node("GameplayWorld/Phase2CDEEncounter/Enemies/StainedGlassSeraph") as Chapter03SpecialistEnemy
	var wraith: Chapter03SpecialistEnemy = level.get_node("GameplayWorld/Phase2CDEEncounter/Enemies/ConfessionalWraith") as Chapter03SpecialistEnemy
	var scribe: Chapter03SpecialistEnemy = level.get_node("GameplayWorld/Phase2FEncounter/Enemies/ThirteenthScribe") as Chapter03SpecialistEnemy
	var group_b: EncounterGroup = level.get_node("GameplayWorld/Phase2BEncounter") as EncounterGroup
	var group_cde: EncounterGroup = level.get_node("GameplayWorld/Phase2CDEEncounter") as EncounterGroup
	var group_f: EncounterGroup = level.get_node("GameplayWorld/Phase2FEncounter") as EncounterGroup
	group_b.activate(player); group_cde.activate(player); group_f.activate(player)
	await _capture_action(player, executioner, Vector2(1660, 584), &"overhead_crush", 17, 0.82, 0.16, 1.05, "01_censer_executioner_overhead_main.png")
	await _capture_action(player, chorister, Vector2(2140, 584), &"crescent_hymn", 12, 0.68, 0.12, 0.72, "02_silent_chorister_hymn_main.png")
	await _capture_action(player, seraph, Vector2(2440, 584), &"dive", 13, 0.60, 0.22, 0.70, "03_stained_glass_seraph_dive_main.png")
	wraith.hurtbox.set_enabled(true)
	await _capture_action(player, wraith, Vector2(2680, 584), &"spectral_dash", 11, 0.52, 0.18, 0.72, "04_confessional_wraith_dash_main.png")
	await _capture_action(player, scribe, Vector2(3360, 584), &"thirteenth_seal", 13, 0.82, 0.10, 0.82, "05_thirteenth_scribe_seal_main.png")
	debug.reset_to_defaults()
	print("CH3_PHASE2_MAIN_QA: PASS captures=%d route=MainBootstrap main=%s" % [_captures, level.scene_file_path])
	quit(0)


func _capture_action(player: Player, enemy: Chapter03SpecialistEnemy, player_position: Vector2, action: StringName, damage: int, windup: float, active: float, recovery: float, file_name: String) -> void:
	player.global_position = player_position
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	enemy.set_target(player)
	enemy.set_facing_direction(signf(player.global_position.x - enemy.global_position.x))
	enemy._on_attack_cancelled()
	enemy._start_action(action, damage, windup, active, recovery)
	var expected: StringName = StringName("%sActive" % action)
	for _frame: int in range(120):
		await physics_frame
		if enemy.get_state_name() == expected: break
	enemy.set_physics_process(false)
	await process_frame; await process_frame
	_save(file_name)
	enemy.set_physics_process(true)
	enemy._on_attack_cancelled()


func _wait_level() -> Node:
	for _frame: int in range(360):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL: return current_scene
	return null


func _save(file_name: String) -> void:
	var path: String = "%s/%s" % [OUTPUT, file_name]
	if root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("Could not save %s" % path)
		return
	_captures += 1


func _fail(message: String) -> void:
	push_error("CH3_PHASE2_MAIN_QA: %s" % message)
	quit(1)
