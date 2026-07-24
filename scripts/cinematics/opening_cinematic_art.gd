class_name OpeningCinematicArt
extends Node2D

## Original native-2D pixel-panel illustrations for the eight opening shots.

const NIGHT: Color = Color(0.02, 0.028, 0.055, 1.0)
const SKY: Color = Color(0.055, 0.075, 0.12, 1.0)
const STONE: Color = Color(0.18, 0.19, 0.24, 1.0)
const STONE_EDGE: Color = Color(0.36, 0.4, 0.46, 1.0)
const FOREST: Color = Color(0.03, 0.07, 0.065, 1.0)
const STEEL: Color = Color(0.68, 0.76, 0.82, 1.0)
const SOUL: Color = Color(0.56, 0.82, 0.92, 0.82)
const CURSE: Color = Color(0.42, 0.08, 0.1, 0.86)
const AMBER: Color = Color(0.58, 0.37, 0.17, 1.0)

var shot_index: int = 0


func set_shot(index: int) -> void:
	shot_index = clampi(index, 0, 7)
	queue_redraw()


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-120.0, -80.0, 1520.0, 880.0), NIGHT)
	match shot_index:
		0:
			_draw_northern_wilds()
		1:
			_draw_hollow_bell(false)
		2:
			_draw_hollow_bell(true)
		3:
			_draw_spreading_curse()
		4:
			_draw_veiled_order()
		5:
			_draw_awakening()
		6:
			_draw_memory_fragments()
		7:
			_draw_departure()


func _draw_northern_wilds() -> void:
	draw_rect(Rect2(-20.0, 20.0, 1320.0, 700.0), SKY)
	draw_circle(Vector2(930.0, 170.0), 64.0, Color(0.66, 0.7, 0.78, 1.0))
	draw_rect(Rect2(0.0, 500.0, 1280.0, 220.0), Color(0.06, 0.065, 0.07, 1.0))
	var forest_line: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, 560.0), Vector2(0.0, 420.0), Vector2(90.0, 350.0), Vector2(160.0, 430.0),
		Vector2(260.0, 320.0), Vector2(350.0, 440.0), Vector2(470.0, 338.0), Vector2(580.0, 450.0),
		Vector2(720.0, 330.0), Vector2(850.0, 455.0), Vector2(1010.0, 350.0), Vector2(1130.0, 430.0),
		Vector2(1280.0, 360.0), Vector2(1280.0, 720.0), Vector2(0.0, 720.0),
	])
	draw_colored_polygon(forest_line, FOREST)
	_draw_castle_silhouette(Vector2(920.0, 410.0), 0.62)
	for crow_origin: Vector2 in [Vector2(610.0, 210.0), Vector2(670.0, 244.0), Vector2(730.0, 190.0)]:
		draw_line(crow_origin, crow_origin + Vector2(12.0, 7.0), Color.BLACK, 3.0)
		draw_line(crow_origin + Vector2(12.0, 7.0), crow_origin + Vector2(24.0, 0.0), Color.BLACK, 3.0)


func _draw_hollow_bell(ringing: bool) -> void:
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color(0.018, 0.02, 0.032, 1.0))
	for pillar_x: float in [120.0, 1060.0]:
		draw_rect(Rect2(pillar_x, 80.0, 100.0, 640.0), STONE)
		for course_y: float in range(110, 700, 46):
			draw_line(Vector2(pillar_x, course_y), Vector2(pillar_x + 100.0, course_y), STONE_EDGE, 2.0)
	for chain_x: float in [500.0, 780.0]:
		for chain_y: float in range(0, 250, 22):
			draw_rect(Rect2(chain_x - 6.0, chain_y, 12.0, 16.0), STONE_EDGE, false, 3.0)
	var bell: PackedVector2Array = PackedVector2Array([
		Vector2(512.0, 258.0), Vector2(768.0, 258.0), Vector2(740.0, 510.0),
		Vector2(820.0, 580.0), Vector2(460.0, 580.0), Vector2(540.0, 510.0),
	])
	draw_colored_polygon(bell, Color(0.08, 0.09, 0.115, 1.0))
	draw_polyline(bell, STONE_EDGE, 6.0)
	draw_circle(Vector2(640.0, 612.0), 34.0, Color(0.03, 0.028, 0.03, 1.0))
	for rune_x: float in [552.0, 610.0, 668.0, 726.0]:
		draw_line(Vector2(rune_x, 354.0), Vector2(rune_x + 20.0, 450.0), CURSE if ringing else Color(0.22, 0.25, 0.28, 1.0), 4.0)
	if ringing:
		draw_line(Vector2(640.0, 320.0), Vector2(680.0, 535.0), CURSE, 10.0)
		for radius: float in [170.0, 220.0, 270.0]:
			draw_arc(Vector2(640.0, 440.0), radius, 0.2, PI - 0.2, 20, Color(CURSE, 0.28), 3.0)


