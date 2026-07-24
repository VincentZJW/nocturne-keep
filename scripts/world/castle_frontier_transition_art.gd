class_name CastleFrontierTransitionArt
extends Node2D

## Visual bridge from the haunted outskirts into Ravenmourn's ruined perimeter.
## It deliberately overlaps both adjacent art spans to avoid a hard theme seam.

const SKY: Color = Color(0.028, 0.043, 0.076, 1.0)
const SKY_LOW: Color = Color(0.04, 0.055, 0.085, 1.0)
const FAR_TREE: Color = Color(0.03, 0.05, 0.052, 1.0)
const FAR_CASTLE: Color = Color(0.052, 0.065, 0.095, 1.0)
const RUIN_DARK: Color = Color(0.085, 0.095, 0.12, 1.0)
const RUIN_MID: Color = Color(0.12, 0.13, 0.16, 1.0)
const STONE_EDGE: Color = Color(0.24, 0.28, 0.33, 0.68)
const IRON: Color = Color(0.08, 0.085, 0.1, 1.0)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_draw_sky_and_clouds()
	_draw_thinning_forest()
	_draw_distant_spires()
	_draw_ruined_watch_post()
	_draw_outer_wall_remains()


func _draw_sky_and_clouds() -> void:
	draw_rect(Rect2(2100.0, 80.0, 1640.0, 560.0), SKY)
	draw_rect(Rect2(2100.0, 320.0, 1640.0, 320.0), SKY_LOW)
	for band: Rect2 in [
		Rect2(2180.0, 176.0, 420.0, 16.0), Rect2(2510.0, 215.0, 500.0, 18.0),
		Rect2(3110.0, 162.0, 540.0, 20.0),
	]:
		draw_rect(band, Color(0.09, 0.105, 0.145, 0.42))


func _draw_thinning_forest() -> void:
	var tree_line: PackedVector2Array = PackedVector2Array([
		Vector2(2100.0, 640.0), Vector2(2100.0, 384.0), Vector2(2220.0, 330.0),
		Vector2(2340.0, 410.0), Vector2(2470.0, 348.0), Vector2(2590.0, 430.0),
		Vector2(2700.0, 374.0), Vector2(2820.0, 446.0), Vector2(2980.0, 396.0),
		Vector2(3120.0, 470.0), Vector2(3260.0, 420.0), Vector2(3420.0, 482.0),
		Vector2(3740.0, 482.0), Vector2(3740.0, 640.0),
	])
	draw_colored_polygon(tree_line, FAR_TREE)
	for tree_x: float in [2180.0, 2380.0, 2650.0, 2940.0]:
		draw_rect(Rect2(tree_x - 6.0, 394.0, 12.0, 246.0), FAR_TREE)
		draw_line(Vector2(tree_x, 430.0), Vector2(tree_x - 60.0, 360.0), FAR_TREE, 9.0)
		draw_line(Vector2(tree_x, 462.0), Vector2(tree_x + 72.0, 390.0), FAR_TREE, 8.0)


func _draw_distant_spires() -> void:
	for tower_data: Rect2 in [
		Rect2(2860.0, 302.0, 90.0, 338.0), Rect2(3190.0, 248.0, 122.0, 392.0),
		Rect2(3510.0, 208.0, 142.0, 432.0),
	]:
		draw_rect(tower_data, FAR_CASTLE)
		var roof: PackedVector2Array = PackedVector2Array([
			Vector2(tower_data.position.x - 14.0, tower_data.position.y),
			Vector2(tower_data.position.x + tower_data.size.x * 0.5, tower_data.position.y - 72.0),
			Vector2(tower_data.end.x + 14.0, tower_data.position.y),
		])
		draw_colored_polygon(roof, Color(0.035, 0.043, 0.07, 1.0))


func _draw_ruined_watch_post() -> void:
	draw_rect(Rect2(2470.0, 468.0, 300.0, 172.0), RUIN_DARK)
	var broken_tower: PackedVector2Array = PackedVector2Array([
		Vector2(2520.0, 468.0), Vector2(2520.0, 338.0), Vector2(2560.0, 338.0),
		Vector2(2580.0, 316.0), Vector2(2604.0, 346.0), Vector2(2640.0, 326.0),
		Vector2(2670.0, 358.0), Vector2(2670.0, 468.0),
	])
	draw_colored_polygon(broken_tower, RUIN_MID)
	draw_rect(Rect2(2568.0, 390.0, 28.0, 78.0), Color(0.02, 0.027, 0.04, 1.0))
	for course_y: float in [502.0, 536.0, 570.0, 604.0]:
		draw_line(Vector2(2480.0, course_y), Vector2(2760.0, course_y), STONE_EDGE, 2.0)


func _draw_outer_wall_remains() -> void:
	var wall: PackedVector2Array = PackedVector2Array([
		Vector2(3000.0, 640.0), Vector2(3000.0, 518.0), Vector2(3100.0, 518.0),
		Vector2(3122.0, 486.0), Vector2(3150.0, 518.0), Vector2(3270.0, 518.0),
		Vector2(3292.0, 500.0), Vector2(3320.0, 518.0), Vector2(3470.0, 518.0),
		Vector2(3470.0, 640.0),
	])
	draw_colored_polygon(wall, RUIN_MID)
	draw_rect(Rect2(3140.0, 554.0, 88.0, 86.0), Color(0.018, 0.024, 0.038, 1.0))
	var arch: PackedVector2Array = PackedVector2Array([
		Vector2(3140.0, 554.0), Vector2(3184.0, 516.0), Vector2(3228.0, 554.0),
	])
	draw_colored_polygon(arch, RUIN_MID)
	var inner_arch: PackedVector2Array = PackedVector2Array([
		Vector2(3150.0, 556.0), Vector2(3184.0, 530.0), Vector2(3218.0, 556.0),
	])
	draw_colored_polygon(inner_arch, Color(0.018, 0.024, 0.038, 1.0))
	for post_x: float in [3408.0, 3460.0]:
		draw_rect(Rect2(post_x, 452.0, 10.0, 188.0), IRON)
		for spike_y: float in range(466, 590, 28):
			draw_line(Vector2(post_x, spike_y), Vector2(post_x - 18.0, spike_y - 14.0), IRON, 4.0)
