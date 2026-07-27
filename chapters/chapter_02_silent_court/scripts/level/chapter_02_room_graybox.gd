class_name Chapter02RoomGraybox
extends Node2D

@export var room_id: StringName = &"ROOM"
@export var bilingual_name: String = "Silent Court Room"
@export var room_index: int = 1
@export var room_size: Vector2i = Vector2i(1280, 720)
@export var vertical_minimum: int = 0
@export var accent_color: Color = Color("64748a")
@export var main_floor_rect: Vector4 = Vector4.ZERO
@export var platform_rects: Array[Vector4] = []
@export var stair_polygons: Array[PackedVector2Array] = []


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var top: float = float(vertical_minimum)
	var width: float = float(room_size.x)
	var height: float = float(room_size.y - vertical_minimum)
	draw_rect(Rect2(0.0, top, width, height), Color("10131f"))
	draw_rect(Rect2(0.0, top + height * 0.35, width, height * 0.65), Color("171b28"))
	_draw_masonry(top, width, height)
	_draw_room_identity(top, width, height)
	var floor_rect: Rect2 = Rect2(0.0, 612.0, width, 108.0)
	if main_floor_rect.z > 0.0 and main_floor_rect.w > 0.0:
		floor_rect = Rect2(
			main_floor_rect.x,
			main_floor_rect.y,
			main_floor_rect.z,
			main_floor_rect.w
		)
	draw_rect(floor_rect, Color("242936"))
	draw_rect(Rect2(floor_rect.position, Vector2(floor_rect.size.x, 6.0)), accent_color.darkened(0.18))
	_draw_route_geometry()


func _draw_masonry(top: float, width: float, height: float) -> void:
	var mortar: Color = Color(0.24, 0.27, 0.35, 0.28)
	var row_y: float = top + 48.0
	var row_index: int = 0
	while row_y < top + height:
		draw_line(Vector2(0.0, row_y), Vector2(width, row_y), mortar, 2.0)
		var offset: float = 48.0 if row_index % 2 == 0 else 0.0
		var x: float = offset
		while x < width:
			draw_line(Vector2(x, row_y - 48.0), Vector2(x, row_y), mortar, 2.0)
			x += 96.0
		row_y += 48.0
		row_index += 1


func _draw_room_identity(top: float, width: float, height: float) -> void:
	match room_index:
		1:
			_draw_arches(top, width, height, 3)
		2:
			_draw_banners(top, width, 8)
		3:
			_draw_banquet(top, width)
		4:
			_draw_portraits(top, width, 9)
		5:
			_draw_chapel(top, width)
		6:
			_draw_servant_passage(top, width)
		7:
			_draw_armory(top, width)
		8:
			_draw_banners(top, width, 5)
		9:
			_draw_ballroom(top, width, height)


func _draw_arches(top: float, width: float, height: float, count: int) -> void:
	var spacing: float = width / float(count)
	for index: int in range(count):
		var center_x: float = spacing * (float(index) + 0.5)
		draw_arc(Vector2(center_x, top + height * 0.47), spacing * 0.28, PI, TAU, 20, accent_color.darkened(0.2), 8.0)
		draw_line(Vector2(center_x - spacing * 0.28, top + height * 0.47), Vector2(center_x - spacing * 0.28, 612.0), accent_color.darkened(0.35), 8.0)
		draw_line(Vector2(center_x + spacing * 0.28, top + height * 0.47), Vector2(center_x + spacing * 0.28, 612.0), accent_color.darkened(0.35), 8.0)


func _draw_banners(top: float, width: float, count: int) -> void:
	var spacing: float = width / float(count + 1)
	for index: int in range(count):
		var x: float = spacing * float(index + 1)
		draw_polygon(PackedVector2Array([Vector2(x - 20.0, top + 96.0), Vector2(x + 20.0, top + 96.0), Vector2(x + 16.0, top + 230.0), Vector2(x, top + 250.0), Vector2(x - 16.0, top + 230.0)]), PackedColorArray([accent_color.darkened(0.35)]))


func _draw_banquet(top: float, width: float) -> void:
	_draw_banners(top, width, 6)
	for ratio: float in [0.10, 0.38, 0.66]:
		var x: float = width * ratio
		draw_rect(Rect2(x, 548.0, 440.0, 18.0), Color("4b3a35"))
		draw_rect(Rect2(x + 32.0, 566.0, 12.0, 46.0), Color("302a2c"))
		draw_rect(Rect2(x + 396.0, 566.0, 12.0, 46.0), Color("302a2c"))


