class_name HollowDuchessBallroomFx
extends Node2D

## Low-cost native-2D Ballroom presentation responding to the Boss phase.

var _phase: int = 1
var _pulse: float = 0.0


func _process(delta: float) -> void:
	_pulse += delta
	queue_redraw()


func set_phase(phase: int) -> void:
	_phase = phase
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, -180, 4608, 792), Color("100d18"), true)
	# Mirror bays and pillars stay behind actors.
	for index: int in range(7):
		var x: float = 300.0 + float(index) * 660.0
		draw_rect(Rect2(x, 30, 360, 410), Color("171525"), true)
		draw_rect(Rect2(x + 18, 48, 324, 374), Color("2a253a"), false, 6.0)
		if _phase >= 2:
			var alpha: float = 0.10 + 0.05 * sin(_pulse * 2.0 + float(index))
			draw_circle(Vector2(x + 180, 305), 54.0, Color(0.58, 0.52, 0.70, alpha))
	# Soul-fire sconces illuminate sequentially during the first phase and intensify in phase two.
	for index: int in range(10):
		var x: float = 210.0 + float(index) * 455.0
		var glow: float = 0.55 + 0.18 * sin(_pulse * 3.0 + float(index) * 0.7)
		if _phase >= 2:
			glow = minf(0.95, glow + 0.18)
		draw_circle(Vector2(x, 222), 18.0, Color(0.50, 0.68, 0.82, glow * 0.18))
		draw_circle(Vector2(x, 222), 6.0, Color(0.68, 0.82, 0.92, glow))
	# Ballroom trim and floor reflection.
	draw_line(Vector2(0, 540), Vector2(4608, 540), Color("53435f"), 4.0)
	for x: int in range(0, 4608, 96):
		draw_line(Vector2(x, 612), Vector2(x + 48, 540), Color(0.32, 0.25, 0.37, 0.28), 2.0)
