extends SceneTree

## Runtime composition and combat proof for the configured F5 Main scene.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const EXPECTED_MAIN_PATH: String = "res://scenes/main/main.tscn"
const NEAR_SPAWN: Vector2 = Vector2(500.0, 610.0)
const FAR_SPAWN: Vector2 = Vector2(850.0, 610.0)

var _failures: Array[String] = []
var _guard_presentation_finished: bool = false
var _guard_tree_exited: bool = false


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "") == EXPECTED_MAIN_PATH,
		"F5 project Main does not resolve to %s" % EXPECTED_MAIN_PATH
	)
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	var player: Player = main.get_node_or_null("World/Player") as Player
	var enemies: Node2D = main.get_node_or_null("World/Enemies") as Node2D
	var near_guard: CastleGuard = main.get_node_or_null(
		"World/Enemies/CursedGuardNear"
	) as CastleGuard
	var far_guard: CastleGuard = main.get_node_or_null(
		"World/Enemies/CursedGuardFar"
	) as CastleGuard
	_expect(player != null, "Main is missing Player")
	_expect(enemies != null, "Main is missing the Enemies container")
	_expect(near_guard != null and far_guard != null, "Main is missing one or both Castle Guard instances")
	if player == null or enemies == null or near_guard == null or far_guard == null:
		main.queue_free()
		_finish()
		return
	_expect(near_guard.position == NEAR_SPAWN, "Near Guard saved spawn is not (500, 610)")
	_expect(far_guard.position == FAR_SPAWN, "Far Guard saved spawn is not (850, 610)")
	_expect(main.has_node("Interface/EnemyDebugPanel/EnemyDebug"), "Main enemy debug display is missing")
	get_root().add_child(main)
	await _wait_physics_frames(8)
	_test_runtime_composition(main, player, near_guard, far_guard)
	await _test_main_ai_attack(player, near_guard)
	await _test_player_damage_sources(player, far_guard)
	await _test_guard_damage_and_death(player, near_guard)
	main.queue_free()
	await process_frame
	_finish()


func _test_runtime_composition(
	main: Node2D,
	player: Player,
	near_guard: CastleGuard,
	far_guard: CastleGuard
) -> void:
	_expect(player.player_camera.enabled, "Player Camera2D is not enabled")
	_expect(main.get_viewport().get_camera_2d() == player.player_camera, "Player Camera2D is not the active runtime camera")
	for guard: CastleGuard in [near_guard, far_guard]:
		_expect(guard.is_inside_tree(), "%s is absent from the runtime SceneTree" % guard.name)
		_expect(guard.visible and not guard.is_dead(), "%s started hidden or dead" % guard.name)
		_expect(guard.animated_sprite.is_playing(), "%s animation is not playing" % guard.name)
		_expect(guard.health_component.current_health == 3, "%s did not start at 3 Health" % guard.name)
		_expect(guard.collision_layer == 4 and guard.collision_mask == 3, "%s body collision contract changed" % guard.name)
		_expect(guard.hurtbox.collision_layer == 16 and guard.hurtbox.collision_mask == 32, "%s Hurtbox layers are invalid" % guard.name)
		_expect(guard.attack_hitbox.collision_layer == 64 and guard.attack_hitbox.collision_mask == 8, "%s sword Hitbox layers are invalid" % guard.name)
	_expect(near_guard.target == player, "Near Guard did not acquire the Player inside 180px detection")
	_expect(far_guard.target == null, "Far Guard acquired the Player too early")
	print(
		"MAIN_RUNTIME_AUDIT: player=%s camera=%s near=%s pos=%s visible=%s state=%s anim=%s:%d hp=%d target=%s far=%s pos=%s visible=%s state=%s anim=%s:%d hp=%d target=%s" % [
			player.get_path(),
			player.player_camera.get_path(),
			near_guard.get_path(),
			near_guard.global_position,
			near_guard.visible,
			near_guard.get_state_name(),
			near_guard.animated_sprite.animation,
			near_guard.animated_sprite.frame + 1,
			near_guard.health_component.current_health,
			near_guard.target != null,
			far_guard.get_path(),
			far_guard.global_position,
			far_guard.visible,
			far_guard.get_state_name(),
			far_guard.animated_sprite.animation,
			far_guard.animated_sprite.frame + 1,
			far_guard.health_component.current_health,
			far_guard.target != null,
		]
	)


