class_name CatacombDoorOpeningBackdrop
extends Node2D

## Exterior night clipped to the stone-door aperture. It always renders behind actors.

const OPENING_RECT: Rect2 = Rect2(-72.0, -248.0, 144.0, 248.0)
const NIGHT_DEEP: Color = Color("07121e")
const NIGHT_MID: Color = Color("102638")
const NIGHT_HORIZON: Color = Color("1b3548")
const MOON: Color = Color(0.75, 0.85, 0.90, 0.88)
const FAR_FOREST: Color = Color("0c1b25")
const NEAR_FOREST: Color = Color("071219")


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	# All geometry stays inside OPENING_RECT; it can never cover the facade.
	draw_rect(OPENING_RECT, NIGHT_DEEP)
	draw_rect(Rect2(-72.0, -174.0, 144.0, 82.0), NIGHT_MID)
	draw_rect(Rect2(-72.0, -92.0, 144.0, 92.0), NIGHT_HORIZON)
	for star: Vector2 in [
		Vector2(-51.0, -222.0),
		Vector2(-21.0, -193.0),
		Vector2(4.0, -229.0),
		Vector2(55.0, -216.0),
		Vector2(48.0, -145.0),
	]:
		draw_rect(Rect2(star, Vector2(2.0, 2.0)), Color(0.65, 0.76, 0.82, 0.52))
	draw_circle(Vector2(31.0, -190.0), 25.0, MOON)
	draw_circle(Vector2(22.0, -197.0), 25.0, NIGHT_MID)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-72.0, -58.0), Vector2(-58.0, -112.0), Vector2(-45.0, -74.0),
			Vector2(-28.0, -132.0), Vector2(-9.0, -78.0), Vector2(8.0, -119.0),
			Vector2(26.0, -67.0), Vector2(45.0, -108.0), Vector2(72.0, -52.0),
			Vector2(72.0, 0.0), Vector2(-72.0, 0.0),
		]),
		FAR_FOREST
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-72.0, -22.0), Vector2(-58.0, -69.0), Vector2(-44.0, -30.0),
			Vector2(-27.0, -86.0), Vector2(-8.0, -31.0), Vector2(11.0, -74.0),
			Vector2(29.0, -25.0), Vector2(49.0, -72.0), Vector2(72.0, -18.0),
			Vector2(72.0, 0.0), Vector2(-72.0, 0.0),
		]),
		NEAR_FOREST
	)
	draw_line(Vector2(-72.0, -1.0), Vector2(72.0, -1.0), Color("263946"), 2.0)
