extends SceneTree

## Captures formal enemy art from the actual MainBootstrap -> Chapter III route.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn"
const OUTPUT: String = "res://docs/qa/chapter_03_enemy_art_rework"

const ENEMY_PATHS: Array[NodePath] = [
	NodePath("GameplayWorld/Phase2AEncounter/Enemies/BellchainPenitent"),
	NodePath("GameplayWorld/Phase2BEncounter/Enemies/CenserExecutioner"),
	NodePath("GameplayWorld/Phase2CDEEncounter/Enemies/SilentChorister"),
	NodePath("GameplayWorld/Phase2CDEEncounter/Enemies/StainedGlassSeraph"),
	NodePath("GameplayWorld/Phase2CDEEncounter/Enemies/ConfessionalWraith"),
	NodePath("GameplayWorld/Phase2FEncounter/Enemies/ThirteenthScribe"),
]
const ENCOUNTER_PATHS: Array[NodePath] = [
	NodePath("GameplayWorld/Phase2AEncounter"),
	NodePath("GameplayWorld/Phase2BEncounter"),
	NodePath("GameplayWorld/Phase2CDEEncounter"),
	NodePath("GameplayWorld/Phase2CDEEncounter"),
	NodePath("GameplayWorld/Phase2CDEEncounter"),
	NodePath("GameplayWorld/Phase2FEncounter"),
]
const FILE_NAMES: Array[String] = [
	"bellchain_penitent", "censer_executioner", "silent_chorister",
	"stained_glass_seraph", "confessional_wraith", "thirteenth_scribe",
]
const ACTIVE_ACTIONS: Array[StringName] = [
	&"chain_lash", &"overhead_crush", &"crescent_hymn",
	&"dive", &"emerging_slash", &"thirteenth_seal",
]

var _capture_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280,720))
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug==null:
		_fail("missing DebugRunConfig")
		return
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	debug.debug_start_spawn_id = &"chapter_03_start"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP)!=OK:
		_fail("cannot launch MainBootstrap")
		return
	var level: Node = await _wait_for_level()
	if level==null:
		_fail("Chapter III did not load via MainBootstrap")
		return
	var player: Player = level.get_node_or_null("GameplayWorld/ChapterRuntime/Player") as Player
	if player==null:
		_fail("missing Main player")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	player.hurtbox.set_invulnerable(true)
	for index: int in range(ENEMY_PATHS.size()):
		var enemy: EnemyCombatant = level.get_node_or_null(ENEMY_PATHS[index]) as EnemyCombatant
		var encounter: EncounterGroup = level.get_node_or_null(ENCOUNTER_PATHS[index]) as EncounterGroup
		if enemy==null or encounter==null:
			_fail("missing Main enemy %s" % FILE_NAMES[index])
			return
		encounter.activate(player)
		enemy.set_target(player)
		player.global_position = enemy.global_position+Vector2(-132,0)
		player.velocity = Vector2.ZERO
		player.player_camera.reset_smoothing()
		enemy.set_physics_process(false)
		enemy.play_animation(&"idle",true)
		await _frames(5)
		_save("%02d_%s_main.png" % [15+index,FILE_NAMES[index]])
		enemy.set_physics_process(true)
		if not await _start_and_wait_active(enemy,ACTIVE_ACTIONS[index]):
			_fail("%s did not reach active art" % FILE_NAMES[index])
			return
		enemy.set_physics_process(false)
		await _frames(2)
		_save("%02d_%s_attack_main.png" % [21+index,FILE_NAMES[index]])
		enemy.set_physics_process(true)
		_cancel_enemy_action(enemy)
	# Three-role live combination on the saved Main encounter.
	player.global_position = Vector2(2440,584)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	var mixed: EncounterGroup = level.get_node_or_null("GameplayWorld/Phase2CDEEncounter") as EncounterGroup
	mixed.activate(player)
	for child: Node in mixed.get_node("Enemies").get_children():
		var mixed_enemy: EnemyCombatant = child as EnemyCombatant
		if mixed_enemy!=null: mixed_enemy.set_target(player)
	await _frames(15)
	_save("27_three_role_combination_main.png")
	debug.reset_to_defaults()
	print("CH3_ENEMY_ART_MAIN_QA: PASS captures=%d route=MainBootstrap enemies=6 attacks=6 combination=1" % _capture_count)
	quit(0)


func _start_and_wait_active(enemy: EnemyCombatant,action: StringName) -> bool:
	if enemy is BellchainPenitent:
		var penitent: BellchainPenitent = enemy as BellchainPenitent
		penitent._on_attack_cancelled()
		penitent._start_attack(action,11,0.06,0.28,0.35)
		for _index: int in range(90):
			await physics_frame
			if penitent.is_attack_window_active(): return true
		return false
	var specialist: Chapter03SpecialistEnemy = enemy as Chapter03SpecialistEnemy
	if specialist==null: return false
	specialist._on_attack_cancelled()
	specialist._start_action(action,10,0.06,0.28,0.35)
	for _index: int in range(90):
		await physics_frame
		if specialist.get_attack_phase_name()==&"Active": return true
	return false


func _cancel_enemy_action(enemy: EnemyCombatant) -> void:
	if enemy is BellchainPenitent:
		(enemy as BellchainPenitent)._on_attack_cancelled()
	else:
		(enemy as Chapter03SpecialistEnemy)._on_attack_cancelled()


func _wait_for_level() -> Node:
	for _index: int in range(420):
		await process_frame
		if current_scene!=null and current_scene.scene_file_path==LEVEL:
			return current_scene
	return null


func _frames(count: int) -> void:
	for _index: int in range(count): await process_frame


func _save(file_name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var path: String = "%s/%s" % [OUTPUT,file_name]
	if image.save_png(ProjectSettings.globalize_path(path))!=OK:
		_fail("cannot save %s" % path)
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("CH3_ENEMY_ART_MAIN_QA: %s" % message)
	quit(1)
