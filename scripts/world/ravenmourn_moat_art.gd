class_name RavenmournMoatArt
extends Node2D

## Adds water depth cues and fortress reflections without changing MoatHazard.


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var reflection: Color = Color(0.08, 0.22, 0.31, 0.5)
	var ripple_bright: Color = Color(0.24, 0.52, 0.62, 0.72)
	var ripple_dim: Color = Color(0.12, 0.33, 0.45, 0.66)
	for reflection_x: float in [5600.0, 5710.0, 6080.0, 6240.0, 6330.0]:
		var width: float = 28.0 if int(reflection_x) % 2 == 0 else 18.0
		draw_rect(Rect2(reflection_x, 684.0, width, 44.0), reflection)
	for ripple_index: int in range(9):
		var x_position: float = 5540.0 + float(ripple_index) * 92.0
		var y_position: float = 682.0 + float(ripple_index % 4) * 10.0
		var ripple_width: float = 42.0 + float((ripple_index * 17) % 48)
		var color: Color = ripple_bright if ripple_index % 3 == 0 else ripple_dim
		draw_line(Vector2(x_position, y_position), Vector2(x_position + ripple_width, y_position), color, 2.0)
		draw_line(Vector2(x_position + 12.0, y_position + 3.0), Vector2(x_position + ripple_width + 24.0, y_position + 3.0), Color(color, 0.45), 2.0)
	# Narrow foam seams make the fall read as water rather than an abstract dark band.
	draw_line(Vector2(5522.0, 677.0), Vector2(5620.0, 677.0), Color(0.44, 0.67, 0.72, 0.7), 2.0)
	draw_line(Vector2(6280.0, 677.0), Vector2(6358.0, 677.0), Color(0.44, 0.67, 0.72, 0.7), 2.0)
