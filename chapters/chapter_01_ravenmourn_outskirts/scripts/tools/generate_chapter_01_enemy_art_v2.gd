extends SceneTree

## Chapter I formal enemy and Boss art generator.
##
## The original sets proved combat timing but used rectangular bodies and line
## weapons. This generator preserves every existing animation family and frame
## count while replacing those masks with role-specific silhouettes, layered
## materials, shaped equipment, stable foot anchors and readable active poses.

const ROOT: String = "res://chapters/chapter_01_ravenmourn_outskirts/assets"
const CLEAR: Color = Color(0.0, 0.0, 0.0, 0.0)
const OUTLINE: Color = Color("0a0d12")
const VOID: Color = Color("11151d")
const IRON_DARK: Color = Color("202a33")
const IRON: Color = Color("3d4a54")
const IRON_LIT: Color = Color("71818b")
const STEEL: Color = Color("aebcc2")
const STEEL_LIT: Color = Color("e2e8e7")
const CLOTH: Color = Color("252532")
const CLOTH_LIT: Color = Color("454352")
const LEATHER: Color = Color("4a332c")
const LEATHER_LIT: Color = Color("7d5140")
const WOOD: Color = Color("5a3e2b")
const WOOD_LIT: Color = Color("8d6540")
const RUST: Color = Color("7f4330")
const RUST_LIT: Color = Color("b06442")
const WINE: Color = Color("612b38")
const WINE_LIT: Color = Color("9a4350")
const GOLD: Color = Color("9a7742")
const GOLD_LIT: Color = Color("d0a65b")
const CURSE_RED: Color = Color("c64942")
const CURSE_LIT: Color = Color("f18a62")
const MOON_BLUE: Color = Color("5f8fa6")
const MOON_LIT: Color = Color("a8d5db")
const STONE: Color = Color("465158")
const STONE_LIT: Color = Color("7b8989")
const MOSS: Color = Color("536148")
const SHADOW_ALPHA: Color = Color(0.08, 0.10, 0.14, 0.55)
const ENEMY_FRAME_SIZE: int = 128
const ENEMY_LEGACY_SIZE: int = 64
const BOSS_FRAME_SIZE: int = 192
const BOSS_LEGACY_SIZE: int = 96

const ROLES: Array[String] = [
	"castle_guard",
	"cursed_shield_guard",
	"decayed_spearman",
	"fallen_crossbowman",
	"gargoyle_sentinel",
	"fallen_gate_knight",
]

const ANIMATIONS: Dictionary = {
	"castle_guard": {"attack": 5, "death": 6, "hurt": 3, "idle": 4, "walk": 6},
	"cursed_shield_guard": {
		"attack": 5, "attack_unshielded": 5, "block": 3,
		"death": 6, "death_unshielded": 6, "guard_break": 4,
		"hurt": 3, "hurt_unshielded": 3, "idle": 4,
		"idle_unshielded": 4, "walk": 6, "walk_unshielded": 6,
	},
	"decayed_spearman": {"attack_thrust": 6, "death": 6, "hurt": 3, "idle": 4, "walk": 6},
	"fallen_crossbowman": {"aim": 4, "death": 6, "hurt": 3, "idle": 4, "reload": 4, "shoot": 3, "walk": 6},
	"gargoyle_sentinel": {
		"death_fall": 5, "death_shatter": 5, "dive": 4, "dive_windup": 4,
		"dormant": 4, "ground_stun": 4, "hover": 4, "hurt": 3,
		"return_to_air": 4, "wake": 4,
	},
	"fallen_gate_knight": {
		"charge_thrust": 5, "combo_slash_1": 5, "combo_slash_2": 5,
		"death": 7, "heavy_overhead": 6, "hurt_shielded": 3,
		"hurt_unshielded": 3, "idle_shielded": 4, "idle_unshielded": 4,
		"jump_smash": 6, "phase_transition": 5, "shield_bash": 5,
		"shield_block": 4, "shield_break": 5, "shockwave_strike": 6,
		"sword_slash": 5, "turn_shielded": 3, "turn_unshielded": 3,
		"walk_shielded": 6, "walk_unshielded": 6,
	},
}


func _initialize() -> void:
	var total: int = 0
	for role: String in ROLES:
		var size: int = BOSS_FRAME_SIZE if role == "fallen_gate_knight" else ENEMY_FRAME_SIZE
		var legacy_size: int = BOSS_LEGACY_SIZE if role == "fallen_gate_knight" else ENEMY_LEGACY_SIZE
		var definitions: Dictionary = ANIMATIONS[role] as Dictionary
		for animation: String in definitions:
			var count: int = int(definitions[animation])
			var directory: String = _sprite_root(role) + "/" + animation
			if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
				push_error("Cannot create Chapter I art directory: %s" % directory)
				quit(1)
				return
			for frame: int in range(count):
				var image: Image = _draw_frame(role, animation, frame, count, legacy_size, size)
				var output: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
				if image.save_png(ProjectSettings.globalize_path(output)) != OK:
					push_error("Cannot save Chapter I formal frame: %s" % output)
					quit(1)
					return
				total += 1
		_write_role_references(role, legacy_size, size)
	_write_shield_effects()
	_write_boss_shield_overlays()
	print("CH1 ENEMY ART V2 | PASS roles=%d frames=%d" % [ROLES.size(), total])
	quit(0)


func _sprite_root(role: String) -> String:
	if role == "fallen_gate_knight":
		return ROOT + "/boss/fallen_gate_knight/sprites"
	return ROOT + "/enemies/" + role + "/sprites"


