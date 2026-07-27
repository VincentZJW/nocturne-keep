class_name PixelAssassinRenderer
extends RefCounted

## Draws one hard-edged 64×64 Night Warden frame from typed pose data.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const Concept: Script = preload("res://scripts/tools/pixel_character_generator.gd")
const Pose: Script = preload("res://scripts/tools/pixel_assassin_pose.gd")


static func draw(pose: PixelAssassinPose, weapon_style: StringName = &"veilbound") -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var rear_shoulder: Vector2i = pose.body + Vector2i(2, 6)
	var front_shoulder: Vector2i = pose.body + Vector2i(13, 5)
	var rear_hip: Vector2i = pose.body + Vector2i(4, 18)
	var front_hip: Vector2i = pose.body + Vector2i(11, 18)
	_draw_dagger(image, pose.rear_hand, pose.offhand_tip, false, weapon_style)
	_draw_arm(image, rear_shoulder, pose.rear_hand, false)
	_draw_mantle(image, pose)
	_draw_leg(image, rear_hip, pose.rear_knee, pose.rear_foot, false)
	_draw_leg(image, front_hip, pose.front_knee, pose.front_foot, true)
	_draw_body(image, pose.body)
	_draw_hood(image, pose.body + pose.hood_shift)
	_draw_arm(image, front_shoulder, pose.front_hand, true)
	_draw_dagger(image, pose.front_hand, pose.main_tip, true, weapon_style)
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


static func _draw_dagger(
		image: Image, hand: Vector2i, tip: Vector2i, is_main: bool,
		weapon_style: StringName = &"veilbound"
	) -> void:
	if weapon_style == &"ravenfang":
		draw_ravenfang_dagger(image, hand, tip, is_main)
		return
	if weapon_style == &"crimson_masque":
		draw_crimson_masque_stiletto(image, hand, tip, is_main)
		return
	var direction: Vector2 = Vector2(tip - hand).normalized()
	var blade_start: Vector2i = hand + Vector2i(roundi(direction.x * 3.0), roundi(direction.y * 3.0))
	PixelCanvas.draw_line(image, blade_start, tip, Concept.PALE_STEEL, 2)
	PixelCanvas.draw_line(image, blade_start, tip, Concept.MOONLIT_SLATE, 1)
	var guard_size: Vector2i = Vector2i(2, 5) if absf(direction.x) > absf(direction.y) else Vector2i(5, 2)
	PixelCanvas.fill_rect(image, Rect2i(hand - guard_size / 2, guard_size), Concept.MOONLIT_SLATE)
	if is_main:
		PixelCanvas.fill_rect(image, Rect2i(hand.x - 1, hand.y - 1, 2, 2), Concept.MUTED_AMBER)


static func draw_ravenfang_dagger(
		image: Image, hand: Vector2i, tip: Vector2i, is_main: bool
	) -> void:
	var delta: Vector2 = Vector2(tip - hand)
	var length: float = maxf(1.0, delta.length())
	var direction: Vector2 = delta / length
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var curve_sign: float = -1.0 if is_main else 1.0
	var blade_start: Vector2 = Vector2(hand) + direction * 3.0
	var shoulder: Vector2 = blade_start + direction * length * 0.36 + normal * 3.0 * curve_sign
	var claw: Vector2 = blade_start + direction * length * 0.74 + normal * 5.0 * curve_sign
	var inward_tip: Vector2 = Vector2(tip) - direction * 2.0 + normal * 2.0 * curve_sign
	var p0: Vector2i = Vector2i(roundi(blade_start.x), roundi(blade_start.y))
	var p1: Vector2i = Vector2i(roundi(shoulder.x), roundi(shoulder.y))
	var p2: Vector2i = Vector2i(roundi(claw.x), roundi(claw.y))
	var p3: Vector2i = Vector2i(roundi(inward_tip.x), roundi(inward_tip.y))
	var dark_steel: Color = Color("405467")
	var cold_edge: Color = Color("9bb1c0")
	var pale_tip: Color = Color("d1dce3")
	var grip_black: Color = Color("060b12")
	var wing_blue: Color = Color("51697a")
	PixelCanvas.draw_line(image, p0, p1, dark_steel, 3)
	PixelCanvas.draw_line(image, p1, p2, dark_steel, 3)
	PixelCanvas.draw_line(image, p2, p3, cold_edge, 2)
	PixelCanvas.draw_line(image, p0, p2, cold_edge, 1)
	PixelCanvas.fill_rect(image, Rect2i(p3.x, p3.y, 1, 1), pale_tip)
	# A compact folded-wing guard and beak/ring pommel read at 48–64 px.
	var guard_center: Vector2 = Vector2(hand) + direction
	var guard_a: Vector2i = Vector2i(roundi(guard_center.x + normal.x * 3.0), roundi(guard_center.y + normal.y * 3.0))
	var guard_b: Vector2i = Vector2i(roundi(guard_center.x - normal.x * 2.0), roundi(guard_center.y - normal.y * 2.0))
	PixelCanvas.draw_line(image, guard_a, guard_b, wing_blue, 2)
	var pommel: Vector2 = Vector2(hand) - direction * 3.0
	var pommel_i: Vector2i = Vector2i(roundi(pommel.x), roundi(pommel.y))
	PixelCanvas.draw_line(image, hand, pommel_i, grip_black, 3)
	PixelCanvas.fill_rect(image, Rect2i(pommel_i.x - 1, pommel_i.y - 1, 3, 3), wing_blue)
	PixelCanvas.fill_rect(image, Rect2i(pommel_i.x, pommel_i.y, 1, 1), grip_black)


