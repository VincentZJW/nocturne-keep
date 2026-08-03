extends SceneTree

## Chapter II Stage 1 formal enemy-art generator.
##
## Every runtime frame is delivered on a native 128x128 production canvas.  The
## approved 64x64 motion silhouettes remain centered for compatibility, while a
## role-specific replication pass restores the concept-art identity at runtime.

const ROOT: String = "res://chapters/chapter_02_silent_court/assets/enemies"
const FRAME_SIZE: int = 128
const LEGACY_SIZE: int = 64
const ART_OFFSET: Vector2i = Vector2i(32, 32)
const CLEAR: Color = Color(0.0, 0.0, 0.0, 0.0)
const VOID: Color = Color("090b12")
const OUTLINE: Color = Color("11141d")
const DEEP: Color = Color("1b1d29")
const CLOTH: Color = Color("28283a")
const CLOTH_LIT: Color = Color("48485d")
const WINE: Color = Color("672d42")
const WINE_LIT: Color = Color("98435a")
const IRON: Color = Color("414956")
const STEEL: Color = Color("758493")
const STEEL_LIT: Color = Color("bcc8cf")
const IVORY: Color = Color("d5cbbc")
const IVORY_SHADOW: Color = Color("9f9588")
const GOLD: Color = Color("8d6b3d")
const GOLD_LIT: Color = Color("c49a58")
const VIOLET: Color = Color("66557f")
const VIOLET_LIT: Color = Color("9a82ad")
const SOUL: Color = Color("70a8bd")
const SOUL_LIT: Color = Color("b7e2e5")
const WAX: Color = Color("8a283b")
const EMBER: Color = Color("d47c56")
const ASH: Color = Color(0.46, 0.39, 0.52, 0.72)

const ROLES: Array[String] = [
	"hollow_retainer", "court_halberdier", "mourning_armor",
	"blood_candle_acolyte", "hanging_stalker",
]

const ANIMATIONS: Dictionary = {
	"hollow_retainer": {
		"idle": 4, "bow_or_service_idle": 4, "patrol": 6, "walk": 6,
		"alert": 3, "approach": 6, "retreat": 4, "turn": 3,
		"stab_windup": 4, "stab_active": 2, "stab_recovery": 4,
		"combo_hit_01": 3, "combo_hit_02": 3, "combo_recovery": 4,
		"attack_single_stab": 5, "attack_combo": 6,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 7,
	},
	"court_halberdier": {
		"idle": 4, "idle_guard": 4, "patrol": 6, "walk": 6,
		"alert": 3, "approach": 6, "turn": 3,
		"long_thrust_windup": 5, "long_thrust_active": 2, "long_thrust_recovery": 5,
		"halberd_sweep_windup": 5, "halberd_sweep_active": 2, "halberd_sweep_recovery": 5,
		"shaft_push": 4, "attack_thrust": 5, "attack_sweep": 6, "attack_shaft_push": 4,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 7,
	},
	"mourning_armor": {
		"dormant": 4, "idle": 4, "heavy_walk": 6, "walk": 6,
		"alert": 3, "turn": 3,
		"overhead_windup": 6, "overhead_active": 2, "overhead_recovery": 5,
		"shoulder_charge": 5, "armor_sweep": 6,
		"attack_overhead": 6, "attack_shoulder_bash": 5, "attack_heavy_sweep": 6,
		"poise_hit": 2, "light_hit": 2, "stagger": 4, "hurt": 3,
		"death_collapse": 7, "hollow_armor_break": 7, "death": 6,
	},
	"blood_candle_acolyte": {
		"prayer_idle": 4, "idle": 4, "walk_or_reposition": 6, "walk": 6,
		"alert": 3, "turn": 3,
		"projectile_cast_windup": 5, "projectile_cast_active": 2, "projectile_cast_recovery": 5,
		"ember_cast": 5, "ally_buff_start": 4, "ally_buff_loop": 4, "ally_buff_end": 4,
		"attack_cast": 6, "buff_channel": 4,
		"light_hit": 2, "stagger": 4, "hurt": 3,
		"candle_extinguish": 5, "death": 7,
	},
	"hanging_stalker": {
		"ceiling_hidden": 4, "ceiling_idle": 4, "ceiling_track": 4,
		"hang": 4, "telegraph": 4, "detach": 3, "drop_attack": 4, "drop": 4,
		"land": 3, "ground_recovery": 3, "emerging_claw": 5, "claw": 5,
		"short_chase": 6, "retreat_or_reclimb": 4, "retreat": 4,
		"return_to_anchor": 4, "turn": 3,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death_fall": 6,
		"death_ground": 6, "death": 6,
	},
}


func _initialize() -> void:
	var written: int = 0
	for role: String in ROLES:
		var definitions: Dictionary = ANIMATIONS[role] as Dictionary
		for animation: String in definitions:
			var count: int = int(definitions[animation])
			var directory: String = "%s/%s/sprites/%s" % [ROOT, role, animation]
			if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
				push_error("Cannot create formal art directory: %s" % directory)
				quit(1)
				return
			for frame: int in range(count):
				var image: Image = _draw_frame(role, animation, frame, count)
				var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
				if image.save_png(ProjectSettings.globalize_path(path)) != OK:
					push_error("Cannot save formal enemy frame: %s" % path)
					quit(1)
					return
				written += 1
		_write_preview(role)
	print("CH2 ENEMY ART V2 | PASS roles=%d frames=%d" % [ROLES.size(), written])
	quit(0)


