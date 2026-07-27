class_name DuchessBossEntrance
extends Node2D

## Formal auto-opening threshold before the Ballroom; the combat rear door owns arena locking.

@export_node_path("Area2D") var approach_area_path: NodePath = NodePath("ApproachArea")
@export_node_path("StaticBody2D") var blocker_path: NodePath = NodePath("DoorBlocker")

@onready var approach_area: Area2D = get_node_or_null(approach_area_path) as Area2D
@onready var blocker: StaticBody2D = get_node_or_null(blocker_path) as StaticBody2D

var door_open_progress: float = 0.0:
	set(value):
		door_open_progress = clampf(value, 0.0, 1.0)
		queue_redraw()
var _opening: bool = false


func _ready() -> void:
	if approach_area == null or blocker == null:
		push_error("DuchessBossEntrance scene composition is incomplete")
		return
	approach_area.body_entered.connect(_on_body_entered)
	queue_redraw()


func open_immediately() -> void:
	door_open_progress = 1.0
	_set_blocker_enabled(false)


func _on_body_entered(body: Node2D) -> void:
	if _opening or door_open_progress >= 1.0 or not body is Player:
		return
	_opening = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "door_open_progress", 1.0, 0.90).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void: _set_blocker_enabled(false))


func _set_blocker_enabled(enabled: bool) -> void:
	blocker.collision_layer = 1 if enabled else 0
	for child: Node in blocker.get_children():
		var shape: CollisionShape2D = child as CollisionShape2D
		if shape != null:
			shape.set_deferred("disabled", not enabled)


func _draw() -> void:
	# Monumental oxidized arch, heraldic mask, mourning statues and black-red carpet.
	draw_rect(Rect2(-260, -360, 520, 360), Color("17131d"), true)
	draw_rect(Rect2(-230, -330, 460, 330), Color("2d2731"), false, 18.0)
	var arch := PackedVector2Array([
		Vector2(-218, -4), Vector2(-218, -238), Vector2(-150, -324),
		Vector2(0, -382), Vector2(150, -324), Vector2(218, -238), Vector2(218, -4),
	])
	draw_polyline(arch, Color("80683d"), 14.0, true)
	draw_polyline(arch, Color("3d3030"), 5.0, true)
	for side: int in [-1, 1]:
		var statue_x: float = float(side) * 300.0
		draw_rect(Rect2(statue_x - 42, -124, 84, 124), Color("26242d"), true)
		draw_circle(Vector2(statue_x, -166), 35.0, Color("393640"))
		draw_line(Vector2(statue_x, -112), Vector2(statue_x - side * 28, -62), Color("746e73"), 9.0)
		draw_line(Vector2(statue_x - side * 28, -62), Vector2(statue_x, -38), Color("746e73"), 9.0)
		for candle: int in range(3):
			var candle_x: float = statue_x + float(candle - 1) * 26.0
			draw_line(Vector2(candle_x, -10), Vector2(candle_x, -44), Color("76634f"), 5.0)
			draw_circle(Vector2(candle_x, -52), 7.0, Color("d08b4f"))
	# Door halves visibly retreat into the stone rather than vanishing.
	var separation: float = door_open_progress * 178.0
	for side: int in [-1, 1]:
		var center: float = float(side) * (108.0 + separation)
		draw_rect(Rect2(center - 106.0, -302, 212, 298), Color("211823"), true)
		draw_rect(Rect2(center - 96.0, -292, 192, 278), Color("4c2633"), false, 6.0)
		for rib: int in range(5):
			draw_line(Vector2(center - 78, -250 + rib * 48), Vector2(center + 78, -250 + rib * 48), Color("6b4c42"), 3.0)
	# Split porcelain crest makes this threshold unique among encounter gates.
	draw_circle(Vector2(0, -270), 46.0, Color("d3ceca"))
	draw_line(Vector2(-3, -310), Vector2(8, -232), Color("6f2639"), 4.0)
	draw_line(Vector2(8, -270), Vector2(38, -245), Color("6f2639"), 3.0)
	draw_colored_polygon(PackedVector2Array([Vector2(-390, 0), Vector2(390, 0), Vector2(250, 34), Vector2(-250, 34)]), Color("441321"))
