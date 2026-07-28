class_name ReliquaryCandleFlames
extends Node2D

## Two restrained three-frame pixel flames. A Timer keeps this decorative effect
## off the per-frame process path and makes its cadence independently testable.

@export_node_path("Timer") var animation_timer_path: NodePath = NodePath("AnimationTimer")

@onready var animation_timer: Timer = get_node_or_null(animation_timer_path) as Timer

var _frame_index: int = 0
var _active: bool = false


func _ready() -> void:
	if animation_timer == null:
		push_error("ReliquaryCandleFlames requires an AnimationTimer")
		return
	animation_timer.timeout.connect(_advance_frame)
	animation_timer.stop()
	queue_redraw()


func set_active(active: bool) -> void:
	_active = active
	visible = active
	if animation_timer == null:
		return
	if active:
		animation_timer.start()
	else:
		animation_timer.stop()
		_frame_index = 0
	queue_redraw()


func get_frame_index() -> int:
	return _frame_index


func _advance_frame() -> void:
	if not _active:
		return
	_frame_index = (_frame_index + 1) % 3
	queue_redraw()


func _draw() -> void:
	if not _active:
		return
	for side: int in [-1, 1]:
		_draw_flame(Vector2(float(side) * 98.0, -73.0), side)


func _draw_flame(origin: Vector2, side: int) -> void:
	var sway: float = float((_frame_index + side + 3) % 3 - 1)
	var flame: PackedVector2Array = PackedVector2Array([
		origin + Vector2(-3.0, 3.0),
		origin + Vector2(-2.0 + sway, -4.0),
		origin + Vector2(sway, -10.0 - float(_frame_index % 2)),
		origin + Vector2(3.0 + sway, -3.0),
		origin + Vector2(3.0, 3.0),
	])
	draw_colored_polygon(flame, Color("d69652"))
	draw_rect(Rect2(origin.x - 1.0 + sway, origin.y - 4.0, 2.0, 5.0), Color("efe1b0"), true)
	draw_circle(origin + Vector2(sway, -3.0), 8.0, Color(0.83, 0.48, 0.25, 0.08))
