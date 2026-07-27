class_name Chapter02SurfaceTrim
extends Node2D

## Thin foreground lip only. The large ground fill is rendered by the room backdrop
## behind actors; this node may cover at most the lowest few pixels at a contact edge.

@export var room_width: float = 1280.0
@export var floor_y: float = 612.0
@export var trim_color: Color = Color("7a8494")
@export var platform_rects: Array[Vector4] = []
@export var stair_polygons: Array[PackedVector2Array] = []


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0.0, floor_y, room_width, 3.0), trim_color)
	for platform: Vector4 in platform_rects:
		draw_rect(Rect2(platform.x, platform.y, platform.z, 3.0), trim_color)
	for stair_polygon: PackedVector2Array in stair_polygons:
		_draw_surface(stair_polygon)


func _draw_surface(points: PackedVector2Array) -> void:
	var surface: Array[Vector2] = []
	for point: Vector2 in points:
		if point.y < 700.0:
			surface.append(point)
	for index: int in range(surface.size() - 1):
		draw_line(surface[index], surface[index + 1], trim_color, 3.0)
