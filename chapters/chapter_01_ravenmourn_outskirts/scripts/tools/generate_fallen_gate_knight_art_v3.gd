extends SceneTree

## Deterministic 96x96 production-art generator for Fallen Gate Knight only.
##
## The Boss keeps the existing gameplay animation names and frame counts, while
## the drawing is rebuilt around a shaped tower shield, complete greatsword,
## layered plate, a permanent four-step shield condition and a genuinely
## redrawn two-handed Phase 2 silhouette.

const ROOT: String = "res://chapters/chapter_01_ravenmourn_outskirts/assets/boss/fallen_gate_knight"
const SPRITES: String = ROOT + "/sprites"
const EFFECTS: String = ROOT + "/effects"
const CONCEPTS: String = ROOT + "/concept_art"
const SIZE: int = 96
const CLEAR: Color = Color(0.0, 0.0, 0.0, 0.0)
const OUTLINE: Color = Color("070a0f")
const DEEP_IRON: Color = Color("111821")
const BLACK_STEEL: Color = Color("1b2630")
const OLD_IRON: Color = Color("33424d")
const OLD_SILVER: Color = Color("647681")
const EDGE_STEEL: Color = Color("aab9be")
const PALE_STEEL: Color = Color("d7e1e2")
const RUST: Color = Color("754334")
const RUST_LIT: Color = Color("a75c42")
const DRIED_BLOOD: Color = Color("572934")
const CAPE_LIT: Color = Color("7d3945")
const LEATHER: Color = Color("422f2a")
const LEATHER_LIT: Color = Color("77503b")
const OLD_GOLD: Color = Color("8f713d")
const GOLD_LIT: Color = Color("c5a05c")
const SOUL_BLUE: Color = Color("4b8fa9")
const SOUL_LIT: Color = Color("a9dce3")
const BONE: Color = Color("9b9a8c")

const ANIMATIONS: Dictionary = {
	# Existing runtime families. Counts must not change: gameplay active frames
	# and duration contracts depend on them.
	&"charge_thrust": 5,
	&"combo_slash_1": 5,
	&"combo_slash_2": 5,
	&"death": 7,
	&"heavy_overhead": 6,
	&"hurt_shielded": 3,
	&"hurt_unshielded": 3,
	&"idle_shielded": 4,
	&"idle_unshielded": 4,
	&"jump_smash": 6,
	&"phase_transition": 5,
	&"shield_bash": 5,
	&"shield_block": 4,
	&"shield_break": 5,
	&"shockwave_strike": 6,
	&"sword_slash": 5,
	&"turn_shielded": 3,
	&"turn_unshielded": 3,
	&"walk_shielded": 6,
	&"walk_unshielded": 6,
	# Production-reference families requested by the art contract. The current
	# AI remains bound to the stable runtime families above.
	&"dormant": 4,
	&"intro": 6,
	&"approach_shielded": 6,
	&"shield_hit": 3,
	&"shield_bash_windup": 3,
	&"shield_bash_active": 2,
	&"shield_bash_recovery": 3,
	&"sword_slash_windup": 3,
	&"sword_slash_active": 2,
	&"sword_slash_recovery": 3,
	&"thrust_windup": 3,
	&"thrust_active": 2,
	&"thrust_recovery": 3,
	&"heavy_overhead_windup": 3,
	&"heavy_overhead_active": 2,
	&"heavy_overhead_recovery": 3,
	&"light_hit": 2,
	&"hurt": 3,
	&"death_start": 3,
	&"combo_slash": 6,
	&"stagger": 4,
}

const PHASE_ONE_ANIMATIONS: Array[StringName] = [
	&"dormant", &"intro", &"idle_shielded", &"walk_shielded",
	&"approach_shielded", &"turn_shielded", &"shield_hit",
	&"shield_block", &"shield_bash", &"shield_bash_windup",
	&"shield_bash_active", &"shield_bash_recovery", &"sword_slash",
	&"sword_slash_windup", &"sword_slash_active", &"sword_slash_recovery",
	&"heavy_overhead", &"heavy_overhead_windup", &"heavy_overhead_active",
	&"heavy_overhead_recovery", &"shield_break", &"hurt_shielded",
	&"light_hit", &"death_start",
]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SPRITES))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EFFECTS))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CONCEPTS))
	var total: int = 0
	for animation_variant: Variant in ANIMATIONS.keys():
		var animation: StringName = animation_variant as StringName
		var count: int = int(ANIMATIONS[animation])
		var directory: String = SPRITES + "/" + String(animation)
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		for frame: int in range(count):
			var image: Image = _draw_frame(animation, frame, count)
			var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
			if image.save_png(ProjectSettings.globalize_path(path)) != OK:
				push_error("Cannot save Fallen Gate Knight frame: %s" % path)
				quit(1)
				return
			total += 1
	_write_shield_condition_art()
	_write_break_effects()
	_write_concept_derivatives()
	_write_runtime_preview()
	print("FALLEN_GATE_KNIGHT_ART_V3: PASS animations=%d frames=%d" % [ANIMATIONS.size(), total])
	quit(0)


func _draw_frame(animation: StringName, frame: int, count: int) -> Image:
	var image: Image = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	if animation == &"death":
		_draw_death(image, frame)
		return image
	var phase_one: bool = animation in PHASE_ONE_ANIMATIONS
	if animation == &"phase_transition":
		phase_one = frame < 2
	_draw_knight(image, animation, frame, count, phase_one)
	return image


