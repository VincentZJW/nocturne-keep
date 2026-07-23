extends SceneTree

const SHIELD_SCENE: PackedScene = preload("res://scenes/enemies/cursed_shield_guard.tscn")
const SPEAR_SCENE: PackedScene = preload("res://scenes/enemies/decayed_spearman.tscn")
const CROSSBOW_SCENE: PackedScene = preload("res://scenes/enemies/fallen_crossbowman.tscn")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_shield_directional_policy()
	await _test_spear_profile()
	await _test_crossbow_profile()
	_finish()


func _test_shield_directional_policy() -> void:
	var shield: CursedShieldGuard = SHIELD_SCENE.instantiate() as CursedShieldGuard
	get_root().add_child(shield)
	await process_frame
	shield.set_ai_active(false)
	var normal: HitboxComponent = _make_player_hitbox(&"normal_attack", 1)
	var dash: HitboxComponent = _make_player_hitbox(&"dash_attack", 2)
	get_root().add_child(normal)
	get_root().add_child(dash)
	shield.set_facing_direction(-1.0)
	normal.global_position = shield.global_position + Vector2(-30.0, 0.0)
	normal.begin_attack(1001, 1)
	_expect(normal.try_hit(shield.hurtbox), "Front normal Attack was not consumed by shield")
	_expect(shield.health_component.current_health == 20, "Front normal Attack damaged blocking Shield Guard")
	_expect(shield.get_state_name() == &"Block", "Front normal Attack did not enter Block")
	normal.end_attack()
	dash.global_position = shield.global_position + Vector2(-34.0, 0.0)
	dash.begin_attack(1002, 2)
	_expect(dash.try_hit(shield.hurtbox), "Front Dash Attack was not consumed")
	_expect(shield.get_state_name() == &"GuardBreak", "Front Dash Attack did not enter GuardBreak")
	_expect(not shield.is_blocking(), "GuardBreak left frontal blocking enabled")
	dash.end_attack()
	normal.global_position = shield.global_position + Vector2(-30.0, 0.0)
	normal.begin_attack(1003, 1)
	_expect(normal.try_hit(shield.hurtbox), "Guard-break punish did not reach Hurtbox")
	_expect(shield.health_component.current_health == 19, "Guard-break punish damage mismatch")
	normal.end_attack()
	var back_shield: CursedShieldGuard = SHIELD_SCENE.instantiate() as CursedShieldGuard
	get_root().add_child(back_shield)
	await process_frame
	back_shield.set_ai_active(false)
	back_shield.set_facing_direction(-1.0)
	normal.global_position = back_shield.global_position + Vector2(30.0, 0.0)
	normal.begin_attack(1004, 1)
	_expect(normal.try_hit(back_shield.hurtbox), "Back Attack did not reach Shield Guard")
	_expect(back_shield.health_component.current_health == 19, "Back Attack was incorrectly blocked")
	normal.end_attack()
	shield.health_component.take_damage(shield.health_component.current_health)
	_expect(shield.get_state_name() == &"Death", "Shield Guard did not enter Death")
	_expect(shield.find_child("*Ghost*", true, false) == null, "Shield Guard death created a ghost")
	shield.animated_sprite.animation_finished.emit()
	back_shield.queue_free()
	normal.queue_free()
	dash.queue_free()
	await process_frame


func _test_spear_profile() -> void:
	var spear: DecayedSpearman = SPEAR_SCENE.instantiate() as DecayedSpearman
	get_root().add_child(spear)
	await process_frame
	spear.set_ai_active(false)
	var shape_node: CollisionShape2D = spear.attack_hitbox.get_node("CollisionShape2D") as CollisionShape2D
	var shape: RectangleShape2D = shape_node.shape as RectangleShape2D
	_expect(spear.health_component.max_health == 10, "Spearman max Health mismatch")
	_expect(spear.get_attack_damage() == 10, "Spearman damage mismatch")
	_expect(is_equal_approx(spear.config.attack_range, 76.0), "Spearman attack range mismatch")
	_expect(shape.size.x > shape.size.y * 2.0, "Spear Hitbox is not narrow and long")
	_expect(spear.attack_hitbox.position.x > 0.0, "Spear Hitbox is not authored in front of FacingRoot")
	_expect(spear.animated_sprite.sprite_frames.has_animation(&"attack_thrust"), "Spearman lacks attack_thrust")
	var normal: HitboxComponent = _make_player_hitbox(&"normal_attack", 1)
	var dash: HitboxComponent = _make_player_hitbox(&"dash_attack", 2)
	get_root().add_child(normal)
	get_root().add_child(dash)
	normal.begin_attack(2001, 1)
	_expect(normal.try_hit(spear.hurtbox), "Player normal Attack did not hit Spearman")
	dash.begin_attack(2002, 2)
	_expect(dash.try_hit(spear.hurtbox), "Player Dash Attack did not hit Spearman")
	_expect(spear.health_component.current_health == 7, "Spearman Player damage totals are incorrect")
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
	_expect(crossbow.health_component.max_health == 5, "Crossbowman max Health mismatch")
	_expect(crossbow.get_attack_damage() == 4, "Crossbow bolt damage mismatch")
	_expect(is_equal_approx((crossbow.config as FallenCrossbowmanConfig).aim_duration, 0.60), "Crossbow Aim duration mismatch")
	_expect(is_equal_approx((crossbow.config as FallenCrossbowmanConfig).reload_duration, 1.50), "Crossbow Reload duration mismatch")
	_expect(crossbow.projectile_scene != null, "Crossbowman lacks projectile scene")
	for animation_name: StringName in [&"idle", &"walk", &"aim", &"shoot", &"reload", &"hurt", &"death"]:
		_expect(crossbow.animated_sprite.sprite_frames.has_animation(animation_name), "Crossbowman lacks %s" % animation_name)
	var normal: HitboxComponent = _make_player_hitbox(&"normal_attack", 1)
	var dash: HitboxComponent = _make_player_hitbox(&"dash_attack", 2)
	get_root().add_child(normal)
	get_root().add_child(dash)
	normal.begin_attack(3001, 1)
	_expect(normal.try_hit(crossbow.hurtbox), "Player normal Attack did not hit Crossbowman")
	dash.begin_attack(3002, 2)
	_expect(dash.try_hit(crossbow.hurtbox), "Player Dash Attack did not hit Crossbowman")
	_expect(crossbow.health_component.current_health == 2, "Crossbowman Player damage totals are incorrect")
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
