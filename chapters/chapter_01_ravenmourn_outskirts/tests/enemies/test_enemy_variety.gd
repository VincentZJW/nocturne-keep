extends SceneTree

const SHIELD_SCENE: PackedScene = preload("res://shared/scenes/enemies/cursed_shield_guard.tscn")
const SPEAR_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/decayed_spearman.tscn")
const CROSSBOW_SCENE: PackedScene = preload("res://shared/scenes/enemies/fallen_crossbowman.tscn")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []
var _shield_break_events: int = 0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_shield_directional_policy()
	await _test_real_player_dash_shield_routing()
	await _test_spear_profile()
	await _test_crossbow_profile()
	_finish()


func _test_shield_directional_policy() -> void:
	var shield: CursedShieldGuard = SHIELD_SCENE.instantiate() as CursedShieldGuard
	get_root().add_child(shield)
	await process_frame
	shield.set_ai_active(false)
	shield.shield_component.shield_broken.connect(_on_test_shield_broken)
	var normal: HitboxComponent = _make_player_hitbox(&"normal_attack", 10)
	var dash: HitboxComponent = _make_player_hitbox(&"dash_attack", 20)
	get_root().add_child(normal)
	get_root().add_child(dash)
	shield.set_facing_direction(-1.0)
	_expect(shield.health_component.current_health == 50, "Shield Guard body did not start at 50/50")
	_expect(shield.get_shield_current_health() == 30, "Shield did not start at 30/30")
	_expect(shield.shield_visual.animation == &"intact", "Shield did not start visually intact")
	normal.global_position = shield.global_position + Vector2(-30.0, 0.0)
	for hit_index: int in range(3):
		normal.begin_attack(1001 + hit_index, 10, 1.0)
		var body_before: int = shield.health_component.current_health
		_expect(normal.try_hit(shield.hurtbox), "Front normal Attack was not routed to shield")
		_expect(not normal.try_hit(shield.hurtbox), "One normal Attack damaged shield twice")
		_expect(shield.health_component.current_health == body_before, "Front hit damaged body and shield")
		_expect(
			shield.get_shield_current_health() == 20 - hit_index * 10,
			"Front normal Attack shield damage mismatch"
		)
		normal.end_attack()
		if hit_index < 2:
			_expect(shield.get_state_name() == &"Block", "Shield hit did not enter Block")
			_expect(shield.shield_hit_effect.visible, "Shield hit spark did not start")
			var expected_visual: StringName = &"cracked" if hit_index == 0 else &"critical"
			_expect(shield.shield_visual.animation == expected_visual, "Shield crack state mismatch")
			shield._process_enemy_state(0.25)
	_expect(shield.get_state_name() == &"GuardBreak", "Zero shield did not enter GuardBreak")
	_expect(shield.is_shield_broken(), "Zero shield did not permanently mark broken")
	_expect(_shield_break_events == 1, "Shield break did not emit exactly once")
	_expect(is_equal_approx(shield.state_timer, 0.65), "GuardBreak timer is not 0.65 seconds")
	_expect(shield.animated_sprite.animation == &"guard_break", "GuardBreak animation did not start")
	_expect(shield.shield_visual.animation == &"shield_break", "ShieldVisual break did not start")
	_expect(shield.shield_break_effect.visible, "Shield break flash/fragments did not start")
	_expect(shield.guard_break_marker.visible, "GuardBreak marker did not become visible")
	_expect(shield.shield_break_effect.scale == Vector2(2.0, 2.0), "Shield break effect is not enlarged")
	_expect(
		shield.animated_sprite.modulate.is_equal_approx(Color.WHITE),
		"Shield break flash still brightens the whole enemy body"
	)
	_expect(
		shield.shield_hit_effect.visible
		and is_equal_approx(shield.shield_hit_effect.modulate.a, 0.30),
		"Shield-local break flash did not start at alpha 0.30"
	)
	_expect(
		shield.get_debug_summary().contains("BODY 50/50")
		and shield.get_debug_summary().contains("SH 0/30")
		and shield.get_debug_summary().contains("SHIELD broken")
		and shield.get_debug_summary().contains("STATE GuardBreak"),
		"Shield Debug state is not transparent during GuardBreak"
	)
	normal.global_position = shield.global_position + Vector2(-30.0, 0.0)
	normal.begin_attack(1010, 10, 1.0)
	_expect(normal.try_hit(shield.hurtbox), "Guard-break punish did not reach Hurtbox")
	_expect(shield.health_component.current_health == 40, "Guard-break punish damage mismatch")
	_expect(shield.get_state_name() == &"GuardBreak", "Punish hit cancelled GuardBreak hard stun")
	normal.end_attack()
	shield._enter_attack()
	_expect(shield.get_state_name() == &"GuardBreak", "GuardBreak allowed an Attack transition")
	shield._process_enemy_state(0.64)
	_expect(shield.get_state_name() == &"GuardBreak", "GuardBreak ended before 0.65 seconds")
	_expect(shield.guard_break_marker.visible, "GuardBreak marker vanished before the hard stun ended")
	shield._process_enemy_state(0.02)
	_expect(shield.get_state_name() == &"Patrol", "GuardBreak did not recover into unshielded movement")
	_expect(shield.animated_sprite.animation == &"walk_unshielded", "Shield reappeared after GuardBreak")
	_expect(not shield.is_blocking(), "GuardBreak recovery restored frontal blocking")
	_expect(not shield.guard_break_marker.visible, "GuardBreak marker remained after recovery")
	shield._enter_idle()
	_expect(shield.animated_sprite.animation == &"idle_unshielded", "Post-break Idle restored the shield")
	_expect(not shield.shield_visual.visible, "ShieldVisual remained after break")
	normal.begin_attack(1011, 10, 1.0)
	_expect(normal.try_hit(shield.hurtbox), "Post-break frontal normal Attack was blocked")
	_expect(shield.health_component.current_health == 30, "Post-break frontal damage mismatch")
	_expect(shield.animated_sprite.animation == &"hurt_unshielded", "Post-break Hurt restored the shield")
	normal.end_attack()

	var dash_shield: CursedShieldGuard = SHIELD_SCENE.instantiate() as CursedShieldGuard
	get_root().add_child(dash_shield)
	await process_frame
	dash_shield.set_ai_active(false)
	dash_shield.set_facing_direction(-1.0)
	dash.global_position = dash_shield.global_position + Vector2(-32.0, 0.0)
	dash.begin_attack(1020, 20, 1.0)
	_expect(dash.try_hit(dash_shield.hurtbox), "First front Dash was rejected")
	_expect(dash_shield.get_shield_current_health() == 10, "First front Dash did not leave shield at 10/30")
	_expect(dash_shield.health_component.current_health == 50, "First front Dash damaged body")
	dash.end_attack()
	dash_shield._process_enemy_state(0.25)
	dash.begin_attack(1021, 20, 1.0)
	_expect(dash.try_hit(dash_shield.hurtbox), "Second front Dash was rejected")
	_expect(dash_shield.is_shield_broken(), "Second front Dash did not break shield")
	_expect(dash_shield.health_component.current_health == 50, "Break overflow damaged body")
	_expect(dash_shield.shield_component.last_overflow_discarded == 10, "Dash overflow was not recorded/discarded")
	dash.end_attack()

	var rear_shield: CursedShieldGuard = SHIELD_SCENE.instantiate() as CursedShieldGuard
	get_root().add_child(rear_shield)
	await process_frame
	rear_shield.set_ai_active(false)
	rear_shield.set_facing_direction(-1.0)
	normal.global_position = rear_shield.global_position + Vector2(30.0, 0.0)
	normal.begin_attack(1030, 10, -1.0)
	_expect(normal.try_hit(rear_shield.hurtbox), "Rear normal Attack did not reach body")
	_expect(rear_shield.health_component.current_health == 40, "Rear normal damage mismatch")
	_expect(rear_shield.get_shield_current_health() == 30, "Rear normal reduced shield")
	normal.end_attack()
	dash.global_position = rear_shield.global_position + Vector2(30.0, 0.0)
	dash.begin_attack(1031, 20, -1.0)
	_expect(dash.try_hit(rear_shield.hurtbox), "Rear Dash Attack did not reach body")
	_expect(rear_shield.health_component.current_health == 20, "Rear Dash damage mismatch")
	_expect(rear_shield.get_shield_current_health() == 30, "Rear Dash reduced shield")
	dash.end_attack()
	normal.global_position = rear_shield.global_position + Vector2(4.0, -30.0)
	normal.begin_attack(1032, 10, -1.0)
	_expect(normal.try_hit(rear_shield.hurtbox), "Center-tolerance body hit was rejected")
	_expect(rear_shield.health_component.current_health == 10, "Center-tolerance hit did not damage body")
	_expect(rear_shield.get_shield_current_health() == 30, "Center-tolerance hit reduced shield")
	normal.end_attack()

	var turn_shield: CursedShieldGuard = SHIELD_SCENE.instantiate() as CursedShieldGuard
	var turn_player: Player = PLAYER_SCENE.instantiate() as Player
	get_root().add_child(turn_shield)
	get_root().add_child(turn_player)
	await process_frame
	turn_shield.set_ai_active(false)
	turn_shield.set_facing_direction(-1.0)
	turn_player.global_position = turn_shield.global_position + Vector2(60.0, 0.0)
	turn_player.set_physics_process(false)
	turn_shield.set_target(turn_player)
	turn_shield._process_enemy_state(0.01)
	_expect(turn_shield.get_state_name() == &"Turn", "Rear target did not start delayed Turn")
	_expect(turn_shield.facing_direction < 0.0, "Shield Guard flipped on the first rear frame")
	turn_shield._process_enemy_state(0.21)
	_expect(turn_shield.facing_direction < 0.0, "Shield Guard turned before 0.22 seconds")
	turn_shield._process_enemy_state(0.02)
	_expect(turn_shield.facing_direction > 0.0, "Shield Guard did not turn after 0.22 seconds")

	shield.health_component.take_damage(shield.health_component.current_health)
	_expect(shield.get_state_name() == &"Death", "Shield Guard did not enter Death")
	_expect(shield.animated_sprite.animation == &"death_unshielded", "Broken shield returned during Death")
	_expect(shield.find_child("*Ghost*", true, false) == null, "Shield Guard death created a ghost")
	shield.animated_sprite.animation_finished.emit()
	dash_shield.queue_free()
	rear_shield.queue_free()
	turn_shield.queue_free()
	turn_player.queue_free()
	normal.queue_free()
	dash.queue_free()
	await process_frame