func _draw_knight(
	image: Image, animation: StringName, frame: int, count: int, phase_one: bool
) -> void:
	var x: int = 50 if phase_one else 45
	var y: int = 7
	var stride: int = 0
	var bob: int = 0
	if animation in [&"walk_shielded", &"approach_shielded", &"walk_unshielded"]:
		var strides: Array[int] = [-6, -3, 1, 6, 3, -1]
		var bobs: Array[int] = [0, -1, 0, 1, -1, 0]
		stride = strides[frame]
		bob = bobs[frame]
	if animation in [&"idle_shielded", &"idle_unshielded", &"dormant"]:
		var idle_bob: Array[int] = [0, -1, -1, 0]
		bob = idle_bob[frame]
	y += bob
	if animation in [&"hurt_shielded", &"hurt_unshielded", &"hurt", &"stagger", &"light_hit"]:
		x -= mini(frame + 1, 4) * 2
	if animation == &"shield_bash":
		var bash_x: Array[int] = [0, -2, 4, 9, 3]
		x += bash_x[frame]
	if animation == &"charge_thrust":
		var charge_x: Array[int] = [0, -3, 4, 10, 6]
		x += charge_x[frame]
	if animation == &"jump_smash":
		var jump_y: Array[int] = [0, -9, -16, -9, 5, 1]
		var jump_x: Array[int] = [0, 1, 4, 7, 9, 3]
		y += jump_y[frame]
		x += jump_x[frame]

	_draw_cape(image, Vector2i(x, y), phase_one, animation, frame)
	_draw_legs(image, Vector2i(x, y), stride, phase_one)
	_draw_waist_and_tassets(image, Vector2i(x, y), phase_one)
	_draw_cuirass(image, Vector2i(x, y), phase_one)
	_draw_pauldrons(image, Vector2i(x, y), phase_one)
	_draw_helmet(image, Vector2i(x, y), phase_one, animation, frame)

	var sword_pose: Dictionary = _get_sword_pose(animation, frame, x, y, phase_one)
	var grip: Vector2i = sword_pose[&"grip"] as Vector2i
	var second_grip: Vector2i = sword_pose[&"second_grip"] as Vector2i
	var sword_tip: Vector2i = sword_pose[&"tip"] as Vector2i
	if phase_one:
		_draw_arm(image, Vector2i(x + 14, y + 27), grip, false)
	else:
		_draw_exposed_curse_arm(image, Vector2i(x - 14, y + 27), second_grip)
		_draw_arm(image, Vector2i(x + 14, y + 27), grip, true)
	_draw_greatsword(image, grip, sword_tip, not phase_one)

	if phase_one:
		var shield_offset: Vector2i = _get_shield_offset(animation, frame)
		var draw_shield: bool = animation != &"shield_break" or frame < 4
		if draw_shield:
			_draw_tower_shield(image, Vector2i(x - 23, y + 47) + shield_offset, animation == &"shield_break", frame)
		_draw_shield_arm(image, Vector2i(x - 13, y + 28), Vector2i(x - 19, y + 42) + shield_offset)

	_draw_animation_fx(image, animation, frame, count, Vector2i(x, y), phase_one)


func _draw_cape(
	image: Image, origin: Vector2i, phase_one: bool, animation: StringName, frame: int
) -> void:
	var x: int = origin.x
	var y: int = origin.y
	var drag: int = 2 if animation.begins_with("walk") or animation in [&"charge_thrust", &"jump_smash"] else 0
	if phase_one:
		_poly(image, _points([
			x - 16, y + 22, x - 28 - drag, y + 36, x - 25 - drag, y + 69,
			x - 18 - drag, y + 63, x - 13, y + 75, x - 7, y + 59,
		]), OUTLINE)
		_poly(image, _points([
			x - 15, y + 24, x - 24 - drag, y + 37, x - 22 - drag, y + 64,
			x - 17 - drag, y + 59, x - 13, y + 69, x - 9, y + 56,
		]), DRIED_BLOOD)
		_draw_segment(image, Vector2i(x - 15, y + 25), Vector2i(x - 21 - drag, y + 54), 2, CAPE_LIT)
	else:
		_poly(image, _points([
			x - 10, y + 19, x - 30 - drag, y + 26, x - 37 - drag, y + 43,
			x - 29 - drag, y + 40, x - 35 - drag, y + 60, x - 23 - drag, y + 55,
			x - 20 - drag, y + 73, x - 10, y + 59, x - 4, y + 47,
		]), OUTLINE)
		_poly(image, _points([
			x - 9, y + 22, x - 27 - drag, y + 28, x - 32 - drag, y + 40,
			x - 25 - drag, y + 38, x - 30 - drag, y + 56, x - 20 - drag, y + 51,
			x - 17 - drag, y + 66, x - 9, y + 55, x - 5, y + 44,
		]), DRIED_BLOOD)
		_draw_segment(image, Vector2i(x - 8, y + 24), Vector2i(x - 27 - drag, y + 36), 2, CAPE_LIT)


func _draw_legs(image: Image, origin: Vector2i, stride: int, phase_one: bool) -> void:
	var x: int = origin.x
	var y: int = origin.y
	var left_knee: Vector2i = Vector2i(x - 9, y + 58)
	var right_knee: Vector2i = Vector2i(x + 8, y + 58)
	var left_foot: Vector2i = Vector2i(x - 13 - stride, y + 84)
	var right_foot: Vector2i = Vector2i(x + 14 + stride, y + 84)
	_draw_segment(image, left_knee, left_foot, 13, OUTLINE)
	_draw_segment(image, right_knee, right_foot, 13, OUTLINE)
	_draw_segment(image, left_knee, left_foot, 8, OLD_IRON)
	_draw_segment(image, right_knee, right_foot, 8, OLD_SILVER)
	for plate_index: int in range(3):
		var left_y: int = y + 63 + plate_index * 7
		var right_y: int = left_y
		_draw_segment(image, Vector2i(x - 15 - stride / 2, left_y), Vector2i(x - 6 - stride / 2, left_y - 1), 2, EDGE_STEEL)
		_draw_segment(image, Vector2i(x + 6 + stride / 2, right_y - 1), Vector2i(x + 16 + stride / 2, right_y), 2, OLD_IRON)
	_poly(image, _points([left_foot.x - 8, left_foot.y - 1, left_foot.x + 3, left_foot.y - 3, left_foot.x + 9, left_foot.y + 3, left_foot.x - 8, left_foot.y + 3]), OUTLINE)
	_poly(image, _points([right_foot.x - 3, right_foot.y - 3, right_foot.x + 9, right_foot.y - 1, right_foot.x + 10, right_foot.y + 3, right_foot.x - 6, right_foot.y + 3]), OUTLINE)
	if not phase_one:
		_draw_segment(image, Vector2i(x - 12, y + 63), Vector2i(x - 10, y + 75), 1, SOUL_BLUE)