func _draw_spreading_curse() -> void:
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), SKY)
	draw_rect(Rect2(0.0, 510.0, 1280.0, 210.0), Color(0.055, 0.05, 0.055, 1.0))
	for grave_x: float in [90.0, 220.0, 350.0]:
		draw_rect(Rect2(grave_x, 430.0, 42.0, 100.0), STONE)
		draw_circle(Vector2(grave_x + 21.0, 430.0), 21.0, STONE)
		draw_line(Vector2(grave_x + 18.0, 532.0), Vector2(grave_x - 8.0, 470.0), Color(0.2, 0.17, 0.16, 1.0), 8.0)
	_draw_guard(Vector2(650.0, 520.0), true)
	_draw_guard(Vector2(820.0, 520.0), false)
	for root_x: float in [1030.0, 1180.0]:
		draw_line(Vector2(root_x, 580.0), Vector2(root_x - 30.0, 260.0), FOREST, 24.0)
		draw_line(Vector2(root_x - 18.0, 360.0), Vector2(root_x - 120.0, 260.0), FOREST, 14.0)
		draw_line(Vector2(root_x - 12.0, 330.0), Vector2(root_x + 100.0, 220.0), FOREST, 12.0)
	draw_rect(Rect2(0.0, 610.0, 1280.0, 110.0), Color(0.02, 0.15, 0.22, 1.0))
	for wave_x: float in range(20, 1260, 110):
		draw_line(Vector2(wave_x, 632.0), Vector2(wave_x + 64.0, 632.0), SOUL, 3.0)


func _draw_veiled_order() -> void:
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), SKY)
	_draw_castle_silhouette(Vector2(880.0, 390.0), 0.72)
	for index: int in range(5):
		var origin: Vector2 = Vector2(230.0 + float(index) * 130.0, 550.0 + float(index % 2) * 12.0)
		_draw_cloaked_figure(origin, index == 4)
	draw_rect(Rect2(70.0, 618.0, 1140.0, 102.0), Color(0.055, 0.05, 0.05, 1.0))
	draw_line(Vector2(800.0, 596.0), Vector2(874.0, 624.0), CURSE, 6.0)
	draw_line(Vector2(846.0, 620.0), Vector2(900.0, 580.0), STEEL, 5.0)


func _draw_awakening() -> void:
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), SKY)
	for tree_x: float in [80.0, 1120.0]:
		draw_line(Vector2(tree_x, 650.0), Vector2(tree_x + 40.0, 180.0), FOREST, 30.0)
		draw_line(Vector2(tree_x + 20.0, 330.0), Vector2(tree_x - 130.0, 240.0), FOREST, 16.0)
	draw_rect(Rect2(0.0, 596.0, 1280.0, 124.0), Color(0.065, 0.07, 0.065, 1.0))
	var body: PackedVector2Array = PackedVector2Array([
		Vector2(450.0, 570.0), Vector2(760.0, 570.0), Vector2(820.0, 620.0),
		Vector2(420.0, 620.0),
	])
	draw_colored_polygon(body, Color(0.04, 0.07, 0.09, 1.0))
	draw_circle(Vector2(438.0, 574.0), 34.0, Color(0.025, 0.04, 0.055, 1.0))
	var ghost: PackedVector2Array = PackedVector2Array([
		Vector2(560.0, 520.0), Vector2(610.0, 420.0), Vector2(660.0, 520.0),
		Vector2(646.0, 568.0), Vector2(574.0, 568.0),
	])
	draw_colored_polygon(ghost, SOUL)
	draw_rect(Rect2(596.0, 508.0, 28.0, 5.0), STEEL)
	draw_circle(Vector2(610.0, 566.0), 12.0, Color(0.72, 0.78, 0.82, 0.76))


