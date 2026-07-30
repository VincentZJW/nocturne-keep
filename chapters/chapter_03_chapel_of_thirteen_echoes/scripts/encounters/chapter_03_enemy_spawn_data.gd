class_name Chapter03EnemySpawnData
extends Resource

## One persisted, hand-reviewable enemy placement produced by the fixed-seed authoring tool.

@export var enemy_type: StringName = &""
@export var spawn_role: StringName = &"ground_light"
@export var enemy_scene: PackedScene
@export var local_position: Vector2 = Vector2.ZERO
@export var movement_bounds: Vector2 = Vector2.ZERO
@export_range(-1.0, 1.0, 2.0) var facing_direction: float = -1.0


func has_valid_bounds() -> bool:
	return movement_bounds.y > movement_bounds.x
