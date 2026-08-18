extends SceneTree

## Deterministic 192x192 production-art generator for the Hollow Duchess Stage 2 rework.
## Gameplay timings and attack names remain stable while presentation families expand.

const ROOT: String = "res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess"
const PHASE_1_ROOT: String = ROOT + "/phase_01"
const PHASE_2_ROOT: String = ROOT + "/phase_02_unmasked"
const TRANSITION_ROOT: String = ROOT + "/phase_transition"
const EFFECTS_ROOT: String = ROOT + "/effects"
const ANIMATIONS_ROOT: String = ROOT + "/animations"
const FRAME_SIZE: int = 192
const LEGACY_SIZE: int = 96
const ART_OFFSET: Vector2i = Vector2i(48, 48)
const CLEAR: Color = Color(0.0, 0.0, 0.0, 0.0)
const OUTLINE: Color = Color("08070d")
const VOID: Color = Color("0b0710")
const BLACK_PLUM: Color = Color("17101d")
const DEEP_PLUM: Color = Color("2a1728")
const OXBLOOD: Color = Color("54202d")
const OXBLOOD_LIT: Color = Color("783243")
const OLD_GOLD: Color = Color("8f6d3e")
const GOLD_LIT: Color = Color("c3a067")
const PORCELAIN_SHADE: Color = Color("b9bcc0")
const PORCELAIN: Color = Color("e5e1da")
const BONE_SHADE: Color = Color("7f817b")
const BONE: Color = Color("c8c6b8")
const PALE_STEEL: Color = Color("d7dee1")
const STEEL: Color = Color("768793")
const COLD_MIST: Color = Color("617887", 0.72)
const COLD_LIGHT: Color = Color("9ebdcc", 0.82)
const DULL_CRIMSON: Color = Color("8d2638")
const LACE: Color = Color("6d5e68")

const PHASE_1_ANIMATIONS: Dictionary = {
	&"backstep": 4, &"death": 7, &"double_lunge": 8, &"elegant_walk": 6,
	&"fan_slash_active": 2, &"fan_slash_recovery": 5, &"fan_slash_windup": 4,
	&"final_waltz": 8, &"idle": 4, &"intro": 6, &"light_hit": 2,
	&"phantom_dance": 6, &"phase_transition": 6, &"rapier_thrust_active": 2,
	&"rapier_thrust_recovery": 4, &"rapier_thrust_windup": 4, &"riposte": 8,
	&"sidestep": 4, &"stagger": 4, &"turn": 4,
	&"dormant": 4, &"intro_back_facing": 4, &"intro_turn": 5,
	&"elegant_approach": 6, &"elegant_retreat": 6, &"backstep_riposte": 7,
	&"sidestep_cut": 6, &"hurt": 3, &"phase_transition_start": 4,
}

const PHASE_2_ANIMATIONS: Dictionary = {
	&"backstep": 4, &"death": 8, &"double_lunge": 8, &"elegant_walk": 6,
	&"fan_slash_active": 2, &"fan_slash_recovery": 5, &"fan_slash_windup": 4,
	&"final_waltz": 8, &"idle": 4, &"intro": 6, &"light_hit": 2,
	&"phantom_dance": 6, &"phase_transition": 6, &"rapier_thrust_active": 2,
	&"rapier_thrust_recovery": 4, &"rapier_thrust_windup": 4, &"riposte": 8,
	&"sidestep": 4, &"stagger": 4, &"turn": 4,
	&"phase_02_idle": 4, &"phase_02_walk": 6, &"phase_02_turn": 4,
	&"phase_02_sidestep": 4, &"phase_02_backstep": 4,
	&"phase_02_rapier_thrust": 6, &"phase_02_fan_slash": 6,
	&"double_waltz_lunge": 8, &"phantom_dancer_sweep": 7,
	&"final_waltz_crossing": 8, &"phase_02_light_hit": 2,
	&"phase_02_stagger": 4, &"phase_02_hurt": 3,
	&"death_start": 3, &"death_mask_shatter": 3, &"death_collapse": 4,
	&"death_dissolve": 5,
}

const TRANSITION_ANIMATIONS: Dictionary = {
	&"freeze_pose": 2, &"candles_out": 2, &"mask_crack": 3, &"mask_break": 3,
	&"head_distort": 3, &"arms_lengthen": 3, &"dress_tear": 3,
	&"spine_or_back_expand": 4, &"weapon_transform": 3, &"phase_02_reveal": 3,
}


func _initialize() -> void:
	if "--marionette-only" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EFFECTS_ROOT))
		_write_marionette_effect()
		print("HOLLOW_DUCHESS_MARIONETTE_EFFECT: PASS")
		quit(0)
		return
	for path: String in [PHASE_1_ROOT, PHASE_2_ROOT, TRANSITION_ROOT, EFFECTS_ROOT, ANIMATIONS_ROOT]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	var phase_1_total: int = _write_set(PHASE_1_ROOT, PHASE_1_ANIMATIONS, false)
	var phase_2_total: int = _write_set(PHASE_2_ROOT, PHASE_2_ANIMATIONS, true)
	var transition_total: int = _write_transition_set()
	_write_effects()
	_write_previews()
	print("HOLLOW_DUCHESS_ART_V2: PASS phase1=%d phase2=%d transition=%d total=%d" % [phase_1_total, phase_2_total, transition_total, phase_1_total + phase_2_total + transition_total])
	quit(0)


func _write_set(root: String, animations: Dictionary, phase_2: bool) -> int:
	var total: int = 0
	for animation_variant: Variant in animations.keys():
		var animation: StringName = animation_variant as StringName
		var count: int = int(animations[animation])
		var directory: String = root + "/" + String(animation)
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		for frame: int in range(count):
			var image: Image = _draw_character_frame(animation, frame, count, phase_2)
			var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
			if image.save_png(ProjectSettings.globalize_path(path)) != OK:
				push_error("Cannot save Duchess frame: %s" % path)
				quit(1)
				return total
			total += 1
	return total


func _write_transition_set() -> int:
	var total: int = 0
	var master_frames: Array[Image] = []
	var stage_index: int = 0
	for animation_variant: Variant in TRANSITION_ANIMATIONS.keys():
		var animation: StringName = animation_variant as StringName
		var count: int = int(TRANSITION_ANIMATIONS[animation])
		var directory: String = TRANSITION_ROOT + "/" + String(animation)
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		for frame: int in range(count):
			var progress: float = (float(stage_index) + float(frame + 1) / float(count)) / float(TRANSITION_ANIMATIONS.size())
			var image: Image = _draw_transition_frame(animation, frame, progress)
			var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
			image.save_png(ProjectSettings.globalize_path(path))
			master_frames.append(image)
			total += 1
		stage_index += 1
	var compatibility: String = TRANSITION_ROOT + "/phase_transition"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(compatibility))
	# Runtime duration is 4.4 seconds. Ten evenly selected poses communicate every transformation beat.
	for index: int in range(10):
		var source_index: int = roundi(float(index) * float(master_frames.size() - 1) / 9.0)
		master_frames[source_index].save_png(ProjectSettings.globalize_path("%s/phase_transition_%02d.png" % [compatibility, index + 1]))
	return total + 10


