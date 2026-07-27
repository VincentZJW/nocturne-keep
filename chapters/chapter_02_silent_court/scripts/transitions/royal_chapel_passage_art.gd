class_name RoyalChapelPassageArt
extends Node2D

## Original native-2D first-pass art for the enemy-free processional corridor.

const WIDTH: float = 3600.0
const FLOOR_Y: float = 612.0


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, WIDTH, 720), Color("0b0c13"), true)
	draw_rect(Rect2(0, 76, WIDTH, 536), Color("171822"), true)
	# Repeating pointed window bays and thirteen bell groups.
	for bay_index: int in range(11):
		var x: float = 180.0 + float(bay_index) * 320.0
		var arch: PackedVector2Array = PackedVector2Array([
			Vector2(x - 74, 392), Vector2(x - 74, 220), Vector2(x, 142),
			Vector2(x + 74, 220), Vector2(x + 74, 392),
		])
		draw_colored_polygon(arch, Color("202431"))
		draw_polyline(arch, Color("5a4b37"), 5.0)
		draw_line(Vector2(x, 158), Vector2(x, 382), Color(0.37, 0.45, 0.53, 0.5), 3.0)
		if bay_index < 10:
			draw_circle(Vector2(x + 144, 286), 10.0, Color("675b4a"))
			draw_arc(Vector2(x + 144, 292), 14.0, PI, TAU, 16, Color("88775c"), 3.0)
	# Five short ceremonial steps are readable without extending the route.
	for step_index: int in range(5):
		var step_x: float = 300.0 + float(step_index) * 34.0
		draw_rect(Rect2(step_x, FLOOR_Y - float(step_index + 1) * 8.0, 180.0, 8.0), Color("34343d"), true)
	# Red royal runner, prayer benches and extinguished sconces.
	draw_rect(Rect2(0, FLOOR_Y - 20, WIDTH, 20), Color("3b1721"), true)
	draw_line(Vector2(0, FLOOR_Y - 20), Vector2(WIDTH, FLOOR_Y - 20), Color("6e3a38"), 2.0)
	for prop_index: int in range(8):
		var x: float = 520.0 + float(prop_index) * 410.0
		draw_rect(Rect2(x, 500, 140, 18), Color("262126"), true)
		draw_line(Vector2(x + 16, 518), Vector2(x + 10, 568), Color("3b3331"), 5.0)
		draw_line(Vector2(x + 124, 518), Vector2(x + 130, 568), Color("3b3331"), 5.0)
	# Confession inscription and old processional blades.
	draw_string(ThemeDB.fallback_font, Vector2(1330, 172), "XIII CONFESSIONS REMEMBER WHAT THE COURT FORGOT", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.55, 0.55, 0.61, 0.72))
	for sword_index: int in range(4):
		var x: float = 1460.0 + float(sword_index) * 220.0
		draw_line(Vector2(x, 196), Vector2(x, 298), Color("777b82"), 4.0)
		draw_line(Vector2(x - 18, 224), Vector2(x + 18, 224), Color("65543b"), 5.0)
	# Restrained floor mist.
	for mist_index: int in range(28):
		var x: float = 40.0 + float(mist_index) * 128.0
		draw_circle(Vector2(x, 598), 24.0, Color(0.58, 0.64, 0.70, 0.035))
