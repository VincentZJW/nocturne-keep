extends SceneTree

## Deterministic Gargoyle/Boss/Main-room contract tests; feel still needs manual play.

const MAIN_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn")

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
	_test_boss_turn_response(player, boss)
	_test_boss_shield_and_phase(player, boss, hud)
	await _test_boss_attack_profiles(main, boss)
	await _test_gate_severance_repetition(boss)
	_test_boss_death_and_exit(main, player, boss, room)
	_test_room_reset(player, boss, room, respawn)
	main.queue_free()
	await process_frame
	_finish()


func _test_main_structure(main: Node2D, boss: FallenGateKnight, room: BossRoomController, hud: BossHealthHud) -> void:
	_expect(boss != null and room != null and hud != null, "Main Boss composition is incomplete")
	_expect(main.has_node("World/CastleEntranceArea/BossCheckpoint"), "Main lacks pre-Boss checkpoint")
	_expect(main.has_node("World/CastleEntranceArea/Moat/MoatHazard"), "Main lacks moat hazard")
	for water_node_name: String in [
		"WaterVisual", "WaterDepth", "WaterSurfaceBand", "WaterReflection",
		"WaterRippleMid", "WaterRippleFar", "BridgeShadow", "NearStoneBank", "FarStoneBank",
	]:
		_expect(
			main.has_node("World/CastleEntranceArea/Moat/%s" % water_node_name),
			"Main moat lacks presentation layer %s" % water_node_name
		)
	var water_visual: Polygon2D = main.get_node(
		"World/CastleEntranceArea/Moat/WaterVisual"
	) as Polygon2D
	_expect(
		water_visual.color.b > water_visual.color.r * 3.0
		and water_visual.color.g > water_visual.color.r * 3.0,
		"Main moat no longer reads as blue/teal water"
	)
	_expect(main.has_node("World/CastleEntranceArea/WoodenBridge"), "Main lacks solid wooden bridge")
	_expect(main.has_node("World/CastleEntranceArea/RearBattleBarrier"), "Main lacks visible rear barrier")
	_expect(main.has_node("World/CastleEntranceArea/CastleGate"), "Main lacks castle gate")
	_expect(main.has_node("World/CastleEntranceArea/CastleEntranceTrigger"), "Main lacks castle entrance trigger")
	_expect(main.has_node("World/LateLevelApproachArt"), "Main lacks late-level Gothic approach art")
	_expect(main.has_node("World/LateLevelSurfaceDetails"), "Main lacks late-level surface details")
	_expect(main.has_node("World/BossCastleBackdrop"), "Main lacks monumental Boss castle backdrop")
	_expect(main.has_node("World/RavenmournArchway"), "Main lacks Ravenmourn approach archway")
	_expect(
		main.has_node("World/CastleEntranceArea/WoodenBridge/DetailedBridgeArt"),
		"Main lacks detailed bridge presentation"
	)
	_expect(
		main.has_node("World/CastleEntranceArea/CastleGate/GateVisual/DetailedGateArt"),
		"Main lacks detailed moving gate presentation"
	)
	var castle_name: Label = main.get_node("World/RavenmournArchway/CastleName") as Label
	_expect(castle_name.text == "RAVENMOURN CASTLE", "Approach archway castle name mismatch")
	_expect(not main.has_node("HUD/LevelCompletePanel"), "Obsolete chapter-complete panel still ships in Main")
	var transition: CastleEntranceTransition = main.get_node(
		"CastleEntranceTransition"
	) as CastleEntranceTransition
	_expect(
		transition.target_scene_path == "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn",
		"Castle entrance transition target mismatch"
	)
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
		&"turn_shielded", &"turn_unshielded",
		&"sword_slash", &"heavy_overhead", &"hurt_shielded", &"shield_break",
		&"phase_transition", &"idle_unshielded", &"walk_unshielded", &"combo_slash_1",
		&"combo_slash_2", &"jump_smash", &"charge_thrust", &"shockwave_strike",
		&"hurt_unshielded", &"death",
	]
	for animation_name: StringName in required_animations:
		_expect(boss.animated_sprite.sprite_frames.has_animation(animation_name), "Boss animation missing: %s" % animation_name)
	_expect(
		boss.config.max_health == 180 and boss.config.boss_shield_max_health == 100,
		"Boss Body/Shield balance mismatch"
	)
	_expect(is_equal_approx(boss.config.boss_turn_reaction_delay, 0.33), "Boss turn reaction mismatch")
	_expect(is_equal_approx(boss.config.boss_turn_animation_duration, 0.80), "Boss turn animation mismatch")
	_expect(is_equal_approx(boss.config.boss_turn_cooldown, 0.14), "Boss turn cooldown mismatch")
	_expect(is_equal_approx(boss.config.boss_turn_facing_commit_ratio, 0.80), "Boss turn commit ratio mismatch")
	_expect(is_equal_approx(boss.config.turn_side_threshold, 12.0), "Boss turn threshold mismatch")
	_expect(is_equal_approx(boss.config.attack_recovery, 0.42), "Boss attack recovery mismatch")
	_expect(is_equal_approx(boss.config.shield_bash_attack_gap, 1.18), "Shield Bash gap mismatch")
	_expect(is_equal_approx(boss.config.sword_slash_attack_gap, 1.05), "Sword Slash gap mismatch")
	_expect(is_equal_approx(boss.config.heavy_overhead_attack_gap, 1.20), "Heavy gap mismatch")
	_expect(is_equal_approx(boss.config.combo_slash_attack_gap, 1.05), "Combo gap mismatch")
	_expect(is_equal_approx(boss.config.charge_thrust_attack_gap, 1.12), "Charge gap mismatch")
	_expect(is_equal_approx(boss.config.jump_smash_attack_gap, 1.16), "Jump gap mismatch")
	_expect(is_equal_approx(boss.config.shockwave_strike_attack_gap, 1.10), "Shockwave gap mismatch")
	_expect(is_equal_approx(boss.config.boss_light_hit_reaction_cooldown, 0.32), "Boss light reaction cooldown mismatch")
	_expect(is_equal_approx(boss.config.boss_heavy_hit_reaction_cooldown, 0.50), "Boss heavy reaction cooldown mismatch")
	_expect(boss.config.shield_bash_damage == 8, "Boss Shield Bash damage mismatch")
	_expect(boss.config.sword_slash_damage == 10, "Boss Slash damage mismatch")
	_expect(boss.config.heavy_overhead_damage == 15, "Boss Heavy damage mismatch")
	_expect(boss.config.charge_thrust_damage == 12, "Boss Charge damage mismatch")
	_expect(boss.config.shockwave_damage == 8, "Boss Shockwave damage mismatch")
	var expected_speeds: Dictionary[StringName, float] = {
		&"shield_bash": 10.0,
		&"sword_slash": 9.8,
		&"heavy_overhead": 8.8,
		&"combo_slash_1": 12.0,
		&"combo_slash_2": 12.0,
		&"jump_smash": 9.8,
		&"charge_thrust": 11.0,
		&"shockwave_strike": 8.8,
		&"turn_shielded": 23.076923,
		&"turn_unshielded": 23.076923,
	}
	for animation_name: StringName in expected_speeds:
		_expect(
			is_equal_approx(
				boss.animated_sprite.sprite_frames.get_animation_speed(animation_name),
				expected_speeds[animation_name]
			),
			"Boss animation cadence mismatch: %s" % animation_name
		)


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


