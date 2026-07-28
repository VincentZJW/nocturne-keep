extends SceneTree

## Chapter III formal enemy art generator.
##
## The Phase 2 generator intentionally proved gameplay with compact geometric masks.
## This replacement builds role-specific, layered pixel silhouettes from hand-authored
## polygons, clustered highlights and material-specific details.  It writes every
## runtime frame so no legacy attack/reaction frame remains in the formal SpriteFrames.

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies"
const CLEAR: Color = Color(0.0, 0.0, 0.0, 0.0)
const VOID: Color = Color("080a10")
const OUTLINE: Color = Color("11141c")
const DEEP: Color = Color("1b2029")
const CLOTH: Color = Color("2a2c38")
const CLOTH_LIT: Color = Color("454653")
const WINE: Color = Color("703344")
const WINE_LIT: Color = Color("9b4a5c")
const IRON: Color = Color("48525d")
const STEEL: Color = Color("8797a4")
const STEEL_LIT: Color = Color("c0ccd2")
const BONE: Color = Color("d3c7b2")
const BONE_SHADOW: Color = Color("9f927f")
const COPPER: Color = Color("8d633b")
const COPPER_LIT: Color = Color("c18a4d")
const INK: Color = Color("2a2136")
const PALE: Color = Color("b8ddd9")
const PALE_LIT: Color = Color("e0f1e9")
const GLASS_BLUE: Color = Color("4e809b")
const GLASS_CYAN: Color = Color("75b0b0")
const GLASS_RED: Color = Color("97485d")
const GLASS_GOLD: Color = Color("b59556")
const SMOKE: Color = Color(0.47, 0.58, 0.58, 0.68)

const ROLES: Array[String] = [
	"bellchain_penitent",
	"censer_executioner",
	"silent_chorister",
	"stained_glass_seraph",
	"confessional_wraith",
	"thirteenth_scribe",
]

