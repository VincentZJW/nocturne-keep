class_name CatacombDoorFrameFront
extends Node2D

## Fixed masonry that masks the aperture edge and always renders in front of actors.

const FRAME_DARK: Color = Color("18212b")
const FRAME_STONE: Color = Color("303b46")
const FRAME_EDGE: Color = Color("53616d")
const INSET: Color = Color("222d37")


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	# Side jambs and lintel create a hard visual mask around the clipped night layer.
	draw_rect(Rect2(-94.0, -268.0, 22.0, 268.0), FRAME_DARK)
	draw_rect(Rect2(72.0, -268.0, 22.0, 268.0), FRAME_DARK)
	draw_rect(Rect2(-100.0, -276.0, 200.0, 28.0), FRAME_DARK)
	draw_rect(Rect2(-88.0, -260.0, 16.0, 260.0), FRAME_STONE)
	draw_rect(Rect2(72.0, -260.0, 16.0, 260.0), FRAME_STONE)
	draw_rect(Rect2(-88.0, -268.0, 176.0, 20.0), FRAME_STONE)
	draw_line(Vector2(-72.0, -248.0), Vector2(-72.0, 0.0), FRAME_EDGE, 3.0)
	draw_line(Vector2(72.0, -248.0), Vector2(72.0, 0.0), FRAME_EDGE, 3.0)
	draw_line(Vector2(-72.0, -248.0), Vector2(72.0, -248.0), FRAME_EDGE, 3.0)
	for y: float in [-214.0, -160.0, -106.0, -52.0]:
		draw_line(Vector2(-87.0, y), Vector2(-73.0, y), INSET, 2.0)
		draw_line(Vector2(73.0, y), Vector2(87.0, y), INSET, 2.0)
	# Restrained Veiled Order portrait relief in the front lintel, not the night layer.
	draw_circle(Vector2(0.0, -258.0), 8.0, FRAME_DARK)
	draw_arc(Vector2(0.0, -259.0), 6.0, 0.25, PI - 0.25, 10, FRAME_EDGE, 2.0)
	draw_line(Vector2(-4.0, -255.0), Vector2(0.0, -250.0), FRAME_EDGE, 2.0)
	draw_line(Vector2(4.0, -255.0), Vector2(0.0, -250.0), FRAME_EDGE, 2.0)
