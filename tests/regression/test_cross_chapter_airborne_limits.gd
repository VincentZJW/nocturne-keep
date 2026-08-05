extends SceneTree

## Stress regression for the shared top boundary and every formal flying enemy
## family used by Chapters I-III. Chapter IV currently has no flying roster.

const BOUNDS_SCENE: String = "res://shared/scenes/world/world_bounds_2d.tscn"
const FLYING_SCENES: Array[Dictionary] = [
	{
		"name": "Gargoyle Sentinel",
		"path": "res://shared/scenes/enemies/gargoyle_sentinel.tscn",
		"kind": "gargoyle",
	},
	{
		"name": "Hanging Stalker",
		"path": "res://chapters/chapter_02_silent_court/scenes/enemies/hanging_stalker.tscn",
		"kind": "stalker",
	},
	{
		"name": "Silent Chorister",
		"path": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/silent_chorister.tscn",
		"kind": "specialist",
	},
	{
		"name": "Stained Glass Seraph",
		"path": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/stained_glass_seraph.tscn",
		"kind": "specialist",
	},
]

var _failures: PackedStringArray = []
var _clamp_attempts: int = 0
var _reloads: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var bounds_packed: PackedScene = load(BOUNDS_SCENE) as PackedScene
	_check(bounds_packed != null, "WorldBounds scene failed to load")
	if bounds_packed == null:
		_finish()
		return
	var host: Node2D = Node2D.new()
	root.add_child(host)
	var bounds: WorldBounds2D = bounds_packed.instantiate() as WorldBounds2D
	bounds.actor_bounds = Rect2(0.0, 0.0, 1280.0, 720.0)
	bounds.flight_margin = 52.0
	host.add_child(bounds)
	await physics_frame
	await _test_player_ceiling(host, bounds)
	for entry: Dictionary in FLYING_SCENES:
		await _stress_enemy(host, bounds, entry)
	for _reload_index: int in range(5):
		for entry: Dictionary in FLYING_SCENES:
			var packed: PackedScene = load(entry["path"] as String) as PackedScene
			var enemy: Node = packed.instantiate() if packed != null else null
			_check(enemy != null, "%s reload fixture failed" % (entry["name"] as String))
			if enemy != null:
				host.add_child(enemy)
				await process_frame
				enemy.queue_free()
				await process_frame
			_reloads += 1
	host.queue_free()
	await process_frame
	await process_frame
	_finish()


func _test_player_ceiling(host: Node2D, bounds: WorldBounds2D) -> void:
	var body: CharacterBody2D = CharacterBody2D.new()
	body.collision_layer = 2
	body.collision_mask = 1
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(24.0, 32.0)
	collision.shape = shape
	body.add_child(collision)
	host.add_child(body)
	body.global_position = Vector2(640.0, 100.0)
	await physics_frame
	for _attempt: int in range(20):
		body.velocity = Vector2(0.0, -720.0)
		body.move_and_slide()
		await physics_frame
	_check(body.global_position.y >= bounds.get_top_limit_y() + 15.0, "Player body crossed the physical top boundary")
	body.queue_free()
	await process_frame


func _stress_enemy(host: Node2D, bounds: WorldBounds2D, entry: Dictionary) -> void:
	var packed: PackedScene = load(entry["path"] as String) as PackedScene
	var enemy: Node2D = packed.instantiate() as Node2D if packed != null else null
	_check(enemy != null, "%s failed to instantiate" % (entry["name"] as String))
	if enemy == null:
		return
	host.add_child(enemy)
	await process_frame
	if enemy is CharacterBody2D:
		(enemy as CharacterBody2D).set_physics_process(false)
	var safe_top: float = bounds.get_safe_flight_top_y()
	var kind: String = entry["kind"] as String
	for attempt: int in range(20):
		enemy.global_position = Vector2(120.0 + attempt * 12.0, safe_top - 80.0 - attempt)
		match kind:
			"gargoyle":
				var gargoyle: GargoyleSentinel = enemy as GargoyleSentinel
				gargoyle.world_bounds = bounds
				gargoyle.home_position = Vector2(enemy.global_position.x, safe_top - 120.0)
				gargoyle._enforce_flight_bounds()
				_check(gargoyle.home_position.y >= safe_top, "Gargoyle retained an out-of-bounds home anchor")
			"stalker":
				var stalker: HangingStalker = enemy as HangingStalker
				stalker.world_bounds = bounds
				stalker.ceiling_anchor = Vector2(enemy.global_position.x, safe_top - 120.0)
				stalker._enforce_flight_bounds()
				_check(stalker.ceiling_anchor.y >= safe_top, "Hanging Stalker retained an out-of-bounds ceiling anchor")
			"specialist":
				var specialist: Chapter03SpecialistEnemy = enemy as Chapter03SpecialistEnemy
				specialist.world_bounds = bounds
				specialist._enforce_flight_bounds()
		_check(enemy.global_position.y >= safe_top, "%s escaped above the safe ceiling on attempt %d" % [entry["name"], attempt + 1])
		_clamp_attempts += 1
	enemy.queue_free()
	await process_frame


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print(
			"CROSS CHAPTER AIRBORNE LIMITS | PASS families=%d clamp_attempts=%d player_attempts=20 reloads=%d"
			% [FLYING_SCENES.size(), _clamp_attempts, _reloads]
		)
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)
