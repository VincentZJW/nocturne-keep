class_name Chapter03EntryArt
extends Node2D

const PROTOTYPE_WIDTH: float = 4200.0


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, PROTOTYPE_WIDTH, 720), Color("080a10"), true)
	draw_rect(Rect2(0, 92, PROTOTYPE_WIDTH, 520), Color("151823"), true)
	# Side door connects visually to the processional corridor.
	var side_door: PackedVector2Array = PackedVector2Array([
		Vector2(26, 612), Vector2(26, 312), Vector2(104, 224),
		Vector2(182, 312), Vector2(182, 612),
	])
	draw_colored_polygon(side_door, Color("242833"))
	draw_polyline(side_door, Color("66583f"), 7.0)
	for groove_index: int in range(13):
		var x: float = 50.0 + float(groove_index) * 9.0
		draw_line(Vector2(x, 382), Vector2(x, 520), Color(0.48, 0.57, 0.64, 0.45), 2.0)
	# Chapel nave is intentionally blocked beyond the minimum vestibule.
	for column_index: int in range(16):
		var x: float = 330.0 + float(column_index) * 260.0
		draw_rect(Rect2(x, 180, 38, 432), Color("2b2d38"), true)
		draw_circle(Vector2(x + 19, 170), 34.0, Color("343743"))
	for bell_index: int in range(37):
		var x: float = 270.0 + float(bell_index) * 108.0
		draw_arc(Vector2(x, 280), 16.0, PI, TAU, 18, Color(0.56, 0.59, 0.66, 0.7), 3.0)
	draw_rect(Rect2(0, 612, PROTOTYPE_WIDTH, 108), Color("252832"), true)
	draw_line(Vector2(0, 612), Vector2(PROTOTYPE_WIDTH, 612), Color("777b87"), 3.0)