func _draw_portraits(top: float, width: float, count: int) -> void:
	var spacing: float = width / float(count + 1)
	for index: int in range(count):
		var x: float = spacing * float(index + 1)
		draw_rect(Rect2(x - 42.0, top + 130.0, 84.0, 126.0), Color("4c443f"), false, 6.0)
		draw_rect(Rect2(x - 32.0, top + 140.0, 64.0, 106.0), accent_color.darkened(0.55))


func _draw_chapel(top: float, width: float) -> void:
	_draw_arches(top, width, 840.0, 5)
	var center_x: float = width * 0.5
	draw_rect(Rect2(center_x - 260.0, 560.0, 520.0, 52.0), Color("4b4049"))
	draw_rect(Rect2(center_x - 180.0, 536.0, 360.0, 24.0), accent_color.darkened(0.35))
	for ratio: float in [0.14, 0.32, 0.50, 0.68, 0.86]:
		var x: float = width * ratio
		draw_line(Vector2(x, top + 190.0), Vector2(x, top + 420.0), Color("6e2634"), 5.0)
		draw_circle(Vector2(x, top + 184.0), 8.0, Color("c58368"))


func _draw_servant_passage(top: float, width: float) -> void:
	for x: float in range(260, int(width), 420):
		draw_rect(Rect2(x, 490.0, 220.0, 20.0), Color("3d3532"))
		draw_rect(Rect2(x + 20.0, 510.0, 16.0, 102.0), Color("2a282b"))
		draw_rect(Rect2(x + 184.0, 510.0, 16.0, 102.0), Color("2a282b"))


func _draw_armory(top: float, width: float) -> void:
	_draw_arches(top, width, 720.0, 4)
	for ratio: float in [0.16, 0.42, 0.68, 0.86]:
		var x: float = width * ratio
		draw_line(Vector2(x, 470.0), Vector2(x + 120.0, 560.0), Color("9aa7b3"), 5.0)
		draw_line(Vector2(x + 120.0, 470.0), Vector2(x, 560.0), Color("657383"), 5.0)


func _draw_ballroom(top: float, width: float, height: float) -> void:
	_draw_arches(top, width, height, 9)
	for x: float in range(256, int(width), 512):
		draw_line(Vector2(x, top + 40.0), Vector2(x, top + 260.0), Color("81758f"), 3.0)
		draw_circle(Vector2(x, top + 284.0), 28.0, Color("a8b3c2"), false, 5.0)


func _draw_route_geometry() -> void:
	var stone: Color = accent_color.darkened(0.48)
	var edge: Color = accent_color.lightened(0.08)
	for platform: Vector4 in platform_rects:
		var platform_rect: Rect2 = Rect2(platform.x, platform.y, platform.z, platform.w)
		draw_rect(platform_rect, stone)
		draw_line(platform_rect.position, platform_rect.position + Vector2(platform_rect.size.x, 0.0), edge, 3.0)
		_draw_platform_blocks(platform_rect)
	for stair_polygon: PackedVector2Array in stair_polygons:
		if stair_polygon.size() < 3:
			continue
		draw_colored_polygon(stair_polygon, stone)
		_draw_stair_surface(stair_polygon, edge)


func _draw_platform_blocks(platform_rect: Rect2) -> void:
	var joint: Color = Color(0.10, 0.11, 0.16, 0.45)
	var block_width: float = 48.0
	var x: float = platform_rect.position.x + block_width
	while x < platform_rect.end.x:
		draw_line(Vector2(x, platform_rect.position.y + 4.0), Vector2(x, platform_rect.end.y), joint, 1.0)
		x += block_width


func _draw_stair_surface(stair_polygon: PackedVector2Array, edge: Color) -> void:
	var bottom_y: float = float(room_size.y)
	var surface_points: Array[Vector2] = []
	for point: Vector2 in stair_polygon:
		if point.y < bottom_y - 1.0:
			surface_points.append(point)
	if surface_points.size() < 2:
		return
	for point_index: int in range(surface_points.size() - 1):
		var from: Vector2 = surface_points[point_index]
		var to: Vector2 = surface_points[point_index + 1]
		draw_line(from, to, edge, 3.0)
		var segment_length: float = from.distance_to(to)
		var tread_count: int = maxi(1, int(segment_length / 32.0))
		for tread_index: int in range(1, tread_count):
			var ratio: float = float(tread_index) / float(tread_count)
			var tread: Vector2 = from.lerp(to, ratio)
			draw_line(tread, tread + Vector2(0.0, 8.0), edge.darkened(0.22), 1.0)
