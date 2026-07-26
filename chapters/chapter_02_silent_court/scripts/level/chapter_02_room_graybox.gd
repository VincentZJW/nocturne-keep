class_name Chapter02RoomGraybox
extends Node2D

@export var room_id: StringName = &"ROOM"
@export var bilingual_name: String = "Silent Court Room"
@export var room_index: int = 1
@export var room_size: Vector2i = Vector2i(1280, 720)
@export var vertical_minimum: int = 0
@export var accent_color: Color = Color("64748a")


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
	draw_rect(Rect2(0.0, 612.0, width, 108.0), Color("242936"))
	draw_rect(Rect2(0.0, 612.0, width, 6.0), accent_color.darkened(0.18))
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
	for x: float in [560.0, 1840.0, 3120.0, 3800.0]:
		draw_rect(Rect2(x, 548.0, 520.0, 18.0), Color("4b3a35"))
		draw_rect(Rect2(x + 32.0, 566.0, 12.0, 46.0), Color("302a2c"))
		draw_rect(Rect2(x + 476.0, 566.0, 12.0, 46.0), Color("302a2c"))


func _draw_portraits(top: float, width: float, count: int) -> void:
	var spacing: float = width / float(count + 1)
	for index: int in range(count):
		var x: float = spacing * float(index + 1)
		draw_rect(Rect2(x - 42.0, top + 130.0, 84.0, 126.0), Color("4c443f"), false, 6.0)
		draw_rect(Rect2(x - 32.0, top + 140.0, 64.0, 106.0), accent_color.darkened(0.55))


func _draw_chapel(top: float, width: float) -> void:
	_draw_arches(top, width, 1440.0, 7)
	draw_rect(Rect2(1660.0, 560.0, 520.0, 52.0), Color("4b4049"))
	draw_rect(Rect2(1740.0, 536.0, 360.0, 24.0), accent_color.darkened(0.35))
	for x: float in [480.0, 1120.0, 1920.0, 2720.0, 3440.0]:
		draw_line(Vector2(x, top + 190.0), Vector2(x, top + 420.0), Color("6e2634"), 5.0)
		draw_circle(Vector2(x, top + 184.0), 8.0, Color("c58368"))


func _draw_servant_passage(top: float, width: float) -> void:
	for x: float in range(260, int(width), 420):
		draw_rect(Rect2(x, 490.0, 220.0, 20.0), Color("3d3532"))
		draw_rect(Rect2(x + 20.0, 510.0, 16.0, 102.0), Color("2a282b"))
		draw_rect(Rect2(x + 184.0, 510.0, 16.0, 102.0), Color("2a282b"))


func _draw_armory(top: float, width: float) -> void:
	_draw_arches(top, width, 720.0, 4)
	for x: float in [300.0, 780.0, 1260.0, 1740.0]:
		draw_line(Vector2(x, 470.0), Vector2(x + 120.0, 560.0), Color("9aa7b3"), 5.0)
		draw_line(Vector2(x + 120.0, 470.0), Vector2(x, 560.0), Color("657383"), 5.0)


func _draw_ballroom(top: float, width: float, height: float) -> void:
	_draw_arches(top, width, height, 9)
	for x: float in range(256, int(width), 512):
		draw_line(Vector2(x, top + 40.0), Vector2(x, top + 260.0), Color("81758f"), 3.0)
		draw_circle(Vector2(x, top + 284.0), 28.0, Color("a8b3c2"), false, 5.0)


func _draw_route_geometry() -> void:
	var stone: Color = accent_color.darkened(0.48)
	if room_index == 2:
		draw_colored_polygon(PackedVector2Array([
			Vector2(700, 612), Vector2(1100, 500), Vector2(1300, 500),
			Vector2(1700, 612), Vector2(1700, 720), Vector2(700, 720),
		]), stone)
	elif room_index == 6:
		draw_colored_polygon(PackedVector2Array([
			Vector2(420, 612), Vector2(760, 520), Vector2(1040, 520),
			Vector2(1380, 612), Vector2(1380, 720), Vector2(420, 720),
		]), stone)
		draw_colored_polygon(PackedVector2Array([
			Vector2(1900, 612), Vector2(2240, 520), Vector2(2480, 520),
			Vector2(2820, 612), Vector2(2820, 720), Vector2(1900, 720),
		]), stone)
