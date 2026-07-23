extends SceneTree

## End-to-end smoke test for the dedicated one-guard combat room.

const ROOM_SCENE: PackedScene = preload("res://scenes/tools/combat_test_room.tscn")

var _failures: Array[String] = []
var _respawn_count: int = 0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var room: CombatTestRoom = ROOM_SCENE.instantiate() as CombatTestRoom
	get_root().add_child(room)
	await _wait_physics_frames(5)
	var player: Player = room.player
	var guard: CastleGuard = room.enemy
	var respawn: PlayerRespawnController = room.get_node(
		"PlayerRespawnController"
	) as PlayerRespawnController
	respawn.player_respawned.connect(_on_player_respawned)
	_expect(player != null and guard != null, "Combat room is missing Player or Castle Guard")
	_expect(room.debug_label != null, "Combat room debug label is missing")
	_expect(room.debug_toggle != null and room.reset_button != null, "Combat room debug/reset controls are missing")
	await _test_body_contact_has_no_damage(player, guard)
	await _test_enemy_damage_death_and_respawn(player, guard)
	room.queue_free()
	await process_frame
	_finish()


func _test_body_contact_has_no_damage(player: Player, guard: CastleGuard) -> void:
	var initial_health: int = player.health_component.current_health
	guard.detection_area.monitoring = false
	guard.clear_target()
	guard.attack_hitbox.end_attack()
	player.global_position = guard.global_position
	await _wait_physics_frames(3)
	_expect(player.health_component.current_health == initial_health, "Enemy body contact caused immediate damage")
	_expect(not guard.attack_hitbox.is_active, "Body-contact check retained sword Hitbox")


func _test_enemy_damage_death_and_respawn(player: Player, guard: CastleGuard) -> void:
	player.health_component.set_current_health(guard.get_attack_damage())
	guard.attack_hitbox.global_position = player.hurtbox.global_position
	guard.attack_hitbox.begin_attack(9901, guard.get_attack_damage())
	_expect(guard.attack_hitbox.try_hit(player.hurtbox), "Guard sword did not reach Player Hurtbox")
	_expect(player.health_component.current_health == 0, "Guard sword did not deal one five-point lethal hit")
	_expect(player.is_dead(), "Lethal enemy damage did not enter Player death state")
	_expect(player.hurtbox.health_component.is_dead() and player.is_dead(), "Player death state and Health diverged")
	guard.attack_hitbox.end_attack()
	await _wait_until_respawn(120)
	_expect(_respawn_count == 1, "Full death presentation did not produce one respawn")
	_expect(not player.is_dead(), "Player remained dead after combat-room respawn")
	_expect(player.health_component.current_health == player.health_component.max_health, "Respawn did not restore Player Health")
	_expect(
		player.global_position.distance_to(Vector2(260.0, 572.0)) < 0.1,
		"Combat-room respawn did not return Player to SpawnPoint"
	)


func _wait_until_respawn(maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		if _respawn_count > 0:
			return
		await physics_frame


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _on_player_respawned(_position: Vector2) -> void:
	_respawn_count += 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("COMBAT_TEST_ROOM_TEST: PASS (composition, no contact damage, enemy damage, death, respawn)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("COMBAT_TEST_ROOM_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
