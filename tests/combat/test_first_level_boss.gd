extends SceneTree

## Deterministic Gargoyle/Boss/Main-room contract tests; feel still needs manual play.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	await _wait_physics_frames(4)
	var player: Player = main.get_node("World/Player") as Player
	var boss: FallenGateKnight = main.get_node("World/CastleEntranceArea/FallenGateKnight") as FallenGateKnight
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	var respawn: PlayerRespawnController = main.get_node("PlayerRespawnController") as PlayerRespawnController
	var hud: BossHealthHud = main.get_node("HUD/BossHealthHud") as BossHealthHud
	_test_main_structure(main, boss, room, hud)
	_test_room_entry(player, boss, room, respawn, hud)
	_test_boss_shield_and_phase(player, boss)
	_test_boss_attack_profiles(main, boss)
	_test_boss_death_and_exit(main, player, boss, room)
	_test_room_reset(player, boss, room, respawn)
	main.queue_free()
	await process_frame
	_finish()


func _test_main_structure(main: Node2D, boss: FallenGateKnight, room: BossRoomController, hud: BossHealthHud) -> void:
	_expect(boss != null and room != null and hud != null, "Main Boss composition is incomplete")
	_expect(main.has_node("World/CastleEntranceArea/BossCheckpoint"), "Main lacks pre-Boss checkpoint")
	_expect(main.has_node("World/CastleEntranceArea/Moat/MoatHazard"), "Main lacks moat hazard")
	_expect(main.has_node("World/CastleEntranceArea/WoodenBridge"), "Main lacks solid wooden bridge")
	_expect(main.has_node("World/CastleEntranceArea/RearBattleBarrier"), "Main lacks visible rear barrier")
	_expect(main.has_node("World/CastleEntranceArea/CastleGate"), "Main lacks castle gate")
	_expect(main.has_node("World/CastleEntranceArea/CastleEntranceTrigger"), "Main lacks castle entrance trigger")
	_expect(boss.global_position == Vector2(6120, 596), "Main Boss spawn coordinate changed")
	_expect(room.checkpoint.global_position == Vector2(5480, 612), "Main Boss checkpoint coordinate changed")
	_expect(boss.bridge_bounds_enabled, "Main Boss bridge bounds are not enabled")
	_expect(boss.get_bridge_bounds() == Vector2(5650, 6320), "Main Boss bridge bounds mismatch")
	var initial_boss_position: Vector2 = boss.global_position
	boss.global_position.x = 5600.0
	boss.velocity.x = -200.0
	boss._enforce_bridge_bounds()
	_expect(is_equal_approx(boss.global_position.x, 5650.0), "Boss crossed the left bridge bound")
	boss.global_position.x = 6380.0
	boss.velocity.x = 200.0
	boss._enforce_bridge_bounds()
	_expect(is_equal_approx(boss.global_position.x, 6320.0), "Boss crossed the right bridge bound")
	boss.global_position = initial_boss_position
	boss.velocity = Vector2.ZERO
	var bridge_collision: CollisionShape2D = main.get_node(
		"World/CastleEntranceArea/WoodenBridge/BridgeCollision"
	) as CollisionShape2D
	var bridge_shape: RectangleShape2D = bridge_collision.shape as RectangleShape2D
	_expect(not bridge_collision.one_way_collision, "Boss bridge is not solid")
	_expect(bridge_shape.size == Vector2(800, 20), "Boss bridge dimensions mismatch")
	_expect(room.castle_gate_controller.gate_audio.stream != null, "Castle gate placeholder audio was not built")
	var required_animations: Array[StringName] = [
		&"idle_shielded", &"walk_shielded", &"shield_block", &"shield_bash",
		&"sword_slash", &"heavy_overhead", &"hurt_shielded", &"shield_break",
		&"phase_transition", &"idle_unshielded", &"walk_unshielded", &"combo_slash_1",
		&"combo_slash_2", &"jump_smash", &"charge_thrust", &"shockwave_strike",
		&"hurt_unshielded", &"death",
	]
	for animation_name: StringName in required_animations:
		_expect(boss.animated_sprite.sprite_frames.has_animation(animation_name), "Boss animation missing: %s" % animation_name)
	_expect(boss.config.max_health == 18 and boss.config.shield_health == 6, "Boss Body/Shield balance mismatch")
	_expect(boss.config.shield_bash_damage == 8, "Boss Shield Bash damage mismatch")
	_expect(boss.config.sword_slash_damage == 10, "Boss Slash damage mismatch")
	_expect(boss.config.heavy_overhead_damage == 15, "Boss Heavy damage mismatch")
	_expect(boss.config.charge_thrust_damage == 12, "Boss Charge damage mismatch")
	_expect(boss.config.shockwave_damage == 8, "Boss Shockwave damage mismatch")