func _draw_waist_and_tassets(image: Image, origin: Vector2i, phase_one: bool) -> void:
	var x: int = origin.x
	var y: int = origin.y
	_draw_segment(image, Vector2i(x - 16, y + 48), Vector2i(x + 16, y + 48), 6, OUTLINE)
	_draw_segment(image, Vector2i(x - 14, y + 48), Vector2i(x + 14, y + 48), 3, LEATHER_LIT)
	for stud: int in range(7):
		_pixel(image, x - 12 + stud * 4, y + 48, GOLD_LIT)
	_poly(image, _points([x - 15, y + 51, x - 6, y + 49, x - 7, y + 68, x - 15, y + 65, x - 19, y + 58]), OUTLINE)
	_poly(image, _points([x + 6, y + 49, x + 15, y + 51, x + 19, y + 58, x + 15, y + 65, x + 7, y + 68]), OUTLINE)
	_poly(image, _points([x - 12, y + 52, x - 7, y + 51, x - 8, y + 64, x - 14, y + 62, x - 16, y + 57]), OLD_IRON)
	_poly(image, _points([x + 7, y + 51, x + 12, y + 52, x + 16, y + 57, x + 14, y + 62, x + 8, y + 64]), OLD_SILVER)
	_poly(image, _points([x - 6, y + 51, x + 7, y + 51, x + 5, y + 73, x, y + 67, x - 4, y + 75]), DRIED_BLOOD)
	if not phase_one:
		_poly(image, _points([x - 4, y + 52, x + 6, y + 51, x + 3, y + 67, x - 1, y + 63]), CAPE_LIT)


func _draw_cuirass(image: Image, origin: Vector2i, phase_one: bool) -> void:
	var x: int = origin.x
	var y: int = origin.y
	_poly(image, _points([
		x - 20, y + 24, x - 13, y + 15, x + 13, y + 15, x + 21, y + 26,
		x + 17, y + 49, x + 8, y + 56, x - 9, y + 55, x - 18, y + 47,
	]), OUTLINE)
	_poly(image, _points([
		x - 16, y + 25, x - 11, y + 19, x + 11, y + 19, x + 17, y + 27,
		x + 13, y + 45, x + 6, y + 51, x - 7, y + 50, x - 14, y + 44,
	]), BLACK_STEEL)
	_poly(image, _points([x - 10, y + 20, x + 9, y + 20, x + 13, y + 35, x + 7, y + 44, x - 7, y + 44, x - 12, y + 34]), OLD_IRON)
	for rib: int in range(4):
		_draw_segment(image, Vector2i(x - 10, y + 24 + rib * 5), Vector2i(x + 10, y + 23 + rib * 5), 2, EDGE_STEEL if rib == 0 else RUST)
	# Crowned raven heraldry: wings, head and tail remain legible at 96px.
	_draw_segment(image, Vector2i(x, y + 30), Vector2i(x - 8, y + 26), 2, OLD_SILVER)
	_draw_segment(image, Vector2i(x, y + 30), Vector2i(x + 8, y + 26), 2, OLD_SILVER)
	_draw_segment(image, Vector2i(x, y + 29), Vector2i(x, y + 39), 2, OLD_GOLD)
	_pixel(image, x + 1, y + 27, GOLD_LIT)
	_draw_segment(image, Vector2i(x - 4, y + 20), Vector2i(x + 4, y + 20), 1, OLD_GOLD)
	if not phase_one:
		_draw_segment(image, Vector2i(x - 8, y + 22), Vector2i(x - 1, y + 34), 2, SOUL_BLUE)
		_draw_segment(image, Vector2i(x - 1, y + 34), Vector2i(x + 7, y + 43), 1, SOUL_LIT)
		_pixel(image, x + 8, y + 43, SOUL_BLUE)


func _draw_pauldrons(image: Image, origin: Vector2i, phase_one: bool) -> void:
	var x: int = origin.x
	var y: int = origin.y
	_poly(image, _points([x - 27, y + 26, x - 22, y + 12, x - 9, y + 14, x - 11, y + 31]), OUTLINE)
	_poly(image, _points([x + 27, y + 26, x + 22, y + 12, x + 9, y + 14, x + 11, y + 31]), OUTLINE)
	if phase_one:
		_poly(image, _points([x - 23, y + 24, x - 20, y + 16, x - 11, y + 17, x - 13, y + 27]), OLD_SILVER)
	else:
		# Permanently shattered left shoulder: three separated plates and exposed fire.
		_poly(image, _points([x - 24, y + 21, x - 20, y + 14, x - 15, y + 16, x - 18, y + 24]), OLD_IRON)
		_poly(image, _points([x - 14, y + 18, x - 9, y + 15, x - 11, y + 24]), OLD_SILVER)
		_draw_segment(image, Vector2i(x - 21, y + 20), Vector2i(x - 11, y + 27), 2, SOUL_LIT)
	_poly(image, _points([x + 23, y + 24, x + 20, y + 16, x + 11, y + 17, x + 13, y + 27]), OLD_IRON)
	_draw_segment(image, Vector2i(x + 21, y + 17), Vector2i(x + 14, y + 25), 2, EDGE_STEEL)


