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
	if weapon_style == &"thirteenfold_absolution":
		draw_thirteenfold_absolution_blade(image, hand, tip, is_main)
		return
	if weapon_style == &"soul_lock_twin_keys":
		draw_soul_lock_twin_key(image, hand, tip, is_main)
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


static func draw_thirteenfold_absolution_blade(
		image: Image, hand: Vector2i, tip: Vector2i, is_main: bool
	) -> void:
	var delta: Vector2 = Vector2(tip - hand)
	var length: float = maxf(1.0, delta.length())
	var direction: Vector2 = delta / length
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var bone: Color = Color("d9d5c8")
	var cold_edge: Color = Color("edf1ed")
	var black_iron: Color = Color("18212a")
	var shadow_steel: Color = Color("4e5d66")
	var prayer_red: Color = Color("702833")
	var old_copper: Color = Color("987543")
	var dark_copper: Color = Color("5f472c")
	var grip_black: Color = Color("090b0e")
	var blade_length_scale: float = 1.0 if is_main else 0.80
	var authored_tip: Vector2 = Vector2(hand) + delta * blade_length_scale
	var blade_start: Vector2 = Vector2(hand) + direction * (5.0 if is_main else 4.0)
	var start_i: Vector2i = Vector2i(roundi(blade_start.x), roundi(blade_start.y))
	var tip_i: Vector2i = Vector2i(roundi(authored_tip.x), roundi(authored_tip.y))
	if is_main:
		# Absolution is a long triangular thrust blade: a black-iron back plane,
		# bone-white face and one restrained prayer groove remain readable at 64 px.
		PixelCanvas.draw_line(image, start_i, tip_i, black_iron, 5)
		PixelCanvas.draw_line(image, start_i, tip_i, bone, 3)
		var bright_start: Vector2 = blade_start + normal
		PixelCanvas.draw_line(
			image,
			Vector2i(roundi(bright_start.x), roundi(bright_start.y)),
			tip_i,
			cold_edge,
			1
		)
		var groove_start: Vector2 = blade_start + direction * 3.0 - normal
		var groove_end: Vector2 = authored_tip - direction * 4.0 - normal
		PixelCanvas.draw_line(
			image,
			Vector2i(roundi(groove_start.x), roundi(groove_start.y)),
			Vector2i(roundi(groove_end.x), roundi(groove_end.y)),
			prayer_red,
			1
		)
	else:
		# Penance is shorter and broader. A shallow hooked spine and perforated
		# thurible face keep it distinct from Ravenfang's large hooked claws.
		var shoulder: Vector2 = blade_start + direction * length * 0.36 - normal * 2.0
		var hook: Vector2 = blade_start + direction * length * 0.64 - normal * 2.0
		var shoulder_i: Vector2i = Vector2i(roundi(shoulder.x), roundi(shoulder.y))
		var hook_i: Vector2i = Vector2i(roundi(hook.x), roundi(hook.y))
		PixelCanvas.draw_line(image, start_i, shoulder_i, black_iron, 6)
		PixelCanvas.draw_line(image, shoulder_i, hook_i, shadow_steel, 5)
		PixelCanvas.draw_line(image, hook_i, tip_i, bone, 3)
		PixelCanvas.draw_line(image, start_i, tip_i, cold_edge, 1)
		for fraction: float in [0.28, 0.46, 0.62]:
			var vent: Vector2 = blade_start + direction * length * fraction - normal
			_set_safe_pixel(image, Vector2i(roundi(vent.x), roundi(vent.y)), black_iron)
	# Both guards are real hollow constructions rather than solid color blocks.
	var guard_center: Vector2i = Vector2i(
		roundi(float(hand.x) + direction.x), roundi(float(hand.y) + direction.y)
	)
	if is_main:
		_draw_hollow_guard(image, guard_center, direction, normal, old_copper, dark_copper, true)
	else:
		_draw_hollow_guard(image, guard_center, direction, normal, old_copper, dark_copper, false)
	var grip_end: Vector2 = Vector2(hand) - direction * (5.0 if is_main else 4.0)
	var grip_end_i: Vector2i = Vector2i(roundi(grip_end.x), roundi(grip_end.y))
	PixelCanvas.draw_line(image, hand, grip_end_i, grip_black, 3)
	var wrap_mid: Vector2 = Vector2(hand) - direction * 2.0
	_set_safe_pixel(image, Vector2i(roundi(wrap_mid.x), roundi(wrap_mid.y)), prayer_red)
	var pommel: Vector2 = grip_end - direction * 2.0
	var pommel_i: Vector2i = Vector2i(roundi(pommel.x), roundi(pommel.y))
	if is_main:
		PixelCanvas.fill_rect(image, Rect2i(pommel_i.x - 1, pommel_i.y - 1, 3, 3), dark_copper)
		_set_safe_pixel(image, pommel_i, bone)
	else:
		# Fixed chain ring: it never swings as a physics weapon.
		_draw_ring_pixels(image, pommel_i, old_copper, grip_black)