func _test_room_entry(player: Player, boss: FallenGateKnight, room: BossRoomController, respawn: PlayerRespawnController, hud: BossHealthHud) -> void:
	player.health_component.take_damage(20)
	player.stamina_component.try_consume_dash()
	room._on_entry_body_entered(player)
	_expect(room.room_is_locked and room.encounter_started, "Boss room did not lock on entry")
	_expect(boss.room_engaged and boss.is_ai_active(), "Boss did not activate")
	_expect(player.health_component.current_health == 100, "Boss entry did not restore Player Health")
	_expect(is_equal_approx(player.stamina_component.current_stamina, 100.0), "Boss entry did not restore Stamina")
	_expect(respawn.spawn_point == room.checkpoint, "Boss checkpoint did not become active respawn")
	_expect(hud.visible, "Boss HUD did not appear on combat start")
	_expect(room.rear_barrier.collision_layer == 1 and room.rear_barrier.visible, "Visible rear barrier did not close")
	_expect(room.castle_gate_controller.gate_body.collision_layer == 1, "Castle gate is not closed")
	_expect(player.player_camera.limit_left == 5340 and player.player_camera.limit_right == 6620, "Boss camera limits were not applied")


func _test_boss_shield_and_phase(player: Player, boss: FallenGateKnight) -> void:
	boss.set_physics_process(false)
	boss.set_facing_direction(-1.0)
	player.global_position = boss.global_position + Vector2(-55.0, 0.0)
	var normal: HitboxComponent = player.action_controller.attack_hitbox
	var dash: HitboxComponent = player.action_controller.dash_attack_hitbox
	for index: int in range(2):
		dash.begin_attack(70_000 + index, 2, 1.0, player)
		_expect(dash.try_hit(boss.hurtbox), "Boss frontal Dash did not reach Shield")
		dash.end_attack()
	_expect(boss.health_component.current_health == 18, "Boss Shield route leaked into Body")
	_expect(boss.shield_component.shield_current_health == 2, "Boss two Dashes did not reduce Shield 6→2")
	for index: int in range(2):
		normal.begin_attack(70_100 + index, 1, 1.0, player)
		_expect(normal.try_hit(boss.hurtbox), "Boss frontal normal Attack did not reach Shield")
		normal.end_attack()
	_expect(boss.shield_component.shield_current_health == 0, "Boss Shield did not break at zero")
	_expect(boss.health_component.current_health == 18, "Boss breaking hit overflowed into Body")
	_expect(boss.get_state_name() == &"ShieldBreak", "Boss did not enter ShieldBreak")
	boss._process_timed_state(0.91)
	_expect(boss.get_state_name() == &"PhaseTransition", "Boss did not enter phase transition")
	boss._process_timed_state(1.11)
	_expect(boss.current_phase == 2, "Boss did not enter Phase 2")
	_expect(boss.animated_sprite.animation == &"idle_unshielded", "Boss did not recover unshielded")
	normal.begin_attack(70_200, 1, 1.0, player)
	_expect(normal.try_hit(boss.hurtbox), "Post-break Boss Attack was rejected")
	normal.end_attack()
	_expect(boss.health_component.current_health == 17, "Post-break Boss Body did not take damage")


func _test_boss_death_and_exit(
	main: Node2D,
	player: Player,
	boss: FallenGateKnight,
	room: BossRoomController
) -> void:
	boss.health_component.take_damage(boss.health_component.current_health)
	_expect(boss.is_dead(), "Boss did not enter Death")
	_expect(boss.animated_sprite.animation == &"death", "Boss death animation did not play")
	_expect(boss.find_child("*Ghost*", true, false) == null, "Boss death incorrectly created a ghost")
	boss.animated_sprite.animation_finished.emit()
	_expect(room.room_is_cleared and not room.room_is_locked, "Boss defeat did not clear room")
	_expect(room.castle_gate_controller.gate_body.collision_layer == 1, "Castle gate collision released before animation clearance")
	room.castle_gate_controller.advance(1.1)
	_expect(room.castle_gate_controller.gate_body.collision_layer == 0, "Castle gate collision did not release after opening")
	_expect(room.gate_open_complete, "Castle gate completion state was not recorded")
	_expect(player.player_camera.limit_left == 0 and player.player_camera.limit_right == 6600, "Boss camera limits did not release")
	var message: Label = main.get_node("HUD/LevelCompletePanel/Message") as Label
	_expect(message.text.contains("castle gate is open"), "Boss clear message missing")
	room._on_castle_entrance_body_entered(room.player)
	_expect(message.text.contains("CHAPTER I COMPLETE"), "Castle entrance did not complete Chapter I")


