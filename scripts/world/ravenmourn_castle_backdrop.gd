class_name RavenmournCastleBackdrop
extends Node2D

## Monumental fortress backdrop for the configured Main bridge arena.
## Visual-only: the saved CastleFacade, CastleGate and bridge retain collision authority.

const SKY: Color = Color(0.028, 0.04, 0.083, 1.0)
const FAR_KEEP: Color = Color(0.065, 0.078, 0.125, 1.0)
const CASTLE_SHADOW: Color = Color(0.085, 0.095, 0.14, 1.0)
const CASTLE_MID: Color = Color(0.13, 0.14, 0.19, 1.0)
const CASTLE_EDGE: Color = Color(0.27, 0.31, 0.38, 0.76)
const WINDOW: Color = Color(0.16, 0.34, 0.48, 0.8)
const WINDOW_WARM: Color = Color(0.62, 0.34, 0.16, 0.78)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(5340.0, 96.0, 1400.0, 580.0), SKY)
	_draw_clouds()
	_draw_far_towers()
	_draw_main_fortress()
	_draw_spire_crown()
	_draw_gatehouse()
	_draw_stone_courses()


func _draw_clouds() -> void:
	for band: Rect2 in [
		Rect2(5390.0, 170.0, 410.0, 18.0),
		Rect2(5660.0, 145.0, 490.0, 22.0),
		Rect2(6120.0, 205.0, 460.0, 20.0),
	]:
		draw_rect(band, Color(0.09, 0.11, 0.17, 0.48))


func _draw_far_towers() -> void:
	_draw_spired_tower(Vector2(5385.0, 308.0), Vector2(126.0, 368.0), 74.0, FAR_KEEP, false)
	_draw_spired_tower(Vector2(5550.0, 264.0), Vector2(146.0, 412.0), 92.0, FAR_KEEP, false)
	_draw_spired_tower(Vector2(5702.0, 224.0), Vector2(164.0, 452.0), 108.0, FAR_KEEP, false)
	_draw_spired_tower(Vector2(6538.0, 232.0), Vector2(148.0, 444.0), 100.0, FAR_KEEP, false)
	_draw_spired_tower(Vector2(6670.0, 300.0), Vector2(112.0, 376.0), 68.0, FAR_KEEP, false)
	draw_rect(Rect2(5400.0, 488.0, 1320.0, 188.0), FAR_KEEP)
	for merlon_x: int in range(5410, 6720, 58):
		draw_rect(Rect2(float(merlon_x), 466.0, 28.0, 24.0), FAR_KEEP)


func _draw_main_fortress() -> void:
	# Left bastion anchors the castle inside the Boss camera even before Player reaches mid-bridge.
	_draw_spired_tower(Vector2(5710.0, 286.0), Vector2(176.0, 390.0), 82.0, CASTLE_SHADOW, true)
	draw_rect(Rect2(5840.0, 332.0, 820.0, 344.0), CASTLE_SHADOW)
	draw_rect(Rect2(5930.0, 282.0, 620.0, 394.0), CASTLE_MID)
	var keep_roof: PackedVector2Array = PackedVector2Array([
		Vector2(5890.0, 282.0), Vector2(6240.0, 146.0), Vector2(6590.0, 282.0),
	])
	draw_colored_polygon(keep_roof, Color(0.075, 0.08, 0.12, 1.0))
	for buttress_x: float in [5882.0, 5960.0, 6520.0, 6600.0]:
		var buttress: PackedVector2Array = PackedVector2Array([
			Vector2(buttress_x, 372.0), Vector2(buttress_x + 24.0, 350.0),
			Vector2(buttress_x + 42.0, 676.0), Vector2(buttress_x - 18.0, 676.0),
		])
		draw_colored_polygon(buttress, Color(0.11, 0.12, 0.17, 1.0))
	_draw_gothic_window(Vector2(6030.0, 360.0), false)
	_draw_gothic_window(Vector2(6160.0, 334.0), true)
	_draw_gothic_window(Vector2(6290.0, 334.0), true)
	_draw_gothic_window(Vector2(6510.0, 374.0), false)
	for merlon_x: float in range(5890, 6600, 58):
		draw_rect(Rect2(merlon_x, 304.0, 28.0, 24.0), CASTLE_SHADOW)


