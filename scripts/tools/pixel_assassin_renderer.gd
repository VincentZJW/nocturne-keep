class_name PixelAssassinRenderer
extends RefCounted

## Draws one hard-edged 64×64 Night Warden frame from typed pose data.
##
## Stage 1 deliberately keeps the gameplay origin and 64 px contract while
## rebuilding the body as layered pixel anatomy instead of flat rectangles.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const Concept: Script = preload("res://scripts/tools/pixel_character_generator.gd")
const Pose: Script = preload("res://scripts/tools/pixel_assassin_pose.gd")


static func draw(pose: PixelAssassinPose, weapon_style: StringName = &"veilbound") -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var rear_shoulder: Vector2i = pose.body + Vector2i(2, 6)
	var front_shoulder: Vector2i = pose.body + Vector2i(13, 5)
	var rear_hip: Vector2i = pose.body + Vector2i(4, 18)
	var front_hip: Vector2i = pose.body + Vector2i(11, 18)
	if weapon_style != &"unarmed":
		_draw_dagger(image, pose.rear_hand, pose.offhand_tip, false, weapon_style)
	_draw_arm(image, rear_shoulder, pose.rear_hand, false)
	_draw_mantle(image, pose)
	_draw_leg(image, rear_hip, pose.rear_knee, pose.rear_foot, false)
	_draw_leg(image, front_hip, pose.front_knee, pose.front_foot, true)
	_draw_body(image, pose.body)
	_draw_hood(image, pose.body + pose.hood_shift)
	_draw_arm(image, front_shoulder, pose.front_hand, true)
	if weapon_style != &"unarmed":
		_draw_dagger(image, pose.front_hand, pose.main_tip, true, weapon_style)
	# The formal player sheet reserves rows 61–63 as transparent padding. Thick
	# limb strokes can otherwise bleed one pixel below the shared y=60 baseline.
	image.fill_rect(Rect2i(0, 61, 64, 3), Color(0.0, 0.0, 0.0, 0.0))
	return image


static func _draw_hood(image: Image, body: Vector2i) -> void:
	# Pointed hood silhouette, cowl fold and a narrow side-facing face opening.
	_fill_rows(image, body + Vector2i(0, -21), [
		Vector2i(7, 9), Vector2i(5, 11), Vector2i(3, 13), Vector2i(1, 15),
		Vector2i(-1, 17), Vector2i(-3, 18), Vector2i(-4, 19),
		Vector2i(-4, 19), Vector2i(-3, 18), Vector2i(-2, 17),
		Vector2i(-1, 17), Vector2i(0, 16), Vector2i(1, 15),
	], Concept.HOOD_BLACK)
	_fill_rows(image, body + Vector2i(0, -15), [
		Vector2i(8, 15), Vector2i(7, 16), Vector2i(7, 16), Vector2i(8, 16),
		Vector2i(9, 16), Vector2i(10, 15),
	], Color("101c29"))
	PixelCanvas.draw_line(
		image, body + Vector2i(2, -16), body + Vector2i(-1, -6),
		Concept.MIDNIGHT_NAVY, 2
	)
	PixelCanvas.draw_line(
		image, body + Vector2i(12, -19), body + Vector2i(16, -11),
		Concept.MOONLIT_SLATE.darkened(0.25), 1
	)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 12, body.y - 12, 4, 1), Concept.PALE_STEEL)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 15, body.y - 11, 2, 1), Color("8eb7ca"))
	# The cowl overlaps the torso and prevents a disconnected block-head read.
	_fill_rows(image, body + Vector2i(0, -5), [
		Vector2i(-3, 18), Vector2i(-4, 19), Vector2i(-3, 18), Vector2i(-1, 16),
	], Concept.HOOD_BLACK)
	PixelCanvas.draw_line(
		image, body + Vector2i(1, -4), body + Vector2i(14, -2),
		Concept.MOONLIT_SLATE.darkened(0.20), 1
	)