func _on_test_shield_broken(_hitbox: HitboxComponent) -> void:
	_shield_break_events += 1


func _test_real_player_dash_shield_routing() -> void:
	var shield: CursedShieldGuard = SHIELD_SCENE.instantiate() as CursedShieldGuard
	var player: Player = PLAYER_SCENE.instantiate() as Player
	get_root().add_child(shield)
	get_root().add_child(player)
	await process_frame
	shield.set_ai_active(false)
	player.set_physics_process(false)
	shield.global_position = Vector2(300.0, 300.0)
	shield.set_facing_direction(-1.0)
	player.global_position = shield.global_position + Vector2(-34.0, 0.0)
	player.animation_controller.set_facing_left(false)
	var actions: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	_expect(
		actions.try_start_actions(true, true, true, 1.0, false),
		"Real Player front Dash Attack did not start"
	)
	sprite.frame = 2
	sprite.frame_changed.emit()
	var dash: HitboxComponent = actions.dash_attack_hitbox
	var first_attack_id: int = dash.attack_id
	_expect(
		absf(dash.global_position.x - shield.global_position.x) <= 8.0,
		"Regression fixture no longer reproduces the forward Hitbox-center ambiguity"
	)
	_expect(dash.try_hit(shield.hurtbox), "Real Player front Dash did not reach shield")
	_expect(shield.health_component.current_health == 50, "Real Player front Dash pierced body")
	_expect(shield.get_shield_current_health() == 10, "Real Player front Dash did not deal twenty to shield")
	var front_hit_one_body: int = shield.health_component.current_health
	var front_hit_one_shield: int = shield.get_shield_current_health()
	_expect(shield.shield_component.last_hit_side == &"front", "Player-root source was not classified front")
	_expect(shield.shield_component.last_route == &"shield", "Front Dash route was not shield")
	dash.end_attack()
	dash.begin_attack(first_attack_id, 20, 1.0, player)
	_expect(not dash.try_hit(shield.hurtbox), "Same Dash id reactivation bypassed Hitbox dedup")
	_expect(shield.health_component.current_health == 50, "Same Dash id reactivation damaged body")
	_expect(shield.get_shield_current_health() == 10, "Same Dash id reactivation damaged shield")
	actions.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	shield._process_enemy_state(0.25)

	_expect(
		actions.try_start_actions(true, true, true, 1.0, false),
		"Second real Player front Dash Attack did not start"
	)
	sprite.frame = 2
	sprite.frame_changed.emit()
	var breaking_attack_id: int = dash.attack_id
	_expect(breaking_attack_id != first_attack_id, "New Dash did not generate a new attack id")
	_expect(dash.try_hit(shield.hurtbox), "Breaking front Dash did not reach shield")
	_expect(shield.is_shield_broken(), "Breaking front Dash did not break shield")
	_expect(shield.health_component.current_health == 50, "Breaking front Dash overflow pierced body")
	_expect(shield.get_shield_current_health() == 0, "Breaking front Dash did not reach zero shield")
	var front_hit_two_body: int = shield.health_component.current_health
	var front_hit_two_shield: int = shield.get_shield_current_health()
	_expect(shield.shield_component.last_overflow_discarded == 10, "Breaking overflow was not discarded")
	var duplicate_result: int = shield.shield_component.resolve_damage(dash)
	_expect(duplicate_result == 0, "Shield ledger accepted the breaking Dash id twice")
	_expect(shield.shield_component.last_duplicate_blocked, "Shield ledger did not report duplicate block")
	_expect(shield.health_component.current_health == 50, "Breaking Dash later frame damaged body")

	actions.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	_expect(
		actions.try_start_actions(true, false, true, 1.0, false),
		"Post-break new normal Attack did not start"
	)
	sprite.frame = 1
	sprite.frame_changed.emit()
	_expect(actions.attack_hitbox.try_hit(shield.hurtbox), "Post-break new normal Attack was rejected")
	_expect(shield.health_component.current_health == 40, "Post-break normal Attack did not deal ten")
	actions.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	player.stamina_component.reset_to_full()
	_expect(
		actions.try_start_actions(true, true, true, 1.0, false),
		"Post-break new Dash Attack did not start"
	)
	sprite.frame = 2
	sprite.frame_changed.emit()
	_expect(dash.try_hit(shield.hurtbox), "Post-break new Dash Attack was rejected")
	_expect(shield.health_component.current_health == 20, "Post-break new Dash Attack did not deal twenty")

	var mirrored_shield: CursedShieldGuard = SHIELD_SCENE.instantiate() as CursedShieldGuard
	get_root().add_child(mirrored_shield)
	await process_frame
	mirrored_shield.set_ai_active(false)
	mirrored_shield.global_position = Vector2(500.0, 300.0)
	mirrored_shield.set_facing_direction(1.0)
	player.global_position = mirrored_shield.global_position + Vector2(34.0, 0.0)
	player.animation_controller.set_facing_left(true)
	actions.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	player.stamina_component.reset_to_full()
	_expect(actions.try_start_actions(true, true, true, -1.0, false), "Mirrored front Dash did not start")
	sprite.frame = 2
	sprite.frame_changed.emit()
	_expect(dash.try_hit(mirrored_shield.hurtbox), "Mirrored front Dash did not reach shield")
	_expect(mirrored_shield.health_component.current_health == 50, "Mirrored front Dash pierced body")
	_expect(mirrored_shield.get_shield_current_health() == 10, "Mirrored front Dash shield damage mismatch")

	var rear_shield: CursedShieldGuard = SHIELD_SCENE.instantiate() as CursedShieldGuard
	get_root().add_child(rear_shield)
	await process_frame
	rear_shield.set_ai_active(false)
	rear_shield.global_position = Vector2(700.0, 300.0)
	rear_shield.set_facing_direction(-1.0)
	player.global_position = rear_shield.global_position + Vector2(34.0, 0.0)
	player.animation_controller.set_facing_left(true)
	actions.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	player.stamina_component.reset_to_full()
	_expect(actions.try_start_actions(true, true, true, -1.0, false), "Rear Dash did not start")
	sprite.frame = 2
	sprite.frame_changed.emit()
	_expect(dash.try_hit(rear_shield.hurtbox), "Rear Dash did not reach body")
	_expect(rear_shield.health_component.current_health == 30, "Rear Dash did not deal twenty to body")
	_expect(rear_shield.get_shield_current_health() == 30, "Rear Dash changed shield")
	print(
		(
			"SHIELD_DASH_MATRIX: before B50 SH30; front1 B%d SH%d; front2 B%d SH%d; "
			+ "rear B%d SH%d; post-break normal/dash B40/B20"
		) % [
			front_hit_one_body,
			front_hit_one_shield,
			front_hit_two_body,
			front_hit_two_shield,
			rear_shield.health_component.current_health,
			rear_shield.get_shield_current_health(),
		]
	)

	shield.queue_free()
	mirrored_shield.queue_free()
	rear_shield.queue_free()
	player.queue_free()
	await process_frame


