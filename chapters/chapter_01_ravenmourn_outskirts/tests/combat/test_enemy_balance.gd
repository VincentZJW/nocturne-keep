extends SceneTree

## Gray-box balance contract: centralized Config values, kill counts, deduplication, and Player invariants.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const CASTLE_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn")
const SHIELD_SCENE: PackedScene = preload("res://shared/scenes/enemies/cursed_shield_guard.tscn")
const SPEAR_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/decayed_spearman.tscn")
const CROSSBOW_SCENE: PackedScene = preload("res://shared/scenes/enemies/fallen_crossbowman.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_player_invariants()
	_test_config_values_and_unchanged_cadence()
	_test_scene_value_authority()
	await _expect_kill_count(CASTLE_SCENE, &"normal_attack", 10, 3, "Castle normal")
	await _expect_kill_count(CASTLE_SCENE, &"dash_attack", 20, 2, "Castle Dash")
	await _expect_shield_kill_count(&"normal_attack", 10, 8, true, "Shield front normal")
	await _expect_shield_kill_count(&"dash_attack", 20, 5, true, "Shield front Dash")
	await _expect_shield_kill_count(&"normal_attack", 10, 5, false, "Shield rear normal")
	await _expect_shield_kill_count(&"dash_attack", 20, 3, false, "Shield rear Dash")
	await _expect_kill_count(SPEAR_SCENE, &"normal_attack", 10, 5, "Spear normal")
	await _expect_kill_count(SPEAR_SCENE, &"dash_attack", 20, 3, "Spear Dash")
	await _expect_kill_count(CROSSBOW_SCENE, &"normal_attack", 10, 4, "Crossbow normal")
	await _expect_kill_count(CROSSBOW_SCENE, &"dash_attack", 20, 2, "Crossbow Dash")
	_finish()


func _test_player_invariants() -> void:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	get_root().add_child(player)
	await process_frame
	player.set_physics_process(false)
	_expect(player.health_component.max_health == 100, "Player max Health changed from 100")
	var equipment: PlayerEquipmentManager = get_root().get_node("EquipmentManager") as PlayerEquipmentManager
	_expect(equipment.get_normal_attack_damage() == 10, "Equipped normal Attack is not ten")
	_expect(equipment.get_dash_attack_damage() == 20, "Equipped Dash Attack is not twenty")
	player.queue_free()
	await process_frame


func _test_config_values_and_unchanged_cadence() -> void:
	var castle: CastleGuardConfig = load(
		"res://chapters/chapter_01_ravenmourn_outskirts/resources/enemies/castle_guard_config.tres"
	) as CastleGuardConfig
	var shield: CursedShieldGuardConfig = load(
		"res://shared/resources/enemies/cursed_shield_guard_config.tres"
	) as CursedShieldGuardConfig
	var spear: DecayedSpearmanConfig = load(
		"res://chapters/chapter_01_ravenmourn_outskirts/resources/enemies/decayed_spearman_config.tres"
	) as DecayedSpearmanConfig
	var crossbow: FallenCrossbowmanConfig = load(
		"res://shared/resources/enemies/fallen_crossbowman_config.tres"
	) as FallenCrossbowmanConfig
	_expect(castle.max_health == 30 and castle.attack_damage == 5, "Castle Config balance mismatch")
	_expect(_cadence_matches(castle, 46.0, 0.35, 0.10, 0.45), "Castle cadence changed")
	_expect(
		shield.max_health == 50 and shield.shield_max_health == 30 and shield.attack_damage == 8,
		"Shield Config body/shield balance mismatch"
	)
	_expect(_cadence_matches(shield, 46.0, 0.40, 0.10, 0.55), "Shield cadence changed")
	_expect(is_equal_approx(shield.guard_break_duration, 0.65), "Shield GuardBreak duration is not 0.65")
	_expect(is_equal_approx(shield.turn_delay, 0.22), "Shield turn delay is not 0.22")
	_expect(
		is_equal_approx(shield.shield_break_flash_duration, 0.05),
		"Shield break flash duration is not 0.05"
	)
	_expect(
		is_equal_approx(shield.shield_break_flash_alpha, 0.30),
		"Shield break flash alpha is not 0.30"
	)
	_expect(spear.max_health == 50 and spear.attack_damage == 10, "Spear Config balance mismatch")
	_expect(_cadence_matches(spear, 76.0, 0.45, 0.10, 0.60), "Spear cadence or range changed")
	_expect(crossbow.max_health == 40, "Crossbow Config Health mismatch")
	_expect(crossbow.projectile_damage == 6, "Crossbow projectile damage is not six")
	_expect(crossbow.attack_damage == crossbow.projectile_damage, "Crossbow Config damage fields conflict")
	_expect(is_equal_approx(crossbow.detection_range, 280.0), "Crossbow detection range changed")
	_expect(is_equal_approx(crossbow.aim_duration, 0.60), "Crossbow Aim duration changed")
	_expect(is_equal_approx(crossbow.reload_duration, 1.50), "Crossbow Reload duration changed")


func _test_scene_value_authority() -> void:
	for path: String in [
		"res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn",
		"res://shared/scenes/enemies/cursed_shield_guard.tscn",
		"res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/decayed_spearman.tscn",
		"res://shared/scenes/enemies/fallen_crossbowman.tscn",
	]:
		var source: String = FileAccess.get_file_as_string(path)
		_expect(not source.contains("\nmax_health ="), "%s duplicates Config max_health" % path)
	_expect(
		not FileAccess.get_file_as_string(
			"res://shared/scenes/enemies/cursed_shield_guard.tscn"
		).contains("\ndamage ="),
		"Shield scene duplicates Config damage"
	)
	_expect(
		not FileAccess.get_file_as_string(
			"res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/decayed_spearman.tscn"
		).contains("\ndamage ="),
		"Spear scene duplicates Config damage"
	)
	_expect(
		not FileAccess.get_file_as_string(
			"res://shared/scenes/projectiles/crossbow_bolt.tscn"
		).contains("\ndamage ="),
		"Bolt scene duplicates Crossbow Config damage"
	)


func _expect_kill_count(
	scene: PackedScene,
	attack_kind: StringName,
	damage: int,
	expected_hits: int,
	label: String
) -> void:
	var enemy: EnemyCombatant = scene.instantiate() as EnemyCombatant
	get_root().add_child(enemy)
	await process_frame
	enemy.set_ai_active(false)
	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.faction = &"player"
	hitbox.attack_kind = attack_kind
	hitbox.damage = damage
	get_root().add_child(hitbox)
	var hit_count: int = 0
	while enemy.get_health_component().current_health > 0 and hit_count < 32:
		var attack_id: int = 9000 + hit_count
		hitbox.begin_attack(attack_id, damage)
		var before: int = enemy.get_health_component().current_health
		_expect(hitbox.try_hit(enemy.get_node("Hurtbox") as HurtboxComponent), "%s hit %d was rejected" % [label, hit_count + 1])
		var after_first_hit: int = enemy.get_health_component().current_health
		_expect(after_first_hit == maxi(0, before - damage), "%s applied wrong damage" % label)
		_expect(not hitbox.try_hit(enemy.get_node("Hurtbox") as HurtboxComponent), "%s attack hit twice" % label)
		_expect(enemy.get_health_component().current_health == after_first_hit, "%s duplicate hit changed Health" % label)
		hitbox.end_attack()
		hit_count += 1
	_expect(hit_count == expected_hits, "%s required %d hits instead of %d" % [label, hit_count, expected_hits])
	_expect(enemy.is_dead(), "%s did not enter Death at zero Health" % label)
	hitbox.queue_free()
	enemy.queue_free()
	await process_frame


func _expect_shield_kill_count(
	attack_kind: StringName,
	damage: int,
	expected_hits: int,
	from_front: bool,
	label: String
) -> void:
	var shield: CursedShieldGuard = SHIELD_SCENE.instantiate() as CursedShieldGuard
	get_root().add_child(shield)
	await process_frame
	shield.set_ai_active(false)
	shield.set_facing_direction(-1.0)
	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.faction = &"player"
	hitbox.attack_kind = attack_kind
	hitbox.damage = damage
	get_root().add_child(hitbox)
	hitbox.global_position = shield.global_position + Vector2(-30.0 if from_front else 30.0, 0.0)
	var hit_count: int = 0
	while shield.health_component.current_health > 0 and hit_count < 32:
		hitbox.begin_attack(12_000 + hit_count, damage, 1.0 if from_front else -1.0)
		_expect(hitbox.try_hit(shield.hurtbox), "%s hit %d was rejected" % [label, hit_count + 1])
		var body_after: int = shield.health_component.current_health
		var shield_after: int = shield.get_shield_current_health()
		_expect(not hitbox.try_hit(shield.hurtbox), "%s attack hit twice" % label)
		_expect(
			shield.health_component.current_health == body_after
			and shield.get_shield_current_health() == shield_after,
			"%s duplicate hit changed body or shield" % label
		)
		hitbox.end_attack()
		hit_count += 1
	_expect(hit_count == expected_hits, "%s required %d hits instead of %d" % [label, hit_count, expected_hits])
	_expect(shield.is_dead(), "%s did not enter Death at zero body Health" % label)
	_expect(
		shield.is_shield_broken() == from_front,
		"%s ended with incorrect shield state" % label
	)
	hitbox.queue_free()
	shield.queue_free()
	await process_frame


func _cadence_matches(
	config: EnemyGroundConfig,
	attack_range: float,
	windup: float,
	active: float,
	recovery: float
) -> bool:
	return (
		is_equal_approx(config.attack_range, attack_range)
		and is_equal_approx(config.attack_windup, windup)
		and is_equal_approx(config.attack_active_duration, active)
		and is_equal_approx(config.attack_recovery, recovery)
	)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("ENEMY_BALANCE_TEST: PASS (Shield front 8/5, rear 5/3; others unchanged)")
		quit(0)
		return
	for failure: String in _failures:
		push_error("ENEMY_BALANCE_TEST: %s" % failure)
	quit(1)
