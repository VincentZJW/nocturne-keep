extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null:
		return _fail_now("missing DebugRunConfig")
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	debug.debug_start_spawn_id = &"CH3_UNDERKEEP_DESCENT"
	if change_scene_to_file(BOOTSTRAP) != OK:
		return _fail_now("MainBootstrap failed")
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		return _fail_now("formal route failed to load")
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var player: Player = controller.player
	var area: Chapter03UnderkeepDescent = controller.active_room.get_node("UnderkeepDescent") as Chapter03UnderkeepDescent
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(420, 584)
	player.velocity = Vector2.ZERO
	await _physics_frames(4)
	var start_x: float = player.global_position.x
	Input.action_press(&"player_move_right")
	await _physics_frames(18)
	Input.action_release(&"player_move_right")
	_expect(player.global_position.x > start_x + 8.0, "Player can run through shallow water")
	_expect(area.effects_root.get_child_count() > 0, "run produces bounded water reaction")
	player.set("_jump_buffer_remaining", 0.12)
	var ground_jump_started: bool = bool(player.call("_try_consume_jump"))
	_expect(ground_jump_started and player.velocity.y < 0.0, "jump remains available in shallow water")
	player.global_position.y = 540.0
	await _physics_frames(2)
	player.set("_coyote_time_remaining", 0.0)
	player.air_jumps_remaining = 1
	player.set("_jump_buffer_remaining", 0.12)
	var double_jump_started: bool = bool(player.call("_try_consume_jump"))
	_expect(double_jump_started and player.air_jumps_remaining == 0, "double jump remains available and consumes one air jump")
	_reset_player(player, Vector2(700, 584))
	await _physics_frames(4)
	player.action_controller.try_start_actions(false, true, true, 1.0, false)
	_expect(player.action_controller.is_ground_dash_active(), "Ground Dash starts in shallow water")
	player.action_controller.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	player.stamina_component.reset_to_full()
	_reset_player(player, Vector2(920, 584))
	await _physics_frames(3)
	player.action_controller.try_start_actions(true, false, true, 0.0, false)
	_expect(player.action_controller.get_action_name() == &"attack", "Normal Attack starts in shallow water")
	player.action_controller.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	_reset_player(player, Vector2(1120, 584))
	await _physics_frames(3)
	player.action_controller.try_start_actions(true, true, true, 1.0, false)
	_expect(player.action_controller.is_dash_attack_active(), "Dash Attack starts in shallow water")
	_expect(area.effects_root.get_child_count() <= 10, "water reactions remain capped")
	debug.reset_to_defaults()
	Input.action_release(&"player_move_right")
	Input.action_release(&"player_jump")
	Input.action_release(&"dash")
	Input.action_release(&"attack")
	if _failures > 0:
		push_error("UNDERKEEP_PLAYER_ACTIONS_TEST FAIL count=%d" % _failures)
		quit(1)
		return
	print("UNDERKEEP_PLAYER_ACTIONS_TEST PASS run=true jump=true double_jump=true dash=true attack=true dash_attack=true")
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _index: int in range(900):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE:
			return current_scene as Chapter03Route
	return null


func _physics_frames(count: int) -> void:
	for _index: int in range(count):
		await physics_frame


func _reset_player(player: Player, position_value: Vector2) -> void:
	player.global_position = position_value
	player.velocity = Vector2.ZERO
	player.action_controller.cancel_all_actions()
	player.animation_controller.reset_to_idle()


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("UNDERKEEP_PLAYER_ACTIONS_TEST: %s" % message)


func _fail_now(message: String) -> void:
	push_error("UNDERKEEP_PLAYER_ACTIONS_TEST: %s" % message)
	quit(1)