func _draw_frame(role: String, animation: String, frame: int, count: int, legacy_size: int, output_size: int) -> Image:
	var legacy: Image = Image.create(legacy_size, legacy_size, false, Image.FORMAT_RGBA8)
	legacy.fill(CLEAR)
	var phase: float = float(frame) / float(maxi(1, count - 1))
	match role:
		"castle_guard": _draw_castle_guard(legacy, animation, frame, phase)
		"cursed_shield_guard": _draw_shield_guard(legacy, animation, frame, phase)
		"decayed_spearman": _draw_spearman(legacy, animation, frame, phase)
		"fallen_crossbowman": _draw_crossbowman(legacy, animation, frame, phase)
		"gargoyle_sentinel": _draw_gargoyle(legacy, animation, frame, phase)
		"fallen_gate_knight": _draw_gate_knight(legacy, animation, frame, phase)
	var image: Image = Image.create(output_size, output_size, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var offset: Vector2i = Vector2i((output_size - legacy_size) / 2, (output_size - legacy_size) / 2)
	image.blit_rect(legacy, Rect2i(Vector2i.ZERO, Vector2i(legacy_size, legacy_size)), offset)
	_draw_replication_details(image, role, animation, frame, phase, offset)
	return image


func _draw_replication_details(img: Image, role: String, animation: String, frame: int, phase: float, offset: Vector2i) -> void:
	if animation.contains("death"):
		return
	var ox: int = offset.x
	var oy: int = offset.y
	match role:
		"castle_guard":
			# Raven-visored patrol helm, layered gorget and royal service studs.
			_poly(img, _pts([ox+25,oy+8,ox+30,oy+1,ox+35,oy+8,ox+33,oy+11,ox+27,oy+11]), OUTLINE)
			_poly(img, _pts([ox+27,oy+8,ox+30,oy+4,ox+33,oy+8,ox+31,oy+9,ox+28,oy+9]), IRON_LIT)
			for rivet: int in range(4): _ellipse(img, Vector2i(ox+24+rivet*4,oy+31), 1, 1, GOLD)
			_draw_segment(img, Vector2i(ox+26,oy+38), Vector2i(ox+34,oy+38), 1, RUST_LIT)
		"cursed_shield_guard":
			var unshielded: bool = animation.contains("unshielded") or animation == "guard_break"
			if not unshielded:
				# Beaked Ravenmourn ward crest and permanent shield construction marks.
				_poly(img, _pts([ox+12,oy+26,ox+19,oy+21,ox+25,oy+26,ox+19,oy+31]), RUST_LIT)
				_draw_segment(img, Vector2i(ox+14,oy+19), Vector2i(ox+24,oy+19), 2, GOLD)
				for rivet: Vector2i in [Vector2i(13,15),Vector2i(25,15),Vector2i(13,46),Vector2i(25,46)]: _ellipse(img, offset+rivet,1,1,STEEL)
			else:
				# Broken harness remains visible so the permanent state change reads at 48px.
				_draw_segment(img, Vector2i(ox+20,oy+25), Vector2i(ox+34,oy+40), 2, LEATHER_LIT)
				_draw_segment(img, Vector2i(ox+20,oy+40), Vector2i(ox+34,oy+25), 2, LEATHER)
		"decayed_spearman":
			# Nasal helm, mail rows and a hooked oath pennon separate him from the guard.
			_draw_segment(img, Vector2i(ox+30,oy+8), Vector2i(ox+30,oy+18), 2, STEEL)
			for row: int in range(4):
				for link: int in range(3): _pixel(img, ox+25+link*4+(row%2)*2, oy+24+row*4, IRON_LIT)
			_poly(img, _pts([ox+39,oy+20,ox+46,oy+23,ox+40,oy+27]), WINE)
		"fallen_crossbowman":
			# Quarrel fletching, hood seam and belt tools remain readable during aim/reload.
			_draw_segment(img, Vector2i(ox+26,oy+9), Vector2i(ox+34,oy+14), 1, CLOTH_LIT)
			for bolt: int in range(3): _draw_segment(img, Vector2i(ox+18+bolt*3,oy+27), Vector2i(ox+16+bolt*3,oy+20), 1, STEEL)
			_ellipse(img, Vector2i(ox+27,oy+37), 2, 2, GOLD)
		"gargoyle_sentinel":
			# Chiselled chapel runes and cold soul seams preserve a carved-stone identity.
			_draw_segment(img, Vector2i(ox+27,oy+19), Vector2i(ox+31,oy+25), 1, MOON_BLUE)
			_draw_segment(img, Vector2i(ox+31,oy+25), Vector2i(ox+35,oy+18), 1, MOON_LIT)
			for chip: Vector2i in [Vector2i(19,31),Vector2i(42,30),Vector2i(25,44),Vector2i(38,46)]: _pixel(img,ox+chip.x,oy+chip.y,STONE_LIT)
		"fallen_gate_knight":
			var phase_two: bool = animation.contains("unshielded") or animation in ["phase_transition","charge_thrust","combo_slash_1","combo_slash_2","heavy_overhead","jump_smash","shockwave_strike"]
			# Crowned gate helm, layered cuirass and oath-chain survive every combat pose.
			_poly(img,_pts([ox+42,oy+16,ox+48,oy+6,ox+54,oy+16,ox+52,oy+20,ox+44,oy+20]),OUTLINE)
			_poly(img,_pts([ox+44,oy+16,ox+48,oy+10,ox+52,oy+16,ox+50,oy+18,ox+46,oy+18]),GOLD)
			_draw_segment(img,Vector2i(ox+39,oy+46),Vector2i(ox+57,oy+46),2,IRON_LIT)
			for clasp: int in range(5): _ellipse(img,Vector2i(ox+40+clasp*4,oy+52),1,1,GOLD)
			if phase_two:
				# Exposed cursed left arm and brighter soul fissure make Phase II structural.
				_draw_segment(img,Vector2i(ox+37,oy+35),Vector2i(ox+30,oy+56),4,IRON_DARK)
				_draw_segment(img,Vector2i(ox+36,oy+38),Vector2i(ox+31,oy+54),1,MOON_LIT)
			else:
				# Shield face receives the gate sigil rather than a featureless slab.
				_poly(img,_pts([ox+23,oy+36,ox+31,oy+29,ox+39,oy+36,ox+31,oy+43]),GOLD)
				_poly(img,_pts([ox+27,oy+36,ox+31,oy+32,ox+35,oy+36,ox+31,oy+39]),WINE)


# -- Castle Guard -----------------------------------------------------------

func _draw_castle_guard(img: Image, animation: String, frame: int, phase: float) -> void:
	if animation == "death":
		_draw_guard_death(img, frame, false)
		return
	var stride: int = [-4, -2, 1, 4, 2, -1][frame] if animation == "walk" else 0
	var bob: int = [0, -1, 0, 0, -1, 0][frame] if animation == "walk" else [0, -1, -1, 0][frame] if animation == "idle" else 0
	var x: int = 30
	var y: int = 5 + bob
	if animation == "hurt": x -= 3 + frame
	if animation == "attack":
		x += [0, -2, 4, 5, 1][frame]
	# Split greaves and sabatons.
	_draw_segment(img, Vector2i(x - 5, y + 37), Vector2i(x - 7 - stride, 57), 7, OUTLINE)
	_draw_segment(img, Vector2i(x + 5, y + 37), Vector2i(x + 7 + stride, 57), 7, OUTLINE)
	_draw_segment(img, Vector2i(x - 5, y + 38), Vector2i(x - 7 - stride, 56), 4, IRON)
	_draw_segment(img, Vector2i(x + 5, y + 38), Vector2i(x + 7 + stride, 56), 4, IRON_LIT)
	_poly(img, _pts([x-12,y+19,x-8,y+14,x+8,y+14,x+13,y+20,x+10,y+41,x+4,y+47,x-5,y+46,x-11,y+40]), OUTLINE)
	_poly(img, _pts([x-10,y+20,x-7,y+16,x+6,y+16,x+10,y+21,x+8,y+38,x+3,y+44,x-4,y+43,x-8,y+38]), IRON_DARK)
	# Tarnished breastplate ribs, belt and torn raven tabard.
	_poly(img, _pts([x-7,y+18,x+6,y+18,x+8,y+31,x+3,y+35,x-5,y+33,x-8,y+27]), IRON)
	_draw_segment(img, Vector2i(x-5,y+21), Vector2i(x+5,y+20), 1, IRON_LIT)
	_draw_segment(img, Vector2i(x-6,y+25), Vector2i(x+6,y+24), 1, RUST)
	_draw_segment(img, Vector2i(x-8,y+34), Vector2i(x+8,y+34), 3, LEATHER)
	for stud: int in range(5): _pixel(img, x - 6 + stud * 3, y + 34, GOLD)
	_poly(img, _pts([x-5,y+35,x+5,y+35,x+4,y+48,x,y+45,x-4,y+49]), WINE)
	_draw_segment(img, Vector2i(x,y+36), Vector2i(x,y+45), 1, WINE_LIT)
	# Separate shoulder plates and sword arm.
	_poly(img, _pts([x-14,y+18,x-11,y+12,x-4,y+13,x-6,y+21]), OUTLINE)
	_poly(img, _pts([x-12,y+17,x-10,y+14,x-6,y+15,x-7,y+19]), IRON_LIT)
	_poly(img, _pts([x+14,y+18,x+10,y+12,x+4,y+14,x+7,y+22]), OUTLINE)
	_poly(img, _pts([x+12,y+17,x+9,y+14,x+6,y+16,x+8,y+20]), IRON)
	var hand: Vector2i = Vector2i(x + 14, y + 31)
	var sword_tip: Vector2i = Vector2i(x + 27, y + 48)
	if animation == "attack":
		var hands: Array[Vector2i] = [Vector2i(x+11,y+21),Vector2i(x+7,y+14),Vector2i(x+18,y+27),Vector2i(x+19,y+35),Vector2i(x+14,y+31)]
		var tips: Array[Vector2i] = [Vector2i(x+16,y-2),Vector2i(x+29,y+1),Vector2i(60,y+31),Vector2i(57,y+49),Vector2i(x+28,y+49)]
		hand = hands[frame]; sword_tip = tips[frame]
	_draw_segment(img, Vector2i(x+8,y+20), hand, 6, OUTLINE)
	_draw_segment(img, Vector2i(x+8,y+21), hand, 3, IRON_LIT)
	_draw_gauntlet(img, hand)
	_draw_arming_sword(img, hand, sword_tip, 5)
	# Sallet with articulated neck and lit eye slit.
	_poly(img, _pts([x-8,y+2,x-4,y-1,x+5,y,x+9,y+5,x+7,y+14,x+3,y+17,x-6,y+15,x-10,y+9]), OUTLINE)
	_poly(img, _pts([x-6,y+3,x-3,y+1,x+4,y+2,x+7,y+6,x+5,y+12,x+2,y+14,x-5,y+13,x-8,y+8]), IRON)
	_poly(img, _pts([x-6,y+7,x+7,y+6,x+5,y+10,x-5,y+10]), IRON_DARK)
	_draw_segment(img, Vector2i(x-4,y+8), Vector2i(x+5,y+8), 1, CURSE_RED)
	_pixel(img, x + 4, y + 8, CURSE_LIT)
	_poly(img, _pts([x-8,y+3,x-4,y-1,x+1,y+1,x-2,y+3]), IRON_LIT)
	# Buckles, rust clusters and readable damage.
	_pixel(img, x-5, y+28, RUST_LIT); _pixel(img, x+4, y+23, RUST)
	_pixel(img, x+8, y+39, STEEL); _pixel(img, x-7, y+40, LEATHER_LIT)


func _draw_guard_death(img: Image, frame: int, shielded: bool) -> void:
	var y: int = 43 + mini(frame, 3) * 4
	var alpha: float = 1.0 if frame < 4 else 0.72 if frame == 4 else 0.42
	var iron: Color = Color(IRON.r, IRON.g, IRON.b, alpha)
	var dark: Color = Color(IRON_DARK.r, IRON_DARK.g, IRON_DARK.b, alpha)
	_poly(img, _pts([8,y+2,19,y-3,46,y-5,56,y+3,49,y+12,14,y+12]), OUTLINE)
	_poly(img, _pts([12,y+2,21,y-1,43,y-3,51,y+3,46,y+8,16,y+9]), dark)
	_poly(img, _pts([18,y,32,y-4,39,y+3,27,y+6]), iron)
	_draw_arming_sword(img, Vector2i(43,y+1), Vector2i(61,58), 5)
	if shielded:
		_draw_kite_shield(img, Vector2i(24,y+2), 1, 9, 16, 1.0, false)
	_draw_death_fragments(img, frame, IRON_LIT, RUST_LIT, 64)


# -- Shield Guard -----------------------------------------------------------

func _draw_shield_guard(img: Image, animation: String, frame: int, phase: float) -> void:
	var unshielded: bool = animation.ends_with("_unshielded")
	if animation.begins_with("death"):
		_draw_guard_death(img, frame, not unshielded)
		return
	var walk: bool = animation.begins_with("walk")
	var stride: int = [-3,-1,1,3,1,-1][frame] if walk else 0
	var bob: int = [0,-1,0,0,-1,0][frame] if walk else [0,-1,-1,0][frame] if animation.begins_with("idle") else 0
	var x: int = 29
	var y: int = 4 + bob
	if animation.begins_with("hurt"): x -= 3 + frame
	if animation == "guard_break": x -= [2,5,6,3][frame]
	if animation.begins_with("attack"): x += [0,-2,3,4,1][frame]
	_draw_segment(img, Vector2i(x-7,y+39), Vector2i(x-9-stride,58), 9, OUTLINE)
	_draw_segment(img, Vector2i(x+7,y+39), Vector2i(x+9+stride,58), 9, OUTLINE)
	_draw_segment(img, Vector2i(x-7,y+40), Vector2i(x-9-stride,57), 6, IRON)
	_draw_segment(img, Vector2i(x+7,y+40), Vector2i(x+9+stride,57), 6, IRON_LIT)
	_poly(img,_pts([x-17,y+18,x-12,y+11,x+12,y+11,x+18,y+20,x+15,y+43,x+8,y+50,x-9,y+49,x-16,y+42]),OUTLINE)
	_poly(img,_pts([x-14,y+19,x-10,y+14,x+10,y+14,x+15,y+21,x+12,y+40,x+6,y+47,x-7,y+46,x-13,y+40]),IRON_DARK)
	_poly(img,_pts([x-10,y+17,x+9,y+17,x+11,y+33,x+5,y+38,x-6,y+37,x-11,y+31]),IRON)
	for rib: int in range(3): _draw_segment(img,Vector2i(x-8,y+20+rib*4),Vector2i(x+8,y+19+rib*4),1,IRON_LIT if rib==0 else RUST)
	_draw_segment(img,Vector2i(x-11,y+35),Vector2i(x+11,y+35),3,LEATHER)
	_poly(img,_pts([x-7,y+36,x+7,y+36,x+5,y+49,x,y+46,x-5,y+50]),CLOTH)
	# Heavy pauldrons with independent silhouette.
	_poly(img,_pts([x-19,y+19,x-15,y+10,x-6,y+12,x-8,y+23]),OUTLINE)
	_poly(img,_pts([x-16,y+18,x-13,y+13,x-8,y+14,x-10,y+20]),IRON_LIT)
	_poly(img,_pts([x+19,y+19,x+15,y+10,x+6,y+12,x+8,y+23]),OUTLINE)
	_poly(img,_pts([x+16,y+18,x+13,y+13,x+8,y+14,x+10,y+20]),IRON)
	# Helmet is taller and more fortified than basic guard.
	_poly(img,_pts([x-9,y+2,x-5,y-2,x+5,y-1,x+10,y+5,x+8,y+16,x+3,y+19,x-7,y+16,x-11,y+8]),OUTLINE)
	_poly(img,_pts([x-7,y+3,x-4,y,x+4,y+1,x+7,y+6,x+5,y+13,x+2,y+16,x-5,y+14,x-8,y+7]),IRON)
	_draw_segment(img,Vector2i(x-6,y+7),Vector2i(x+6,y+7),2,IRON_DARK)
	_draw_segment(img,Vector2i(x-4,y+8),Vector2i(x+5,y+8),1,CURSE_RED)
	_pixel(img,x+4,y+8,CURSE_LIT)
	var hand: Vector2i = Vector2i(x+15,y+31)
	var mace_tip: Vector2i = Vector2i(x+24,y+48)
	if animation.begins_with("attack"):
		var hands: Array[Vector2i] = [Vector2i(x+11,y+21),Vector2i(x+8,y+14),Vector2i(x+19,y+27),Vector2i(x+21,y+37),Vector2i(x+15,y+31)]
		var tips: Array[Vector2i] = [Vector2i(x+17,y),Vector2i(x+28,y+3),Vector2i(59,y+30),Vector2i(57,y+50),Vector2i(x+26,y+49)]
		hand = hands[frame]; mace_tip = tips[frame]
	_draw_segment(img,Vector2i(x+9,y+21),hand,7,OUTLINE)
	_draw_segment(img,Vector2i(x+9,y+21),hand,4,IRON_LIT)
	_draw_gauntlet(img,hand)
	_draw_mace(img,hand,mace_tip)
	if not unshielded:
		var shield_center: Vector2i = Vector2i(x-14,y+31)
		var shield_rot: int = -1
		if animation == "block": shield_center += Vector2i([2,5,7][frame],[-1,-3,-2][frame])
		if animation == "guard_break": shield_center += Vector2i(-frame*5,-frame*3)
		_draw_kite_shield(img,shield_center,shield_rot,14,26,1.0,animation=="guard_break" and frame>=1)
	elif animation == "guard_break":
		_draw_shield_fragments(img,Vector2i(16,25),frame)
	# Broken straps remain after shield loss.
	if unshielded:
		_draw_segment(img,Vector2i(x-9,y+20),Vector2i(x-15,y+31),2,LEATHER_LIT)
		_draw_segment(img,Vector2i(x-10,y+23),Vector2i(x-17,y+27),1,GOLD)


# -- Spearman ---------------------------------------------------------------

func _draw_spearman(img: Image, animation: String, frame: int, phase: float) -> void:
	if animation == "death":
		_draw_spearman_death(img,frame)
		return
	var stride: int = [-4,-2,1,4,2,-1][frame] if animation=="walk" else 0
	var bob: int = [0,-1,0,0,-1,0][frame] if animation=="walk" else [0,-1,-1,0][frame] if animation=="idle" else 0
	var x: int = 25
	var y: int = 4+bob
	if animation=="hurt": x -= 3+frame
	if animation=="attack_thrust": x += [0,-2,1,5,6,2][frame]
	_draw_segment(img,Vector2i(x-4,y+40),Vector2i(x-6-stride,58),5,OUTLINE)
	_draw_segment(img,Vector2i(x+4,y+40),Vector2i(x+6+stride,58),5,OUTLINE)
	_draw_segment(img,Vector2i(x-4,y+40),Vector2i(x-6-stride,57),3,IRON)
	_draw_segment(img,Vector2i(x+4,y+40),Vector2i(x+6+stride,57),3,IRON_LIT)
	_poly(img,_pts([x-10,y+18,x-7,y+14,x+7,y+14,x+11,y+20,x+8,y+44,x+3,y+50,x-4,y+49,x-9,y+43]),OUTLINE)
	_poly(img,_pts([x-8,y+19,x-5,y+16,x+5,y+16,x+8,y+21,x+6,y+41,x+2,y+47,x-3,y+46,x-7,y+41]),CLOTH)
	# Mail texture and torn gambeson tails.
	for row: int in range(4):
		for col: int in range(4):
			_pixel(img,x-5+col*3+(row%2),y+20+row*3,IRON_LIT if (row+col)%3==0 else IRON)
	_poly(img,_pts([x-5,y+33,x+6,y+33,x+5,y+49,x+1,y+45,x-3,y+50]),MOSS)
	_draw_segment(img,Vector2i(x-7,y+34),Vector2i(x+7,y+34),2,LEATHER)
	# Narrow nasal helm.
	_poly(img,_pts([x-7,y+3,x-2,y-2,x+4,y+1,x+8,y+6,x+5,y+16,x-5,y+16,x-9,y+9]),OUTLINE)
	_poly(img,_pts([x-5,y+3,x-1,y,x+3,y+2,x+6,y+6,x+3,y+13,x-4,y+13,x-7,y+8]),IRON)
	_poly(img,_pts([x-2,y-2,x+1,y-6,x+3,y+2]),IRON_LIT)
	_draw_segment(img,Vector2i(x,y+4),Vector2i(x,y+14),2,IRON_LIT)
	_pixel(img,x+3,y+8,MOON_LIT)
	var back_hand: Vector2i = Vector2i(x-6,y+29)
	var front_hand: Vector2i = Vector2i(x+8,y+28)
	var butt: Vector2i = Vector2i(4,51)
	var tip: Vector2i = Vector2i(61,22)
	if animation=="attack_thrust":
		var hands: Array[Vector2i] = [Vector2i(x-5,y+25),Vector2i(x-1,y+24),Vector2i(x+7,y+28),Vector2i(x+11,y+29),Vector2i(x+12,y+29),Vector2i(x+7,y+29)]
		var tips: Array[Vector2i] = [Vector2i(48,y+10),Vector2i(43,y+14),Vector2i(60,y+25),Vector2i(63,y+27),Vector2i(63,y+28),Vector2i(56,y+25)]
		front_hand=hands[frame]; back_hand=front_hand-Vector2i(10,2); tip=tips[frame]; butt=back_hand-Vector2i(25,7)
	_draw_segment(img,Vector2i(x-7,y+20),back_hand,5,OUTLINE)
	_draw_segment(img,Vector2i(x-7,y+20),back_hand,3,CLOTH_LIT)
	_draw_segment(img,Vector2i(x+7,y+20),front_hand,5,OUTLINE)
	_draw_segment(img,Vector2i(x+7,y+20),front_hand,3,IRON)
	_draw_gauntlet(img,back_hand); _draw_gauntlet(img,front_hand)
	_draw_spear(img,butt,tip,front_hand)


func _draw_spearman_death(img: Image, frame: int) -> void:
	var y: int=42+mini(frame,3)*4
	_poly(img,_pts([8,y+5,19,y-2,42,y-4,51,y+3,45,y+11,12,y+12]),OUTLINE)
	_poly(img,_pts([13,y+4,21,y,40,y-2,47,y+3,42,y+8,16,y+9]),CLOTH)
	_draw_spear(img,Vector2i(2,58),Vector2i(62,47),Vector2i(34,53))
	_draw_death_fragments(img,frame,IRON_LIT,MOSS,64)


# -- Crossbowman ------------------------------------------------------------

func _draw_crossbowman(img: Image, animation: String, frame: int, phase: float) -> void:
	if animation=="death":
		_draw_crossbow_death(img,frame)
		return
	var stride: int=[-4,-2,1,4,2,-1][frame] if animation=="walk" else 0
	var bob: int=[0,-1,0,0,-1,0][frame] if animation=="walk" else [0,-1,-1,0][frame] if animation=="idle" else 0
	var x: int=28
	var y: int=6+bob
	if animation=="hurt": x-=3+frame
	if animation=="shoot": x += [0,3,1][frame]
	_draw_segment(img,Vector2i(x-5,y+38),Vector2i(x-7-stride,58),5,OUTLINE)
	_draw_segment(img,Vector2i(x+5,y+38),Vector2i(x+7+stride,58),5,OUTLINE)
	_draw_segment(img,Vector2i(x-5,y+39),Vector2i(x-7-stride,57),3,LEATHER)
	_draw_segment(img,Vector2i(x+5,y+39),Vector2i(x+7+stride,57),3,IRON)
	_poly(img,_pts([x-10,y+18,x-6,y+14,x+7,y+15,x+11,y+22,x+8,y+43,x+3,y+48,x-5,y+47,x-10,y+40]),OUTLINE)
	_poly(img,_pts([x-8,y+19,x-5,y+16,x+5,y+17,x+8,y+22,x+6,y+40,x+2,y+45,x-4,y+44,x-8,y+38]),LEATHER)
	_poly(img,_pts([x-5,y+20,x+5,y+19,x+6,y+30,x-4,y+32]),IRON_DARK)
	_draw_segment(img,Vector2i(x-4,y+21),Vector2i(x+4,y+20),1,IRON_LIT)
	_draw_segment(img,Vector2i(x-8,y+33),Vector2i(x+8,y+33),2,LEATHER_LIT)
	# Hood over a half-mask and visible quiver.
	_poly(img,_pts([x-8,y+3,x-3,y-1,x+5,y+1,x+9,y+8,x+5,y+17,x-5,y+16,x-10,y+10]),OUTLINE)
	_poly(img,_pts([x-6,y+4,x-2,y+1,x+4,y+3,x+6,y+8,x+3,y+14,x-4,y+13,x-7,y+9]),CLOTH)
	_poly(img,_pts([x-5,y+8,x+5,y+7,x+4,y+13,x-4,y+13]),IRON)
	_pixel(img,x+3,y+9,MOON_LIT)
	_poly(img,_pts([x-11,y+21,x-15,y+19,x-13,y+40,x-8,y+38]),OUTLINE)
	_poly(img,_pts([x-13,y+21,x-12,y+36,x-9,y+37,x-10,y+22]),LEATHER_LIT)
	for bolt: int in range(3):
		_draw_segment(img,Vector2i(x-13+bolt,y+20),Vector2i(x-10+bolt,y+11+bolt),1,STEEL)
	var center: Vector2i=Vector2i(x+10,y+29)
	var aim_shift: int=0
	if animation=="aim": aim_shift=[-2,0,1,2][frame]
	if animation=="reload": center+=Vector2i([-3,-1,0,2][frame],[7,9,5,1][frame])
	if animation=="shoot": center+=Vector2i([0,4,1][frame],[0,1,0][frame])
	center+=Vector2i(aim_shift,0)
	_draw_segment(img,Vector2i(x-6,y+22),center-Vector2i(7,0),5,OUTLINE)
	_draw_segment(img,Vector2i(x+6,y+21),center+Vector2i(4,1),5,OUTLINE)
	_draw_segment(img,Vector2i(x-6,y+22),center-Vector2i(7,0),3,LEATHER_LIT)
	_draw_segment(img,Vector2i(x+6,y+21),center+Vector2i(4,1),3,IRON)
	_draw_crossbow(img,center,1,animation=="shoot" and frame==1,animation=="reload" and frame<3)


func _draw_crossbow_death(img: Image, frame: int) -> void:
	var y: int=43+mini(frame,3)*4
	_poly(img,_pts([10,y+2,20,y-3,42,y-3,52,y+4,46,y+11,15,y+11]),OUTLINE)
	_poly(img,_pts([14,y+2,22,y-1,39,y-1,47,y+4,42,y+8,18,y+8]),LEATHER)
	_draw_crossbow(img,Vector2i(51,54),1,false,false)
	_draw_death_fragments(img,frame,LEATHER_LIT,IRON_LIT,64)


# -- Gargoyle ---------------------------------------------------------------

func _draw_gargoyle(img: Image, animation: String, frame: int, phase: float) -> void:
	if animation=="death_shatter":
		_draw_gargoyle_shatter(img,frame)
		return
	if animation=="death_fall":
		_draw_gargoyle_fall(img,frame)
		return
	var dormant: bool=animation=="dormant"
	var stunned: bool=animation=="ground_stun"
	var dive: bool=animation=="dive"
	var spread: int=[0,2,4,2][frame]
	var x: int=31+(frame*4 if dive else 0)
	var y: int=(34 if dormant or stunned else 24)+([0,-2,0,2][frame] if animation in ["hover","return_to_air"] else 0)
	if animation=="wake": y=34-frame*3
	if animation=="dive_windup": x-=frame*2; y-=frame
	if animation=="hurt": x-=3+frame; y+=frame
	# Asymmetric stone wings with ribbed membranes.
	var wing_drop: int=10 if dormant or stunned else 0
	_draw_gargoyle_wing(img,Vector2i(x-5,y-5),-1,spread,wing_drop,frame)
	_draw_gargoyle_wing(img,Vector2i(x+5,y-5),1,spread+1,wing_drop,frame+1)
	# Digitigrade legs and hooked talons.
	var leg_y: int=y+15
	_draw_segment(img,Vector2i(x-6,leg_y),Vector2i(x-10,leg_y+14),7,OUTLINE)
	_draw_segment(img,Vector2i(x+6,leg_y),Vector2i(x+10,leg_y+14),7,OUTLINE)
	_draw_segment(img,Vector2i(x-6,leg_y),Vector2i(x-10,leg_y+14),4,STONE)
	_draw_segment(img,Vector2i(x+6,leg_y),Vector2i(x+10,leg_y+14),4,STONE_LIT)
	for claw: int in range(3):
		_draw_segment(img,Vector2i(x-10,leg_y+14),Vector2i(x-16+claw*3,leg_y+17+claw%2),1,STEEL)
		_draw_segment(img,Vector2i(x+10,leg_y+14),Vector2i(x+8+claw*4,leg_y+17+claw%2),1,STEEL)
	# Faceted torso, shoulders and arms.
	_poly(img,_pts([x-11,y-5,x-6,y-12,x+7,y-11,x+12,y-4,x+9,y+15,x+2,y+21,x-7,y+18,x-12,y+8]),OUTLINE)
	_poly(img,_pts([x-9,y-4,x-5,y-9,x+5,y-8,x+9,y-3,x+7,y+12,x+1,y+17,x-5,y+15,x-9,y+6]),STONE)
	_poly(img,_pts([x-4,y-6,x+4,y-7,x+6,y+7,x+1,y+13,x-3,y+8]),STONE_LIT)
	_draw_segment(img,Vector2i(x-7,y-4),Vector2i(x+6,y+8),2,IRON_DARK)
	_pixel(img,x,y+5,MOON_BLUE); _pixel(img,x+1,y+5,MOON_LIT)
	var left_claw: Vector2i=Vector2i(x-17,y+12)
	var right_claw: Vector2i=Vector2i(x+18,y+11)
	if dive: right_claw=Vector2i(60,y+7+frame*2); left_claw=Vector2i(x+7,y+14)
	_draw_segment(img,Vector2i(x-9,y),left_claw,7,OUTLINE)
	_draw_segment(img,Vector2i(x+9,y),right_claw,7,OUTLINE)
	_draw_segment(img,Vector2i(x-9,y),left_claw,4,STONE)
	_draw_segment(img,Vector2i(x+9,y),right_claw,4,STONE_LIT)
	_draw_monster_claw(img,left_claw,-1); _draw_monster_claw(img,right_claw,1)
	# Horned skull.
	_poly(img,_pts([x-8,y-20,x-4,y-25,x+5,y-23,x+10,y-17,x+7,y-8,x+2,y-5,x-6,y-8,x-11,y-15]),OUTLINE)
	_poly(img,_pts([x-6,y-19,x-3,y-22,x+4,y-20,x+7,y-16,x+5,y-10,x+1,y-8,x-4,y-10,x-8,y-15]),STONE_LIT)
	_poly(img,_pts([x-5,y-22,x-8,y-30,x-2,y-25]),STONE)
	_poly(img,_pts([x+4,y-21,x+9,y-29,x+8,y-19]),STONE)
	_pixel(img,x-3,y-15,MOON_LIT); _pixel(img,x+3,y-15,MOON_LIT)
	_draw_segment(img,Vector2i(x-3,y-10),Vector2i(x+4,y-10),1,VOID)
	_pixel(img,x-5,y-5,MOSS); _pixel(img,x+7,y+3,MOSS)


func _draw_gargoyle_wing(img: Image, root: Vector2i, side: int, spread: int, drop: int, frame: int) -> void:
	var top: Vector2i=root+Vector2i(side*(10+spread),-17+drop)
	var outer: Vector2i=root+Vector2i(side*(23+spread),-6+drop)
	var lower: Vector2i=root+Vector2i(side*(18+spread),14+drop/2)
	_poly(img,PackedVector2Array([root,top,outer,lower,root+Vector2i(side*5,8)]),OUTLINE)
	_poly(img,PackedVector2Array([root+Vector2i(side*2,0),top+Vector2i(-side*2,3),outer+Vector2i(-side*3,1),lower+Vector2i(-side*3,-2),root+Vector2i(side*4,6)]),STONE)
	_draw_segment(img,root,top,3,STONE_LIT)
	_draw_segment(img,root,outer,2,STONE_LIT)
	_draw_segment(img,root,lower,2,IRON_DARK)
	_draw_segment(img,top+Vector2i(0,3),lower-Vector2i(0,3),1,IRON_DARK)
	_pixel(img,outer.x-side*3,outer.y,MOSS)


func _draw_gargoyle_fall(img: Image, frame: int) -> void:
	var center: Vector2i=Vector2i(31,24+frame*7)
	_poly(img,_pts([center.x-13,center.y-10,center.x+12,center.y-8,center.x+15,center.y+9,center.x+3,center.y+17,center.x-11,center.y+12]),OUTLINE)
	_poly(img,_pts([center.x-9,center.y-7,center.x+9,center.y-5,center.x+11,center.y+7,center.x+2,center.y+13,center.x-8,center.y+9]),STONE)
	_draw_death_fragments(img,frame,STONE_LIT,MOON_BLUE,64)


func _draw_gargoyle_shatter(img: Image, frame: int) -> void:
	var center: Vector2i=Vector2i(31,42)
	for shard: int in range(7+frame*4):
		var angle: float=TAU*float(shard)/float(7+frame*4)
		var radius: float=5.0+float(frame*4)+(shard%3)*2.0
		var p: Vector2i=center+Vector2i(roundi(cos(angle)*radius),roundi(sin(angle)*radius*0.65))
		_poly(img,_pts([p.x-2,p.y+2,p.x,p.y-3,p.x+3,p.y+1,p.x+1,p.y+3]),STONE_LIT if shard%3 else MOON_BLUE)


# -- Fallen Gate Knight -----------------------------------------------------

func _draw_gate_knight(img: Image, animation: String, frame: int, phase: float) -> void:
	if animation=="death":
		_draw_boss_death(img,frame)
		return
	var shielded: bool=animation.ends_with("_shielded") or animation in ["shield_bash","shield_block","shield_break","phase_transition"]
	var walk: bool=animation.begins_with("walk")
	var stride: int=[-5,-2,2,5,2,-2][frame] if walk else 0
	var bob: int=[0,-1,0,0,-1,0][frame] if walk else [0,-1,-1,0][frame] if animation.begins_with("idle") else 0
	var x: int=44
	var y: int=6+bob
	if animation.begins_with("hurt"): x-=4+frame*2
	if animation=="charge_thrust": x += [0,-3,5,10,6][frame]
	if animation in ["combo_slash_1","combo_slash_2","sword_slash"]: x += [0,-2,4,7,2][frame]
	if animation=="shield_bash": x += [0,-2,4,8,3][frame]
	if animation=="jump_smash": y += [0,-8,-14,-7,5,1][frame]; x += [0,1,4,7,8,3][frame]
	# Large articulated legs and sabatons.
	_draw_segment(img,Vector2i(x-9,y+55),Vector2i(x-13-stride,y+86),13,OUTLINE)
	_draw_segment(img,Vector2i(x+9,y+55),Vector2i(x+13+stride,y+86),13,OUTLINE)
	_draw_segment(img,Vector2i(x-9,y+56),Vector2i(x-13-stride,y+84),8,IRON)
	_draw_segment(img,Vector2i(x+9,y+56),Vector2i(x+13+stride,y+84),8,IRON_LIT)
	_poly(img,_pts([x-22,y+26,x-15,y+16,x+15,y+16,x+23,y+29,x+19,y+61,x+10,y+69,x-12,y+68,x-21,y+58]),OUTLINE)
	_poly(img,_pts([x-18,y+28,x-13,y+20,x+12,y+20,x+19,y+30,x+15,y+56,x+7,y+64,x-9,y+63,x-17,y+54]),IRON_DARK)
	# Layered cuirass with cursed fissures and raven mantle.
	_poly(img,_pts([x-13,y+22,x+12,y+22,x+16,y+43,x+8,y+52,x-8,y+51,x-15,y+42]),IRON)
	for rib: int in range(4): _draw_segment(img,Vector2i(x-10,y+25+rib*5),Vector2i(x+11,y+24+rib*5),2,IRON_LIT if rib==0 else RUST)
	_draw_segment(img,Vector2i(x-15,y+49),Vector2i(x+15,y+49),4,LEATHER)
	for stud: int in range(7): _pixel(img,x-12+stud*4,y+49,GOLD)
	_poly(img,_pts([x-12,y+51,x+13,y+51,x+10,y+72,x+3,y+66,x-3,y+75,x-10,y+68]),WINE)
	_poly(img,_pts([x-3,y+51,x+6,y+51,x+4,y+68,x,y+64,x-2,y+72]),WINE_LIT)
	# Raven-wing pauldrons and torn back mantle.
	_poly(img,_pts([x-28,y+27,x-22,y+12,x-8,y+15,x-11,y+31]),OUTLINE)
	_poly(img,_pts([x-24,y+25,x-20,y+16,x-11,y+18,x-14,y+28]),IRON_LIT)
	_poly(img,_pts([x+28,y+27,x+22,y+12,x+8,y+15,x+11,y+31]),OUTLINE)
	_poly(img,_pts([x+24,y+25,x+20,y+16,x+11,y+18,x+14,y+28]),IRON)
	_poly(img,_pts([x-18,y+21,x-25,y+31,x-22,y+67,x-15,y+60,x-11,y+70,x-5,y+58]),CLOTH)
	# Distinct raven-crested helm.
	_poly(img,_pts([x-12,y+1,x-6,y-5,x+6,y-4,x+13,y+4,x+10,y+19,x+4,y+23,x-8,y+20,x-15,y+11]),OUTLINE)
	_poly(img,_pts([x-9,y+2,x-5,y-2,x+5,y-1,x+10,y+5,x+7,y+16,x+3,y+19,x-6,y+17,x-11,y+9]),IRON)
	_poly(img,_pts([x-8,y+6,x+10,y+5,x+7,y+11,x-7,y+12]),IRON_DARK)
	_draw_segment(img,Vector2i(x-6,y+8),Vector2i(x+7,y+8),2,CURSE_RED)
	_pixel(img,x+5,y+8,CURSE_LIT)
	_poly(img,_pts([x-6,y-4,x-12,y-18,x-3,y-12,x,y-4]),OUTLINE)
	_poly(img,_pts([x+3,y-4,x+10,y-19,x+11,y-8,x+7,y]),OUTLINE)
	_poly(img,_pts([x-5,y-5,x-9,y-15,x-4,y-10,x-1,y-4]),IRON_LIT)
	_poly(img,_pts([x+4,y-4,x+9,y-16,x+9,y-8,x+6,y]),IRON)
	# More curse exposure after shield break.
	if not shielded:
		_draw_segment(img,Vector2i(x-8,y+29),Vector2i(x-1,y+39),2,CURSE_RED)
		_draw_segment(img,Vector2i(x+5,y+22),Vector2i(x+9,y+36),1,CURSE_LIT)
		_draw_segment(img,Vector2i(x-20,y+22),Vector2i(x-27,y+40),2,WINE_LIT)
	# Attack-specific hands and sword.
	var hand: Vector2i=Vector2i(x+20,y+45)
	var sword_tip: Vector2i=Vector2i(x+38,y+77)
	if animation in ["sword_slash","combo_slash_1","combo_slash_2"]:
		var hands: Array[Vector2i]=[Vector2i(x+14,y+30),Vector2i(x+9,y+18),Vector2i(x+24,y+39),Vector2i(x+27,y+55),Vector2i(x+20,y+45)]
		var tips: Array[Vector2i]=[Vector2i(x+21,y-13),Vector2i(x+42,y-8),Vector2i(92,y+37),Vector2i(88,y+76),Vector2i(x+42,y+80)]
		hand=hands[frame]; sword_tip=tips[frame]
		if animation=="combo_slash_2": sword_tip.y=96-sword_tip.y
	elif animation=="heavy_overhead":
		var hands_h: Array[Vector2i]=[Vector2i(x+13,y+29),Vector2i(x+7,y+12),Vector2i(x+2,y+4),Vector2i(x+23,y+33),Vector2i(x+27,y+69),Vector2i(x+20,y+47)]
		var tips_h: Array[Vector2i]=[Vector2i(x+17,y-16),Vector2i(x+12,y-25),Vector2i(x+8,y-29),Vector2i(82,y+21),Vector2i(82,y+88),Vector2i(x+42,y+80)]
		hand=hands_h[frame]; sword_tip=tips_h[frame]
	elif animation=="charge_thrust":
		hand=Vector2i(x+15+[0,0,3,5,2][frame],y+40)
		sword_tip=Vector2i([68,63,89,95,78][frame],y+37)
	elif animation=="jump_smash":
		hand=Vector2i(x+14,y+[25,16,10,24,60,45][frame]); sword_tip=Vector2i(x+26,y+[-19,-28,-34,-4,83,78][frame])
	elif animation=="shockwave_strike":
		hand=Vector2i(x+16,y+[30,18,13,33,58,45][frame]); sword_tip=Vector2i(x+31,y+[-12,-22,-25,25,85,79][frame])
	_draw_segment(img,Vector2i(x+13,y+29),hand,12,OUTLINE)
	_draw_segment(img,Vector2i(x+13,y+29),hand,7,IRON_LIT)
	_draw_gauntlet_large(img,hand)
	_draw_boss_sword(img,hand,sword_tip)
	if shielded:
		var shield_center: Vector2i=Vector2i(x-21,y+45)
		if animation=="shield_bash": shield_center+=Vector2i([0,3,9,13,5][frame],[0,-2,-1,0,0][frame])
		if animation=="shield_block": shield_center+=Vector2i([0,4,7,4][frame],[-1,-4,-3,-1][frame])
		_draw_tower_shield(img,shield_center,1.0,animation=="shield_break" and frame>=1)
	if animation=="shield_break": _draw_boss_shield_fragments(img,Vector2i(x-20,y+39),frame)
	if animation=="phase_transition":
		for spark: int in range(4+frame*3):
			var p: Vector2i=Vector2i(x-24+(spark*13+frame*5)%55,y+8+(spark*11)%58)
			_pixel(img,p.x,p.y,CURSE_LIT if spark%3==0 else RUST_LIT)
	if animation=="shockwave_strike" and frame in [3,4]:
		_draw_shockwave(img,Vector2i(x+32,86),frame-3)


func _draw_boss_death(img: Image, frame: int) -> void:
	var y: int=59+mini(frame,4)*6
	var alpha: float=1.0 if frame<5 else 0.68 if frame==5 else 0.32
	var plate: Color=Color(IRON.r,IRON.g,IRON.b,alpha)
	_poly(img,_pts([8,y+4,27,y-8,70,y-9,91,y+5,80,y+22,17,y+23]),OUTLINE)
	_poly(img,_pts([14,y+5,31,y-4,66,y-5,84,y+5,75,y+16,22,y+17]),plate)
	_poly(img,_pts([27,y,54,y-4,65,y+10,38,y+14]),WINE)
	_draw_boss_sword(img,Vector2i(63,y+3),Vector2i(95,93))
	_draw_death_fragments(img,frame,IRON_LIT,CURSE_RED,96)


# -- Equipment --------------------------------------------------------------

func _draw_arming_sword(img: Image, grip: Vector2i, tip: Vector2i, width: int) -> void:
	var direction: Vector2=(Vector2(tip-grip)).normalized()
	var normal: Vector2=Vector2(-direction.y,direction.x)
	var guard: Vector2i=grip+Vector2i(roundi(direction.x*4.0),roundi(direction.y*4.0))
	var base: Vector2i=grip+Vector2i(roundi(direction.x*7.0),roundi(direction.y*7.0))
	var blade_tip: Vector2i=tip
	_draw_segment(img,grip,guard,4,LEATHER)
	_draw_segment(img,guard+Vector2i(roundi(normal.x*5.0),roundi(normal.y*5.0)),guard-Vector2i(roundi(normal.x*5.0),roundi(normal.y*5.0)),3,GOLD)
	_poly(img,PackedVector2Array([Vector2(base)+normal*float(width/2),Vector2(blade_tip),Vector2(base)-normal*float(width/2)]),OUTLINE)
	_poly(img,PackedVector2Array([Vector2(base)+normal*1.5,Vector2(blade_tip)-direction*2.0,Vector2(base)-normal*1.5]),STEEL)
	_draw_segment(img,base,blade_tip-Vector2i(roundi(direction.x*3.0),roundi(direction.y*3.0)),1,STEEL_LIT)
	_pixel(img,grip.x-roundi(direction.x*2.0),grip.y-roundi(direction.y*2.0),GOLD_LIT)


func _draw_mace(img: Image, grip: Vector2i, tip: Vector2i) -> void:
	_draw_segment(img,grip,tip,4,OUTLINE)
	_draw_segment(img,grip,tip,2,IRON_LIT)
	_ellipse(img,tip,5,5,OUTLINE)
	_ellipse(img,tip,3,3,IRON)
	for spike: Vector2i in [Vector2i(-7,0),Vector2i(7,0),Vector2i(0,-7),Vector2i(0,7)]:
		_poly(img,PackedVector2Array([tip+spike,tip+Vector2i(spike.y/3,-spike.x/3),tip-Vector2i(spike.y/3,-spike.x/3)]),STEEL)
	_pixel(img,tip.x-1,tip.y-1,RUST_LIT)


func _draw_spear(img: Image, butt: Vector2i, tip: Vector2i, grip: Vector2i) -> void:
	var direction: Vector2=(Vector2(tip-butt)).normalized()
	var normal: Vector2=Vector2(-direction.y,direction.x)
	var socket: Vector2i=tip-Vector2i(roundi(direction.x*9.0),roundi(direction.y*9.0))
	_draw_segment(img,butt,socket,4,OUTLINE)
	_draw_segment(img,butt,socket,2,WOOD)
	_draw_segment(img,butt+Vector2i(2,0),socket,1,WOOD_LIT)
	_poly(img,PackedVector2Array([Vector2(socket)+normal*3.0,Vector2(tip),Vector2(socket)-normal*3.0,Vector2(socket)-direction*2.0]),OUTLINE)
	_poly(img,PackedVector2Array([Vector2(socket)+normal*1.5,Vector2(tip)-direction*1.5,Vector2(socket)-normal*1.5]),STEEL)
	_draw_segment(img,socket,tip-Vector2i(roundi(direction.x*2.0),roundi(direction.y*2.0)),1,STEEL_LIT)
	_draw_segment(img,grip-Vector2i(roundi(direction.x*3.0),roundi(direction.y*3.0)),grip+Vector2i(roundi(direction.x*3.0),roundi(direction.y*3.0)),3,LEATHER_LIT)
	_pixel(img,butt.x,butt.y,GOLD)


func _draw_crossbow(img: Image, center: Vector2i, direction: int, fired: bool, slack: bool) -> void:
	_poly(img,_pts([center.x-10*direction,center.y+2,center.x+14*direction,center.y-1,center.x+15*direction,center.y+3,center.x-9*direction,center.y+5]),OUTLINE)
	_poly(img,_pts([center.x-8*direction,center.y+2,center.x+12*direction,center.y,center.x+13*direction,center.y+2,center.x-7*direction,center.y+4]),WOOD)
	_pixel(img,center.x+4*direction,center.y+1,WOOD_LIT)
	_draw_segment(img,center+Vector2i(7*direction,0),center+Vector2i(4*direction,-10),3,IRON)
	_draw_segment(img,center+Vector2i(7*direction,0),center+Vector2i(5*direction,10),3,IRON_LIT)
	var string_x: int=center.x+(3 if slack else 7)*direction
	_draw_segment(img,center+Vector2i(4*direction,-10),Vector2i(string_x,center.y),1,STEEL_LIT)
	_draw_segment(img,Vector2i(string_x,center.y),center+Vector2i(5*direction,10),1,STEEL_LIT)
	if not fired:
		_draw_segment(img,center+Vector2i(-2*direction,1),center+Vector2i(19*direction,1),1,STEEL_LIT)
		_poly(img,_pts([center.x+19*direction,center.y-1,center.x+23*direction,center.y+1,center.x+19*direction,center.y+3]),STEEL)


func _draw_kite_shield(img: Image, center: Vector2i, direction: int, half_w: int, half_h: int, alpha: float, broken: bool) -> void:
	var edge: Color=Color(IRON_LIT.r,IRON_LIT.g,IRON_LIT.b,alpha)
	var face: Color=Color(IRON_DARK.r,IRON_DARK.g,IRON_DARK.b,alpha)
	_poly(img,_pts([center.x-half_w,center.y-half_h+4,center.x-half_w+3,center.y-half_h,center.x+half_w-3,center.y-half_h,center.x+half_w,center.y-half_h+4,center.x+half_w-2,center.y+8,center.x,center.y+half_h,center.x-half_w+2,center.y+8]),OUTLINE)
	_poly(img,_pts([center.x-half_w+2,center.y-half_h+5,center.x-half_w+4,center.y-half_h+2,center.x+half_w-4,center.y-half_h+2,center.x+half_w-2,center.y-half_h+5,center.x+half_w-4,center.y+7,center.x,center.y+half_h-3,center.x-half_w+4,center.y+7]),face)
	_draw_segment(img,Vector2i(center.x-half_w+3,center.y-half_h+4),Vector2i(center.x+half_w-3,center.y-half_h+4),2,edge)
	_draw_segment(img,Vector2i(center.x,center.y-half_h+3),Vector2i(center.x,center.y+half_h-4),2,edge)
	_ellipse(img,center,4,4,OUTLINE); _ellipse(img,center,2,2,GOLD)
	# Raven heraldry: wing bars and beak.
	_draw_segment(img,center-Vector2i(2,0),center+Vector2i(-8,-5),2,RUST_LIT)
	_draw_segment(img,center+Vector2i(2,0),center+Vector2i(8,-5),2,RUST_LIT)
	_draw_segment(img,center,center+Vector2i(0,7),2,RUST)
	if broken:
		_draw_segment(img,center-Vector2i(5,9),center+Vector2i(2,1),2,STEEL_LIT)
		_draw_segment(img,center+Vector2i(2,1),center+Vector2i(-3,11),1,RUST_LIT)


func _draw_tower_shield(img: Image, center: Vector2i, alpha: float, broken: bool) -> void:
	var edge: Color=Color(IRON_LIT.r,IRON_LIT.g,IRON_LIT.b,alpha)
	var face: Color=Color(VOID.r,VOID.g,VOID.b,alpha)
	_poly(img,_pts([center.x-20,center.y-33,center.x-15,center.y-39,center.x+15,center.y-39,center.x+20,center.y-33,center.x+18,center.y+25,center.x,center.y+39,center.x-18,center.y+25]),OUTLINE)
	_poly(img,_pts([center.x-17,center.y-32,center.x-13,center.y-36,center.x+13,center.y-36,center.x+17,center.y-32,center.x+15,center.y+23,center.x,center.y+35,center.x-15,center.y+23]),face)
	_draw_segment(img,Vector2i(center.x-14,center.y-32),Vector2i(center.x+14,center.y-32),3,edge)
	_draw_segment(img,Vector2i(center.x-14,center.y-28),Vector2i(center.x-12,center.y+21),2,RUST)
	_draw_segment(img,Vector2i(center.x+14,center.y-28),Vector2i(center.x+12,center.y+21),2,RUST)
	_ellipse(img,center,8,8,OUTLINE); _ellipse(img,center,5,5,GOLD)
	# Large raven crest.
	_draw_segment(img,center,center+Vector2i(-11,-8),3,IRON_LIT)
	_draw_segment(img,center,center+Vector2i(11,-8),3,IRON_LIT)
	_draw_segment(img,center,center+Vector2i(0,13),3,IRON)
	for rivet: Vector2i in [Vector2i(-14,-30),Vector2i(14,-30),Vector2i(-13,20),Vector2i(13,20)]: _ellipse(img,center+rivet,1,1,GOLD_LIT)
	if broken:
		_draw_segment(img,center-Vector2i(8,20),center+Vector2i(4,-1),3,STEEL_LIT)
		_draw_segment(img,center+Vector2i(4,-1),center+Vector2i(-5,25),2,CURSE_RED)


func _draw_boss_sword(img: Image, grip: Vector2i, tip: Vector2i) -> void:
	var direction: Vector2=(Vector2(tip-grip)).normalized()
	var normal: Vector2=Vector2(-direction.y,direction.x)
	var guard: Vector2=Vector2(grip)+direction*7.0
	var base: Vector2=Vector2(grip)+direction*13.0
	_draw_segment(img,grip,Vector2i(guard),7,OUTLINE)
	_draw_segment(img,grip,Vector2i(guard),4,LEATHER_LIT)
	_draw_segment(img,Vector2i(guard+normal*11.0),Vector2i(guard-normal*11.0),5,OUTLINE)
	_draw_segment(img,Vector2i(guard+normal*9.0),Vector2i(guard-normal*9.0),3,GOLD)
	_poly(img,PackedVector2Array([base+normal*5.0,Vector2(tip),base-normal*5.0]),OUTLINE)
	_poly(img,PackedVector2Array([base+normal*3.0,Vector2(tip)-direction*3.0,base-normal*3.0]),IRON_LIT)
	_draw_segment(img,Vector2i(base),tip-Vector2i(roundi(direction.x*4.0),roundi(direction.y*4.0)),2,STEEL_LIT)
	# Chipped edges and curse vein.
	var middle: Vector2i=Vector2i((base+Vector2(tip))*0.5)
	_draw_segment(img,middle-Vector2i(roundi(normal.x*2.0),roundi(normal.y*2.0)),middle+Vector2i(roundi(direction.x*8.0),roundi(direction.y*8.0)),1,CURSE_RED)


# -- FX and production references ------------------------------------------

func _write_shield_effects() -> void:
	var fx_root: String=ROOT+"/enemies/cursed_shield_guard/effects"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(fx_root))
	var marker: Image=Image.create(20,20,false,Image.FORMAT_RGBA8); marker.fill(CLEAR)
	_poly(marker,PackedVector2Array([Vector2(3,3),Vector2(16,3),Vector2(15,12),Vector2(10,17),Vector2(4,12)]),OUTLINE)
	_poly(marker,PackedVector2Array([Vector2(5,5),Vector2(14,5),Vector2(13,11),Vector2(10,14),Vector2(6,11)]),IRON_LIT)
	_draw_segment(marker,Vector2i(6,5),Vector2i(11,10),2,STEEL_LIT)
	_draw_segment(marker,Vector2i(11,10),Vector2i(8,15),2,CURSE_LIT)
	marker.save_png(ProjectSettings.globalize_path(fx_root+"/broken_shield_marker.png"))
	for frame: int in range(4):
		var image: Image=Image.create(64,64,false,Image.FORMAT_RGBA8); image.fill(CLEAR)
		_draw_shield_fragments(image,Vector2i(28,31),frame)
		image.save_png(ProjectSettings.globalize_path("%s/shield_break_fx_%02d.png" % [fx_root,frame+1]))
	for frame: int in range(3):
		var hit: Image=Image.create(64,64,false,Image.FORMAT_RGBA8); hit.fill(CLEAR)
		_draw_impact(hit,Vector2i(21,31),frame)
		hit.save_png(ProjectSettings.globalize_path("%s/shield_hit_fx_%02d.png" % [fx_root,frame+1]))
	for state: String in ["intact","cracked","critical"]:
		var shield: Image=Image.create(64,64,false,Image.FORMAT_RGBA8); shield.fill(CLEAR)
		_draw_kite_shield(shield,Vector2i(23,33),1,14,26,1.0,state!="intact")
		if state=="critical": _draw_segment(shield,Vector2i(16,17),Vector2i(28,49),2,CURSE_RED)
		shield.save_png(ProjectSettings.globalize_path("%s/shield_%s.png" % [fx_root,state]))
	for frame: int in range(4):
		var breaking: Image=Image.create(64,64,false,Image.FORMAT_RGBA8); breaking.fill(CLEAR)
		if frame<3:
			_draw_kite_shield(breaking,Vector2i(23-frame*3,33-frame*2),1,14,26,1.0,true)
		_draw_shield_fragments(breaking,Vector2i(25,31),frame)
		breaking.save_png(ProjectSettings.globalize_path("%s/shield_break_%02d.png" % [fx_root,frame+1]))


