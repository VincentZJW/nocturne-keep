class_name CandleWarden
extends Node2D

## Story-only Candle Warden presentation. It owns no combat or following AI.

enum PresentationState {
	SEATED,
	RISING,
	IDLE,
	WALK,
	RAISE_LANTERN,
	TALK,
	TURN_AWAY,
}

const ROBE: Color = Color("34424f")
const ROBE_DARK: Color = Color("0d141d")
const METAL: Color = Color("667581")
const SOUL_FIRE: Color = Color("85c6de")

var presentation_state: PresentationState = PresentationState.SEATED
var facing_left: bool = true
var elapsed: float = 0.0


func set_presentation_state(next_state: PresentationState) -> void:
	presentation_state = next_state
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()


func _draw() -> void:
	var mirror: float = -1.0 if facing_left else 1.0
	var seated_offset: float = 18.0 if presentation_state == PresentationState.SEATED else 0.0
	var bob: float = sin(elapsed * 2.2) if presentation_state in [PresentationState.IDLE, PresentationState.TALK] else 0.0
	# Tall patched robe and hidden face.
	draw_colored_polygon(PackedVector2Array([Vector2(-18, -46 + seated_offset + bob), Vector2(15, -46 + seated_offset + bob), Vector2(28, 0), Vector2(-30, 0)]), ROBE)
	draw_rect(Rect2(-22, -50 + seated_offset + bob, 42, 8), ROBE_DARK)
	draw_colored_polygon(PackedVector2Array([Vector2(-16, -50 + seated_offset + bob), Vector2(-9, -72 + seated_offset + bob), Vector2(8, -79 + seated_offset + bob), Vector2(18, -54 + seated_offset + bob), Vector2(9, -43 + seated_offset + bob), Vector2(-8, -43 + seated_offset + bob)]), ROBE_DARK)
	draw_rect(Rect2(-7, -61 + seated_offset + bob, 14, 9), Color("53616c"))
	draw_line(Vector2(-6, -58 + seated_offset + bob), Vector2(6, -58 + seated_offset + bob), METAL, 2.0)
	for y: float in [-35.0, -22.0, -9.0]:
		draw_line(Vector2(-14, y + seated_offset), Vector2(16, y + 2 + seated_offset), Color("141c25"), 2.0)
	# Key at belt.
	draw_circle(Vector2(-14 * mirror, -27 + seated_offset), 4, METAL, false, 2.0)
	draw_line(Vector2(-14 * mirror, -23 + seated_offset), Vector2(-14 * mirror, -12 + seated_offset), METAL, 2.0)
	_draw_lantern(mirror, seated_offset, bob)


func _draw_lantern(mirror: float, seated_offset: float, bob: float) -> void:
	var raised: bool = presentation_state == PresentationState.RAISE_LANTERN
	var hand: Vector2 = Vector2(22 * mirror, -43 if raised else -30) + Vector2(0, seated_offset + bob)
	draw_line(Vector2(10 * mirror, -42 + seated_offset + bob), hand, ROBE, 7.0)
	var lantern: Vector2 = hand + Vector2(8 * mirror, -10 if raised else 13)
	draw_line(hand, lantern + Vector2(0, -8), METAL, 2.0)
	draw_rect(Rect2(lantern.x - 8, lantern.y - 8, 16, 20), Color("28333d"), false, 2.0)
	draw_circle(lantern + Vector2(0, 2), 6, SOUL_FIRE * Color(1, 1, 1, 0.75))
	draw_circle(lantern + Vector2(0, 2), 13 + sin(elapsed * 3.0) * 2.0, SOUL_FIRE * Color(1, 1, 1, 0.10))