static func draw_crimson_masque_stiletto(
		image: Image, hand: Vector2i, tip: Vector2i, is_main: bool
	) -> void:
	var delta: Vector2 = Vector2(tip - hand)
	var length: float = maxf(1.0, delta.length())
	var direction: Vector2 = delta / length
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var blade_start: Vector2 = Vector2(hand) + direction * 3.0
	var blade_tip: Vector2 = Vector2(tip)
	var dark_silver: Color = Color("58616c")
	var porcelain: Color = Color("ded8cf")
	var pale_edge: Color = Color("ecf0ed")
	var crimson: Color = Color("7d2130")
	var grip_black: Color = Color("07090e")
	var guard_center: Vector2 = Vector2(hand) + direction
	var p0: Vector2i = Vector2i(roundi(blade_start.x), roundi(blade_start.y))
	var p1: Vector2i = Vector2i(roundi(blade_tip.x), roundi(blade_tip.y))
	# Straight needle silhouettes distinguish the court stilettos from Ravenfang's claws.
	PixelCanvas.draw_line(image, p0, p1, dark_silver, 3 if is_main else 4)
	PixelCanvas.draw_line(image, p0, p1, pale_edge, 1)
	var groove_start: Vector2 = blade_start + direction * 3.0
	var groove_end: Vector2 = blade_tip - direction * 3.0
	PixelCanvas.draw_line(
		image,
		Vector2i(roundi(groove_start.x), roundi(groove_start.y)),
		Vector2i(roundi(groove_end.x), roundi(groove_end.y)),
		crimson,
		1
	)
	if is_main:
		# Cracked half-mask guard: porcelain crescent with one crimson fracture.
		var mask_a: Vector2i = Vector2i(
			roundi(guard_center.x + normal.x * 3.0), roundi(guard_center.y + normal.y * 3.0)
		)
		var mask_b: Vector2i = Vector2i(
			roundi(guard_center.x - normal.x * 2.0), roundi(guard_center.y - normal.y * 2.0)
		)
		PixelCanvas.draw_line(image, mask_a, mask_b, porcelain, 3)
		PixelCanvas.fill_rect(image, Rect2i(mask_a.x, mask_a.y, 1, 1), crimson)
	else:
		# Three compact fan facets read as a ceremonial folding guard.
		for extent: int in [2, 3, 4]:
			var offset_index: int = extent - 2
			var fan_end: Vector2 = guard_center + normal * float(extent) - direction * float(offset_index)
			PixelCanvas.draw_line(
				image,
				Vector2i(roundi(guard_center.x), roundi(guard_center.y)),
				Vector2i(roundi(fan_end.x), roundi(fan_end.y)),
				porcelain if extent != 3 else crimson,
				1
			)
	var grip_end: Vector2 = Vector2(hand) - direction * 4.0
	var grip_end_i: Vector2i = Vector2i(roundi(grip_end.x), roundi(grip_end.y))
	PixelCanvas.draw_line(image, hand, grip_end_i, grip_black, 3)
	var pommel: Vector2 = grip_end - direction * 1.5
	var pommel_i: Vector2i = Vector2i(roundi(pommel.x), roundi(pommel.y))
	PixelCanvas.fill_rect(image, Rect2i(pommel_i.x - 1, pommel_i.y - 1, 3, 3), crimson)
	PixelCanvas.fill_rect(image, Rect2i(pommel_i.x, pommel_i.y, 1, 1), porcelain)
