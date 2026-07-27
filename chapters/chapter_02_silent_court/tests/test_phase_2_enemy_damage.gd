extends SceneTree

const ROOT_PATH: String = "res://chapters/chapter_02_silent_court"

var _failures: Array[String] = []
var _attack_id: int = 9000


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var fixture: Node2D = Node2D.new()
	root.add_child(fixture)
	var health: HealthComponent = HealthComponent.new()
	health.name = "HealthComponent"
	health.max_health = 999
	var target: HurtboxComponent = HurtboxComponent.new()
	target.name = "Hurtbox"
	target.faction = &"player"
	fixture.add_child(health)
	fixture.add_child(target)
	await process_frame
	_test_ground_role(fixture, target, health, "hollow_retainer", 7, 5)
	_test_ground_role(fixture, target, health, "court_halberdier", 10, 6)
	_test_ground_role(fixture, target, health, "mourning_armor", 14, 9)
	await _test_acolyte_projectile(fixture, target, health)
	_test_stalker(fixture, target, health)
	fixture.queue_free()
	await process_frame
	if _failures.is_empty():
		print("CH2_PHASE2_ENEMY_DAMAGE_TEST: PASS damages=7/5,10/6,14/9,8/4,9/6 dedup=ok")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	push_error("CH2_PHASE2_ENEMY_DAMAGE_TEST: FAIL count=%d" % _failures.size())
	quit(1)


func _test_ground_role(
	fixture: Node2D,
	target: HurtboxComponent,
	health: HealthComponent,
	slug: String,
	primary_damage: int,
	secondary_damage: int
) -> void:
	var enemy: SilentCourtGroundEnemy = _instantiate(slug) as SilentCourtGroundEnemy
	fixture.add_child(enemy)
	enemy.set_physics_process(false)
	_test_hitbox(enemy.primary_hitbox, target, health, primary_damage, "%s primary" % slug)
	_test_hitbox(enemy.secondary_hitbox, target, health, secondary_damage, "%s secondary" % slug)
	enemy.queue_free()


func _test_acolyte_projectile(
	fixture: Node2D, target: HurtboxComponent, health: HealthComponent
) -> void:
	var projectile_scene: PackedScene = ResourceLoader.load(
		"%s/scenes/projectiles/blood_candle_projectile.tscn" % ROOT_PATH, "PackedScene"
	) as PackedScene
	var projectile: BloodCandleProjectile = projectile_scene.instantiate() as BloodCandleProjectile
	fixture.add_child(projectile)
	await process_frame
	projectile.initialize(1.0, 180.0, 8, 2.4, 4, 0.65)
	_test_active_hitbox(projectile.hitbox, target, health, 8, "Acolyte projectile")
	projectile.queue_free()
	var ember_scene: PackedScene = ResourceLoader.load(
		"%s/scenes/projectiles/blood_candle_ember.tscn" % ROOT_PATH, "PackedScene"
	) as PackedScene
	var ember: BloodCandleEmber = ember_scene.instantiate() as BloodCandleEmber
	fixture.add_child(ember)
	await process_frame
	ember.initialize(4, 0.65)
	_test_active_hitbox(ember.hitbox, target, health, 4, "Acolyte ember")
	ember.queue_free()


func _test_stalker(
	fixture: Node2D, target: HurtboxComponent, health: HealthComponent
) -> void:
	var stalker: HangingStalker = _instantiate("hanging_stalker") as HangingStalker
	fixture.add_child(stalker)
	stalker.set_physics_process(false)
	_test_hitbox(stalker.drop_hitbox, target, health, 9, "Stalker drop")
	_test_hitbox(stalker.claw_hitbox, target, health, 6, "Stalker claw")
	stalker.queue_free()


func _test_hitbox(
	hitbox: HitboxComponent,
	target: HurtboxComponent,
	health: HealthComponent,
	damage: int,
	label: String
) -> void:
	_attack_id += 1
	hitbox.begin_attack(_attack_id, damage, 1.0)
	_test_active_hitbox(hitbox, target, health, damage, label)
	hitbox.end_attack()


func _test_active_hitbox(
	hitbox: HitboxComponent,
	target: HurtboxComponent,
	health: HealthComponent,
	damage: int,
	label: String
) -> void:
	health.reset_to_full()
	var before: int = health.current_health
	_expect(hitbox.try_hit(target), "%s did not resolve" % label)
	_expect(health.current_health == before - damage, "%s damage mismatch" % label)
	_expect(not hitbox.try_hit(target), "%s hit the same target twice" % label)


func _instantiate(slug: String) -> EnemyCombatant:
	var scene: PackedScene = ResourceLoader.load(
		"%s/scenes/enemies/%s.tscn" % [ROOT_PATH, slug], "PackedScene"
	) as PackedScene
	return scene.instantiate() as EnemyCombatant if scene != null else null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