func _test_boss_turn_response(player: Player, boss: FallenGateKnight) -> void:
	boss.set_physics_process(false)
	boss.current_phase = 1
	boss.current_state = FallenGateKnight.APPROACH_SHIELDED
	boss.state_timer = 0.0
	boss.set_target(player)
	boss.set_facing_direction(-1.0)
	boss._interrupt_turn()
	boss._turn_cooldown_timer = 0.0
	player.global_position = boss.global_position + Vector2(120.0, 0.0)
	var step: float = 1.0 / 60.0
	var elapsed: float = 0.0
	var facing_commit_elapsed: float = -1.0
	var saw_turn_animation: bool = false
	while not boss._turn_commit_queued and elapsed < 1.40:
		if boss.current_state in [FallenGateKnight.TURN_SHIELDED, FallenGateKnight.TURN_UNSHIELDED]:
			saw_turn_animation = true
			boss._process_turn_state(step)
		else:
			boss._process_approach(step)
		elapsed += step
		if facing_commit_elapsed < 0.0 and boss.facing_direction > 0.0:
			facing_commit_elapsed = elapsed
	_expect(saw_turn_animation, "Boss did not enter authored Turn state")
	_expect(
		elapsed >= 1.00 and elapsed <= 1.30,
		"Boss turn completed outside 1.00-1.30 seconds: %.4f" % elapsed
	)
	_expect(
		facing_commit_elapsed >= boss.config.boss_turn_reaction_delay + boss.config.boss_turn_animation_duration * 0.70,
		"Boss facing committed before 70%% of the turn animation: %.4f" % facing_commit_elapsed
	)
	_expect(boss.facing_direction > 0.0, "Boss did not commit facing near the end of Turn")
	boss._commit_turn()
	_expect(boss.facing_direction > 0.0, "Boss did not complete turn toward rear target")
	_expect(
		boss.shield_component.classify_source_side(player.global_position) == ShieldComponent.SIDE_FRONT,
		"Post-turn contact did not adopt new frontal Shield routing"
	)
	_expect(boss.animated_sprite.flip_h == false, "Boss visual did not finish facing right")
	_expect(boss.facing_root.scale.x > 0.0, "Boss Hitbox facing did not match visual")

	# A target returning to the old front during the reaction delay cancels cleanly.
	boss.set_facing_direction(-1.0)
	boss.current_state = FallenGateKnight.APPROACH_SHIELDED
	boss._interrupt_turn()
	boss._turn_cooldown_timer = 0.0
	player.global_position = boss.global_position + Vector2(120.0, 0.0)
	boss._process_turn_request(step)
	boss._process_turn_request(step)
	player.global_position = boss.global_position + Vector2(-120.0, 0.0)
	_expect(not boss._process_turn_request(step), "Boss did not cancel stale rear-side turn")
	_expect(is_zero_approx(boss._pending_facing), "Canceled Boss turn retained pending facing")

	# The center tolerance and post-turn cooldown prevent flip jitter.
	player.global_position = boss.global_position + Vector2(8.0, 0.0)
	for _frame: int in range(12):
		_expect(not boss._process_turn_request(step), "Boss turned inside center tolerance")
	_expect(boss.facing_direction < 0.0, "Center tolerance changed Boss facing")
	boss._turn_cooldown_timer = boss.config.boss_turn_cooldown
	player.global_position = boss.global_position + Vector2(120.0, 0.0)
	_expect(not boss._process_turn_request(step), "Boss ignored post-turn cooldown")

	# Attack direction remains locked; Recovery is the first state allowed to react.
	boss._turn_cooldown_timer = 0.0
	boss.current_state = FallenGateKnight.SWORD_SLASH
	boss.play_animation(&"sword_slash", true)
	for _frame: int in range(12):
		boss._process_attack_motion(step)
	_expect(boss.facing_direction < 0.0, "Boss turned during locked SwordSlash")
	boss._on_animation_finished()
	_expect(boss.current_state == FallenGateKnight.GUARD_RECOVERY, "Boss did not enter GuardRecovery")
	var recovery_elapsed: float = 0.0
	while not boss._turn_commit_queued and recovery_elapsed < 1.40:
		boss._combat_clock += step
		boss._attack_gap_remaining = maxf(0.0, boss._attack_gap_remaining - step)
		if boss.current_state == FallenGateKnight.TURN_SHIELDED:
			boss._process_turn_state(step)
		else:
			boss._process_post_attack_gap(step)
		recovery_elapsed += step
	boss._commit_turn()
	_expect(boss.facing_direction > 0.0, "Boss did not turn during GuardRecovery")
	print("BOSS_TURN_TIMING: free=%.4f facing=%.4f recovery=%.4f target=1.00..1.30" % [elapsed, facing_commit_elapsed, recovery_elapsed])