static func _draw_body(image: Image, body: Vector2i) -> void:
	# Tapered torso: fitted cloth under segmented leather and dark-silver plates.
	_fill_rows(image, body + Vector2i(0, -1), [
		Vector2i(-2, 17), Vector2i(-3, 18), Vector2i(-3, 18), Vector2i(-2, 17),
		Vector2i(-2, 17), Vector2i(-1, 16), Vector2i(-1, 16), Vector2i(0, 15),
		Vector2i(0, 15), Vector2i(1, 14), Vector2i(1, 14), Vector2i(1, 14),
		Vector2i(1, 14), Vector2i(0, 15), Vector2i(0, 15), Vector2i(-1, 16),
		Vector2i(-1, 16), Vector2i(-2, 17), Vector2i(-2, 17), Vector2i(-1, 16),
	], Concept.MIDNIGHT_NAVY)
	# Shoulder mantle and two asymmetric armor plates.
	PixelCanvas.draw_line(image, body + Vector2i(-2, 1), body + Vector2i(8, 4), Concept.MOONLIT_SLATE, 4)
	PixelCanvas.draw_line(image, body + Vector2i(8, 3), body + Vector2i(16, 1), Color("34495a"), 3)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 10, body.y + 5, 5, 7), Color("34495a"))
	PixelCanvas.fill_rect(image, Rect2i(body.x + 11, body.y + 6, 3, 5), Concept.MOONLIT_SLATE)
	# Cross-body oath straps, buckle and tiny veil-shaped soul mark.
	PixelCanvas.draw_line(image, body + Vector2i(1, 1), body + Vector2i(13, 15), Color("3d302a"), 2)
	PixelCanvas.draw_line(image, body + Vector2i(13, 2), body + Vector2i(4, 14), Color("574338"), 1)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 7, body.y + 7, 2, 2), Concept.MUTED_AMBER)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 7, body.y + 9, 2, 2), Color("7e9bac"))
	PixelCanvas.fill_rect(image, Rect2i(body.x + 8, body.y + 11, 1, 2), Color("486a7b"))
	# Layered belts, sheath loops and split coat tails preserve leg separation.
	PixelCanvas.fill_rect(image, Rect2i(body.x - 1, body.y + 15, 18, 3), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(body.x + 2, body.y + 16, 10, 1), Concept.MUTED_AMBER.darkened(0.24))
	PixelCanvas.fill_rect(image, Rect2i(body.x + 2, body.y + 18, 5, 6), Color("101d2a"))
	PixelCanvas.fill_rect(image, Rect2i(body.x + 10, body.y + 18, 5, 5), Color("122131"))
	PixelCanvas.fill_rect(image, Rect2i(body.x - 2, body.y + 14, 3, 7), Color("3d302a"))
	PixelCanvas.fill_rect(image, Rect2i(body.x + 16, body.y + 14, 2, 6), Color("3d302a"))


static func _draw_mantle(image: Image, pose: PixelAssassinPose) -> void:
	var shoulder: Vector2i = pose.body + Vector2i(3, 1)
	PixelCanvas.draw_line(image, shoulder, pose.mantle_tip, Concept.HOOD_BLACK, 7)
	PixelCanvas.draw_line(image, shoulder + Vector2i(1, 2), pose.mantle_tip + Vector2i(2, 1), Concept.MIDNIGHT_NAVY, 3)
	# Three deliberately uneven ends read as a torn short cape, not a long cloak.
	var cape_direction: Vector2 = Vector2(pose.mantle_tip - shoulder).normalized()
	var normal: Vector2 = Vector2(-cape_direction.y, cape_direction.x)
	for offset: int in [-2, 0, 2]:
		var torn_tip: Vector2 = Vector2(pose.mantle_tip) + normal * float(offset) + cape_direction * float(absi(offset) % 2)
		PixelCanvas.fill_rect(
			image, Rect2i(roundi(torn_tip.x), roundi(torn_tip.y), 2, 2),
			Concept.HOOD_BLACK
		)


static func _draw_arm(image: Image, shoulder: Vector2i, hand: Vector2i, is_front: bool) -> void:
	PixelCanvas.draw_line(image, shoulder, hand, Concept.HOOD_BLACK, 7)
	PixelCanvas.draw_line(image, shoulder, hand, Concept.MIDNIGHT_NAVY, 5)
	var inset_start: Vector2i = shoulder + Vector2i(1, 1)
	PixelCanvas.draw_line(image, inset_start, hand, Concept.MOONLIT_SLATE, 2 if is_front else 1)
	var midpoint: Vector2i = Vector2i((shoulder.x + hand.x) / 2, (shoulder.y + hand.y) / 2)
	PixelCanvas.fill_rect(image, Rect2i(midpoint.x - 2, midpoint.y - 2, 5, 4), Color("34495a"))
	PixelCanvas.fill_rect(image, Rect2i(midpoint.x - 1, midpoint.y - 1, 3, 1), Concept.MOONLIT_SLATE)
	PixelCanvas.fill_rect(image, Rect2i(hand.x - 2, hand.y - 2, 5, 5), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(hand.x, hand.y - 1, 2, 2), Color("3e5363"))


