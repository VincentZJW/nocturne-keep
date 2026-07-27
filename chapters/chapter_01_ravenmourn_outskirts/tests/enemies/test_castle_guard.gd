extends SceneTree

## State, fairness, interruption, edge safety, and death tests for Castle Guard.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const GUARD_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn")

var _failures: Array[String] = []
var _death_presentation_finished: bool = false
var _death_tree_exited: bool = false


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var world: Node2D = _create_world()
	var player: Player = PLAYER_SCENE.instantiate() as Player
	var guard: CastleGuard = GUARD_SCENE.instantiate() as CastleGuard
	player.position = Vector2(-500.0, 252.0)
	guard.position = Vector2(0.0, 250.0)
	world.add_child(player)
	world.add_child(guard)
	await _wait_physics_frames(5)
	await _test_idle_patrol_and_edge(guard)
	await _test_chase_and_loss(player, guard)
	await _test_fair_attack(player, guard)
	await _test_hurt_interrupt_and_death(player, guard)
	world.queue_free()
	await process_frame
	_finish()


func _test_idle_patrol_and_edge(guard: CastleGuard) -> void:
	_expect(guard.get_state_name() == &"Idle", "Guard did not begin in Idle")
	await _wait_physics_frames(38)
	_expect(guard.get_state_name() == &"Patrol", "Idle did not transition to Patrol")
	guard.global_position.x = 151.0
	guard.facing_direction = 1.0
	await _wait_physics_frames(3)
	_expect(guard.facing_direction < 0.0, "Guard did not turn before the platform edge/boundary")
	_expect(absf(guard.global_position.x) < 160.0, "Guard walked off the test platform")


func _test_chase_and_loss(player: Player, guard: CastleGuard) -> void:
	player.global_position = guard.global_position + Vector2(-115.0, 0.0)
	guard.set_target(player)
	var start_x: float = guard.global_position.x
	await _wait_physics_frames(10)
	_expect(guard.get_state_name() == &"Chase", "Target acquisition did not enter Chase")
	_expect(guard.global_position.x < start_x, "Guard did not chase the Player horizontally")
	_expect(guard.facing_direction < 0.0, "Left-side target did not face Guard left")
	_expect(guard.attack_hitbox.global_position.x < guard.global_position.x, "Left-facing sword Hitbox remained behind Guard")
	player.global_position = guard.global_position + Vector2(115.0, 0.0)
	await _wait_physics_frames(4)
	_expect(guard.facing_direction > 0.0, "Right-side target did not face Guard right")
	_expect(guard.attack_hitbox.global_position.x > guard.global_position.x, "Right-facing sword Hitbox remained behind Guard")
	player.global_position = guard.global_position + Vector2(-300.0, 0.0)
	await _wait_physics_frames(3)
	_expect(guard.target == null, "Guard retained a target beyond lose_target_range")
	_expect(guard.get_state_name() == &"Patrol", "Lost target did not return Guard to Patrol")


func _test_fair_attack(player: Player, guard: CastleGuard) -> void:
	player.health_component.reset_to_full()
	player.global_position = guard.global_position + Vector2(-40.0, 0.0)
	guard.set_target(player)
	await _wait_until_state(guard, &"Attack", 30)
	_expect(guard.get_state_name() == &"Attack", "Attack range did not enter Attack")
	var health_before: int = player.health_component.current_health
	_expect(guard.facing_direction < 0.0, "Attack entry did not face the nearby left-side Player")
	_expect(not guard.is_attack_window_active(), "Sword Hitbox opened on Attack entry")
	await _wait_physics_frames(18)
	_expect(player.health_component.current_health == health_before, "Guard damaged Player before 0.35s windup")
	await _wait_until_health_changes(player.health_component, health_before, 20)
	_expect(player.health_component.current_health == health_before - 5, "Guard active frames did not deal exactly five damage")
	await _wait_physics_frames(34)
	_expect(player.health_component.current_health == health_before - 5, "One sword attack damaged Player more than once")
	_expect(not guard.is_attack_window_active(), "Sword Hitbox remained active during/after recovery")


func _test_hurt_interrupt_and_death(player: Player, guard: CastleGuard) -> void:
	guard.presentation_finished.connect(_on_death_presentation_finished)
	guard.tree_exited.connect(_on_death_tree_exited)
	guard.health_component.reset_to_full()
	player.global_position = guard.global_position + Vector2(-40.0, 0.0)
	guard.set_target(player)
	await _wait_until_state(guard, &"Attack", 30)
	var source: HitboxComponent = _make_player_hitbox()
	get_root().add_child(source)
	await process_frame
	source.global_position = player.global_position
	source.begin_attack(7001, 10)
	_expect(source.try_hit(guard.hurtbox), "Player test Hitbox did not damage Guard")
	_expect(guard.get_state_name() == &"Hurt", "Damage did not interrupt Guard into Hurt")
	_expect(not guard.is_attack_window_active(), "Hurt did not cancel Guard sword Hitbox")
	_expect(absf(guard.velocity.x) > 0.0, "Hurt did not apply knockback")
	await _wait_physics_frames(14)
	_expect(guard.get_state_name() == &"Chase" or guard.get_state_name() == &"Attack", "Hurt did not recover toward Chase")
	source.begin_attack(7002, 10)
	source.try_hit(guard.hurtbox)
	source.begin_attack(7003, 10)
	source.try_hit(guard.hurtbox)
	_expect(guard.health_component.current_health == 0, "Three normal hits did not defeat 30-Health Guard")
	_expect(guard.get_state_name() == &"Death", "Zero Health did not enter Death")
	_expect(not guard.hurtbox.is_enabled, "Death did not close Guard Hurtbox")
	_expect(not guard.attack_hitbox.is_active, "Death retained sword Hitbox")
	var death_position: Vector2 = guard.global_position
	await _wait_physics_frames(5)
	_expect(guard.global_position.distance_to(death_position) < 0.01, "Dead Guard continued moving")
	await _wait_physics_frames(50)
	_expect(_death_presentation_finished, "Death animation did not reach its presentation boundary")
	_expect(_death_tree_exited, "Completed dead Guard was not removed from the SceneTree")
	_expect(not is_instance_valid(guard), "Completed dead Guard node is still alive")
	source.queue_free()


func _create_world() -> Node2D:
	var world: Node2D = Node2D.new()
	var floor: StaticBody2D = StaticBody2D.new()
	floor.collision_layer = 1
	floor.collision_mask = 0
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(320.0, 40.0)
	collision.position = Vector2(0.0, 320.0)
	collision.shape = shape
	floor.add_child(collision)
	world.add_child(floor)
	get_root().add_child(world)
	return world


func _make_player_hitbox() -> HitboxComponent:
	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.faction = &"player"
	hitbox.collision_layer = 32
	hitbox.collision_mask = 16
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(40.0, 18.0)
	collision.shape = shape
	hitbox.add_child(collision)
	return hitbox


func _wait_until_state(guard: CastleGuard, desired_state: StringName, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		if guard.get_state_name() == desired_state:
			return
		await physics_frame


func _wait_until_health_changes(health: HealthComponent, original_health: int, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		if health.current_health != original_health:
			return
		await physics_frame


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _on_death_presentation_finished() -> void:
	_death_presentation_finished = true


func _on_death_tree_exited() -> void:
	_death_tree_exited = true


func _finish() -> void:
	if _failures.is_empty():
		print("CASTLE_GUARD_TEST: PASS (patrol, edge, chase, fair attack, Hurt, Death)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CASTLE_GUARD_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