func _test_spear_profile() -> void:
	var spear: DecayedSpearman = SPEAR_SCENE.instantiate() as DecayedSpearman
	get_root().add_child(spear)
	await process_frame
	spear.set_ai_active(false)
	var shape_node: CollisionShape2D = spear.attack_hitbox.get_node("CollisionShape2D") as CollisionShape2D
	var shape: RectangleShape2D = shape_node.shape as RectangleShape2D
	_expect(spear.health_component.max_health == 50, "Spearman max Health mismatch")
	_expect(spear.get_attack_damage() == 10, "Spearman damage mismatch")
	_expect(is_equal_approx(spear.config.attack_range, 76.0), "Spearman attack range mismatch")
	_expect(shape.size.x > shape.size.y * 2.0, "Spear Hitbox is not narrow and long")
	_expect(spear.attack_hitbox.position.x > 0.0, "Spear Hitbox is not authored in front of FacingRoot")
	_expect(spear.animated_sprite.sprite_frames.has_animation(&"attack_thrust"), "Spearman lacks attack_thrust")
	var normal: HitboxComponent = _make_player_hitbox(&"normal_attack", 10)
	var dash: HitboxComponent = _make_player_hitbox(&"dash_attack", 20)
	get_root().add_child(normal)
	get_root().add_child(dash)
	normal.begin_attack(2001, 10)
	_expect(normal.try_hit(spear.hurtbox), "Player normal Attack did not hit Spearman")
	dash.begin_attack(2002, 20)
	_expect(dash.try_hit(spear.hurtbox), "Player Dash Attack did not hit Spearman")
	_expect(spear.health_component.current_health == 20, "Spearman Player damage totals are incorrect")
	normal.end_attack()
	dash.end_attack()
	spear._enter_attack()
	_expect(not spear.attack_hitbox.is_active, "Spear Hitbox opened during windup")
	spear.animated_sprite.frame = 3
	spear.animated_sprite.frame_changed.emit()
	_expect(spear.attack_hitbox.is_active, "Spear Hitbox did not open on attack_thrust_04")
	spear.animated_sprite.frame = 5
	spear.animated_sprite.frame_changed.emit()
	_expect(not spear.attack_hitbox.is_active, "Spear Hitbox stayed open in recovery")
	spear.health_component.take_damage(spear.health_component.current_health)
	_expect(spear.get_state_name() == &"Death", "Spearman did not enter Death")
	_expect(spear.find_child("*Ghost*", true, false) == null, "Spearman death created a ghost")
	spear.animated_sprite.animation_finished.emit()
	normal.queue_free()
	dash.queue_free()
	await process_frame


