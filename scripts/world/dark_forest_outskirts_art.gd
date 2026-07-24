class_name DarkForestOutskirtsArt
extends Node2D

## Layered wilderness and haunted forest backdrop for the first third of Main.
## Presentation only: it owns no collision, AI, camera, or encounter authority.

const SKY_HIGH: Color = Color(0.018, 0.028, 0.055, 1.0)
const SKY_LOW: Color = Color(0.035, 0.052, 0.074, 1.0)
const MOON: Color = Color(0.64, 0.69, 0.77, 1.0)
const MOON_GLOW: Color = Color(0.38, 0.48, 0.6, 0.15)
const FAR_FOREST: Color = Color(0.025, 0.045, 0.048, 1.0)
const MID_FOREST: Color = Color(0.035, 0.062, 0.058, 1.0)
const TRUNK_DARK: Color = Color(0.045, 0.052, 0.05, 1.0)
const TRUNK_EDGE: Color = Color(0.095, 0.112, 0.098, 0.72)
const MIST: Color = Color(0.2, 0.3, 0.34, 0.1)
const RUIN_STONE: Color = Color(0.075, 0.09, 0.1, 1.0)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_draw_sky()
	_draw_moon()
	_draw_far_tree_line()
	_draw_distant_ruins()
	_draw_midground_trees()
	_draw_mist()


func _draw_sky() -> void:
	draw_rect(Rect2(-100.0, 80.0, 2520.0, 560.0), SKY_HIGH)
	draw_rect(Rect2(-100.0, 286.0, 2520.0, 354.0), SKY_LOW)
	draw_rect(Rect2(-100.0, 482.0, 2520.0, 158.0), Color(0.025, 0.044, 0.052, 1.0))
	for cloud: Rect2 in [
		Rect2(60.0, 164.0, 360.0, 14.0), Rect2(310.0, 188.0, 420.0, 18.0),
		Rect2(1080.0, 152.0, 440.0, 16.0), Rect2(1480.0, 206.0, 520.0, 18.0),
	]:
		draw_rect(cloud, Color(0.08, 0.105, 0.125, 0.38))


func _draw_moon() -> void:
	draw_circle(Vector2(760.0, 235.0), 88.0, MOON_GLOW)
	var moon_shape: PackedVector2Array = PackedVector2Array([
		Vector2(760.0, 173.0), Vector2(784.0, 178.0), Vector2(804.0, 191.0),
		Vector2(817.0, 211.0), Vector2(822.0, 235.0), Vector2(817.0, 259.0),
		Vector2(804.0, 279.0), Vector2(784.0, 292.0), Vector2(760.0, 297.0),
		Vector2(736.0, 292.0), Vector2(716.0, 279.0), Vector2(703.0, 259.0),
		Vector2(698.0, 235.0), Vector2(703.0, 211.0), Vector2(716.0, 191.0),
		Vector2(736.0, 178.0),
	])
	draw_colored_polygon(moon_shape, MOON)
	draw_rect(Rect2(724.0, 210.0, 18.0, 8.0), Color(0.47, 0.52, 0.6, 0.28))
	draw_rect(Rect2(774.0, 258.0, 24.0, 7.0), Color(0.47, 0.52, 0.6, 0.22))


func _draw_far_tree_line() -> void:
	var tree_line: PackedVector2Array = PackedVector2Array([
		Vector2(-100.0, 640.0), Vector2(-100.0, 430.0), Vector2(40.0, 370.0),
		Vector2(160.0, 422.0), Vector2(270.0, 345.0), Vector2(390.0, 420.0),
		Vector2(510.0, 322.0), Vector2(630.0, 410.0), Vector2(850.0, 350.0),
		Vector2(1010.0, 430.0), Vector2(1170.0, 332.0), Vector2(1320.0, 416.0),
		Vector2(1490.0, 302.0), Vector2(1640.0, 404.0), Vector2(1830.0, 328.0),
		Vector2(1990.0, 410.0), Vector2(2180.0, 344.0), Vector2(2420.0, 430.0),
		Vector2(2420.0, 640.0),
	])
	draw_colored_polygon(tree_line, FAR_FOREST)
	for tree_x: float in range(-40, 2420, 92):
		var height: float = 112.0 + float((int(tree_x) / 92) % 4) * 18.0
		_draw_far_pine(Vector2(tree_x, 505.0), height)