func _write_boss_shield_overlays() -> void:
	var fx_root: String=ROOT+"/boss/fallen_gate_knight/effects"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(fx_root))
	for state: String in ["intact","damaged","critical","broken"]:
		var overlay: Image=Image.create(96,96,false,Image.FORMAT_RGBA8); overlay.fill(CLEAR)
		if state!="intact":
			var cracks: int=2 if state=="damaged" else 5 if state=="critical" else 8
			for crack: int in range(cracks):
				var start: Vector2i=Vector2i(19+(crack*7)%25,26+(crack*11)%40)
				_draw_segment(overlay,start,start+Vector2i(5+(crack%3)*2,7+(crack%2)*4),2,CURSE_LIT if state=="critical" else STEEL_LIT)
		overlay.save_png(ProjectSettings.globalize_path("%s/shield_%s_overlay.png" % [fx_root,state]))


func _write_role_references(role: String, legacy_size: int, size: int) -> void:
	var base: String=ROOT+("/boss/" if role=="fallen_gate_knight" else "/enemies/")+role
	var concept_root: String=base+"/concept_art"
	var effect_root: String=base+"/effects"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(concept_root))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(effect_root))
	var idle_name: String="idle_shielded" if role=="fallen_gate_knight" else "hover" if role=="gargoyle_sentinel" else "idle"
	var action_name: String=_representative_action(role)
	var idle_count: int=int((ANIMATIONS[role] as Dictionary)[idle_name])
	var action_count: int=int((ANIMATIONS[role] as Dictionary)[action_name])
	var action_frame: int=maxi(0,action_count/2)
	var action_reference: Image=Image.create(size*3,size,false,Image.FORMAT_RGBA8); action_reference.fill(CLEAR)
	action_reference.blit_rect(_draw_frame(role,idle_name,0,idle_count,legacy_size,size),Rect2i(0,0,size,size),Vector2i(0,0))
	action_reference.blit_rect(_draw_frame(role,action_name,action_frame,action_count,legacy_size,size),Rect2i(0,0,size,size),Vector2i(size,0))
	var hurt_name: String="hurt_shielded" if role=="fallen_gate_knight" else "hurt"
	var hurt_count: int=int((ANIMATIONS[role] as Dictionary)[hurt_name])
	action_reference.blit_rect(_draw_frame(role,hurt_name,0,hurt_count,legacy_size,size),Rect2i(0,0,size,size),Vector2i(size*2,0))
	action_reference.save_png(ProjectSettings.globalize_path("%s/%s_action_reference.png" % [concept_root,role]))
	var silhouette: Image=Image.create(256,256,false,Image.FORMAT_RGBA8); silhouette.fill(CLEAR)
	var idle: Image=_draw_frame(role,idle_name,0,idle_count,legacy_size,size)
	var black: Image=idle.duplicate()
	for py: int in range(size):
		for px: int in range(size):
			if black.get_pixel(px,py).a>0.05: black.set_pixel(px,py,Color.BLACK)
	black.resize(size*3,size*3,Image.INTERPOLATE_NEAREST)
	silhouette.blit_rect(black,Rect2i(0,0,black.get_width(),black.get_height()),Vector2i((256-black.get_width())/2,(256-black.get_height())/2))
	silhouette.save_png(ProjectSettings.globalize_path("%s/%s_silhouette.png" % [concept_root,role]))
	var effect: Image=Image.create(144 if role!="fallen_gate_knight" else 216,72 if role!="fallen_gate_knight" else 108,false,Image.FORMAT_RGBA8); effect.fill(CLEAR)
	match role:
		"castle_guard": _draw_impact(effect,Vector2i(45,28),1)
		"cursed_shield_guard": _draw_shield_fragments(effect,Vector2i(46,27),3)
		"decayed_spearman": _draw_segment(effect,Vector2i(12,27),Vector2i(85,21),2,STEEL_LIT)
		"fallen_crossbowman": _draw_crossbow(effect,Vector2i(44,23),1,false,false)
		"gargoyle_sentinel": _draw_death_fragments(effect,4,STONE_LIT,MOON_BLUE,effect.get_width())
		"fallen_gate_knight": _draw_shockwave(effect,Vector2i(52,58),1)
	effect.save_png(ProjectSettings.globalize_path("%s/%s_effect_reference.png" % [effect_root,role]))


