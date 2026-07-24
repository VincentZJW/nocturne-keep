class_name RavenmournApproachArt
extends Node2D

## Draws the late-level Gothic approach as native, nearest-edge 2D presentation.
## It owns no collision, encounter, camera, or combat state.

const SKY_DEEP: Color = Color(0.025, 0.035, 0.075, 1.0)
const SKY_MID: Color = Color(0.045, 0.065, 0.12, 1.0)
const CLOUD_DARK: Color = Color(0.085, 0.095, 0.15, 0.55)
const FAR_STONE: Color = Color(0.075, 0.085, 0.13, 1.0)
const MID_STONE: Color = Color(0.11, 0.12, 0.17, 1.0)
const EDGE_STONE: Color = Color(0.22, 0.27, 0.34, 1.0)
const WINDOW_COLD: Color = Color(0.24, 0.4, 0.54, 0.72)
const WINDOW_WARM: Color = Color(0.64, 0.39, 0.19, 0.8)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_draw_sky_bands()
	_draw_clouds()
	_draw_far_stronghold()
	_draw_mid_walls()
	_draw_moonlight_edges()


func _draw_sky_bands() -> void:
	draw_rect(Rect2(3560.0, 96.0, 2040.0, 544.0), SKY_DEEP)
	draw_rect(Rect2(3560.0, 250.0, 2040.0, 390.0), SKY_MID)
	draw_rect(Rect2(3560.0, 460.0, 2040.0, 180.0), Color(0.035, 0.045, 0.085, 1.0))


func _draw_clouds() -> void:
	var cloud_bands: Array[Rect2] = [
		Rect2(3650.0, 178.0, 410.0, 20.0),
		Rect2(3820.0, 160.0, 380.0, 18.0),
		Rect2(4320.0, 214.0, 520.0, 22.0),
		Rect2(4700.0, 188.0, 390.0, 18.0),
		Rect2(5080.0, 235.0, 430.0, 20.0),
	]
	for band: Rect2 in cloud_bands:
		draw_rect(band, CLOUD_DARK)


func _draw_far_stronghold() -> void:
	_draw_tower(Vector2(3710.0, 286.0), Vector2(150.0, 354.0), 58.0, FAR_STONE, false)
	_draw_tower(Vector2(4020.0, 342.0), Vector2(120.0, 298.0), 48.0, FAR_STONE, true)
	_draw_tower(Vector2(4510.0, 250.0), Vector2(188.0, 390.0), 76.0, FAR_STONE, false)
	_draw_tower(Vector2(4930.0, 328.0), Vector2(132.0, 312.0), 54.0, FAR_STONE, true)
	_draw_tower(Vector2(5270.0, 224.0), Vector2(176.0, 416.0), 72.0, FAR_STONE, false)
	draw_rect(Rect2(3600.0, 470.0, 1980.0, 170.0), FAR_STONE)
	for merlon_x: float in range(3620, 5580, 72):
		draw_rect(Rect2(merlon_x, 444.0, 34.0, 28.0), FAR_STONE)


func _draw_mid_walls() -> void:
	var broken_wall: PackedVector2Array = PackedVector2Array([
		Vector2(3890.0, 640.0), Vector2(3890.0, 506.0), Vector2(3970.0, 506.0),
		Vector2(3990.0, 476.0), Vector2(4020.0, 506.0), Vector2(4130.0, 506.0),
		Vector2(4150.0, 490.0), Vector2(4180.0, 506.0), Vector2(4300.0, 506.0),
		Vector2(4300.0, 640.0),
	])
	draw_colored_polygon(broken_wall, MID_STONE)
	var outer_wall: PackedVector2Array = PackedVector2Array([
		Vector2(4620.0, 640.0), Vector2(4620.0, 455.0), Vector2(4690.0, 455.0),
		Vector2(4710.0, 425.0), Vector2(4730.0, 455.0), Vector2(4820.0, 455.0),
		Vector2(4840.0, 434.0), Vector2(4860.0, 455.0), Vector2(5000.0, 455.0),
		Vector2(5000.0, 640.0),
	])
	draw_colored_polygon(outer_wall, MID_STONE)
	_draw_arch_opening(Rect2(3980.0, 526.0, 96.0, 114.0))
	_draw_arch_opening(Rect2(4750.0, 500.0, 110.0, 140.0))
	for brick_y: float in range(520, 632, 28):
		var offset: float = 18.0 if int(brick_y / 28.0) % 2 == 0 else 0.0
		for brick_x: float in range(3910, 4280, 54):
			draw_line(
				Vector2(brick_x + offset, brick_y),
				Vector2(minf(brick_x + offset + 40.0, 4290.0), brick_y),
				Color(0.17, 0.18, 0.23, 0.62),
				2.0
			)


func _draw_moonlight_edges() -> void:
	draw_line(Vector2(3890.0, 506.0), Vector2(4300.0, 506.0), EDGE_STONE, 3.0)
	draw_line(Vector2(4620.0, 455.0), Vector2(5000.0, 455.0), EDGE_STONE, 3.0)
	draw_line(Vector2(5270.0, 224.0), Vector2(5270.0, 640.0), Color(0.26, 0.33, 0.42, 0.46), 3.0)


func _draw_tower(
	position: Vector2,
	size: Vector2,
	roof_height: float,
	stone_color: Color,
	warm_windows: bool
) -> void:
	draw_rect(Rect2(position, size), stone_color)
	var roof: PackedVector2Array = PackedVector2Array([
		Vector2(position.x - 18.0, position.y),
		Vector2(position.x + size.x * 0.5, position.y - roof_height),
		Vector2(position.x + size.x + 18.0, position.y),
	])
	draw_colored_polygon(roof, Color(stone_color.r * 0.72, stone_color.g * 0.72, stone_color.b * 0.82, 1.0))
	draw_rect(Rect2(position.x + size.x * 0.5 - 3.0, position.y - roof_height - 34.0, 6.0, 34.0), stone_color)
	var window_color: Color = WINDOW_WARM if warm_windows else WINDOW_COLD
	for window_y: float in [position.y + 62.0, position.y + 132.0]:
		var window_rect: Rect2 = Rect2(position.x + size.x * 0.5 - 8.0, window_y, 16.0, 28.0)
		draw_rect(window_rect, Color(0.02, 0.025, 0.045, 1.0))
		draw_rect(Rect2(window_rect.position + Vector2(5.0, 7.0), Vector2(6.0, 14.0)), window_color)


func _draw_arch_opening(rect: Rect2) -> void:
	draw_rect(rect, Color(0.018, 0.02, 0.038, 1.0))
	var peak: PackedVector2Array = PackedVector2Array([
		Vector2(rect.position.x, rect.position.y),
		Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y - 38.0),
		Vector2(rect.end.x, rect.position.y),
	])
	draw_colored_polygon(peak, MID_STONE)
	var inner_peak: PackedVector2Array = PackedVector2Array([
		Vector2(rect.position.x + 10.0, rect.position.y + 2.0),
		Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y - 22.0),
		Vector2(rect.end.x - 10.0, rect.position.y + 2.0),
	])
	draw_colored_polygon(inner_peak, Color(0.018, 0.02, 0.038, 1.0))