func _draw_helmet(
	image: Image, origin: Vector2i, phase_one: bool, animation: StringName, frame: int
) -> void:
	var x: int = origin.x
	var y: int = origin.y
	var tilt: int = -2 if animation in [&"charge_thrust", &"combo_slash", &"combo_slash_1"] else 0
	_poly(image, _points([
		x - 13, y + 4 + tilt, x - 7, y - 3 + tilt, x + 7, y - 2 + tilt,
		x + 14, y + 5 + tilt, x + 11, y + 20 + tilt, x + 4, y + 24 + tilt,
		x - 8, y + 21 + tilt, x - 15, y + 12 + tilt,
	]), OUTLINE)
	_poly(image, _points([
		x - 10, y + 5 + tilt, x - 5, y + 1 + tilt, x + 5, y + 1 + tilt,
		x + 10, y + 6 + tilt, x + 8, y + 16 + tilt, x + 3, y + 20 + tilt,
		x - 6, y + 18 + tilt, x - 11, y + 11 + tilt,
	]), OLD_IRON)
	_poly(image, _points([x - 9, y + 7 + tilt, x + 10, y + 6 + tilt, x + 7, y + 13 + tilt, x - 8, y + 14 + tilt]), DEEP_IRON)
	_draw_segment(image, Vector2i(x - 6, y + 10 + tilt), Vector2i(x + 7, y + 9 + tilt), 2, SOUL_BLUE)
	_pixel(image, x + 6, y + 9 + tilt, SOUL_LIT)
	# Crowned gate-spire silhouette.
	_poly(image, _points([x - 7, y + 1 + tilt, x - 11, y - 11 + tilt, x - 5, y - 6 + tilt, x - 2, y + 1 + tilt]), OUTLINE)
	_poly(image, _points([x - 1, y - 1 + tilt, x, y - 15 + tilt, x + 4, y - 5 + tilt, x + 3, y + 1 + tilt]), OUTLINE)
	_poly(image, _points([x + 5, y + 1 + tilt, x + 10, y - 12 + tilt, x + 11, y - 3 + tilt, x + 8, y + 3 + tilt]), OUTLINE)
	_draw_segment(image, Vector2i(x, y - 12 + tilt), Vector2i(x, y - 1 + tilt), 2, OLD_SILVER)
	if not phase_one:
		_draw_segment(image, Vector2i(x - 5, y + 2 + tilt), Vector2i(x + 2, y + 12 + tilt), 1, SOUL_LIT)
		if frame % 2 == 1:
			_pixel(image, x + 11, y + 8 + tilt, SOUL_BLUE)


func _draw_arm(image: Image, shoulder: Vector2i, hand: Vector2i, aggressive: bool) -> void:
	_draw_segment(image, shoulder, hand, 13, OUTLINE)
	_draw_segment(image, shoulder, hand, 8, OLD_IRON if aggressive else OLD_SILVER)
	var midpoint: Vector2i = Vector2i((shoulder + hand) / 2)
	_draw_segment(image, midpoint - Vector2i(3, 2), midpoint + Vector2i(4, 1), 2, EDGE_STEEL)
	_circle(image, hand, 5, OUTLINE)
	_circle(image, hand, 3, OLD_SILVER)


func _draw_shield_arm(image: Image, shoulder: Vector2i, hand: Vector2i) -> void:
	_draw_segment(image, shoulder, hand, 12, OUTLINE)
	_draw_segment(image, shoulder, hand, 7, OLD_IRON)
	_circle(image, hand, 4, OUTLINE)


func _draw_exposed_curse_arm(image: Image, shoulder: Vector2i, hand: Vector2i) -> void:
	_draw_segment(image, shoulder, hand, 12, OUTLINE)
	_draw_segment(image, shoulder, hand, 7, BONE)
	var elbow: Vector2i = Vector2i((shoulder + hand) / 2)
	_draw_segment(image, shoulder + Vector2i(-2, 1), elbow, 3, OLD_IRON)
	_draw_segment(image, elbow, hand, 2, SOUL_BLUE)
	_draw_segment(image, shoulder, elbow + Vector2i(2, 1), 1, SOUL_LIT)
	_circle(image, hand, 5, OUTLINE)
	_circle(image, hand, 3, BONE)


func _get_sword_pose(
	animation: StringName, frame: int, x: int, y: int, phase_one: bool
) -> Dictionary:
	var grip: Vector2i = Vector2i(x + 18, y + 43)
	var second_grip: Vector2i = Vector2i(x - 3, y + 37)
	var tip: Vector2i = Vector2i(x + 40, y + 78)
	if phase_one:
		second_grip = grip
	match animation:
		&"sword_slash", &"combo_slash_1", &"sword_slash_active":
			var grips: Array[Vector2i] = [Vector2i(x + 10, y + 31), Vector2i(x + 7, y + 18), Vector2i(x + 8, y + 37), Vector2i(x + 10, y + 51), Vector2i(x + 14, y + 45)]
			var tips: Array[Vector2i] = [Vector2i(x + 17, y - 14), Vector2i(x + 40, y - 8), Vector2i(94, y + 32), Vector2i(93, y + 76), Vector2i(91, y + 81)]
			var index: int = mini(frame, grips.size() - 1)
			grip = grips[index]
			tip = tips[index]
		&"combo_slash_2":
			var combo_grips: Array[Vector2i] = [Vector2i(x + 18, y + 48), Vector2i(x + 24, y + 54), Vector2i(x + 25, y + 39), Vector2i(x + 12, y + 19), Vector2i(x + 17, y + 43)]
			var combo_tips: Array[Vector2i] = [Vector2i(x + 42, y + 80), Vector2i(91, y + 75), Vector2i(94, y + 32), Vector2i(x + 39, y - 8), Vector2i(x + 39, y + 76)]
			grip = combo_grips[frame]
			tip = combo_tips[frame]
		&"combo_slash":
			var combo6_tips: Array[Vector2i] = [Vector2i(x + 36, y + 77), Vector2i(x + 19, y - 10), Vector2i(93, y + 30), Vector2i(91, y + 71), Vector2i(x + 26, y - 10), Vector2i(x + 39, y + 77)]
			grip = Vector2i(x + 15 + mini(frame, 3) * 3, y + 35 + (frame % 3) * 4)
			tip = combo6_tips[frame]
		&"heavy_overhead", &"heavy_overhead_active":
			var heavy_grips: Array[Vector2i] = [Vector2i(x + 10, y + 29), Vector2i(x + 5, y + 14), Vector2i(x, y + 7), Vector2i(x + 7, y + 33), Vector2i(x + 8, y + 53), Vector2i(x + 14, y + 46)]
			var heavy_tips: Array[Vector2i] = [Vector2i(x + 15, y - 20), Vector2i(x + 10, y - 29), Vector2i(x + 7, y - 32), Vector2i(93, y + 19), Vector2i(93, y + 89), Vector2i(91, y + 82)]
			var heavy_index: int = mini(frame, heavy_grips.size() - 1)
			grip = heavy_grips[heavy_index]
			tip = heavy_tips[heavy_index]
		&"charge_thrust", &"thrust_active":
			var thrust_tips: Array[Vector2i] = [Vector2i(72, y + 37), Vector2i(76, y + 36), Vector2i(91, y + 35), Vector2i(95, y + 34), Vector2i(88, y + 39)]
			var thrust_index: int = mini(frame, thrust_tips.size() - 1)
			grip = Vector2i(x + 3 + mini(frame, 3) * 2, y + 39)
			second_grip = grip - Vector2i(9, 1)
			tip = thrust_tips[thrust_index]
		&"jump_smash":
			var jump_grips: Array[Vector2i] = [Vector2i(x + 13, y + 25), Vector2i(x + 10, y + 15), Vector2i(x + 7, y + 10), Vector2i(x + 20, y + 24), Vector2i(x + 25, y + 59), Vector2i(x + 17, y + 44)]
			var jump_tips: Array[Vector2i] = [Vector2i(x + 25, y - 20), Vector2i(x + 19, y - 29), Vector2i(x + 16, y - 33), Vector2i(81, y - 2), Vector2i(82, y + 87), Vector2i(x + 39, y + 79)]
			grip = jump_grips[frame]
			tip = jump_tips[frame]
		&"shockwave_strike":
			var shock_grips: Array[Vector2i] = [Vector2i(x + 12, y + 28), Vector2i(x + 7, y + 15), Vector2i(x + 4, y + 10), Vector2i(x + 19, y + 32), Vector2i(x + 24, y + 61), Vector2i(x + 17, y + 45)]
			var shock_tips: Array[Vector2i] = [Vector2i(x + 24, y - 15), Vector2i(x + 16, y - 24), Vector2i(x + 12, y - 27), Vector2i(83, y + 22), Vector2i(83, y + 87), Vector2i(x + 39, y + 80)]
			grip = shock_grips[frame]
			tip = shock_tips[frame]
		&"sword_slash_windup", &"heavy_overhead_windup", &"thrust_windup":
			grip = Vector2i(x + 9 - frame * 2, y + 28 - frame * 5)
			tip = Vector2i(x + 18 + frame * 5, y - 11 - frame * 4)
		&"sword_slash_recovery", &"heavy_overhead_recovery", &"thrust_recovery":
			grip = Vector2i(x + 24 - frame * 3, y + 55 - frame * 4)
			tip = Vector2i(88 - frame * 10, y + 73)
	if not phase_one and second_grip == Vector2i(x - 3, y + 37):
		second_grip = grip - Vector2i(8, 4)
	return {&"grip": grip, &"second_grip": second_grip, &"tip": tip}


