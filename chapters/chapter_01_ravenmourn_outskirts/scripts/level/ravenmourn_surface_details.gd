class_name RavenmournSurfaceDetails
extends Node2D

## Adds decorative stone joints, rubble, weeds and hanging chains without collision.

const JOINT: Color = Color(0.28, 0.31, 0.38, 0.72)
const RUBBLE: Color = Color(0.24, 0.24, 0.3, 1.0)
const WEED: Color = Color(0.18, 0.27, 0.22, 0.86)
const CHAIN: Color = Color(0.22, 0.23, 0.27, 1.0)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_draw_ground_masonry()
	_draw_platform_masonry(Rect2(4310.0, 504.0, 220.0, 24.0))
	_draw_platform_masonry(Rect2(5050.0, 508.0, 220.0, 24.0))
	_draw_platform_masonry(Rect2(3440.0, 492.0, 240.0, 24.0))
	_draw_rubble()
	_draw_weeds()
	_draw_chain(Vector2(4328.0, 526.0), 72.0)
	_draw_chain(Vector2(5200.0, 530.0), 58.0)


func _draw_ground_masonry() -> void:
	for joint_x: float in range(3820, 5520, 64):
		draw_line(Vector2(joint_x, 647.0), Vector2(joint_x - 10.0, 676.0), JOINT, 2.0)
	for course_y: float in [654.0, 680.0, 708.0]:
		draw_line(Vector2(3760.0, course_y), Vector2(5520.0, course_y), Color(JOINT, 0.46), 2.0)


func _draw_platform_masonry(rect: Rect2) -> void:
	draw_line(rect.position, Vector2(rect.end.x, rect.position.y), Color(0.42, 0.48, 0.56, 0.9), 3.0)
	for joint_x: float in range(int(rect.position.x + 30.0), int(rect.end.x), 44):
		draw_line(Vector2(joint_x, rect.position.y + 4.0), Vector2(joint_x - 6.0, rect.end.y - 2.0), JOINT, 2.0)


func _draw_rubble() -> void:
	var stones: Array[Rect2] = [
		Rect2(3860.0, 628.0, 18.0, 12.0), Rect2(3882.0, 632.0, 12.0, 8.0),
		Rect2(4590.0, 626.0, 22.0, 14.0), Rect2(4616.0, 632.0, 14.0, 8.0),
		Rect2(5320.0, 630.0, 16.0, 10.0), Rect2(5340.0, 626.0, 22.0, 14.0),
	]
	for stone: Rect2 in stones:
		draw_rect(stone, RUBBLE)
		draw_line(stone.position, Vector2(stone.end.x, stone.position.y), Color(0.4, 0.42, 0.48, 0.8), 2.0)


func _draw_weeds() -> void:
	for root_x: float in [3940.0, 4680.0, 4760.0, 5278.0, 5386.0]:
		draw_line(Vector2(root_x, 640.0), Vector2(root_x - 6.0, 628.0), WEED, 2.0)
		draw_line(Vector2(root_x, 640.0), Vector2(root_x + 2.0, 624.0), WEED, 2.0)
		draw_line(Vector2(root_x + 2.0, 640.0), Vector2(root_x + 10.0, 630.0), WEED, 2.0)


func _draw_chain(origin: Vector2, length: float) -> void:
	var link_count: int = int(length / 8.0)
	for link_index: int in range(link_count):
		var link_position: Vector2 = origin + Vector2(3.0 if link_index % 2 == 0 else -3.0, link_index * 8.0)
		draw_rect(Rect2(link_position, Vector2(6.0, 5.0)), CHAIN, false, 2.0)
