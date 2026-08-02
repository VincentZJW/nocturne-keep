extends SceneTree

## W5 final MainBootstrap capture. This uses the disposable CH3_REWARD_TEST
## state, performs the formal pickup, then follows the reward into Underkeep.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_SCENE: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/"
	+ "chapter_03_route.tscn"
)
const OUTPUT_ROOT: String = "res://docs/qa/chapter_03_thirteenfold_absolution/w5"
const WEAPON_ID: StringName = &"thirteenfold_absolution_blades"

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
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var post_room: Chapter03PostBossRoom = controller.active_room as Chapter03PostBossRoom
	if post_room == null or not post_room.reliquary.is_reward_available():
		_fail("CH3_REWARD_TEST did not expose the uncollected formal reward")
		return
	var player: Player = controller.player
	var equipment: PlayerEquipmentManager = root.get_node_or_null(
		"EquipmentManager"
	) as PlayerEquipmentManager
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(430.0, 584.0)
	player.velocity = Vector2.ZERO
	player.player_camera.zoom = Vector2.ONE
	player.player_camera.reset_smoothing()
	await _save("01_reward_test_uncollected_main.png")
	player.global_position = Vector2(590.0, 584.0)
	post_room.reliquary._on_body_entered(player)
	await _save("02_pickup_prompt_main.png")
	if not post_room.reliquary.pickup.collect():
		_fail("formal pickup failed during W5 capture")
		return
	await create_timer(0.22).timeout
	if equipment == null or equipment.equipped_weapon_id != WEAPON_ID:
		_fail("formal pickup did not equip Thirteenfold Absolution")
		return
	await _save("03_acquired_equipped_main.png")
	post_room.acquisition_panel.visible = false
	player.set_physics_process(false)
	await _capture_pose(player, &"attack_2", 1, false, "04_equipped_attack_main.png")
	await _capture_pose(player, &"dash_attack", 2, false, "05_equipped_dash_attack_main.png")
	await _capture_pose(player, &"ready_idle", 1, true, "06_left_facing_main.png")
	player.set_physics_process(true)
	player.animation_controller.reset_to_idle()
	player.hurtbox.set_invulnerable(false)
	if not controller.request_room_change(&"CH3_UNDERKEEP_DESCENT", &"EntryWest"):
		_fail("underkeep transition rejected")
		return
	if not await _wait_for_room(controller, &"CH3_UNDERKEEP_DESCENT", 3.0):
		_fail("underkeep transition timed out")
		return
	player.global_position = Vector2(520.0, 584.0)
	player.player_camera.reset_smoothing()
	await _save("07_underkeep_inherited_main.png")
	player.health_component.take_damage(player.health_component.max_health)
	var death_sequence: PlayerDeathSequence = player.get_node("DeathSequence") as PlayerDeathSequence
	if not await _wait_for_death_phase(death_sequence, &"GhostPause", 3.0):
		_fail("death sequence did not reach GhostPause")
		return
	await _save("08_death_retains_equipment_main.png")
	if not await _wait_for_respawn(player, 2.0):
		_fail("Player did not respawn in Underkeep")
		return
	await _save("09_respawn_retains_equipment_main.png")
	if not controller._swap_room(&"CH3_POST_BOSS", &"EntryWest"):
		_fail("return visit to post-Boss room failed")
		return
	await process_frame
	await physics_frame
	post_room = controller.active_room as Chapter03PostBossRoom
	if (
		post_room == null
		or not post_room.reliquary.is_reward_collected()
		or post_room.reliquary.is_reward_available()
	):
		_fail("return visit did not preserve the empty reliquary")
		return
	player.global_position = Vector2(590.0, 584.0)
	player.player_camera.reset_smoothing()
	await _save("10_return_empty_reliquary_main.png")
	_config.reset_to_defaults()
	print((
		"THIRTEENFOLD_W5_MAIN_QA: PASS captures=%d states=reward/underkeep/return "
		+ "equipment=14/28 respawn=true duplicate=false"
	) % _capture_count)
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


func _wait_for_death_phase(
	sequence: PlayerDeathSequence, phase_name: StringName, timeout_seconds: float
) -> bool:
	var deadline: int = Time.get_ticks_msec() + roundi(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if sequence.get_phase_name() == phase_name:
			return true
	return false


func _wait_for_respawn(player: Player, timeout_seconds: float) -> bool:
	var deadline: int = Time.get_ticks_msec() + roundi(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if not player.is_dead():
			return true
	return false


func _capture_pose(
	player: Player,
	animation_name: StringName,
	frame_index: int,
	flip_h: bool,
	file_name: String
) -> void:
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	sprite.flip_h = flip_h
	sprite.play(animation_name)
	sprite.pause()
	sprite.frame = frame_index
	for _frame: int in range(4):
		await process_frame
	await _save(file_name)


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
	push_error("THIRTEENFOLD_W5_MAIN_QA: %s" % message)
	if _config != null:
		_config.reset_to_defaults()
	quit(1)
