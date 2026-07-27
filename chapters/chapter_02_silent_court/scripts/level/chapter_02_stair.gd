class_name Chapter02Stair
extends Node2D

@export var surface_points: PackedVector2Array = PackedVector2Array()
@export var fill_bottom_y: float = 1600.0
@export var stone_color: Color = Color("303746")
@export var edge_color: Color = Color("7a8798")
@export var wood_accents: bool = false
@export_range(4, 24, 1) var step_count: int = 14


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	if surface_points.size() < 2:
		return
	for index: int in range(surface_points.size() - 1):
		var from: Vector2 = surface_points[index]
		var to: Vector2 = surface_points[index + 1]
		var normal: Vector2 = (to - from).orthogonal().normalized()
		if normal.y < 0.0:
			normal = -normal
		draw_line(from + normal * 12.0, to + normal * 12.0, stone_color, 26.0)
		var stepped_line: PackedVector2Array = PackedVector2Array([from])
		for step_index: int in range(1, step_count + 1):
			var next: Vector2 = from.lerp(to, float(step_index) / float(step_count))
			var previous: Vector2 = stepped_line[-1]
			stepped_line.append(Vector2(next.x, previous.y))
			stepped_line.append(next)
		draw_polyline(stepped_line, edge_color, 3.0, false)
		var rail_color: Color = Color("4b352f") if wood_accents else edge_color.darkened(0.34)
		var rail_points: PackedVector2Array = PackedVector2Array()
		for post_index: int in range(5):
			var base: Vector2 = from.lerp(to, float(post_index) / 4.0)
			var top: Vector2 = base + Vector2(0.0, -58.0)
			draw_line(base, top, rail_color, 4.0)
			rail_points.append(top)
		draw_polyline(rail_points, rail_color, 5.0, false)