func _get_shield_offset(animation: StringName, frame: int) -> Vector2i:
	if animation == &"shield_bash":
		var bash: Array[Vector2i] = [Vector2i.ZERO, Vector2i(3, -2), Vector2i(9, -1), Vector2i(13, 0), Vector2i(5, 0)]
		return bash[frame]
	if animation == &"shield_block":
		var block: Array[Vector2i] = [Vector2i.ZERO, Vector2i(4, -4), Vector2i(7, -3), Vector2i(4, -1)]
		return block[frame]
	if animation == &"turn_shielded":
		var turn: Array[Vector2i] = [Vector2i.ZERO, Vector2i(7, 0), Vector2i(2, 0)]
		return turn[frame]
	if animation == &"shield_bash_active":
		return Vector2i(10 + frame * 3, -1)
	if animation == &"shield_bash_windup":
		return Vector2i(-frame * 2, -frame)
	if animation == &"shield_hit":
		return Vector2i(-frame * 2, 0)
	return Vector2i.ZERO


func _draw_tower_shield(
	image: Image, center: Vector2i, breaking: bool, break_frame: int
) -> void:
	# Peaked crown, concave shoulders and tapered gate-spike; no rectangular slab.
	var outline_points: PackedVector2Array = _points([
		center.x, center.y - 39, center.x - 19, center.y - 31,
		center.x - 21, center.y - 23, center.x - 18, center.y + 25,
		center.x - 9, center.y + 34, center.x, center.y + 40,
		center.x + 9, center.y + 34, center.x + 18, center.y + 25,
		center.x + 21, center.y - 23, center.x + 19, center.y - 31,
	])
	_poly(image, outline_points, OUTLINE)
	_poly(image, _points([
		center.x, center.y - 35, center.x - 16, center.y - 29,
		center.x - 18, center.y - 21, center.x - 15, center.y + 22,
		center.x - 7, center.y + 31, center.x, center.y + 36,
		center.x + 7, center.y + 31, center.x + 15, center.y + 22,
		center.x + 18, center.y - 21, center.x + 16, center.y - 29,
	]), DEEP_IRON)
	# Thick beveled edge and structural ribs.
	_draw_segment(image, Vector2i(center.x, center.y - 36), Vector2i(center.x - 16, center.y - 28), 3, EDGE_STEEL)
	_draw_segment(image, Vector2i(center.x - 16, center.y - 27), Vector2i(center.x - 13, center.y + 21), 3, OLD_SILVER)
	_draw_segment(image, Vector2i(center.x + 16, center.y - 27), Vector2i(center.x + 13, center.y + 21), 3, OLD_IRON)
	_draw_segment(image, Vector2i(center.x - 12, center.y - 20), Vector2i(center.x + 13, center.y - 20), 2, RUST)
	# Crowned raven crest.
	_circle(image, center - Vector2i(0, 3), 7, OUTLINE)
	_circle(image, center - Vector2i(0, 3), 4, OLD_GOLD)
	_draw_segment(image, center - Vector2i(0, 2), center + Vector2i(-12, -11), 3, OLD_SILVER)
	_draw_segment(image, center - Vector2i(0, 2), center + Vector2i(12, -11), 3, OLD_SILVER)
	_draw_segment(image, center + Vector2i(0, 1), center + Vector2i(0, 15), 3, OLD_IRON)
	_draw_segment(image, center + Vector2i(-4, -13), center + Vector2i(4, -13), 2, GOLD_LIT)
	for rivet: Vector2i in [Vector2i(-15, -25), Vector2i(15, -25), Vector2i(-13, 19), Vector2i(13, 19), Vector2i(0, 31)]:
		_circle(image, center + rivet, 1, GOLD_LIT)
	if breaking:
		var cracks: int = mini(2 + break_frame * 2, 8)
		_draw_shield_cracks(image, center, cracks, break_frame >= 3)


