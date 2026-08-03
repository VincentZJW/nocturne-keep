extends SceneTree

## Captures the rebuilt Mirefin Raider from the real MainBootstrap -> Chapter IV
## route. The formal Main instance is posed only for QA; no scene state is saved.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const CHAPTER_FOUR: String = (
	"res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
)
const OUTPUT: String = "res://docs/qa/chapter_04_character_replication/mirefin_raider/main_f5"
const ENEMY_PATH: NodePath = NodePath(
	"CharacterTrial/PenitentFloodway/Enemies/MirefinRaider"
)
const OTHER_ENEMY_PATH: NodePath = NodePath(
	"CharacterTrial/PenitentFloodway/Enemies/SunkenShieldPenitent"
)

var _captures: int = 0
var _debug_config: DebugRunConfigState


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	_debug_config = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if _debug_config == null:
		_fail("DebugRunConfig missing")
		return
	_debug_config.debug_chapter_start_enabled = true
	_debug_config.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	_debug_config.debug_start_spawn_id = &"CH4_CREATURE_COMBAT"
	_debug_config.debug_reset_chapter_state_on_run = true
	_debug_config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("MainBootstrap launch failed")
		return
	var level: Node2D = await _wait_for_level()
	if level == null:
		_fail("MainBootstrap did not route to Chapter IV")
		return
	var player: Player = level.get_node_or_null("ChapterRuntime/Player") as Player
	var enemy: Chapter04Enemy = level.get_node_or_null(ENEMY_PATH) as Chapter04Enemy
	if player == null or enemy == null:
		_fail("formal Player or Mirefin Raider instance missing")
		return
	var encounter: EncounterGroup = level.get_node_or_null(
		"CharacterTrial/PenitentFloodway"
	) as EncounterGroup
	if encounter != null:
		encounter.activate(player)
	var other_enemy: CanvasItem = level.get_node_or_null(OTHER_ENEMY_PATH) as CanvasItem
	if other_enemy != null:
		other_enemy.visible = false
	var hud: CanvasLayer = level.get_node_or_null("ChapterRuntime/HUD") as CanvasLayer
	if hud != null:
		hud.visible = false
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(3445.0, 612.0)
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.animation_controller.play_loop(&"idle")
	player.player_camera.zoom = Vector2(2.0, 2.0)
	player.player_camera.reset_smoothing()
	enemy.set_ai_active(false)
	enemy.global_position = Vector2(3545.0, 612.0)
	enemy.set_facing_direction(-1.0)
	await _capture_pose(enemy, &"idle", 1, "01_f5_idle_with_player.png")
	await _capture_pose(enemy, &"walk", 2, "02_f5_walk.png")
	await _capture_pose(enemy, &"claw_swipe_active", 1, "03_f5_claw_swipe.png")
	await _capture_pose(enemy, &"mire_lunge_active", 1, "04_f5_mire_lunge.png")
	await _capture_pose(enemy, &"fin_bite_active", 1, "05_f5_fin_bite.png")
	await _capture_pose(enemy, &"hurt", 1, "06_f5_hurt.png")
	await _capture_pose(enemy, &"death", 4, "07_f5_death.png")
	enemy.set_facing_direction(1.0)
	await _capture_pose(enemy, &"idle", 2, "08_f5_flip_right.png")
	_debug_config.reset_to_defaults()
	print(
		"MIRE FIN MAIN F5 QA | PASS captures=%d main=%s enemy=%s"
		% [_captures, level.scene_file_path, ENEMY_PATH]
	)
	call_deferred("_teardown_successfully")


func _capture_pose(
	enemy: Chapter04Enemy,
	animation_name: StringName,
	frame_index: int,
	file_name: String
) -> void:
	var sprite: AnimatedSprite2D = enemy.animated_sprite
	sprite.play(animation_name)
	sprite.pause()
	sprite.frame = mini(frame_index, sprite.sprite_frames.get_frame_count(animation_name) - 1)
	for _frame: int in range(6):
		await process_frame
	_save(file_name)


func _wait_for_level() -> Node2D:
	for _frame: int in range(480):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == CHAPTER_FOUR:
			return current_scene as Node2D
	return null


func _save(file_name: String) -> void:
	var viewport_texture: ViewportTexture = root.get_texture()
	if viewport_texture == null:
		_fail("viewport texture unavailable")
		return
	var image: Image = viewport_texture.get_image()
	var output_path: String = "%s/%s" % [OUTPUT, file_name]
	if image == null or image.save_png(ProjectSettings.globalize_path(output_path)) != OK:
		_fail("cannot save %s" % output_path)
		return
	_captures += 1


func _teardown_successfully() -> void:
	var loaded_scene: Node = current_scene
	current_scene = null
	if loaded_scene != null:
		loaded_scene.free()
	loaded_scene = null
	# Chapter IV owns hundreds of imported textures. Give deferred frees and the
	# compatibility renderer enough frames to release them before script exit.
	for _frame: int in range(60):
		await process_frame
	RenderingServer.force_sync()
	await process_frame
	quit(0)


func _fail(message: String) -> void:
	push_error("MIRE FIN MAIN F5 QA: %s" % message)
	if _debug_config != null:
		_debug_config.reset_to_defaults()
	quit(1)
