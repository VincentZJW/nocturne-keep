extends SceneTree

## PLAYER-RESPAWN-001 integration test for delayed, repeatable single-point respawn.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")

var _failures: Array[String] = []
var _respawn_events: int = 0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_delayed_respawn_contract()
	_release_inputs()
	_finish()


func _test_delayed_respawn_contract() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	get_root().add_child(main)
	await _wait_physics_frames(5)
	var player: Player = main.get_node("World/Player") as Player
	var death_sequence: PlayerDeathSequence = player.get_node("DeathSequence") as PlayerDeathSequence
	var spawn_point: Marker2D = main.get_node("World/DarkForestTutorialSpawn") as Marker2D
	var respawn_controller: PlayerRespawnController = main.get_node(
		"PlayerRespawnController"
	) as PlayerRespawnController
	var health: HealthComponent = player.health_component
	var stamina: PlayerStaminaComponent = player.stamina_component
	var death_overlay: Control = main.get_node("HUD/DeathOverlay") as Control
	var health_bar: ProgressBar = main.get_node("HUD/HealthContainer/HealthBar") as ProgressBar
	var health_value: Label = main.get_node("HUD/HealthContainer/HealthValue") as Label
	var stamina_bar: ProgressBar = main.get_node("HUD/StaminaContainer/StaminaBar") as ProgressBar
	var stamina_value: Label = main.get_node("HUD/StaminaContainer/StaminaValue") as Label
	var camera: Camera2D = player.get_node("Camera2D") as Camera2D
	respawn_controller.player_respawned.connect(_on_player_respawned)
	_expect(spawn_point != null, "Main is missing DarkForestTutorialSpawn")
	_expect(camera != null and camera.get_parent() == player, "Camera no longer follows the Player instance")
	player.global_position = spawn_point.global_position + Vector2(420.0, -80.0)
	_expect(stamina.try_consume_dash(), "Pre-death Stamina setup failed")
	player.velocity = Vector2(180.0, -240.0)
	health.take_damage(health.max_health)
	await physics_frame
	_expect(player.is_dead(), "Lethal damage did not enter death before the delay")
	_expect(death_overlay.visible, "Death prompt was not visible during the delay")
	_expect(_respawn_events == 0, "Respawn happened before the configured delay")
	await _wait_until_respawned(120)
	_expect(_respawn_events == 1, "First death did not produce exactly one respawn")
	_expect(not player.is_dead(), "Player remained dead after respawn")
	_expect(
		player.global_position.distance_to(spawn_point.global_position) < 0.01,
		"Player did not return to SpawnPoint"
	)
	_expect(player.velocity == Vector2.ZERO, "Respawn did not clear Player velocity")
	_expect(is_zero_approx(player.get_coyote_time_remaining()), "Respawn retained coyote time")
	_expect(is_zero_approx(player.get_jump_buffer_remaining()), "Respawn retained jump input")
	_expect(player.air_jumps_remaining == 1, "Respawn did not restore the Debug air jump")
	_expect(health.current_health == health.max_health, "Respawn did not restore Health")
	_expect(
		is_equal_approx(stamina.current_stamina, stamina.max_stamina),
		"Respawn did not restore Stamina"
	)
	_expect(is_zero_approx(stamina.stamina_regen_timer), "Respawn did not clear Stamina delay")
	_expect(not player.action_controller.is_action_active(), "Respawn retained an active action")
	_expect(not death_sequence.is_active(), "Respawn retained an active death presentation")
	_expect(not death_sequence.ghost_sprite.visible, "Respawn retained the ghost visual")
	_expect(player.get_movement_state_name() == &"idle", "Respawn did not restore idle state")
	_expect(player.animation_controller.animated_sprite.animation == &"idle", "Respawn did not restore idle presentation")
	_expect(not death_overlay.visible, "Death prompt remained visible after respawn")
	_expect(is_equal_approx(health_bar.value, 100.0), "Health HUD did not restore after respawn")
	_expect(health_value.text == "100 / 100", "Health numeric HUD did not restore after respawn")
	_expect(is_equal_approx(stamina_bar.value, 100.0), "Stamina HUD did not restore after respawn")
	_expect(stamina_value.text == "100 / 100", "Stamina numeric HUD did not restore after respawn")
	await _wait_physics_frames(20)
	_expect(_respawn_events == 1, "First death produced a duplicate respawn")
	var position_before_move: Vector2 = player.global_position
	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	await _wait_physics_frames(8)
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	_expect(player.global_position.x > position_before_move.x, "Player input did not recover after respawn")
	player.global_position = spawn_point.global_position + Vector2(260.0, 0.0)
	_expect(stamina.try_consume_dash(), "Second-cycle Stamina setup failed")
	health.take_damage(health.max_health)
	await _wait_until_respawned(120)
	_expect(_respawn_events == 2, "Second death did not produce exactly one new respawn")
	_expect(not player.is_dead(), "Player remained dead after the second respawn")
	_expect(
		player.global_position.distance_to(spawn_point.global_position) < 0.01,
		"Second respawn did not return to SpawnPoint"
	)
	_expect(health.current_health == health.max_health, "Second respawn did not restore Health")
	_expect(
		is_equal_approx(stamina.current_stamina, stamina.max_stamina),
		"Second respawn did not restore Stamina"
	)
	await _wait_physics_frames(20)
	_expect(_respawn_events == 2, "Second death produced a duplicate respawn")
	main.queue_free()
	await process_frame


func _wait_until_respawned(maximum_frames: int) -> void:
	var initial_count: int = _respawn_events
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if _respawn_events > initial_count:
			return


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _on_player_respawned(_global_spawn_position: Vector2) -> void:
	_respawn_events += 1


func _release_inputs() -> void:
	for action_name: StringName in [
		PlayerScript.MOVE_LEFT_ACTION,
		PlayerScript.MOVE_RIGHT_ACTION,
		PlayerScript.JUMP_ACTION,
		PlayerScript.DASH_ACTION,
		PlayerScript.ATTACK_ACTION,
	]:
		Input.action_release(action_name)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PLAYER_RESPAWN_TEST: PASS (delay, reset, HUD, repeat cycle, input recovery)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("PLAYER_RESPAWN_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