func _draw_far_pine(root: Vector2, height: float) -> void:
	draw_rect(Rect2(root.x - 3.0, root.y - height, 6.0, height + 135.0), FAR_FOREST)
	for tier: int in range(4):
		var tier_y: float = root.y - height + 20.0 + float(tier) * 26.0
		var half_width: float = 26.0 + float(tier) * 10.0
		var crown: PackedVector2Array = PackedVector2Array([
			Vector2(root.x, tier_y - 28.0), Vector2(root.x - half_width, tier_y + 22.0),
			Vector2(root.x + half_width, tier_y + 22.0),
		])
		draw_colored_polygon(crown, FAR_FOREST)


func _draw_distant_ruins() -> void:
	draw_rect(Rect2(1540.0, 486.0, 470.0, 154.0), RUIN_STONE)
	for merlon_x: float in range(1550, 2010, 54):
		draw_rect(Rect2(merlon_x, 464.0, 28.0, 24.0), RUIN_STONE)
	var broken_top: PackedVector2Array = PackedVector2Array([
		Vector2(1780.0, 486.0), Vector2(1780.0, 414.0), Vector2(1816.0, 414.0),
		Vector2(1838.0, 386.0), Vector2(1862.0, 414.0), Vector2(1902.0, 414.0),
		Vector2(1902.0, 486.0),
	])
	draw_colored_polygon(broken_top, RUIN_STONE)
	draw_rect(Rect2(1644.0, 534.0, 54.0, 106.0), Color(0.016, 0.025, 0.03, 1.0))


func _draw_midground_trees() -> void:
	var roots: Array[Vector2] = [
		Vector2(90.0, 640.0), Vector2(470.0, 640.0), Vector2(1040.0, 640.0),
		Vector2(1370.0, 640.0), Vector2(2140.0, 640.0),
	]
	var heights: Array[float] = [270.0, 330.0, 300.0, 350.0, 250.0]
	for index: int in range(roots.size()):
		_draw_twisted_tree(roots[index], heights[index], index % 2 == 0)


func _draw_twisted_tree(root: Vector2, height: float, bends_right: bool) -> void:
	var bend: float = 34.0 if bends_right else -34.0
	var trunk: PackedVector2Array = PackedVector2Array([
		root + Vector2(-18.0, 0.0), root + Vector2(-12.0, -height * 0.46),
		root + Vector2(bend - 10.0, -height), root + Vector2(bend + 8.0, -height),
		root + Vector2(12.0, -height * 0.45), root + Vector2(18.0, 0.0),
	])
	draw_colored_polygon(trunk, TRUNK_DARK)
	draw_line(root + Vector2(-7.0, -12.0), root + Vector2(bend - 3.0, -height + 8.0), TRUNK_EDGE, 3.0)
	var crown: Vector2 = root + Vector2(bend, -height)
	var branch_direction: float = 1.0 if bends_right else -1.0
	_draw_branch(crown, Vector2(92.0 * branch_direction, -54.0))
	_draw_branch(crown + Vector2(0.0, 18.0), Vector2(-76.0 * branch_direction, -38.0))
	_draw_branch(crown + Vector2(4.0, 42.0), Vector2(88.0 * branch_direction, 8.0))


func _draw_branch(origin: Vector2, delta: Vector2) -> void:
	draw_line(origin, origin + delta, TRUNK_DARK, 10.0)
	draw_line(origin + delta * 0.55, origin + delta + Vector2(delta.x * 0.28, -28.0), TRUNK_DARK, 6.0)
	draw_line(origin + delta * 0.72, origin + delta + Vector2(-delta.x * 0.18, 22.0), TRUNK_DARK, 5.0)


func _draw_mist() -> void:
	for band: Rect2 in [
		Rect2(-60.0, 492.0, 640.0, 12.0), Rect2(380.0, 536.0, 780.0, 14.0),
		Rect2(1020.0, 478.0, 720.0, 12.0), Rect2(1540.0, 556.0, 780.0, 16.0),
	]:
		draw_rect(band, MIST)
