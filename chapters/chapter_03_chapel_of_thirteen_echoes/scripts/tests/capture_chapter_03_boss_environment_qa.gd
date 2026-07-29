extends SceneTree

## Produces the required evidence from the actual MainBootstrap -> Chapter III
## route. Boss-character-only rows remain explicitly partial in the report.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn"
const OUTPUT: String = "res://docs/qa/chapter_03_boss_environment"

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
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	debug.debug_start_spawn_id = &"CH3_BOSS_ANTE"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("cannot launch MainBootstrap")
		return
	var level: Node = await _wait_for_level()
	if level == null:
		_fail("Chapter III did not load through MainBootstrap")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var player: Player = level.get_node_or_null("GameplayWorld/ChapterRuntime/Player") as Player
	var gate: Chapter03BossGate = level.get_node_or_null("GameplayWorld/Chapter03BossAreas/BossGateTransition") as Chapter03BossGate
	var sanctum: Chapter03BossSanctum = level.get_node_or_null("GameplayWorld/Chapter03BossAreas/BossSanctum") as Chapter03BossSanctum
	var reliquary: Chapter03PostBossReliquary = level.get_node_or_null("GameplayWorld/Chapter03BossAreas/PostBossReliquary") as Chapter03PostBossReliquary
	if player == null or gate == null or sanctum == null or reliquary == null:
		_fail("missing Main Boss-area integration nodes")
		return
	# The capture runner drives each presentation state deterministically. Disable
	# the Area2D trigger so an in-flight gate coroutine cannot leave its full-screen
	# fade over later sanctuary/reliquary evidence frames.
	gate.auto_trigger = false
	gate.reset_gate()
	sanctum.intro_trigger.set_deferred("monitoring", false)
	sanctum.intro_trigger.set_deferred("monitorable", false)
	await physics_frame
	player.hurtbox.set_invulnerable(true)
	await _capture_at(player, Vector2(4620, 584), "01_boss_antechamber_panorama_main.png")
	await _capture_at(player, Vector2(4860, 584), "02_thirteen_blood_candles_main.png")
	await _capture_at(player, Vector2(5040, 584), "03_thirteen_confession_tablets_main.png")
	await _capture_at(player, Vector2(5340, 584), "04_boss_gate_closed_main.png")
	var visuals: Node2D = gate.get_node("Visuals") as Node2D
	(visuals.get_node("GateClosed") as Sprite2D).visible = false
	(visuals.get_node("GateLit") as Sprite2D).visible = true
	for seal: Node in (visuals.get_node("SealLights") as Node2D).get_children():
		(seal as CanvasItem).visible = true
	await _capture_at(player, Vector2(5340, 584), "05_boss_gate_lit_main.png")
	gate.open_immediately()
	await _capture_at(player, Vector2(5340, 584), "06_boss_gate_open_main.png")
	var fade: ColorRect = gate.get_node("TransitionFade/Fade") as ColorRect
	fade.visible = true
	fade.modulate.a = 0.72
	await _frames(3)
	_save("07_gate_fade_out_main.png")
	fade.visible = false
	await _capture_at(player, Vector2(6220, 584), "08_boss_room_fade_in_main.png")
	sanctum.skip_intro_to_combat_state()
	await _capture_at(player, Vector2(7600, 584), "09_boss_sanctum_panorama_main.png")
	await _capture_at(player, Vector2(7560, 584), "10_central_altar_main.png")
	await _capture_at(player, Vector2(7440, 584), "11_thirteenfold_stained_glass_main.png")
	await _capture_at(player, Vector2(6900, 584), "12_choir_stalls_main.png")
	var incense: Sprite2D = sanctum.get_node("Presentation/Incense") as Sprite2D
	incense.modulate.a = 0.85
	await _capture_at(player, Vector2(7160, 584), "13_dynamic_incense_main.png")
	var resonance: Sprite2D = sanctum.get_node("Presentation/Resonance") as Sprite2D
	resonance.visible = true
	resonance.modulate.a = 0.85
	await _capture_at(player, Vector2(7440, 584), "14_boss_intro_environment_main.png")
	resonance.visible = false
	await _capture_at(player, Vector2(7680, 584), "15_boss_combat_readability_hook_main.png")
	sanctum.notify_boss_defeated()
	await _frames(120)
	await _capture_at(player, Vector2(7560, 584), "16_boss_death_environment_response_main.png")
	reliquary.reveal_after_boss()
	await _capture_at(player, Vector2(9700, 584), "17_post_boss_reliquary_main.png")
	reliquary.notify_reward_collected()
	await _capture_at(player, Vector2(10140, 584), "18_underground_gate_open_main.png")
	await _capture_at(player, Vector2(10920, 584), "19_drowned_saints_descent_main.png")
	await _capture_at(player, Vector2(12180, 584), "20_shallow_water_chapter_four_gate_main.png")
	debug.reset_to_defaults()
	print("CH3_BOSS_ENV_MAIN_QA: PASS captures=%d route=MainBootstrap boss_character=PARTIAL chapter4_scene=PARTIAL" % _capture_count)
	quit(0)


func _capture_at(player: Player, position: Vector2, file_name: String) -> void:
	player.global_position = position
	player.velocity = Vector2.ZERO
	if player.player_camera != null:
		player.player_camera.reset_smoothing()
	await _frames(8)
	_save(file_name)


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
	var path: String = "%s/%s" % [OUTPUT, file_name]
	if image.save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("cannot save %s" % path)
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("CH3_BOSS_ENV_MAIN_QA: %s" % message)
	quit(1)