func _draw_memory_fragments() -> void:
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color(0.006, 0.006, 0.012, 1.0))
	var panels: Array[Rect2] = [
		Rect2(90.0, 90.0, 300.0, 220.0), Rect2(490.0, 70.0, 300.0, 240.0),
		Rect2(890.0, 100.0, 300.0, 210.0), Rect2(270.0, 390.0, 300.0, 220.0),
		Rect2(710.0, 380.0, 300.0, 230.0),
	]
	for index: int in range(panels.size()):
		draw_rect(panels[index], Color(0.06, 0.065, 0.08, 1.0))
		draw_rect(panels[index], STONE_EDGE, false, 3.0)
	draw_circle(Vector2(240.0, 196.0), 38.0, AMBER, false, 8.0)
	draw_rect(Rect2(590.0, 124.0, 100.0, 170.0), Color(0.015, 0.02, 0.03, 1.0))
	draw_line(Vector2(938.0, 260.0), Vector2(1120.0, 142.0), STEEL, 8.0)
	draw_line(Vector2(350.0, 548.0), Vector2(470.0, 430.0), CURSE, 12.0)
	draw_circle(Vector2(860.0, 492.0), 72.0, Color(0.025, 0.03, 0.04, 1.0))


func _draw_departure() -> void:
	_draw_northern_wilds()
	_draw_cloaked_figure(Vector2(510.0, 600.0), true)
	draw_line(Vector2(540.0, 564.0), Vector2(600.0, 520.0), STEEL, 6.0)
	draw_line(Vector2(540.0, 574.0), Vector2(606.0, 548.0), STEEL, 5.0)


func _draw_castle_silhouette(origin: Vector2, scale_factor: float) -> void:
	var castle: PackedVector2Array = PackedVector2Array([
		origin + Vector2(0.0, 170.0) * scale_factor, origin + Vector2(0.0, 40.0) * scale_factor,
		origin + Vector2(60.0, -50.0) * scale_factor, origin + Vector2(120.0, 40.0) * scale_factor,
		origin + Vector2(180.0, -90.0) * scale_factor, origin + Vector2(240.0, 40.0) * scale_factor,
		origin + Vector2(310.0, -34.0) * scale_factor, origin + Vector2(370.0, 40.0) * scale_factor,
		origin + Vector2(370.0, 170.0) * scale_factor,
	])
	draw_colored_polygon(castle, Color(0.025, 0.03, 0.045, 1.0))


func _draw_cloaked_figure(origin: Vector2, highlighted: bool) -> void:
	var cloak: PackedVector2Array = PackedVector2Array([
		origin + Vector2(-34.0, 0.0), origin + Vector2(-22.0, -98.0),
		origin + Vector2(0.0, -132.0), origin + Vector2(22.0, -98.0),
		origin + Vector2(38.0, 0.0),
	])
	draw_colored_polygon(cloak, Color(0.07, 0.1, 0.14, 1.0))
	if highlighted:
		draw_rect(Rect2(origin.x - 15.0, origin.y - 100.0, 30.0, 4.0), STEEL)


func _draw_guard(origin: Vector2, red_eye: bool) -> void:
	draw_rect(Rect2(origin.x - 28.0, origin.y - 124.0, 56.0, 124.0), STONE)
	draw_rect(Rect2(origin.x - 32.0, origin.y - 154.0, 64.0, 42.0), STONE_EDGE)
	draw_rect(Rect2(origin.x - 18.0, origin.y - 138.0, 36.0, 5.0), CURSE if red_eye else SOUL)
	draw_line(origin + Vector2(28.0, -100.0), origin + Vector2(92.0, -40.0), STEEL, 7.0)