func _test_boss_attack_profiles(main: Node2D, boss: FallenGateKnight) -> void:
	var target_root: Node2D = Node2D.new()
	var target_health: HealthComponent = HealthComponent.new()
	var target_hurtbox: HurtboxComponent = HurtboxComponent.new()
	target_health.name = "HealthComponent"
	target_health.max_health = 100
	target_hurtbox.name = "Hurtbox"
	target_hurtbox.faction = &"player"
	target_hurtbox.health_component_path = NodePath("../HealthComponent")
	target_root.add_child(target_health)
	target_root.add_child(target_hurtbox)
	main.add_child(target_root)
	var profiles: Array[Dictionary] = [
		{"state": FallenGateKnight.SHIELD_BASH, "frame": 2, "damage": 8, "shock": false, "phase": 1},
		{"state": FallenGateKnight.SWORD_SLASH, "frame": 2, "damage": 10, "shock": false, "phase": 1},
		{"state": FallenGateKnight.HEAVY_OVERHEAD, "frame": 3, "damage": 15, "shock": false, "phase": 1},
		{"state": FallenGateKnight.COMBO_SLASH, "frame": 2, "damage": 10, "shock": false, "phase": 2},
		{"state": FallenGateKnight.JUMP_SMASH, "frame": 3, "damage": 15, "shock": false, "phase": 2},
		{"state": FallenGateKnight.CHARGE_THRUST, "frame": 2, "damage": 12, "shock": false, "phase": 2},
		{"state": FallenGateKnight.SHOCKWAVE_STRIKE, "frame": 3, "damage": 8, "shock": true, "phase": 2},
	]
	for profile: Dictionary in profiles:
		target_health.reset_to_full()
		boss.current_phase = profile["phase"] as int
		boss.current_state = FallenGateKnight.IDLE_SHIELDED if boss.current_phase == 1 else FallenGateKnight.IDLE_UNSHIELDED
		boss._start_attack(profile["state"] as StringName)
		boss.animated_sprite.frame = profile["frame"] as int
		boss._on_animation_frame_changed()
		var use_shockwave: bool = profile["shock"] as bool
		var expected_damage: int = profile["damage"] as int
		var hitbox: HitboxComponent = boss.shockwave_hitbox if use_shockwave else boss.melee_hitbox
		_expect(hitbox.is_active, "%s did not open its active frame" % profile["state"])
		_expect(hitbox.try_hit(target_hurtbox), "%s did not hit target" % profile["state"])
		_expect(target_health.current_health == 100 - expected_damage, "%s damage mismatch" % profile["state"])
		_expect(not hitbox.try_hit(target_hurtbox), "%s hit the same target twice" % profile["state"])
		boss._end_attack_window()
	target_root.queue_free()


func _test_room_reset(player: Player, boss: FallenGateKnight, room: BossRoomController, respawn: PlayerRespawnController) -> void:
	room.room_is_cleared = false
	room.encounter_started = true
	room.room_is_locked = true
	boss.reset_boss()
	boss.activate(player)
	boss.health_component.take_damage(5)
	respawn.player_respawned.emit(room.checkpoint.global_position)
	_expect(not room.encounter_started and not room.room_is_locked, "Player respawn did not reset Boss room")
	_expect(boss.health_component.current_health == 18, "Boss reset did not restore Body Health")
	_expect(boss.shield_component.shield_current_health == 6, "Boss reset did not restore Shield")
	_expect(not boss.is_ai_active(), "Boss reset left AI active")
	_expect(room.rear_barrier.collision_layer == 0, "Boss reset did not reopen rear barrier")
	_expect(room.castle_gate_controller.gate_body.collision_layer == 1, "Boss reset did not close castle gate")
	_expect(not room.gate_open_complete, "Boss reset retained gate completion")


func _wait_physics_frames(count: int) -> void:
	for _index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("FIRST_LEVEL_BOSS_TEST: PASS (shield routing, phase, room lock/reset, death/exit)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("FIRST_LEVEL_BOSS_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
