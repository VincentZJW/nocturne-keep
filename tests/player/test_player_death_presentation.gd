extends SceneTree

## Death body, released daggers, ghost rise/pause, cleanup, and lockout timing test.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")

var _failures: Array[String] = []
var _sequence_started_events: int = 0
var _body_completed_events: int = 0
var _ghost_emerged_events: int = 0
var _ghost_pause_events: int = 0
var _sequence_completed_events: int = 0
var _sequence_started_frame: int = -1
var _ghost_pause_started_frame: int = -1
var _sequence_completed_frame: int = -1
var _reported_pause_duration: float = -1.0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_death_presentation_contract()
	_release_inputs()
	_finish()


func _test_death_presentation_contract() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	get_root().add_child(main)
	await _wait_physics_frames(5)
	var respawn_controller: PlayerRespawnController = main.get_node(
		"PlayerRespawnController"
	) as PlayerRespawnController
	respawn_controller.enabled = false
	var player: Player = main.get_node("World/Player") as Player
	var health: HealthComponent = player.health_component
	var death_sequence: PlayerDeathSequence = player.get_node("DeathSequence") as PlayerDeathSequence
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	var ghost: Sprite2D = death_sequence.ghost_sprite
	death_sequence.sequence_started.connect(_on_sequence_started)
	death_sequence.body_animation_completed.connect(_on_body_animation_completed)
	death_sequence.ghost_emerged.connect(_on_ghost_emerged)
	death_sequence.ghost_pause_started.connect(_on_ghost_pause_started)
	death_sequence.sequence_completed.connect(_on_sequence_completed)
	_expect(is_equal_approx(death_sequence.ghost_emerge_duration, 0.35), "Ghost emerge duration changed")
	_expect(is_equal_approx(death_sequence.ghost_pause_duration, 0.50), "Ghost pause is not 0.50 seconds")
	_expect(
		death_sequence.ghost_rise_distance >= 8.0 and death_sequence.ghost_rise_distance <= 16.0,
		"Ghost rise distance is outside 8–16 pixels"
	)
	health.take_damage(health.max_health)
	await physics_frame
	_expect(player.is_dead(), "Lethal damage did not enter Dead")
	_expect(_sequence_started_events == 1, "Death sequence did not start exactly once")
	_expect(death_sequence.get_phase_name() == &"BodyFall", "Death sequence did not start with body fall")
	_expect(sprite.animation == &"death", "Body death animation did not start")
	_expect(not ghost.visible, "Ghost appeared before body fall completed")
	var death_position: Vector2 = player.global_position
	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	Input.action_press(PlayerScript.JUMP_ACTION)
	Input.action_press(PlayerScript.DASH_ACTION)
	Input.action_press(PlayerScript.ATTACK_ACTION)
	await _wait_physics_frames(8)
	_release_inputs()
	_expect(player.global_position.distance_to(death_position) < 0.01, "Dead Player moved under input")
	_expect(not player.action_controller.is_action_active(), "Dead Player started an action")
	await _wait_until_counter(&"body", 40)
	_expect(_body_completed_events == 1, "Body animation did not complete exactly once")
	_expect(sprite.frame == 4, "Body did not reach death_05 horizontal corpse frame")
	_expect(ghost.visible, "Ghost did not appear after the body animation")
	_expect(death_sequence.get_phase_name() == &"GhostEmerge", "Ghost did not enter emerge phase")
	var ghost_start_y: float = ghost.position.y
	await _wait_physics_frames(6)
	_expect(ghost.position.y < ghost_start_y, "Ghost did not begin moving upward")
	await _wait_until_counter(&"ghost", 30)
	_expect(_ghost_emerged_events == 1, "Ghost did not finish emerging exactly once")
	_expect(death_sequence.get_phase_name() == &"GhostPause", "Ghost did not enter pause phase")
	_expect(
		absf(ghost.position.y - death_sequence.get_ghost_end_position().y) < 0.1,
		"Ghost did not rise the configured distance"
	)
	_expect(ghost.visible, "Ghost disappeared before its pause")
	_expect(_ghost_pause_events == 1, "Ghost pause did not start exactly once")
	_expect(is_equal_approx(_reported_pause_duration, 0.50), "Ghost pause signal did not report 0.50 seconds")
	await _wait_physics_frames(20)
	_expect(_sequence_completed_events == 0, "Death sequence completed before the 0.50-second pause")
	_expect(ghost.visible, "Ghost was hidden during the required pause")
	await _wait_until_counter(&"sequence", 20)
	_expect(_sequence_completed_events == 1, "Death sequence did not complete exactly once")
	_expect(
		_sequence_completed_frame - _ghost_pause_started_frame >= 29,
		"Ghost pause lasted less than approximately 0.50 seconds"
	)
	_expect(
		_sequence_completed_frame - _sequence_started_frame >= 72,
		"Full death flow completed too early"
	)
	_expect(not death_sequence.is_active(), "Death sequence remained active after completion")
	_expect(not ghost.visible, "Ghost was not cleaned after completion")
	_expect(player.is_dead(), "Disabled respawn controller still respawned the Player")
	_expect(sprite.animation == &"death" and sprite.frame == 4, "Corpse did not remain flat before respawn")
	health.take_damage(25)
	await _wait_physics_frames(5)
	_expect(_sequence_started_events == 1, "Repeated dead-state damage spawned another sequence")
	main.queue_free()
	await process_frame


func _wait_until_counter(counter_name: StringName, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if counter_name == &"body" and _body_completed_events > 0:
			return
		if counter_name == &"ghost" and _ghost_emerged_events > 0:
			return
		if counter_name == &"sequence" and _sequence_completed_events > 0:
			return


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _on_sequence_started() -> void:
	_sequence_started_events += 1
	_sequence_started_frame = Engine.get_physics_frames()


func _on_body_animation_completed() -> void:
	_body_completed_events += 1


func _on_ghost_emerged() -> void:
	_ghost_emerged_events += 1


func _on_ghost_pause_started(duration: float) -> void:
	_ghost_pause_events += 1
	_reported_pause_duration = duration
	_ghost_pause_started_frame = Engine.get_physics_frames()


func _on_sequence_completed() -> void:
	_sequence_completed_events += 1
	_sequence_completed_frame = Engine.get_physics_frames()


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
		print("PLAYER_DEATH_PRESENTATION_TEST: PASS (flat body, released daggers, ghost rise/pause, cleanup)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("PLAYER_DEATH_PRESENTATION_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