func _draw_greatsword(image: Image, grip: Vector2i, tip: Vector2i, cursed: bool) -> void:
	var direction: Vector2 = Vector2(tip - grip).normalized()
	if direction.length_squared() < 0.5:
		return
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	# Extend the authored blade slightly so the boss reads as a greatsword user at
	# gameplay scale, while keeping every pose inside the 96 px production cell.
	# Seven pixels is intentionally restrained: it lengthens the visible blade
	# without letting it dominate the knight's silhouette or change hitbox reach.
	var extended_tip: Vector2 = Vector2(tip) + direction * 7.0
	extended_tip.x = clampf(extended_tip.x, 1.0, 95.0)
	extended_tip.y = clampf(extended_tip.y, 1.0, 95.0)
	var pommel: Vector2 = Vector2(grip) - direction * 5.0
	var guard_center: Vector2 = Vector2(grip) + direction * 8.0
	var blade_base: Vector2 = Vector2(grip) + direction * 14.0
	var blade_tip: Vector2 = extended_tip - direction * 7.0
	_draw_segment(image, Vector2i(pommel), Vector2i(guard_center), 8, OUTLINE)
	_draw_segment(image, Vector2i(pommel), Vector2i(guard_center), 4, LEATHER_LIT)
	_circle(image, Vector2i(pommel), 4, OUTLINE)
	_circle(image, Vector2i(pommel), 2, OLD_GOLD)
	_draw_segment(image, Vector2i(guard_center + normal * 13.0), Vector2i(guard_center - normal * 13.0), 6, OUTLINE)
	_draw_segment(image, Vector2i(guard_center + normal * 10.0), Vector2i(guard_center - normal * 10.0), 3, OLD_GOLD)
	# Wide complete blade with a longer two-stage taper and a decisive point.
	_poly(image, PackedVector2Array([
		blade_base + normal * 7.0,
		blade_tip + normal * 3.0,
		extended_tip,
		blade_tip - normal * 3.0,
		blade_base - normal * 7.0,
	]), OUTLINE)
	_poly(image, PackedVector2Array([
		blade_base + normal * 5.0,
		blade_tip + normal * 1.5,
		extended_tip - direction * 1.0,
		blade_tip - normal * 1.5,
		blade_base - normal * 5.0,
	]), OLD_SILVER)
	_draw_segment(image, Vector2i(blade_base + normal * 2.0), Vector2i(blade_tip + normal * 0.5), 2, PALE_STEEL)
	_draw_segment(image, Vector2i(blade_base - normal * 2.0), Vector2i(blade_tip - normal * 0.5), 2, BLACK_STEEL)
	var middle: Vector2i = Vector2i((blade_base + blade_tip) * 0.5)
	_circle(image, middle, 3, OUTLINE)
	_circle(image, middle, 1, OLD_GOLD)
	if cursed:
		_draw_segment(image, Vector2i(blade_base), middle + Vector2i(roundi(direction.x * 4.0), roundi(direction.y * 4.0)), 1, SOUL_BLUE)
		_draw_segment(image, middle, Vector2i(blade_tip - direction * 5.0), 1, SOUL_LIT)


func _draw_animation_fx(
	image: Image,
	animation: StringName,
	frame: int,
	count: int,
	origin: Vector2i,
	phase_one: bool
) -> void:
	if animation == &"shield_break":
		_draw_shield_fragments(image, origin + Vector2i(-22, 43), frame)
	if animation == &"phase_transition":
		_draw_shield_fragments(image, origin + Vector2i(-21, 42), frame + 1)
		for spark: int in range(5 + frame * 3):
			var point: Vector2i = origin + Vector2i(-25 + (spark * 13 + frame * 7) % 56, 9 + (spark * 11) % 57)
			_pixel(image, point.x, point.y, SOUL_LIT if spark % 3 == 0 else RUST_LIT)
	if animation == &"shockwave_strike" and frame in [3, 4]:
		_draw_shockwave(image, origin + Vector2i(35, 81), frame - 3)
	if animation in [&"shield_hit", &"shield_block"] and frame > 0:
		_draw_impact(image, origin + Vector2i(-42, 35), frame)
	if animation in [&"hurt", &"hurt_unshielded", &"stagger"]:
		for spark: int in range(2 + frame):
			_pixel(image, origin.x - 19 + spark * 7, origin.y + 20 + spark * 5, SOUL_BLUE)
	if animation == &"intro":
		for soul: int in range(frame + 1):
			_pixel(image, origin.x - 8 + soul * 4, origin.y + 9 - soul * 2, SOUL_LIT)
	if animation == &"death_start" and frame == count - 1:
		_draw_impact(image, origin + Vector2i(1, 26), 1)
	if not phase_one and animation in [&"charge_thrust", &"combo_slash", &"combo_slash_1", &"jump_smash"] and frame >= count / 2:
		_draw_segment(image, origin + Vector2i(-23, 29), origin + Vector2i(-35, 25), 1, SOUL_BLUE)


func _draw_death(image: Image, frame: int) -> void:
	var y: int = 54 + mini(frame, 4) * 7
	var collapse: int = mini(frame, 4) * 5
	if frame < 3:
		_draw_knight(image, &"hurt", mini(frame, 2), 3, false)
		return
	_poly(image, _points([7, y + 4, 26, y - 8, 66, y - 8, 91, y + 4, 81, y + 20, 16, y + 22]), OUTLINE)
	_poly(image, _points([13, y + 4, 30, y - 4, 63, y - 4, 84, y + 5, 75, y + 15, 22, y + 17]), OLD_IRON)
	_poly(image, _points([28, y, 53, y - 4, 66, y + 9, 39, y + 14]), DRIED_BLOOD)
	_draw_greatsword(image, Vector2i(60, y + 2), Vector2i(94, 91), true)
	for fragment: int in range(maxi(0, frame - 3) * 8):
		var point: Vector2i = Vector2i(10 + (fragment * 13 + frame * 5) % 78, y - 9 + (fragment * 9) % 23)
		_poly(image, _points([point.x - 2, point.y + 2, point.x, point.y - 3, point.x + 3, point.y, point.x + 1, point.y + 3]), SOUL_BLUE if fragment % 5 == 0 else OLD_SILVER)
	if collapse > 0:
		_draw_segment(image, Vector2i(20, y + 17), Vector2i(75, y + 17), 1, RUST)


