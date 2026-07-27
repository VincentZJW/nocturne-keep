class_name ChapterOneStorytellingArt
extends Node2D

## Collision-free narrative landmarks for Chapter I. All marks are deliberately
## visual-only so they cannot change traversal or combat behavior.

const INK: Color = Color("171923")
const STONE: Color = Color("353645")
const STEEL: Color = Color("758293")
const CLOTH: Color = Color("24283a")
const AMBER: Color = Color("b98243")
const SOUL: Color = Color(0.58, 0.78, 0.88, 0.62)


func _ready() -> void:
	z_index = -1
	queue_redraw()


func _draw() -> void:
	_draw_fallen_order(740.0)
	_draw_warning_post(1480.0)
	_draw_empty_armor(2650.0)
	_draw_spear_corpse(3520.0)
	_draw_broken_camp(4260.0)
	_draw_soul_fragments(4920.0)
	_draw_crows()


func _draw_fallen_order(x: float) -> void:
	draw_polygon(PackedVector2Array([Vector2(x - 28, 628), Vector2(x + 32, 628), Vector2(x + 12, 610), Vector2(x - 12, 606)]), PackedColorArray([CLOTH]))
	draw_circle(Vector2(x - 8, 606), 9.0, INK)
	draw_line(Vector2(x + 16, 616), Vector2(x + 38, 604), STEEL, 3.0)
	draw_line(Vector2(x + 19, 621), Vector2(x + 42, 629), STEEL, 3.0)


func _draw_warning_post(x: float) -> void:
	draw_rect(Rect2(x - 3, 566, 6, 74), STONE)
	draw_polygon(PackedVector2Array([Vector2(x - 28, 574), Vector2(x + 28, 568), Vector2(x + 24, 590), Vector2(x - 26, 596)]), PackedColorArray([Color("4b372b")]))
	draw_line(Vector2(x - 12, 579), Vector2(x + 10, 587), AMBER, 2.0)
	draw_line(Vector2(x - 4, 575), Vector2(x + 7, 592), AMBER, 2.0)


func _draw_empty_armor(x: float) -> void:
	draw_circle(Vector2(x, 588), 11.0, STONE)
	draw_rect(Rect2(x - 13, 599, 26, 28), STONE)
	draw_line(Vector2(x - 8, 605), Vector2(x - 20, 626), STEEL, 4.0)
	draw_line(Vector2(x + 8, 605), Vector2(x + 20, 626), STEEL, 4.0)
	draw_rect(Rect2(x - 6, 585, 12, 2), Color("8c2939"))


func _draw_spear_corpse(x: float) -> void:
	draw_polygon(PackedVector2Array([Vector2(x - 38, 628), Vector2(x + 28, 628), Vector2(x + 18, 612), Vector2(x - 20, 607)]), PackedColorArray([STONE]))
	draw_line(Vector2(x - 48, 632), Vector2(x + 55, 592), Color("5b4935"), 3.0)
	draw_polygon(PackedVector2Array([Vector2(x + 55, 592), Vector2(x + 44, 594), Vector2(x + 50, 602)]), PackedColorArray([STEEL]))


func _draw_broken_camp(x: float) -> void:
	draw_line(Vector2(x - 28, 632), Vector2(x - 5, 605), Color("4d3a2c"), 3.0)
	draw_line(Vector2(x + 28, 632), Vector2(x + 5, 605), Color("4d3a2c"), 3.0)
	draw_circle(Vector2(x, 628), 12.0, Color(0.42, 0.18, 0.09, 0.6))
	draw_circle(Vector2(x, 621), 5.0, Color(0.84, 0.52, 0.2, 0.7))


func _draw_soul_fragments(x: float) -> void:
	for offset: Vector2 in [Vector2(-26, -8), Vector2(-8, -24), Vector2(14, -12), Vector2(31, -31)]:
		draw_polygon(PackedVector2Array([Vector2(x, 612) + offset, Vector2(x + 5, 604) + offset, Vector2(x + 8, 614) + offset]), PackedColorArray([SOUL]))


func _draw_crows() -> void:
	for point: Vector2 in [Vector2(1120, 438), Vector2(3100, 412), Vector2(4720, 384)]:
		draw_polyline(PackedVector2Array([point + Vector2(-8, 0), point, point + Vector2(8, -2)]), INK, 2.0)
