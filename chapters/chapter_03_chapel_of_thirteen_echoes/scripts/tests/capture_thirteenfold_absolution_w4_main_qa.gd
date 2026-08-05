extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_SCENE: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/"
	+ "chapter_03_route.tscn"
)
const OUTPUT_ROOT: String = "res://docs/qa/chapter_03_thirteenfold_absolution/w4"

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
	_config.debug_start_spawn_id = &"CH3_BOSS"
	_config.debug_reset_chapter_state_on_run = true
	_config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_fail("could not open MainBootstrap")
		return
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		_fail("Chapter III route did not load through MainBootstrap")
		return
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var room: Chapter03BossSanctumRoom = controller.active_room as Chapter03BossSanctumRoom
	if room == null:
		_fail("CH3_BOSS did not load the formal Boss room")
		return
	var intro_deadline: int = Time.get_ticks_msec() + 16000
	while not room.sanctum.is_intro_complete() and Time.get_ticks_msec() < intro_deadline:
		await process_frame
	if not room.sanctum.is_intro_complete():
		_fail("Boss intro did not complete")
		return
	var player: Player = controller.player
	player.global_position = Vector2(1680.0, 584.0)
	player.velocity = Vector2.ZERO
	player.hurtbox.set_invulnerable(true)
	player.player_camera.zoom = Vector2.ONE
	player.player_camera.reset_smoothing()
	room.boss.config.death_sequence_duration = 0.50
	room.boss.debug_enter_phase_02_immediate()
	room.boss.health_component.set_current_health(0)
	var formation_deadline: int = Time.get_ticks_msec() + 5000
	while not room.reward_sequence.is_running() and Time.get_ticks_msec() < formation_deadline:
		await process_frame
	if not room.reward_sequence.is_running():
		_fail("Boss defeat did not start reward formation")
		return
	await create_timer(0.42).timeout
	await _save("01_boss_fragments_converge_main.png")
	await create_timer(0.90).timeout
	await _save("02_thirteen_seals_extinguish_main.png")
	await create_timer(0.95).timeout
	if room.reward_sequence.weapon.visible:
		_fail("Boss room exposed a duplicate reward weapon")
		return
	await _save("03_reliquary_unsealed_boss_room_no_weapon_main.png")
	while not room.reward_sequence.is_complete():
		await process_frame
	await _save("04_boss_room_sequence_complete_no_weapon_main.png")
	if not room.post_boss_exit.monitoring:
		_fail("post-Boss exit did not wait for and open after formation")
		return
	if not controller.request_room_change(&"CH3_POST_BOSS", &"EntryWest"):
		_fail("could not enter formal post-Boss reliquary")
		return
	if not await _wait_for_room(controller, &"CH3_POST_BOSS", 3.0):
		_fail("post-Boss reliquary room did not load")
		return
	var post_room: Chapter03PostBossRoom = controller.active_room as Chapter03PostBossRoom
	player.global_position = Vector2(590.0, 584.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	post_room.reliquary._on_body_entered(player)
	await _save("05_reliquary_pickup_prompt_main.png")
	if not post_room.reliquary.pickup.collect():
		_fail("formal pickup did not collect")
		return
	await create_timer(0.22).timeout
	await _save("06_acquisition_panel_open_gate_main.png")
	var equipment: PlayerEquipmentManager = root.get_node_or_null(
		"EquipmentManager"
	) as PlayerEquipmentManager
	var visual: PlayerWeaponVisual = player.get_node_or_null(
		"VisualRoot/WeaponVisual"
	) as PlayerWeaponVisual
	if (
		equipment == null
		or equipment.equipped_weapon_id != &"thirteenfold_absolution_blades"
		or equipment.get_normal_attack_damage() != 14
		or equipment.get_dash_attack_damage() != 28
		or visual == null
		or visual.get_visual_id() != &"thirteenfold_absolution"
	):
		_fail("Main equipment/HUD visual did not switch to the formal reward")
		return
	if not post_room.underkeep_exit.monitoring or not post_room.reliquary.descent_blocker.disabled:
		_fail("post-Boss descent did not unlock after pickup")
		return
	_config.reset_to_defaults()
	print(
		"THIRTEENFOLD_W4_MAIN_QA: PASS captures=%d boss_weapon=0 reliquary_weapon=1 equipment=14/28 gate=open"
		% _capture_count
	)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _frame: int in range(600):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE_SCENE:
			return current_scene as Chapter03Route
	return null


func _wait_for_room(
	controller: Chapter03RoomTransitionController, room_id: StringName, timeout_seconds: float
) -> bool:
	var deadline: int = Time.get_ticks_msec() + roundi(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if controller.active_room_id == room_id and not controller._transitioning:
			return true
	return false


func _save(file_name: String) -> void:
	for _frame: int in range(4):
		await process_frame
	var viewport_texture: ViewportTexture = root.get_texture()
	if viewport_texture == null:
		_fail("viewport texture unavailable")
		return
	var image: Image = viewport_texture.get_image()
	if image == null or image.is_empty():
		_fail("viewport image unavailable")
		return
	var path: String = OUTPUT_ROOT.path_join(file_name)
	if image.save_png(ProjectSettings.globalize_path(path)) != OK:
		_fail("could not save %s" % path)
		return
	_capture_count += 1


func _fail(message: String) -> void:
	push_error("THIRTEENFOLD_W4_MAIN_QA: %s" % message)
	if _config != null:
		_config.reset_to_defaults()
	quit(1)