static func draw_soul_lock_twin_key(
		image: Image, hand: Vector2i, tip: Vector2i, is_main: bool
	) -> void:
	var delta: Vector2 = Vector2(tip - hand)
	var length: float = maxf(1.0, delta.length())
	var direction: Vector2 = delta / length
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var authored_tip: Vector2 = Vector2(tip) if is_main else Vector2(hand) + delta * 0.84
	var blade_start: Vector2 = Vector2(hand) + direction * (5.0 if is_main else 4.0)
	var start_i: Vector2i = Vector2i(roundi(blade_start.x), roundi(blade_start.y))
	var tip_i: Vector2i = Vector2i(roundi(authored_tip.x), roundi(authored_tip.y))
	var lock_black: Color = Color("10171d")
	var corroded_steel: Color = Color("6f7d80")
	var pale_edge: Color = Color("c7d4d3")
	var rust: Color = Color("8b5133")
	var soul_cyan: Color = Color("6ca7ac")
	var grip: Color = Color("171313")
	if is_main:
		# Lockbreaker / 断狱: broad asymmetric key-tooth blade and broken shackle guard.
		PixelCanvas.draw_line(image, start_i, tip_i, lock_black, 6)
		PixelCanvas.draw_line(image, start_i, tip_i, corroded_steel, 4)
		PixelCanvas.draw_line(image, start_i, tip_i, pale_edge, 1)
		for fraction: float in [0.42, 0.61, 0.78]:
			var tooth_root: Vector2 = blade_start + (authored_tip - blade_start) * fraction
			var tooth_length: float = 3.0 if fraction < 0.7 else 2.0
			var tooth_end: Vector2 = tooth_root - normal * tooth_length
			PixelCanvas.draw_line(
				image,
				Vector2i(roundi(tooth_root.x), roundi(tooth_root.y)),
				Vector2i(roundi(tooth_end.x), roundi(tooth_end.y)),
				lock_black,
				3
			)
			PixelCanvas.draw_line(
				image,
				Vector2i(roundi(tooth_root.x), roundi(tooth_root.y)),
				Vector2i(roundi(tooth_end.x), roundi(tooth_end.y)),
				pale_edge,
				1
			)
	else:
		# Soulseal / 魂契: narrower intact key with a cyan soul channel and sealed teeth.
		PixelCanvas.draw_line(image, start_i, tip_i, lock_black, 5)
		PixelCanvas.draw_line(image, start_i, tip_i, corroded_steel, 3)
		var channel_start: Vector2 = blade_start + direction * 2.0
		var channel_end: Vector2 = authored_tip - direction * 3.0
		PixelCanvas.draw_line(
			image,
			Vector2i(roundi(channel_start.x), roundi(channel_start.y)),
			Vector2i(roundi(channel_end.x), roundi(channel_end.y)),
			soul_cyan,
			1
		)
		for fraction: float in [0.58, 0.76]:
			var tooth_root: Vector2 = blade_start + (authored_tip - blade_start) * fraction
			var tooth_end: Vector2 = tooth_root + normal * 2.0
			PixelCanvas.draw_line(
				image,
				Vector2i(roundi(tooth_root.x), roundi(tooth_root.y)),
				Vector2i(roundi(tooth_end.x), roundi(tooth_end.y)),
				pale_edge,
				1
			)
	# The opposed guards make the pair read as broken lock and intact seal.
	var guard_center: Vector2i = Vector2i(
		roundi(float(hand.x) + direction.x), roundi(float(hand.y) + direction.y)
	)
	if is_main:
		var guard_a: Vector2i = Vector2i(
			roundi(float(guard_center.x) + normal.x * 4.0),
			roundi(float(guard_center.y) + normal.y * 4.0)
		)
		var guard_b: Vector2i = Vector2i(
			roundi(float(guard_center.x) - normal.x * 2.0),
			roundi(float(guard_center.y) - normal.y * 2.0)
		)
		PixelCanvas.draw_line(image, guard_a, guard_center, rust, 2)
		PixelCanvas.draw_line(image, guard_center, guard_b, corroded_steel, 2)
		_set_safe_pixel(image, guard_a + Vector2i(roundi(direction.x), roundi(direction.y)), soul_cyan)
	else:
		_draw_ring_pixels(image, guard_center, corroded_steel, lock_black)
		_set_safe_pixel(image, guard_center, soul_cyan)
	var grip_end: Vector2 = Vector2(hand) - direction * (5.0 if is_main else 4.0)
	var grip_end_i: Vector2i = Vector2i(roundi(grip_end.x), roundi(grip_end.y))
	PixelCanvas.draw_line(image, hand, grip_end_i, grip, 3)
	_set_safe_pixel(
		image,
		Vector2i(roundi(float(hand.x) - direction.x * 2.0), roundi(float(hand.y) - direction.y * 2.0)),
		rust
	)
	var pommel: Vector2i = Vector2i(
		roundi(grip_end.x - direction.x * 2.0), roundi(grip_end.y - direction.y * 2.0)
	)
	if is_main:
		# Two compact links imply the broken gaol-chain without changing attack reach.
		_draw_ring_pixels(image, pommel, rust, lock_black)
		_set_safe_pixel(
			image,
			pommel - Vector2i(roundi(direction.x * 3.0), roundi(direction.y * 3.0)),
			corroded_steel
		)
	else:
		PixelCanvas.fill_rect(image, Rect2i(pommel.x - 1, pommel.y - 1, 3, 3), lock_black)
		_set_safe_pixel(image, pommel, soul_cyan)