func _test_crossbow_profile() -> void:
	var crossbow: FallenCrossbowman = CROSSBOW_SCENE.instantiate() as FallenCrossbowman
	var player: Player = PLAYER_SCENE.instantiate() as Player
	player.position = Vector2(150.0, 0.0)
	get_root().add_child(crossbow)
	get_root().add_child(player)
	await process_frame
	crossbow.set_ai_active(false)
	player.set_physics_process(false)
	_expect(crossbow.health_component.max_health == 40, "Crossbowman max Health mismatch")
	_expect(crossbow.get_attack_damage() == 6, "Crossbow bolt damage mismatch")
	_expect(crossbow.config.attack_damage == 6, "Crossbow shared damage field conflicts with projectile damage")
	_expect(is_equal_approx((crossbow.config as FallenCrossbowmanConfig).aim_duration, 0.60), "Crossbow Aim duration mismatch")
	_expect(is_equal_approx((crossbow.config as FallenCrossbowmanConfig).reload_duration, 1.50), "Crossbow Reload duration mismatch")
	_expect(crossbow.projectile_scene != null, "Crossbowman lacks projectile scene")
	for animation_name: StringName in [&"idle", &"walk", &"aim", &"shoot", &"reload", &"hurt", &"death"]:
		_expect(crossbow.animated_sprite.sprite_frames.has_animation(animation_name), "Crossbowman lacks %s" % animation_name)
	var normal: HitboxComponent = _make_player_hitbox(&"normal_attack", 10)
	var dash: HitboxComponent = _make_player_hitbox(&"dash_attack", 20)
	get_root().add_child(normal)
	get_root().add_child(dash)
	normal.begin_attack(3001, 10)
	_expect(normal.try_hit(crossbow.hurtbox), "Player normal Attack did not hit Crossbowman")
	dash.begin_attack(3002, 20)
	_expect(dash.try_hit(crossbow.hurtbox), "Player Dash Attack did not hit Crossbowman")
	_expect(crossbow.health_component.current_health == 10, "Crossbowman Player damage totals are incorrect")
	normal.end_attack()
	dash.end_attack()
	crossbow.set_target(player)
	crossbow._enter_aim()
	_expect(crossbow.get_state_name() == &"Aim", "Crossbowman did not enter Aim")
	crossbow._process_aim(0.61)
	_expect(crossbow.get_state_name() == &"Shoot", "Crossbowman did not leave Aim after 0.60 seconds")
	crossbow.animated_sprite.frame = 1
	crossbow.animated_sprite.frame_changed.emit()
	_expect(crossbow.active_projectiles == 1, "Crossbowman did not spawn exactly one bolt")
	crossbow.animated_sprite.animation_finished.emit()
	_expect(crossbow.get_state_name() == &"Reload", "Crossbowman did not enter Reload")
	crossbow.health_component.take_damage(crossbow.health_component.current_health)
	_expect(crossbow.get_state_name() == &"Death", "Crossbowman did not enter Death")
	_expect(crossbow.find_child("*Ghost*", true, false) == null, "Crossbowman death created a ghost")
	crossbow.animated_sprite.animation_finished.emit()
	player.queue_free()
	normal.queue_free()
	dash.queue_free()
	for child: Node in get_root().get_children():
		if child is CrossbowBolt:
			child.queue_free()
	await process_frame


func _make_player_hitbox(kind: StringName, damage: int) -> HitboxComponent:
	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.faction = &"player"
	hitbox.attack_kind = kind
	hitbox.damage = damage
	return hitbox


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("ENEMY_VARIETY_TEST: PASS (shield facing/break, spear reach, crossbow cadence)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("ENEMY_VARIETY_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
