class_name RavenmournGateArt
extends Node2D

## Moving wood-and-iron portcullis presentation parented to GateVisual.


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var oak_dark: Color = Color(0.12, 0.07, 0.045, 1.0)
	var oak: Color = Color(0.25, 0.14, 0.075, 1.0)
	var oak_edge: Color = Color(0.42, 0.25, 0.12, 0.86)
	var iron: Color = Color(0.09, 0.095, 0.115, 1.0)
	var iron_edge: Color = Color(0.31, 0.32, 0.35, 0.9)
	draw_rect(Rect2(-34.0, -130.0, 68.0, 260.0), oak_dark)
	for plank_index: int in range(4):
		var plank_x: float = -31.0 + float(plank_index) * 16.0
		draw_rect(Rect2(plank_x, -126.0, 13.0, 250.0), oak)
		draw_line(Vector2(plank_x + 2.0, -122.0), Vector2(plank_x + 2.0, 120.0), oak_edge, 2.0)
	for band_y: float in [-100.0, -20.0, 60.0, 112.0]:
		draw_rect(Rect2(-38.0, band_y, 76.0, 8.0), iron)
		draw_line(Vector2(-36.0, band_y + 1.0), Vector2(36.0, band_y + 1.0), iron_edge, 2.0)
	for bar_x: float in [-28.0, -14.0, 0.0, 14.0, 28.0]:
		draw_rect(Rect2(bar_x - 3.0, -134.0, 6.0, 270.0), iron)
		draw_line(Vector2(bar_x - 1.0, -130.0), Vector2(bar_x - 1.0, 130.0), iron_edge, 1.0)
		var spike: PackedVector2Array = PackedVector2Array([
			Vector2(bar_x - 5.0, 134.0), Vector2(bar_x, 150.0), Vector2(bar_x + 5.0, 134.0),
		])
		draw_colored_polygon(spike, iron)
	for rivet_y: float in [-96.0, -16.0, 64.0, 116.0]:
		for rivet_x: float in [-28.0, 28.0]:
			draw_rect(Rect2(rivet_x - 2.0, rivet_y, 4.0, 4.0), Color(0.46, 0.4, 0.29, 1.0))
	var crest: PackedVector2Array = PackedVector2Array([
		Vector2(-12.0, -64.0), Vector2(0.0, -78.0), Vector2(12.0, -64.0),
		Vector2(8.0, -43.0), Vector2(0.0, -36.0), Vector2(-8.0, -43.0),
	])
	draw_colored_polygon(crest, Color(0.48, 0.35, 0.18, 1.0))