func _test_boss_shield_and_phase(player: Player, boss: FallenGateKnight, hud: BossHealthHud) -> void:
	boss.set_physics_process(false)
	boss.set_facing_direction(-1.0)
	player.global_position = boss.global_position + Vector2(-55.0, 0.0)
	var normal: HitboxComponent = player.action_controller.attack_hitbox
	var dash: HitboxComponent = player.action_controller.dash_attack_hitbox
	boss.health_component.reset_to_full()
	boss.shield_component.reset_shield()
	boss.current_phase = 1
	boss.current_state = FallenGateKnight.IDLE_SHIELDED
	normal.begin_attack(70_000, 10, 1.0, player)
	_expect(normal.try_hit(boss.hurtbox), "Boss frontal normal Attack did not reach Shield")
	normal.end_attack()
	_expect(boss.health_component.current_health == 180, "Boss frontal normal leaked into Body")
	_expect(boss.shield_component.shield_current_health == 90, "Boss frontal normal did not reduce Shield 100→90")
	_expect(hud.shield_value.text == "90 / 100", "Boss HUD did not display Shield 90/100")

	# Contact-time rear routing bypasses Shield while preserving the Shield value.
	player.global_position = boss.global_position + Vector2(55.0, 0.0)
	normal.begin_attack(70_001, 10, -1.0, player)
	_expect(normal.try_hit(boss.hurtbox), "Boss rear normal Attack was rejected")
	normal.end_attack()
	dash.begin_attack(70_002, 20, -1.0, player)
	_expect(dash.try_hit(boss.hurtbox), "Boss rear Dash Attack was rejected")
	dash.end_attack()
	_expect(boss.health_component.current_health == 150, "Boss rear 10+20 damage routing mismatch")
	_expect(boss.shield_component.shield_current_health == 90, "Boss rear attacks changed Shield")

	# Five frontal Dash Attacks break exactly 10 Shield without same-hit overflow.
	boss.health_component.reset_to_full()
	boss.shield_component.reset_shield()
	boss.current_phase = 1
	boss.current_state = FallenGateKnight.IDLE_SHIELDED
	player.global_position = boss.global_position + Vector2(-55.0, 0.0)
	for index: int in range(5):
		dash.begin_attack(70_100 + index, 20, 1.0, player)
		_expect(dash.try_hit(boss.hurtbox), "Boss frontal Dash did not reach Shield")
		dash.end_attack()
		if index == 0:
			_expect(boss._get_shield_visual_state() == &"intact", "Boss Shield 80/100 was not intact")
		elif index == 1:
			_expect(boss._get_shield_visual_state() == &"damaged", "Boss Shield 60/100 was not damaged")
		elif index == 3:
			_expect(boss._get_shield_visual_state() == &"critical", "Boss Shield 20/100 was not critical")
	_expect(boss.shield_component.shield_current_health == 0, "Boss Shield did not break at zero")
	_expect(boss.health_component.current_health == 180, "Boss breaking hit overflowed into Body")
	_expect(boss.get_state_name() == &"ShieldBreak", "Boss did not enter ShieldBreak")
	_expect(hud.shield_value.text == "BROKEN", "Boss HUD did not display broken Shield")
	boss._process_timed_state(0.91)
	_expect(boss.get_state_name() == &"PhaseTransition", "Boss did not enter phase transition")
	boss._process_timed_state(1.11)
	_expect(boss.current_phase == 2, "Boss did not enter Phase 2")
	_expect(boss.animated_sprite.animation == &"idle_unshielded", "Boss did not recover unshielded")
	normal.begin_attack(70_200, 10, 1.0, player)
	_expect(normal.try_hit(boss.hurtbox), "Post-break Boss Attack was rejected")
	normal.end_attack()
	_expect(boss.health_component.current_health == 170, "Post-break Boss Body did not take damage")


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
	room.castle_gate_controller.advance(1.3)
	_expect(room.castle_gate_controller.gate_body.collision_layer == 0, "Castle gate collision did not release after opening")
	_expect(room.gate_open_complete, "Castle gate completion state was not recorded")
	_expect(
		player.player_camera.limit_left == 0 and player.player_camera.limit_right == 6600,
		"Boss camera limits did not release: %d..%d" % [
			player.player_camera.limit_left, player.player_camera.limit_right,
		]
	)
	var transition: CastleEntranceTransition = main.get_node(
		"CastleEntranceTransition"
	) as CastleEntranceTransition
	transition.scene_change_enabled = false
	var level_completion_count: Array[int] = [0]
	room.level_completed.connect(func() -> void: level_completion_count[0] += 1)
	room._on_castle_entrance_body_entered(room.player)
	var reward: BossRewardController = main.get_node("World/CastleEntranceArea/BossReward") as BossRewardController
	reward.weapon_pickup.collect()
	room._on_castle_entrance_body_entered(room.player)
	_expect(level_completion_count[0] == 1, "Castle entrance did not emit completion once")
	_expect(transition.is_transition_in_progress(), "Castle entrance did not start text-free transition")


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
		{"state": FallenGateKnight.SHIELD_BASH, "frame": 2, "damage": 8, "phase": 1},
		{"state": FallenGateKnight.SWORD_SLASH, "frame": 2, "damage": 10, "phase": 1},
		{"state": FallenGateKnight.HEAVY_OVERHEAD, "frame": 3, "damage": 15, "phase": 1},
		{"state": FallenGateKnight.COMBO_SLASH, "frame": 2, "damage": 10, "phase": 2},
		{"state": FallenGateKnight.JUMP_SMASH, "frame": 3, "damage": 15, "phase": 2},
		{"state": FallenGateKnight.CHARGE_THRUST, "frame": 2, "damage": 12, "phase": 2},
		{"state": FallenGateKnight.SHOCKWAVE_STRIKE, "frame": 3, "damage": 8, "phase": 2},
	]
	for profile: Dictionary in profiles:
		target_health.reset_to_full()
		boss.current_phase = profile["phase"] as int
		boss.current_state = FallenGateKnight.IDLE_SHIELDED if boss.current_phase == 1 else FallenGateKnight.IDLE_UNSHIELDED
		boss._start_attack(profile["state"] as StringName)
		boss.animated_sprite.frame = profile["frame"] as int
		boss._on_animation_frame_changed()
		var expected_damage: int = profile["damage"] as int
		var hitbox: HitboxComponent = boss._get_hitbox_for_attack_state(profile["state"] as StringName)
		if profile["state"] as StringName == FallenGateKnight.SHOCKWAVE_STRIKE:
			hitbox = boss.get_parent().get_node_or_null("GateSeveranceWave") as HitboxComponent
			_expect(hitbox != null, "Gate Severance did not release its committed ground wave")
			if hitbox == null:
				continue
			_expect(not hitbox.is_active, "Gate Severance armed before its 0.10s materialization")
			var visual: Node2D = hitbox.get_node_or_null("CrescentVisual") as Node2D
			_expect(visual != null and visual.get_child_count() >= 10, "Gate Severance lacks layered crescent presentation")
			var collision: CollisionShape2D = hitbox.get_node("CollisionShape2D") as CollisionShape2D
			var rectangle: RectangleShape2D = collision.shape as RectangleShape2D
			_expect(rectangle.size == boss.config.shockwave_collision_size, "Gate Severance collision size mismatch")
			for _frame: int in range(8):
				await physics_frame
		_expect(hitbox.is_active, "%s did not open its active frame" % profile["state"])
		_expect(hitbox.try_hit(target_hurtbox), "%s did not hit target" % profile["state"])
		_expect(target_health.current_health == 100 - expected_damage, "%s damage mismatch" % profile["state"])
		_expect(not hitbox.try_hit(target_hurtbox), "%s hit the same target twice" % profile["state"])
		var locked_state: StringName = boss.current_state
		boss.shield_component.last_attack_kind = &"normal_attack"
		boss._on_hurtbox_hit_received(1, boss.global_position - Vector2(40.0, 0.0), 90_000)
		_expect(
			boss.current_state == locked_state,
			"Normal Attack interrupted locked Boss state %s" % profile["state"]
		)
		boss._end_attack_window()
		if profile["state"] as StringName == FallenGateKnight.SHOCKWAVE_STRIKE and is_instance_valid(hitbox):
			hitbox.queue_free()
			await process_frame
	target_root.queue_free()


