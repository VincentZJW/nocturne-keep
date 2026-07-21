class_name PixelAssassinRenderer
extends RefCounted

## Draws one hard-edged 64×64 Night Warden frame from typed pose data.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const Concept: Script = preload("res://scripts/tools/pixel_character_generator.gd")
const Pose: Script = preload("res://scripts/tools/pixel_assassin_pose.gd")


static func draw(pose: PixelAssassinPose) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var rear_shoulder: Vector2i = pose.body + Vector2i(2, 6)
	var front_shoulder: Vector2i = pose.body + Vector2i(13, 5)
	var rear_hip: Vector2i = pose.body + Vector2i(4, 18)
	var front_hip: Vector2i = pose.body + Vector2i(11, 18)
	_draw_dagger(image, pose.rear_hand, pose.offhand_tip, false)
	_draw_arm(image, rear_shoulder, pose.rear_hand, false)
	_draw_mantle(image, pose)
	_draw_leg(image, rear_hip, pose.rear_knee, pose.rear_foot, false)
	_draw_leg(image, front_hip, pose.front_knee, pose.front_foot, true)
	_draw_body(image, pose.body)
	_draw_hood(image, pose.body + pose.hood_shift)
	_draw_arm(image, front_shoulder, pose.front_hand, true)
	_draw_dagger(image, pose.front_hand, pose.main_tip, true)
	return image


static func _draw_hood(image: Image, body: Vector2i) -> void:
	var blocks: Array[Rect2i] = [
		Rect2i(body.x + 5, body.y - 18, 4, 2),
		Rect2i(body.x + 2, body.y - 16, 10, 2),
		Rect2i(body.x - 1, body.y - 14, 16, 3),
		Rect2i(body.x - 3, body.y - 11, 20, 6),
		Rect2i(body.x - 1, body.y - 5, 17, 4),
	]
	PixelCanvas.fill_rects(image, blocks, Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 9, body.y - 10, 7, 5), Concept.MIDNIGHT_NAVY)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 13, body.y - 8, 3, 1), Concept.PALE_STEEL)
	PixelCanvas.fill_rect(image, Rect2i(body.x, body.y - 12, 3, 7), Concept.MIDNIGHT_NAVY)


static func _draw_body(image: Image, body: Vector2i) -> void:
	PixelCanvas.fill_rect(image, Rect2i(body.x, body.y, 16, 18), Concept.MIDNIGHT_NAVY)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 2, body.y + 2, 12, 4), Concept.MOONLIT_SLATE)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 10, body.y + 6, 5, 9), Concept.MOONLIT_SLATE)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 1, body.y + 15, 14, 4), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 8, body.y + 6, 2, 3), Concept.MUTED_AMBER)


static func _draw_mantle(image: Image, pose: PixelAssassinPose) -> void:
	var shoulder: Vector2i = pose.body + Vector2i(3, 1)
	PixelCanvas.draw_line(image, shoulder, pose.mantle_tip, Concept.HOOD_BLACK, 6)
	PixelCanvas.draw_line(image, shoulder + Vector2i(1, 2), pose.mantle_tip + Vector2i(2, 1), Concept.MIDNIGHT_NAVY, 2)


static func _draw_arm(image: Image, shoulder: Vector2i, hand: Vector2i, is_front: bool) -> void:
	PixelCanvas.draw_line(image, shoulder, hand, Concept.MIDNIGHT_NAVY, 5)
	var inset_start: Vector2i = shoulder + Vector2i(1, 1)
	PixelCanvas.draw_line(image, inset_start, hand, Concept.MOONLIT_SLATE, 2 if is_front else 1)
	PixelCanvas.fill_rect(image, Rect2i(hand.x - 1, hand.y - 1, 3, 3), Concept.HOOD_BLACK)


static func _draw_leg(
		image: Image,
		hip: Vector2i,
		knee: Vector2i,
		foot: Vector2i,
		is_front: bool
	) -> void:
	PixelCanvas.draw_line(image, hip, knee, Concept.MIDNIGHT_NAVY, 6)
	PixelCanvas.draw_line(image, knee, foot, Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.draw_line(image, hip + Vector2i(1, 1), knee, Concept.MOONLIT_SLATE, 2 if is_front else 1)
	var boot_start_x: int = foot.x - 3 if foot.x <= knee.x else foot.x - 1
	PixelCanvas.fill_rect(image, Rect2i(boot_start_x, foot.y - 1, 7, 3), Concept.HOOD_BLACK)


static func _draw_dagger(image: Image, hand: Vector2i, tip: Vector2i, is_main: bool) -> void:
	var direction: Vector2 = Vector2(tip - hand).normalized()
	var blade_start: Vector2i = hand + Vector2i(roundi(direction.x * 3.0), roundi(direction.y * 3.0))
	PixelCanvas.draw_line(image, blade_start, tip, Concept.PALE_STEEL, 2)
	PixelCanvas.draw_line(image, blade_start, tip, Concept.MOONLIT_SLATE, 1)
	var guard_size: Vector2i = Vector2i(2, 5) if absf(direction.x) > absf(direction.y) else Vector2i(5, 2)
	PixelCanvas.fill_rect(image, Rect2i(hand - guard_size / 2, guard_size), Concept.MOONLIT_SLATE)
	if is_main:
		PixelCanvas.fill_rect(image, Rect2i(hand.x - 1, hand.y - 1, 2, 2), Concept.MUTED_AMBER)
