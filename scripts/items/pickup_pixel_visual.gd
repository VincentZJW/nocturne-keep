class_name PickupPixelVisual
extends Node2D

@export_enum("coin", "small_health", "large_health", "weapon", "coin_bag") var kind: String = "coin"


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	match kind:
		"coin":
			_draw_coin()
		"small_health":
			_draw_vial(false)
		"large_health":
			_draw_vial(true)
		"weapon":
			_draw_weapon()
		"coin_bag":
			_draw_coin_bag()


func _draw_coin() -> void:
	draw_rect(Rect2(-5, -6, 10, 12), Color("5b341a"))
	draw_rect(Rect2(-4, -7, 8, 14), Color("b98243"))
	draw_rect(Rect2(-2, -5, 4, 10), Color("e6bf68"))
	draw_rect(Rect2(-1, -3, 2, 6), Color("fff0a6"))


func _draw_vial(large: bool) -> void:
	var width: float = 12.0 if large else 8.0
	var height: float = 16.0 if large else 12.0
	draw_rect(Rect2(-3, -height * 0.5 - 4, 6, 4), Color("8fa4ad"))
	draw_rect(Rect2(-width * 0.5, -height * 0.5, width, height), Color("2b1724"))
	draw_rect(Rect2(-width * 0.5 + 2, -height * 0.5 + 3, width - 4, height - 5), Color("7b1e2b"))
	draw_rect(Rect2(-width * 0.5, height * 0.5 - 2, width, 2), Color("b98243"))
	if large:
		draw_rect(Rect2(-width * 0.5 - 1, -3, width + 2, 2), Color("d5dee3"))


func _draw_weapon() -> void:
	for y_offset: float in [-4.0, 4.0]:
		draw_rect(Rect2(-15, y_offset - 1, 22, 3), Color("d5dee3"))
		draw_rect(Rect2(7, y_offset - 2, 7, 5), Color("607a90"))
		draw_rect(Rect2(13, y_offset - 1, 5, 3), Color("b98243"))


func _draw_coin_bag() -> void:
	draw_rect(Rect2(-8, -7, 16, 15), Color("57371f"))
	draw_rect(Rect2(-6, -10, 12, 4), Color("b98243"))
	draw_rect(Rect2(-3, -3, 6, 7), Color("e6bf68"))