func _write_shield_condition_art() -> void:
	for state: StringName in [&"intact", &"damaged", &"critical", &"broken"]:
		var overlay: Image = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
		overlay.fill(CLEAR)
		var center: Vector2i = Vector2i(27, 54)
		match state:
			&"intact":
				for rivet: Vector2i in [Vector2i(-15, -25), Vector2i(15, -25), Vector2i(-13, 19), Vector2i(13, 19)]:
					_circle(overlay, center + rivet, 1, GOLD_LIT)
			&"damaged":
				_draw_shield_cracks(overlay, center, 4, false)
				_poly(overlay, _points([center.x - 20, center.y - 3, center.x - 15, center.y - 6, center.x - 16, center.y + 5, center.x - 20, center.y + 8]), OUTLINE)
			&"critical":
				_draw_shield_cracks(overlay, center, 8, true)
				_poly(overlay, _points([center.x - 21, center.y - 19, center.x - 12, center.y - 15, center.x - 15, center.y - 3, center.x - 21, center.y + 1]), OUTLINE)
				_poly(overlay, _points([center.x + 12, center.y + 18, center.x + 19, center.y + 23, center.x + 8, center.y + 34, center.x + 3, center.y + 29]), OUTLINE)
			&"broken":
				_draw_shield_fragments(overlay, center, 4)
		var output: String = "%s/shield_%s_overlay.png" % [EFFECTS, state]
		overlay.save_png(ProjectSettings.globalize_path(output))
	# Standalone 96px shield states for QA/design inspection.
	for stage: int in range(4):
		var state_image: Image = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
		state_image.fill(CLEAR)
		if stage < 3:
			_draw_tower_shield(state_image, Vector2i(48, 50), stage > 0, 1 + stage * 2)
			if stage == 2:
				_poly(state_image, _points([28, 29, 37, 32, 34, 45, 27, 49]), OUTLINE)
		else:
			_draw_shield_fragments(state_image, Vector2i(48, 50), 4)
		state_image.save_png(ProjectSettings.globalize_path("%s/shield_stage_%02d.png" % [EFFECTS, stage]))


func _write_break_effects() -> void:
	for frame: int in range(5):
		var effect: Image = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
		effect.fill(CLEAR)
		_draw_shield_fragments(effect, Vector2i(40, 50), frame)
		if frame < 3:
			_draw_impact(effect, Vector2i(30, 45), frame)
		effect.save_png(ProjectSettings.globalize_path("%s/shield_break_fx_%02d.png" % [EFFECTS, frame + 1]))


func _write_concept_derivatives() -> void:
	var equipment_path: String = CONCEPTS + "/fallen_gate_knight_equipment_sheet_source.png"
	var equipment: Image = Image.load_from_file(ProjectSettings.globalize_path(equipment_path))
	if not equipment.is_empty():
		_crop_and_save(equipment, Rect2i(0, 0, 520, equipment.get_height()), CONCEPTS + "/fallen_gate_knight_shield_design.png")
		_crop_and_save(equipment, Rect2i(500, 0, 340, equipment.get_height()), CONCEPTS + "/fallen_gate_knight_shield_damage_states.png")
		_crop_and_save(equipment, Rect2i(815, 0, equipment.get_width() - 815, equipment.get_height()), CONCEPTS + "/fallen_gate_knight_greatsword_design.png")
	var comparison: Image = Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	comparison.fill(Color("11151b"))
	_blit_fit(comparison, CONCEPTS + "/fallen_gate_knight_phase_01_concept.png", Rect2i(40, 40, 870, 930))
	_blit_fit(comparison, CONCEPTS + "/fallen_gate_knight_phase_02_concept.png", Rect2i(1010, 40, 870, 930))
	var phase_one: Image = _draw_frame(&"idle_shielded", 0, 4)
	var phase_two: Image = _draw_frame(&"idle_unshielded", 0, 4)
	var silhouette_one: Image = _to_silhouette(phase_one)
	var silhouette_two: Image = _to_silhouette(phase_two)
	silhouette_one.resize(192, 192, Image.INTERPOLATE_NEAREST)
	silhouette_two.resize(192, 192, Image.INTERPOLATE_NEAREST)
	comparison.blend_rect(silhouette_one, Rect2i(0, 0, 192, 192), Vector2i(340, 868))
	comparison.blend_rect(silhouette_two, Rect2i(0, 0, 192, 192), Vector2i(1390, 868))
	comparison.save_png(ProjectSettings.globalize_path(CONCEPTS + "/fallen_gate_knight_phase_comparison.png"))


func _write_runtime_preview() -> void:
	var board: Image = Image.create(768, 384, false, Image.FORMAT_RGBA8)
	board.fill(Color("11151b"))
	var samples: Array[Dictionary] = [
		{&"animation": &"idle_shielded", &"frame": 0},
		{&"animation": &"shield_bash", &"frame": 2},
		{&"animation": &"shield_break", &"frame": 3},
		{&"animation": &"idle_unshielded", &"frame": 0},
		{&"animation": &"charge_thrust", &"frame": 3},
		{&"animation": &"heavy_overhead", &"frame": 4},
		{&"animation": &"jump_smash", &"frame": 4},
		{&"animation": &"death", &"frame": 5},
	]
	for index: int in range(samples.size()):
		var entry: Dictionary = samples[index]
		var animation: StringName = entry[&"animation"] as StringName
		var frame: int = int(entry[&"frame"])
		var source: Image = _draw_frame(animation, frame, int(ANIMATIONS[animation]))
		source.resize(192, 192, Image.INTERPOLATE_NEAREST)
		board.blit_rect(source, Rect2i(0, 0, 192, 192), Vector2i((index % 4) * 192, (index / 4) * 192))
	board.save_png(ProjectSettings.globalize_path(ROOT + "/animations/fallen_gate_knight_v3_runtime_preview.png"))


