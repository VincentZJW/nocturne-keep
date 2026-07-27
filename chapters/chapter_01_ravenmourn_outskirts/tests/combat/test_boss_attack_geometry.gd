extends SceneTree

## Main-backed acceptance for Fallen Gate Knight attack geometry, Shield Bash
## authored timing/selection, left-right collision behavior, and cooldown.

const MAIN_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn")
const OLD_SHARED_SIZE: Vector2 = Vector2(100.0, 42.0)
const OLD_SHARED_OFFSET: Vector2 = Vector2(65.0, 4.0)
const TARGET_HALF_WIDTH: float = 11.0

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	await _wait_physics_frames(4)
	var boss: FallenGateKnight = main.get_node(
		"World/CastleEntranceArea/FallenGateKnight"
	) as FallenGateKnight
	boss.set_physics_process(false)
	var target: Node2D = _create_target()
	main.add_child(target)
	await _wait_physics_frames(2)
	_test_main_paths_and_geometry(boss)
	await _test_left_right_collision_ranges(boss, target)
	_test_shield_bash_timing(boss)
	_test_shield_bash_selection_and_cooldown(boss)
	target.queue_free()
	main.queue_free()
	await process_frame
	_finish()


func _create_target() -> Node2D:
	var root: Node2D = Node2D.new()
	root.name = "GeometryTarget"
	var health: HealthComponent = HealthComponent.new()
	health.name = "HealthComponent"
	health.max_health = 100
	var hurtbox: HurtboxComponent = HurtboxComponent.new()
	hurtbox.name = "Hurtbox"
	hurtbox.collision_layer = 8
	hurtbox.collision_mask = 64
	hurtbox.faction = &"player"
	hurtbox.health_component_path = NodePath("../HealthComponent")
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = Vector2(22.0, 50.0)
	collision.shape = rectangle
	root.add_child(health)
	root.add_child(hurtbox)
	hurtbox.add_child(collision)
	return root


func _test_main_paths_and_geometry(boss: FallenGateKnight) -> void:
	_expect(boss.get_path() == NodePath("/root/Main/World/CastleEntranceArea/FallenGateKnight"), "Main Boss path changed")
	var expected: Dictionary[StringName, Dictionary] = {
		&"shield": {&"hitbox": boss.shield_bash_hitbox, &"size": Vector2(14.0, 30.0), &"offset": Vector2(19.0, 4.0), &"tip": 32.0},
		&"slash": {&"hitbox": boss.slash_hitbox, &"size": Vector2(26.0, 22.0), &"offset": Vector2(16.0, 0.0), &"tip": 31.0},
		&"thrust": {&"hitbox": boss.thrust_hitbox, &"size": Vector2(32.0, 10.0), &"offset": Vector2(20.0, -7.0), &"tip": 41.0},
	}
	for family: StringName in expected:
		var profile: Dictionary = expected[family]
		var hitbox: HitboxComponent = profile[&"hitbox"] as HitboxComponent
		var collision: CollisionShape2D = hitbox.get_node("CollisionShape2D") as CollisionShape2D
		var rectangle: RectangleShape2D = collision.shape as RectangleShape2D
		var expected_size: Vector2 = profile[&"size"] as Vector2
		var expected_offset: Vector2 = profile[&"offset"] as Vector2
		var visual_tip: float = profile[&"tip"] as float
		var forward_edge: float = hitbox.position.x + rectangle.size.x * 0.5
		_expect(rectangle.size == expected_size, "%s Hitbox size mismatch" % family)
		_expect(hitbox.position == expected_offset, "%s Hitbox offset mismatch" % family)
		_expect(forward_edge <= visual_tip, "%s Hitbox exceeds visual tip" % family)
		_expect(hitbox.position.x - rectangle.size.x * 0.5 >= 0.0, "%s Hitbox reaches behind Boss center" % family)
	_expect(boss.shield_bash_hitbox != boss.slash_hitbox, "Shield and Slash still share one Area2D")
	_expect(boss.slash_hitbox != boss.thrust_hitbox, "Slash and Thrust still share one Area2D")
	print("BOSS_GEOMETRY old_shared=%s@%s shield=14x30@(19,4) slash=26x22@(16,0) thrust=32x10@(20,-7)" % [OLD_SHARED_SIZE, OLD_SHARED_OFFSET])


