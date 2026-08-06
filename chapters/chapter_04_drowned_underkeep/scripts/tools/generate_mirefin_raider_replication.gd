extends SceneTree

## Redraws Mirefin Raider directly on 128x128 transparent pixel canvases.
## The authoritative reference is the Chapter IV concept sheet; no concept pixels
## are scaled, traced, or sampled into the runtime frames.

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep/assets/enemies/mirefin_raider"
const FRAME_SIZE: Vector2i = Vector2i(128, 128)
const BASELINE_Y: int = 102
const CLEAR: Color = Color(0.0, 0.0, 0.0, 0.0)
const OUTLINE: Color = Color("071015")
const ABYSS: Color = Color("0d1a1d")
const SCALE_DARK: Color = Color("1d3433")
const SCALE_MID: Color = Color("355452")
const SCALE_LIGHT: Color = Color("5f7972")
const WET_LIGHT: Color = Color("94aaa0")
const BONE_DARK: Color = Color("5f6259")
const BONE_MID: Color = Color("a7a493")
const BONE_LIGHT: Color = Color("d0c9b3")
const GILL_DARK: Color = Color("391f27")
const GILL_RED: Color = Color("7d3b42")
const RAG_DARK: Color = Color("2c211c")
const RAG_MID: Color = Color("5a392b")
const RAG_LIGHT: Color = Color("86543b")
const IRON_DARK: Color = Color("263238")
const IRON: Color = Color("607178")
const IRON_LIGHT: Color = Color("a0b0ad")
const SOUL: Color = Color("6eb4ba")
const SOUL_LIGHT: Color = Color("c6ece5")

const ACTIONS: Array[String] = ["claw_swipe", "mire_lunge", "fin_bite"]


func _initialize() -> void:
	var total: int = 0
	var definitions: Dictionary = _animation_definitions()
	for animation_variant: Variant in definitions.keys():
		var animation: String = str(animation_variant)
		var count: int = int(definitions[animation])
		var directory: String = "%s/sprites/%s" % [ROOT, animation]
		var absolute_directory: String = ProjectSettings.globalize_path(directory)
		if not DirAccess.dir_exists_absolute(absolute_directory):
			push_error("MIRE FIN REPLICATION: formal directory does not exist: %s" % directory)
			quit(1)
			return
		for frame: int in range(count):
			var image: Image = _draw_frame(animation, frame, count)
			var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
			if not FileAccess.file_exists(path):
				push_error("MIRE FIN REPLICATION: refusing to create replacement frame: %s" % path)
				quit(1)
				return
			if image.save_png(ProjectSettings.globalize_path(path)) != OK:
				push_error("MIRE FIN REPLICATION: cannot save %s" % path)
				quit(1)
				return
			total += 1
	_write_reference_sheet()
	print("MIRE FIN REPLICATION ART | PASS frames=%d size=%dx%d" % [total, FRAME_SIZE.x, FRAME_SIZE.y])
	quit(0)


func _animation_definitions() -> Dictionary:
	var result: Dictionary = {
		"idle": 4,
		"walk": 6,
		"alert": 3,
		"turn": 3,
		"light_hit": 2,
		"stagger": 4,
		"hurt": 3,
		"death": 6,
	}
	for action: String in ACTIONS:
		result["%s_windup" % action] = 5
		result["%s_active" % action] = 2
		result["%s_recovery" % action] = 5
	return result