func _representative_action(role: String) -> String:
	match role:
		"castle_guard": return "attack"
		"cursed_shield_guard": return "guard_break"
		"decayed_spearman": return "attack_thrust"
		"fallen_crossbowman": return "shoot"
		"gargoyle_sentinel": return "dive"
		_: return "shield_break"


func _draw_shield_fragments(img: Image, center: Vector2i, frame: int) -> void:
	for shard: int in range(3+frame*4):
		var p: Vector2i=center+Vector2i(-10+(shard*9+frame*3)%28,-12+(shard*7+frame*5)%30)
		_poly(img,_pts([p.x-2,p.y+2,p.x,p.y-3,p.x+3,p.y,p.x+1,p.y+3]),IRON_LIT if shard%3 else GOLD)


func _draw_boss_shield_fragments(img: Image, center: Vector2i, frame: int) -> void:
	for shard: int in range(5+frame*5):
		var p: Vector2i=center+Vector2i(-22+(shard*13+frame*7)%52,-25+(shard*11+frame*4)%58)
		_poly(img,_pts([p.x-3,p.y+3,p.x,p.y-5,p.x+5,p.y,p.x+1,p.y+5]),IRON_LIT if shard%4 else CURSE_RED)


func _draw_shockwave(img: Image, center: Vector2i, frame: int) -> void:
	for band: int in range(3):
		var width: int=12+band*14+frame*7
		_draw_segment(img,center-Vector2i(width,0),center-Vector2i(width/2,8+band*3),2,CURSE_RED if band%2 else RUST_LIT)
		_draw_segment(img,center+Vector2i(width/2,-8-band*3),center+Vector2i(width,0),2,CURSE_LIT)