static func _draw_hollow_guard(
		image: Image,
		center: Vector2i,
		direction: Vector2,
		normal: Vector2,
		outer: Color,
		shadow: Color,
		is_main: bool
	) -> void:
	var tangent_extent: int = 4 if is_main else 3
	var axial_extent: int = 3 if is_main else 2
	for sign: int in [-1, 1]:
		for offset: int in range(-axial_extent + 1, axial_extent):
			var point: Vector2 = (
				Vector2(center)
				+ normal * float(tangent_extent * sign)
				+ direction * float(offset)
			)
			_set_safe_pixel(image, Vector2i(roundi(point.x), roundi(point.y)), outer)
	for sign: int in [-1, 1]:
		for offset: int in range(-tangent_extent + 1, tangent_extent):
			var point: Vector2 = (
				Vector2(center)
				+ direction * float(axial_extent * sign)
				+ normal * float(offset)
			)
			_set_safe_pixel(image, Vector2i(roundi(point.x), roundi(point.y)), outer)
	_set_safe_pixel(image, center, Color(0.0, 0.0, 0.0, 0.0))
	if is_main:
		# Four readable seal bosses imply the full thirteen-node construction.
		for point: Vector2i in [
			center + Vector2i(tangent_extent, 0), center + Vector2i(-tangent_extent, 0),
			center + Vector2i(0, axial_extent), center + Vector2i(0, -axial_extent),
		]:
			_set_safe_pixel(image, point, Color("c3a35d"))
	else:
		# Three dark vents make the semicircular thurible guard legible.
		for offset: int in [-2, 0, 2]:
			var vent: Vector2 = Vector2(center) + normal * float(offset) + direction
			_set_safe_pixel(image, Vector2i(roundi(vent.x), roundi(vent.y)), shadow)


static func _draw_ring_pixels(image: Image, center: Vector2i, outer: Color, inner: Color) -> void:
	for offset: Vector2i in [
		Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2),
		Vector2i(-2, -1), Vector2i(2, -1), Vector2i(-2, 0), Vector2i(2, 0),
		Vector2i(-2, 1), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2),
	]:
		_set_safe_pixel(image, center + offset, outer)
	_set_safe_pixel(image, center, inner)


static func _set_safe_pixel(image: Image, point: Vector2i, color: Color) -> void:
	if Rect2i(Vector2i.ZERO, image.get_size()).has_point(point):
		image.set_pixelv(point, color)