func _draw_frame(role: String, animation: String, frame: int, count: int) -> Image:
	var legacy: Image = Image.create(LEGACY_SIZE, LEGACY_SIZE, false, Image.FORMAT_RGBA8)
	legacy.fill(CLEAR)
	var phase: float = float(frame) / float(maxi(1, count - 1))
	var stage: String = _stage(animation, phase)
	match role:
		"hollow_retainer": _draw_retainer(legacy, animation, stage, frame, phase)
		"court_halberdier": _draw_halberdier(legacy, animation, stage, frame, phase)
		"mourning_armor": _draw_mourning_armor(legacy, animation, stage, frame, phase)
		"blood_candle_acolyte": _draw_acolyte(legacy, animation, stage, frame, phase)
		"hanging_stalker": _draw_stalker(legacy, animation, stage, frame, phase)
	var image: Image = Image.create(FRAME_SIZE, FRAME_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	image.blit_rect(legacy, Rect2i(Vector2i.ZERO, legacy.get_size()), ART_OFFSET)
	_draw_replication_details(image, role, animation, stage, frame)
	return image


func _draw_replication_details(image: Image, role: String, animation: String, stage: String, frame: int) -> void:
	if stage == "death" and frame >= 4:
		return
	var o: Vector2i = ART_OFFSET
	match role:
		"hollow_retainer":
			# Porcelain half-mask seam, chamberlain chain and wine-red service sash.
			_segment(image, o + Vector2i(24, 15), o + Vector2i(34, 15), 1, IVORY)
			_segment(image, o + Vector2i(29, 16), o + Vector2i(29, 23), 1, IVORY_SHADOW)
			for link: int in range(5):
				_pixel(image, o.x + 23 + link * 3, o.y + 31 + (link % 2), GOLD_LIT)
			_segment(image, o + Vector2i(21, 34), o + Vector2i(35, 43), 2, WINE_LIT)
		"court_halberdier":
			# Tall court crest, layered gorget and oath pennon distinguish the reach unit.
			_poly(image, _pts([o.x+25,o.y+7, o.x+30,o.y+1, o.x+35,o.y+7, o.x+32,o.y+13, o.x+27,o.y+13]), IRON)
			_segment(image, o + Vector2i(21, 23), o + Vector2i(39, 23), 2, STEEL)
			_poly(image, _pts([o.x+47,o.y+12, o.x+59,o.y+17, o.x+49,o.y+24]), WINE)
			_pixel(image, o.x + 30, o.y + 11, SOUL_LIT)
		"mourning_armor":
			# Empty visor glow, funeral ribbons and layered plate rivets.
			_segment(image, o + Vector2i(23, 18), o + Vector2i(38, 18), 2, OUTLINE)
			_segment(image, o + Vector2i(26, 18), o + Vector2i(35, 18), 1, SOUL_LIT)
			for rivet: int in range(4):
				_pixel(image, o.x + 22 + rivet * 6, o.y + 31, STEEL_LIT)
			_segment(image, o + Vector2i(19, 35), o + Vector2i(15, 53), 2, WINE)
			_segment(image, o + Vector2i(41, 35), o + Vector2i(45, 52), 2, WINE)
		"blood_candle_acolyte":
			# Wax crown, prayer stole and a readable blood-candle drip pattern.
			for wick: int in range(3):
				_rect(image, o.x + 24 + wick * 5, o.y + 5 - (wick % 2) * 2, 2, 7, WAX)
				_pixel(image, o.x + 25 + wick * 5, o.y + 3 - (wick % 2) * 2, EMBER)
			_segment(image, o + Vector2i(27, 27), o + Vector2i(24, 48), 2, GOLD)
			_segment(image, o + Vector2i(33, 27), o + Vector2i(36, 48), 2, GOLD)
		"hanging_stalker":
			# Hook silhouette, exposed ribs and curse seam remain legible upside-down.
			for rib: int in range(4):
				_segment(image, o + Vector2i(25, 25 + rib * 4), o + Vector2i(37, 25 + rib * 4), 1, IVORY_SHADOW)
			_segment(image, o + Vector2i(18, 23), o + Vector2i(12, 13), 2, STEEL)
			_segment(image, o + Vector2i(42, 23), o + Vector2i(49, 13), 2, STEEL)
			_pixel(image, o.x + 30, o.y + 16, SOUL_LIT)


func _stage(animation: String, phase: float) -> String:
	if animation.contains("death") or animation in ["hollow_armor_break", "candle_extinguish"]: return "death"
	if animation.contains("windup") or animation in ["ally_buff_start"]: return "windup"
	if animation.contains("active") or animation in ["combo_hit_01", "combo_hit_02", "shaft_push", "shoulder_charge", "armor_sweep", "ember_cast", "ally_buff_loop", "emerging_claw", "drop_attack"]: return "active"
	if animation.contains("recovery") or animation in ["ally_buff_end", "land"]: return "recovery"
	if animation in ["light_hit", "poise_hit", "stagger", "hurt"]: return "hurt"
	if animation.begins_with("attack_") or animation in ["claw", "buff_channel"]:
		if phase < 0.36: return "windup"
		if phase < 0.74: return "active"
		return "recovery"
	return "base"


func _draw_retainer(img: Image, animation: String, stage: String, frame: int, phase: float) -> void:
	if stage == "death":
		_draw_falling_death(img, frame, 7, WINE, true)
		return
	var gait: bool = animation in ["patrol", "walk", "approach", "retreat"]
	var stride: int = [-3, -1, 2, 3, 1, -2][frame % 6] if gait else 0
	var bob: int = [0, -1, 0, 0, -1, 0][frame % 6] if gait else [0, -1, -1, 0][frame % 4]
	var lean: int = -3 if stage == "windup" else 3 if stage == "active" else -4 if stage == "hurt" else 0
	var x: int = 27 + lean
	var y: int = 8 + bob
	# Narrow boots and separated legs beneath split court tails.
	_segment(img, Vector2i(x - 4, y + 38), Vector2i(x - 5 - stride, 58), 5, OUTLINE)
	_segment(img, Vector2i(x + 4, y + 38), Vector2i(x + 5 + stride, 58), 5, OUTLINE)
	_segment(img, Vector2i(x - 4, y + 39), Vector2i(x - 5 - stride, 57), 3, STEEL)
	_segment(img, Vector2i(x + 4, y + 39), Vector2i(x + 5 + stride, 57), 3, IRON)
	_poly(img, _pts([x-10,y+19, x+9,y+18, x+11,y+39, x+7,y+50, x+2,y+44, x-2,y+51, x-7,y+45, x-11,y+49]), OUTLINE)
	_poly(img, _pts([x-8,y+20, x+7,y+20, x+8,y+37, x+5,y+47, x+1,y+41, x-2,y+48, x-5,y+42, x-8,y+46]), CLOTH)
	_poly(img, _pts([x-1,y+21, x+4,y+20, x+4,y+40, x+1,y+43, x-2,y+39, x-2,y+25]), WINE)
	# High servant collar, porcelain half-mask and silver mourning chain.
	_poly(img, _pts([x-11,y+20, x-7,y+15, x-2,y+18, x+7,y+15, x+11,y+20, x+7,y+23, x-7,y+23]), OUTLINE)
	_poly(img, _pts([x-9,y+19, x-6,y+17, x-1,y+20, x+6,y+17, x+9,y+20, x+6,y+21, x-6,y+21]), CLOTH_LIT)
	_poly(img, _pts([x-7,y+2, x-3,y, x+5,y+2, x+7,y+8, x+4,y+16, x-2,y+18, x-7,y+14, x-9,y+7]), OUTLINE)
	_poly(img, _pts([x-5,y+3, x-2,y+2, x+4,y+3, x+5,y+8, x+2,y+14, x-2,y+15, x-5,y+12, x-7,y+7]), IVORY_SHADOW)
	_rect(img, x-4, y+5, 8, 2, IVORY)
	_pixel(img, x+3, y+7, SOUL_LIT)
	_poly(img, _pts([x-6,y+15, x+5,y+14, x+7,y+20, x-7,y+21]), WINE)
	for link: int in range(4): _pixel(img, x - 4 + link * 3, y + 24 + link % 2, GOLD_LIT)
	# Back arm carries coat-tail balance; front arm controls a complete smallsword.
	var hand: Vector2i = Vector2i(x + 12, y + 27)
	var sword_tip: Vector2i = Vector2i(x + 27, y + 33)
	if stage == "windup":
		hand = Vector2i(x + 6, y + 28)
		sword_tip = Vector2i(x - 10, y + 22)
	elif stage == "active":
		hand = Vector2i(x + 16, y + 24)
		sword_tip = Vector2i(62, y + 22 + (2 if animation.contains("02") else 0))
	elif stage == "recovery": sword_tip = Vector2i(x + 24, y + 37)
	_segment(img, Vector2i(x-7,y+23), Vector2i(x-13,y+31), 5, OUTLINE)
	_segment(img, Vector2i(x-7,y+23), Vector2i(x-13,y+31), 3, CLOTH_LIT)
	_segment(img, Vector2i(x+7,y+22), hand, 5, OUTLINE)
	_segment(img, Vector2i(x+7,y+22), hand, 3, WINE_LIT)
	_draw_hand(img, hand)
	_draw_smallsword(img, hand, sword_tip)
	if animation == "bow_or_service_idle":
		_poly(img, _pts([x-11,y+19, x-17,y+23+frame%2, x-11,y+28]), WINE_LIT)


func _draw_halberdier(img: Image, animation: String, stage: String, frame: int, phase: float) -> void:
	if stage == "death":
		_draw_falling_death(img, frame, 7, IRON, false)
		# The ceremonial halberd loses support beside the body.
		_draw_halberd(img, Vector2i(13, 57), Vector2i(58, 57), true)
		return
	var gait: bool = animation in ["patrol", "walk", "approach"]
	var stride: int = [-3,-1,2,3,1,-2][frame % 6] if gait else 0
	var bob: int = [0,-1,0,0,-1,0][frame % 6] if gait else 0
	var lean: int = -2 if stage == "windup" else 3 if stage == "active" else -4 if stage == "hurt" else 0
	var x: int = 28 + lean
	var y: int = 6 + bob
	_segment(img, Vector2i(x-6,y+40), Vector2i(x-7-stride,58), 7, OUTLINE)
	_segment(img, Vector2i(x+6,y+40), Vector2i(x+7+stride,58), 7, OUTLINE)
	_segment(img, Vector2i(x-6,y+41), Vector2i(x-7-stride,57), 4, STEEL)
	_segment(img, Vector2i(x+6,y+41), Vector2i(x+7+stride,57), 4, IRON)
	_poly(img, _pts([x-10,y+20,x+10,y+20,x+12,y+43,x+7,y+49,x-7,y+49,x-12,y+42]), OUTLINE)
	_poly(img, _pts([x-8,y+21,x+8,y+21,x+9,y+40,x+5,y+46,x-5,y+46,x-9,y+40]), IRON)
	_poly(img, _pts([x-4,y+23,x+5,y+22,x+6,y+42,x,y+46,x-5,y+42]), WINE)
	# Mantle and high-crested closed helm establish court rank.
	_poly(img, _pts([x-15,y+22,x-11,y+15,x-4,y+18,x+8,y+15,x+15,y+22,x+9,y+26,x-10,y+26]), OUTLINE)
	_poly(img, _pts([x-13,y+21,x-9,y+17,x-4,y+21,x+7,y+17,x+13,y+21,x+8,y+23,x-9,y+23]), WINE_LIT)
	_poly(img, _pts([x-7,y+2,x-3,y-1,x+4,y+1,x+8,y+7,x+6,y+18,x-6,y+19,x-9,y+8]), OUTLINE)
	_poly(img, _pts([x-5,y+3,x-2,y+1,x+3,y+3,x+6,y+7,x+4,y+16,x-4,y+17,x-6,y+7]), STEEL)
	_poly(img, _pts([x-2,y+1,x,y-4,x+2,y+1]), GOLD_LIT)
	_rect(img, x-4, y+8, 9, 3, VOID)
	_rect(img, x+1, y+9, 3, 1, SOUL_LIT)
	for rivet: int in range(3): _pixel(img, x-4+rivet*4, y+28, GOLD_LIT)
	var rear: Vector2i = Vector2i(x-13,y+10)
	var head: Vector2i = Vector2i(x+27,y+43)
	if animation.contains("thrust"):
		if stage == "windup":
			rear = Vector2i(x-22,y+26)
			head = Vector2i(x+20,y+25)
		elif stage == "active":
			rear = Vector2i(x-15,y+27)
			head = Vector2i(63,y+25)
		else:
			rear = Vector2i(x-17,y+18)
			head = Vector2i(x+30,y+31)
	elif animation.contains("sweep"):
		rear = Vector2i(x-15,y+15)
		head = Vector2i(58, y + 5 + roundi(phase*40.0))
	elif animation.contains("shaft_push") or animation == "shaft_push":
		rear = Vector2i(x-13,y+27)
		head = Vector2i(57,y+27)
	_draw_halberd(img, rear, head, true)
	var hand: Vector2i = Vector2i(x+10,y+27)
	_segment(img, Vector2i(x+7,y+23), hand, 6, OUTLINE)
	_segment(img, Vector2i(x+7,y+23), hand, 3, STEEL)
	_draw_hand(img, hand)


func _draw_mourning_armor(img: Image, animation: String, stage: String, frame: int, phase: float) -> void:
	if stage == "death":
		_draw_armor_collapse(img, frame)
		return
	var gait: bool = animation in ["heavy_walk", "walk"]
	var stride: int = [-3,-1,1,3,1,-1][frame % 6] if gait else 0
	var bob: int = [0,-1,0,0,-1,0][frame % 6] if gait else 0
	var x: int = 29 + (4 if stage == "active" else -3 if stage in ["windup","hurt"] else 0)
	var y: int = 6 + bob
	_segment(img, Vector2i(x-8,y+39), Vector2i(x-9-stride,58), 9, OUTLINE)
	_segment(img, Vector2i(x+8,y+39), Vector2i(x+9+stride,58), 9, OUTLINE)
	_segment(img, Vector2i(x-8,y+40), Vector2i(x-9-stride,57), 6, IRON)
	_segment(img, Vector2i(x+8,y+40), Vector2i(x+9+stride,57), 6, STEEL)
	# Empty waist and skirt plates allow visible mist between armor segments.
	_poly(img, _pts([x-11,y+23,x+11,y+23,x+13,y+42,x+8,y+49,x-8,y+49,x-13,y+42]), OUTLINE)
	_poly(img, _pts([x-9,y+24,x+9,y+24,x+10,y+39,x+6,y+46,x-6,y+46,x-10,y+39]), IRON)
	_rect(img, x-5, y+31, 11, 4, VOID)
	_rect(img, x-3, y+32, 7, 2, VIOLET)
	# Huge layered funerary shoulders are the primary silhouette.
	_poly(img, _pts([x-19,y+20,x-15,y+11,x-7,y+13,x-4,y+22]), OUTLINE)
	_poly(img, _pts([x+19,y+20,x+15,y+11,x+7,y+13,x+4,y+22]), OUTLINE)
	_poly(img, _pts([x-17,y+19,x-14,y+13,x-8,y+15,x-6,y+21]), STEEL)
	_poly(img, _pts([x+17,y+19,x+14,y+13,x+8,y+15,x+6,y+21]), IRON)
	_segment(img, Vector2i(x-13,y+20), Vector2i(x-17,y+35), 9, OUTLINE)
	_segment(img, Vector2i(x+13,y+20), Vector2i(x+17,y+35), 9, OUTLINE)
	_segment(img, Vector2i(x-13,y+20), Vector2i(x-17,y+35), 5, IRON)
	_segment(img, Vector2i(x+13,y+20), Vector2i(x+17,y+35), 5, STEEL)
	# Hollow crown helm and funeral veil.
	_poly(img, _pts([x-8,y+2,x-4,y-1,x+5,y+1,x+9,y+8,x+7,y+20,x-7,y+20,x-10,y+8]), OUTLINE)
	_poly(img, _pts([x-6,y+3,x-3,y+1,x+4,y+3,x+7,y+8,x+5,y+17,x-5,y+17,x-7,y+8]), IRON)
	for tine: int in range(4):
		_poly(img, _pts([x-6+tine*4,y+3, x-5+tine*4,y-3-(tine%2)*2, x-3+tine*4,y+3]), GOLD)
	_rect(img, x-5, y+8, 11, 5, VOID)
	_rect(img, x-2, y+10, 5, 1, SOUL_LIT)
	_poly(img, _pts([x-8,y+16,x-15,y+23,x-13,y+48,x-8,y+43,x-6,y+19]), CLOTH)
	_poly(img, _pts([x+7,y+17,x+13,y+25,x+11,y+44,x+7,y+40]), CLOTH)
	# Weaponless empty armor attacks with articulated gauntlets/pauldrons.
	if animation.contains("overhead"):
		var fist: Vector2i = Vector2i(x+13-roundi(phase*2.0), y+30-roundi(phase*35.0)) if stage == "windup" else Vector2i(x+25,y+49) if stage == "active" else Vector2i(x+16,y+33)
		_segment(img, Vector2i(x+12,y+20), fist, 10, OUTLINE)
		_segment(img, Vector2i(x+12,y+20), fist, 6, STEEL)
		_ellipse(img, fist, Vector2i(5,4), STEEL_LIT)
	elif animation.contains("shoulder"):
		_poly(img, _pts([x+10,y+12,x+24,y+15,x+28,y+23,x+12,y+23]), STEEL_LIT)
	elif animation.contains("sweep") or animation == "armor_sweep":
		var sweep_hand: Vector2i = Vector2i(58, y+21+roundi(phase*12.0))
		_segment(img, Vector2i(x+12,y+21), sweep_hand, 11, OUTLINE)
		_segment(img, Vector2i(x+12,y+21), sweep_hand, 7, STEEL)
		_ellipse(img, sweep_hand, Vector2i(5,4), STEEL_LIT)
	for leak: int in range(3): _pixel(img, x-6+leak*7, y+37+leak%2, VIOLET_LIT)


func _draw_acolyte(img: Image, animation: String, stage: String, frame: int, phase: float) -> void:
	if stage == "death":
		_draw_acolyte_death(img, frame)
		return
	var gait: bool = animation in ["walk_or_reposition", "walk"]
	var stride: int = [-2,-1,1,2,1,-1][frame % 6] if gait else 0
	var bob: int = [0,-1,0,0,-1,0][frame % 6] if gait else [0,-1,-1,0][frame%4]
	var x: int = 28 + (2 if stage == "active" else -2 if stage in ["windup","hurt"] else 0)
	var y: int = 7 + bob
	# Split robe and visible shoes/hands avoid a monolithic mage silhouette.
	_segment(img, Vector2i(x-4,y+43), Vector2i(x-5-stride,58), 4, OUTLINE)
	_segment(img, Vector2i(x+4,y+43), Vector2i(x+5+stride,58), 4, OUTLINE)
	_poly(img, _pts([x-9,y+20,x+9,y+20,x+13,y+49,x+6,y+54,x+1,y+48,x-4,y+54,x-12,y+50]), OUTLINE)
	_poly(img, _pts([x-7,y+21,x+7,y+21,x+10,y+47,x+5,y+51,x+1,y+45,x-3,y+51,x-9,y+47]), WINE)
	_poly(img, _pts([x-1,y+21,x+4,y+21,x+5,y+47,x+1,y+45,x-2,y+49,x-3,y+24]), CLOTH)
	for seal: int in range(3):
		_ellipse(img, Vector2i(x-5+seal*5,y+30+seal*6), Vector2i(2,2), WAX)
	# Wax-sealed pale face and narrow ritual hood.
	_poly(img, _pts([x-8,y+3,x-4,y,x+5,y+2,x+8,y+9,x+6,y+20,x-7,y+20,x-10,y+9]), OUTLINE)
	_poly(img, _pts([x-6,y+4,x-3,y+2,x+4,y+4,x+6,y+9,x+4,y+17,x-5,y+17,x-7,y+9]), IVORY)
	_rect(img, x-4,y+8,9,2,IVORY_SHADOW)
	_pixel(img,x+3,y+9,WINE_LIT)
	_ellipse(img,Vector2i(x-3,y+14),Vector2i(2,2),WAX)
	_poly(img, _pts([x-8,y+19,x-4,y+16,x+5,y+17,x+9,y+21,x+5,y+25,x-5,y+25]), CLOTH)
	# Both hands and the blood candle remain readable through every cast.
	var candle_hand: Vector2i = Vector2i(x+13,y+29)
	var free_hand: Vector2i = Vector2i(x-13,y+30)
	if stage == "windup":
		candle_hand = Vector2i(x+12,y+20-roundi(phase*8.0))
		free_hand = Vector2i(x-16,y+22)
	elif stage == "active":
		candle_hand = Vector2i(x+16,y+20)
		free_hand = Vector2i(x+3,y+22)
	_segment(img, Vector2i(x+7,y+23), candle_hand, 5, OUTLINE)
	_segment(img, Vector2i(x+7,y+23), candle_hand, 3, GOLD)
	_segment(img, Vector2i(x-7,y+23), free_hand, 5, OUTLINE)
	_segment(img, Vector2i(x-7,y+23), free_hand, 3, IVORY_SHADOW)
	_draw_hand(img, candle_hand)
	_draw_hand(img, free_hand)
	_draw_blood_candle(img, candle_hand + Vector2i(1,-11), frame, animation)
	if stage == "active":
		for spark: int in range(4):
			_ellipse(img, Vector2i(48+spark*4, y+13+(spark%2)*3), Vector2i(2,2), WAX if spark%2==0 else EMBER)
	if animation.contains("buff"):
		for mote: int in range(5):
			_pixel(img, x-14+mote*7, y+10+(mote+frame)%4*5, GOLD_LIT)


func _draw_stalker(img: Image, animation: String, stage: String, frame: int, phase: float) -> void:
	if stage == "death":
		_draw_stalker_death(img, frame, animation.contains("fall"))
		return
	var hanging: bool = animation in ["ceiling_hidden","ceiling_idle","ceiling_track","hang","telegraph","detach","return_to_anchor"]
	var x: int = 31 + (frame%2)
	var y: int = 8 if hanging else 15 + (roundi(phase*10.0) if animation in ["drop","drop_attack"] else 0)
	if hanging:
		_segment(img, Vector2i(x,0), Vector2i(x,y+1), 3, GOLD)
		_ellipse(img, Vector2i(x,y+1), Vector2i(4,3), IRON)
	# Folded legs/harness above the inverted torso.
	if hanging:
		_segment(img,Vector2i(x-2,y+5),Vector2i(x-9,y+2),6,OUTLINE)
		_segment(img,Vector2i(x+2,y+5),Vector2i(x+9,y+2),6,OUTLINE)
	else:
		_segment(img,Vector2i(x-4,y+34),Vector2i(x-9,y+54),5,OUTLINE)
		_segment(img,Vector2i(x+4,y+34),Vector2i(x+10,y+54),5,OUTLINE)
	_poly(img,_pts([x-7,y+6,x+7,y+6,x+9,y+27,x+4,y+36,x-5,y+35,x-10,y+26]),OUTLINE)
	_poly(img,_pts([x-5,y+8,x+5,y+8,x+6,y+25,x+2,y+32,x-4,y+31,x-7,y+24]),CLOTH)
	_poly(img,_pts([x-4,y+12,x+4,y+11,x+5,y+28,x,y+31,x-5,y+27]),WINE)
	for buckle: int in range(3): _pixel(img,x-4+buckle*4,y+16+buckle*4,GOLD_LIT)
	# Pale human hunting mask, not a beast head.
	_poly(img,_pts([x-6,y+26,x-2,y+23,x+5,y+25,x+7,y+31,x+3,y+38,x-3,y+39,x-7,y+34]),OUTLINE)
	_poly(img,_pts([x-4,y+27,x-1,y+25,x+4,y+27,x+5,y+31,x+2,y+36,x-2,y+37,x-5,y+33]),IVORY_SHADOW)
	_pixel(img,x+3,y+30,SOUL_LIT)
	# Long separately articulated arms terminate in two-prong hooks.
	var left_hand: Vector2i = Vector2i(x-19,y+44)
	var right_hand: Vector2i = Vector2i(x+20,y+43)
	if animation in ["emerging_claw","claw"] and stage == "active": right_hand = Vector2i(62,y+38)
	if animation == "telegraph":
		left_hand.y += frame%2*3
		right_hand.y += frame%2*3
	_segment(img,Vector2i(x-6,y+18),left_hand,5,OUTLINE)
	_segment(img,Vector2i(x+6,y+18),right_hand,5,OUTLINE)
	_segment(img,Vector2i(x-6,y+18),left_hand,3,STEEL)
	_segment(img,Vector2i(x+6,y+18),right_hand,3,IRON)
	_draw_hook_hand(img,left_hand,-1)
	_draw_hook_hand(img,right_hand,1)
	if animation == "telegraph" and frame%2==1:
		for mote: int in range(4): _pixel(img,x-15+mote*10,y+46+(mote%2)*3,SOUL_LIT)


func _draw_smallsword(img: Image, hand: Vector2i, tip: Vector2i) -> void:
	var direction: Vector2 = Vector2(tip-hand).normalized()
	var guard_center: Vector2i = hand + Vector2i(roundi(direction.x*3.0),roundi(direction.y*3.0))
	_segment(img,hand-Vector2i(roundi(direction.x*4.0),roundi(direction.y*4.0)),hand,3,GOLD)
	var normal: Vector2i = Vector2i(-roundi(direction.y*5.0),roundi(direction.x*5.0))
	_segment(img,guard_center-normal,guard_center+normal,3,GOLD_LIT)
	_segment(img,guard_center,tip,3,OUTLINE)
	_segment(img,guard_center,tip,1,STEEL_LIT)
	_ellipse(img,tip,Vector2i(2,2),IVORY)


func _draw_halberd(img: Image, rear: Vector2i, head: Vector2i, ornamented: bool) -> void:
	_segment(img,rear,head,4,OUTLINE)
	_segment(img,rear,head,2,GOLD if ornamented else IRON)
	var direction: Vector2 = Vector2(head-rear).normalized()
	var normal: Vector2 = Vector2(-direction.y,direction.x)
	var base: Vector2 = Vector2(head)-direction*5.0
	var p0: Vector2i = head+Vector2i(roundi(direction.x*7.0),roundi(direction.y*7.0))
	var p1: Vector2i = Vector2i(roundi(base.x+normal.x*8.0),roundi(base.y+normal.y*8.0))
	var p2: Vector2i = Vector2i(roundi(base.x-normal.x*4.0),roundi(base.y-normal.y*4.0))
	_poly(img,PackedVector2Array([head,p0,p1,head]),OUTLINE)
	_poly(img,PackedVector2Array([head,p0,p1-Vector2i(roundi(normal.x*2.0),roundi(normal.y*2.0)),head]),STEEL_LIT)
	# Rear hook makes it a complete court halberd rather than a spear line.
	_poly(img,PackedVector2Array([head,p0,p2,head]),IRON)
	_ellipse(img,rear,Vector2i(3,3),GOLD_LIT)


func _draw_blood_candle(img: Image, center: Vector2i, frame: int, animation: String) -> void:
	_poly(img,_pts([center.x-3,center.y-2,center.x+4,center.y-2,center.x+3,center.y+12,center.x-3,center.y+12]),OUTLINE)
	_rect(img,center.x-2,center.y,5,11,WAX)
	_rect(img,center.x+2,center.y+2,1,7,WINE_LIT)
	_rect(img,center.x-4,center.y+11,9,3,GOLD)
	_rect(img,center.x,center.y+14,2,6,GOLD_LIT)
	if animation != "candle_extinguish":
		_poly(img,_pts([center.x,center.y,center.x+1,center.y-5-frame%2,center.x+3,center.y-1]),EMBER)
		_pixel(img,center.x+1,center.y-3-frame%2,SOUL_LIT)


func _draw_hook_hand(img: Image, hand: Vector2i, side: int) -> void:
	_ellipse(img,hand,Vector2i(3,3),GOLD)
	_segment(img,hand,hand+Vector2i(side*6,4),2,STEEL_LIT)
	_segment(img,hand+Vector2i(side*2,1),hand+Vector2i(side*4,7),2,STEEL)


func _draw_falling_death(img: Image, frame: int, count: int, cloth_color: Color, sword: bool) -> void:
	var t: float = float(frame)/float(maxi(1,count-1))
	var cx: int = 30+roundi(t*5.0)
	var floor_y: int = 57
	var height: int = maxi(6,46-roundi(t*35.0))
	_poly(img,_pts([cx-10,floor_y-height,cx+8,floor_y-height+2,cx+18,floor_y-4,cx-15,floor_y]),OUTLINE)
	_poly(img,_pts([cx-7,floor_y-height+3,cx+6,floor_y-height+4,cx+14,floor_y-5,cx-12,floor_y-2]),cloth_color)
	_ellipse(img,Vector2i(cx+11,floor_y-5),Vector2i(5,3),IVORY_SHADOW)
	if sword: _draw_smallsword(img,Vector2i(cx-7,floor_y-3),Vector2i(cx+24,floor_y-1))
	for mote: int in range(frame): _pixel(img,18+mote*6,48-mote*3-frame,ASH)


func _draw_armor_collapse(img: Image, frame: int) -> void:
	var t: float = float(frame)/6.0
	var y: int = 19+roundi(t*32.0)
	_ellipse(img,Vector2i(31,y),Vector2i(10,7),OUTLINE)
	_ellipse(img,Vector2i(31,y),Vector2i(7,5),IRON)
	_poly(img,_pts([8,y+4,22,y-2,25,y+10,14,y+14]),STEEL)
	_poly(img,_pts([54,y+4,41,y-2,38,y+10,49,y+14]),IRON)
	_rect(img,24,y+7,15,maxi(3,13-roundi(t*8.0)),CLOTH)
	for piece: int in range(frame+2):
		_rect(img,12+piece*7,55-(piece%2)*4,3,2,STEEL if piece%2==0 else GOLD)
		_pixel(img,18+piece*5,46-piece*2,VIOLET_LIT)


func _draw_acolyte_death(img: Image, frame: int) -> void:
	_draw_falling_death(img,frame,7,WINE,false)
	var candle: Vector2i = Vector2i(45,54-frame)
	_draw_blood_candle(img,candle,frame,"candle_extinguish")
	for smoke: int in range(frame): _pixel(img,46+smoke%2,43-smoke*3,ASH)


func _draw_stalker_death(img: Image, frame: int, falling: bool) -> void:
	var y: int = 10+frame*7 if falling else 47+mini(frame,2)*3
	_poly(img,_pts([20,y,42,y+1,50,y+9,16,y+11]),OUTLINE)
	_poly(img,_pts([23,y+2,39,y+3,45,y+8,19,y+9]),WINE)
	_ellipse(img,Vector2i(46,y+7),Vector2i(5,4),IVORY_SHADOW)
	for mote: int in range(frame): _pixel(img,18+mote*7,y-4-mote*2,ASH)


func _draw_hand(img: Image, center: Vector2i) -> void:
	_ellipse(img,center,Vector2i(3,3),IVORY_SHADOW)
	_pixel(img,center.x+1,center.y-1,IVORY)


func _write_preview(role: String) -> void:
	var samples: Array[String]
	match role:
		"hollow_retainer": samples=["idle","patrol","stab_windup","stab_active","combo_hit_02","death"]
		"court_halberdier": samples=["idle_guard","patrol","long_thrust_windup","long_thrust_active","halberd_sweep_active","death"]
		"mourning_armor": samples=["dormant","heavy_walk","overhead_windup","overhead_active","stagger","death_collapse"]
		"blood_candle_acolyte": samples=["prayer_idle","walk_or_reposition","projectile_cast_windup","projectile_cast_active","ally_buff_loop","death"]
		_: samples=["ceiling_idle","telegraph","drop_attack","land","emerging_claw","death_fall"]
	var board: Image = Image.create(768,256,false,Image.FORMAT_RGBA8)
	board.fill(Color("10131d"))
	for index: int in range(samples.size()):
		var animation: String = samples[index]
		var count: int = int((ANIMATIONS[role] as Dictionary)[animation])
		var source: Image = _draw_frame(role,animation,count/2,count)
		source.resize(192,192,Image.INTERPOLATE_NEAREST)
		var px: int = (index%4)*192
		var py: int = (index/4)*128
		board.blit_rect(source,Rect2i(0,0,192,mini(128,192)),Vector2i(px,py))
	var path: String = "%s/%s/animations/%s_stage1_preview.png" % [ROOT,role,role]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	board.save_png(ProjectSettings.globalize_path(path))


func _segment(img: Image, start: Vector2i, finish: Vector2i, thickness: int, color: Color) -> void:
	var steps: int = maxi(abs(finish.x-start.x),abs(finish.y-start.y))
	if steps == 0:
		_ellipse(img,start,Vector2i(maxi(1,thickness/2),maxi(1,thickness/2)),color)
		return
	for index: int in range(steps+1):
		var t: float = float(index)/float(steps)
		var point: Vector2i = Vector2i(roundi(lerpf(start.x,finish.x,t)),roundi(lerpf(start.y,finish.y,t)))
		_rect(img,point.x-thickness/2,point.y-thickness/2,thickness,thickness,color)


func _ellipse(img: Image, center: Vector2i, radius: Vector2i, color: Color) -> void:
	for y: int in range(center.y-radius.y,center.y+radius.y+1):
		for x: int in range(center.x-radius.x,center.x+radius.x+1):
			var dx: float = float(x-center.x)/float(maxi(1,radius.x))
			var dy: float = float(y-center.y)/float(maxi(1,radius.y))
			if dx*dx+dy*dy<=1.0: _pixel(img,x,y,color)


func _poly(img: Image, points: PackedVector2Array, color: Color) -> void:
	if points.size()<3:
		return
	var min_x: int=img.get_width()-1
	var max_x: int=0
	var min_y: int=img.get_height()-1
	var max_y: int=0
	for point: Vector2 in points:
		min_x=mini(min_x,floori(point.x)); max_x=maxi(max_x,ceili(point.x))
		min_y=mini(min_y,floori(point.y)); max_y=maxi(max_y,ceili(point.y))
	min_x=clampi(min_x,0,img.get_width()-1); max_x=clampi(max_x,0,img.get_width()-1)
	min_y=clampi(min_y,0,img.get_height()-1); max_y=clampi(max_y,0,img.get_height()-1)
	for py: int in range(min_y,max_y+1):
		for px: int in range(min_x,max_x+1):
			if Geometry2D.is_point_in_polygon(Vector2(px+0.5,py+0.5),points):
				img.set_pixel(px,py,color)


func _pts(values: Array[int]) -> PackedVector2Array:
	var points: PackedVector2Array=PackedVector2Array()
	for index: int in range(0,values.size(),2): points.append(Vector2(values[index],values[index+1]))
	return points


func _rect(img: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	var clipped: Rect2i=Rect2i(x,y,width,height).intersection(Rect2i(0,0,64,64))
	if clipped.size.x>0 and clipped.size.y>0: img.fill_rect(clipped,color)


func _pixel(img: Image, x: int, y: int, color: Color) -> void:
	if x>=0 and x<64 and y>=0 and y<64: img.set_pixel(x,y,color)