func _draw_impact(img: Image, center: Vector2i, frame: int) -> void:
	var reach: int=7+frame*3
	for ray: Vector2i in [Vector2i(-reach,-2),Vector2i(-5,-reach),Vector2i(reach,-5),Vector2i(reach,4)]:
		_draw_segment(img,center,center+ray,2,STEEL_LIT if ray.x<0 else GOLD_LIT)


func _draw_death_fragments(img: Image, frame: int, primary: Color, accent: Color, width: int) -> void:
	for particle: int in range(frame*4):
		var p: Vector2i=Vector2i(8+(particle*13+frame*5)%(width-16),12+(particle*9+frame*4)%maxi(20,width-22))
		_poly(img,_pts([p.x,p.y-2,p.x+3,p.y,p.x+1,p.y+3,p.x-2,p.y+1]),accent if particle%4==0 else primary)


func _draw_gauntlet(img: Image, center: Vector2i) -> void:
	_ellipse(img,center,3,3,OUTLINE); _ellipse(img,center,2,2,IRON_LIT)
	_pixel(img,center.x+1,center.y-1,STEEL)


func _draw_gauntlet_large(img: Image, center: Vector2i) -> void:
	_ellipse(img,center,5,5,OUTLINE); _ellipse(img,center,3,3,IRON_LIT)
	_draw_segment(img,center-Vector2i(2,1),center+Vector2i(3,1),1,STEEL)


