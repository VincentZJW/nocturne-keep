extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const SHIELD_SCENE: PackedScene = preload("res://scenes/enemies/cursed_shield_guard.tscn")
const SPEAR_SCENE: PackedScene = preload("res://scenes/enemies/decayed_spearman.tscn")
const BOLT_SCENE: PackedScene = preload("res://scenes/projectiles/crossbow_bolt.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_melee_damage(SHIELD_SCENE, 8, &"Shield Guard")
	await _test_melee_damage(SPEAR_SCENE, 10, &"Spearman")
	await _test_bolt_damage()
	_finish()


func _test_melee_damage(scene: PackedScene, expected_damage: int, label: StringName) -> void:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	var enemy: EnemyCombatant = scene.instantiate() as EnemyCombatant
	player.position = Vector2(1000.0, 0.0)
	get_root().add_child(player)
	get_root().add_child(enemy)
	await process_frame
	player.set_physics_process(false)
	enemy.set_ai_active(false)
	var hitbox: HitboxComponent = enemy.get_node("FacingRoot/AttackHitbox") as HitboxComponent
	hitbox.begin_attack(4000 + expected_damage, expected_damage)
	var before: int = player.health_component.current_health
	_expect(hitbox.try_hit(player.hurtbox), "%s Hitbox did not hit Player" % label)
	_expect(player.health_component.current_health == before - expected_damage, "%s damage mismatch" % label)
	_expect(player.get_life_state_name() == &"Hurt", "%s did not trigger Player Hurt" % label)
	hitbox.end_attack()
	player.queue_free()
	enemy.queue_free()
	await process_frame


func _test_bolt_damage() -> void:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	var bolt: CrossbowBolt = BOLT_SCENE.instantiate() as CrossbowBolt
	player.position = Vector2(1000.0, 0.0)
	get_root().add_child(player)
	get_root().add_child(bolt)
	await process_frame
	player.set_physics_process(false)
	bolt.set_physics_process(false)
	bolt.initialize(1.0, 260.0, 4, 3.0)
	var before: int = player.health_component.current_health
	_expect(bolt.hitbox.try_hit(player.hurtbox), "Crossbow bolt did not hit Player")
	_expect(player.health_component.current_health == before - 4, "Crossbow bolt damage mismatch")
	_expect(player.get_life_state_name() == &"Hurt", "Crossbow bolt did not trigger Player Hurt")
	player.queue_free()
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("ENEMY_VARIETY_DAMAGE_TEST: PASS (Shield 8, Spear 10, Bolt 4, Player Hurt)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("ENEMY_VARIETY_DAMAGE_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
