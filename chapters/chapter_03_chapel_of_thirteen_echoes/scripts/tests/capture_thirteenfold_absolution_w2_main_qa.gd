extends SceneTree

## MainBootstrap evidence for the W2 visual-only Thirteenfold Absolution route.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_SCENE: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/"
	+ "chapter_03_route.tscn"
)
const OUTPUT_ROOT: String = "res://docs/qa/chapter_03_thirteenfold_absolution/w2"

var _config: DebugRunConfigState
var _capture_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	_config = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if _config == null:
		_fail("missing DebugRunConfig")
		return
	_config.debug_chapter_start_enabled = true
	_config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	_config.debug_start_spawn_id = &"CH3_REWARD_TEST"
	_config.debug_reset_chapter_state_on_run = true
	_config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("could not open MainBootstrap")
		return
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		_fail("Chapter III route did not load through MainBootstrap")
		return
	var player: Player = route.transition_controller.player
	var visual: PlayerWeaponVisual = player.get_node_or_null(
		"VisualRoot/WeaponVisual"
	) as PlayerWeaponVisual
	if visual == null:
		_fail("Main player has no WeaponVisual")
		return
	for _frame: int in range(12):
		await process_frame
	if route.transition_controller.active_room_id != &"CH3_POST_BOSS":
		_fail("CH3_REWARD_TEST did not resolve to CH3_POST_BOSS")
		return
	if visual.get_visual_id() != &"thirteenfold_absolution":
		_fail("Main route did not apply W2 preview visual")
		return
	var equipment: PlayerEquipmentManager = root.get_node_or_null(
		"EquipmentManager"
	) as PlayerEquipmentManager
	if equipment == null or equipment.equipped_weapon_id != &"crimson_masque_stilettos":
		_fail("W2 preview mutated or lost the formal equipped weapon")
		return
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(590.0, 584.0)
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.player_camera.zoom = Vector2.ONE
	player.player_camera.reset_smoothing()
	await _pose(player, &"idle", 0, false)
	await _save("01_main_route_idle.png")
	var hud: CanvasLayer = route.get_node_or_null(
		"PersistentRuntime/ChapterRuntime/HUD"
	) as CanvasLayer
	if hud != null:
		hud.visible = false
	var prompt: CanvasItem = route.transition_controller.active_room.find_child(
		"InteractionPrompt", true, false
	) as CanvasItem
	if prompt != null:
		prompt.visible = false
	# 2x is the largest integer zoom that keeps the 64px body clear of the
	# room's lower camera limit; 3x crops the feet in this 720px room.
	player.player_camera.zoom = Vector2(2.0, 2.0)
	player.player_camera.reset_smoothing()
	await _capture_pose(player, &"ready_idle", 1, false, "02_ready_idle.png")
	await _capture_pose(player, &"run", 1, false, "03_run.png")
	await _capture_pose(player, &"jump_apex", 1, false, "04_jump_apex.png")
	await _capture_pose(player, &"attack_1", 1, false, "05_attack_1.png")
	await _capture_pose(player, &"attack_2", 1, false, "06_attack_2.png")
	await _capture_pose(player, &"attack_3", 1, false, "07_attack_3.png")
	await _capture_pose(player, &"dash_attack", 2, false, "08_dash_attack.png")
	await _capture_pose(player, &"ready_idle", 1, true, "09_left_flip.png")
	await _capture_pose(player, &"death", 4, false, "10_death_daggers.png")
	_config.reset_to_defaults()
	print(
		"THIRTEENFOLD_W2_MAIN_QA: PASS captures=%d room=%s visual=%s equipment=%s"
		% [
			_capture_count,
			route.transition_controller.active_room_id,
			visual.get_visual_id(),
			equipment.equipped_weapon_id,
		]
	)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _frame: int in range(480):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE_SCENE:
			return current_scene as Chapter03Route
	return null


func _capture_pose(
	player: Player,
	animation_name: StringName,
	frame_index: int,
	flip_h: bool,
	file_name: String
) -> void:
	await _pose(player, animation_name, frame_index, flip_h)
	await _save(file_name)


func _pose(
	player: Player, animation_name: StringName, frame_index: int, flip_h: bool
) -> void:
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	sprite.flip_h = flip_h
	sprite.play(animation_name)
	sprite.pause()
	sprite.frame = frame_index
	for _frame: int in range(4):
		await process_frame


func _save(file_name: String) -> void:
	for _frame: int in range(3):
		await process_frame
	var viewport_texture: ViewportTexture = root.get_texture()
	if viewport_texture == null:
		_fail("viewport texture unavailable; capture requires a rendered run")
		return
	var image: Image = viewport_texture.get_image()
	if image == null or image.is_empty():
		_fail("viewport image unavailable; capture requires a rendered run")
		return
	var path: String = OUTPUT_ROOT.path_join(file_name)
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_fail("unable to save %s" % path)
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("THIRTEENFOLD_W2_MAIN_QA: %s" % message)
	if _config != null:
		_config.reset_to_defaults()
	quit(1)