func _draw_frame(animation: String, frame: int, count: int) -> Image:
	var image: Image = Image.create(FRAME_SIZE.x, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	if animation == "death":
		_draw_death(image, frame)
		return image
	var phase: float = float(frame) / float(maxi(1, count - 1))
	var action: String = ""
	var stage: String = "base"
	for candidate: String in ACTIONS:
		if animation.begins_with(candidate):
			action = candidate
			if animation.ends_with("_windup"):
				stage = "windup"
			elif animation.ends_with("_active"):
				stage = "active"
			elif animation.ends_with("_recovery"):
				stage = "recovery"
			break
	if animation in ["light_hit", "hurt", "stagger"]:
		stage = "hurt"
	var bob: int = 0
	if animation == "idle":
		bob = [0, -1, -2, -1][frame]
	elif animation == "walk":
		bob = [0, -2, -1, 0, -2, -1][frame]
	elif animation == "alert":
		bob = [1, -2, -3][frame]
	var stride: int = [-8, -4, 1, 8, 4, -1][frame] if animation == "walk" else 0
	var turn_compress: int = [0, 6, 2][frame] if animation == "turn" else 0
	_draw_raider(image, animation, action, stage, frame, phase, bob, stride, turn_compress)
	return image


func _draw_raider(
	image: Image,
	animation: String,
	action: String,
	stage: String,
	frame: int,
	phase: float,
	bob: int,
	stride: int,
	turn_compress: int
) -> void:
	var body_shift: Vector2i = Vector2i.ZERO
	var crouch: int = 0
	if stage == "windup":
		body_shift.x = -roundi(phase * 4.0)
		crouch = roundi(phase * 5.0)
	elif stage == "active":
		body_shift.x = 13 if action == "mire_lunge" else 8 if action == "fin_bite" else 5
		body_shift.y = -2 if action == "mire_lunge" else 0
	elif stage == "recovery":
		body_shift.x = roundi((1.0 - phase) * (8.0 if action == "mire_lunge" else 4.0))
		crouch = roundi((1.0 - phase) * 3.0)
	elif stage == "hurt":
		body_shift.x = -4 - frame * 2
		body_shift.y = frame if animation == "stagger" else 0
	var origin: Vector2i = Vector2i(0, bob + crouch) + body_shift
	var hip: Vector2i = Vector2i(53, 72) + origin
	var shoulder: Vector2i = Vector2i(57, 45) + origin
	var neck: Vector2i = Vector2i(70, 38) + origin
	var head_push: int = 0
	var jaw_open: int = 2
	if action == "fin_bite":
		if stage == "windup":
			head_push = -roundi(phase * 3.0)
			jaw_open = 2 + roundi(phase * 4.0)
		elif stage == "active":
			head_push = 11 + frame * 3
			jaw_open = 10
		elif stage == "recovery":
			head_push = roundi((1.0 - phase) * 8.0)
			jaw_open = 2 + roundi((1.0 - phase) * 7.0)
	var head: Vector2i = neck + Vector2i(14 + head_push - turn_compress, -8)

	# The ankle restraint and loose chain render behind every living pose.
	var rear_foot: Vector2i = Vector2i(34 - stride, BASELINE_Y) + Vector2i(body_shift.x / 3, 0)
	var front_foot: Vector2i = Vector2i(71 + stride, BASELINE_Y) + Vector2i(body_shift.x / 3, 0)
	_draw_ankle_chain(image, hip + Vector2i(-4, 5), rear_foot + Vector2i(0, -3), origin)

	# Long irregular fin ridge and layered back scales establish the hunched silhouette.
	_draw_dorsal_ridge(image, origin, action, stage)
	_draw_far_leg(image, hip + Vector2i(-7, 0), rear_foot, stride)
	_draw_far_arm(image, shoulder + Vector2i(-8, 4), action, stage, phase)

	# Hunched torso: outline, wet scale mass, bony shoulder and belly shadow.
	_poly(image, _pts([
		shoulder.x - 23, shoulder.y + 2,
		shoulder.x - 13, shoulder.y - 10,
		shoulder.x + 8, shoulder.y - 7,
		neck.x + 8, neck.y + 8,
		hip.x + 15, hip.y + 6,
		hip.x + 4, hip.y + 17,
		hip.x - 18, hip.y + 12,
		shoulder.x - 26, shoulder.y + 18,
	]), OUTLINE)
	_poly(image, _pts([
		shoulder.x - 19, shoulder.y + 3,
		shoulder.x - 11, shoulder.y - 6,
		shoulder.x + 7, shoulder.y - 4,
		neck.x + 4, neck.y + 9,
		hip.x + 10, hip.y + 5,
		hip.x + 2, hip.y + 13,
		hip.x - 15, hip.y + 9,
		shoulder.x - 21, shoulder.y + 16,
	]), SCALE_DARK)
	_poly(image, _pts([
		shoulder.x - 12, shoulder.y - 3,
		shoulder.x + 4, shoulder.y - 1,
		neck.x, neck.y + 11,
		hip.x + 4, hip.y + 4,
		hip.x - 8, hip.y + 7,
		shoulder.x - 15, shoulder.y + 12,
	]), SCALE_MID)
	_draw_scale_field(image, shoulder + Vector2i(-14, 2), 5, 4)
	_segment(image, shoulder + Vector2i(-12, 1), neck + Vector2i(1, 7), 3, WET_LIGHT)

	# Prisoner remnants are layered strips, not one flat loincloth.
	_draw_rags(image, hip)
	_draw_front_leg(image, hip + Vector2i(7, 2), front_foot, stride)

	# Exposed crimson gill cage remains visible between skull and torso.
	_draw_gills(image, neck)
	_draw_skull(image, head, jaw_open)

	# Near arm owns the principal attack readability; four fingers remain distinct.
	var near_elbow: Vector2i = shoulder + Vector2i(17, 24)
	var near_hand: Vector2i = shoulder + Vector2i(31, 45)
	if action == "claw_swipe":
		if stage == "windup":
			near_elbow = shoulder + Vector2i(-7 - roundi(phase * 8.0), 15 - roundi(phase * 5.0))
			near_hand = shoulder + Vector2i(-19 - roundi(phase * 8.0), 27)
		elif stage == "active":
			near_elbow = shoulder + Vector2i(29, 13)
			near_hand = Vector2i(119, shoulder.y + 24 + frame * 4)
		elif stage == "recovery":
			near_elbow = shoulder + Vector2i(17 + roundi((1.0 - phase) * 11.0), 22)
			near_hand = shoulder + Vector2i(31 + roundi((1.0 - phase) * 25.0), 42)
	elif action == "mire_lunge":
		if stage == "windup":
			near_elbow = shoulder + Vector2i(-5, 20)
			near_hand = shoulder + Vector2i(-17, 37)
		elif stage == "active":
			near_elbow = shoulder + Vector2i(28, 18)
			near_hand = Vector2i(120, shoulder.y + 34)
		elif stage == "recovery":
			near_elbow = shoulder + Vector2i(18 + roundi((1.0 - phase) * 10.0), 24)
			near_hand = shoulder + Vector2i(31 + roundi((1.0 - phase) * 22.0), 43)
	elif action == "fin_bite" and stage == "active":
		near_elbow = shoulder + Vector2i(22, 28)
		near_hand = shoulder + Vector2i(34, 43)
	_draw_scaled_limb(image, shoulder + Vector2i(6, 7), near_elbow, near_hand, true)
	_draw_wet_details(image, origin)
	_draw_foreground_chain(image, rear_foot, origin)


func _draw_dorsal_ridge(image: Image, origin: Vector2i, action: String, stage: String) -> void:
	var flatten: int = 3 if action == "mire_lunge" and stage == "active" else 0
	var roots: Array[Vector2i] = [
		Vector2i(69, 37), Vector2i(62, 34), Vector2i(55, 33), Vector2i(48, 35),
		Vector2i(42, 39), Vector2i(37, 45), Vector2i(34, 52), Vector2i(34, 60),
	]
	var heights: Array[int] = [13, 20, 25, 24, 22, 19, 15, 11]
	for index: int in range(roots.size() - 1, -1, -1):
		var root: Vector2i = roots[index] + origin
		var width: int = 7 if index < 4 else 6
		var tip: Vector2i = root + Vector2i(-4 - index / 3, -heights[index] + flatten)
		_poly(image, PackedVector2Array([
			Vector2(root.x - width, root.y + 3), Vector2(tip), Vector2(root.x + width, root.y + 5)
		]), OUTLINE)
		_poly(image, PackedVector2Array([
			Vector2(root.x - width + 2, root.y + 2), Vector2(tip.x + 1, tip.y + 3), Vector2(root.x + width - 2, root.y + 3)
		]), SCALE_MID if index % 2 == 0 else SCALE_DARK)
		_segment(image, root + Vector2i(-width + 2, 1), tip + Vector2i(1, 3), 2, SCALE_LIGHT)


func _draw_skull(image: Image, center: Vector2i, jaw_open: int) -> void:
	# Long fish-bone cranium and hooked snout.
	_poly(image, _pts([
		center.x - 16, center.y - 8,
		center.x - 7, center.y - 15,
		center.x + 8, center.y - 13,
		center.x + 22, center.y - 5,
		center.x + 29, center.y + 3,
		center.x + 22, center.y + 9,
		center.x + 4, center.y + 9,
		center.x - 12, center.y + 5,
	]), OUTLINE)
	_poly(image, _pts([
		center.x - 12, center.y - 7,
		center.x - 5, center.y - 12,
		center.x + 7, center.y - 10,
		center.x + 20, center.y - 3,
		center.x + 25, center.y + 2,
		center.x + 19, center.y + 6,
		center.x + 4, center.y + 5,
		center.x - 9, center.y + 2,
	]), BONE_MID)
	_poly(image, _pts([
		center.x - 7, center.y - 7,
		center.x + 5, center.y - 8,
		center.x + 17, center.y - 2,
		center.x + 7, center.y,
		center.x - 5, center.y - 1,
	]), BONE_LIGHT)
	# Temple holes and cold drowned eye.
	_ellipse(image, center + Vector2i(-5, -3), 6, 6, OUTLINE)
	_ellipse(image, center + Vector2i(-4, -3), 3, 3, SOUL)
	_pixel(image, center.x - 3, center.y - 4, SOUL_LIGHT)
	_ellipse(image, center + Vector2i(8, 0), 2, 2, BONE_DARK)
	_ellipse(image, center + Vector2i(15, 2), 2, 1, BONE_DARK)
	# Deep mouth and separate lower jaw preserve mouth depth in every pose.
	_poly(image, _pts([
		center.x - 4, center.y + 6,
		center.x + 25, center.y + 4,
		center.x + 20, center.y + 10 + jaw_open,
		center.x + 1, center.y + 12 + jaw_open,
		center.x - 9, center.y + 8,
	]), OUTLINE)
	_poly(image, _pts([
		center.x, center.y + 7,
		center.x + 21, center.y + 6,
		center.x + 17, center.y + 8 + jaw_open,
		center.x + 2, center.y + 10 + jaw_open,
		center.x - 5, center.y + 8,
	]), GILL_DARK)
	for tooth: int in range(7):
		var tooth_x: int = center.x + tooth * 4 - 2
		_poly(image, _pts([tooth_x, center.y + 6, tooth_x + 2, center.y + 11, tooth_x + 4, center.y + 6]), BONE_LIGHT)
		_poly(image, _pts([tooth_x, center.y + 9 + jaw_open, tooth_x + 2, center.y + 5 + jaw_open, tooth_x + 4, center.y + 9 + jaw_open]), BONE_LIGHT)
	_segment(image, center + Vector2i(0, 11 + jaw_open), center + Vector2i(18, 9 + jaw_open), 2, BONE_DARK)


func _draw_gills(image: Image, neck: Vector2i) -> void:
	_poly(image, _pts([
		neck.x - 4, neck.y - 2,
		neck.x + 8, neck.y,
		neck.x + 6, neck.y + 18,
		neck.x - 7, neck.y + 16,
	]), OUTLINE)
	for slit: int in range(4):
		var x: int = neck.x - 2 + slit * 3
		_segment(image, Vector2i(x, neck.y + 2), Vector2i(x - 2, neck.y + 14), 2, GILL_RED)
		_pixel(image, x, neck.y + 3, WET_LIGHT)


func _draw_far_arm(image: Image, shoulder: Vector2i, action: String, stage: String, phase: float) -> void:
	var elbow: Vector2i = shoulder + Vector2i(-12, 23)
	var hand: Vector2i = shoulder + Vector2i(-25, 43)
	if action == "mire_lunge" and stage == "active":
		elbow = shoulder + Vector2i(18, 24)
		hand = shoulder + Vector2i(37, 38)
	elif stage == "windup":
		hand += Vector2i(-roundi(phase * 7.0), -roundi(phase * 4.0))
	_draw_scaled_limb(image, shoulder, elbow, hand, false)


func _draw_scaled_limb(image: Image, root: Vector2i, elbow: Vector2i, hand: Vector2i, near: bool) -> void:
	_segment(image, root, elbow, 13, OUTLINE)
	_segment(image, elbow, hand, 11, OUTLINE)
	_segment(image, root, elbow, 8, SCALE_MID if near else SCALE_DARK)
	_segment(image, elbow, hand, 7, SCALE_LIGHT if near else SCALE_MID)
	_segment(image, root + Vector2i(1, -2), elbow + Vector2i(1, -2), 2, WET_LIGHT)
	_draw_webbed_claw(image, hand, 1 if hand.x >= root.x else -1, near)


func _draw_webbed_claw(image: Image, palm: Vector2i, direction: int, near: bool) -> void:
	_ellipse(image, palm, 5, 5, OUTLINE)
	_ellipse(image, palm, 3, 3, SCALE_LIGHT if near else SCALE_MID)
	for finger: int in range(4):
		var length: int = 11 + finger * 2
		var end: Vector2i = palm + Vector2i(direction * length, -7 + finger * 5)
		_segment(image, palm, end, 3, OUTLINE)
		_segment(image, palm + Vector2i(direction, 0), end - Vector2i(direction, 2), 1, SCALE_LIGHT)
		var claw_tip: Vector2i = end + Vector2i(direction * 4, -1 if finger < 2 else 1)
		_segment(image, end, claw_tip, 2, BONE_LIGHT)
	# Two dark membrane wedges retain the webbed anatomy without merging fingers.
	_poly(image, PackedVector2Array([
		Vector2(palm), Vector2(palm + Vector2i(direction * 9, -6)), Vector2(palm + Vector2i(direction * 11, -1))
	]), SCALE_DARK)
	_poly(image, PackedVector2Array([
		Vector2(palm), Vector2(palm + Vector2i(direction * 11, 4)), Vector2(palm + Vector2i(direction * 9, 9))
	]), SCALE_DARK)


func _draw_far_leg(image: Image, hip: Vector2i, foot: Vector2i, stride: int) -> void:
	var knee: Vector2i = Vector2i(hip.x - 11 - stride / 3, 88)
	_segment(image, hip, knee, 14, OUTLINE)
	_segment(image, knee, foot + Vector2i(4, -3), 11, OUTLINE)
	_segment(image, hip, knee, 9, SCALE_DARK)
	_segment(image, knee, foot + Vector2i(4, -3), 7, SCALE_MID)
	_draw_webbed_foot(image, foot, -1, false)


func _draw_front_leg(image: Image, hip: Vector2i, foot: Vector2i, stride: int) -> void:
	var knee: Vector2i = Vector2i(hip.x + 10 + stride / 3, 88)
	_segment(image, hip, knee, 15, OUTLINE)
	_segment(image, knee, foot - Vector2i(3, 3), 12, OUTLINE)
	_segment(image, hip, knee, 10, SCALE_MID)
	_segment(image, knee, foot - Vector2i(3, 3), 8, SCALE_LIGHT)
	_segment(image, hip + Vector2i(2, -2), knee + Vector2i(2, -2), 2, WET_LIGHT)
	_draw_webbed_foot(image, foot, 1, true)


func _draw_webbed_foot(image: Image, ankle: Vector2i, direction: int, near: bool) -> void:
	for toe: int in range(4):
		var end: Vector2i = ankle + Vector2i(direction * (8 + toe * 3), toe - 2)
		_segment(image, ankle, end, 3, OUTLINE)
		_segment(image, ankle, end - Vector2i(direction * 2, 0), 1, SCALE_LIGHT if near else SCALE_MID)
		_segment(image, end, end + Vector2i(direction * 3, 0), 2, BONE_LIGHT)


func _draw_rags(image: Image, hip: Vector2i) -> void:
	_poly(image, _pts([
		hip.x - 16, hip.y - 2, hip.x + 13, hip.y - 3,
		hip.x + 16, hip.y + 5, hip.x - 17, hip.y + 6,
	]), OUTLINE)
	_segment(image, hip + Vector2i(-14, 1), hip + Vector2i(13, 0), 4, RAG_LIGHT)
	var strips: Array[PackedVector2Array] = [
		_pts([hip.x-13,hip.y+4,hip.x-5,hip.y+4,hip.x-8,hip.y+25,hip.x-15,hip.y+20]),
		_pts([hip.x-4,hip.y+4,hip.x+4,hip.y+4,hip.x+2,hip.y+29,hip.x-6,hip.y+23]),
		_pts([hip.x+5,hip.y+3,hip.x+13,hip.y+4,hip.x+11,hip.y+22,hip.x+3,hip.y+18]),
	]
	for index: int in range(strips.size()):
		_poly(image, strips[index], OUTLINE)
		var inner: PackedVector2Array = strips[index]
		# Offset a narrow highlight through the strip so the cloth reads separately from scales.
		_segment(image, Vector2i(inner[0]) + Vector2i(2, 3), Vector2i(inner[2]) + Vector2i(1, -2), 3, RAG_MID if index != 1 else RAG_LIGHT)


func _draw_scale_field(image: Image, start: Vector2i, columns: int, rows: int) -> void:
	for row: int in range(rows):
		for column: int in range(columns - row / 2):
			var center: Vector2i = start + Vector2i(column * 6 + (row % 2) * 3, row * 7)
			_poly(image, _pts([center.x-3,center.y,center.x,center.y-3,center.x+4,center.y,center.x,center.y+4]), SCALE_LIGHT if (row + column) % 3 == 0 else SCALE_MID)


func _draw_ankle_chain(image: Image, waist: Vector2i, ankle: Vector2i, origin: Vector2i) -> void:
	var sag: Vector2i = Vector2i(waist.x - 22, maxi(waist.y + 18, ankle.y - 5))
	_draw_chain_curve(image, waist, sag, ankle, IRON_LIGHT)
	_draw_shackle(image, ankle)
	var loose_end: Vector2i = Vector2i(14 + origin.x / 4, BASELINE_Y + 1)
	_draw_chain_curve(image, ankle, Vector2i(25, BASELINE_Y + 5), loose_end, IRON)


func _draw_shackle(image: Image, center: Vector2i) -> void:
	_ellipse(image, center, 6, 4, OUTLINE)
	_ellipse(image, center, 4, 2, IRON_LIGHT)
	_ellipse(image, center, 2, 1, CLEAR)


func _draw_foreground_chain(image: Image, ankle: Vector2i, origin: Vector2i) -> void:
	# The foreground pass prevents the restraint from disappearing behind the
	# long forearm/rags while preserving a physically connected ankle origin.
	_draw_shackle(image, ankle + Vector2i(0, -3))
	var finish: Vector2i = Vector2i(12 + origin.x / 4, BASELINE_Y + 1)
	_draw_chain_curve(
		image,
		ankle + Vector2i(-3, -2),
		Vector2i(25 + origin.x / 5, BASELINE_Y + 5),
		finish,
		IRON_LIGHT
	)


func _draw_chain_curve(image: Image, start: Vector2i, control: Vector2i, finish: Vector2i, color: Color) -> void:
	for index: int in range(16):
		var t: float = float(index) / 15.0
		var inverse: float = 1.0 - t
		var point: Vector2i = Vector2i(
			roundi(inverse * inverse * start.x + 2.0 * inverse * t * control.x + t * t * finish.x),
			roundi(inverse * inverse * start.y + 2.0 * inverse * t * control.y + t * t * finish.y)
		)
		_ellipse(image, point, 3 if index % 2 == 0 else 2, 2 if index % 2 == 0 else 3, OUTLINE)
		_ellipse(image, point, 1, 1, color)


func _draw_wet_details(image: Image, origin: Vector2i) -> void:
	for point: Vector2i in [Vector2i(44, 50), Vector2i(51, 42), Vector2i(58, 56), Vector2i(48, 66), Vector2i(68, 78)]:
		_pixel(image, point.x + origin.x, point.y + origin.y, WET_LIGHT)
	for drop: Vector2i in [Vector2i(80, 53), Vector2i(39, 68), Vector2i(60, 82)]:
		_segment(image, drop + origin, drop + origin + Vector2i(0, 3), 1, SOUL)


func _draw_death(image: Image, frame: int) -> void:
	var alpha: float = 1.0 if frame < 4 else 0.68 if frame == 4 else 0.34
	var fall: int = mini(frame, 3) * 4
	var base_y: int = 83 + fall
	var skull: Vector2i = Vector2i(91, base_y - 6)
	# Collapsed body retains the long skull, fin ridge, claws, rags and chain.
	_poly(image, _pts([28,base_y-18,54,base_y-26,78,base_y-18,91,base_y-3,76,base_y+8,42,base_y+7,24,base_y]), _with_alpha(OUTLINE, alpha))
	_poly(image, _pts([32,base_y-16,55,base_y-22,74,base_y-15,85,base_y-4,73,base_y+4,43,base_y+3,29,base_y-1]), _with_alpha(SCALE_DARK, alpha))
	for fin: int in range(6):
		var root: Vector2i = Vector2i(37 + fin * 7, base_y - 17 - (fin % 2) * 2)
		_poly(image, PackedVector2Array([Vector2(root.x-5,root.y+3),Vector2(root.x-2,root.y-14-fin%3*2),Vector2(root.x+6,root.y+3)]), _with_alpha(SCALE_MID, alpha))
	# Reuse readable skull anatomy in the fallen orientation.
	_draw_skull_alpha(image, skull, alpha)
	var left_hand: Vector2i = Vector2i(25, BASELINE_Y - 2)
	var right_hand: Vector2i = Vector2i(106, BASELINE_Y - 1)
	_segment(image, Vector2i(49, base_y - 9), left_hand, 10, _with_alpha(OUTLINE, alpha))
	_segment(image, Vector2i(49, base_y - 9), left_hand, 6, _with_alpha(SCALE_MID, alpha))
	_segment(image, Vector2i(70, base_y - 8), right_hand, 10, _with_alpha(OUTLINE, alpha))
	_segment(image, Vector2i(70, base_y - 8), right_hand, 6, _with_alpha(SCALE_LIGHT, alpha))
	_draw_webbed_claw_alpha(image, left_hand, -1, alpha)
	_draw_webbed_claw_alpha(image, right_hand, 1, alpha)
	_draw_chain_curve(image, Vector2i(51, base_y), Vector2i(38, BASELINE_Y + 4), Vector2i(14, BASELINE_Y + 1), _with_alpha(IRON_LIGHT, alpha))
	for strip: int in range(3):
		_poly(image, _pts([48+strip*7,base_y-2,53+strip*7,base_y-3,52+strip*8,BASELINE_Y,46+strip*7,BASELINE_Y-1]), _with_alpha(RAG_MID, alpha))
	if frame >= 3:
		for mote: int in range((frame - 2) * 10):
			var x: int = 20 + (mote * 17) % 95
			var y: int = 45 + (mote * 11) % 58
			_ellipse(image, Vector2i(x, y), 1 + mote % 2, 1, _with_alpha(SOUL, alpha))


func _draw_skull_alpha(image: Image, center: Vector2i, alpha: float) -> void:
	_poly(image, _pts([center.x-15,center.y-8,center.x-5,center.y-13,center.x+11,center.y-9,center.x+26,center.y,center.x+18,center.y+8,center.x-6,center.y+7]), _with_alpha(OUTLINE, alpha))
	_poly(image, _pts([center.x-11,center.y-6,center.x-4,center.y-10,center.x+9,center.y-7,center.x+21,center.y,center.x+15,center.y+4,center.x-5,center.y+3]), _with_alpha(BONE_MID, alpha))
	_ellipse(image, center + Vector2i(-3, -3), 4, 4, _with_alpha(SOUL, alpha))
	for tooth: int in range(6):
		var x: int = center.x + tooth * 4
		_poly(image, _pts([x,center.y+3,x+2,center.y+8,x+4,center.y+3]), _with_alpha(BONE_LIGHT, alpha))


func _draw_webbed_claw_alpha(image: Image, palm: Vector2i, direction: int, alpha: float) -> void:
	for finger: int in range(4):
		var end: Vector2i = palm + Vector2i(direction * (9 + finger * 2), -4 + finger * 3)
		_segment(image, palm, end, 2, _with_alpha(SCALE_LIGHT, alpha))
		_segment(image, end, end + Vector2i(direction * 3, 0), 2, _with_alpha(BONE_LIGHT, alpha))


func _write_reference_sheet() -> void:
	var directory: String = "%s/reference" % ROOT
	var output: String = "%s/mirefin_raider_runtime_reference.png" % directory
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(directory)) or not FileAccess.file_exists(output):
		push_error("MIRE FIN REPLICATION: refusing to create replacement reference sheet: %s" % output)
		return
	var sheet: Image = Image.create(FRAME_SIZE.x * 3, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	sheet.fill(CLEAR)
	sheet.blit_rect(_draw_frame("idle", 0, 4), Rect2i(Vector2i.ZERO, FRAME_SIZE), Vector2i.ZERO)
	sheet.blit_rect(_draw_frame("claw_swipe_active", 0, 2), Rect2i(Vector2i.ZERO, FRAME_SIZE), Vector2i(FRAME_SIZE.x, 0))
	sheet.blit_rect(_draw_frame("death", 3, 6), Rect2i(Vector2i.ZERO, FRAME_SIZE), Vector2i(FRAME_SIZE.x * 2, 0))
	sheet.save_png(ProjectSettings.globalize_path(output))


func _pts(values: Array[int]) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(0, values.size(), 2):
		points.append(Vector2(values[index], values[index + 1]))
	return points


func _poly(image: Image, points: PackedVector2Array, color: Color) -> void:
	if points.size() < 3:
		return
	var min_x: int = image.get_width() - 1
	var max_x: int = 0
	var min_y: int = image.get_height() - 1
	var max_y: int = 0
	for point: Vector2 in points:
		min_x = mini(min_x, floori(point.x))
		max_x = maxi(max_x, ceili(point.x))
		min_y = mini(min_y, floori(point.y))
		max_y = maxi(max_y, ceili(point.y))
	for y: int in range(clampi(min_y, 0, image.get_height() - 1), clampi(max_y, 0, image.get_height() - 1) + 1):
		for x: int in range(clampi(min_x, 0, image.get_width() - 1), clampi(max_x, 0, image.get_width() - 1) + 1):
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), points):
				image.set_pixel(x, y, color)


func _ellipse(image: Image, center: Vector2i, radius_x: int, radius_y: int, color: Color) -> void:
	for y: int in range(center.y - radius_y, center.y + radius_y + 1):
		for x: int in range(center.x - radius_x, center.x + radius_x + 1):
			if radius_x > 0 and radius_y > 0 and pow(float(x - center.x) / radius_x, 2) + pow(float(y - center.y) / radius_y, 2) <= 1.0:
				_pixel(image, x, y, color)


func _segment(image: Image, start: Vector2i, finish: Vector2i, thickness: int, color: Color) -> void:
	var steps: int = maxi(abs(finish.x - start.x), abs(finish.y - start.y))
	for index: int in range(steps + 1):
		var t: float = float(index) / float(maxi(1, steps))
		var point: Vector2i = Vector2i(roundi(lerpf(start.x, finish.x, t)), roundi(lerpf(start.y, finish.y, t)))
		_ellipse(image, point, maxi(1, thickness / 2), maxi(1, thickness / 2), color)


func _pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
		image.set_pixel(x, y, color)


func _with_alpha(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, color.a * alpha)
