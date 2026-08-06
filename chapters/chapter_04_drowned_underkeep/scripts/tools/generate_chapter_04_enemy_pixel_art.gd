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

const ROLES: Array[String] = ["bog_toad", "sewer_maw"]

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
			if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(directory)):
				push_error("Formal sprite directory does not exist: %s" % directory)
				quit(1)
				return
			for frame: int in range(count):
				var image: Image = _draw_frame(role, animation, frame, count)
				var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
				if not FileAccess.file_exists(path):
					push_error("Refusing to create a replacement frame: %s" % path)
					quit(1)
					return
				if image.save_png(ProjectSettings.globalize_path(path)) != OK:
					push_error("Cannot save %s" % path)
					quit(1)
					return
				total += 1
		_write_reference_sheet(role)
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
	var image: Image = Image.create(FRAME_SIZE, FRAME_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
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
		bob = [0, -1, -2, -1][frame]
	elif animation == "walk":
		bob = [0, -2, -1, 0, -2, -1][frame]
	if role == "bog_toad":
		_draw_toad(image, animation, stage, frame, phase, bob)
		_detail_toad(image, animation, stage, frame, phase, bob)
	else:
		_draw_maw(image, animation, stage, frame, phase, bob)
		_detail_maw(image, animation, stage, frame, phase, bob)
	return image


func _draw_legacy_frame(role: String, animation: String, frame: int, count: int) -> Image:
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
	# The concept's timber punishment yoke, chained wrists and ruined human body
	# must remain readable at gameplay scale. Build the yoke from layered timber
	# and iron rather than a single horizontal bar.
	_rect(img, Rect2i(x-35,y+21,70,9), OUTLINE)
	_rect(img, Rect2i(x-32,y+23,64,5), Color("49352c"))
	_segment(img, Vector2i(x-31,y+24), Vector2i(x+31,y+24), 1, RUST_LIT)
	_rect(img, Rect2i(x-8,y+17,7,15), OUTLINE)
	_rect(img, Rect2i(x-6,y+18,3,13), IRON)
	_rect(img, Rect2i(x+3,y+17,7,15), OUTLINE)
	_rect(img, Rect2i(x+5,y+18,3,13), IRON_LIT)
	for bolt_x: int in [x-27,x-14,x+14,x+27]: _ellipse(img, Vector2i(bolt_x,y+25), 1, 1, STEEL)
	# Cage mask highlights and the restrained cyan eye survive the dark scene.
	for mask_bar: int in range(4):
		_segment(img, Vector2i(x-6+mask_bar*4,y+5), Vector2i(x-7+mask_bar*4,y+19), 1, IRON_LIT)
	_pixel(img, x+5, y+11, SOUL_LIT)
	# Scarred torso planes, crossing chain and torn prison cloth match the concept.
	_segment(img, Vector2i(x-12,y+37), Vector2i(x+11,y+55), 2, DEEP)
	_segment(img, Vector2i(x+10,y+37), Vector2i(x-9,y+56), 2, IRON_LIT)
	for scar: int in range(3):
		_segment(img, Vector2i(x-10+scar*7,y+43), Vector2i(x-5+scar*7,y+41), 1, RUST_LIT)
	_poly(img, _pts([x-15,y+63,x-6,y+68,x-2,y+64,x+4,y+70,x+14,y+63,x+11,y+78,x+4,y+75,x-1,y+82,x-7,y+75,x-14,y+79]), DEEP)
	_segment(img, Vector2i(x-29,y+29), Vector2i(x-34,y+49), 4, IRON)
	_segment(img, Vector2i(x+29,y+29), Vector2i(x+35,y+49), 4, IRON)
	_draw_shackle(img, Vector2i(x-34,y+49))
	_draw_shackle(img, Vector2i(x+35,y+49))
	_chain_curve(img, Vector2i(x-30,y+47), Vector2i(x-47,y+63), Vector2i(x-39,y+83), STEEL)
	_chain_curve(img, Vector2i(x+31,y+47), Vector2i(x+48,y+62), Vector2i(x+43,y+81), STEEL)
	# Bare feet and ankle irons prevent the lower half reading as two rounded blocks.
	_rect(img, Rect2i(x-17,y+79,12,4), OUTLINE)
	_rect(img, Rect2i(x+6,y+79,12,4), OUTLINE)
	_segment(img, Vector2i(x-14,y+78), Vector2i(x-5,y+78), 2, IRON_LIT)
	_segment(img, Vector2i(x+7,y+78), Vector2i(x+16,y+78), 2, IRON_LIT)


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
	if stage == "death":
		return
	var leap: int = -16 if stage == "active" and animation.begins_with("leap_crush") else 0
	var shift: int = 9 if stage == "active" else -roundi(phase * 5.0) if stage == "windup" else 0
	var x: int = 62 + shift
	var y: int = 69 + bob + leap
	# Uneven osteoderms and warts keep the concept's heavy, diseased back readable.
	for ridge: int in range(9):
		var rx: int = x - 38 + ridge * 8
		var height: int = 8 + (ridge * 5) % 9
		_poly(img, _pts([rx-4,y-22,rx,y-22-height,rx+5,y-20]), OUTLINE)
		_poly(img, _pts([rx-2,y-23,rx,y-20-height,rx+3,y-21]), BONE if ridge % 3 == 0 else BOG_LIT)
	for wart: Vector2i in [Vector2i(-33,-13),Vector2i(-24,-27),Vector2i(-12,-33),Vector2i(1,-31),Vector2i(15,-27),Vector2i(29,-16),Vector2i(-9,-13),Vector2i(10,-10)]:
		_ellipse(img, Vector2i(x+wart.x,y+wart.y), 3, 2, OUTLINE)
		_ellipse(img, Vector2i(x+wart.x,y+wart.y-1), 2, 1, BOG_LIT)
		_pixel(img, x+wart.x-1, y+wart.y-2, STEEL)
	# Heavy neck shackle and dragging chain are permanent identifiers.
	_ellipse(img, Vector2i(x+21,y-9), 8, 11, OUTLINE)
	_segment(img, Vector2i(x+17,y-18), Vector2i(x+26,y+2), 3, RUST_LIT)
	_chain_curve(img, Vector2i(x+18,y+1), Vector2i(x-4,y+24), Vector2i(x-42,y+30), IRON_LIT)
	# Wet highlights, skin folds, moss and hanging slime.
	for fold: int in range(5):
		_segment(img, Vector2i(x-24+fold*11,y-3+(fold%2)*3), Vector2i(x-17+fold*11,y+6+(fold%2)*2), 2, BOG_LIT)
	for drip: int in range(6):
		_segment(img, Vector2i(x-24+drip*10,y+16), Vector2i(x-24+drip*10,y+20+(drip%3)*2), 1, MIRE_LIT)
	# Tongue remains broad and fleshy rather than a single red line.
	if stage == "active" and animation.begins_with("tongue_lash"):
		_poly(img, _pts([x+31,y-5,124,y-7,126,y-3,124,y+1,x+31,y+1]), OUTLINE)
		_poly(img, _pts([x+32,y-4,123,y-5,124,y-2,123,y-1,x+32,y]), Color("8f5660"))


func _detail_maw(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "hidden":
		return
	if stage == "death":
		return
	var shift: int = 12 if stage == "active" else -roundi(phase * 5.0) if stage == "windup" else 0
	var x: int = 60 + shift
	var y: int = 73 + bob - (6 if stage == "windup" else 0)
	# Dorsal bone plates, prison grate remains, number tag and body chains.
	for plate: int in range(11):
		var px: int = x - 46 + plate * 8
		var peak: int = 13 + (plate * 7) % 8
		_poly(img, _pts([px-4,y-19,px,y-19-peak,px+5,y-18]), OUTLINE)
		_poly(img, _pts([px-2,y-20,px,y-17-peak,px+3,y-19]), BONE if plate % 2 == 0 else IRON_LIT)
	for armor: int in range(7):
		_ellipse(img, Vector2i(x-37+armor*9,y-14+(armor%2)*2), 5, 4, OUTLINE)
		_ellipse(img, Vector2i(x-37+armor*9,y-15+(armor%2)*2), 3, 2, IRON)
	_rect(img, Rect2i(x-42,y-25,27,5), OUTLINE)
	_rect(img, Rect2i(x-40,y-24,23,3), RUST)
	for grate: int in range(5):
		_segment(img, Vector2i(x-39+grate*5,y-31), Vector2i(x-37+grate*5,y-18), 2, IRON_LIT)
	_ellipse(img, Vector2i(x-10,y-8), 6, 6, OUTLINE)
	_ellipse(img, Vector2i(x-10,y-8), 4, 4, RUST)
	_segment(img, Vector2i(x-12,y-11), Vector2i(x-8,y-5), 1, BONE)
	_chain_curve(img, Vector2i(x-28,y-5), Vector2i(x-5,y+18), Vector2i(x+25,y+15), IRON_LIT)
	# Articulated short legs and distinct hooked claws.
	for limb: int in range(4):
		var root_x: int = x - 34 + limb * 22
		var side: int = -1 if limb < 2 else 1
		var foot_x: int = root_x + side * (8 + (limb%2)*4)
		_segment(img, Vector2i(root_x,y+7), Vector2i(foot_x,y+25), 8, OUTLINE)
		_segment(img, Vector2i(root_x,y+7), Vector2i(foot_x,y+24), 4, MIRE_LIT)
		for claw: int in range(3):
			_segment(img, Vector2i(foot_x,y+24), Vector2i(foot_x+side*(7+claw*2),y+26-claw*2), 2, BONE)
	# Wet speculars and saliva retain the sewer-predator material.
	for glint: Vector2i in [Vector2i(-34,-10),Vector2i(-17,-16),Vector2i(4,-15),Vector2i(22,-9),Vector2i(37,-4)]:
		_pixel(img, x+glint.x, y+glint.y, STEEL)
	for drip: int in range(4):
		_segment(img, Vector2i(x+29+drip*5,y+1), Vector2i(x+29+drip*5,y+5+(drip%2)*3), 1, SOUL)


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
	if stage == "death":
		_draw_toad_death(img, frame)
		return
	var leap: int = -16 if stage == "active" and animation.begins_with("leap_crush") else 0
	var shift: int = 9 if stage == "active" else -roundi(phase * 5.0) if stage == "windup" else 0
	var x: int = 62 + shift
	var y: int = 69 + bob + leap
	var stride: int = [-7,-3,2,7,3,-2][frame] if animation == "walk" else 0
	var crouch: int = roundi(phase * 7.0) if stage == "windup" else 0
	y += crouch
	# Three-quarter side silhouette: huge rear mass, wide head, low belly and separate limbs.
	_poly(img, _pts([x-50,y-2,x-45,y-25,x-28,y-43,x-4,y-49,x+20,y-42,x+39,y-27,x+47,y-4,x+42,y+16,x+25,y+27,x-24,y+27,x-46,y+17]), OUTLINE)
	_poly(img, _pts([x-45,y-3,x-40,y-22,x-25,y-38,x-4,y-44,x+17,y-38,x+34,y-24,x+41,y-5,x+36,y+12,x+22,y+22,x-22,y+22,x-40,y+14]), BOG)
	_poly(img, _pts([x-39,y-15,x-28,y-32,x-7,y-39,x+12,y-35,x+27,y-24,x+33,y-11,x+18,y-17,x-4,y-20,x-25,y-13]), Color("667044"))
	# Side head, heavy eyelid, nostril and multi-layer jaw.
	_poly(img, _pts([x+10,y-31,x+29,y-32,x+46,y-22,x+50,y-8,x+44,y+5,x+17,y+7,x+5,y-6]), OUTLINE)
	_poly(img, _pts([x+13,y-28,x+28,y-29,x+42,y-20,x+46,y-9,x+40,y+1,x+19,y+3,x+9,y-6]), BOG_LIT)
	_ellipse(img, Vector2i(x+25,y-27), 8, 7, OUTLINE)
	_ellipse(img, Vector2i(x+26,y-27), 5, 5, Color("8c8b70"))
	_ellipse(img, Vector2i(x+27,y-27), 2, 4, OUTLINE)
	_pixel(img, x+26, y-29, SOUL_LIT)
	_ellipse(img, Vector2i(x+42,y-15), 2, 2, OUTLINE)
	_poly(img, _pts([x+12,y-5,x+45,y-6,x+48,y+2,x+40,y+12,x+15,y+12,x+7,y+3]), OUTLINE)
	_poly(img, _pts([x+15,y-3,x+43,y-4,x+44,y+1,x+37,y+8,x+17,y+8,x+11,y+3]), Color("4c3030"))
	for tooth: int in range(7):
		var tx: int = x + 15 + tooth * 4
		_poly(img, _pts([tx,y-3,tx+2,y+2,tx+4,y-3]), BONE)
	# Thick rear leg, front arm, webbing and individually readable claws.
	var rear_foot: Vector2i = Vector2i(x-45-stride,y+28)
	_segment(img, Vector2i(x-27,y+4), Vector2i(x-36-stride/2,y+18), 19, OUTLINE)
	_segment(img, Vector2i(x-27,y+4), Vector2i(x-36-stride/2,y+18), 13, BOG_LIT)
	_draw_large_toad_foot(img, rear_foot, -1)
	var front_foot: Vector2i = Vector2i(x+42+stride,y+27)
	_segment(img, Vector2i(x+20,y+1), Vector2i(x+31+stride/2,y+18), 13, OUTLINE)
	_segment(img, Vector2i(x+20,y+1), Vector2i(x+31+stride/2,y+18), 8, BOG_LIT)
	_draw_large_toad_foot(img, front_foot, 1)
	# Inflated throat and belly folds.
	_ellipse(img, Vector2i(x+10,y+10), 18, 15, OUTLINE)
	_ellipse(img, Vector2i(x+10,y+9), 14, 12, Color("6c6145"))
	for fold: int in range(4):
		_segment(img, Vector2i(x-1,y+4+fold*4), Vector2i(x+21,y+5+fold*3), 1, GOLD)
	if stage == "active" and animation.begins_with("mud_burst"):
		for i: int in range(9):
			_ellipse(img, Vector2i(x+45+i*7,y-5-(i%3)*8), 3, 2, BOG_LIT)


func _draw_maw(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage=="hidden":
		for ripple: int in range(4):
			_segment(img, Vector2i(18+ripple*18,96-(ripple%2)*3), Vector2i(40+ripple*18,96-(ripple%2)*3), 2, SOUL)
		for plate: int in range(7):
			var px: int = 36 + plate * 10
			_poly(img, _pts([px-5,96,px,80-(plate%3)*3,px+6,96]), OUTLINE)
			_poly(img, _pts([px-2,94,px,84-(plate%3)*3,px+3,94]), IRON_LIT)
		_chain_curve(img, Vector2i(31,97), Vector2i(59,106), Vector2i(92,99), RUST_LIT)
		return
	if stage == "death":
		_draw_maw_death(img, frame)
		return
	var shift: int = 12 if stage == "active" else -roundi(phase * 5.0) if stage == "windup" else 0
	var x: int = 60 + shift
	var y: int = 73 + bob - (6 if stage == "windup" else 0)
	var stride: int = [-5,-2,2,5,2,-2][frame] if animation == "walk" else 0
	# Full crocodilian body and tapering rear replace the old compact mouth-ball.
	_poly(img, _pts([x-51,y-6,x-42,y-25,x-22,y-34,x+4,y-34,x+28,y-28,x+48,y-16,x+54,y+2,x+45,y+18,x+18,y+25,x-18,y+24,x-45,y+15,x-55,y+4]), OUTLINE)
	_poly(img, _pts([x-47,y-6,x-38,y-21,x-20,y-29,x+3,y-29,x+25,y-24,x+43,y-14,x+49,y+1,x+40,y+13,x+16,y+20,x-17,y+19,x-41,y+12,x-50,y+3]), DEEP)
	_poly(img, _pts([x-42,y-12,x-24,y-25,x+1,y-26,x+22,y-21,x+34,y-14,x+9,y-13,x-17,y-9]), MIRE)
	# Elongated skull and two independently articulated jaws.
	var jaw_open: int = 10 if stage == "active" else 4 + roundi(phase*5.0) if stage == "windup" else 5
	_poly(img, _pts([x+8,y-25,x+29,y-28,x+53,y-20,x+62,y-12,x+56,y-4,x+24,y-5,x+5,y-11]), OUTLINE)
	_poly(img, _pts([x+12,y-22,x+29,y-24,x+50,y-17,x+57,y-12,x+53,y-8,x+25,y-9,x+9,y-12]), IRON)
	_poly(img, _pts([x+10,y-6,x+59,y-8,x+64,y+2+jaw_open,x+53,y+9+jaw_open,x+20,y+8+jaw_open,x+4,y+2]), OUTLINE)
	_poly(img, _pts([x+14,y-4,x+56,y-6,x+59,y+1+jaw_open,x+50,y+5+jaw_open,x+21,y+4+jaw_open,x+9,y+1]), Color("3f242a"))
	# Irregular multi-row teeth and deep tongue.
	for tooth: int in range(12):
		var tx: int = x + 12 + tooth * 4
		var th: int = 5 + (tooth*3)%5
		_poly(img, _pts([tx,y-7,tx+2,y-7+th,tx+4,y-7]), BONE)
		_poly(img, _pts([tx,y+4+jaw_open,tx+2,y+4+jaw_open-th,tx+4,y+4+jaw_open]), BONE)
	_poly(img, _pts([x+24,y+1+jaw_open,x+56,y-1+jaw_open,x+50,y+4+jaw_open,x+27,y+6+jaw_open]), PRISON_RED)
	_ellipse(img, Vector2i(x+25,y-20), 5, 5, OUTLINE)
	_ellipse(img, Vector2i(x+26,y-20), 2, 2, SOUL_LIT)
	# Tail taper and waterline shadow ground the unusually long silhouette.
	_poly(img, _pts([x-45,y-4,x-62,y+3,x-55,y+12,x-37,y+11]), OUTLINE)
	_poly(img, _pts([x-44,y,x-58,y+4,x-53,y+8,x-38,y+8]), MIRE)
	_segment(img, Vector2i(x-52-stride,y+22), Vector2i(x+48+stride,y+23), 3, Color("1a353b"))


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


func _draw_large_toad_foot(img: Image, center: Vector2i, direction: int) -> void:
	_ellipse(img, center, 7, 5, OUTLINE)
	_ellipse(img, center, 5, 3, BOG_LIT)
	for toe: int in range(4):
		var finish: Vector2i = center + Vector2i(direction * (9 + toe * 3), -4 + toe * 3)
		_segment(img, center, finish, 4, OUTLINE)
		_segment(img, center + Vector2i(direction, 0), finish - Vector2i(direction * 2, 0), 2, BOG_LIT)
		_segment(img, finish, finish + Vector2i(direction * 3, 0), 2, BONE)


func _draw_toad_death(img: Image, frame: int) -> void:
	var alpha: float = 1.0 if frame < 4 else 0.65 if frame == 4 else 0.3
	var fall: int = mini(frame, 3) * 4
	var y: int = 83 + fall
	_poly(img, _pts([12,y-11,25,y-26,57,y-31,90,y-21,111,y-5,105,y+13,73,y+18,27,y+15,10,y+4]), Color(OUTLINE.r,OUTLINE.g,OUTLINE.b,alpha))
	_poly(img, _pts([17,y-10,29,y-22,57,y-26,86,y-17,105,y-4,99,y+8,70,y+13,29,y+11,15,y+3]), Color(BOG.r,BOG.g,BOG.b,alpha))
	_ellipse(img, Vector2i(89,y-14), 7, 6, Color(BOG_LIT.r,BOG_LIT.g,BOG_LIT.b,alpha))
	_poly(img, _pts([79,y-5,107,y-6,103,y+5,82,y+6]), Color(PRISON_RED.r,PRISON_RED.g,PRISON_RED.b,alpha))
	for ridge: int in range(8):
		var rx: int = 27 + ridge * 9
		_poly(img, _pts([rx-4,y-20,rx,y-31-(ridge%3)*3,rx+5,y-19]), Color(BONE.r,BONE.g,BONE.b,alpha))
	_chain_curve(img, Vector2i(78,y+2), Vector2i(54,y+21), Vector2i(17,y+17), Color(IRON_LIT.r,IRON_LIT.g,IRON_LIT.b,alpha))
	for mote: int in range(maxi(0, frame - 2) * 10):
		_ellipse(img, Vector2i(15+(mote*17)%100,45+(mote*13)%65), 1+mote%2, 1, Color(SOUL.r,SOUL.g,SOUL.b,alpha))


func _draw_maw_death(img: Image, frame: int) -> void:
	var alpha: float = 1.0 if frame < 4 else 0.65 if frame == 4 else 0.3
	var fall: int = mini(frame, 3) * 3
	var y: int = 81 + fall
	_poly(img, _pts([5,y-4,18,y-18,54,y-25,90,y-22,121,y-9,124,y+8,98,y+17,48,y+16,14,y+11]), Color(OUTLINE.r,OUTLINE.g,OUTLINE.b,alpha))
	_poly(img, _pts([10,y-4,22,y-14,55,y-20,88,y-17,116,y-7,118,y+4,95,y+12,49,y+11,18,y+7]), Color(DEEP.r,DEEP.g,DEEP.b,alpha))
	_poly(img, _pts([67,y-14,117,y-10,121,y+5,108,y+12,73,y+9]), Color(PRISON_RED.r,PRISON_RED.g,PRISON_RED.b,alpha))
	for tooth: int in range(11):
		var tx: int = 70 + tooth * 4
		_poly(img, _pts([tx,y-10,tx+2,y-4,tx+4,y-10]), Color(BONE.r,BONE.g,BONE.b,alpha))
	for plate: int in range(10):
		var px: int = 20 + plate * 8
		_poly(img, _pts([px-4,y-15,px,y-29-(plate%3)*3,px+5,y-14]), Color(IRON_LIT.r,IRON_LIT.g,IRON_LIT.b,alpha))
	_chain_curve(img, Vector2i(27,y), Vector2i(55,y+20), Vector2i(91,y+15), Color(RUST_LIT.r,RUST_LIT.g,RUST_LIT.b,alpha))
	for mote: int in range(maxi(0, frame - 2) * 10):
		_ellipse(img, Vector2i(8+(mote*19)%112,45+(mote*11)%66), 1+mote%2, 1, Color(SOUL.r,SOUL.g,SOUL.b,alpha))


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
	var output: String = "%s/%s_runtime_reference.png" % [directory,role]
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(directory)) or not FileAccess.file_exists(output):
		push_error("Refusing to create a replacement reference sheet: %s" % output)
		return
	var sheet: Image=Image.create(FRAME_SIZE*3,FRAME_SIZE,false,Image.FORMAT_RGBA8); sheet.fill(CLEAR)
	var action: String=(ACTIONS[role] as Array)[0]
	sheet.blit_rect(_draw_frame(role,"idle",0,4),Rect2i(0,0,FRAME_SIZE,FRAME_SIZE),Vector2i.ZERO)
	sheet.blit_rect(_draw_frame(role,"%s_active" % action,0,2),Rect2i(0,0,FRAME_SIZE,FRAME_SIZE),Vector2i(FRAME_SIZE,0))
	sheet.blit_rect(_draw_frame(role,"death",3,6),Rect2i(0,0,FRAME_SIZE,FRAME_SIZE),Vector2i(FRAME_SIZE*2,0))
	sheet.save_png(ProjectSettings.globalize_path(output))


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
