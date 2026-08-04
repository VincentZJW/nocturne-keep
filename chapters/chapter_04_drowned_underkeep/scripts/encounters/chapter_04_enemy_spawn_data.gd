class_name Chapter04EnemySpawnData
extends Resource

## One deterministic enemy placement. Runtime consumes this data without RNG.

@export var spawn_record_id: StringName = &""
@export var enemy_type: StringName = &""
@export var spawn_point_id: StringName = &""
@export var spawn_role: StringName = &"ground"
@export var enemy_scene: PackedScene
@export var local_position: Vector2 = Vector2.ZERO
@export var movement_bounds: Vector2 = Vector2.ZERO
@export_range(-1.0, 1.0, 2.0) var facing_direction: float = -1.0
@export var access_route: String = ""


func has_valid_bounds() -> bool:
	return movement_bounds.y > movement_bounds.x