func _test_main_ai_attack(player: Player, guard: CastleGuard) -> void:
	var health_before: int = player.health_component.current_health
	for frame_index: int in range(180):
		if player.health_component.current_health < health_before:
			break
		await physics_frame
	_expect(
		player.health_component.current_health == health_before - 1,
		"Near Guard AI did not deliver exactly one sword hit in Main"
	)
	_expect(guard.target == player, "Near Guard lost its valid Player target during the Main attack test")


func _test_player_damage_sources(player: Player, guard: CastleGuard) -> void:
	guard.detection_area.set_deferred("monitoring", false)
	guard.clear_target()
	player.set_physics_process(false)
	guard.set_physics_process(false)
	guard.health_component.reset_to_full()
	var actions: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	_expect(actions.try_start_actions(true, false, true, 1.0, false), "Main Player could not start normal Attack")
	sprite.frame = 1
	sprite.frame_changed.emit()
	_expect(actions.attack_hitbox.try_hit(guard.hurtbox), "Main Player normal Attack did not hit Guard")
	_expect(guard.health_component.current_health == 2, "Main normal Attack did not deal exactly one damage")
	actions.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	guard.health_component.reset_to_full()
	_expect(actions.try_start_actions(true, true, true, 1.0, false), "Main Player could not start Dash Attack")
	sprite.frame = 2
	sprite.frame_changed.emit()
	_expect(actions.dash_attack_hitbox.try_hit(guard.hurtbox), "Main Player Dash Attack did not hit Guard")
	_expect(guard.health_component.current_health == 1, "Main Dash Attack did not deal exactly two damage")
	actions.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	guard.set_physics_process(true)
	player.set_physics_process(true)


func _test_guard_damage_and_death(player: Player, guard: CastleGuard) -> void:
	guard.presentation_finished.connect(_on_guard_presentation_finished)
	guard.tree_exited.connect(_on_guard_tree_exited)
	guard.set_physics_process(false)
	player.set_physics_process(false)
	player.health_component.reset_to_full()
	guard.attack_hitbox.global_position = player.hurtbox.global_position
	guard.attack_hitbox.begin_attack(8801, 1)
	_expect(guard.attack_hitbox.try_hit(player.hurtbox), "Main Guard sword did not hit Player Hurtbox")
	_expect(player.health_component.current_health == 99, "Main Guard sword did not deal exactly one damage")
	guard.attack_hitbox.end_attack()
	guard.health_component.take_damage(guard.health_component.current_health)
	_expect(guard.get_state_name() == &"Death", "Lethal damage did not enter Guard Death")
	_expect(not guard.hurtbox.is_enabled and not guard.attack_hitbox.is_active, "Dead Guard retained a combat area")
	guard.set_physics_process(true)
	player.set_physics_process(true)
	await _wait_physics_frames(50)
	_expect(_guard_presentation_finished, "Main Guard Death/dissolve did not complete")
	_expect(_guard_tree_exited, "Completed Main Guard did not leave the runtime SceneTree")
	_expect(not is_instance_valid(guard), "Completed Main Guard node was not freed")


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _on_guard_presentation_finished() -> void:
	_guard_presentation_finished = true


func _on_guard_tree_exited() -> void:
	_guard_tree_exited = true


func _finish() -> void:
	if _failures.is_empty():
		print("MAIN_ENEMY_INTEGRATION_TEST: PASS (F5 composition, runtime audit, Player 1/2 damage, Guard damage/Death)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("MAIN_ENEMY_INTEGRATION_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
