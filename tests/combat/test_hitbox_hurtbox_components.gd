extends SceneTree

## Contract tests for faction filtering, activation, and one-hit-per-attack memory.

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_damage_activation_and_deduplication()
	await _test_faction_and_enable_guards()
	_finish()


func _test_damage_activation_and_deduplication() -> void:
	var target_root: Node2D = Node2D.new()
	var health: HealthComponent = HealthComponent.new()
	health.name = "HealthComponent"
	health.max_health = 5
	var hurtbox: HurtboxComponent = _make_hurtbox(&"enemy")
	target_root.add_child(health)
	target_root.add_child(hurtbox)
	get_root().add_child(target_root)
	var hitbox: HitboxComponent = _make_hitbox(&"player", 2)
	get_root().add_child(hitbox)
	await process_frame
	_expect(not hitbox.is_active, "Hitbox started active despite start_enabled=false")
	_expect(not hitbox.try_hit(hurtbox), "Inactive Hitbox dealt damage")
	_expect(health.current_health == 5, "Inactive Hitbox changed Health")
	hitbox.begin_attack(1001)
	_expect(hitbox.try_hit(hurtbox), "Active hostile Hitbox did not deal damage")
	_expect(health.current_health == 3, "Hitbox damage did not reach HealthComponent")
	_expect(not hitbox.try_hit(hurtbox), "One attack damaged the same Hurtbox twice")
	_expect(health.current_health == 3, "Duplicate attack changed Health")
	hitbox.begin_attack(1002)
	_expect(hitbox.try_hit(hurtbox), "New attack id could not damage the same target")
	_expect(health.current_health == 1, "New attack did not apply its damage")
	hitbox.end_attack()
	_expect(not hitbox.is_active, "Hitbox did not close")
	_expect(not hitbox.try_hit(hurtbox), "Closed Hitbox still dealt damage")
	target_root.queue_free()
	hitbox.queue_free()
	await process_frame


func _test_faction_and_enable_guards() -> void:
	var target_root: Node2D = Node2D.new()
	var health: HealthComponent = HealthComponent.new()
	health.name = "HealthComponent"
	var hurtbox: HurtboxComponent = _make_hurtbox(&"player")
	target_root.add_child(health)
	target_root.add_child(hurtbox)
	get_root().add_child(target_root)
	var hitbox: HitboxComponent = _make_hitbox(&"player", 7)
	get_root().add_child(hitbox)
	await process_frame
	hitbox.begin_attack(2001)
	_expect(not hitbox.try_hit(hurtbox), "Same-faction Hitbox damaged its target")
	_expect(health.current_health == health.max_health, "Friendly fire changed Health")
	hitbox.faction = &"enemy"
	hurtbox.set_enabled(false)
	hitbox.begin_attack(2002)
	_expect(not hitbox.try_hit(hurtbox), "Disabled Hurtbox accepted damage")
	hurtbox.set_enabled(true)
	hitbox.begin_attack(2003)
	_expect(hitbox.try_hit(hurtbox), "Re-enabled hostile Hurtbox rejected damage")
	_expect(health.current_health == 93, "Re-enabled Hurtbox forwarded the wrong damage")
	target_root.queue_free()
	hitbox.queue_free()
	await process_frame


func _make_hitbox(faction: StringName, damage: int) -> HitboxComponent:
	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.faction = faction
	hitbox.damage = damage
	hitbox.collision_layer = 32
	hitbox.collision_mask = 16
	var shape_node: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(24.0, 16.0)
	shape_node.shape = shape
	hitbox.add_child(shape_node)
	return hitbox


func _make_hurtbox(faction: StringName) -> HurtboxComponent:
	var hurtbox: HurtboxComponent = HurtboxComponent.new()
	hurtbox.faction = faction
	hurtbox.health_component_path = NodePath("../HealthComponent")
	hurtbox.collision_layer = 16
	hurtbox.collision_mask = 32
	var shape_node: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(20.0, 30.0)
	shape_node.shape = shape
	hurtbox.add_child(shape_node)
	return hurtbox


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("HITBOX_HURTBOX_TEST: PASS (activation, faction, deduplication, Health forwarding)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("HITBOX_HURTBOX_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
