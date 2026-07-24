extends SceneTree

## Configured-Main bridge collision, moat death/respawn, and clear persistence contract.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	await _wait_physics_frames(8)
	var player: Player = main.get_node("World/Player") as Player
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	var boss: FallenGateKnight = main.get_node(
		"World/CastleEntranceArea/FallenGateKnight"
	) as FallenGateKnight
	var hazard: MoatHazard = main.get_node(
		"World/CastleEntranceArea/Moat/MoatHazard"
	) as MoatHazard
	await _test_bridge_underside(player, hazard)
	await _test_uncleared_moat_reset(player, room, boss, hazard)
	await _test_cleared_boss_persists(player, room, boss, hazard)
	main.queue_free()
	await process_frame
	_finish()


func _test_bridge_underside(player: Player, hazard: MoatHazard) -> void:
	hazard.monitoring = false
	player.global_position = Vector2(5960, 712)
	player.velocity = Vector2(0, -420)
	var minimum_root_y: float = player.global_position.y
	var ceiling_hit: bool = false
	for frame_index: int in range(40):
		await physics_frame
		minimum_root_y = minf(minimum_root_y, player.global_position.y)
		if player.is_on_ceiling():
			ceiling_hit = true
			break
	_expect(ceiling_hit, "WoodenBridge underside did not report a ceiling collision")
	_expect(minimum_root_y >= 683.0, "Player penetrated the 20-pixel solid bridge")
	_expect(player.velocity.y >= 0.0, "Bridge ceiling impact retained upward velocity")
	hazard.monitoring = true


func _test_uncleared_moat_reset(
	player: Player,
	room: BossRoomController,
	boss: FallenGateKnight,
	hazard: MoatHazard
) -> void:
	player.global_position = room.checkpoint.global_position
	player.velocity = Vector2.ZERO
	await _wait_physics_frames(4)
	room._on_checkpoint_body_entered(player)
	room._on_entry_body_entered(player)
	_expect(room.encounter_started and boss.is_ai_active(), "Bridge encounter did not start")
	player.global_position = Vector2(5540, 612)
	player.velocity = Vector2.ZERO
	for frame_index: int in range(90):
		await physics_frame
		if player.is_dead():
			break
	_expect(player.is_dead(), "Moat did not enter the existing Player death state")
	_expect(not hazard.is_armed(), "Moat one-shot guard did not disarm")
	await _wait_for_respawn(player)
	_expect(not player.is_dead(), "Moat death sequence did not respawn Player")
	_expect(player.global_position == room.checkpoint.global_position, "Moat respawn missed BossCheckpoint")
	_expect(not room.encounter_started and not boss.is_ai_active(), "Uncleared Boss did not reset after moat death")
	_expect(boss.health_component.current_health == boss.config.max_health, "Boss Body did not reset after moat death")
	_expect(
		boss.shield_component.shield_current_health == boss.config.boss_shield_max_health,
		"Boss Shield did not reset after moat death"
	)
	_expect(hazard.is_armed(), "Moat did not rearm after respawn")


func _test_cleared_boss_persists(
	player: Player,
	room: BossRoomController,
	boss: FallenGateKnight,
	hazard: MoatHazard
) -> void:
	room._on_entry_body_entered(player)
	boss.health_component.take_damage(boss.health_component.current_health)
	boss.animated_sprite.animation_finished.emit()
	room.castle_gate_controller.advance(1.3)
	_expect(room.room_is_cleared and boss.is_dead(), "Boss clear setup failed")
	player.global_position = Vector2(6320, 612)
	player.velocity = Vector2.ZERO
	Input.action_press(Player.MOVE_RIGHT_ACTION)
	for frame_index: int in range(120):
		await physics_frame
		if player.global_position.x >= 6426.0:
			break
	Input.action_release(Player.MOVE_RIGHT_ACTION)
	_expect(player.global_position.x >= 6426.0, "Opened CastleGate retained invisible blocking collision")
	hazard._on_body_entered(player)
	await _wait_for_respawn(player)
	_expect(not player.is_dead(), "Post-clear moat death did not respawn Player")
	_expect(room.room_is_cleared and boss.is_dead(), "Cleared Boss revived after later Player death")
	_expect(room.castle_gate_controller.is_gate_open(), "Cleared castle gate reclosed after later death")


func _wait_for_respawn(player: Player) -> void:
	for frame_index: int in range(240):
		await physics_frame
		if not player.is_dead():
			return


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CASTLE_BRIDGE_FLOW_TEST: PASS (solid underside, moat death/respawn, Boss reset/persistence)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CASTLE_BRIDGE_FLOW_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
