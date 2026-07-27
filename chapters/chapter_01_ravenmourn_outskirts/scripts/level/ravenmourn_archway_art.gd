class_name RavenmournArchwayArt
extends Node2D

## Non-blocking Gothic iron wayfinding arch at the Boss approach threshold.


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var iron: Color = Color(0.12, 0.13, 0.16, 1.0)
	var iron_edge: Color = Color(0.31, 0.34, 0.39, 0.9)
	var brass: Color = Color(0.43, 0.31, 0.18, 1.0)
	draw_rect(Rect2(-70.0, -220.0, 12.0, 220.0), iron)
	draw_rect(Rect2(58.0, -220.0, 12.0, 220.0), iron)
	draw_line(Vector2(-64.0, -218.0), Vector2(0.0, -286.0), iron, 12.0)
	draw_line(Vector2(0.0, -286.0), Vector2(64.0, -218.0), iron, 12.0)
	draw_line(Vector2(-64.0, -218.0), Vector2(0.0, -268.0), iron_edge, 2.0)
	draw_line(Vector2(0.0, -268.0), Vector2(64.0, -218.0), iron_edge, 2.0)
	for spike_x: float in [-64.0, -32.0, 0.0, 32.0, 64.0]:
		var spike_base_y: float = -220.0 - (64.0 - absf(spike_x)) * 0.72
		var spike: PackedVector2Array = PackedVector2Array([
			Vector2(spike_x - 5.0, spike_base_y),
			Vector2(spike_x, spike_base_y - 18.0),
			Vector2(spike_x + 5.0, spike_base_y),
		])
		draw_colored_polygon(spike, iron)
	draw_rect(Rect2(-118.0, -246.0, 236.0, 42.0), Color(0.105, 0.075, 0.055, 1.0))
	draw_rect(Rect2(-112.0, -240.0, 224.0, 30.0), Color(0.19, 0.13, 0.085, 1.0))
	draw_rect(Rect2(-118.0, -246.0, 236.0, 42.0), brass, false, 2.0)
	for rivet_x: float in [-102.0, 102.0]:
		draw_rect(Rect2(rivet_x - 2.0, -227.0, 4.0, 4.0), brass)
	draw_rect(Rect2(-82.0, -8.0, 36.0, 8.0), Color(0.18, 0.18, 0.22, 1.0))
	draw_rect(Rect2(46.0, -8.0, 36.0, 8.0), Color(0.18, 0.18, 0.22, 1.0))