func _draw_character_frame(animation: StringName, frame: int, count: int, phase_2: bool) -> Image:
	var legacy: Image = _draw_character_frame_legacy(animation, frame, count, phase_2)
	var image: Image = Image.create(FRAME_SIZE, FRAME_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	image.blit_rect(legacy, Rect2i(Vector2i.ZERO, legacy.get_size()), ART_OFFSET)
	_draw_replication_details(image, animation, frame, phase_2)
	return image


func _draw_character_frame_legacy(animation: StringName, frame: int, count: int, phase_2: bool) -> Image:
	var image: Image = Image.create(LEGACY_SIZE, LEGACY_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	if animation in [&"death", &"death_start", &"death_mask_shatter", &"death_collapse", &"death_dissolve"]:
		_draw_death(image, animation, frame, count, phase_2)
		return image
	var pose: Dictionary = _pose(animation, frame, count, phase_2)
	if phase_2:
		_draw_phase_2(image, pose, animation, frame, count)
	else:
		_draw_phase_1(image, pose, animation, frame, count)
	return image


func _draw_replication_details(image: Image, animation: StringName, frame: int, phase_2: bool) -> void:
	if String(animation).contains("death") and frame >= 4:
		return
	var o: Vector2i = ART_OFFSET
	if not phase_2:
		# Porcelain court mask, widow crown, necklace and embroidered ballroom bodice.
		_draw_segment(image, o + Vector2i(39, 20), o + Vector2i(51, 20), 1, PORCELAIN)
		_draw_segment(image, o + Vector2i(45, 21), o + Vector2i(45, 29), 1, PORCELAIN_SHADE)
		for crown_point: int in range(5):
			var crown_x: int = o.x + 35 + crown_point * 5
			_draw_segment(image, Vector2i(crown_x, o.y + 13), Vector2i(crown_x + 2, o.y + 7 + abs(crown_point - 2) * 2), 2, OLD_GOLD)
		for jewel: int in range(4):
			_pixel(image, o.x + 38 + jewel * 5, o.y + 38 + (jewel % 2), GOLD_LIT)
		_draw_segment(image, o + Vector2i(40, 44), o + Vector2i(45, 69), 2, OXBLOOD_LIT)
	else:
		# Broken mask, exposed hollow face, spinal fan and torn ceremonial train.
		_draw_segment(image, o + Vector2i(37, 20), o + Vector2i(47, 27), 2, PORCELAIN_SHADE)
		_draw_segment(image, o + Vector2i(48, 18), o + Vector2i(54, 29), 1, DULL_CRIMSON)
		_pixel(image, o.x + 43, o.y + 23, COLD_LIGHT)
		_pixel(image, o.x + 49, o.y + 25, COLD_LIGHT)
		for rib: int in range(5):
			_draw_segment(image, o + Vector2i(43, 39), o + Vector2i(16 + rib * 14, 20 + (rib % 2) * 6), 2, BONE_SHADE)
		_draw_segment(image, o + Vector2i(28, 71), o + Vector2i(18, 86), 2, OXBLOOD)
		_draw_segment(image, o + Vector2i(61, 70), o + Vector2i(75, 86), 2, OXBLOOD)


func _pose(animation: StringName, frame: int, count: int, phase_2: bool) -> Dictionary:
	var x: int = 45 if not phase_2 else 43
	var top: int = 9 if not phase_2 else 13
	var bob: int = 0
	var lean: int = 0 if not phase_2 else 5
	var stride: int = 0
	var progress: float = float(frame) / float(maxi(1, count - 1))
	if animation in [&"idle", &"dormant", &"phase_02_idle"]:
		bob = [0, -1, -1, 0][frame % 4]
	if animation in [&"elegant_walk", &"elegant_approach", &"elegant_retreat", &"phase_02_walk"]:
		stride = [-4, -2, 1, 4, 2, -1][frame % 6]
		bob = [0, -1, 0, 1, -1, 0][frame % 6]
	if animation in [&"backstep", &"phase_02_backstep"]:
		x -= [0, 2, 5, 2][frame % 4]
	if animation in [&"sidestep", &"phase_02_sidestep"]:
		x += [-2, 1, 5, 2][frame % 4]
	if animation in [&"light_hit", &"hurt", &"phase_02_light_hit", &"phase_02_hurt", &"stagger", &"phase_02_stagger"]:
		x -= 2 + frame * 2
		lean = -3 if not phase_2 else 1
	if "thrust" in String(animation) or animation in [&"double_lunge", &"double_waltz_lunge", &"riposte", &"backstep_riposte"]:
		lean += roundi(progress * 6.0)
		x += roundi(maxf(0.0, progress - 0.25) * 6.0)
	if animation in [&"intro", &"intro_turn", &"turn", &"phase_02_turn"]:
		lean += roundi(sin(progress * PI) * 2.0)
	return {&"x": x, &"top": top + bob, &"lean": lean, &"stride": stride, &"progress": progress}


func _draw_phase_1(image: Image, pose: Dictionary, animation: StringName, frame: int, count: int) -> void:
	var x: int = int(pose[&"x"])
	var y: int = int(pose[&"top"])
	var lean: int = int(pose[&"lean"])
	var stride: int = int(pose[&"stride"])
	var back_facing: bool = animation in [&"dormant", &"intro_back_facing"] or (animation == &"intro" and frame < 2)
	_draw_phase_1_skirt(image, x, y, stride, animation, frame)
	_draw_phase_1_torso(image, x + lean, y, back_facing)
	_draw_phase_1_head(image, x + lean, y, back_facing, animation, frame)
	var rapier_pose: Dictionary = _phase_1_rapier_pose(animation, frame, count, x + lean, y)
	var fan_pose: Dictionary = _phase_1_fan_pose(animation, frame, count, x + lean, y)
	_draw_sleeved_arm(image, Vector2i(x + lean + 10, y + 29), rapier_pose[&"hand"] as Vector2i, true)
	_draw_rapier(image, rapier_pose[&"hand"] as Vector2i, rapier_pose[&"tip"] as Vector2i, false)
	_draw_sleeved_arm(image, Vector2i(x + lean - 10, y + 29), fan_pose[&"hand"] as Vector2i, false)
	_draw_fan(image, fan_pose[&"hand"] as Vector2i, float(fan_pose[&"angle"]), float(fan_pose[&"open"]), false)
	_draw_phase_fx(image, animation, frame, count, false, Vector2i(x, y))


func _draw_phase_1_skirt(image: Image, x: int, y: int, stride: int, animation: StringName, frame: int) -> void:
	var sway: int = 2 if animation in [&"elegant_walk", &"elegant_approach", &"elegant_retreat", &"sidestep", &"backstep"] and frame % 2 else 0
	_poly(image, _points([x - 13, y + 39, x + 14, y + 39, x + 25 + sway, y + 78, x + 18, y + 82, x + 5, y + 79, x - 5, y + 84, x - 26 + sway, y + 81]), OUTLINE)
	_poly(image, _points([x - 10, y + 41, x + 11, y + 41, x + 21 + sway, y + 77, x + 13, y + 78, x + 4, y + 75, x - 5, y + 80, x - 21 + sway, y + 78]), DEEP_PLUM)
	_poly(image, _points([x - 6, y + 43, x + 6, y + 43, x + 10, y + 77, x + 3, y + 74, x - 4, y + 79, x - 12, y + 76]), OXBLOOD)
	for fold: int in [-13, -6, 0, 7, 14]:
		_draw_segment(image, Vector2i(x + fold / 2, y + 45), Vector2i(x + fold + sway, y + 77), 1, OXBLOOD_LIT if fold in [-6, 7] else LACE)
	_draw_segment(image, Vector2i(x - 15, y + 57), Vector2i(x + 17, y + 55), 1, OLD_GOLD)
	_draw_segment(image, Vector2i(x - 19, y + 69), Vector2i(x + 20, y + 67), 1, LACE)
	# Two tiny pointed shoes and torn lace preserve feet/floor readability.
	_poly(image, _points([x - 8 - stride, y + 78, x - 1 - stride, y + 78, x + 2 - stride, y + 83, x - 10 - stride, y + 83]), OUTLINE)
	_poly(image, _points([x + 3 + stride, y + 77, x + 10 + stride, y + 78, x + 14 + stride, y + 82, x + 2 + stride, y + 82]), OUTLINE)
	for mist: int in range(4):
		var mx: int = x - 21 + (mist * 13 + frame * 3) % 43
		_pixel(image, mx, y + 84 - mist % 2, COLD_MIST)


func _draw_phase_1_torso(image: Image, x: int, y: int, back_facing: bool) -> void:
	_poly(image, _points([x - 14, y + 27, x - 9, y + 19, x + 9, y + 19, x + 15, y + 29, x + 11, y + 47, x - 11, y + 47]), OUTLINE)
	_poly(image, _points([x - 11, y + 28, x - 7, y + 22, x + 7, y + 22, x + 11, y + 29, x + 8, y + 43, x - 8, y + 43]), BLACK_PLUM)
	_poly(image, _points([x - 7, y + 24, x + 6, y + 24, x + 8, y + 33, x + 4, y + 41, x - 4, y + 41, x - 8, y + 33]), OXBLOOD)
	_draw_segment(image, Vector2i(x, y + 23), Vector2i(x, y + 43), 1, OLD_GOLD)
	_draw_segment(image, Vector2i(x - 9, y + 35), Vector2i(x + 9, y + 35), 1, GOLD_LIT)
	_circle(image, Vector2i(x, y + 30), 2, OLD_GOLD)
	if back_facing:
		_draw_segment(image, Vector2i(x - 7, y + 26), Vector2i(x + 7, y + 40), 1, OLD_GOLD)
	# Structured court shoulders, not a rectangular robe.
	_poly(image, _points([x - 20, y + 28, x - 15, y + 20, x - 7, y + 23, x - 11, y + 33]), OUTLINE)
	_poly(image, _points([x + 20, y + 28, x + 15, y + 20, x + 7, y + 23, x + 11, y + 33]), OUTLINE)
	_poly(image, _points([x - 17, y + 27, x - 14, y + 23, x - 9, y + 25, x - 12, y + 30]), OXBLOOD_LIT)
	_poly(image, _points([x + 17, y + 27, x + 14, y + 23, x + 9, y + 25, x + 12, y + 30]), DEEP_PLUM)


func _draw_phase_1_head(image: Image, x: int, y: int, back_facing: bool, animation: StringName, frame: int) -> void:
	# Hair and decayed aureole/headpiece.
	_circle(image, Vector2i(x, y + 11), 11, OUTLINE)
	_circle(image, Vector2i(x - 2, y + 10), 8, BLACK_PLUM)
	for pin: int in range(5):
		var px: int = x - 10 + pin * 5
		_draw_segment(image, Vector2i(px, y + 4), Vector2i(px - 1, y - 4 - (pin % 2) * 2), 2, OLD_GOLD)
		_pixel(image, px - 1, y - 5 - (pin % 2) * 2, GOLD_LIT)
	if not back_facing:
		_poly(image, _points([x - 6, y + 5, x + 6, y + 5, x + 8, y + 14, x + 3, y + 19, x - 4, y + 18, x - 8, y + 13]), OUTLINE)
		_poly(image, _points([x - 4, y + 6, x + 5, y + 6, x + 6, y + 13, x + 2, y + 17, x - 3, y + 16, x - 6, y + 12]), PORCELAIN)
		_draw_segment(image, Vector2i(x - 2, y + 10), Vector2i(x + 4, y + 10), 1, PORCELAIN_SHADE)
		_pixel(image, x + 4, y + 11, VOID)
		if animation in [&"phase_transition", &"phase_transition_start"]:
			_draw_segment(image, Vector2i(x, y + 6), Vector2i(x + frame - 1, y + 15), 1, DULL_CRIMSON)
	else:
		_draw_segment(image, Vector2i(x - 5, y + 7), Vector2i(x + 4, y + 15), 2, OLD_GOLD)


func _draw_phase_2(image: Image, pose: Dictionary, animation: StringName, frame: int, count: int) -> void:
	var x: int = int(pose[&"x"])
	var y: int = int(pose[&"top"])
	var lean: int = int(pose[&"lean"])
	var stride: int = int(pose[&"stride"])
	_draw_back_rib_fan(image, Vector2i(x + 2, y + 31), animation, frame)
	_draw_phase_2_skirt_and_legs(image, x, y, stride, animation, frame)
	_draw_phase_2_torso(image, x + lean, y)
	_draw_phase_2_head(image, x + lean, y, animation, frame)
	var rapier_pose: Dictionary = _phase_2_rapier_pose(animation, frame, count, x + lean, y)
	var fan_pose: Dictionary = _phase_2_fan_pose(animation, frame, count, x + lean, y)
	_draw_long_arm(image, Vector2i(x + lean + 9, y + 31), rapier_pose[&"hand"] as Vector2i)
	_draw_rapier(image, rapier_pose[&"hand"] as Vector2i, rapier_pose[&"tip"] as Vector2i, true)
	_draw_long_arm(image, Vector2i(x + lean - 9, y + 30), fan_pose[&"hand"] as Vector2i)
	_draw_fan(image, fan_pose[&"hand"] as Vector2i, float(fan_pose[&"angle"]), float(fan_pose[&"open"]), true)
	_draw_phase_fx(image, animation, frame, count, true, Vector2i(x, y))


func _draw_back_rib_fan(image: Image, center: Vector2i, animation: StringName, frame: int) -> void:
	var spread: float = 0.85
	if animation in [&"fan_slash_active", &"phase_02_fan_slash", &"phantom_dance", &"phantom_dancer_sweep", &"final_waltz", &"final_waltz_crossing"]:
		spread = 1.0
	for rib: int in range(7):
		var angle: float = lerpf(-2.35, -0.55, float(rib) / 6.0) * spread
		var length: float = 23.0 + float(rib % 3) * 3.0
		var finish: Vector2i = center + Vector2i(roundi(cos(angle) * length), roundi(sin(angle) * length))
		_draw_segment(image, center, finish, 3, OUTLINE)
		_draw_segment(image, center, finish, 1, BONE)
		_circle(image, finish, 2, BONE_SHADE)
		if rib < 6:
			var next_angle: float = lerpf(-2.35, -0.55, float(rib + 1) / 6.0) * spread
			var next_finish: Vector2i = center + Vector2i(roundi(cos(next_angle) * 23.0), roundi(sin(next_angle) * 23.0))
			_draw_segment(image, finish, next_finish, 1, LACE)
	if frame % 2:
		_pixel(image, center.x - 19, center.y - 17, COLD_LIGHT)


func _draw_phase_2_skirt_and_legs(image: Image, x: int, y: int, stride: int, animation: StringName, frame: int) -> void:
	var drag: int = 3 if animation in [&"phase_02_walk", &"elegant_walk", &"final_waltz", &"final_waltz_crossing"] else 0
	_poly(image, _points([x - 10, y + 42, x + 11, y + 41, x + 23 + drag, y + 74, x + 13, y + 69, x + 7, y + 82, x - 2, y + 73, x - 13, y + 83, x - 25 - drag, y + 77]), OUTLINE)
	_poly(image, _points([x - 7, y + 44, x + 8, y + 43, x + 19 + drag, y + 71, x + 10, y + 66, x + 5, y + 77, x - 2, y + 69, x - 12, y + 78, x - 20 - drag, y + 74]), DEEP_PLUM)
	_poly(image, _points([x - 5, y + 45, x + 4, y + 44, x + 7, y + 61, x + 1, y + 66, x - 5, y + 61, x - 10, y + 72]), OXBLOOD)
	# Visible skeletal legs create negative-space breaks in the gown.
	_draw_segment(image, Vector2i(x - 5, y + 58), Vector2i(x - 8 - stride, y + 82), 5, OUTLINE)
	_draw_segment(image, Vector2i(x - 5, y + 58), Vector2i(x - 8 - stride, y + 82), 2, BONE)
	_draw_segment(image, Vector2i(x + 5, y + 58), Vector2i(x + 11 + stride, y + 82), 5, OUTLINE)
	_draw_segment(image, Vector2i(x + 5, y + 58), Vector2i(x + 11 + stride, y + 82), 2, BONE_SHADE)
	for tear: int in range(5):
		var tx: int = x - 18 + tear * 8 + (frame % 2)
		_draw_segment(image, Vector2i(tx, y + 69), Vector2i(tx - 3 + tear % 2 * 6, y + 81), 1, OXBLOOD_LIT)
	for mist: int in range(5):
		_pixel(image, x - 23 + (mist * 11 + frame * 4) % 47, y + 84 - mist % 3, COLD_MIST)


func _draw_phase_2_torso(image: Image, x: int, y: int) -> void:
	_poly(image, _points([x - 13, y + 28, x - 7, y + 18, x + 8, y + 19, x + 14, y + 30, x + 9, y + 49, x - 10, y + 48]), OUTLINE)
	_poly(image, _points([x - 9, y + 28, x - 5, y + 22, x + 5, y + 22, x + 10, y + 30, x + 6, y + 43, x - 7, y + 43]), DEEP_PLUM)
	# Open bodice: complete rib cage, not a shader recolour.
	for rib: int in range(4):
		var ry: int = y + 27 + rib * 4
		_draw_segment(image, Vector2i(x - 7 + rib, ry), Vector2i(x, ry + 2), 2, BONE_SHADE)
		_draw_segment(image, Vector2i(x, ry + 2), Vector2i(x + 7 - rib, ry), 2, BONE)
	_draw_segment(image, Vector2i(x, y + 25), Vector2i(x, y + 44), 1, COLD_LIGHT)
	_poly(image, _points([x - 20, y + 30, x - 14, y + 21, x - 6, y + 23, x - 11, y + 34]), OUTLINE)
	_poly(image, _points([x + 20, y + 30, x + 14, y + 21, x + 6, y + 23, x + 11, y + 34]), OUTLINE)
	_draw_segment(image, Vector2i(x - 17, y + 26), Vector2i(x - 10, y + 31), 2, OXBLOOD_LIT)
	_draw_segment(image, Vector2i(x + 17, y + 26), Vector2i(x + 10, y + 31), 2, OLD_GOLD)


func _draw_phase_2_head(image: Image, x: int, y: int, animation: StringName, frame: int) -> void:
	_circle(image, Vector2i(x - 2, y + 10), 10, OUTLINE)
	_circle(image, Vector2i(x - 3, y + 9), 7, VOID)
	# Broken porcelain remains frame the void instead of becoming a normal face.
	_poly(image, _points([x - 9, y + 4, x - 4, y + 3, x - 5, y + 11, x - 10, y + 14]), PORCELAIN_SHADE)
	_poly(image, _points([x + 1, y + 2, x + 6, y + 6, x + 5, y + 11, x + 1, y + 8]), PORCELAIN)
	_pixel(image, x - 1, y + 9, DULL_CRIMSON)
	_pixel(image, x + 3, y + 10, DULL_CRIMSON)
	_poly(image, _points([x - 3, y + 13, x + 5, y + 13, x + 7, y + 21, x + 1, y + 25, x - 4, y + 18]), OUTLINE)
	_draw_segment(image, Vector2i(x, y + 14), Vector2i(x + 3, y + 21), 1, BONE)
	for pin: int in range(5):
		var px: int = x - 10 + pin * 5
		_draw_segment(image, Vector2i(px, y + 3), Vector2i(px - 2, y - 5 - pin % 2 * 2), 2, BONE_SHADE)
	if animation in [&"phase_02_hurt", &"phase_02_stagger", &"stagger"] and frame > 0:
		_pixel(image, x + 8, y + 12, COLD_LIGHT)


func _phase_1_rapier_pose(animation: StringName, frame: int, count: int, x: int, y: int) -> Dictionary:
	var hand: Vector2i = Vector2i(x + 14, y + 34)
	var tip: Vector2i = Vector2i(x + 38, y + 63)
	var p: float = float(frame) / float(maxi(1, count - 1))
	if "rapier_thrust" in String(animation) or animation in [&"double_lunge", &"riposte", &"backstep_riposte"]:
		hand = Vector2i(x + 8 + roundi(p * 8.0), y + 34 - roundi(p * 3.0))
		tip = Vector2i(69 + roundi(p * 25.0), y + 31 - roundi(p * 2.0))
	if animation in [&"intro", &"intro_turn"]:
		tip = Vector2i(x + 34, y + 55 - frame * 3)
	if animation in [&"stagger", &"hurt", &"light_hit"]:
		tip = Vector2i(x + 28, y + 70)
	if animation in [&"final_waltz", &"sidestep_cut"]:
		tip = Vector2i(92, y + 25 + (frame % 3) * 9)
	return {&"hand": hand, &"tip": tip}


func _phase_1_fan_pose(animation: StringName, frame: int, count: int, x: int, y: int) -> Dictionary:
	var hand: Vector2i = Vector2i(x - 13, y + 37)
	var angle: float = -2.45
	var open: float = 0.42
	var p: float = float(frame) / float(maxi(1, count - 1))
	if "fan_slash" in String(animation) or animation in [&"sidestep_cut", &"phantom_dance"]:
		hand = Vector2i(x - 8 + roundi(p * 9.0), y + 32 - roundi(sin(p * PI) * 8.0))
		angle = -2.4 + p * 2.7
		open = 1.0
	if animation == &"final_waltz":
		angle = -2.8 + p * 4.0
		open = 0.88
	return {&"hand": hand, &"angle": angle, &"open": open}


func _phase_2_rapier_pose(animation: StringName, frame: int, count: int, x: int, y: int) -> Dictionary:
	var hand: Vector2i = Vector2i(x + 18, y + 37)
	var tip: Vector2i = Vector2i(x + 45, y + 68)
	var p: float = float(frame) / float(maxi(1, count - 1))
	if "thrust" in String(animation) or animation in [&"double_lunge", &"double_waltz_lunge", &"riposte"]:
		hand = Vector2i(x + 11 + roundi(p * 9.0), y + 34)
		tip = Vector2i(72 + roundi(p * 23.0), y + 29 - roundi(p * 2.0))
	if animation in [&"final_waltz", &"final_waltz_crossing", &"phantom_dance", &"phantom_dancer_sweep"]:
		tip = Vector2i(94, y + 17 + (frame % 4) * 11)
	if animation in [&"phase_02_stagger", &"phase_02_hurt", &"stagger", &"light_hit"]:
		tip = Vector2i(x + 35, y + 76)
	return {&"hand": hand, &"tip": tip}


func _phase_2_fan_pose(animation: StringName, frame: int, count: int, x: int, y: int) -> Dictionary:
	var hand: Vector2i = Vector2i(x - 18, y + 39)
	var angle: float = -2.55
	var open: float = 0.65
	var p: float = float(frame) / float(maxi(1, count - 1))
	if "fan_slash" in String(animation) or animation in [&"phantom_dance", &"phantom_dancer_sweep", &"final_waltz", &"final_waltz_crossing"]:
		hand = Vector2i(x - 15 + roundi(p * 12.0), y + 34 - roundi(sin(p * PI) * 9.0))
		angle = -2.7 + p * 3.0
		open = 1.0
	return {&"hand": hand, &"angle": angle, &"open": open}


func _draw_sleeved_arm(image: Image, shoulder: Vector2i, hand: Vector2i, right_side: bool) -> void:
	_draw_segment(image, shoulder, hand, 9, OUTLINE)
	_draw_segment(image, shoulder, hand, 5, DEEP_PLUM if right_side else OXBLOOD)
	var elbow: Vector2i = Vector2i((shoulder + hand) / 2)
	_poly(image, _points([elbow.x - 4, elbow.y, elbow.x, elbow.y - 4, elbow.x + 5, elbow.y + 2, elbow.x, elbow.y + 7]), LACE)
	_circle(image, hand, 3, OUTLINE)
	_circle(image, hand, 2, PORCELAIN_SHADE)


func _draw_long_arm(image: Image, shoulder: Vector2i, hand: Vector2i) -> void:
	_draw_segment(image, shoulder, hand, 8, OUTLINE)
	_draw_segment(image, shoulder, hand, 4, BONE_SHADE)
	var elbow: Vector2i = Vector2i((shoulder + hand) / 2) + Vector2i(0, 2)
	_circle(image, elbow, 3, BONE)
	_circle(image, hand, 3, OUTLINE)
	_circle(image, hand, 2, BONE)
	var direction: Vector2 = Vector2(hand - shoulder).normalized()
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	for finger: int in range(3):
		_draw_segment(image, hand, hand + Vector2i(direction * float(4 + finger) + normal * float(finger - 1) * 2.0), 1, BONE)


func _draw_rapier(image: Image, hand: Vector2i, tip: Vector2i, bone_spined: bool) -> void:
	var direction: Vector2 = Vector2(tip - hand).normalized()
	if direction.length_squared() < 0.5:
		return
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var guard: Vector2 = Vector2(hand) + direction * 3.0
	var pommel: Vector2 = Vector2(hand) - direction * 8.0
	var blade_base: Vector2 = guard + direction * 5.0
	_draw_segment(image, Vector2i(pommel), Vector2i(guard), 5, OUTLINE)
	_draw_segment(image, Vector2i(pommel), Vector2i(guard), 2, OXBLOOD_LIT)
	_circle(image, Vector2i(pommel), 3, OUTLINE)
	_circle(image, Vector2i(pommel), 1, OLD_GOLD)
	# Complete swept court guard remains visible at native size.
	_draw_segment(image, Vector2i(guard - normal * 8.0), Vector2i(guard + normal * 8.0), 4, OUTLINE)
	_draw_segment(image, Vector2i(guard - normal * 7.0), Vector2i(guard + normal * 7.0), 2, OLD_GOLD)
	_circle(image, Vector2i(guard + normal * 5.0 - direction * 3.0), 4, OLD_GOLD)
	_draw_segment(image, Vector2i(blade_base), tip, 4 if bone_spined else 3, OUTLINE)
	_draw_segment(image, Vector2i(blade_base), tip, 2 if bone_spined else 1, BONE if bone_spined else PALE_STEEL)
	if bone_spined:
		var length: float = Vector2(tip - Vector2i(blade_base)).length()
		for spike_index: int in range(3):
			var center: Vector2 = blade_base + direction * (length * float(spike_index + 1) / 4.0)
			_draw_segment(image, Vector2i(center), Vector2i(center + normal * float(4 - spike_index % 2)), 2, BONE_SHADE)
	_pixel(image, tip.x, tip.y, PORCELAIN if not bone_spined else BONE)


func _draw_fan(image: Image, hand: Vector2i, angle: float, openness: float, bone_fan: bool) -> void:
	var ribs: int = 6
	var half_arc: float = 0.25 + openness * 0.65
	var radius: float = 10.0 + openness * 10.0
	_circle(image, hand, 3, OUTLINE)
	_circle(image, hand, 1, OLD_GOLD)
	var tips: Array[Vector2i] = []
	for rib: int in range(ribs):
		var fraction: float = float(rib) / float(ribs - 1)
		var rib_angle: float = angle - half_arc + fraction * half_arc * 2.0
		var tip: Vector2i = hand + Vector2i(roundi(cos(rib_angle) * radius), roundi(sin(rib_angle) * radius))
		tips.append(tip)
		_draw_segment(image, hand, tip, 3, OUTLINE)
		_draw_segment(image, hand, tip, 1, BONE if bone_fan else STEEL)
		_poly(image, _points([tip.x - 2, tip.y + 1, tip.x, tip.y - 4, tip.x + 3, tip.y + 1]), PORCELAIN_SHADE if bone_fan else PALE_STEEL)
	for index: int in range(tips.size() - 1):
		_draw_segment(image, tips[index], tips[index + 1], 2, OUTLINE)
		_draw_segment(image, tips[index], tips[index + 1], 1, PORCELAIN_SHADE if bone_fan else LACE)


func _draw_phase_fx(image: Image, animation: StringName, frame: int, count: int, phase_2: bool, origin: Vector2i) -> void:
	if animation in [&"fan_slash_active", &"phase_02_fan_slash", &"sidestep_cut"]:
		for arc: int in range(3):
			_draw_segment(image, origin + Vector2i(15 + arc * 5, 24 + arc * 5), origin + Vector2i(37 + arc * 7, 41 + arc * 8), 1, COLD_LIGHT if arc == 0 else COLD_MIST)
	if animation in [&"rapier_thrust_active", &"phase_02_rapier_thrust", &"double_lunge", &"double_waltz_lunge", &"riposte", &"backstep_riposte"] and frame >= count / 2:
		_draw_segment(image, origin + Vector2i(28, 28), Vector2i(95, origin.y + 30), 1, COLD_LIGHT)
	if animation in [&"phantom_dance", &"phantom_dancer_sweep", &"final_waltz", &"final_waltz_crossing"]:
		for echo: int in range(3):
			_pixel(image, origin.x - 24 + echo * 9 - frame * 2, origin.y + 31 + echo * 9, COLD_MIST)
	if animation in [&"stagger", &"hurt", &"phase_02_stagger", &"phase_02_hurt", &"light_hit", &"phase_02_light_hit"]:
		for shard: int in range(2 + frame):
			_pixel(image, origin.x + 10 + shard * 4, origin.y + 8 + shard * 5, PORCELAIN_SHADE if not phase_2 else BONE)


func _draw_transition_frame(animation: StringName, frame: int, progress: float) -> Image:
	var legacy: Image = _draw_transition_frame_legacy(animation, frame, progress)
	var image: Image = Image.create(FRAME_SIZE, FRAME_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	image.blit_rect(legacy, Rect2i(Vector2i.ZERO, legacy.get_size()), ART_OFFSET)
	_draw_replication_details(image, animation, frame, progress >= 0.54)
	return image


func _draw_transition_frame_legacy(animation: StringName, frame: int, progress: float) -> Image:
	var image: Image = Image.create(LEGACY_SIZE, LEGACY_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	if progress < 0.54:
		var pose: Dictionary = {&"x": 45, &"top": 9, &"lean": roundi(progress * 5.0), &"stride": 0, &"progress": progress}
		_draw_phase_1(image, pose, &"phase_transition", mini(frame + roundi(progress * 5.0), 5), 6)
	else:
		var pose_2: Dictionary = {&"x": 43, &"top": 13, &"lean": 3 + roundi(progress * 3.0), &"stride": 0, &"progress": progress}
		_draw_phase_2(image, pose_2, &"phase_transition", frame, 4)
	_draw_transition_overlay(image, animation, frame, progress)
	return image


func _draw_transition_overlay(image: Image, animation: StringName, frame: int, progress: float) -> void:
	var center: Vector2i = Vector2i(48, 22)
	if animation in [&"mask_crack", &"mask_break", &"head_distort"]:
		for crack: int in range(2 + frame * 2):
			var start: Vector2i = center + Vector2i(-7 + crack * 3, -6 + (crack * 5) % 11)
			_draw_segment(image, start, start + Vector2i(3 - crack % 2 * 6, 6), 1, DULL_CRIMSON)
	if animation in [&"mask_break", &"head_distort", &"arms_lengthen", &"dress_tear", &"spine_or_back_expand", &"weapon_transform", &"phase_02_reveal"]:
		var shard_count: int = 3 + roundi(progress * 10.0)
		for shard: int in range(shard_count):
			var point: Vector2i = center + Vector2i(-18 + (shard * 11 + frame * 5) % 39, -14 + (shard * 7 + frame * 3) % 31)
			_poly(image, _points([point.x - 2, point.y + 2, point.x, point.y - 3, point.x + 3, point.y + 1]), PORCELAIN_SHADE)
	if animation in [&"candles_out", &"mask_crack", &"mask_break"]:
		for mist: int in range(6):
			_pixel(image, 27 + (mist * 13 + frame * 4) % 45, 77 - mist * 4, COLD_MIST)
	if animation in [&"spine_or_back_expand", &"weapon_transform", &"phase_02_reveal"]:
		for ray: int in range(5):
			_draw_segment(image, Vector2i(45, 42), Vector2i(18 + ray * 14, 18 + (ray % 2) * 7), 1, BONE_SHADE)


func _draw_death(image: Image, animation: StringName, frame: int, count: int, phase_2: bool) -> void:
	var global_frame: int = frame
	if animation == &"death":
		global_frame = roundi(float(frame) * 14.0 / float(maxi(1, count - 1)))
	elif animation == &"death_mask_shatter":
		global_frame = 3 + frame
	elif animation == &"death_collapse":
		global_frame = 6 + frame
	elif animation == &"death_dissolve":
		global_frame = 10 + frame
	var collapse: float = clampf(float(global_frame) / 10.0, 0.0, 1.0)
	if global_frame < 7:
		var pose: Dictionary = {&"x": 43 - roundi(collapse * 4.0), &"top": 13 + roundi(collapse * 10.0), &"lean": 5 - roundi(collapse * 8.0), &"stride": 0, &"progress": collapse}
		_draw_phase_2(image, pose, &"phase_02_hurt", mini(frame, 2), 3)
	else:
		var y: int = 67 + mini(global_frame - 7, 3) * 5
		_poly(image, _points([15, y + 6, 29, y - 8, 56, y - 10, 83, y + 2, 78, y + 13, 27, y + 15]), OUTLINE)
		_poly(image, _points([20, y + 5, 32, y - 4, 54, y - 6, 76, y + 3, 70, y + 9, 31, y + 11]), DEEP_PLUM)
		_draw_segment(image, Vector2i(47, y - 5), Vector2i(93, y + 8), 3, BONE)
	var shard_count: int = maxi(0, global_frame - 2) * 3
	for shard: int in range(shard_count):
		var point: Vector2i = Vector2i(20 + (shard * 17 + global_frame * 7) % 67, 14 + (shard * 11 + global_frame * 3) % 68)
		var color: Color = PORCELAIN_SHADE if shard % 4 else COLD_MIST
		_pixel(image, point.x, point.y, color)


func _write_effects() -> void:
	_write_marionette_effect()
	var glint: Image = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	glint.fill(CLEAR)
	_draw_segment(glint, Vector2i(3, 12), Vector2i(21, 12), 1, PALE_STEEL)
	_draw_segment(glint, Vector2i(12, 3), Vector2i(12, 21), 1, COLD_LIGHT)
	_circle(glint, Vector2i(12, 12), 2, PORCELAIN)
	glint.save_png(ProjectSettings.globalize_path(EFFECTS_ROOT + "/rapier_glint.png"))
	for index: int in range(5):
		var shards: Image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
		shards.fill(CLEAR)
		for shard: int in range(3 + index * 3):
			var point: Vector2i = Vector2i(8 + (shard * 13 + index * 5) % 34, 7 + (shard * 9 + index * 4) % 35)
			_poly(shards, _points([point.x - 2, point.y + 2, point.x, point.y - 4, point.x + 3, point.y + 1]), PORCELAIN_SHADE)
		shards.save_png(ProjectSettings.globalize_path("%s/mask_shatter_%02d.png" % [EFFECTS_ROOT, index + 1]))


func _write_marionette_effect() -> void:
	var sheet: Image = Image.create(384, 192, false, Image.FORMAT_RGBA8)
	sheet.fill(CLEAR)
	_draw_marionette(sheet, 0, false)
	_draw_marionette(sheet, 192, true)
	sheet.save_png(ProjectSettings.globalize_path(EFFECTS_ROOT + "/phantom_dancer.png"))


func _draw_marionette(image: Image, offset_x: int, feminine: bool) -> void:
	var center_x: int = offset_x + 96
	var mask_center: Vector2i = Vector2i(center_x, 45)
	# Four taut strings make the summoned bodies read as controlled puppets.
	for string_x: int in [center_x - 16, center_x - 6, center_x + 8, center_x + 19]:
		_draw_segment(image, Vector2i(string_x, 4), Vector2i(string_x, 57), 1, COLD_LIGHT)
		_circle(image, Vector2i(string_x, 57), 2, OLD_GOLD)
	# Porcelain head and cracked mask.
	_circle(image, mask_center, 15 if feminine else 14, OUTLINE)
	_circle(image, mask_center, 11 if feminine else 10, PORCELAIN)
	_draw_segment(image, mask_center + Vector2i(-2, -8), mask_center + Vector2i(3, 8), 1, OXBLOOD)
	_pixel(image, center_x - 4, 43, DULL_CRIMSON)
	_pixel(image, center_x + 5, 43, COLD_LIGHT)
	if feminine:
		_poly(image, _points([
			center_x - 17, 31, center_x - 7, 22, center_x + 9, 24,
			center_x + 18, 34, center_x + 14, 50, center_x - 15, 49,
		]), BLACK_PLUM)
		# Restore the porcelain face above the hair mass so the second puppet
		# reads as a complete court marionette at gameplay scale.
		_circle(image, mask_center + Vector2i(1, 1), 9, PORCELAIN)
		_draw_segment(image, mask_center + Vector2i(-1, -6), mask_center + Vector2i(4, 7), 1, OXBLOOD)
		_pixel(image, center_x - 3, 44, DULL_CRIMSON)
		_pixel(image, center_x + 5, 44, COLD_LIGHT)
	else:
		_poly(image, _points([
			center_x - 15, 31, center_x - 9, 24, center_x + 12, 26,
			center_x + 17, 36, center_x + 11, 40, center_x - 13, 39,
		]), DEEP_PLUM)
	# Articulated torso, shoulder joints and court costume.
	_poly(image, _points([
		center_x - 19, 59, center_x - 12, 53, center_x + 13, 53,
		center_x + 20, 61, center_x + 13, 104, center_x - 13, 104,
	]), OUTLINE)
	_poly(image, _points([
		center_x - 14, 61, center_x - 9, 58, center_x + 9, 58,
		center_x + 14, 63, center_x + 9, 99, center_x - 9, 99,
	]), OXBLOOD if feminine else DEEP_PLUM)
	image.fill_rect(Rect2i(center_x - 3, 58, 6, 41), OLD_GOLD)
	_circle(image, Vector2i(center_x - 18, 62), 4, OLD_GOLD)
	_circle(image, Vector2i(center_x + 18, 62), 4, OLD_GOLD)
	# Both arms drive two short daggers forward; blade heights remain separated.
	_draw_segment(image, Vector2i(center_x + 17, 64), Vector2i(center_x + 39, 69), 7, OUTLINE)
	_draw_segment(image, Vector2i(center_x + 17, 65), Vector2i(center_x + 38, 69), 4, BONE_SHADE)
	_circle(image, Vector2i(center_x + 40, 69), 4, OLD_GOLD)
	_draw_segment(image, Vector2i(center_x + 41, 69), Vector2i(center_x + 68, 63), 5, OUTLINE)
	_draw_segment(image, Vector2i(center_x + 42, 69), Vector2i(center_x + 67, 63), 2, PALE_STEEL)
	_draw_segment(image, Vector2i(center_x + 14, 78), Vector2i(center_x + 36, 87), 7, OUTLINE)
	_draw_segment(image, Vector2i(center_x + 14, 78), Vector2i(center_x + 35, 86), 4, STEEL)
	_circle(image, Vector2i(center_x + 37, 87), 4, OLD_GOLD)
	_draw_segment(image, Vector2i(center_x + 38, 87), Vector2i(center_x + 62, 91), 5, OUTLINE)
	_draw_segment(image, Vector2i(center_x + 39, 87), Vector2i(center_x + 61, 91), 2, PALE_STEEL)
	# Rear arm counterbalances the attack and preserves a complete body silhouette.
	_draw_segment(image, Vector2i(center_x - 17, 66), Vector2i(center_x - 35, 80), 7, OUTLINE)
	_draw_segment(image, Vector2i(center_x - 16, 66), Vector2i(center_x - 34, 79), 4, BONE_SHADE)
	_circle(image, Vector2i(center_x - 35, 81), 4, OLD_GOLD)
	# Distinct lower bodies: split court tails for the man, torn skirt for the woman.
	if feminine:
		_poly(image, _points([
			center_x - 13, 97, center_x + 12, 97, center_x + 24, 128,
			center_x + 10, 132, center_x, 122, center_x - 11, 133,
			center_x - 25, 127,
		]), OUTLINE)
		_poly(image, _points([
			center_x - 9, 100, center_x + 9, 100, center_x + 18, 124,
			center_x + 7, 127, center_x, 116, center_x - 9, 128,
			center_x - 19, 123,
		]), OXBLOOD)
	else:
		image.fill_rect(Rect2i(center_x - 13, 100, 26, 16), OUTLINE)
		image.fill_rect(Rect2i(center_x - 9, 101, 18, 13), BLACK_PLUM)
	# Fully articulated legs and pointed ballroom shoes.
	_draw_segment(image, Vector2i(center_x - 8, 113), Vector2i(center_x - 18, 145), 9, OUTLINE)
	_draw_segment(image, Vector2i(center_x - 7, 114), Vector2i(center_x - 17, 144), 5, STEEL)
	_draw_segment(image, Vector2i(center_x + 8, 113), Vector2i(center_x + 23, 143), 9, OUTLINE)
	_draw_segment(image, Vector2i(center_x + 7, 114), Vector2i(center_x + 22, 142), 5, BONE_SHADE)
	_poly(image, _points([center_x - 25, 150, center_x - 18, 141, center_x - 7, 149]), OUTLINE)
	_poly(image, _points([center_x + 17, 148, center_x + 22, 140, center_x + 35, 149]), OUTLINE)
	# Small cold soul joints retain supernatural readability without reverting to silhouettes.
	for joint: Vector2i in [
		Vector2i(center_x - 18, 62), Vector2i(center_x + 18, 62),
		Vector2i(center_x - 8, 113), Vector2i(center_x + 8, 113),
	]:
		_circle(image, joint, 2, COLD_LIGHT)


func _write_previews() -> void:
	var cell_size: int = 288
	var columns: int = 5
	var board: Image = Image.create(columns * cell_size, 2 * cell_size, false, Image.FORMAT_RGBA8)
	board.fill(Color("101017"))
	var samples: Array[Dictionary] = [
		{&"p2": false, &"animation": &"idle", &"frame": 0},
		{&"p2": false, &"animation": &"rapier_thrust_active", &"frame": 1},
		{&"p2": false, &"animation": &"fan_slash_active", &"frame": 1},
		{&"p2": false, &"animation": &"intro", &"frame": 4},
		{&"p2": true, &"animation": &"phase_02_idle", &"frame": 0},
		{&"p2": true, &"animation": &"phase_02_rapier_thrust", &"frame": 4},
		{&"p2": true, &"animation": &"phase_02_fan_slash", &"frame": 4},
		{&"p2": true, &"animation": &"final_waltz_crossing", &"frame": 5},
		{&"p2": true, &"animation": &"death", &"frame": 6},
	]
	for index: int in range(samples.size()):
		var entry: Dictionary = samples[index]
		var animation: StringName = entry[&"animation"] as StringName
		var phase_2: bool = bool(entry[&"p2"])
		var count: int = int(PHASE_2_ANIMATIONS[animation]) if phase_2 else int(PHASE_1_ANIMATIONS[animation])
		var source: Image = _draw_character_frame(animation, int(entry[&"frame"]), count, phase_2)
		source.resize(cell_size, cell_size, Image.INTERPOLATE_NEAREST)
		var row: int = floori(float(index) / float(columns))
		var destination: Vector2i = Vector2i((index % columns) * cell_size, row * cell_size)
		board.blend_rect(source, Rect2i(0, 0, cell_size, cell_size), destination)
	board.save_png(ProjectSettings.globalize_path(ANIMATIONS_ROOT + "/hollow_duchess_stage_2_runtime_preview.png"))
	var silhouettes: Image = Image.create(768, 384, false, Image.FORMAT_RGBA8)
	silhouettes.fill(Color("d7d0c5"))
	var p1: Image = _to_silhouette(_draw_character_frame(&"idle", 0, 4, false))
	var p2: Image = _to_silhouette(_draw_character_frame(&"phase_02_idle", 0, 4, true))
	p1.resize(384, 384, Image.INTERPOLATE_NEAREST)
	p2.resize(384, 384, Image.INTERPOLATE_NEAREST)
	silhouettes.blend_rect(p1, Rect2i(0, 0, 384, 384), Vector2i.ZERO)
	silhouettes.blend_rect(p2, Rect2i(0, 0, 384, 384), Vector2i(384, 0))
	silhouettes.save_png(ProjectSettings.globalize_path(ANIMATIONS_ROOT + "/hollow_duchess_stage_2_silhouette_preview.png"))


func _to_silhouette(source: Image) -> Image:
	var result: Image = Image.create(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	result.fill(CLEAR)
	for py: int in range(source.get_height()):
		for px: int in range(source.get_width()):
			if source.get_pixel(px, py).a >= 0.2:
				result.set_pixel(px, py, Color.BLACK)
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
