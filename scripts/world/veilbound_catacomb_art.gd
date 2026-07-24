class_name VeilboundCatacombArt
extends Node2D

## Original native-2D pixel-edged environment for the Severed Altar chamber.

const STONE_DARK: Color = Color("101721")
const STONE: Color = Color("26303b")
const STONE_LIGHT: Color = Color("465563")
const SOUL_BLUE: Color = Color("86bad1")
const SILVER: Color = Color("b7c7cf")

var soul_pulse: float = 0.0


func _ready() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	soul_pulse = fmod(soul_pulse + delta, TAU)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1600, 720), Color("070b12"))
	_draw_stone_wall()
	_draw_columns()
	_draw_sarcophagi()
	_draw_order_remains()
	_draw_altar()
	_draw_soul_fires()
	_draw_mist()
	_draw_exit_moonlight()


func _draw_stone_wall() -> void:
	draw_rect(Rect2(0, 90, 1600, 570), STONE_DARK)
	for row: int in range(7):
		var y: float = 112.0 + float(row) * 74.0
		var offset: float = 0.0 if row % 2 == 0 else -58.0
		for column: int in range(15):
			var x: float = offset + float(column) * 118.0
			draw_rect(Rect2(x, y, 112, 68), STONE, false, 2.0)
			draw_line(Vector2(x + 8, y + 60), Vector2(x + 104, y + 60), Color("171f29"), 2.0)
	draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(1600, 0), Vector2(1500, 112), Vector2(100, 112)]), Color("04070d"))
	draw_rect(Rect2(0, 654, 1600, 66), Color("171d25"))
	draw_line(Vector2(0, 654), Vector2(1600, 654), STONE_LIGHT, 3.0)
	# Veiled Order crest behind the altar.
	draw_arc(Vector2(500, 248), 72, PI * 0.12, PI * 0.88, 18, SILVER * Color(1, 1, 1, 0.38), 5.0)
	draw_line(Vector2(455, 228), Vector2(500, 318), SILVER * Color(1, 1, 1, 0.34), 4.0)
	draw_line(Vector2(545, 228), Vector2(500, 318), SILVER * Color(1, 1, 1, 0.34), 4.0)
	draw_circle(Vector2(500, 274), 11, Color("0b111a"))
	draw_circle(Vector2(500, 274), 5, SOUL_BLUE * Color(1, 1, 1, 0.55))


func _draw_columns() -> void:
	for x: float in [105.0, 910.0, 1190.0, 1510.0]:
		draw_rect(Rect2(x - 27, 160, 54, 494), Color("202a34"))
		draw_rect(Rect2(x - 36, 146, 72, 24), STONE_LIGHT)
		draw_rect(Rect2(x - 40, 630, 80, 24), Color("303b46"))
		for y: float in [238.0, 356.0, 474.0]:
			draw_rect(Rect2(x - 24, y, 48, 5), Color("111923"))


func _draw_sarcophagi() -> void:
	_draw_sarcophagus(Vector2(218, 548), -0.07)
	_draw_sarcophagus(Vector2(1034, 568), 0.05)
	_draw_sarcophagus(Vector2(1110, 505), -0.04)


func _draw_sarcophagus(center: Vector2, angle: float) -> void:
	var points: PackedVector2Array = PackedVector2Array([
		center + Vector2(-76, -30).rotated(angle), center + Vector2(58, -30).rotated(angle),
		center + Vector2(78, 20).rotated(angle), center + Vector2(-62, 28).rotated(angle),
	])
	draw_colored_polygon(points, Color("303844"))
	draw_polyline(points + PackedVector2Array([points[0]]), STONE_LIGHT, 3.0)
	draw_line(center + Vector2(-38, -4), center + Vector2(38, 2), Color("151c25"), 4.0)


func _draw_order_remains() -> void:
	# Fallen Veiled Order member and broken weapon.
	draw_colored_polygon(PackedVector2Array([Vector2(760, 611), Vector2(818, 578), Vector2(874, 618), Vector2(842, 648), Vector2(782, 646)]), Color("111823"))
	draw_circle(Vector2(804, 590), 15, Color("0a1018"))
	draw_line(Vector2(858, 610), Vector2(920, 572), Color("6b7680"), 4.0)
	draw_line(Vector2(903, 584), Vector2(931, 608), Color("6b7680"), 3.0)
	draw_line(Vector2(920, 572), Vector2(936, 557), Color("3a424a"), 3.0)
	# Black cloak and broken dagger near the left sarcophagus.
	draw_colored_polygon(PackedVector2Array([Vector2(300, 622), Vector2(356, 584), Vector2(410, 640), Vector2(328, 650)]), Color("0b111a"))
	draw_line(Vector2(374, 606), Vector2(420, 583), SILVER, 3.0)
	draw_line(Vector2(420, 583), Vector2(432, 592), Color("3b4652"), 3.0)


func _draw_altar() -> void:
	draw_rect(Rect2(352, 545, 296, 24), Color("53616c"))
	draw_rect(Rect2(368, 569, 264, 68), Color("2b3540"))
	draw_rect(Rect2(388, 637, 224, 17), Color("46525e"))
	for x: float in [395.0, 605.0]:
		draw_rect(Rect2(x, 579, 18, 54), Color("1b242e"))
	# Severed Soul Mark inlaid into the altar face.
	draw_arc(Vector2(500, 602), 22, 0.2, PI * 1.8, 18, SILVER * Color(1, 1, 1, 0.7), 3.0)
	draw_line(Vector2(488, 581), Vector2(509, 624), SOUL_BLUE * Color(1, 1, 1, 0.75), 2.0)


func _draw_soul_fires() -> void:
	for x: float in [160.0, 690.0, 970.0, 1240.0]:
		var flame_height: float = 24.0 + sin(soul_pulse * 2.0 + x) * 3.0
		draw_rect(Rect2(x - 12, 446, 24, 5), Color("343d46"))
		draw_colored_polygon(PackedVector2Array([Vector2(x - 8, 446), Vector2(x - 5, 424), Vector2(x, 446 - flame_height), Vector2(x + 6, 426), Vector2(x + 8, 446)]), SOUL_BLUE * Color(1, 1, 1, 0.76))
		draw_circle(Vector2(x, 438), 14, SOUL_BLUE * Color(1, 1, 1, 0.09))


func _draw_mist() -> void:
	for index: int in range(7):
		var x: float = fmod(float(index) * 247.0 + soul_pulse * 12.0, 1760.0) - 80.0
		_draw_mist_ellipse(Vector2(x, 626), Vector2(112, 12), Color(0.35, 0.55, 0.64, 0.055))


func _draw_exit_moonlight() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(1306, 244), Vector2(1458, 244), Vector2(1504, 654), Vector2(1256, 654)]), Color(0.35, 0.5, 0.65, 0.10))
	for x: float in [1340.0, 1384.0, 1428.0]:
		draw_line(Vector2(x, 300), Vector2(x - 14, 654), Color(0.48, 0.65, 0.76, 0.09), 12.0)


func _draw_mist_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(24):
		var angle: float = TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
