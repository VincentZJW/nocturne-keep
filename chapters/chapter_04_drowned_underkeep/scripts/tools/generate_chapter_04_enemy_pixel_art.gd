extends SceneTree

## Produces the formal low-resolution Chapter IV enemy frames. Every frame is drawn
## directly on a transparent pixel canvas; no scaled concept art or smoothing is used.

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep/assets/enemies"
const CLEAR: Color = Color(0, 0, 0, 0)
const OUTLINE: Color = Color("081117")
const DEEP: Color = Color("101c24")
const IRON: Color = Color("354954")
const IRON_LIT: Color = Color("71868d")
const STEEL: Color = Color("a8b8b8")
const BONE: Color = Color("b8b09a")
const RUST: Color = Color("754538")
const RUST_LIT: Color = Color("a86648")
const PRISON_RED: Color = Color("682f36")
const MIRE: Color = Color("274a42")
const MIRE_LIT: Color = Color("4f7661")
const BOG: Color = Color("515b37")
const BOG_LIT: Color = Color("84905b")
const SOUL: Color = Color("73b7ba")
const SOUL_LIT: Color = Color("c2e4df")
const GOLD: Color = Color("9a7440")
const FRAME_SIZE: int = 128
const LEGACY_SIZE: int = 96
const ART_OFFSET: Vector2i = Vector2i(16, 16)

const ROLES: Array[String] = [
	"drowned_gaoler", "chainbound_convict", "mire_harpooner",
	"sunken_shield_penitent", "bog_toad", "sewer_maw",
	"underkeep_executioner",
]

const ACTIONS: Dictionary = {
	"drowned_gaoler": ["jailer_cleave", "hook_drag", "shoulder_check"],
	"chainbound_convict": ["chain_sweep", "shackle_slam", "drag"],
	"mire_harpooner": ["harpoon_shot", "hooked_harpoon", "close_thrust"],
	"sunken_shield_penitent": ["shield_bash", "rusted_thrust", "shield_crush"],
	"mirefin_raider": ["claw_swipe", "mire_lunge", "fin_bite"],
	"bog_toad": ["leap_crush", "mud_burst", "tongue_lash"],
	"sewer_maw": ["sewer_bite", "ambush", "latch"],
	"underkeep_executioner": ["executioner_cleave", "chain_reaper", "gallows_slam"],
}


func _initialize() -> void:
	var total: int = 0
	for role: String in ROLES:
		var definitions: Dictionary = _animation_definitions(role)
		for animation: String in definitions:
			var count: int = int(definitions[animation])
			var directory: String = "%s/%s/sprites/%s" % [ROOT, role, animation]
			if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
				push_error("Cannot create %s" % directory)
				quit(1)
				return
			for frame: int in range(count):
				var image: Image = _draw_frame(role, animation, frame, count)
				var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
				if image.save_png(ProjectSettings.globalize_path(path)) != OK:
					push_error("Cannot save %s" % path)
					quit(1)
					return
				total += 1
		_write_reference_sheet(role)
	if not _write_shield_states():
		quit(1)
		return
	print("CH4 FORMAL ENEMY ART | PASS roles=%d frames=%d" % [ROLES.size(), total])
	quit(0)


func _animation_definitions(role: String) -> Dictionary:
	var result: Dictionary = {
		"idle": 4, "walk": 6, "alert": 3, "turn": 3,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 6,
	}
	if role == "sewer_maw":
		result["hidden"] = 4
	if role == "sunken_shield_penitent":
		result["guard_break"] = 4
	for action: String in ACTIONS[role]:
		result["%s_windup" % action] = 5
		result["%s_active" % action] = 2
		result["%s_recovery" % action] = 5
	return result


