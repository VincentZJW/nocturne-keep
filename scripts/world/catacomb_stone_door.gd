class_name CatacombStoneDoor
extends Node2D

## Pixel-edged moving slab and rune presentation; fixed layers are sibling nodes.

var open_progress: float = 0.0:
	set(value):
		open_progress = clampf(value, 0.0, 1.0)
		queue_redraw()
var rune_strength: float = 0.0:
	set(value):
		rune_strength = clampf(value, 0.0, 1.0)
		queue_redraw()


func _draw() -> void:
	var rise: float = open_progress * 235.0
	draw_rect(Rect2(-76, -248 - rise, 152, 248), Color("303943"))
	for y: float in [-210.0, -156.0, -102.0, -48.0]:
		draw_line(Vector2(-70, y - rise), Vector2(70, y - rise), Color("151d26"), 4.0)
	for x: float in [-46.0, 0.0, 46.0]:
		draw_line(Vector2(x, -242 - rise), Vector2(x, -7 - rise), Color("424d58"), 3.0)
	var rune_color: Color = Color(0.62, 0.83, 0.94, rune_strength)
	draw_arc(Vector2(0, -132 - rise), 28, 0.2, 5.7, 18, rune_color, 4.0)
	draw_line(Vector2(-14, -158 - rise), Vector2(16, -106 - rise), rune_color, 3.0)
