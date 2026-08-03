extends SceneTree

## Deterministic 192x192 formal pixel-art generator for Edran Phase 1.
## Concept boards remain production references; runtime art is authored directly at target resolution.

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran"
const SPRITES_ROOT: String = ROOT + "/phase_01"
const PREVIEW_ROOT: String = ROOT + "/previews"
const FRAME_SIZE: int = 192
const LEGACY_SIZE: int = 96
const ART_OFFSET: Vector2i = Vector2i(48, 48)
const CLEAR: Color = Color(0.0, 0.0, 0.0, 0.0)
const OUTLINE: Color = Color("070810")
const VOID: Color = Color("0b0c14")
const BLACK_CLOTH: Color = Color("171923")
const CLOTH: Color = Color("242631")
const CLOTH_LIGHT: Color = Color("3b3e4a")
const OXBLOOD: Color = Color("542331")
const OXBLOOD_LIGHT: Color = Color("793445")
const BONE_SHADE: Color = Color("948c7c")
const BONE: Color = Color("d6cfbd")
const OLD_GOLD: Color = Color("8d6a38")
const GOLD_LIGHT: Color = Color("c3a15d")
const COPPER: Color = Color("795333")
const COPPER_LIGHT: Color = Color("b27b47")
const IRON: Color = Color("424954")
const STEEL: Color = Color("7e8c97")
const SOUL: Color = Color("77a7bb")
const SOUL_LIGHT: Color = Color("b8dce2")
const WAX: Color = Color("7f2638")
const SMOKE: Color = Color(0.52, 0.59, 0.62, 0.62)
const SMOKE_RED: Color = Color(0.43, 0.16, 0.22, 0.56)

const ANIMATIONS: Dictionary = {
	&"prayer_idle": 4,
	&"scripture_writing": 5,
	&"intro_back_facing": 4,
	&"intro_turn": 5,
	&"dialogue_idle": 4,
	&"phase_01_idle": 4,
	&"slow_walk": 6,
	&"turn": 4,
	&"pontifical_sweep_windup": 5,
	&"pontifical_sweep_active": 2,
	&"pontifical_sweep_recovery": 5,
	&"crozier_thrust_windup": 4,
	&"crozier_thrust_active": 2,
	&"crozier_thrust_recovery": 4,
	&"censer_procession_windup": 5,
	&"censer_procession_active": 2,
	&"censer_procession_recovery": 5,
	&"litany_cast": 6,
	&"summon_start": 5,
	&"summon_loop": 4,
	&"summon_success": 4,
	&"summon_interrupt": 4,
	&"thirteenfold_sentence": 8,
	&"light_hit": 2,
	&"hurt": 3,
	&"stagger": 4,
	&"phase_transition_start": 4,
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SPRITES_ROOT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PREVIEW_ROOT))
	var written: int = 0
	for animation_variant: Variant in ANIMATIONS.keys():
		var animation: StringName = animation_variant as StringName
		var frame_count: int = int(ANIMATIONS[animation])
		var directory: String = "%s/%s" % [SPRITES_ROOT, animation]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		for frame: int in range(frame_count):
			var image: Image = _draw_frame(animation, frame, frame_count)
			var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
			if image.save_png(ProjectSettings.globalize_path(path)) != OK:
				push_error("Could not save Edran frame: %s" % path)
				quit(1)
				return
			written += 1
	_write_master_previews()
	print("EDRAN_PHASE_01_ART | PASS animations=%d frames=%d" % [ANIMATIONS.size(), written])
	quit(0)


func _write_master_previews() -> void:
	var idle: Image = _draw_frame(&"phase_01_idle", 0, 4)
	idle.save_png(ProjectSettings.globalize_path(PREVIEW_ROOT + "/edran_phase_01_sprite_master.png"))
	var back: Image = _draw_frame(&"intro_back_facing", 0, 4)
	back.save_png(ProjectSettings.globalize_path(PREVIEW_ROOT + "/edran_phase_01_back_sprite_master.png"))
	var silhouette: Image = idle.duplicate()
	for y: int in range(FRAME_SIZE):
		for x: int in range(FRAME_SIZE):
			if silhouette.get_pixel(x, y).a > 0.0:
				silhouette.set_pixel(x, y, Color.BLACK)
	silhouette.save_png(ProjectSettings.globalize_path(PREVIEW_ROOT + "/edran_phase_01_sprite_silhouette.png"))
	var scale_board: Image = Image.create(640, 256, false, Image.FORMAT_RGBA8)
	scale_board.fill(Color("11131c"))
	_blit_scaled_nearest(scale_board, idle, Vector2i(18, 32), 1)
	_blit_scaled_nearest(scale_board, idle, Vector2i(280, 0), 1)
	_draw_segment(scale_board, Vector2i(8, 224), Vector2i(620, 224), 2, STEEL)
	scale_board.save_png(ProjectSettings.globalize_path(PREVIEW_ROOT + "/edran_phase_01_scale_preview.png"))