func _test_gate_severance_repetition(boss: FallenGateKnight) -> void:
	for iteration: int in range(20):
		boss.current_attack_id = 120_000 + iteration
		boss._spawn_gate_severance_wave()
		var wave: HitboxComponent = boss.get_parent().get_node_or_null("GateSeveranceWave") as HitboxComponent
		_expect(wave != null, "Gate Severance repetition %d did not spawn" % (iteration + 1))
		if wave == null:
			continue
		for _frame: int in range(8):
			await physics_frame
		_expect(wave.is_active, "Gate Severance repetition %d did not arm" % (iteration + 1))
		wave.end_attack()
		wave.queue_free()
		await process_frame
	print("GATE_SEVERANCE_VISUAL_CYCLES: PASS triggers=20 layered_crescent=true")


func _test_room_reset(player: Player, boss: FallenGateKnight, room: BossRoomController, respawn: PlayerRespawnController) -> void:
	room.room_is_cleared = false
	room.encounter_started = true
	room.room_is_locked = true
	boss.reset_boss()
	boss.activate(player)
	boss.health_component.take_damage(5)
	respawn.player_respawned.emit(room.checkpoint.global_position)
	_expect(not room.encounter_started and not room.room_is_locked, "Player respawn did not reset Boss room")
	_expect(boss.health_component.current_health == 180, "Boss reset did not restore Body Health")
	_expect(boss.shield_component.shield_current_health == 100, "Boss reset did not restore Shield")
	_expect(boss._get_shield_visual_state() == &"intact", "Boss reset did not restore intact Shield")
	_expect(is_zero_approx(boss._turn_timer), "Boss reset retained turn timer")
	_expect(is_zero_approx(boss._turn_cooldown_timer), "Boss reset retained turn cooldown")
	_expect(is_zero_approx(boss._light_hit_reaction_cooldown), "Boss reset retained light reaction cooldown")
	_expect(is_zero_approx(boss._heavy_hit_reaction_cooldown), "Boss reset retained heavy reaction cooldown")
	_expect(is_zero_approx(boss._attack_gap_remaining), "Boss reset retained Attack Gap")
	_expect(boss._last_attack_active_end_time < 0.0, "Boss reset retained active-end timestamp")
	_expect(boss._next_attack_windup_start_time < 0.0, "Boss reset retained windup timestamp")
	_expect(boss._measured_attack_gap < 0.0, "Boss reset retained measured Attack Gap")
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