func _draw_frame(role: String, animation: String, frame: int, count: int) -> Image:
	var legacy: Image = Image.create(LEGACY_SIZE, LEGACY_SIZE, false, Image.FORMAT_RGBA8)
	legacy.fill(CLEAR)
	var phase: float = float(frame) / float(maxi(1, count - 1))
	var stage: String = "base"
	if animation.ends_with("_windup"):
		stage = "windup"
	elif animation.ends_with("_active"):
		stage = "active"
	elif animation.ends_with("_recovery"):
		stage = "recovery"
	elif animation in ["light_hit", "hurt", "stagger", "guard_break"]:
		stage = "hurt"
	elif animation == "death":
		stage = "death"
	elif animation == "hidden":
		stage = "hidden"
	var bob: int = 0
	if animation == "idle":
		bob = [0, -1, -1, 0][frame]
	elif animation == "walk":
		bob = [0, -2, -1, 0, -2, -1][frame]
	match role:
		"drowned_gaoler": _draw_humanoid(legacy, role, animation, stage, frame, phase, bob, 1.0)
		"chainbound_convict": _draw_convict(legacy, animation, stage, frame, phase, bob)
		"mire_harpooner": _draw_harpooner(legacy, animation, stage, frame, phase, bob)
		"sunken_shield_penitent": _draw_humanoid(legacy, role, animation, stage, frame, phase, bob, 1.12)
		"bog_toad": _draw_toad(legacy, animation, stage, frame, phase, bob)
		"sewer_maw": _draw_maw(legacy, animation, stage, frame, phase, bob)
		"underkeep_executioner": _draw_executioner(legacy, animation, stage, frame, phase, bob)
	var image: Image = Image.create(FRAME_SIZE, FRAME_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	image.blit_rect(legacy, Rect2i(0, 0, LEGACY_SIZE, LEGACY_SIZE), ART_OFFSET)
	_draw_replication_details(image, role, animation, stage, frame, phase, bob)
	return image


func _draw_replication_details(img: Image, role: String, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "death":
		return
	match role:
		"drowned_gaoler": _detail_gaoler(img, animation, stage, frame, phase, bob)
		"chainbound_convict": _detail_convict(img, animation, stage, frame, phase, bob)
		"mire_harpooner": _detail_harpooner(img, animation, stage, frame, phase, bob)
		"sunken_shield_penitent": _detail_penitent(img, animation, stage, frame, phase, bob)
		"bog_toad": _detail_toad(img, animation, stage, frame, phase, bob)
		"sewer_maw": _detail_maw(img, animation, stage, frame, phase, bob)
		"underkeep_executioner": _detail_executioner(img, animation, stage, frame, phase, bob)


func _detail_gaoler(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	var x: int = 59 + (5 if stage == "active" else -4 if stage in ["windup", "hurt"] else 0)
	var y: int = 29 + bob
	# Distinct drowned prison helm, leather gorget and key-studded coat.
	_poly(img, _pts([x-12,y+1,x-7,y-7,x+3,y-9,x+12,y-2,x+9,y+3,x-9,y+4]), OUTLINE)
	_poly(img, _pts([x-8,y,x-5,y-4,x+2,y-6,x+8,y-1,x+6,y+1,x-7,y+2]), IRON_LIT)
	_segment(img, Vector2i(x-8,y+23), Vector2i(x+10,y+21), 3, RUST)
	for clasp: int in range(4):
		_ellipse(img, Vector2i(x-7+clasp*5,y+55), 1, 1, GOLD)
	_chain(img, Vector2i(x-12,y+62), Vector2i(x-24,y+76), STEEL)
	_draw_key_ring(img, Vector2i(x-25,y+76))


func _detail_convict(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	var x: int = 61 + (6 if stage == "active" else -5 if stage in ["windup", "hurt"] else 0)
	var y: int = 24 + bob
	# The concept's wooden punishment yoke is the primary silhouette identifier.
	_rect(img, Rect2i(x-35,y+21,70,9), OUTLINE)
	_rect(img, Rect2i(x-32,y+23,64,5), RUST)
	for bolt_x: int in [x-27,x-14,x+14,x+27]: _ellipse(img, Vector2i(bolt_x,y+25), 1, 1, STEEL)
	_segment(img, Vector2i(x-29,y+29), Vector2i(x-34,y+49), 4, IRON)
	_segment(img, Vector2i(x+29,y+29), Vector2i(x+35,y+49), 4, IRON)
	_chain_curve(img, Vector2i(x-30,y+47), Vector2i(x-47,y+63), Vector2i(x-39,y+83), STEEL)
	_chain_curve(img, Vector2i(x+31,y+47), Vector2i(x+48,y+62), Vector2i(x+43,y+81), STEEL)


func _detail_harpooner(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	var x: int = 55 + (5 if stage == "active" else -3 if stage in ["windup", "hurt"] else 0)
	var y: int = 29 + bob
	# Fish-bone helm crown and belt winch/rope coil.
	for spike: int in range(5):
		_poly(img, _pts([x-10+spike*5,y+3,x-8+spike*5,y-8-(spike%2)*3,x-5+spike*5,y+4]), BONE)
	_ellipse(img, Vector2i(x-11,y+58), 8, 8, OUTLINE)
	_ellipse(img, Vector2i(x-11,y+58), 5, 5, GOLD)
	_ellipse(img, Vector2i(x-11,y+58), 2, 2, DEEP)
	_chain_curve(img, Vector2i(x-8,y+58), Vector2i(x+16,y+72), Vector2i(x+29,y+54), IRON_LIT)
	for patch: int in range(3): _segment(img, Vector2i(x-7,y+35+patch*7), Vector2i(x+8,y+33+patch*7), 1, SOUL)


func _detail_penitent(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	var x: int = 59 + (5 if stage == "active" else -4 if stage in ["windup", "hurt"] else 0)
	var y: int = 29 + bob
	# Penitent scripture tags and asymmetric cage pauldrons remain after the shield breaks.
	for strip: int in range(3):
		var sx: int = x-12+strip*9
		_rect(img, Rect2i(sx,y+46,5,17+strip*2), BONE)
		_segment(img, Vector2i(sx+1,y+50), Vector2i(sx+3,y+50), 1, PRISON_RED)
	_poly(img, _pts([x-18,y+19,x-13,y+12,x-6,y+17,x-10,y+29]), IRON_LIT)
	_poly(img, _pts([x+18,y+19,x+13,y+12,x+7,y+17,x+11,y+29]), RUST_LIT)


func _detail_toad(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	var jump: int = -12 if stage == "active" else -roundi(phase*7.0) if stage == "windup" else 0
	var x: int = 62 + (8 if stage == "active" else 0)
	var y: int = 57 + bob + jump
	# Bone growths, layered wet hide, pustules, teeth and a dragging chain.
	for ridge: int in range(6):
		var rx: int = x-20+ridge*8
		_poly(img, _pts([rx,y-15-(ridge%2)*3,rx+3,y-27-(ridge%3)*2,rx+6,y-14]), BONE)
	for wart: Vector2i in [Vector2i(-20,-6),Vector2i(-11,-14),Vector2i(3,-16),Vector2i(18,-7),Vector2i(12,4),Vector2i(-4,7)]:
		_ellipse(img, Vector2i(x+wart.x,y+wart.y), 2, 2, BOG_LIT)
		_pixel(img,x+wart.x,y+wart.y-1,SOUL)
	_segment(img, Vector2i(x-16,y+8), Vector2i(x+18,y+8), 2, OUTLINE)
	for tooth: int in range(6): _poly(img,_pts([x-13+tooth*5,y+8,x-11+tooth*5,y+13,x-8+tooth*5,y+8]),BONE)
	_chain_curve(img, Vector2i(x-24,y+13), Vector2i(x-43,y+25), Vector2i(x-48,y+39), IRON_LIT)
	for drip: int in range(4): _segment(img,Vector2i(x-12+drip*8,y+22),Vector2i(x-12+drip*8,y+27+(drip%2)*3),1,MIRE_LIT)


func _detail_maw(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "hidden":
		return
	var x: int = 60 + (10 if stage == "active" else 0)
	var y: int = 65 + bob - (8 if stage == "windup" else 0)
	# Long plated sewer predator silhouette: ribs, dorsal plates and torn cage debris.
	_poly(img,_pts([x-42,y+4,x-32,y-13,x-20,y-19,x-9,y-17,x-15,y+15,x-34,y+20]),OUTLINE)
	_poly(img,_pts([x-38,y+4,x-29,y-10,x-20,y-15,x-13,y-13,x-19,y+11,x-33,y+16]),MIRE)
	for plate: int in range(7):
		var px: int=x-34+plate*9
		_poly(img,_pts([px,y-8-(plate%2)*3,px+4,y-20-(plate%3)*2,px+8,y-7]),IRON_LIT if plate%2==0 else BONE)
	for rib: int in range(5): _segment(img,Vector2i(x-31+rib*7,y+4),Vector2i(x-27+rib*7,y+17),2,BONE)
	for claw: int in range(4):
		var cx: int=x-29+claw*14
		_segment(img,Vector2i(cx,y+16),Vector2i(cx-5+(claw%2)*10,y+29),4,IRON)
		_poly(img,_pts([cx-7+(claw%2)*10,y+28,cx-2+(claw%2)*10,y+31,cx-8+(claw%2)*10,y+33]),BONE)
	_segment(img,Vector2i(x+5,y+3),Vector2i(x+29,y+5),2,PRISON_RED)
	_rect(img,Rect2i(x-46,y+7,3,22),IRON); _segment(img,Vector2i(x-51,y+8),Vector2i(x-39,y+8),3,RUST)


func _detail_executioner(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	var x: int = 58 + (5 if stage == "active" else -4 if stage in ["windup", "hurt"] else 0)
	var y: int = 24 + bob
	# Layered execution cuirass, hanging keys and the full hooked axe blade.
	for plate: int in range(4): _segment(img,Vector2i(x-17,y+37+plate*8),Vector2i(x+18,y+35+plate*8),3,IRON_LIT if plate%2==0 else RUST)
	_chain(img,Vector2i(x-21,y+31),Vector2i(x+22,y+31),GOLD)
	_draw_key_ring(img,Vector2i(x-23,y+69))
	var blade_center: Vector2i=Vector2i(x+31,y+56)
	if stage=="windup": blade_center=Vector2i(x-28-roundi(phase*10.0),y+15-roundi(phase*12.0))
	elif stage=="active": blade_center=Vector2i(111,y+39+frame*9)
	_poly(img,_pts([blade_center.x-4,blade_center.y-20,blade_center.x+14,blade_center.y-12,blade_center.x+18,blade_center.y+3,blade_center.x+6,blade_center.y+16,blade_center.x-8,blade_center.y+12,blade_center.x+2,blade_center.y]),OUTLINE)
	_poly(img,_pts([blade_center.x,blade_center.y-15,blade_center.x+10,blade_center.y-9,blade_center.x+13,blade_center.y+1,blade_center.x+5,blade_center.y+10,blade_center.x-2,blade_center.y+8,blade_center.x+6,blade_center.y]),STEEL)


func _draw_humanoid(img: Image, role: String, animation: String, stage: String, frame: int, phase: float, bob: int, scale_factor: float) -> void:
	if stage == "death":
		_draw_fallen_body(img, frame, true)
		return
	var stride: int = [-5, -2, 2, 5, 2, -2][frame] if animation == "walk" else 0
	var x: int = 43 + (5 if stage == "active" else -4 if stage in ["windup", "hurt"] else 0)
	var y: int = 13 + bob
	var wide: int = roundi(13.0 * scale_factor)
	# Boots, greaves and separate legs.
	_segment(img, Vector2i(x - 7, y + 49), Vector2i(x - 9 - stride, 86), 9, OUTLINE)
	_segment(img, Vector2i(x + 7, y + 49), Vector2i(x + 10 + stride, 86), 9, OUTLINE)
	_segment(img, Vector2i(x - 7, y + 50), Vector2i(x - 9 - stride, 85), 5, IRON)
	_segment(img, Vector2i(x + 7, y + 50), Vector2i(x + 10 + stride, 85), 5, IRON_LIT)
	# Layered prison coat and corroded cuirass.
	_poly(img, _pts([x-wide,y+26,x-10,y+19,x+10,y+19,x+wide,y+27,x+12,y+61,x+5,y+68,x,y+62,x-5,y+69,x-13,y+61]), OUTLINE)
	_poly(img, _pts([x-wide+3,y+28,x-8,y+22,x+8,y+22,x+wide-3,y+28,x+9,y+58,x+4,y+64,x,y+58,x-4,y+65,x-10,y+58]), DEEP)
	_poly(img, _pts([x-8,y+25,x+8,y+24,x+7,y+48,x-7,y+50]), IRON)
	_segment(img, Vector2i(x-6,y+30), Vector2i(x+6,y+28), 2, RUST_LIT)
	_segment(img, Vector2i(x-5,y+38), Vector2i(x+7,y+36), 2, IRON_LIT)
	for rivet: int in range(4):
		_pixel(img, x-6+rivet*4, y+45, STEEL)
	# Helmet has prison bars and cold drowned eyes.
	_poly(img, _pts([x-10,y+3,x-5,y-2,x+6,y,x+11,y+7,x+8,y+20,x-7,y+21,x-12,y+13]), OUTLINE)
	_poly(img, _pts([x-8,y+4,x-4,y,x+5,y+2,x+8,y+7,x+6,y+18,x-5,y+18,x-9,y+12]), IRON)
	for bar: int in range(4):
		_segment(img, Vector2i(x-5+bar*3,y+6), Vector2i(x-5+bar*3,y+16), 1, STEEL)
	_pixel(img, x+4, y+10, SOUL_LIT)
	# Shoulder cages and chain collar.
	_poly(img, _pts([x-wide-3,y+27,x-wide+2,y+18,x-8,y+20,x-10,y+31]), OUTLINE)
	_poly(img, _pts([x+wide+3,y+27,x+wide-2,y+18,x+8,y+20,x+10,y+31]), OUTLINE)
	_poly(img, _pts([x-wide,y+26,x-wide+3,y+21,x-10,y+22,x-11,y+28]), RUST)
	_poly(img, _pts([x+wide,y+26,x+wide-3,y+21,x+10,y+22,x+11,y+28]), IRON_LIT)
	_chain(img, Vector2i(x-9,y+22), Vector2i(x+9,y+22), STEEL)
	var hand: Vector2i = Vector2i(x+wide+7, y+43)
	var weapon_tip: Vector2i = Vector2i(x+33, y+67)
	if stage == "windup": weapon_tip = Vector2i(x-25-roundi(phase*10.0),y+25-roundi(phase*18.0))
	elif stage == "active": weapon_tip = Vector2i(92,y+37+frame*8)
	elif stage == "recovery": weapon_tip = Vector2i(91-roundi(phase*43.0),y+42+roundi(phase*25.0))
	_segment(img, Vector2i(x+9,y+29), hand, 8, OUTLINE)
	_segment(img, Vector2i(x+9,y+29), hand, 4, IRON_LIT)
	_draw_gaoler_weapon(img, hand, weapon_tip, role == "sunken_shield_penitent")
	if role == "sunken_shield_penitent":
		# The shield is a separate runtime layer; visible arm posture remains readable after break.
		_segment(img, Vector2i(x-9,y+30), Vector2i(x-18,y+45), 8, OUTLINE)
		_segment(img, Vector2i(x-9,y+30), Vector2i(x-18,y+45), 4, RUST)
	else:
		_segment(img, Vector2i(x-9,y+30), Vector2i(x-17,y+48), 8, OUTLINE)
		_segment(img, Vector2i(x-9,y+30), Vector2i(x-17,y+48), 4, IRON)
		_draw_key_ring(img, Vector2i(x-20,y+57))


func _draw_convict(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "death":
		_draw_fallen_body(img, frame, false)
		return
	var x: int = 45 + (6 if stage == "active" else -5 if stage in ["windup", "hurt"] else 0)
	var y: int = 8 + bob
	var stride: int = [-4,-2,2,4,2,-2][frame] if animation == "walk" else 0
	_segment(img,Vector2i(x-12,y+55),Vector2i(x-15-stride,88),13,OUTLINE)
	_segment(img,Vector2i(x+11,y+55),Vector2i(x+15+stride,88),13,OUTLINE)
	_segment(img,Vector2i(x-12,y+55),Vector2i(x-15-stride,87),8,RUST)
	_segment(img,Vector2i(x+11,y+55),Vector2i(x+15+stride,87),8,IRON)
	_poly(img,_pts([x-22,y+26,x-14,y+16,x+13,y+15,x+23,y+27,x+19,y+62,x+10,y+70,x-13,y+69,x-21,y+59]),OUTLINE)
	_poly(img,_pts([x-18,y+28,x-12,y+20,x+11,y+19,x+19,y+29,x+15,y+58,x+8,y+65,x-10,y+64,x-17,y+56]),RUST)
	# Bent cage mask and shackled wrists.
	_poly(img,_pts([x-13,y+2,x-6,y-4,x+8,y-2,x+14,y+7,x+10,y+23,x-10,y+22,x-15,y+12]),OUTLINE)
	_poly(img,_pts([x-10,y+3,x-5,y,x+7,y+1,x+10,y+7,x+7,y+19,x-7,y+19,x-11,y+11]),IRON)
	for bar: int in range(5): _segment(img,Vector2i(x-7+bar*3,y+4),Vector2i(x-8+bar*3,y+18),2,STEEL)
	_pixel(img,x+5,y+10,SOUL)
	var left: Vector2i = Vector2i(x-27,y+44)
	var right: Vector2i = Vector2i(x+27,y+43)
	var ball: Vector2i = Vector2i(x+37,y+72)
	if stage == "windup": ball = Vector2i(x-28-roundi(phase*14.0),y+36-roundi(phase*18.0))
	elif stage == "active": ball = Vector2i(91,y+32+frame*14)
	elif stage == "recovery": ball = Vector2i(91-roundi(phase*38.0),y+45+roundi(phase*24.0))
	_segment(img,Vector2i(x-16,y+29),left,12,OUTLINE); _segment(img,Vector2i(x-16,y+29),left,7,RUST_LIT)
	_segment(img,Vector2i(x+16,y+29),right,12,OUTLINE); _segment(img,Vector2i(x+16,y+29),right,7,IRON_LIT)
	_draw_shackle(img,left); _draw_shackle(img,right)
	_chain_curve(img,right,Vector2i((right.x+ball.x)/2,min(right.y,ball.y)-18),ball,STEEL)
	_ellipse(img,ball,8,8,OUTLINE); _ellipse(img,ball,5,5,IRON)


func _draw_harpooner(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "death": _draw_fallen_body(img,frame,false); return
	var x: int = 39+(5 if stage=="active" else -3 if stage in ["windup","hurt"] else 0)
	var y: int = 13+bob
	var stride: int = [-5,-2,2,5,2,-2][frame] if animation=="walk" else 0
	_segment(img,Vector2i(x-6,y+48),Vector2i(x-9-stride,87),7,OUTLINE); _segment(img,Vector2i(x+6,y+48),Vector2i(x+9+stride,87),7,OUTLINE)
	_segment(img,Vector2i(x-6,y+49),Vector2i(x-9-stride,86),4,MIRE); _segment(img,Vector2i(x+6,y+49),Vector2i(x+9+stride,86),4,MIRE_LIT)
	_poly(img,_pts([x-12,y+20,x+10,y+19,x+14,y+57,x+7,y+65,x,y+59,x-6,y+67,x-14,y+57]),OUTLINE)
	_poly(img,_pts([x-9,y+23,x+8,y+22,x+10,y+54,x+5,y+61,x,y+55,x-5,y+63,x-10,y+54]),MIRE)
	# Fishbone ribs and pointed diver mask.
	for rib: int in range(4): _segment(img,Vector2i(x-7,y+29+rib*5),Vector2i(x+8,y+27+rib*5),2,BONE)
	_poly(img,_pts([x-9,y+3,x-3,y-2,x+8,y+2,x+12,y+10,x+5,y+19,x-8,y+17,x-12,y+10]),OUTLINE)
	_poly(img,_pts([x-6,y+4,x-2,y+1,x+6,y+3,x+8,y+9,x+3,y+15,x-6,y+14,x-9,y+9]),IRON)
	_pixel(img,x+5,y+8,SOUL_LIT)
	var grip: Vector2i = Vector2i(x+12,y+37)
	var tip: Vector2i = Vector2i(x+50,y+29)
	if stage=="windup": tip=Vector2i(x-31-roundi(phase*8.0),y+24)
	elif stage=="active": tip=Vector2i(95,y+30+frame*2)
	elif stage=="recovery": tip=Vector2i(94-roundi(phase*42.0),y+29+roundi(phase*5.0))
	_segment(img,Vector2i(x+8,y+28),grip,7,OUTLINE); _segment(img,Vector2i(x+8,y+28),grip,4,MIRE_LIT)
	_draw_harpoon(img,grip,tip)
	_chain_curve(img,grip,Vector2i(x+20,y+61),Vector2i(x-4,y+68),IRON_LIT)


func _draw_raider(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage=="death": _draw_creature_death(img,frame,MIRE); return
	var x: int = 42+(9 if stage=="active" else -5 if stage in ["windup","hurt"] else 0)
	var y: int = 21+bob
	var stride: int = [-7,-3,3,7,3,-3][frame] if animation=="walk" else 0
	# Digitigrade legs, hunched amphibian torso and dorsal fin.
	_segment(img,Vector2i(x-8,y+39),Vector2i(x-15-stride,y+66),9,OUTLINE); _segment(img,Vector2i(x+7,y+39),Vector2i(x+13+stride,y+66),9,OUTLINE)
	_segment(img,Vector2i(x-8,y+39),Vector2i(x-15-stride,y+65),5,MIRE_LIT); _segment(img,Vector2i(x+7,y+39),Vector2i(x+13+stride,y+65),5,MIRE)
	_poly(img,_pts([x-18,y+20,x-10,y+8,x+8,y+7,x+18,y+19,x+13,y+46,x-8,y+49,x-20,y+37]),OUTLINE)
	_poly(img,_pts([x-15,y+20,x-8,y+11,x+7,y+10,x+14,y+20,x+10,y+42,x-7,y+45,x-16,y+35]),MIRE)
	_poly(img,_pts([x-7,y+9,x-3,y-4,x+2,y+8,x+8,y-2,x+10,y+12]),MIRE_LIT)
	_poly(img,_pts([x-13,y+7,x-5,y+1,x+7,y+2,x+14,y+9,x+10,y+20,x-8,y+20,x-16,y+14]),OUTLINE)
	_poly(img,_pts([x-10,y+8,x-4,y+4,x+6,y+5,x+10,y+10,x+7,y+16,x-7,y+17,x-12,y+13]),MIRE_LIT)
	_pixel(img,x+6,y+10,SOUL_LIT)
	var claw: Vector2i=Vector2i(x+25,y+34)
	if stage=="windup": claw=Vector2i(x-20-roundi(phase*10.0),y+24-roundi(phase*8.0))
	elif stage=="active": claw=Vector2i(91,y+28+frame*6)
	_segment(img,Vector2i(x+12,y+24),claw,8,OUTLINE); _segment(img,Vector2i(x+12,y+24),claw,4,MIRE_LIT)
	_draw_claw(img,claw,1)
	_segment(img,Vector2i(x-13,y+25),Vector2i(x-25,y+41),8,OUTLINE); _draw_claw(img,Vector2i(x-25,y+41),-1)


func _draw_toad(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage=="death": _draw_creature_death(img,frame,BOG); return
	var jump: int = -12 if stage=="active" else -roundi(phase*7.0) if stage=="windup" else 0
	var x: int=46+(8 if stage=="active" else 0); var y: int=41+bob+jump
	var stride: int=[-5,-2,2,5,2,-2][frame] if animation=="walk" else 0
	# Broad readable toad mass with bell sac and webbed feet.
	_poly(img,_pts([x-30,y+3,x-21,y-15,x-7,y-23,x+15,y-21,x+29,y-8,x+31,y+11,x+18,y+25,x-20,y+25,x-32,y+14]),OUTLINE)
	_poly(img,_pts([x-26,y+3,x-18,y-12,x-6,y-19,x+13,y-18,x+25,y-6,x+27,y+9,x+16,y+21,x-17,y+21,x-28,y+12]),BOG)
	_ellipse(img,Vector2i(x-13,y-18),6,5,BOG_LIT); _ellipse(img,Vector2i(x+13,y-17),6,5,BOG_LIT)
	_pixel(img,x-12,y-20,SOUL_LIT); _pixel(img,x+14,y-19,SOUL_LIT)
	_ellipse(img,Vector2i(x,y+4),11,9,RUST); _segment(img,Vector2i(x-9,y+3),Vector2i(x+9,y+3),2,GOLD)
	_segment(img,Vector2i(x-20,y+15),Vector2i(x-31-stride,y+28),10,OUTLINE); _segment(img,Vector2i(x+19,y+15),Vector2i(x+31+stride,y+28),10,OUTLINE)
	_draw_webbed_foot(img,Vector2i(x-33-stride,y+29),-1); _draw_webbed_foot(img,Vector2i(x+33+stride,y+29),1)
	if stage=="active" and animation.begins_with("mud_burst"):
		for i: int in range(7): _ellipse(img,Vector2i(62+i*5,70-(i%3)*7),2,2,BOG_LIT)
	if stage=="active" and animation.begins_with("tongue_lash"):
		_segment(img,Vector2i(x+22,y+2),Vector2i(95,y-1+frame*2),3,PRISON_RED)


func _draw_maw(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage=="hidden":
		for grate: int in range(5): _segment(img,Vector2i(25+grate*10,75),Vector2i(25+grate*10,86),3,IRON)
		return
	if stage=="death": _draw_creature_death(img,frame,DEEP); return
	var x: int=44+(10 if stage=="active" else 0); var y: int=49+bob-(8 if stage=="windup" else 0)
	_poly(img,_pts([x-29,y+2,x-20,y-14,x-5,y-21,x+14,y-18,x+29,y-5,x+25,y+18,x+8,y+27,x-15,y+25,x-30,y+14]),OUTLINE)
	_poly(img,_pts([x-25,y+3,x-17,y-11,x-4,y-17,x+12,y-15,x+25,y-3,x+21,y+14,x+7,y+23,x-13,y+21,x-26,y+12]),DEEP)
	# Huge sewer bite is distinct from the compact body.
	_poly(img,_pts([x-16,y-5,x+21,y-6,x+26,y+7,x+17,y+17,x-13,y+16,x-21,y+7]),RUST)
	for tooth: int in range(7):
		_poly(img,_pts([x-13+tooth*5,y-5,x-11+tooth*5,y+2,x-8+tooth*5,y-5]),BONE)
		_poly(img,_pts([x-13+tooth*5,y+16,x-11+tooth*5,y+9,x-8+tooth*5,y+16]),BONE)
	_pixel(img,x-17,y-9,SOUL); _pixel(img,x+17,y-10,SOUL)
	for leg: int in range(3):
		var side: int=-1 if leg<2 else 1
		var root: Vector2i=Vector2i(x+side*(10+leg*3),y+18)
		_segment(img,root,Vector2i(root.x+side*13,y+31+leg*2),6,OUTLINE)


func _draw_executioner(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	_draw_humanoid(img,"drowned_gaoler",animation,stage,frame,phase,bob,1.35)
	if stage=="death": return
	var x: int=42+(5 if stage=="active" else -4 if stage in ["windup","hurt"] else 0)
	var y: int=8+bob
	# Distinctive gallows crest, chain mantle and execution apron.
	_poly(img,_pts([x-14,y+2,x-7,y-7,x+8,y-5,x+16,y+3,x+12,y+13,x-11,y+14]),OUTLINE)
	_poly(img,_pts([x-10,y+2,x-5,y-3,x+6,y-2,x+11,y+3,x+8,y+10,x-8,y+10]),RUST)
	_chain(img,Vector2i(x-20,y+28),Vector2i(x+20,y+28),STEEL)
	_poly(img,_pts([x-10,y+44,x+10,y+42,x+13,y+72,x+2,y+79,x-10,y+72]),PRISON_RED)


func _draw_gaoler_weapon(img: Image, grip: Vector2i, tip: Vector2i, heavy: bool) -> void:
	_segment(img,grip,tip,5 if heavy else 4,OUTLINE)
	_segment(img,grip,tip,2,STEEL)
	var dir: Vector2=(Vector2(tip-grip)).normalized(); var normal: Vector2=Vector2(-dir.y,dir.x)
	var hook: Vector2i=Vector2i(tip)+Vector2i(roundi(normal.x*9.0-dir.x*7.0),roundi(normal.y*9.0-dir.y*7.0))
	_segment(img,tip,hook,4,OUTLINE); _segment(img,tip,hook,2,RUST_LIT)
	_segment(img,grip-Vector2i(roundi(dir.x*7),roundi(dir.y*7)),grip+Vector2i(roundi(normal.x*6),roundi(normal.y*6)),3,GOLD)


func _draw_harpoon(img: Image, grip: Vector2i, tip: Vector2i) -> void:
	_segment(img,grip,tip,4,OUTLINE); _segment(img,grip,tip,2,STEEL)
	var d: Vector2=Vector2(tip-grip).normalized(); var n: Vector2=Vector2(-d.y,d.x)
	var base: Vector2i=Vector2i(tip)-Vector2i(roundi(d.x*9),roundi(d.y*9))
	_poly(img,PackedVector2Array([tip,base+Vector2i(roundi(n.x*7),roundi(n.y*7)),base-Vector2i(roundi(n.x*7),roundi(n.y*7))]),STEEL)
	_segment(img,base,base-Vector2i(roundi(d.x*5-n.x*7),roundi(d.y*5-n.y*7)),3,RUST_LIT)


func _draw_shackle(img: Image, center: Vector2i) -> void:
	_ellipse(img,center,5,4,OUTLINE); _ellipse(img,center,3,2,RUST_LIT)


func _draw_key_ring(img: Image, center: Vector2i) -> void:
	_ellipse(img,center,5,5,GOLD); _ellipse(img,center,2,2,CLEAR)
	for i: int in range(3):
		_segment(img,center+Vector2i(i*3-3,5),center+Vector2i(i*3-3,14+i*2),2,GOLD)


func _draw_claw(img: Image, center: Vector2i, direction: int) -> void:
	_ellipse(img,center,3,3,MIRE_LIT)
	for i: int in range(3): _segment(img,center,center+Vector2i(direction*(7+i*2),-4+i*4),2,BONE)


func _draw_webbed_foot(img: Image, center: Vector2i, direction: int) -> void:
	for i: int in range(3): _segment(img,center,center+Vector2i(direction*(7+i*3),i*2-2),4,BOG_LIT)


func _draw_fallen_body(img: Image, frame: int, armored: bool) -> void:
	var y: int=67+mini(frame,3)*5
	_poly(img,_pts([10,y,65,y-8,86,y+2,78,y+15,19,y+15]),OUTLINE)
	_poly(img,_pts([15,y+2,62,y-5,80,y+2,74,y+10,21,y+11]),IRON if armored else RUST)
	for p: int in range(frame*3): _ellipse(img,Vector2i(18+(p*17)%66,38+(p*11)%35),2,2,SOUL if p%3==0 else RUST_LIT)


func _draw_creature_death(img: Image, frame: int, color: Color) -> void:
	var alpha: float=maxf(0.12,1.0-frame*0.15)
	_poly(img,_pts([12,67,76,60,90,72,80,87,18,87]),Color(color.r,color.g,color.b,alpha))
	for p: int in range(frame*4): _ellipse(img,Vector2i(15+(p*19)%72,35+(p*13)%45),2,2,Color(SOUL.r,SOUL.g,SOUL.b,alpha))


func _write_shield_states() -> bool:
	var directory: String="%s/sunken_shield_penitent/shield" % ROOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	for stage: int in range(4):
		var image: Image=Image.create(FRAME_SIZE,FRAME_SIZE,false,Image.FORMAT_RGBA8); image.fill(CLEAR)
		if stage<3:
			_poly(image,_pts([27,29,58,17,88,31,84,91,58,108,30,90]),OUTLINE)
			_poly(image,_pts([32,33,58,23,82,35,79,87,58,101,35,85]),IRON)
			_rect(image,Rect2i(37,38,42,7),RUST)
			_rect(image,Rect2i(37,58,42,7),RUST)
			_rect(image,Rect2i(37,78,42,7),RUST)
			_segment(image,Vector2i(58,25),Vector2i(58,99),4,GOLD)
			_segment(image,Vector2i(34,56),Vector2i(81,56),4,GOLD)
			_rect(image,Rect2i(49,46,18,18),DEEP)
			for bar: int in range(4): _segment(image,Vector2i(52+bar*4,48),Vector2i(52+bar*4,62),2,STEEL)
			for crack: int in range(stage*4): _segment(image,Vector2i(48+crack*3,34+crack*6),Vector2i(43+crack*4,48+crack*7),2,RUST_LIT)
		else:
			for shard: int in range(12):
				var p: Vector2i=Vector2i(31+(shard*17)%56,32+(shard*19)%60)
				_poly(image,_pts([p.x,p.y-5,p.x+5,p.y+2,p.x-3,p.y+5]),IRON)
		var name: String=["intact","cracked","critical","broken"][stage]
		if image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [directory,name]))!=OK: return false
	return true


func _write_reference_sheet(role: String) -> void:
	var directory: String="%s/%s/reference" % [ROOT,role]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var sheet: Image=Image.create(FRAME_SIZE*3,FRAME_SIZE,false,Image.FORMAT_RGBA8); sheet.fill(CLEAR)
	var action: String=(ACTIONS[role] as Array)[0]
	sheet.blit_rect(_draw_frame(role,"idle",0,4),Rect2i(0,0,FRAME_SIZE,FRAME_SIZE),Vector2i.ZERO)
	sheet.blit_rect(_draw_frame(role,"%s_active" % action,0,2),Rect2i(0,0,FRAME_SIZE,FRAME_SIZE),Vector2i(FRAME_SIZE,0))
	sheet.blit_rect(_draw_frame(role,"death",3,6),Rect2i(0,0,FRAME_SIZE,FRAME_SIZE),Vector2i(FRAME_SIZE*2,0))
	sheet.save_png(ProjectSettings.globalize_path("%s/%s_runtime_reference.png" % [directory,role]))


func _pts(values: Array[int]) -> PackedVector2Array:
	var points: PackedVector2Array=PackedVector2Array()
	for i: int in range(0,values.size(),2): points.append(Vector2(values[i],values[i+1]))
	return points


func _rect(img: Image, rect: Rect2i, color: Color) -> void:
	img.fill_rect(rect, color)


func _poly(img: Image, points: PackedVector2Array, color: Color) -> void:
	if points.size()<3: return
	var min_x: int=img.get_width()-1; var max_x: int=0; var min_y: int=img.get_height()-1; var max_y: int=0
	for point: Vector2 in points:
		min_x=mini(min_x,floori(point.x)); max_x=maxi(max_x,ceili(point.x)); min_y=mini(min_y,floori(point.y)); max_y=maxi(max_y,ceili(point.y))
	for y: int in range(clampi(min_y,0,img.get_height()-1),clampi(max_y,0,img.get_height()-1)+1):
		for x: int in range(clampi(min_x,0,img.get_width()-1),clampi(max_x,0,img.get_width()-1)+1):
			if Geometry2D.is_point_in_polygon(Vector2(x+0.5,y+0.5),points): img.set_pixel(x,y,color)


func _ellipse(img: Image, center: Vector2i, rx: int, ry: int, color: Color) -> void:
	for y: int in range(center.y-ry,center.y+ry+1):
		for x: int in range(center.x-rx,center.x+rx+1):
			if rx>0 and ry>0 and pow(float(x-center.x)/rx,2)+pow(float(y-center.y)/ry,2)<=1.0: _pixel(img,x,y,color)


func _segment(img: Image, start: Vector2i, finish: Vector2i, thickness: int, color: Color) -> void:
	var steps: int=maxi(abs(finish.x-start.x),abs(finish.y-start.y))
	for i: int in range(steps+1):
		var t: float=float(i)/float(maxi(1,steps)); var p: Vector2i=Vector2i(roundi(lerpf(start.x,finish.x,t)),roundi(lerpf(start.y,finish.y,t)))
		_ellipse(img,p,maxi(1,thickness/2),maxi(1,thickness/2),color)


func _chain(img: Image, start: Vector2i, finish: Vector2i, color: Color) -> void:
	var steps: int=maxi(2,int(Vector2(start).distance_to(Vector2(finish))/4.0))
	for i: int in range(steps+1):
		var p: Vector2i=Vector2i(Vector2(start).lerp(Vector2(finish),float(i)/steps)); _ellipse(img,p,2,1,color)


func _chain_curve(img: Image, start: Vector2i, control: Vector2i, finish: Vector2i, color: Color) -> void:
	for i: int in range(19):
		var t: float=float(i)/18.0; var inv: float=1.0-t
		var p: Vector2i=Vector2i(roundi(inv*inv*start.x+2.0*inv*t*control.x+t*t*finish.x),roundi(inv*inv*start.y+2.0*inv*t*control.y+t*t*finish.y))
		_ellipse(img,p,2,1,color)


func _pixel(img: Image, x: int, y: int, color: Color) -> void:
	if x>=0 and x<img.get_width() and y>=0 and y<img.get_height(): img.set_pixel(x,y,color)