func _draw_frame(animation: StringName, frame: int, count: int) -> Image:
	var legacy: Image = _draw_frame_legacy(animation, frame, count)
	var image: Image = Image.create(FRAME_SIZE, FRAME_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	image.blit_rect(legacy, Rect2i(Vector2i.ZERO, legacy.get_size()), ART_OFFSET)
	_draw_replication_details(image, animation, frame)
	return image


func _draw_frame_legacy(animation: StringName, frame: int, count: int) -> Image:
	var image: Image = Image.create(LEGACY_SIZE, LEGACY_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var progress: float = float(frame) / float(maxi(1, count - 1))
	var pose: Dictionary = _pose(animation, frame, progress)
	_draw_edran(image, animation, frame, progress, pose)
	return image


func _draw_replication_details(image: Image, animation: StringName, frame: int) -> void:
	var o: Vector2i = ART_OFFSET
	# Thirteen-point reliquary crown, sealed pontifical mask, scripture stole,
	# black-bell breast reliquary and chained censer identify Edran in every pose.
	for point: int in range(7):
		var crown_x: int = o.x + 31 + point * 5
		_draw_segment(image, Vector2i(crown_x, o.y + 13), Vector2i(crown_x + 2, o.y + 4 + abs(point - 3)), 2, OLD_GOLD)
	_draw_segment(image, o + Vector2i(39, 20), o + Vector2i(57, 20), 2, BONE)
	for seal: int in range(5):
		_pixel(image, o.x + 38 + seal * 4, o.y + 34 + (seal % 2), GOLD_LIGHT)
	_draw_segment(image, o + Vector2i(45, 39), o + Vector2i(45, 72), 3, OXBLOOD_LIGHT)
	for script_line: int in range(5):
		_draw_segment(image, o + Vector2i(39, 48 + script_line * 5), o + Vector2i(51, 48 + script_line * 5), 1, BONE_SHADE)
	_draw_segment(image, o + Vector2i(63, 39), o + Vector2i(74, 58), 2, COPPER_LIGHT)
	if animation in [&"summon_loop", &"thirteenfold_sentence"]:
		for mote: int in range(4):
			_pixel(image, o.x + 27 + mote * 13, o.y + 17 + (frame + mote) % 4, SOUL_LIGHT)


func _pose(animation: StringName, frame: int, progress: float) -> Dictionary:
	var x: int = 48
	var y: int = 4
	var bob: int = 0
	var lean: int = 0
	var stride: int = 0
	var facing_scale: float = 1.0
	if animation in [&"prayer_idle", &"phase_01_idle", &"dialogue_idle", &"summon_loop"]:
		bob = [0, -1, -1, 0][frame % 4]
	if animation == &"slow_walk":
		stride = [-4, -2, 1, 4, 2, -1][frame % 6]
		bob = [0, -1, 0, 1, -1, 0][frame % 6]
	if animation in [&"light_hit", &"hurt"]:
		x -= 2 + frame * 2
		lean = -3
	if animation == &"stagger":
		x -= [1, 4, 6, 3][frame]
		lean = -5
	if animation == &"summon_interrupt":
		x -= frame * 2
		lean = -4
	if animation == &"phase_transition_start":
		lean = roundi(progress * 4.0)
	if animation in [&"pontifical_sweep_active", &"crozier_thrust_active", &"censer_procession_active"]:
		lean = 5
		x += 2
	if animation in [&"intro_turn", &"turn"]:
		facing_scale = lerpf(-1.0, 1.0, progress)
	return {&"x": x, &"y": y + bob, &"lean": lean, &"stride": stride, &"facing_scale": facing_scale}


func _draw_edran(image: Image, animation: StringName, frame: int, progress: float, pose: Dictionary) -> void:
	var x: int = int(pose[&"x"])
	var y: int = int(pose[&"y"])
	var lean: int = int(pose[&"lean"])
	var stride: int = int(pose[&"stride"])
	var back_facing: bool = animation == &"intro_back_facing"
	var turn_scale: float = absf(float(pose[&"facing_scale"]))
	if animation in [&"intro_turn", &"turn"] and turn_scale < 0.30:
		turn_scale = 0.30
	_draw_robe(image, x, y, stride, animation, frame)
	_draw_torso(image, x + lean, y, back_facing, turn_scale)
	_draw_head_and_crown(image, x + lean, y, back_facing, turn_scale, animation, frame)
	var crozier_pose: Dictionary = _crozier_pose(animation, frame, progress, x + lean, y)
	var censer_pose: Dictionary = _censer_pose(animation, frame, progress, x + lean, y)
	var staff_hand: Vector2i = crozier_pose[&"hand"] as Vector2i
	var staff_bottom: Vector2i = crozier_pose[&"bottom"] as Vector2i
	var staff_top: Vector2i = crozier_pose[&"top"] as Vector2i
	var censer_hand: Vector2i = censer_pose[&"hand"] as Vector2i
	var censer_center: Vector2i = censer_pose[&"center"] as Vector2i
	_draw_sleeved_arm(image, Vector2i(x + lean + 12, y + 31), staff_hand, true)
	_draw_sleeved_arm(image, Vector2i(x + lean - 12, y + 31), censer_hand, false)
	_draw_crozier(image, staff_bottom, staff_top, staff_hand)
	_draw_hand(image, staff_hand)
	_draw_hand(image, censer_hand)
	_draw_chain_and_censer(image, censer_hand, censer_center, animation, frame)
	_draw_action_fx(image, animation, frame, progress, Vector2i(x + lean, y))


func _draw_robe(image: Image, x: int, y: int, stride: int, animation: StringName, frame: int) -> void:
	var sway: int = 2 if animation == &"slow_walk" and frame % 2 == 1 else 0
	_poly(image, _points([x-15,y+39, x+15,y+39, x+24+sway,y+85, x+12,y+82, x+4,y+88, x-5,y+83, x-17,y+88, x-25+sway,y+84]), OUTLINE)
	_poly(image, _points([x-12,y+41, x+12,y+41, x+20+sway,y+81, x+10,y+79, x+3,y+85, x-5,y+80, x-15,y+85, x-21+sway,y+81]), BLACK_CLOTH)
	_poly(image, _points([x-8,y+43, x+7,y+42, x+11,y+79, x+4,y+82, x-2,y+78, x-9,y+83, x-14,y+79]), OXBLOOD)
	_draw_segment(image, Vector2i(x-10,y+45), Vector2i(x-15+sway,y+80), 1, CLOTH_LIGHT)
	_draw_segment(image, Vector2i(x+10,y+44), Vector2i(x+14+sway,y+79), 1, CLOTH_LIGHT)
	_draw_segment(image, Vector2i(x-18,y+70), Vector2i(x+18,y+69), 1, OLD_GOLD)
	for tear: int in range(5):
		var tx: int = x - 18 + tear * 8
		_pixel(image, tx + sway, y + 84 - tear % 2, OXBLOOD_LIGHT)
	_draw_segment(image, Vector2i(x-6,y+78), Vector2i(x-9-stride,y+88), 5, OUTLINE)
	_draw_segment(image, Vector2i(x+6,y+78), Vector2i(x+9+stride,y+88), 5, OUTLINE)
	_draw_segment(image, Vector2i(x-6,y+79), Vector2i(x-9-stride,y+87), 2, IRON)
	_draw_segment(image, Vector2i(x+6,y+79), Vector2i(x+9+stride,y+87), 2, STEEL)


func _draw_torso(image: Image, x: int, y: int, back_facing: bool, width_scale: float) -> void:
	var shoulder: int = maxi(7, roundi(20.0 * width_scale))
	_poly(image, _points([x-15,y+27, x-9,y+19, x+9,y+19, x+15,y+28, x+11,y+49, x-11,y+49]), OUTLINE)
	_poly(image, _points([x-12,y+28, x-7,y+22, x+7,y+22, x+12,y+29, x+8,y+46, x-8,y+46]), CLOTH)
	_poly(image, _points([x-shoulder,y+29, x-15,y+20, x-7,y+23, x-12,y+36]), OUTLINE)
	_poly(image, _points([x+shoulder,y+29, x+15,y+20, x+7,y+23, x+12,y+36]), OUTLINE)
	_poly(image, _points([x-shoulder+3,y+28, x-14,y+23, x-9,y+25, x-13,y+32]), BONE_SHADE)
	_poly(image, _points([x+shoulder-3,y+28, x+14,y+23, x+9,y+25, x+13,y+32]), BONE)
	if back_facing:
		_draw_segment(image, Vector2i(x-7,y+24), Vector2i(x+7,y+44), 2, OLD_GOLD)
		return
	# Thirteen-cell absolution stole: seven readable cells per side with the sealed blank at the hem.
	for cell: int in range(7):
		var cy: int = y + 24 + cell * 8
		var spread: int = 5 + cell / 3
		_fill(image, Rect2i(x-spread-5, cy, 5, 6), BONE if cell % 2 == 0 else BONE_SHADE)
		_fill(image, Rect2i(x+spread, cy, 5, 6), BONE_SHADE if cell % 2 == 0 else BONE)
		_pixel(image, x-spread-3, cy+3, WAX)
		_pixel(image, x+spread+2, cy+3, WAX)
	_fill(image, Rect2i(x-2,y+24,4,20), OXBLOOD)
	_draw_segment(image, Vector2i(x-10,y+49), Vector2i(x+10,y+49), 1, OLD_GOLD)
	# Waist keys, bell and bone tags remain sparse at gameplay scale.
	_draw_bell(image, Vector2i(x+12,y+56), 5)
	_draw_segment(image, Vector2i(x-10,y+50), Vector2i(x-14,y+61), 1, OLD_GOLD)
	_fill(image, Rect2i(x-16,y+59,4,2), STEEL)
	_fill(image, Rect2i(x-13,y+58,2,6), STEEL)


func _draw_head_and_crown(image: Image, x: int, y: int, back_facing: bool, width_scale: float, animation: StringName, frame: int) -> void:
	var half_width: int = maxi(4, roundi(8.0 * width_scale))
	_poly(image, _points([x-half_width,y+7, x-4,y+2, x+4,y+2, x+half_width,y+7, x+6,y+21, x-6,y+21]), OUTLINE)
	_poly(image, _points([x-maxi(3,half_width-2),y+8, x-3,y+4, x+3,y+4, x+maxi(3,half_width-2),y+8, x+4,y+19, x-4,y+19]), VOID if back_facing else BONE)
	if not back_facing:
		_draw_segment(image, Vector2i(x-3,y+12), Vector2i(x+4,y+12), 1, BONE_SHADE)
		_pixel(image, x+3, y+12, SOUL_LIGHT)
		_pixel(image, x+4, y+12, SOUL)
	# Original hollow-bell crown: three pointed arches and thirteen seal nodes.
	_poly(image, _points([x-10,y+7, x-9,y-8, x-5,y-1, x-2,y-15, x+1,y-5, x+5,y-12, x+10,y+7]), OUTLINE)
	_draw_segment(image, Vector2i(x-8,y+5), Vector2i(x-7,y-5), 2, OLD_GOLD)
	_draw_segment(image, Vector2i(x-7,y-5), Vector2i(x-4,y+2), 2, GOLD_LIGHT)
	_draw_segment(image, Vector2i(x-4,y+2), Vector2i(x-2,y-12), 2, OLD_GOLD)
	_draw_segment(image, Vector2i(x-2,y-12), Vector2i(x+1,y-3), 2, GOLD_LIGHT)
	_draw_segment(image, Vector2i(x+1,y-3), Vector2i(x+5,y-10), 2, OLD_GOLD)
	_draw_segment(image, Vector2i(x+5,y-10), Vector2i(x+8,y+5), 2, GOLD_LIGHT)
	for seal: int in range(13):
		var sx: int = x - 9 + seal * 18 / 12
		var sy: int = y + 3 - (seal % 3)
		_fill(image, Rect2i(sx, sy, 2, 2), WAX)
		if seal % 4 == 0:
			_pixel(image, sx, sy, GOLD_LIGHT)
	if animation == &"phase_transition_start":
		_draw_segment(image, Vector2i(x,y-11), Vector2i(x+frame-1,y+5), 1, SOUL_LIGHT)


func _draw_sleeved_arm(image: Image, shoulder: Vector2i, hand: Vector2i, lit: bool) -> void:
	_draw_segment(image, shoulder, hand, 8, OUTLINE)
	_draw_segment(image, shoulder, hand, 5, CLOTH_LIGHT if lit else OXBLOOD)
	var cuff: Vector2i = hand + (shoulder - hand).sign() * 4
	_draw_segment(image, cuff + Vector2i(0,-2), cuff + Vector2i(0,2), 3, BONE_SHADE)


func _draw_hand(image: Image, center: Vector2i) -> void:
	_fill(image, Rect2i(center.x-2, center.y-2, 5, 5), BONE_SHADE)
	_pixel(image, center.x+2, center.y-1, BONE)


func _crozier_pose(animation: StringName, frame: int, progress: float, x: int, y: int) -> Dictionary:
	var hand: Vector2i = Vector2i(x+18,y+33)
	var bottom: Vector2i = Vector2i(x+25,y+88)
	var top: Vector2i = Vector2i(x+25,y+10)
	if animation.begins_with("pontifical_sweep"):
		if animation.ends_with("windup"):
			hand = Vector2i(x+12-roundi(progress*12.0),y+31-roundi(progress*7.0))
			bottom = Vector2i(x-15-roundi(progress*8.0),y+58)
			top = Vector2i(x+22,y+15-roundi(progress*7.0))
		elif animation.ends_with("active"):
			hand = Vector2i(x+12,y+32); bottom = Vector2i(8,y+39+frame*2); top = Vector2i(80,y+29+frame*2)
		else:
			hand = Vector2i(x+14,y+33); bottom = Vector2i(9+roundi(progress*17.0),y+48+roundi(progress*36.0)); top = Vector2i(80-roundi(progress*50.0),y+34-roundi(progress*24.0))
	elif animation.begins_with("crozier_thrust"):
		if animation.ends_with("windup"):
			hand = Vector2i(x+10-roundi(progress*8.0),y+34); bottom = Vector2i(x-25,y+42); top = Vector2i(x+26,y+26)
		elif animation.ends_with("active"):
			hand = Vector2i(x+18,y+34); bottom = Vector2i(x-25,y+41); top = Vector2i(80,y+26)
		else:
			hand = Vector2i(x+18-roundi(progress*3.0),y+34); bottom = Vector2i(x-25+roundi(progress*48.0),y+41+roundi(progress*47.0)); top = Vector2i(80-roundi(progress*50.0),y+26-roundi(progress*16.0))
	elif animation in [&"litany_cast", &"summon_start", &"summon_loop", &"summon_success", &"thirteenfold_sentence"]:
		hand = Vector2i(x+17,y+28); bottom = Vector2i(x+23,y+88); top = Vector2i(x+23,y+10)
	elif animation == &"summon_interrupt":
		hand = Vector2i(x+10,y+35); bottom = Vector2i(x+31,y+87); top = Vector2i(x+2,y+14)
	return {&"hand":hand, &"bottom":bottom, &"top":top}


func _censer_pose(animation: StringName, frame: int, progress: float, x: int, y: int) -> Dictionary:
	var hand: Vector2i = Vector2i(x-18,y+34)
	var center: Vector2i = Vector2i(x-25,y+60)
	if animation.begins_with("censer_procession"):
		if animation.ends_with("windup"):
			hand = Vector2i(x-14,y+31); center = Vector2i(x-22-roundi(progress*22.0),y+52-roundi(progress*15.0))
		elif animation.ends_with("active"):
			hand = Vector2i(x-10,y+33); center = Vector2i(90,y+68-frame*4)
		else:
			hand = Vector2i(x-12,y+34); center = Vector2i(91-roundi(progress*66.0),y+65-roundi(progress*5.0))
	elif animation in [&"summon_start", &"summon_loop", &"summon_success"]:
		hand = Vector2i(x-20,y+24-roundi(progress*5.0)); center = Vector2i(x-26,y+51-roundi(sin(progress*PI)*8.0))
	elif animation == &"summon_interrupt":
		hand = Vector2i(x-13,y+39); center = Vector2i(x-35,y+76)
	elif animation == &"thirteenfold_sentence":
		hand = Vector2i(x-18,y+26); center = Vector2i(x-30+frame*3,y+50-frame%2*4)
	return {&"hand":hand, &"center":center}


func _draw_crozier(image: Image, bottom: Vector2i, top: Vector2i, hand: Vector2i) -> void:
	# The gameplay crozier mirrors the formal prop: a long, segmented black-iron
	# shaft, oxblood grip, pointed finial, and a large seal-ring carrying a bell.
	# `top` is the ring centre, which lets every action keep the head on-canvas.
	var ring_center: Vector2i = Vector2i(clampi(top.x, 14, FRAME_SIZE-15), clampi(top.y, 14, FRAME_SIZE-15))
	var axis: Vector2 = Vector2(ring_center - bottom).normalized()
	if axis.length_squared() <= 0.01:
		axis = Vector2.UP
	var side: Vector2 = Vector2(-axis.y, axis.x)
	var neck: Vector2i = _crozier_local(ring_center, axis, side, -10.0, 0.0)
	_draw_segment(image, bottom, neck, 5, OUTLINE)
	_draw_segment(image, bottom, neck, 3, IRON)
	_draw_segment(image, bottom, neck, 1, STEEL)

	# Oxblood leather grip and four metal divisions keep the shaft from reading
	# as a featureless line in vertical, sweep, or thrust poses.
	var hand_along: float = Vector2(hand - bottom).dot(axis)
	for offset: float in [-8.0, -5.0, -2.0, 1.0, 4.0, 7.0]:
		var grip_point: Vector2i = _crozier_local(bottom, axis, side, hand_along + offset, 0.0)
		_circle(image, grip_point, 2, OUTLINE)
		_circle(image, grip_point, 1, OXBLOOD_LIGHT if int(offset) % 2 == 0 else OXBLOOD)
	for ratio: float in [0.16, 0.48, 0.76]:
		var band_center_f: Vector2 = Vector2(bottom).lerp(Vector2(neck),ratio)
		var band_center: Vector2i = Vector2i(roundi(band_center_f.x),roundi(band_center_f.y))
		_draw_segment(image, _crozier_local(band_center, axis, side, 0.0, -3.0), _crozier_local(band_center, axis, side, 0.0, 3.0), 3, OUTLINE)
		_draw_segment(image, _crozier_local(band_center, axis, side, 0.0, -2.0), _crozier_local(band_center, axis, side, 0.0, 2.0), 1, GOLD_LIGHT)

	# Gothic spear-finial at the foot.
	var tail_tip: Vector2i = _crozier_local(bottom, axis, side, -7.0, 0.0)
	var tail_left: Vector2i = _crozier_local(bottom, axis, side, -1.0, -4.0)
	var tail_right: Vector2i = _crozier_local(bottom, axis, side, -1.0, 4.0)
	_poly(image, PackedVector2Array([tail_tip, tail_left, bottom, tail_right]), OUTLINE)
	_poly(image, PackedVector2Array([_crozier_local(bottom, axis, side, -5.0, 0.0), _crozier_local(bottom, axis, side, -1.0, -2.0), bottom, _crozier_local(bottom, axis, side, -1.0, 2.0)]), OLD_GOLD)

	# Layered neck and open pontifical ring.
	_circle(image, neck, 4, OUTLINE)
	_circle(image, neck, 2, OLD_GOLD)
	for index: int in range(28):
		var angle: float = TAU * float(index) / 28.0
		# Leave a narrow opening beside the bell, matching the asymmetric relic.
		if angle > 2.58 and angle < 3.72:
			continue
		var ring_point: Vector2i = _crozier_local(ring_center, axis, side, sin(angle)*11.0, cos(angle)*11.0)
		_circle(image, ring_point, 2, OUTLINE)
		_pixel(image, ring_point.x, ring_point.y, OLD_GOLD)
		if index % 4 == 0:
			_pixel(image, ring_point.x, ring_point.y, GOLD_LIGHT)

	# Thirteen distinct seal medallions around the ring.
	for seal: int in range(13):
		var seal_angle: float = TAU * float(seal) / 13.0
		var seal_point: Vector2i = _crozier_local(ring_center, axis, side, sin(seal_angle)*14.0, cos(seal_angle)*14.0)
		_circle(image, seal_point, 2, OUTLINE)
		_circle(image, seal_point, 1, OLD_GOLD)
		_pixel(image, seal_point.x, seal_point.y, WAX if seal % 2 else GOLD_LIGHT)

	# A proper bell occupies the open side: crown, flared bronze body, dark mouth,
	# chain, and separate black clapper all remain readable at gameplay scale.
	var bell_crown: Vector2i = _crozier_local(ring_center, axis, side, 5.0, -4.0)
	var bell_center: Vector2i = _crozier_local(ring_center, axis, side, 0.0, -5.0)
	_draw_segment(image, ring_center, bell_crown, 1, GOLD_LIGHT)
	var bell_top_left: Vector2i = _crozier_local(bell_center, axis, side, 4.0, -3.0)
	var bell_top_right: Vector2i = _crozier_local(bell_center, axis, side, 4.0, 3.0)
	var bell_lip_right: Vector2i = _crozier_local(bell_center, axis, side, -4.0, 6.0)
	var bell_lip_left: Vector2i = _crozier_local(bell_center, axis, side, -4.0, -6.0)
	_poly(image, PackedVector2Array([bell_top_left, bell_top_right, bell_lip_right, bell_lip_left]), OUTLINE)
	_poly(image, PackedVector2Array([_crozier_local(bell_center, axis, side, 3.0, -2.0), _crozier_local(bell_center, axis, side, 3.0, 2.0), _crozier_local(bell_center, axis, side, -3.0, 4.0), _crozier_local(bell_center, axis, side, -3.0, -4.0)]), COPPER)
	_draw_segment(image, bell_lip_left, bell_lip_right, 3, OUTLINE)
	_draw_segment(image, _crozier_local(bell_center, axis, side, -3.0, -5.0), _crozier_local(bell_center, axis, side, -3.0, 5.0), 1, COPPER_LIGHT)
	var clapper_chain: Vector2i = _crozier_local(bell_center, axis, side, -5.0, 0.0)
	var clapper: Vector2i = _crozier_local(bell_center, axis, side, -8.0, 0.0)
	_draw_segment(image, bell_center, clapper_chain, 1, IRON)
	_circle(image, clapper, 2, OUTLINE)
	_pixel(image, clapper.x, clapper.y, VOID)


func _crozier_local(origin: Vector2i, axis: Vector2, side: Vector2, along: float, lateral: float) -> Vector2i:
	return origin + Vector2i(
		roundi(axis.x * along + side.x * lateral),
		roundi(axis.y * along + side.y * lateral)
	)


func _draw_chain_and_censer(image: Image, hand: Vector2i, center: Vector2i, animation: StringName, frame: int) -> void:
	var mid: Vector2i = Vector2i((hand.x+center.x)/2, mini(hand.y,center.y)-7)
	_draw_chain_curve(image, hand, mid, center-Vector2i(0,7), STEEL)
	# Perforated old-bronze body and fitted lid, never a plain circle.
	_poly(image, _points([center.x-7,center.y-3, center.x-4,center.y-8, center.x+4,center.y-8, center.x+7,center.y-3, center.x+5,center.y+6, center.x,center.y+9, center.x-5,center.y+6]), OUTLINE)
	_poly(image, _points([center.x-5,center.y-2, center.x-3,center.y-6, center.x+3,center.y-6, center.x+5,center.y-2, center.x+3,center.y+5, center.x,center.y+7, center.x-3,center.y+5]), COPPER)
	_draw_segment(image, Vector2i(center.x-5,center.y-2), Vector2i(center.x+5,center.y-2), 2, COPPER_LIGHT)
	_circle(image, Vector2i(center.x,center.y-8), 2, OLD_GOLD)
	for hole: Vector2i in [Vector2i(-2,1),Vector2i(2,0),Vector2i(0,4)]:
		_pixel(image, center.x+hole.x, center.y+hole.y, OXBLOOD_LIGHT)
	if animation in [&"censer_procession_active", &"summon_start", &"summon_loop", &"summon_success", &"thirteenfold_sentence"]:
		_draw_smoke(image, center-Vector2i(0,10), frame)


func _draw_action_fx(image: Image, animation: StringName, frame: int, progress: float, center: Vector2i) -> void:
	if animation == &"litany_cast":
		_draw_rune_ring(image, Vector2i(center.x,84), 19+frame, OLD_GOLD, frame)
	elif animation in [&"summon_start", &"summon_loop", &"summon_success"]:
		_draw_rune_ring(image, Vector2i(center.x,86), 24, SOUL, frame)
		for hand: int in range(3):
			_draw_segment(image, Vector2i(center.x-22+hand*20,90), Vector2i(center.x-20+hand*20,78-frame%2*3), 2, SOUL)
	elif animation == &"summon_interrupt":
		for shard: int in range(7):
			var angle: float = TAU*float(shard)/7.0
			_pixel(image, center.x+roundi(cos(angle)*(8.0+frame*3.0)), center.y+36+roundi(sin(angle)*(8.0+frame*3.0)), SOUL_LIGHT)
	elif animation == &"thirteenfold_sentence":
		for seal: int in range(13):
			var sx: int = 4 + seal*7
			var sy: int = 88 - ((seal+frame)%3)*3
			_fill(image, Rect2i(sx,sy,3,2), WAX if seal%2 else OLD_GOLD)
	elif animation == &"phase_transition_start":
		for seal: int in range(frame+1):
			_pixel(image, center.x-6+seal*4, center.y+30+seal%2*3, SOUL_LIGHT)
	if animation == &"pontifical_sweep_active":
		_draw_segment(image, Vector2i(12,center.y+38+frame*2), Vector2i(90,center.y+29+frame*2), 1, SOUL)
	if animation == &"crozier_thrust_active":
		_draw_segment(image, Vector2i(74,center.y+26), Vector2i(95,center.y+26), 2, SOUL_LIGHT)


func _draw_smoke(image: Image, origin: Vector2i, frame: int) -> void:
	for puff: int in range(5):
		var px: int = origin.x + ((puff*7+frame*3)%13)-6
		var py: int = origin.y - puff*4 - frame%2
		_circle(image, Vector2i(px,py), 2+puff%2, SMOKE if puff%2==0 else SMOKE_RED)


func _draw_bell(image: Image, center: Vector2i, radius: int) -> void:
	_poly(image, _points([center.x-radius,center.y+2, center.x-radius+2,center.y-radius+1, center.x+radius-2,center.y-radius+1, center.x+radius,center.y+2, center.x+radius-2,center.y+5, center.x-radius+2,center.y+5]), OUTLINE)
	_poly(image, _points([center.x-radius+2,center.y+1, center.x-radius+3,center.y-radius+2, center.x+radius-3,center.y-radius+2, center.x+radius-2,center.y+1]), COPPER)
	_draw_segment(image, Vector2i(center.x-radius+1,center.y+4),Vector2i(center.x+radius-1,center.y+4),2,COPPER_LIGHT)
	_pixel(image,center.x,center.y+6,VOID)


func _draw_chain_curve(image: Image, start: Vector2i, control: Vector2i, finish: Vector2i, color: Color) -> void:
	var previous: Vector2i = start
	for index: int in range(1, 13):
		var t: float = float(index)/12.0
		var point_f: Vector2 = Vector2(start)*(1.0-t)*(1.0-t)+Vector2(control)*2.0*(1.0-t)*t+Vector2(finish)*t*t
		var point: Vector2i = Vector2i(roundi(point_f.x),roundi(point_f.y))
		_draw_segment(image,previous,point,1,color)
		if index%2==0:
			_circle(image,point,1,GOLD_LIGHT)
		previous=point


func _draw_rune_ring(image: Image, center: Vector2i, radius: int, color: Color, frame: int) -> void:
	for point_index: int in range(24):
		var angle: float = TAU*float(point_index)/24.0+float(frame)*0.08
		var point: Vector2i = center+Vector2i(roundi(cos(angle)*radius),roundi(sin(angle)*radius*0.28))
		_pixel(image,point.x,point.y,color)


func _blit_scaled_nearest(target: Image, source: Image, origin: Vector2i, scale: int) -> void:
	for sy: int in range(source.get_height()):
		for sx: int in range(source.get_width()):
			var color: Color = source.get_pixel(sx,sy)
			if color.a<=0.0:
				continue
			_fill(target,Rect2i(origin.x+sx*scale,origin.y+sy*scale,scale,scale),color)


func _points(values: Array[int]) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	for index: int in range(0,values.size(),2):
		result.append(Vector2(values[index],values[index+1]))
	return result


func _poly(image: Image, points: PackedVector2Array, color: Color) -> void:
	if points.size() < 3:
		return
	var min_x: int = image.get_width() - 1
	var min_y: int = image.get_height() - 1
	var max_x: int = 0
	var max_y: int = 0
	for point: Vector2 in points:
		min_x = mini(min_x, floori(point.x))
		min_y = mini(min_y, floori(point.y))
		max_x = maxi(max_x, ceili(point.x))
		max_y = maxi(max_y, ceili(point.y))
	for y: int in range(maxi(0, min_y), mini(image.get_height() - 1, max_y) + 1):
		for x: int in range(maxi(0, min_x), mini(image.get_width() - 1, max_x) + 1):
			if Geometry2D.is_point_in_polygon(Vector2(x, y), points):
				image.set_pixel(x, y, color)


func _fill(image: Image, rect: Rect2i, color: Color) -> void:
	var clipped: Rect2i = rect.intersection(Rect2i(0,0,image.get_width(),image.get_height()))
	if clipped.size.x>0 and clipped.size.y>0:
		image.fill_rect(clipped,color)


func _pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x>=0 and y>=0 and x<image.get_width() and y<image.get_height():
		image.set_pixel(x,y,color)


func _circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y: int in range(center.y-radius,center.y+radius+1):
		for x: int in range(center.x-radius,center.x+radius+1):
			if Vector2i(x,y).distance_squared_to(center)<=radius*radius:
				_pixel(image,x,y,color)


func _draw_segment(image: Image, start: Vector2i, finish: Vector2i, width: int, color: Color) -> void:
	var dx: int = absi(finish.x-start.x)
	var sx: int = 1 if start.x<finish.x else -1
	var dy: int = -absi(finish.y-start.y)
	var sy: int = 1 if start.y<finish.y else -1
	var error: int = dx+dy
	var point: Vector2i = start
	while true:
		_circle(image,point,maxi(0,width/2),color)
		if point==finish:
			break
		var twice: int = 2*error
		if twice>=dy:
			error+=dy
			point.x+=sx
		if twice<=dx:
			error+=dx
			point.y+=sy
