class_name Chapter02Stair
extends Node2D

@export var surface_points: PackedVector2Array = PackedVector2Array()
@export var fill_bottom_y: float = 1600.0
@export var stone_color: Color = Color("303746")
@export var edge_color: Color = Color("7a8798")
@export var wood_accents: bool = false


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
		draw_line(from, to, edge_color, 3.0)
		var count: int = maxi(1, int(from.distance_to(to) / 36.0))
		for tread_index: int in range(1, count):
			var tread: Vector2 = from.lerp(to, float(tread_index) / float(count))
			draw_line(tread, tread + Vector2(0.0, 9.0), edge_color.darkened(0.3), 1.0)
	if wood_accents:
		for x_value: int in range(80, int(maxf(surface_points[0].x, surface_points[-1].x)), 180):
			var x: float = float(x_value)
			draw_line(Vector2(x, 760.0), Vector2(x, 1460.0), Color("4b352f"), 5.0)