const ANIMATIONS: Dictionary = {
	"bellchain_penitent": {
		"idle": 4, "walk": 6, "alert": 3, "turn": 3,
		"chain_lash_windup": 5, "chain_lash_active": 2, "chain_lash_recovery": 5,
		"bell_slam_windup": 7, "bell_slam_active": 2, "bell_slam_recovery": 6,
		"chain_pull_windup": 5, "chain_pull_active": 2, "chain_pull_recovery": 5,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 6,
	},
	"censer_executioner": {
		"idle": 4, "walk": 6, "alert": 3, "turn": 3,
		"primary_windup": 5, "primary_active": 2, "primary_recovery": 5,
		"overhead_crush_windup": 7, "overhead_crush_active": 2, "overhead_crush_recovery": 7,
		"smoke_release_windup": 5, "smoke_release_active": 2, "smoke_release_recovery": 5,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 6,
	},
	"silent_chorister": {
		"idle": 4, "walk": 6, "alert": 3, "turn": 3,
		"silent_wave_windup": 5, "silent_wave_active": 2, "silent_wave_recovery": 5,
		"crescent_hymn_windup": 5, "crescent_hymn_active": 2, "crescent_hymn_recovery": 5,
		"hush_field_windup": 5, "hush_field_active": 4, "hush_field_recovery": 5,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 6,
	},
	"stained_glass_seraph": {
		"idle": 4, "walk": 6, "alert": 3, "turn": 3,
		"shard_volley_windup": 5, "shard_volley_active": 2, "shard_volley_recovery": 5,
		"dive_windup": 5, "dive_active": 2, "dive_recovery": 5,
		"shatter_burst_windup": 5, "shatter_burst_active": 2, "shatter_burst_recovery": 5,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 6,
	},
	"confessional_wraith": {
		"hidden": 4, "idle": 4, "walk": 6, "alert": 3, "turn": 3,
		"emerging_slash_windup": 5, "emerging_slash_active": 2, "emerging_slash_recovery": 5,
		"spectral_dash_windup": 5, "spectral_dash_active": 2, "spectral_dash_recovery": 5,
		"confession_scream_windup": 5, "confession_scream_active": 2, "confession_scream_recovery": 5,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 6,
	},
	"thirteenth_scribe": {
		"idle": 4, "walk": 6, "alert": 3, "turn": 3,
		"ink_lance_windup": 5, "ink_lance_active": 2, "ink_lance_recovery": 5,
		"binding_script_windup": 5, "binding_script_active": 2, "binding_script_recovery": 5,
		"thirteenth_seal_windup": 5, "thirteenth_seal_active": 2, "thirteenth_seal_recovery": 5,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 6,
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
		_write_role_references(role)
	print("CH3 ENEMY ART V2 | PASS roles=%d frames=%d" % [ROLES.size(), written])
	quit(0)


func _draw_frame(role: String, animation: String, frame: int, count: int) -> Image:
	var image: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var phase: float = float(frame) / float(maxi(1, count - 1))
	var stage: String = "base"
	if animation.ends_with("_windup"):
		stage = "windup"
	elif animation.ends_with("_active"):
		stage = "active"
	elif animation.ends_with("_recovery"):
		stage = "recovery"
	elif animation in ["light_hit", "hurt", "stagger"]:
		stage = "hurt"
	elif animation == "death":
		stage = "death"
	elif animation == "hidden":
		stage = "hidden"
	var bob: int = 0
	if animation == "idle":
		bob = [0, -1, -1, 0][frame]
	elif animation == "walk":
		bob = [0, -1, 0, 0, -1, 0][frame]
	match role:
		"bellchain_penitent":
			_draw_penitent(image, animation, stage, frame, phase, bob)
		"censer_executioner":
			_draw_executioner(image, animation, stage, frame, phase, bob)
		"silent_chorister":
			_draw_chorister(image, animation, stage, frame, phase, bob)
		"stained_glass_seraph":
			_draw_seraph(image, animation, stage, frame, phase, bob)
		"confessional_wraith":
			_draw_wraith(image, animation, stage, frame, phase, bob)
		"thirteenth_scribe":
			_draw_scribe(image, animation, stage, frame, phase, bob)
	return image


func _draw_penitent(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "death":
		_draw_penitent_death(img, frame)
		return
	var stride: int = [-4, -2, 1, 4, 2, -1][frame] if animation == "walk" else 0
	var lean: int = -2
	if stage == "windup": lean -= roundi(phase * 3.0)
	elif stage == "active": lean = 3
	elif stage == "hurt": lean = -5 - frame
	var x: int = 30 + lean
	var y: int = 7 + bob
	# Separate wrapped legs, curled feet and torn layered robe.
	_draw_segment(img, Vector2i(x - 4, y + 39), Vector2i(x - 6 - stride, 57), 5, OUTLINE)
	_draw_segment(img, Vector2i(x + 4, y + 39), Vector2i(x + 5 + stride, 57), 5, OUTLINE)
	_draw_segment(img, Vector2i(x - 4, y + 40), Vector2i(x - 6 - stride, 57), 3, IRON)
	_draw_segment(img, Vector2i(x + 4, y + 40), Vector2i(x + 5 + stride, 57), 3, CLOTH_LIT)
	_poly(img, _pts([x-11,y+18, x+9,y+17, x+12,y+44, x+7,y+50, x+2,y+46, x-2,y+51, x-7,y+47, x-12,y+49]), OUTLINE)
	_poly(img, _pts([x-9,y+20, x+7,y+19, x+9,y+42, x+5,y+47, x+1,y+43, x-3,y+48, x-7,y+44, x-10,y+46]), CLOTH)
	_poly(img, _pts([x-2,y+21, x+4,y+20, x+5,y+43, x+1,y+42, x-1,y+47, x-3,y+41]), WINE)
	_draw_fold(img, Vector2i(x-7,y+25), Vector2i(x-5,y+44), CLOTH_LIT)
	_draw_fold(img, Vector2i(x+6,y+24), Vector2i(x+7,y+40), DEEP)
	# Spiked shoulder rope and separately readable arms.
	_poly(img, _pts([x-12,y+18, x-8,y+14, x-3,y+17, x+8,y+14, x+12,y+19, x+7,y+22, x-8,y+22]), OUTLINE)
	_poly(img, _pts([x-10,y+18, x-7,y+16, x-2,y+19, x+7,y+16, x+10,y+19, x+6,y+20, x-7,y+20]), IRON)
	var left_hand: Vector2i = Vector2i(x - 13, y + 31)
	var right_hand: Vector2i = Vector2i(x + 13, y + 29)
	var bell: Vector2i = Vector2i(x + 18, y + 40)
	if animation.begins_with("chain_lash"):
		if stage == "windup": bell = Vector2i(x - 14 - roundi(phase * 18.0), y + 31 - roundi(phase * 8.0))
		elif stage == "active": bell = Vector2i(56, y + 22 + frame * 5)
		elif stage == "recovery": bell = Vector2i(58 - roundi(phase * 24.0), y + 26 + roundi(phase * 14.0))
	elif animation.begins_with("bell_slam"):
		if stage == "windup": bell = Vector2i(x + 8 + roundi(phase * 9.0), y + 34 - roundi(phase * 33.0))
		elif stage == "active": bell = Vector2i(52 + frame * 2, 59)
		elif stage == "recovery": bell = Vector2i(53 - roundi(phase * 18.0), 57 - roundi(phase * 16.0))
	elif animation.begins_with("chain_pull"):
		if stage == "windup": bell = Vector2i(x + 19 + roundi(phase * 15.0), y + 36 - roundi(phase * 5.0))
		elif stage == "active": bell = Vector2i(57, y + 26 + frame * 2)
		elif stage == "recovery": bell = Vector2i(61 - roundi(phase * 28.0), y + 29 + roundi(phase * 10.0))
	_draw_segment(img, Vector2i(x-8,y+20), left_hand, 5, OUTLINE)
	_draw_segment(img, Vector2i(x-8,y+21), left_hand, 3, CLOTH_LIT)
	_draw_segment(img, Vector2i(x+8,y+20), right_hand, 5, OUTLINE)
	_draw_segment(img, Vector2i(x+8,y+21), right_hand, 3, CLOTH_LIT)
	_draw_hand(img, left_hand)
	_draw_hand(img, right_hand)
	# Angular bandage hood, bolted mouth cage and copper throat bell.
	_poly(img, _pts([x-7,y+1, x-3,y-1, x+5,y+1, x+7,y+5, x+5,y+15, x-1,y+17, x-7,y+13, x-9,y+6]), OUTLINE)
	_poly(img, _pts([x-5,y+2, x-2,y+1, x+4,y+2, x+5,y+6, x+3,y+13, x-1,y+15, x-5,y+12, x-7,y+6]), BONE_SHADOW)
	_draw_segment(img, Vector2i(x-6,y+5), Vector2i(x+4,y+3), 2, BONE)
	_draw_segment(img, Vector2i(x-5,y+9), Vector2i(x+4,y+7), 2, BONE)
	_poly(img, _pts([x-5,y+10, x+5,y+9, x+4,y+14, x-4,y+15]), IRON)
	for bolt: int in range(3):
		_pixel(img, x - 3 + bolt * 3, y + 12, COPPER_LIT)
	if animation == "alert" or stage == "active":
		_pixel(img, x + 2, y + 6, PALE_LIT)
	_poly(img, _pts([x-5,y+16, x+6,y+15, x+7,y+20, x-6,y+21]), OUTLINE)
	_draw_bell(img, Vector2i(x+1,y+23), 7, true)
	_draw_chain_curve(img, right_hand, Vector2i((right_hand.x+bell.x)/2, mini(right_hand.y,bell.y)-8), bell - Vector2i(0,4), STEEL)
	_draw_bell(img, bell, 6, false)
	if animation.begins_with("bell_slam") and stage == "active":
		_draw_impact(img, Vector2i(bell.x, 59), COPPER_LIT)


func _draw_executioner(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "death":
		_draw_executioner_death(img, frame)
		return
	var stride: int = [-3,-1,1,3,1,-1][frame] if animation == "walk" else 0
	var x: int = 29 + (3 if stage == "active" else -3 if stage in ["windup","hurt"] else 0)
	var y: int = 5 + bob
	# Thick boots, bent knees and layered execution apron.
	_draw_segment(img, Vector2i(x-8,y+39), Vector2i(x-10-stride,58), 8, OUTLINE)
	_draw_segment(img, Vector2i(x+8,y+39), Vector2i(x+10+stride,58), 8, OUTLINE)
	_draw_segment(img, Vector2i(x-8,y+40), Vector2i(x-10-stride,57), 5, IRON)
	_draw_segment(img, Vector2i(x+8,y+40), Vector2i(x+10+stride,57), 5, IRON)
	_poly(img, _pts([x-16,y+18,x-10,y+13,x+11,y+13,x+17,y+19,x+14,y+44,x+9,y+50,x-11,y+50,x-16,y+43]), OUTLINE)
	_poly(img, _pts([x-13,y+19,x-8,y+16,x+9,y+16,x+14,y+20,x+11,y+42,x+7,y+47,x-9,y+47,x-13,y+41]), CLOTH)
	_poly(img, _pts([x-8,y+24,x+9,y+22,x+11,y+45,x+2,y+48,x-5,y+45]), WINE)
	_poly(img, _pts([x-7,y+25,x+6,y+24,x+7,y+42,x+1,y+45,x-4,y+42]), WINE_LIT)
	# Riveted iron shoulder plates and chain belt.
	_poly(img, _pts([x-17,y+18,x-12,y+12,x-5,y+14,x-7,y+21]), OUTLINE)
	_poly(img, _pts([x+17,y+18,x+12,y+12,x+5,y+14,x+7,y+21]), OUTLINE)
	_poly(img, _pts([x-15,y+17,x-11,y+14,x-7,y+15,x-9,y+19]), IRON)
	_poly(img, _pts([x+15,y+17,x+11,y+14,x+7,y+15,x+9,y+19]), STEEL)
	_draw_chain_curve(img, Vector2i(x-10,y+32), Vector2i(x,y+36), Vector2i(x+11,y+32), IRON)
	# Stitched pointed execution hood.
	_poly(img, _pts([x-9,y+2,x-4,y-2,x+7,y+2,x+9,y+12,x+5,y+18,x-7,y+17,x-11,y+11]), OUTLINE)
	_poly(img, _pts([x-7,y+3,x-3,y,x+5,y+3,x+6,y+11,x+3,y+15,x-5,y+14,x-8,y+10]), DEEP)
	_poly(img, _pts([x-5,y+7,x+6,y+6,x+5,y+10,x-5,y+11]), IRON)
	_pixel(img, x+3, y+8, WINE_LIT)
	for stitch: int in range(4):
		_pixel(img, x-5+stitch*3, y+4+stitch%2, CLOTH_LIT)
	var hand: Vector2i = Vector2i(x+17,y+28)
	var censer: Vector2i = Vector2i(x+23,y+46)
	if animation.begins_with("primary"):
		if stage == "windup": censer = Vector2i(x-13-roundi(phase*12.0),y+26-roundi(phase*8.0))
		elif stage == "active": censer = Vector2i(55,y+25+frame*7)
		elif stage == "recovery": censer = Vector2i(59-roundi(phase*25.0),y+31+roundi(phase*13.0))
	elif animation.begins_with("overhead_crush"):
		if stage == "windup": censer = Vector2i(x+7+roundi(phase*10.0),y+34-roundi(phase*34.0))
		elif stage == "active": censer = Vector2i(48+frame*3,55)
		elif stage == "recovery": censer = Vector2i(52-roundi(phase*20.0),58-roundi(phase*14.0))
	elif animation.begins_with("smoke_release"):
		censer = Vector2i(x+24,y+42-roundi(phase*5.0) if stage == "windup" else y+42)
	_draw_segment(img, Vector2i(x+11,y+20), hand, 8, OUTLINE)
	_draw_segment(img, Vector2i(x+11,y+21), hand, 5, IRON)
	_draw_hand(img, hand)
	_draw_chain_curve(img, hand, Vector2i((hand.x+censer.x)/2, mini(hand.y,censer.y)-9), censer-Vector2i(0,6), STEEL_LIT)
	_draw_censer(img, censer, 10)
	if animation.begins_with("smoke_release") and stage in ["active","recovery"]:
		_draw_smoke(img, Vector2i(censer.x,censer.y-10), frame+roundi(phase*5.0))
	if animation.begins_with("overhead_crush") and stage == "active":
		_draw_impact(img, Vector2i(censer.x,59), STEEL_LIT)


func _draw_chorister(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "death":
		_draw_chorister_death(img, frame)
		return
	var x: int = 30 + (3 if stage == "active" else -2 if stage == "hurt" else 0)
	var y: int = 7 + bob + [-1,0,1,0, -1,0][frame] if animation == "walk" else 7 + bob
	# Ragged floating choir vestments, three visible cloth layers.
	_poly(img, _pts([x-9,y+18,x+8,y+17,x+12,y+47,x+7,y+54,x+2,y+50,x-2,y+56,x-7,y+51,x-13,y+54]), OUTLINE)
	_poly(img, _pts([x-7,y+20,x+6,y+19,x+9,y+45,x+5,y+51,x+1,y+47,x-3,y+53,x-6,y+48,x-10,y+51]), INK)
	_poly(img, _pts([x-3,y+21,x+4,y+20,x+5,y+45,x+1,y+49,x-2,y+46]), WINE)
	_draw_fold(img, Vector2i(x-6,y+25),Vector2i(x-4,y+47),CLOTH_LIT)
	_draw_fold(img, Vector2i(x+6,y+24),Vector2i(x+7,y+44),DEEP)
	# Wax-sealed faceless mask and fractured choir halo.
	_poly(img,_pts([x-7,y+3,x-2,y,x+5,y+2,x+8,y+7,x+5,y+17,x-5,y+16,x-9,y+10]),OUTLINE)
	_poly(img,_pts([x-5,y+4,x-1,y+2,x+4,y+3,x+6,y+7,x+3,y+14,x-4,y+14,x-7,y+9]),BONE)
	_poly(img,_pts([x-5,y+9,x+5,y+9,x+3,y+13,x-3,y+13]),WINE)
	_ellipse(img,Vector2i(x+1,y+11),2,2,WINE_LIT)
	_draw_segment(img,Vector2i(x-11,y),Vector2i(x-3,y-3),2,GLASS_GOLD)
	_draw_segment(img,Vector2i(x+2,y-3),Vector2i(x+11,y),2,GLASS_GOLD)
	_pixel(img,x-7,y-2,GLASS_GOLD)
	# Sleeves, expressive chant hand and a proper open codex.
	var left_hand: Vector2i = Vector2i(x-14,y+29)
	var right_hand: Vector2i = Vector2i(x+14,y+28)
	if stage == "windup":
		left_hand += Vector2i(-roundi(phase*4.0),-roundi(phase*7.0)); right_hand += Vector2i(roundi(phase*5.0),-roundi(phase*6.0))
	elif stage == "active":
		left_hand = Vector2i(x-18,y+19); right_hand = Vector2i(x+18,y+18)
	_draw_segment(img,Vector2i(x-7,y+21),left_hand,5,OUTLINE)
	_draw_segment(img,Vector2i(x-7,y+21),left_hand,3,CLOTH_LIT)
	_draw_segment(img,Vector2i(x+7,y+21),right_hand,5,OUTLINE)
	_draw_segment(img,Vector2i(x+7,y+21),right_hand,3,CLOTH_LIT)
	_draw_hand(img,left_hand); _draw_hand(img,right_hand)
	_draw_book(img,Vector2i(x+10,y+33),stage == "active")
	if stage == "active":
		if animation.begins_with("silent_wave"):
			_draw_chant_wave(img,Vector2i(x+17,y+20),PALE,frame)
		elif animation.begins_with("crescent_hymn"):
			_draw_crescent(img,Vector2i(x+22,y+26),12,PALE_LIT)
		else:
			_draw_rune_ring(img,Vector2i(x,y+45),24,WINE_LIT,frame)


func _draw_seraph(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "death":
		_draw_seraph_death(img, frame)
		return
	var dive: bool = animation.begins_with("dive") and stage == "active"
	var x: int = 31 + (5 + frame*2 if dive else 0)
	var y: int = 11 + bob
	var spread: int = 1 if stage == "windup" else 4 if stage == "active" else 0
	# Leaded stained-glass wings are built from individual asymmetric panes.
	_draw_glass_wing(img,x,y,-1,spread,frame)
	_draw_glass_wing(img,x,y,1,spread,frame+1)
	# Sacred reliquary body: crown, mask, ribbed breastplate and split vestment.
	_poly(img,_pts([x-6,y+7,x-2,y+3,x+4,y+5,x+7,y+10,x+4,y+17,x-4,y+17,x-8,y+12]),OUTLINE)
	_poly(img,_pts([x-4,y+7,x-1,y+5,x+3,y+6,x+5,y+10,x+2,y+14,x-3,y+14,x-5,y+11]),BONE)
	_pixel(img,x+2,y+10,GLASS_CYAN)
	_poly(img,_pts([x-7,y+2,x-4,y-3,x-1,y+1,x+2,y-5,x+4,y+1,x+8,y-2,x+6,y+5,x-6,y+5]),OUTLINE)
	_draw_segment(img,Vector2i(x-5,y+2),Vector2i(x+5,y+2),2,GLASS_GOLD)
	_poly(img,_pts([x-7,y+17,x+7,y+17,x+9,y+37,x+4,y+47,x,y+43,x-4,y+49,x-8,y+37]),OUTLINE)
	_poly(img,_pts([x-5,y+19,x+5,y+19,x+6,y+35,x+2,y+43,x,y+39,x-3,y+45,x-6,y+35]),STEEL)
	_poly(img,_pts([x-3,y+21,x+3,y+20,x+3,y+34,x,y+39,x-2,y+34]),GLASS_BLUE)
	for rib: int in range(3):
		_draw_segment(img,Vector2i(x-4,y+24+rib*4),Vector2i(x+4,y+23+rib*4),1,GLASS_GOLD)
	if stage == "active" and animation.begins_with("shard_volley"):
		for shard: int in range(3):
			_draw_glass_shard(img,Vector2i(x+12+shard*8,y+18+shard*5),GLASS_CYAN if shard%2==0 else GLASS_RED)
	elif stage == "active" and animation.begins_with("shatter_burst"):
		for shard: int in range(7):
			var angle: float = TAU * float(shard) / 7.0
			_draw_glass_shard(img,Vector2i(x+roundi(cos(angle)*20.0),y+28+roundi(sin(angle)*18.0)),GLASS_RED if shard%2 else GLASS_CYAN)
	elif dive:
		_draw_segment(img,Vector2i(x-17,y+31),Vector2i(x+17,y+27),2,PALE_LIT)


func _draw_wraith(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "death":
		_draw_wraith_death(img,frame)
		return
	var booth_x: int = 23
	_draw_confessional(img,booth_x,10)
	if stage == "hidden":
		return
	var emergence: int = 4
	if stage == "windup": emergence = roundi(phase*10.0)
	elif stage == "active": emergence = 12
	elif stage == "recovery": emergence = 12-roundi(phase*8.0)
	elif stage == "hurt": emergence = 8
	var x: int = booth_x+7+emergence
	var y: int = 15+bob
	# Draped hood, visible death-mask and layered ectoplasmic stole.
	_poly(img,_pts([x-7,y+1,x-1,y-3,x+6,y+1,x+9,y+9,x+5,y+16,x-5,y+15,x-10,y+9]),OUTLINE)
	_poly(img,_pts([x-5,y+2,x-1,y-1,x+4,y+2,x+6,y+8,x+3,y+13,x-4,y+12,x-7,y+8]),PALE)
	_ellipse(img,Vector2i(x-2,y+7),1,2,VOID); _ellipse(img,Vector2i(x+3,y+7),1,2,VOID)
	_poly(img,_pts([x-8,y+15,x+8,y+15,x+12,y+39,x+5,y+46,x,y+42,x-5,y+48,x-13,y+39]),Color(PALE.r,PALE.g,PALE.b,0.82))
	_poly(img,_pts([x-5,y+18,x+2,y+17,x+5,y+39,x,y+42,x-4,y+37]),Color(GLASS_BLUE.r,GLASS_BLUE.g,GLASS_BLUE.b,0.62))
	var claw: Vector2i = Vector2i(x+17,y+28)
	if stage == "active": claw = Vector2i(59,y+23+frame*2)
	_draw_segment(img,Vector2i(x+5,y+20),claw,4,PALE)
	_draw_claw(img,claw,1)
	_draw_segment(img,Vector2i(x-5,y+21),Vector2i(x-13,y+30),4,PALE)
	_draw_claw(img,Vector2i(x-13,y+30),-1)
	if stage == "active" and animation.begins_with("confession_scream"):
		_draw_chant_wave(img,Vector2i(x+9,y+8),PALE_LIT,frame)
	elif stage == "active" and animation.begins_with("spectral_dash"):
		for trail: int in range(3):
			_draw_segment(img,Vector2i(x-8-trail*7,y+21+trail*5),Vector2i(x-2-trail*7,y+38+trail*3),2,Color(PALE.r,PALE.g,PALE.b,0.38))


func _draw_scribe(img: Image, animation: String, stage: String, frame: int, phase: float, bob: int) -> void:
	if stage == "death":
		_draw_scribe_death(img,frame)
		return
	var stride: int = [-2,-1,1,2,1,-1][frame] if animation == "walk" else 0
	var x: int = 29+(3 if stage == "active" else -3 if stage == "hurt" else 0)
	var y: int = 5+bob
	_draw_segment(img,Vector2i(x-4,y+41),Vector2i(x-5-stride,58),5,OUTLINE)
	_draw_segment(img,Vector2i(x+4,y+41),Vector2i(x+5+stride,58),5,OUTLINE)
	_draw_segment(img,Vector2i(x-4,y+42),Vector2i(x-5-stride,58),3,IRON)
	_draw_segment(img,Vector2i(x+4,y+42),Vector2i(x+5+stride,58),3,IRON)
	# Narrow clerk vestment with split tails, cords, seals and written strips.
	_poly(img,_pts([x-8,y+17,x+7,y+17,x+10,y+46,x+5,y+52,x+1,y+47,x-3,y+53,x-8,y+47,x-10,y+33]),OUTLINE)
	_poly(img,_pts([x-6,y+19,x+5,y+19,x+7,y+44,x+4,y+49,x+1,y+44,x-3,y+50,x-6,y+45,x-8,y+32]),INK)
	_poly(img,_pts([x-2,y+20,x+3,y+20,x+4,y+43,x+1,y+46,x-2,y+42]),WINE)
	_draw_chain_curve(img,Vector2i(x-6,y+30),Vector2i(x,y+34),Vector2i(x+7,y+30),COPPER)
	_ellipse(img,Vector2i(x+1,y+35),2,2,WINE_LIT)
	# Paper-wrapped face with thirteen-script impression and black gaps.
	_poly(img,_pts([x-6,y+1,x-2,y-1,x+5,y+1,x+7,y+16,x+2,y+19,x-6,y+15,x-8,y+6]),OUTLINE)
	_poly(img,_pts([x-4,y+2,x-1,y+1,x+3,y+2,x+5,y+14,x+1,y+16,x-4,y+13,x-6,y+6]),BONE)
	for row: int in range(4):
		_draw_segment(img,Vector2i(x-4,y+4+row*3),Vector2i(x+3,y+3+row*3),1,WINE if row==2 else INK)
	var ledger: Vector2i = Vector2i(x+15,y+31)
	_draw_ledger(img,ledger)
	var quill_tip: Vector2i = Vector2i(x+23,y+17)
	if stage == "windup": quill_tip += Vector2i(roundi(phase*7.0),-roundi(phase*8.0))
	elif stage == "active": quill_tip = Vector2i(62,y+13+frame*3)
	_draw_quill(img,Vector2i(x+8,y+27),quill_tip)
	if stage == "active":
		if animation.begins_with("ink_lance"):
			_poly(img,_pts([quill_tip.x-3,quill_tip.y-2,63,quill_tip.y,quill_tip.x-3,quill_tip.y+2]),INK)
		elif animation.begins_with("binding_script"):
			_draw_scroll_ribbon(img,Vector2i(x+13,y+39),frame)
		else:
			_draw_rune_ring(img,Vector2i(x+19,y+44),17,WINE_LIT,frame)


# -- Role details ------------------------------------------------------------

func _draw_glass_wing(img: Image, x: int, y: int, side: int, spread: int, frame: int) -> void:
	var root: Vector2i = Vector2i(x+side*5,y+22)
	var outer: Vector2i = Vector2i(x+side*(18+spread),y+5-(frame%2))
	var lower: Vector2i = Vector2i(x+side*(21+spread),y+36+(frame%3))
	_draw_segment(img,root,outer,4,OUTLINE)
	_draw_segment(img,root,lower,4,OUTLINE)
	var a: PackedVector2Array = PackedVector2Array([root,Vector2i(x+side*(9+spread),y+8),outer,Vector2i(x+side*(12+spread),y+21)])
	var b: PackedVector2Array = PackedVector2Array([root,Vector2i(x+side*(12+spread),y+22),lower,Vector2i(x+side*8,y+30)])
	_poly(img,a,GLASS_BLUE if side<0 else GLASS_RED)
	_poly(img,b,GLASS_CYAN if side<0 else GLASS_GOLD)
	_draw_segment(img,root,outer,2,GLASS_GOLD)
	_draw_segment(img,root,lower,2,GLASS_GOLD)
	_draw_segment(img,Vector2i(x+side*10,y+13),Vector2i(x+side*16,y+27),2,OUTLINE)
	_pixel(img,outer.x-side*2,outer.y+2,PALE_LIT)


func _draw_confessional(img: Image, x: int, y: int) -> void:
	_poly(img,_pts([x-11,y+7,x-8,y+1,x-3,y-3,x+4,y-3,x+10,y+2,x+12,y+53,x-12,y+53]),OUTLINE)
	_poly(img,_pts([x-8,y+8,x-6,y+3,x-2,y,x+3,y,x+7,y+4,x+9,y+50,x-9,y+50]),Color("382b35"))
	_poly(img,_pts([x-6,y+11,x+7,y+10,x+7,y+28,x-6,y+29]),WINE)
	for bar: int in range(4):
		_draw_segment(img,Vector2i(x-5+bar*3,y+11),Vector2i(x-4+bar*3,y+28),2,IRON)
	_draw_segment(img,Vector2i(x-7,y+34),Vector2i(x+8,y+33),2,COPPER)
	for nail: Vector2i in [Vector2i(x-7,y+7),Vector2i(x+7,y+7),Vector2i(x-7,y+46),Vector2i(x+7,y+46)]:
		_pixel(img,nail.x,nail.y,COPPER_LIT)


func _draw_censer(img: Image, center: Vector2i, size: int) -> void:
	var r: int = maxi(4,size/2)
	_poly(img,_pts([center.x-r,center.y-5,center.x-r+2,center.y-10,center.x,center.y-13,center.x+r-2,center.y-10,center.x+r,center.y-5,center.x+r-2,center.y+2,center.x,center.y+5,center.x-r+2,center.y+2]),OUTLINE)
	_poly(img,_pts([center.x-r+2,center.y-5,center.x-r+3,center.y-8,center.x,center.y-11,center.x+r-3,center.y-8,center.x+r-2,center.y-5,center.x+r-3,center.y,center.x,center.y+3,center.x-r+3,center.y]),COPPER)
	_draw_segment(img,Vector2i(center.x-r-1,center.y-3),Vector2i(center.x+r+1,center.y-3),2,STEEL)
	for hole: Vector2i in [Vector2i(center.x-3,center.y-6),Vector2i(center.x+2,center.y-7),Vector2i(center.x,center.y-2)]:
		_ellipse(img,hole,1,1,VOID)
	_pixel(img,center.x,center.y+1,WINE_LIT)
	_draw_segment(img,Vector2i(center.x-4,center.y+4),Vector2i(center.x+4,center.y+4),2,OUTLINE)


func _draw_bell(img: Image, base: Vector2i, size: int, throat: bool) -> void:
	var half: int = maxi(2,size/2)
	_poly(img,_pts([base.x-half+1,base.y-size,base.x+half-1,base.y-size,base.x+half,base.y-2,base.x+half+2,base.y,base.x-half-2,base.y,base.x-half,base.y-2]),OUTLINE)
	_poly(img,_pts([base.x-half+2,base.y-size+2,base.x+half-2,base.y-size+2,base.x+half-1,base.y-2,base.x-half+1,base.y-2]),COPPER)
	_draw_segment(img,Vector2i(base.x-half,base.y-3),Vector2i(base.x+half,base.y-3),1,COPPER_LIT)
	_ellipse(img,Vector2i(base.x,base.y+1),1,1,OUTLINE)
	if throat:
		_pixel(img,base.x-2,base.y-size+2,STEEL_LIT)


func _draw_book(img: Image, center: Vector2i, open_wide: bool) -> void:
	var width: int = 14 if open_wide else 11
	_poly(img,_pts([center.x-width/2,center.y-5,center.x-1,center.y-3,center.x,center.y+5,center.x-width/2,center.y+3]),OUTLINE)
	_poly(img,_pts([center.x+width/2,center.y-5,center.x+1,center.y-3,center.x,center.y+5,center.x+width/2,center.y+3]),OUTLINE)
	_poly(img,_pts([center.x-width/2+1,center.y-4,center.x-2,center.y-2,center.x-1,center.y+3,center.x-width/2+1,center.y+2]),BONE)
	_poly(img,_pts([center.x+width/2-1,center.y-4,center.x+2,center.y-2,center.x+1,center.y+3,center.x+width/2-1,center.y+2]),BONE)
	for row: int in range(2):
		_draw_segment(img,Vector2i(center.x-width/2+2,center.y-1+row*2),Vector2i(center.x-3,center.y+row*2),1,WINE)
		_draw_segment(img,Vector2i(center.x+3,center.y+row*2),Vector2i(center.x+width/2-2,center.y-1+row*2),1,WINE)


func _draw_ledger(img: Image, center: Vector2i) -> void:
	_poly(img,_pts([center.x-6,center.y-7,center.x+7,center.y-5,center.x+6,center.y+7,center.x-7,center.y+5]),OUTLINE)
	_poly(img,_pts([center.x-4,center.y-5,center.x+5,center.y-4,center.x+4,center.y+5,center.x-5,center.y+4]),BONE)
	for row: int in range(3):
		_draw_segment(img,Vector2i(center.x-3,center.y-2+row*2),Vector2i(center.x+3,center.y-1+row*2),1,WINE if row==1 else INK)


func _draw_quill(img: Image, grip: Vector2i, tip: Vector2i) -> void:
	_draw_segment(img,grip,tip,2,STEEL_LIT)
	var mid: Vector2i = Vector2i((grip.x+tip.x)/2,(grip.y+tip.y)/2)
	_poly(img,_pts([mid.x-2,mid.y+1,mid.x+1,mid.y-5,mid.x+5,mid.y-8,mid.x+3,mid.y-2,mid.x+1,mid.y+2]),BONE)
	_draw_segment(img,Vector2i(mid.x+1,mid.y-4),Vector2i(mid.x+3,mid.y-7),1,INK)


func _draw_claw(img: Image, palm: Vector2i, direction: int) -> void:
	_ellipse(img,palm,2,2,PALE)
	for finger: int in range(3):
		_draw_segment(img,palm,Vector2i(palm.x+direction*(4+finger),palm.y-3+finger*3),1,PALE_LIT)


func _draw_glass_shard(img: Image, center: Vector2i, color: Color) -> void:
	_poly(img,_pts([center.x-2,center.y+3,center.x,center.y-4,center.x+3,center.y+2]),OUTLINE)
	_poly(img,_pts([center.x-1,center.y+1,center.x,center.y-2,center.x+1,center.y+1]),color)


func _draw_smoke(img: Image, center: Vector2i, frame: int) -> void:
	for cloud: int in range(5):
		var p: Vector2i = center+Vector2i((cloud-2)*5+(frame%3),-cloud*4-frame)
		_ellipse(img,p,4+cloud%2,3+cloud%2,Color(SMOKE.r,SMOKE.g,SMOKE.b,maxf(0.18,SMOKE.a-cloud*0.08)))
		_pixel(img,p.x-2,p.y-1,PALE)


func _draw_chant_wave(img: Image, origin: Vector2i, color: Color, frame: int) -> void:
	for band: int in range(3):
		var x: int = origin.x+band*6+frame*2
		_draw_segment(img,Vector2i(x,origin.y-4-band*2),Vector2i(x+2,origin.y+4+band*2),2,color)
		_pixel(img,x+3,origin.y-band*3,PALE_LIT)


func _draw_crescent(img: Image, center: Vector2i, radius: int, color: Color) -> void:
	for step: int in range(13):
		var angle: float = -1.25+float(step)*0.18
		var p: Vector2i = center+Vector2i(roundi(cos(angle)*radius),roundi(sin(angle)*radius))
		_ellipse(img,p,1,1,color)


func _draw_rune_ring(img: Image, center: Vector2i, radius: int, color: Color, frame: int) -> void:
	for rune: int in range(8):
		var angle: float = TAU*float(rune)/8.0+float(frame)*0.12
		var p: Vector2i = center+Vector2i(roundi(cos(angle)*radius),roundi(sin(angle)*radius*0.45))
		_poly(img,_pts([p.x,p.y-2,p.x+2,p.y,p.x,p.y+2,p.x-2,p.y]),color)


func _draw_scroll_ribbon(img: Image, origin: Vector2i, frame: int) -> void:
	var points: Array[Vector2i] = []
	for index: int in range(6):
		points.append(origin+Vector2i(index*6,roundi(sin(float(index+frame))*3.0)))
	for index: int in range(points.size()-1):
		_draw_segment(img,points[index],points[index+1],3,BONE)
		if index%2==0: _pixel(img,points[index].x,points[index].y,WINE)


func _draw_impact(img: Image, center: Vector2i, color: Color) -> void:
	for ray: Vector2i in [Vector2i(-9,-2),Vector2i(-6,-7),Vector2i(7,-6),Vector2i(10,-1)]:
		_draw_segment(img,center,center+ray,2,color)


# -- Death treatments preserve equipment and avoid simple disappearance ------

func _draw_penitent_death(img: Image, frame: int) -> void:
	var y: int = 46+mini(frame,3)*3
	_poly(img,_pts([11,y,43,y-4,50,y+3,45,y+9,17,y+9]),OUTLINE)
	_poly(img,_pts([15,y+1,40,y-2,46,y+3,42,y+6,18,y+7]),CLOTH)
	_draw_bell(img,Vector2i(28,y),6,true)
	_draw_chain_curve(img,Vector2i(39,y+2),Vector2i(49,y-6),Vector2i(58,58),IRON)
	_draw_bell(img,Vector2i(58,58),6,false)
	_draw_death_fragments(img,frame,CLOTH_LIT,COPPER_LIT)


func _draw_executioner_death(img: Image, frame: int) -> void:
	var y: int = 43+mini(frame,3)*4
	_poly(img,_pts([8,y,48,y-5,56,y+3,49,y+12,13,y+12]),OUTLINE)
	_poly(img,_pts([12,y+1,44,y-3,51,y+3,46,y+8,15,y+9]),CLOTH)
	_poly(img,_pts([20,y,41,y-1,43,y+7,22,y+8]),WINE)
	_draw_chain_curve(img,Vector2i(42,y),Vector2i(52,y-7),Vector2i(59,57),STEEL)
	_draw_censer(img,Vector2i(58,57),9)
	_draw_death_fragments(img,frame,IRON,COPPER)


func _draw_chorister_death(img: Image, frame: int) -> void:
	var y: int = 36+frame*3
	_poly(img,_pts([18,y,43,y-2,48,y+10,39,y+16,22,y+13,14,y+7]),Color(INK.r,INK.g,INK.b,maxf(0.25,1.0-frame*0.12)))
	_draw_book(img,Vector2i(49,56),true)
	_draw_death_fragments(img,frame,PALE,WINE)


func _draw_seraph_death(img: Image, frame: int) -> void:
	var center: Vector2i = Vector2i(31,29+frame*3)
	if frame<4:
		_poly(img,_pts([center.x-5,center.y-10,center.x+5,center.y-10,center.x+7,center.y+12,center.x,center.y+18,center.x-7,center.y+12]),STEEL)
	for shard: int in range(5+frame*2):
		var angle: float = TAU*float(shard)/float(5+frame*2)
		var p: Vector2i = center+Vector2i(roundi(cos(angle)*(10+frame*3)),roundi(sin(angle)*(8+frame*2)))
		_draw_glass_shard(img,p,GLASS_RED if shard%3==0 else GLASS_CYAN)


func _draw_wraith_death(img: Image, frame: int) -> void:
	_draw_confessional(img,23,10)
	var alpha: float = maxf(0.14,1.0-frame*0.16)
	_poly(img,_pts([29,26-frame,46,22-frame,55,43-frame,45,57,28,51]),Color(PALE.r,PALE.g,PALE.b,alpha))
	_draw_death_fragments(img,frame,PALE,COPPER)


func _draw_scribe_death(img: Image, frame: int) -> void:
	var y: int = 44+mini(frame,3)*4
	_poly(img,_pts([13,y,42,y-3,49,y+4,43,y+11,18,y+10]),OUTLINE)
	_poly(img,_pts([17,y+1,39,y-1,45,y+4,40,y+7,20,y+7]),INK)
	_draw_ledger(img,Vector2i(51,55))
	for page: int in range(3+frame*2):
		var p: Vector2i = Vector2i(15+(page*9+frame*4)%45,18+(page*7+frame*3)%30)
		_poly(img,_pts([p.x,p.y,p.x+4,p.y-1,p.x+3,p.y+3,p.x-1,p.y+2]),BONE)
		_pixel(img,p.x+1,p.y+1,WINE)


func _draw_death_fragments(img: Image, frame: int, primary: Color, accent: Color) -> void:
	for particle: int in range(frame*3):
		var p: Vector2i = Vector2i(11+(particle*11+frame*5)%46,16+(particle*7+frame*3)%34)
		_poly(img,_pts([p.x,p.y-1,p.x+2,p.y,p.x+1,p.y+2,p.x-1,p.y+1]),accent if particle%3==0 else primary)


# -- Pixel primitives --------------------------------------------------------

func _pts(values: Array[int]) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(0,values.size(),2):
		points.append(Vector2(values[index],values[index+1]))
	return points


func _poly(img: Image, points: PackedVector2Array, color: Color) -> void:
	if points.size()<3:
		return
	var min_x: int = img.get_width()-1; var max_x: int = 0
	var min_y: int = img.get_height()-1; var max_y: int = 0
	for point: Vector2 in points:
		min_x = mini(min_x,floori(point.x)); max_x = maxi(max_x,ceili(point.x))
		min_y = mini(min_y,floori(point.y)); max_y = maxi(max_y,ceili(point.y))
	min_x = clampi(min_x,0,img.get_width()-1); max_x = clampi(max_x,0,img.get_width()-1)
	min_y = clampi(min_y,0,img.get_height()-1); max_y = clampi(max_y,0,img.get_height()-1)
	for py: int in range(min_y,max_y+1):
		for px: int in range(min_x,max_x+1):
			if Geometry2D.is_point_in_polygon(Vector2(px+0.5,py+0.5),points):
				img.set_pixel(px,py,color)


func _ellipse(img: Image, center: Vector2i, radius_x: int, radius_y: int, color: Color) -> void:
	for py: int in range(center.y-radius_y,center.y+radius_y+1):
		for px: int in range(center.x-radius_x,center.x+radius_x+1):
			if radius_x<=0 or radius_y<=0:
				continue
			var dx: float = float(px-center.x)/float(radius_x)
			var dy: float = float(py-center.y)/float(radius_y)
			if dx*dx+dy*dy<=1.0:
				_pixel(img,px,py,color)


func _draw_segment(img: Image, start: Vector2i, finish: Vector2i, thickness: int, color: Color) -> void:
	var steps: int = maxi(abs(finish.x-start.x),abs(finish.y-start.y))
	for index: int in range(steps+1):
		var ratio: float = float(index)/float(maxi(1,steps))
		var p: Vector2i = Vector2i(roundi(lerpf(start.x,finish.x,ratio)),roundi(lerpf(start.y,finish.y,ratio)))
		_ellipse(img,p,maxi(1,thickness/2),maxi(1,thickness/2),color)


func _draw_chain_curve(img: Image, start: Vector2i, control: Vector2i, finish: Vector2i, color: Color) -> void:
	var previous: Vector2i = start
	for index: int in range(1,19):
		var t: float = float(index)/18.0
		var inv: float = 1.0-t
		var point: Vector2i = Vector2i(roundi(inv*inv*start.x+2.0*inv*t*control.x+t*t*finish.x),roundi(inv*inv*start.y+2.0*inv*t*control.y+t*t*finish.y))
		if index%2==0:
			_draw_segment(img,previous,point,2,OUTLINE)
			_pixel(img,point.x,point.y,color)
		previous = point


func _draw_fold(img: Image, start: Vector2i, finish: Vector2i, color: Color) -> void:
	_draw_segment(img,start,finish,1,color)
	_pixel(img,finish.x+1,finish.y-1,color)


func _draw_hand(img: Image, center: Vector2i) -> void:
	_ellipse(img,center,2,2,OUTLINE)
	_ellipse(img,center,1,1,BONE)


func _pixel(img: Image, x: int, y: int, color: Color) -> void:
	if x>=0 and x<img.get_width() and y>=0 and y<img.get_height():
		img.set_pixel(x,y,color)


# -- Production references ---------------------------------------------------

func _write_role_references(role: String) -> void:
	var reference_dir: String = "%s/%s/concept_art" % [ROOT,role]
	var effect_dir: String = "%s/%s/effects" % [ROOT,role]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(reference_dir))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(effect_dir))
	var action_reference: Image = Image.create(192,64,false,Image.FORMAT_RGBA8)
	action_reference.fill(CLEAR)
	var idle: Image = _draw_frame(role,"idle",0,4)
	var action_name: String = _representative_action(role)
	var active_count: int = int((ANIMATIONS[role] as Dictionary)[action_name])
	var active: Image = _draw_frame(role,action_name,0,active_count)
	var hurt: Image = _draw_frame(role,"hurt",0,3)
	action_reference.blit_rect(idle,Rect2i(0,0,64,64),Vector2i(0,0))
	action_reference.blit_rect(active,Rect2i(0,0,64,64),Vector2i(64,0))
	action_reference.blit_rect(hurt,Rect2i(0,0,64,64),Vector2i(128,0))
	action_reference.save_png(ProjectSettings.globalize_path("%s/%s_action_reference.png" % [reference_dir,role]))
	var effect: Image = Image.create(96,48,false,Image.FORMAT_RGBA8)
	effect.fill(CLEAR)
	match role:
		"bellchain_penitent": _draw_chain_curve(effect,Vector2i(8,28),Vector2i(45,2),Vector2i(82,31),COPPER_LIT)
		"censer_executioner": _draw_smoke(effect,Vector2i(46,35),3)
		"silent_chorister": _draw_chant_wave(effect,Vector2i(18,24),PALE,0)
		"stained_glass_seraph":
			for index: int in range(5): _draw_glass_shard(effect,Vector2i(20+index*13,24+(index%2)*6),GLASS_RED if index%2 else GLASS_CYAN)
		"confessional_wraith": _draw_chant_wave(effect,Vector2i(18,24),PALE_LIT,1)
		"thirteenth_scribe": _draw_rune_ring(effect,Vector2i(48,24),20,WINE_LIT,1)
	effect.save_png(ProjectSettings.globalize_path("%s/%s_effect_reference.png" % [effect_dir,role]))


func _representative_action(role: String) -> String:
	match role:
		"bellchain_penitent": return "chain_lash_active"
		"censer_executioner": return "overhead_crush_active"
		"silent_chorister": return "crescent_hymn_active"
		"stained_glass_seraph": return "dive_active"
		"confessional_wraith": return "emerging_slash_active"
		_: return "thirteenth_seal_active"