static func _draw_leg(
		image: Image,
		hip: Vector2i,
		knee: Vector2i,
		foot: Vector2i,
		is_front: bool
	) -> void:
	PixelCanvas.draw_line(image, hip, knee, Concept.HOOD_BLACK, 8)
	PixelCanvas.draw_line(image, knee, foot, Concept.HOOD_BLACK, 7)
	PixelCanvas.draw_line(image, hip, knee, Concept.MIDNIGHT_NAVY, 6)
	PixelCanvas.draw_line(image, knee, foot, Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.draw_line(image, hip + Vector2i(1, 1), knee, Concept.MOONLIT_SLATE, 2 if is_front else 1)
	PixelCanvas.fill_rect(image, Rect2i(knee.x - 2, knee.y - 2, 5, 4), Color("34495a"))
	PixelCanvas.fill_rect(image, Rect2i(knee.x - 1, knee.y - 1, 3, 1), Concept.MOONLIT_SLATE)
	var shin_mid: Vector2i = Vector2i((knee.x + foot.x) / 2, (knee.y + foot.y) / 2)
	PixelCanvas.fill_rect(image, Rect2i(shin_mid.x - 2, shin_mid.y - 2, 4, 5), Color("142433"))
	PixelCanvas.draw_line(image, knee + Vector2i(-1, 3), foot + Vector2i(-1, -2), Color("5a7181"), 1)
	var boot_start_x: int = foot.x - 3 if foot.x <= knee.x else foot.x - 1
	# Keep the established y=60 foot baseline. A four-pixel boot extended the
	# generated silhouette to y=61 and made otherwise identical animations hop.
	PixelCanvas.fill_rect(image, Rect2i(boot_start_x, foot.y - 2, 8, 3), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(boot_start_x + 1, foot.y - 2, 5, 1), Color("435363"))


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
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var blade_start: Vector2i = hand + Vector2i(roundi(direction.x * 4.0), roundi(direction.y * 4.0))
	PixelCanvas.draw_line(image, blade_start, tip, Color("1f2f3a"), 4)
	PixelCanvas.draw_line(image, blade_start, tip, Concept.MOONLIT_SLATE, 3)
	PixelCanvas.draw_line(image, blade_start, tip, Concept.PALE_STEEL, 1)
	var near_tip: Vector2 = Vector2(tip) - direction * 2.0
	var point_a: Vector2i = Vector2i(roundi(near_tip.x + normal.x), roundi(near_tip.y + normal.y))
	PixelCanvas.draw_line(image, point_a, tip, Concept.PALE_STEEL, 1)
	var guard_a: Vector2i = hand + Vector2i(roundi(normal.x * 3.0), roundi(normal.y * 3.0))
	var guard_b: Vector2i = hand - Vector2i(roundi(normal.x * 3.0), roundi(normal.y * 3.0))
	PixelCanvas.draw_line(image, guard_a, guard_b, Color("6d8290"), 2)
	var grip_end: Vector2i = hand - Vector2i(roundi(direction.x * 4.0), roundi(direction.y * 4.0))
	PixelCanvas.draw_line(image, hand, grip_end, Concept.HOOD_BLACK, 3)
	PixelCanvas.fill_rect(image, Rect2i(grip_end.x - 1, grip_end.y - 1, 3, 3), Concept.MUTED_AMBER if is_main else Color("34495a"))


static func _fill_rows(
		image: Image, origin: Vector2i, spans: Array[Vector2i], color: Color
	) -> void:
	for row_index: int in range(spans.size()):
		var span: Vector2i = spans[row_index]
		PixelCanvas.fill_rect(
			image,
			Rect2i(origin.x + span.x, origin.y + row_index, span.y - span.x + 1, 1),
			color
		)


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
