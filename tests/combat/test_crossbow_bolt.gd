extends SceneTree

const BOLT_SCENE: PackedScene = preload("res://scenes/projectiles/crossbow_bolt.tscn")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_player_hit_once()
	await _test_world_collision()
	_finish()


func _test_player_hit_once() -> void:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	var bolt: CrossbowBolt = BOLT_SCENE.instantiate() as CrossbowBolt
	player.position = Vector2(1000.0, 0.0)
	bolt.position = Vector2.ZERO
	get_root().add_child(player)
	get_root().add_child(bolt)
	await process_frame
	player.set_physics_process(false)
	bolt.set_physics_process(false)
	bolt.initialize(1.0, 260.0, 6, 3.0)
	var health_before: int = player.health_component.current_health
	_expect(bolt.hitbox.try_hit(player.hurtbox), "Bolt did not hit Player Hurtbox")
	_expect(player.health_component.current_health == health_before - 6, "Bolt did not deal six damage")
	_expect(not bolt.hitbox.try_hit(player.hurtbox), "Same bolt hit Player twice")
	await process_frame
	_expect(not is_instance_valid(bolt), "Resolved bolt was not freed")
	player.queue_free()
	await process_frame


func _test_world_collision() -> void:
	var wall: StaticBody2D = StaticBody2D.new()
	wall.collision_layer = 1
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(4.0, 100.0)
	collision.shape = shape
	wall.add_child(collision)
	wall.position = Vector2(20.0, 0.0)
	get_root().add_child(wall)
	var bolt: CrossbowBolt = BOLT_SCENE.instantiate() as CrossbowBolt
	get_root().add_child(bolt)
	bolt.global_position = Vector2.ZERO
	bolt.initialize(1.0, 260.0, 6, 3.0)
	for _index: int in range(20):
		if not is_instance_valid(bolt):
			break
		await physics_frame
	_expect(not is_instance_valid(bolt), "Bolt did not despawn on World collision")
	wall.queue_free()
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CROSSBOW_BOLT_TEST: PASS (six damage, one hit, World collision cleanup)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CROSSBOW_BOLT_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
