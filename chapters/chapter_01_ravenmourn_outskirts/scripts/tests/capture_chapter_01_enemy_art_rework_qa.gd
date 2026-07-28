extends SceneTree

## Actual F5 route evidence: MainBootstrap -> Chapter I saved level -> saved encounters.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
const OUTPUT: String = "res://docs/qa/chapter_01_enemy_art_rework"
const ENEMY_PATHS: Array[NodePath] = [
	NodePath("World/Encounters/TutorialEncounter01/Enemies/TutorialGuard01"),
	NodePath("World/Encounters/TutorialEncounter05/Enemies/TutorialShieldGuard01"),
	NodePath("World/Encounters/ForestEncounter01/Enemies/ForestSpearman01"),
	NodePath("World/Encounters/ForestEncounter02/Enemies/ForestCrossbowman01"),
	NodePath("World/Encounters/ForestEncounter03/Enemies/ForestGargoyle01"),
]
const ENCOUNTER_PATHS: Array[NodePath] = [
	NodePath("World/Encounters/TutorialEncounter01"),
	NodePath("World/Encounters/TutorialEncounter05"),
	NodePath("World/Encounters/ForestEncounter01"),
	NodePath("World/Encounters/ForestEncounter02"),
	NodePath("World/Encounters/ForestEncounter03"),
]
const FILE_NAMES: Array[String] = [
	"castle_guard", "cursed_shield_guard", "decayed_spearman",
	"fallen_crossbowman", "gargoyle_sentinel",
]
const IDLES: Array[StringName] = [&"idle", &"idle", &"idle", &"idle", &"hover"]
const ACTIONS: Array[StringName] = [&"attack", &"guard_break", &"attack_thrust", &"shoot", &"dive"]
const ACTION_FRAMES: Array[int] = [2, 1, 3, 1, 2]

var _capture_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null:
		_fail("missing DebugRunConfig")
		return
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS
	debug.debug_start_spawn_id = &"dark_forest_tutorial_spawn"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("cannot launch MainBootstrap")
		return
	var level: Node = await _wait_for_level()
	if level == null:
		_fail("Chapter I did not load via MainBootstrap")
		return
	var player: Player = level.get_node_or_null("World/Player") as Player
	if player == null:
		_fail("missing Main player")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	player.hurtbox.set_invulnerable(true)
	var debug_controller: MainDebugHudController = level.get_node_or_null("Interface") as MainDebugHudController
	if debug_controller != null:
		debug_controller.set_debug_hud_visible(false)
	for index: int in range(ENEMY_PATHS.size()):
		var enemy: EnemyCombatant = level.get_node_or_null(ENEMY_PATHS[index]) as EnemyCombatant
		var encounter: EncounterGroup = level.get_node_or_null(ENCOUNTER_PATHS[index]) as EncounterGroup
		if enemy == null or encounter == null:
			_fail("missing Main enemy %s" % FILE_NAMES[index])
			return
		encounter.activate(player)
		enemy.set_target(player)
		enemy.set_ai_active(false)
		player.global_position = Vector2(enemy.global_position.x - 120.0, 612.0)
		player.velocity = Vector2.ZERO
		player.player_camera.reset_smoothing()
		_freeze_animation(enemy, IDLES[index], 0)
		await _frames(5)
		_save("%02d_%s_main_idle.png" % [14 + index * 2, FILE_NAMES[index]])
		_freeze_animation(enemy, ACTIONS[index], ACTION_FRAMES[index])
		await _frames(3)
		_save("%02d_%s_main_action.png" % [15 + index * 2, FILE_NAMES[index]])
	var boss: FallenGateKnight = level.get_node_or_null("World/CastleEntranceArea/FallenGateKnight") as FallenGateKnight
	var room: BossRoomController = level.get_node_or_null("BossRoomController") as BossRoomController
	if boss == null or room == null:
		_fail("missing saved Main Boss")
		return
	player.global_position = Vector2(5940, 612)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	room._on_entry_body_entered(player)
	boss.set_ai_active(false)
	_boss_frame(boss, &"idle_shielded", 0)
	await _frames(5)
	_save("24_fallen_gate_knight_main_phase_1.png")
	_boss_frame(boss, &"shield_break", 3)
	await _frames(3)
	_save("25_fallen_gate_knight_main_shield_break.png")
	_boss_frame(boss, &"idle_unshielded", 0)
	await _frames(3)
	_save("26_fallen_gate_knight_main_phase_2.png")
	_boss_frame(boss, &"heavy_overhead", 3)
	await _frames(3)
	_save("27_fallen_gate_knight_main_heavy_active.png")
	_boss_frame(boss, &"death", 5)
	await _frames(3)
	_save("28_fallen_gate_knight_main_death.png")
	debug.reset_to_defaults()
	print("CH1_ENEMY_ART_MAIN_QA: PASS route=MainBootstrap roles=6 captures=%d" % _capture_count)
	quit(0)


func _freeze_animation(enemy: EnemyCombatant, animation: StringName, frame: int) -> void:
	var sprite: AnimatedSprite2D = enemy.get_node_or_null("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	if sprite != null:
		sprite.play(animation)
		sprite.pause()
		sprite.frame = mini(frame, sprite.sprite_frames.get_frame_count(sprite.animation) - 1)


func _boss_frame(boss: FallenGateKnight, animation: StringName, frame: int) -> void:
	boss.play_animation(animation, true)
	boss.animated_sprite.pause()
	boss.animated_sprite.frame = mini(frame, boss.animated_sprite.sprite_frames.get_frame_count(animation) - 1)


func _wait_for_level() -> Node:
	for _index: int in range(420):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


func _save(file_name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var path: String = OUTPUT + "/" + file_name
	if image.save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("cannot save %s" % path)
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("CH1_ENEMY_ART_MAIN_QA: %s" % message)
	quit(1)
