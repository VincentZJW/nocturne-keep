class_name WorldBounds2D
extends Node2D

## Shared physical and queryable bounds for formal chapter spaces.
## The four generated StaticBody2D walls keep Player and CharacterBody2D actors
## inside the playable rectangle; flying AI can also query the same limits.

@export var actor_bounds: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)
@export_range(8.0, 128.0, 1.0) var wall_thickness: float = 32.0
@export_range(0.0, 128.0, 1.0) var flight_margin: float = 48.0
@export_flags_2d_physics var collision_layer: int = 1
@export var debug_visible: bool = false
@export var debug_color: Color = Color(0.25, 0.72, 0.92, 0.34)


func _ready() -> void:
	add_to_group(&"world_bounds")
	_rebuild_collision()
	queue_redraw()


func get_top_limit_y() -> float:
	return global_position.y + actor_bounds.position.y


func get_bottom_limit_y() -> float:
	return global_position.y + actor_bounds.end.y


func get_left_limit_x() -> float:
	return global_position.x + actor_bounds.position.x


func get_right_limit_x() -> float:
	return global_position.x + actor_bounds.end.x


func get_safe_flight_top_y() -> float:
	return get_top_limit_y() + flight_margin


func clamp_flight_anchor(anchor: Vector2) -> Vector2:
	return Vector2(
		clampf(anchor.x, get_left_limit_x() + flight_margin, get_right_limit_x() - flight_margin),
		clampf(anchor.y, get_safe_flight_top_y(), get_bottom_limit_y() - flight_margin)
	)


func contains_global_point(point: Vector2) -> bool:
	return Rect2(global_position + actor_bounds.position, actor_bounds.size).has_point(point)


func _rebuild_collision() -> void:
	for child: Node in get_children():
		if child.has_meta(&"world_bounds_generated"):
			child.queue_free()
	var center: Vector2 = actor_bounds.get_center()
	_add_wall(
		&"TopCeiling",
		Vector2(center.x, actor_bounds.position.y - wall_thickness * 0.5),
		Vector2(actor_bounds.size.x + wall_thickness * 2.0, wall_thickness)
	)
	_add_wall(
		&"BottomBoundary",
		Vector2(center.x, actor_bounds.end.y + wall_thickness * 0.5),
		Vector2(actor_bounds.size.x + wall_thickness * 2.0, wall_thickness)
	)
	_add_wall(
		&"LeftBoundary",
		Vector2(actor_bounds.position.x - wall_thickness * 0.5, center.y),
		Vector2(wall_thickness, actor_bounds.size.y)
	)
	_add_wall(
		&"RightBoundary",
		Vector2(actor_bounds.end.x + wall_thickness * 0.5, center.y),
		Vector2(wall_thickness, actor_bounds.size.y)
	)


func _add_wall(wall_name: StringName, wall_position: Vector2, wall_size: Vector2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.name = wall_name
	body.collision_layer = collision_layer
	body.collision_mask = 0
	body.position = wall_position
	body.set_meta(&"world_bounds_generated", true)
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = wall_size
	collision.shape = rectangle
	body.add_child(collision)
	add_child(body)


func _draw() -> void:
	if not debug_visible:
		return
	draw_rect(actor_bounds, debug_color, false, 2.0)
