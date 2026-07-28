extends SceneTree

## Captures the mandatory Stage 2 Night Warden acceptance evidence.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const CHAPTER_ONE: String = ChapterRegistry.CHAPTER_01_SCENE_PATH
const OUTPUT_ROOT: String = "res://docs/qa/core_character_art_rework/stage_2"
const GUARD_SCENE: PackedScene = preload(
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn"
)

var _config: DebugRunConfigState
var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	_config = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if _config == null:
		_fail("missing DebugRunConfig")
		return
	var chapter_one: Node2D = await _route_chapter(
		ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS,
		&"dark_forest_tutorial_spawn",
		CHAPTER_ONE
	)
	if chapter_one == null:
		_fail("Chapter I did not load through MainBootstrap")
		return
	await _capture_chapter_one_actions(chapter_one)
	_config.reset_to_defaults()
	await _release_current_scene()
	print("PLAYER_STAGE_2_MAIN_QA: PASS captures=%d bootstrap=%s" % [_captures, BOOTSTRAP])
	quit(0)


func _capture_chapter_one_actions(level: Node2D) -> void:
	var player: Player = level.get_node_or_null("World/Player") as Player
	if player == null:
		_fail("Chapter I shared Player missing")
		return
	var interface: MainDebugHudController = level.get_node_or_null("Interface") as MainDebugHudController
	if interface != null:
		interface.set_debug_hud_visible(false)
	var tutorial_prompt: CanvasItem = level.get_node_or_null("HUD/TutorialPrompt") as CanvasItem
	if tutorial_prompt != null:
		tutorial_prompt.visible = false
	_disable_existing_encounters(level)
	player.global_position = Vector2(1040.0, 612.0)
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.player_camera.zoom = Vector2.ONE
	player.player_camera.reset_smoothing()
	var guard: Node2D = GUARD_SCENE.instantiate() as Node2D
	level.get_node("World").add_child(guard)
	guard.global_position = Vector2(1140.0, 612.0)
	guard.set_physics_process(false)
	var guard_sprite: AnimatedSprite2D = guard.get_node("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	guard_sprite.play(&"idle")
	guard_sprite.pause()
	await _pose(player, &"idle", 0)
	await _save("01_idle_vs_guard_native_scale.png")
	guard.visible = false
	player.player_camera.zoom = Vector2(2.0, 2.0)
	player.player_camera.reset_smoothing()
	await _capture_pose(player, &"run", 1, "02_run.png")
	await _capture_pose(player, &"turn", 1, "03_turn.png")
	await _capture_pose(player, &"jump_start", 1, "04_jump_start.png")
	await _capture_pose(player, &"jump_apex", 1, "05_jump_apex.png")
	await _capture_pose(player, &"double_jump", 2, "06_double_jump.png")
	await _capture_pose(player, &"air_dash_loop", 1, "07_air_dash.png")
	await _capture_pose(player, &"dash_loop", 1, "08_ground_dash.png")
	for combo_step: int in range(1, 4):
		player.animation_controller.select_attack_variant(combo_step)
		await _capture_pose(player, &"attack", 2, "0%d_attack_%d.png" % [8 + combo_step, combo_step])
	await _capture_pose(player, &"dash_attack", 2, "12_dash_attack.png")
	await _capture_pose(player, &"hurt_light", 1, "13_hurt_light.png")
	await _capture_pose(player, &"hurt_heavy", 2, "14_hurt_heavy.png")
	var weapon_resources: Dictionary[String, String] = {
		"veilbound": "res://resources/player/player_sprite_frames.tres",
		"ravenfang": "res://resources/player/ravenfang_player_sprite_frames.tres",
		"crimson_masque": (
			"res://chapters/chapter_02_silent_court/resources/weapons/"
			+ "crimson_masque_player_sprite_frames.tres"
		),
	}
	for weapon_name: String in weapon_resources:
		player.animation_controller.animated_sprite.sprite_frames = load(weapon_resources[weapon_name]) as SpriteFrames
		await _capture_pose(player, &"ready_idle", 1, "weapon_%s.png" % weapon_name)
	player.animation_controller.animated_sprite.sprite_frames = load(weapon_resources["veilbound"]) as SpriteFrames
	var respawn: PlayerRespawnController = level.get_node_or_null("PlayerRespawnController") as PlayerRespawnController
	if respawn != null:
		respawn.enabled = false
	player.set_physics_process(true)
	player.health_component.take_damage(player.health_component.max_health)
	var death_sequence: PlayerDeathSequence = player.get_node("DeathSequence") as PlayerDeathSequence
	await _wait_for_death_frame(player, death_sequence, 4)
	await _save("15_death_ground_and_daggers.png")
	await _wait_for_death_phase(death_sequence, &"GhostPause")
	await _save("16_ghost_release.png")


func _route_chapter(chapter_id: StringName, spawn_id: StringName, expected_path: String) -> Node2D:
	_config.debug_chapter_start_enabled = true
	_config.debug_start_chapter_id = chapter_id
	_config.debug_start_spawn_id = spawn_id
	_config.debug_reset_chapter_state_on_run = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		return null
	for _frame: int in range(360):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == expected_path:
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


func _capture_pose(player: Player, animation_name: StringName, frame_index: int, file_name: String) -> void:
	await _pose(player, animation_name, frame_index)
	await _save(file_name)


func _pose(player: Player, animation_name: StringName, frame_index: int) -> void:
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	sprite.play(animation_name)
	sprite.pause()
	sprite.frame = frame_index
	for _frame: int in range(4):
		await process_frame


func _wait_for_death_frame(
		player: Player, death_sequence: PlayerDeathSequence, target_frame: int
	) -> void:
	for _frame: int in range(180):
		await process_frame
		if (
			death_sequence.get_phase_name() == &"BodyFall"
			and player.animation_controller.animated_sprite.frame >= target_frame
		):
			return


func _wait_for_death_phase(death_sequence: PlayerDeathSequence, target_phase: StringName) -> void:
	for _frame: int in range(180):
		await process_frame
		if death_sequence.get_phase_name() == target_phase:
			return


func _save(file_name: String) -> void:
	for _frame: int in range(3):
		await process_frame
	var image: Image = root.get_texture().get_image()
	var path: String = OUTPUT_ROOT.path_join(file_name)
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_fail("unable to save %s" % path)
		return
	_captures += 1


func _release_current_scene() -> void:
	var old_scene: Node = current_scene
	current_scene = null
	if old_scene != null and is_instance_valid(old_scene):
		old_scene.queue_free()
	for _frame: int in range(12):
		await process_frame


func _fail(message: String) -> void:
	push_error("PLAYER_STAGE_2_MAIN_QA: %s" % message)
	if _config != null:
		_config.reset_to_defaults()
	quit(1)
