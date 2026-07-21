class_name PixelAssassinPose
extends RefCounted

## Typed pose data shared by every animation frame of the Night Warden.

var body: Vector2i
var hood_shift: Vector2i
var front_hand: Vector2i
var rear_hand: Vector2i
var front_knee: Vector2i
var front_foot: Vector2i
var rear_knee: Vector2i
var rear_foot: Vector2i
var main_tip: Vector2i
var offhand_tip: Vector2i
var mantle_tip: Vector2i


func _init(
		p_body: Vector2i,
		p_hood_shift: Vector2i,
		p_front_hand: Vector2i,
		p_rear_hand: Vector2i,
		p_front_knee: Vector2i,
		p_front_foot: Vector2i,
		p_rear_knee: Vector2i,
		p_rear_foot: Vector2i,
		p_main_tip: Vector2i,
		p_offhand_tip: Vector2i,
		p_mantle_tip: Vector2i
	) -> void:
	body = p_body
	hood_shift = p_hood_shift
	front_hand = p_front_hand
	rear_hand = p_rear_hand
	front_knee = p_front_knee
	front_foot = p_front_foot
	rear_knee = p_rear_knee
	rear_foot = p_rear_foot
	main_tip = p_main_tip
	offhand_tip = p_offhand_tip
	mantle_tip = p_mantle_tip