func _test_left_right_collision_ranges(boss: FallenGateKnight, target: Node2D) -> void:
	var profiles: Array[Dictionary] = [
		{&"name": &"shield", &"hitbox": boss.shield_bash_hitbox},
		{&"name": &"slash", &"hitbox": boss.slash_hitbox},
		{&"name": &"thrust", &"hitbox": boss.thrust_hitbox},
	]
	for profile: Dictionary in profiles:
		var hitbox: HitboxComponent = profile[&"hitbox"] as HitboxComponent
		var collision: CollisionShape2D = hitbox.get_node("CollisionShape2D") as CollisionShape2D
		var rectangle: RectangleShape2D = collision.shape as RectangleShape2D
		var forward_edge: float = hitbox.position.x + rectangle.size.x * 0.5
		for direction: float in [-1.0, 1.0]:
			boss.set_facing_direction(direction)
			for _trial: int in range(10):
				await _expect_spatial_hit(boss, target, hitbox, direction, forward_edge + TARGET_HALF_WIDTH + 2.0, false)
				# Keep the positive sample comfortably inside the authored rectangle.
				# Pixel-edge contacts are deliberately not treated as the acceptance
				# threshold because PhysicsServer broadphase updates can quantize them.
				await _expect_spatial_hit(boss, target, hitbox, direction, forward_edge + TARGET_HALF_WIDTH - 8.0, true)
			await _expect_spatial_hit(boss, target, hitbox, -direction, 24.0, false)
		print("RANGE_20 %s left=10/10 right=10/10 outside_safe and inside_hit" % profile[&"name"])


func _expect_spatial_hit(
	boss: FallenGateKnight,
	target: Node2D,
	hitbox: HitboxComponent,
	direction: float,
	distance: float,
	expect_hit: bool
) -> void:
	var hurtbox: HurtboxComponent = target.get_node("Hurtbox") as HurtboxComponent
	target.global_position = boss.global_position + Vector2(direction * distance, 0.0)
	await _wait_physics_frames(2)
	var collision: CollisionShape2D = hitbox.get_node("CollisionShape2D") as CollisionShape2D
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query.shape = collision.shape
	query.transform = collision.global_transform
	query.collision_mask = hitbox.collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results: Array[Dictionary] = boss.get_world_2d().direct_space_state.intersect_shape(query, 16)
	var was_hit: bool = false
	for result: Dictionary in results:
		if result.get("collider") == hurtbox:
			was_hit = true
			break
	_expect(
		was_hit == expect_hit,
		"%s spatial result mismatch at distance %.1f direction %+.0f (expected=%s actual=%s)" % [
			hitbox.name,
			distance,
			direction,
			expect_hit,
			was_hit,
		]
	)


func _test_shield_bash_timing(boss: FallenGateKnight) -> void:
	var frames: SpriteFrames = boss.animated_sprite.sprite_frames
	var speed: float = frames.get_animation_speed(&"shield_bash")
	var windup: float = (
		frames.get_frame_duration(&"shield_bash", 0)
		+ frames.get_frame_duration(&"shield_bash", 1)
	) / speed
	var active: float = (
		frames.get_frame_duration(&"shield_bash", 2)
		+ frames.get_frame_duration(&"shield_bash", 3)
	) / speed
	var recovery: float = frames.get_frame_duration(&"shield_bash", 4) / speed
	_expect(is_equal_approx(windup, boss.config.shield_bash_windup), "Shield Bash windup mismatch")
	_expect(is_equal_approx(active, boss.config.shield_bash_active), "Shield Bash active duration mismatch")
	_expect(is_equal_approx(recovery, boss.config.shield_bash_recovery), "Shield Bash recovery mismatch")
	_expect(is_equal_approx(boss.config.shield_bash_attack_gap, 1.18), "Shield Bash post-active gap mismatch")
	print("SHIELD_BASH_TIMING windup=%.2f active=%.2f recovery=%.2f post_active_gap=%.2f" % [windup, active, recovery, boss.config.shield_bash_attack_gap])


