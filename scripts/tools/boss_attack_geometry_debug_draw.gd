class_name BossAttackGeometryDebugDraw
extends Node2D

## Expanded-only Main debug drawing for the live Boss attack volumes.

@export_node_path("FallenGateKnight") var boss_path: NodePath = NodePath("../..")

@onready var boss: FallenGateKnight = get_node_or_null(boss_path) as FallenGateKnight

var debug_visible: bool = false


func _ready() -> void:
	visible = false
	set_process(false)


func _process(_delta: float) -> void:
	queue_redraw()


func set_debug_visible(enabled: bool) -> void:
	debug_visible = enabled
	visible = enabled
	set_process(enabled)
	if enabled:
		queue_redraw()


func _draw() -> void:
	if not debug_visible or boss == null:
		return
	_draw_hitbox(boss.shield_bash_hitbox, Color(0.95, 0.72, 0.25, 0.95))
	_draw_hitbox(boss.slash_hitbox, Color(0.40, 0.78, 1.0, 0.95))
	_draw_hitbox(boss.thrust_hitbox, Color(0.78, 0.92, 1.0, 0.95))
	_draw_visual_tip(boss.config.shield_visual_forward_tip, Color(0.95, 0.72, 0.25, 0.85))
	_draw_visual_tip(boss.config.slash_visual_forward_tip, Color(0.40, 0.78, 1.0, 0.85))
	_draw_visual_tip(boss.config.thrust_visual_forward_tip, Color(0.78, 0.92, 1.0, 0.85))
	_draw_player_hurtbox()


func _draw_hitbox(hitbox: HitboxComponent, color: Color) -> void:
	if hitbox == null:
		return
	var collision: CollisionShape2D = hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var rectangle: RectangleShape2D = collision.shape as RectangleShape2D if collision != null else null
	if rectangle == null:
		return
	var rect: Rect2 = Rect2(hitbox.position - rectangle.size * 0.5, rectangle.size)
	var fill: Color = color
	fill.a = 0.24 if hitbox.is_active else 0.08
	draw_rect(rect, fill, true)
	draw_rect(rect, color, false, 1.0)


func _draw_visual_tip(forward_x: float, color: Color) -> void:
	draw_line(Vector2(forward_x, -20.0), Vector2(forward_x, 24.0), color, 1.0)


func _draw_player_hurtbox() -> void:
	if boss.target == null or not is_instance_valid(boss.target):
		return
	var collision: CollisionShape2D = boss.target.get_node_or_null(
		"Hurtbox/CollisionShape2D"
	) as CollisionShape2D
	var rectangle: RectangleShape2D = collision.shape as RectangleShape2D if collision != null else null
	if rectangle == null:
		return
	var center: Vector2 = to_local(collision.global_position)
	var rect: Rect2 = Rect2(center - rectangle.size * 0.5, rectangle.size)
	draw_rect(rect, Color(0.95, 0.30, 0.35, 0.16), true)
	draw_rect(rect, Color(1.0, 0.38, 0.42, 0.95), false, 1.0)
