extends SceneTree

## Death-state integration test for one-shot entry, lockout, HUD, and presentation handoff.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")

var _failures: Array[String] = []
var _death_state_events: int = 0
var _death_sequence_events: int = 0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_death_state_contract()
	_release_inputs()
	_finish()


func _test_death_state_contract() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	get_root().add_child(main)
	await _wait_physics_frames(5)
	var respawn_controller: PlayerRespawnController = main.get_node(
		"PlayerRespawnController"
	) as PlayerRespawnController
	respawn_controller.enabled = false
	var player: Player = main.get_node("World/Player") as Player
	var death_sequence: PlayerDeathSequence = player.get_node("DeathSequence") as PlayerDeathSequence
	var health: HealthComponent = player.health_component
	var stamina: PlayerStaminaComponent = player.stamina_component
	var damage_button: Button = main.get_node("Interface/DamageTestButton") as Button
	var death_overlay: Control = main.get_node("HUD/DeathOverlay") as Control
	var health_bar: ProgressBar = main.get_node("HUD/HealthContainer/HealthBar") as ProgressBar
	var health_value: Label = main.get_node("HUD/HealthContainer/HealthValue") as Label
	player.death_state_entered.connect(_on_death_state_entered)
	death_sequence.sequence_completed.connect(_on_death_sequence_completed)
	_expect(player.get_life_state_name() == &"Alive", "Player did not start Alive")
	_expect(not death_overlay.visible, "Death prompt was visible before death")
	Input.action_press(PlayerScript.DASH_ACTION)
	await physics_frame
	Input.action_release(PlayerScript.DASH_ACTION)
	await physics_frame
	_expect(player.action_controller.is_action_active(), "Pre-death Dash did not start")
	_expect(is_equal_approx(stamina.current_stamina, 75.0), "Pre-death Dash cost changed")
	for press_index: int in range(4):
		damage_button.pressed.emit()
	_expect(health.current_health == 0, "Four test-button presses did not reduce Health to zero")
	_expect(player.is_dead(), "Zero Health did not enter Player death state")
	_expect(_death_state_events == 1, "Player entered death state more than once")
	_expect(not player.action_controller.is_action_active(), "Death did not cancel the active action")
	_expect(player.velocity == Vector2.ZERO, "Death did not clear velocity")
	_expect(player.animation_controller.animated_sprite.animation == &"death", "Death animation was not selected")
	_expect(death_overlay.visible, "Death prompt did not become visible")
	_expect(is_equal_approx(health_bar.value, 0.0), "Health HUD did not show zero")
	_expect(health_value.text == "000 / 100", "Health numeric display did not show zero")
	var death_position: Vector2 = player.position
	var stamina_at_death: float = stamina.current_stamina
	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	Input.action_press(PlayerScript.JUMP_ACTION)
	Input.action_press(PlayerScript.DASH_ACTION)
	Input.action_press(PlayerScript.ATTACK_ACTION)
	await _wait_physics_frames(12)
	_release_inputs()
	_expect(player.position.distance_to(death_position) < 0.01, "Dead Player moved under Gameplay input")
	_expect(player.velocity == Vector2.ZERO, "Dead Player regained velocity")
	_expect(not player.action_controller.is_action_active(), "Dead Player started an action")
	_expect(is_equal_approx(stamina.current_stamina, stamina_at_death), "Dead Player consumed or regenerated Stamina")
	damage_button.pressed.emit()
	_expect(_death_state_events == 1, "Post-death damage repeated Player death entry")
	await _wait_until_death_sequence_completed(100)
	_expect(_death_sequence_events == 1, "Death presentation did not complete exactly once")
	_expect(
		player.animation_controller.animated_sprite.frame == 4,
		"Death presentation did not retain its horizontal final frame"
	)
	_expect(not death_sequence.ghost_sprite.visible, "Ghost was not cleaned after the death sequence")
	await _wait_physics_frames(20)
	_expect(_death_sequence_events == 1, "Death presentation completion repeated")
	_expect(player.is_dead(), "PLAYER-DEATH-001 incorrectly respawned the Player")
	main.queue_free()
	await process_frame


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _wait_until_death_sequence_completed(maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if _death_sequence_events > 0:
			return


func _on_death_state_entered() -> void:
	_death_state_events += 1


func _on_death_sequence_completed() -> void:
	_death_sequence_events += 1


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
		print("PLAYER_DEATH_STATE_TEST: PASS (single entry, lockout, full presentation, no respawn)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("PLAYER_DEATH_STATE_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