func _test_shield_bash_selection_and_cooldown(boss: FallenGateKnight) -> void:
	boss._attack_rng.seed = boss.config.attack_selection_seed
	boss._shield_bash_cooldown_remaining = 0.0
	boss._last_selected_attack = &"None"
	var counts: Dictionary[StringName, int] = {
		FallenGateKnight.SHIELD_BASH: 0,
		FallenGateKnight.SWORD_SLASH: 0,
		FallenGateKnight.HEAVY_OVERHEAD: 0,
	}
	for _sample: int in range(2000):
		boss._shield_bash_cooldown_remaining = 0.0
		boss._last_selected_attack = &"None"
		var selected: StringName = boss._select_phase_one_attack(34.0)
		counts[selected] += 1
	var shield_ratio: float = float(counts[FallenGateKnight.SHIELD_BASH]) / 2000.0
	var slash_ratio: float = float(counts[FallenGateKnight.SWORD_SLASH]) / 2000.0
	var heavy_ratio: float = float(counts[FallenGateKnight.HEAVY_OVERHEAD]) / 2000.0
	_expect(shield_ratio >= 0.18 and shield_ratio <= 0.25, "Shield Bash weighted share outside 18-25%%")
	_expect(slash_ratio >= 0.40 and slash_ratio <= 0.46, "Sword Slash weighted share outside target")
	_expect(heavy_ratio >= 0.32 and heavy_ratio <= 0.40, "Heavy weighted share outside target")
	boss._last_selected_attack = FallenGateKnight.SHIELD_BASH
	boss._shield_bash_cooldown_remaining = 0.0
	_expect(boss._select_phase_one_attack(34.0) != FallenGateKnight.SHIELD_BASH, "Consecutive Shield Bash was selected")
	boss._last_selected_attack = &"None"
	_expect(boss._select_phase_one_attack(40.0) != FallenGateKnight.SHIELD_BASH, "Shield Bash selected outside close range")
	boss._shield_bash_cooldown_remaining = boss.config.shield_bash_repeat_cooldown
	_expect(boss._select_phase_one_attack(34.0) != FallenGateKnight.SHIELD_BASH, "Shield Bash ignored repeat cooldown")
	_print_three_fight_selection_counts(boss)
	print("SHIELD_BASH_WEIGHTS sampled shield=%.3f slash=%.3f heavy=%.3f cooldown=%.2f" % [shield_ratio, slash_ratio, heavy_ratio, boss.config.shield_bash_repeat_cooldown])


func _print_three_fight_selection_counts(boss: FallenGateKnight) -> void:
	for fight: int in range(3):
		boss._attack_rng.seed = boss.config.attack_selection_seed + fight
		boss._shield_bash_cooldown_remaining = 0.0
		boss._last_selected_attack = &"None"
		var counts: Dictionary[StringName, int] = {
			FallenGateKnight.SHIELD_BASH: 0,
			FallenGateKnight.SWORD_SLASH: 0,
			FallenGateKnight.HEAVY_OVERHEAD: 0,
		}
		var elapsed: float = 0.0
		var last_bash_time: float = -1.0
		var minimum_bash_interval: float = INF
		for _attack: int in range(12):
			var selected: StringName = boss._select_phase_one_attack(34.0)
			counts[selected] += 1
			boss._last_selected_attack = selected
			if selected == FallenGateKnight.SHIELD_BASH:
				if last_bash_time >= 0.0:
					minimum_bash_interval = minf(minimum_bash_interval, elapsed - last_bash_time)
				last_bash_time = elapsed
				boss._shield_bash_cooldown_remaining = boss.config.shield_bash_repeat_cooldown
			var segment: float = 1.20
			elapsed += segment
			boss._shield_bash_cooldown_remaining = maxf(0.0, boss._shield_bash_cooldown_remaining - segment)
		_expect(minimum_bash_interval >= boss.config.shield_bash_repeat_cooldown, "Fight %d repeated Shield Bash too early" % (fight + 1))
		var minimum_text: String = "n/a" if is_inf(minimum_bash_interval) else "%.2f" % minimum_bash_interval
		print("CONTROLLED_FIGHT_%d bash=%d slash=%d heavy=%d min_bash_gap=%s" % [fight + 1, counts[FallenGateKnight.SHIELD_BASH], counts[FallenGateKnight.SWORD_SLASH], counts[FallenGateKnight.HEAVY_OVERHEAD], minimum_text])


func _wait_physics_frames(count: int) -> void:
	for _index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("BOSS_ATTACK_GEOMETRY_TEST: PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("BOSS_ATTACK_GEOMETRY_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