func _draw_spire_crown() -> void:
	# A stepped central tower cluster creates the required vertical Gothic hierarchy.
	_draw_spired_tower(Vector2(5990.0, 222.0), Vector2(112.0, 454.0), 96.0, CASTLE_SHADOW, true)
	_draw_spired_tower(Vector2(6110.0, 162.0), Vector2(146.0, 514.0), 126.0, CASTLE_MID, true)
	_draw_spired_tower(Vector2(6268.0, 204.0), Vector2(116.0, 472.0), 102.0, CASTLE_SHADOW, true)
	_draw_spired_tower(Vector2(6400.0, 246.0), Vector2(96.0, 430.0), 82.0, CASTLE_SHADOW, false)
	draw_rect(Rect2(6178.0, 18.0, 10.0, 62.0), CASTLE_SHADOW)
	var finial: PackedVector2Array = PackedVector2Array([
		Vector2(6166.0, 20.0), Vector2(6183.0, -8.0), Vector2(6200.0, 20.0),
	])
	draw_colored_polygon(finial, CASTLE_EDGE)


func _draw_gatehouse() -> void:
	# The moving foreground portcullis is centered at x=6400; this is its fixed stone frame.
	draw_rect(Rect2(6310.0, 346.0, 180.0, 330.0), Color(0.16, 0.16, 0.205, 1.0))
	var outer_arch: PackedVector2Array = PackedVector2Array([
		Vector2(6296.0, 388.0), Vector2(6400.0, 270.0), Vector2(6504.0, 388.0),
		Vector2(6486.0, 414.0), Vector2(6400.0, 316.0), Vector2(6314.0, 414.0),
	])
	draw_colored_polygon(outer_arch, CASTLE_MID)
	draw_rect(Rect2(6356.0, 386.0, 88.0, 290.0), Color(0.018, 0.022, 0.04, 1.0))
	var inner_arch: PackedVector2Array = PackedVector2Array([
		Vector2(6356.0, 388.0), Vector2(6400.0, 326.0), Vector2(6444.0, 388.0),
	])
	draw_colored_polygon(inner_arch, Color(0.018, 0.022, 0.04, 1.0))
	draw_rect(Rect2(6294.0, 560.0, 212.0, 26.0), Color(0.22, 0.22, 0.27, 1.0))
	draw_rect(Rect2(6278.0, 604.0, 244.0, 20.0), Color(0.19, 0.19, 0.235, 1.0))
	draw_rect(Rect2(6260.0, 640.0, 280.0, 36.0), Color(0.15, 0.15, 0.19, 1.0))
	var crest: PackedVector2Array = PackedVector2Array([
		Vector2(6378.0, 292.0), Vector2(6400.0, 272.0), Vector2(6422.0, 292.0),
		Vector2(6414.0, 322.0), Vector2(6400.0, 334.0), Vector2(6386.0, 322.0),
	])
	draw_colored_polygon(crest, Color(0.35, 0.29, 0.22, 0.9))


func _draw_stone_courses() -> void:
	for course_y: int in range(404, 650, 34):
		draw_line(
			Vector2(5850.0, float(course_y)),
			Vector2(6660.0, float(course_y)),
			Color(0.22, 0.23, 0.28, 0.42),
			2.0
		)
	for joint_x: int in range(5880, 6650, 62):
		draw_line(Vector2(float(joint_x), 520.0), Vector2(float(joint_x) - 8.0, 640.0), Color(0.2, 0.21, 0.26, 0.32), 2.0)


func _draw_spired_tower(
	position: Vector2,
	size: Vector2,
	roof_height: float,
	stone: Color,
	with_windows: bool
) -> void:
	draw_rect(Rect2(position, size), stone)
	var roof: PackedVector2Array = PackedVector2Array([
		Vector2(position.x - 22.0, position.y),
		Vector2(position.x + size.x * 0.5, position.y - roof_height),
		Vector2(position.x + size.x + 22.0, position.y),
	])
	draw_colored_polygon(roof, Color(stone.r * 0.62, stone.g * 0.64, stone.b * 0.76, 1.0))
	for merlon_offset: float in [8.0, size.x - 34.0]:
		draw_rect(Rect2(position.x + merlon_offset, position.y - 18.0, 26.0, 20.0), stone)
	if with_windows:
		_draw_gothic_window(position + Vector2(size.x * 0.5 - 12.0, 92.0), false)


func _draw_gothic_window(position: Vector2, warm: bool) -> void:
	var frame: PackedVector2Array = PackedVector2Array([
		Vector2(position.x, position.y + 22.0), Vector2(position.x + 12.0, position.y),
		Vector2(position.x + 24.0, position.y + 22.0), Vector2(position.x + 24.0, position.y + 68.0),
		Vector2(position.x, position.y + 68.0),
	])
	draw_colored_polygon(frame, Color(0.025, 0.028, 0.05, 1.0))
	var light: Color = WINDOW_WARM if warm else WINDOW
	draw_rect(Rect2(position.x + 6.0, position.y + 24.0, 12.0, 36.0), light)
	draw_line(Vector2(position.x + 12.0, position.y + 24.0), Vector2(position.x + 12.0, position.y + 60.0), Color(0.04, 0.05, 0.07, 1.0), 2.0)