func _draw_monster_claw(img: Image, center: Vector2i, direction: int) -> void:
	_ellipse(img,center,3,3,OUTLINE); _ellipse(img,center,2,2,STONE_LIT)
	for finger: int in range(3): _draw_segment(img,center,center+Vector2i(direction*(5+finger),-3+finger*3),1,STEEL)


# -- Pixel primitives -------------------------------------------------------

func _pts(values: Array[int]) -> PackedVector2Array:
	var result: PackedVector2Array=PackedVector2Array()
	for index: int in range(0,values.size(),2): result.append(Vector2(values[index],values[index+1]))
	return result


func _poly(img: Image, points: PackedVector2Array, color: Color) -> void:
	if points.size()<3: return
	var min_x: int=img.get_width()-1; var max_x: int=0
	var min_y: int=img.get_height()-1; var max_y: int=0
	for point: Vector2 in points:
		min_x=mini(min_x,floori(point.x)); max_x=maxi(max_x,ceili(point.x))
		min_y=mini(min_y,floori(point.y)); max_y=maxi(max_y,ceili(point.y))
	min_x=clampi(min_x,0,img.get_width()-1); max_x=clampi(max_x,0,img.get_width()-1)
	min_y=clampi(min_y,0,img.get_height()-1); max_y=clampi(max_y,0,img.get_height()-1)
	for py: int in range(min_y,max_y+1):
		for px: int in range(min_x,max_x+1):
			if Geometry2D.is_point_in_polygon(Vector2(px+0.5,py+0.5),points): img.set_pixel(px,py,color)


func _ellipse(img: Image, center: Vector2i, radius_x: int, radius_y: int, color: Color) -> void:
	for py: int in range(center.y-radius_y,center.y+radius_y+1):
		for px: int in range(center.x-radius_x,center.x+radius_x+1):
			if radius_x<=0 or radius_y<=0: continue
			var dx: float=float(px-center.x)/float(radius_x); var dy: float=float(py-center.y)/float(radius_y)
			if dx*dx+dy*dy<=1.0: _pixel(img,px,py,color)


func _draw_segment(img: Image, start: Vector2i, finish: Vector2i, thickness: int, color: Color) -> void:
	var steps: int=maxi(abs(finish.x-start.x),abs(finish.y-start.y))
	for index: int in range(steps+1):
		var ratio: float=float(index)/float(maxi(1,steps))
		var p: Vector2i=Vector2i(roundi(lerpf(start.x,finish.x,ratio)),roundi(lerpf(start.y,finish.y,ratio)))
		_ellipse(img,p,maxi(1,thickness/2),maxi(1,thickness/2),color)


func _pixel(img: Image, x: int, y: int, color: Color) -> void:
	if x>=0 and x<img.get_width() and y>=0 and y<img.get_height(): img.set_pixel(x,y,color)