func _draw_shield_cracks(image: Image, center: Vector2i, count: int, soul_leak: bool) -> void:
	for crack: int in range(count):
		var start: Vector2i = center + Vector2i(-11 + (crack * 7) % 21, -24 + (crack * 13) % 43)
		var bend: Vector2i = start + Vector2i(4 + crack % 3, 5 + crack % 4)
		var finish: Vector2i = bend + Vector2i(-3 + (crack % 2) * 7, 6 + crack % 3)
		var color: Color = SOUL_LIT if soul_leak and crack % 3 == 0 else PALE_STEEL
		_draw_segment(image, start, bend, 2, OUTLINE)
		_draw_segment(image, bend, finish, 2, OUTLINE)
		_draw_segment(image, start, bend, 1, color)
		_draw_segment(image, bend, finish, 1, color)


func _draw_shield_fragments(image: Image, center: Vector2i, frame: int) -> void:
	# Keep the knight readable during the break; fragments punctuate the hit instead of
	# becoming an opaque cloud that hides the new unshielded silhouette.
	var fragment_count: int = 4 + mini(frame, 4) * 3
	for fragment: int in range(fragment_count):
		var point: Vector2i = center + Vector2i(-23 + (fragment * 13 + frame * 7) % 54, -25 + (fragment * 11 + frame * 5) % 59)
		var color: Color = SOUL_BLUE if fragment % 7 == 0 else OLD_SILVER if fragment % 3 else RUST_LIT
		_poly(image, _points([point.x - 3, point.y + 3, point.x, point.y - 5, point.x + 5, point.y, point.x + 1, point.y + 5]), color)


func _draw_shockwave(image: Image, center: Vector2i, frame: int) -> void:
	for band: int in range(3):
		var width: int = 12 + band * 14 + frame * 7
		_draw_segment(image, center - Vector2i(width, 0), center - Vector2i(width / 2, 8 + band * 3), 2, SOUL_BLUE if band % 2 else RUST_LIT)
		_draw_segment(image, center + Vector2i(width / 2, -8 - band * 3), center + Vector2i(width, 0), 2, SOUL_LIT)


func _draw_impact(image: Image, center: Vector2i, frame: int) -> void:
	var reach: int = 7 + frame * 3
	for ray: Vector2i in [Vector2i(-reach, -2), Vector2i(-5, -reach), Vector2i(reach, -5), Vector2i(reach, 4)]:
		_draw_segment(image, center, center + ray, 2, PALE_STEEL if ray.x < 0 else GOLD_LIT)


func _crop_and_save(source: Image, rectangle: Rect2i, output: String) -> void:
	var result: Image = source.get_region(rectangle)
	result.save_png(ProjectSettings.globalize_path(output))


func _blit_fit(target: Image, source_path: String, destination: Rect2i) -> void:
	var source: Image = Image.load_from_file(ProjectSettings.globalize_path(source_path))
	if source.is_empty():
		return
	if source.get_format() != Image.FORMAT_RGBA8:
		source.convert(Image.FORMAT_RGBA8)
	var scale: float = minf(float(destination.size.x) / float(source.get_width()), float(destination.size.y) / float(source.get_height()))
	var width: int = maxi(1, roundi(float(source.get_width()) * scale))
	var height: int = maxi(1, roundi(float(source.get_height()) * scale))
	source.resize(width, height, Image.INTERPOLATE_LANCZOS)
	var offset: Vector2i = destination.position + Vector2i((destination.size.x - width) / 2, (destination.size.y - height) / 2)
	target.blit_rect(source, Rect2i(0, 0, width, height), offset)


func _to_silhouette(source: Image) -> Image:
	var result: Image = Image.create(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	result.fill(CLEAR)
	for py: int in range(source.get_height()):
		for px: int in range(source.get_width()):
			if source.get_pixel(px, py).a >= 0.5:
				result.set_pixel(px, py, Color(0.0, 0.0, 0.0, 1.0))
	return result


func _points(values: Array[int]) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(0, values.size(), 2):
		points.append(Vector2(values[index], values[index + 1]))
	return points


func _poly(image: Image, points: PackedVector2Array, color: Color) -> void:
	if points.size() < 3:
		return
	var minimum_y: int = image.get_height() - 1
	var maximum_y: int = 0
	for point: Vector2 in points:
		minimum_y = mini(minimum_y, floori(point.y))
		maximum_y = maxi(maximum_y, ceili(point.y))
	for py: int in range(maxi(0, minimum_y), mini(image.get_height() - 1, maximum_y) + 1):
		var intersections: Array[float] = []
		for index: int in range(points.size()):
			var first: Vector2 = points[index]
			var second: Vector2 = points[(index + 1) % points.size()]
			if (first.y <= float(py) and second.y > float(py)) or (second.y <= float(py) and first.y > float(py)):
				var amount: float = (float(py) - first.y) / (second.y - first.y)
				intersections.append(lerpf(first.x, second.x, amount))
		intersections.sort()
		for intersection_index: int in range(0, intersections.size() - 1, 2):
			var start_x: int = ceili(intersections[intersection_index])
			var end_x: int = floori(intersections[intersection_index + 1])
			for px: int in range(maxi(0, start_x), mini(image.get_width() - 1, end_x) + 1):
				image.set_pixel(px, py, color)


func _draw_segment(image: Image, start: Vector2i, finish: Vector2i, width: int, color: Color) -> void:
	var delta: Vector2i = finish - start
	var steps: int = maxi(absi(delta.x), absi(delta.y))
	if steps <= 0:
		_circle(image, start, maxi(1, width / 2), color)
		return
	for step: int in range(steps + 1):
		var amount: float = float(step) / float(steps)
		var point: Vector2i = Vector2i(roundi(lerpf(float(start.x), float(finish.x), amount)), roundi(lerpf(float(start.y), float(finish.y), amount)))
		_circle(image, point, maxi(1, width / 2), color)


func _circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for py: int in range(center.y - radius, center.y + radius + 1):
		for px: int in range(center.x - radius, center.x + radius + 1):
			if Vector2i(px, py).distance_squared_to(center) <= radius * radius:
				_pixel(image, px, py, color)


func _pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
		image.set_pixel(x, y, color)
