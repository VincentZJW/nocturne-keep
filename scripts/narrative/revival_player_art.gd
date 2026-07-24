class_name RevivalPlayerArt
extends Node2D

## Pixel-block story-only poses; separate from the fast combat respawn animation.

enum Pose {
	CORPSE,
	TWITCH,
	BREATH,
	SIT_UP,
	LOOK_HANDS,
	KNEEL,
	STAND,
	UNARMED,
}

const HOOD: Color = Color("08101a")
const NAVY: Color = Color("172b3d")
const SLATE: Color = Color("607a90")
const STEEL: Color = Color("d5dee3")
const AMBER: Color = Color("b98243")

var pose: Pose = Pose.CORPSE
var soul_visible: bool = false
var soul_offset: Vector2 = Vector2(0, -112)
var soul_alpha: float = 0.0
var soul_mark_strength: float = 0.0


func set_pose(next_pose: Pose) -> void:
	pose = next_pose
	if pose == Pose.UNARMED:
		position.y = 28.0
	elif pose in [Pose.KNEEL, Pose.STAND]:
		position.y = 14.0
	else:
		position.y = 0.0
	queue_redraw()


func _process(_delta: float) -> void:
	if pose == Pose.UNARMED:
		var player: Player = get_parent() as Player
		position.y = 27.0 if player != null and absf(player.velocity.x) > 5.0 and Time.get_ticks_msec() % 240 < 120 else 28.0
	queue_redraw()


func _draw() -> void:
	match pose:
		Pose.CORPSE, Pose.TWITCH, Pose.BREATH:
			_draw_lying()
		Pose.SIT_UP:
			_draw_sitting(false)
		Pose.LOOK_HANDS:
			_draw_sitting(true)
		Pose.KNEEL:
			_draw_kneeling()
		Pose.STAND, Pose.UNARMED:
			_draw_standing()
	if soul_mark_strength > 0.0:
		draw_circle(Vector2(0, -10), 5, STEEL * Color(1, 1, 1, soul_mark_strength))
		draw_arc(Vector2(0, -10), 9, 0.2, 5.5, 12, Color(0.52, 0.78, 0.92, soul_mark_strength), 2.0)
	if soul_visible:
		_draw_soul()


func _draw_lying() -> void:
	var lift: float = -1.0 if pose == Pose.BREATH else 0.0
	draw_rect(Rect2(-34, -14 + lift, 42, 18), NAVY)
	draw_rect(Rect2(-42, -13 + lift, 16, 17), HOOD)
	draw_rect(Rect2(-38, -8 + lift, 8, 2), STEEL)
	draw_rect(Rect2(6, -10 + lift, 30, 8), SLATE)
	draw_rect(Rect2(10, 0 + lift, 27, 7), HOOD)
	draw_rect(Rect2(-9, -1 + lift, 7, 5), AMBER)
	if pose == Pose.TWITCH:
		draw_rect(Rect2(26, -17, 10, 5), SLATE)


func _draw_sitting(looking_at_hands: bool) -> void:
	draw_rect(Rect2(-14, -46, 29, 33), NAVY)
	draw_colored_polygon(PackedVector2Array([Vector2(-18, -52), Vector2(-10, -66), Vector2(11, -62), Vector2(18, -49), Vector2(9, -39), Vector2(-11, -40)]), HOOD)
	draw_rect(Rect2(-5, -54, 9, 2), STEEL)
	draw_rect(Rect2(-16, -16, 13, 19), SLATE)
	draw_rect(Rect2(4, -14, 28, 9), HOOD)
	if looking_at_hands:
		draw_line(Vector2(-10, -35), Vector2(-28, -24), SLATE, 6.0)
		draw_line(Vector2(10, -35), Vector2(29, -24), SLATE, 6.0)
		draw_rect(Rect2(-32, -27, 7, 7), STEEL)
		draw_rect(Rect2(26, -27, 7, 7), STEEL)
	else:
		draw_line(Vector2(-11, -35), Vector2(-22, -12), SLATE, 6.0)


func _draw_kneeling() -> void:
	draw_rect(Rect2(-12, -53, 25, 31), NAVY)
	_draw_hood(Vector2(0, -61))
	draw_rect(Rect2(-15, -24, 13, 26), SLATE)
	draw_rect(Rect2(4, -19, 31, 8), HOOD)
	draw_line(Vector2(-12, -37), Vector2(-25, -12), SLATE, 6.0)


func _draw_standing() -> void:
	draw_rect(Rect2(-13, -49, 27, 29), NAVY)
	draw_rect(Rect2(-17, -45, 34, 8), HOOD)
	_draw_hood(Vector2(0, -58))
	draw_rect(Rect2(-12, -22, 9, 22), SLATE)
	draw_rect(Rect2(4, -22, 9, 22), SLATE)
	draw_line(Vector2(-12, -39), Vector2(-19, -17), SLATE, 6.0)
	draw_line(Vector2(12, -39), Vector2(19, -17), SLATE, 6.0)
	draw_rect(Rect2(-5, -36, 10, 5), AMBER)


func _draw_hood(center: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([center + Vector2(-14, 7), center + Vector2(-8, -10), center + Vector2(1, -18), center + Vector2(12, -8), center + Vector2(15, 8), center + Vector2(8, 14), center + Vector2(-9, 13)]), HOOD)
	draw_rect(Rect2(center.x - 5, center.y + 3, 10, 2), STEEL)


func _draw_soul() -> void:
	var soul_color: Color = Color(0.72, 0.88, 0.97, soul_alpha)
	draw_circle(soul_offset, 14, soul_color * Color(1, 1, 1, 0.18))
	draw_colored_polygon(PackedVector2Array([soul_offset + Vector2(-10, 12), soul_offset + Vector2(-7, -7), soul_offset + Vector2(0, -16), soul_offset + Vector2(9, -7), soul_offset + Vector2(11, 13), soul_offset + Vector2(5, 24), soul_offset + Vector2(0, 17), soul_offset + Vector2(-5, 24)]), soul_color * Color(1, 1, 1, 0.72))
	draw_rect(Rect2(soul_offset.x - 5, soul_offset.y - 4, 10, 2), Color(0.9, 0.97, 1.0, soul_alpha))
