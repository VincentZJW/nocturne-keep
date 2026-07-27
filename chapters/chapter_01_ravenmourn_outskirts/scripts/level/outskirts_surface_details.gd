class_name OutskirtsSurfaceDetails
extends Node2D

## Readability-safe foreground and play-surface decoration for early/middle Main.
## All props are visual-only and stay behind actors and attack silhouettes.

const EARTH: Color = Color(0.105, 0.105, 0.105, 1.0)
const EARTH_MID: Color = Color(0.15, 0.135, 0.115, 1.0)
const COBBLE: Color = Color(0.205, 0.21, 0.22, 0.92)
const COBBLE_EDGE: Color = Color(0.31, 0.34, 0.36, 0.72)
const GRASS: Color = Color(0.16, 0.225, 0.17, 1.0)
const BRAMBLE: Color = Color(0.105, 0.155, 0.115, 1.0)
const WOOD: Color = Color(0.17, 0.105, 0.064, 1.0)
const WOOD_EDGE: Color = Color(0.31, 0.22, 0.13, 0.85)
const STONE: Color = Color(0.22, 0.23, 0.25, 1.0)
const IRON: Color = Color(0.1, 0.105, 0.115, 1.0)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_draw_earth_road()
	_draw_cobbles()
	_draw_platform_detail()
	_draw_vegetation()
	_draw_broken_fence()
	_draw_road_sign()
	_draw_cart_wreck()
	_draw_grave_stones()


func _draw_earth_road() -> void:
	draw_rect(Rect2(-100.0, 640.0, 2700.0, 96.0), EARTH)
	draw_rect(Rect2(-100.0, 640.0, 2700.0, 7.0), Color(0.29, 0.31, 0.3, 1.0))
	var road_patches: Array[Rect2] = [
		Rect2(280.0, 652.0, 340.0, 18.0), Rect2(760.0, 676.0, 420.0, 16.0),
		Rect2(1320.0, 648.0, 390.0, 20.0), Rect2(1900.0, 684.0, 520.0, 18.0),
	]
	for patch: Rect2 in road_patches:
		draw_rect(patch, EARTH_MID)


func _draw_cobbles() -> void:
	var cobbles: Array[Rect2] = [
		Rect2(340.0, 650.0, 42.0, 12.0), Rect2(396.0, 654.0, 34.0, 10.0),
		Rect2(820.0, 648.0, 54.0, 13.0), Rect2(892.0, 652.0, 38.0, 11.0),
		Rect2(1460.0, 648.0, 48.0, 12.0), Rect2(1530.0, 652.0, 56.0, 10.0),
		Rect2(2070.0, 648.0, 46.0, 12.0), Rect2(2140.0, 650.0, 34.0, 11.0),
		Rect2(2380.0, 648.0, 52.0, 12.0), Rect2(2500.0, 650.0, 42.0, 10.0),
	]
	for cobble: Rect2 in cobbles:
		draw_rect(cobble, COBBLE)
		draw_line(cobble.position, Vector2(cobble.end.x, cobble.position.y), COBBLE_EDGE, 2.0)


func _draw_platform_detail() -> void:
	draw_line(Vector2(760.0, 508.0), Vector2(980.0, 508.0), COBBLE_EDGE, 3.0)
	for joint_x: float in range(786, 970, 38):
		draw_line(Vector2(joint_x, 512.0), Vector2(joint_x - 6.0, 532.0), Color(COBBLE_EDGE, 0.62), 2.0)
	draw_line(Vector2(2685.0, 500.0), Vector2(2875.0, 500.0), COBBLE_EDGE, 3.0)
	for joint_x: float in range(2710, 2860, 42):
		draw_line(Vector2(joint_x, 504.0), Vector2(joint_x - 8.0, 524.0), Color(COBBLE_EDGE, 0.62), 2.0)


func _draw_vegetation() -> void:
	for root_x: float in [30.0, 110.0, 590.0, 700.0, 1020.0, 1190.0, 1740.0, 1990.0, 2240.0, 2580.0]:
		_draw_grass_tuft(Vector2(root_x, 640.0), 14.0 + float(int(root_x) % 9))
	for center: Vector2 in [Vector2(680.0, 632.0), Vector2(1210.0, 634.0), Vector2(2050.0, 634.0), Vector2(2580.0, 634.0)]:
		draw_circle(center, 16.0, BRAMBLE)
		draw_circle(center + Vector2(15.0, 4.0), 12.0, BRAMBLE)
		draw_line(center + Vector2(-8.0, 6.0), center + Vector2(18.0, -10.0), GRASS, 2.0)


func _draw_grass_tuft(root: Vector2, height: float) -> void:
	draw_line(root, root + Vector2(-9.0, -height * 0.7), GRASS, 3.0)
	draw_line(root, root + Vector2(-2.0, -height), GRASS, 3.0)
	draw_line(root + Vector2(2.0, 0.0), root + Vector2(8.0, -height * 0.8), GRASS, 3.0)
	draw_line(root + Vector2(4.0, 0.0), root + Vector2(14.0, -height * 0.45), BRAMBLE, 2.0)


func _draw_broken_fence() -> void:
	for post_x: float in [155.0, 226.0, 298.0]:
		draw_rect(Rect2(post_x, 584.0, 9.0, 56.0), WOOD)
		draw_line(Vector2(post_x + 2.0, 587.0), Vector2(post_x + 2.0, 636.0), WOOD_EDGE, 2.0)
	draw_line(Vector2(156.0, 602.0), Vector2(294.0, 618.0), WOOD, 8.0)
	draw_line(Vector2(156.0, 626.0), Vector2(246.0, 610.0), WOOD, 7.0)


func _draw_road_sign() -> void:
	draw_rect(Rect2(1062.0, 570.0, 10.0, 70.0), WOOD)
	var sign: PackedVector2Array = PackedVector2Array([
		Vector2(1030.0, 574.0), Vector2(1100.0, 566.0), Vector2(1120.0, 580.0),
		Vector2(1100.0, 594.0), Vector2(1030.0, 588.0),
	])
	draw_colored_polygon(sign, WOOD)
	draw_line(Vector2(1040.0, 578.0), Vector2(1098.0, 573.0), WOOD_EDGE, 2.0)


func _draw_cart_wreck() -> void:
	draw_line(Vector2(1780.0, 624.0), Vector2(1870.0, 606.0), WOOD, 10.0)
	draw_line(Vector2(1800.0, 590.0), Vector2(1848.0, 630.0), WOOD, 8.0)
	draw_circle(Vector2(1790.0, 626.0), 22.0, IRON, false, 5.0)
	for angle_index: int in range(6):
		var direction: Vector2 = Vector2.RIGHT.rotated(float(angle_index) * PI / 3.0)
		draw_line(Vector2(1790.0, 626.0), Vector2(1790.0, 626.0) + direction * 18.0, IRON, 2.0)


func _draw_grave_stones() -> void:
	for grave: Rect2 in [Rect2(2460.0, 594.0, 24.0, 46.0), Rect2(2520.0, 606.0, 20.0, 34.0)]:
		draw_rect(grave, STONE)
		draw_circle(Vector2(grave.position.x + grave.size.x * 0.5, grave.position.y), grave.size.x * 0.5, STONE)
		draw_line(Vector2(grave.position.x + 5.0, grave.position.y + 12.0), Vector2(grave.end.x - 5.0, grave.position.y + 12.0), COBBLE_EDGE, 2.0)
