extends SceneTree

## Captures Stage 1 Player presentation through the configured Main/Bootstrap route.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const CHAPTER_ONE: String = (
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
)
const GUARD_SCENE: PackedScene = preload(
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn"
)
const OUTPUT_ROOT: String = "res://docs/qa/core_character_art_rework/stage_1"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		push_error("PLAYER_STAGE_1_MAIN_QA: missing DebugRunConfig")
		quit(1)
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS
	config.debug_start_spawn_id = &"dark_forest_tutorial_spawn"
	if change_scene_to_file(BOOTSTRAP) != OK:
		push_error("PLAYER_STAGE_1_MAIN_QA: unable to load Bootstrap")
		quit(1)
		return
	var level: Node2D = await _wait_for_level()
	if level == null:
		push_error("PLAYER_STAGE_1_MAIN_QA: Chapter I did not load through Bootstrap")
		quit(1)
		return
	var player: Player = level.get_node_or_null("World/Player") as Player
	if player == null:
		push_error("PLAYER_STAGE_1_MAIN_QA: Main Player missing")
		quit(1)
		return
	var interface: MainDebugHudController = level.get_node_or_null("Interface") as MainDebugHudController
	if interface != null:
		interface.set_debug_hud_visible(false)
	var tutorial: Node = level.get_node_or_null("TutorialController")
	if tutorial != null:
		tutorial.set_process(false)
	var tutorial_prompt: CanvasItem = level.get_node_or_null("HUD/TutorialPrompt") as CanvasItem
	if tutorial_prompt != null:
		tutorial_prompt.visible = false
	_disable_existing_encounters(level)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	player.global_position = Vector2(1040.0, 612.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	var guard: CastleGuard = GUARD_SCENE.instantiate() as CastleGuard
	level.get_node("World").add_child(guard)
	guard.global_position = Vector2(1140.0, 612.0)
	guard.set_physics_process(false)
	guard.animated_sprite.play(&"idle")
	guard.animated_sprite.pause()
	await _pose_player(player, &"idle", 0)
	await _save("main_player_guard_scale.png")
	guard.visible = false
	for combo_step: int in range(1, 4):
		player.animation_controller.select_attack_variant(combo_step)
		await _pose_player(player, &"attack", 2)
		await _save("main_player_attack_%d.png" % combo_step)
	await _pose_player(player, &"double_jump", 1)
	await _save("main_player_double_jump.png")
	await _pose_player(player, &"dash_attack", 2)
	await _save("main_player_dash_attack.png")
	var weapon_resources: Dictionary[String, String] = {
		"veilbound": "res://resources/player/player_sprite_frames.tres",
		"ravenfang": "res://resources/player/ravenfang_player_sprite_frames.tres",
		"crimson_masque": "res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_player_sprite_frames.tres",
	}
	for weapon_name: String in weapon_resources:
		player.animation_controller.animated_sprite.sprite_frames = load(weapon_resources[weapon_name]) as SpriteFrames
		await _pose_player(player, &"ready_idle", 1)
		await _save("main_player_weapon_%s.png" % weapon_name)
	config.reset_to_defaults()
	print("PLAYER_STAGE_1_MAIN_QA: PASS captures=9 main=%s" % level.scene_file_path)
	quit(0)


func _wait_for_level() -> Node2D:
	for _frame: int in range(240):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == CHAPTER_ONE:
			return current_scene as Node2D
	return null


func _disable_existing_encounters(level: Node2D) -> void:
	var encounters: Node = level.get_node_or_null("World/Encounters")
	if encounters == null:
		return
	encounters.process_mode = Node.PROCESS_MODE_DISABLED
	for child: Node in encounters.find_children("*", "", true, false):
		if child is CanvasItem:
			(child as CanvasItem).visible = false


func _pose_player(player: Player, animation_name: StringName, frame_index: int) -> void:
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	sprite.play(animation_name)
	sprite.pause()
	sprite.frame = frame_index
	for _frame: int in range(4):
		await process_frame


func _save(file_name: String) -> void:
	await process_frame
	var image: Image = root.get_texture().get_image()
	var path: String = OUTPUT_ROOT.path_join(file_name)
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("PLAYER_STAGE_1_MAIN_QA: unable to save %s" % path)
