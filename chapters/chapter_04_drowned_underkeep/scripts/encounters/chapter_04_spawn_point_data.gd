class_name Chapter04SpawnPointData
extends Resource

## Persisted authoring snapshot for one reviewed Chapter IV spawn anchor.

@export var spawn_point_id: StringName = &""
@export var room_id: StringName = &""
@export var semantic_tag: StringName = &"ground"
@export var local_position: Vector2 = Vector2.ZERO
@export var movement_bounds: Vector2 = Vector2.ZERO
@export var platform_width: float = 0.0
@export var access_route: String = ""


func has_valid_bounds() -> bool:
	return movement_bounds.y > movement_bounds.x
