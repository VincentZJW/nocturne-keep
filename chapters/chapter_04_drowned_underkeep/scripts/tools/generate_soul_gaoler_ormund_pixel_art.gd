extends SceneTree

## Formal 192 px boss production art. Phase II is redrawn with an opened soul cage,
## broken helm and two-handed fused key-halberd rather than recolouring Phase I.

const ROOT := "res://chapters/chapter_04_drowned_underkeep/assets/bosses/soul_gaoler_ormund"
const CLEAR := Color(0, 0, 0, 0)
const OUTLINE := Color("071015")
const ABYSS := Color("101b22")
const IRON := Color("344954")
const IRON_LIT := Color("718991")
const STEEL := Color("afc1c0")
const RUST := Color("714039")
const RUST_LIT := Color("a66249")
const SOUL := Color("4f9fa6")
const SOUL_LIT := Color("bce4df")
const GOLD := Color("9a7440")
const BONE := Color("b7ae96")
const MIRE := Color("294c47")

const ACTIONS_P1: Array[String] = ["halberd_sweep", "chain_anchor_slam", "prison_hook_drag", "floodgate_charge", "soul_cage_pulse"]
const ACTIONS_P2: Array[String] = ["chainstorm_cleave", "undertow_pull", "drowned_cell_rupture", "soul_shackle", "flooded_judgment"]


func _initialize() -> void:
	var defs: Dictionary = _definitions()
	var total: int = 0
	for animation: String in defs:
		var count: int = int(defs[animation])
		var directory: String = "%s/sprites/%s" % [ROOT, animation]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		for index: int in range(count):
			var image: Image = _draw_frame(animation, index, count)
			var path: String = "%s/%s_%02d.png" % [directory, animation, index + 1]
			if image.save_png(ProjectSettings.globalize_path(path)) != OK:
				push_error("Cannot save %s" % path)
				quit(1)
				return
			total += 1
	_write_reference_sheet()
	_write_phase_comparison()
	print("SOUL GAOLER ORMUND ART | PASS frames=%d animations=%d" % [total, defs.size()])
	quit(0)


func _definitions() -> Dictionary:
	var defs: Dictionary = {
		"dormant": 4, "intro": 6, "idle_p1": 5, "walk_p1": 6, "turn_p1": 4,
		"light_hit_p1": 2, "stagger_p1": 5, "phase_transition": 8,
		"idle_p2": 5, "move_p2": 6, "turn_p2": 4, "light_hit_p2": 2, "stagger_p2": 5,
		"death_start": 5, "death_collapse": 6, "soul_release": 8,
	}
	for action: String in ACTIONS_P1 + ACTIONS_P2:
		defs["%s_windup" % action] = 5
		defs["%s_active" % action] = 3
		defs["%s_recovery" % action] = 5
	return defs


func _draw_frame(animation: String, index: int, count: int) -> Image:
	var image := Image.create(192, 192, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var phase: float = float(index) / float(maxi(1, count - 1))
	var p2: bool = animation.contains("_p2") or animation in ACTIONS_P2 or _action_prefix(animation) in ACTIONS_P2
	if animation == "phase_transition":
		p2 = index >= 5
	var stage: String = "idle"
	if animation.ends_with("_windup"): stage = "windup"
	elif animation.ends_with("_active"): stage = "active"
	elif animation.ends_with("_recovery"): stage = "recovery"
	elif animation.contains("stagger") or animation.contains("light_hit"): stage = "hurt"
	elif animation.begins_with("death") or animation == "soul_release": stage = "death"
	elif animation == "phase_transition": stage = "transition"
	var bob: int = 0
	if animation.contains("idle"): bob = [0, -1, -2, -1, 0][index]
	elif animation.contains("walk") or animation == "move_p2": bob = [0, -2, -1, 0, -2, -1][index]
	_draw_ormund(image, p2, animation, stage, index, phase, bob)
	return image


func _draw_ormund(img: Image, p2: bool, animation: String, stage: String, frame: int, t: float, bob: int) -> void:
	if stage == "death":
		_draw_death(img, animation, frame, t)
		return
	var x: int = 91 + (12 if stage == "active" else -7 if stage in ["windup", "hurt"] else 0)
	var y: int = 34 + bob
	if stage == "transition":
		y -= roundi(sin(t * PI) * 5.0)
	var stride: int = [-9, -4, 4, 9, 4, -4][frame] if animation in ["walk_p1", "move_p2"] else 0
	# Separate armored legs and heavy sabatons.
	_segment(img, Vector2i(x - 17, y + 83), Vector2i(x - 23 - stride, 166), 22, OUTLINE)
	_segment(img, Vector2i(x + 16, y + 83), Vector2i(x + 25 + stride, 166), 22, OUTLINE)
	_segment(img, Vector2i(x - 17, y + 84), Vector2i(x - 23 - stride, 164), 14, RUST if p2 else IRON)
	_segment(img, Vector2i(x + 16, y + 84), Vector2i(x + 25 + stride, 164), 14, IRON_LIT)
	_poly(img, _pts([x-38,y+54,x-31,y+37,x-18,y+27,x+21,y+26,x+39,y+46,x+34,y+108,x+18,y+126,x+2,y+116,x-11,y+128,x-32,y+108]), OUTLINE)
	_poly(img, _pts([x-33,y+54,x-27,y+42,x-15,y+33,x+18,y+32,x+33,y+48,x+29,y+103,x+15,y+119,x+3,y+109,x-10,y+121,x-27,y+104]), RUST if p2 else ABYSS)
	# Ribbed cuirass and opened Phase II soul-cage.
	for rib: int in range(5):
		_segment(img, Vector2i(x-20,y+48+rib*10), Vector2i(x+21,y+45+rib*10), 4, IRON_LIT if rib % 2 == 0 else IRON)
	if p2:
		_poly(img, _pts([x-17,y+45,x+18,y+43,x+14,y+93,x-13,y+96]), OUTLINE)
		for bar: int in range(4): _segment(img, Vector2i(x-10+bar*7,y+48), Vector2i(x-9+bar*7,y+90), 3, RUST_LIT)
		_ellipse(img, Vector2i(x+2,y+67), 10, 14, SOUL)
		_ellipse(img, Vector2i(x+3,y+65), 4, 7, SOUL_LIT)
	else:
		_poly(img, _pts([x-12,y+49,x+18,y+46,x+17,y+80,x-10,y+85]), IRON)
		_draw_key_sigils(img, Vector2i(x+3,y+65))
	# Mantle, prison pauldrons and broken cape.
	_poly(img, _pts([x-47,y+51,x-39,y+27,x-18,y+23,x-22,y+58]), OUTLINE)
	_poly(img, _pts([x+47,y+49,x+39,y+25,x+17,y+24,x+23,y+59]), OUTLINE)
	_poly(img, _pts([x-42,y+49,x-35,y+31,x-20,y+28,x-24,y+51]), RUST)
	_poly(img, _pts([x+42,y+47,x+35,y+30,x+19,y+29,x+25,y+52]), IRON_LIT)
	_poly(img, _pts([x-31,y+91,x-52,y+118,x-45,y+153,x-30,y+141,x-19,y+161,x-10,y+114]), PRISON_COLOR(p2))
	# Crowned prison helm: intact in P1, split and exposed in P2.
	if p2:
		_poly(img, _pts([x-18,y+4,x-9,y-9,x+1,y+1,x+12,y-13,x+20,y+6,x+15,y+30,x-14,y+31,x-23,y+18]), OUTLINE)
		_poly(img, _pts([x-14,y+5,x-8,y-4,x+1,y+5,x+11,y-7,x+15,y+8,x+11,y+25,x-11,y+26,x-18,y+17]), RUST)
		_poly(img, _pts([x+2,y+4,x+19,y+8,x+15,y+28,x+1,y+26]), IRON_LIT)
		_ellipse(img, Vector2i(x+5,y+16), 10, 6, SOUL)
		_segment(img, Vector2i(x-6,y+16), Vector2i(x+14,y+14), 3, SOUL_LIT)
	else:
		_poly(img, _pts([x-22,y+5,x-14,y-10,x-4,y-2,x+3,y-15,x+10,y-3,x+19,y-10,x+23,y+8,x+17,y+32,x-16,y+32,x-25,y+18]), OUTLINE)
		_poly(img, _pts([x-17,y+6,x-11,y-5,x-4,y+3,x+3,y-10,x+9,y+3,x+15,y-5,x+18,y+9,x+13,y+27,x-12,y+27,x-19,y+17]), IRON)
		for bar: int in range(6): _segment(img, Vector2i(x-10+bar*5,y+8), Vector2i(x-10+bar*5,y+24), 2, STEEL)
		_segment(img, Vector2i(x-11,y+14), Vector2i(x+14,y+13), 2, SOUL_LIT)
	# Back cage silhouette in P1; broken chains replace it in P2.
	if not p2:
		_rect(img, Rect2i(x-52,y+39,18,67), OUTLINE); _rect(img, Rect2i(x-48,y+43,10,59), IRON)
		for rung: int in range(5): _segment(img, Vector2i(x-51,y+48+rung*12), Vector2i(x-36,y+48+rung*12), 2, STEEL)
	else:
		_chain(img, Vector2i(x-35,y+36), Vector2i(x-58,y+83)); _chain(img, Vector2i(x+34,y+38), Vector2i(x+55,y+96))
	# Arms and key-halberd. Phase II genuinely uses a two-handed fused posture.
	var rear_hand := Vector2i(x - 28, y + 76)
	var front_hand := Vector2i(x + 33, y + 76)
	var tip := Vector2i(x + 75, y + 132)
	if stage == "windup": tip = Vector2i(x-68-roundi(t*10.0), y+28-roundi(t*38.0))
	elif stage == "active": tip = Vector2i(190, y+48+frame*13)
	elif stage == "recovery": tip = Vector2i(188-roundi(t*70.0), y+59+roundi(t*63.0))
	if p2:
		rear_hand = Vector2i(x+3,y+69); front_hand=Vector2i(x+31,y+78)
		_segment(img, Vector2i(x-22,y+50), rear_hand, 15, OUTLINE); _segment(img, Vector2i(x-22,y+50), rear_hand, 8, RUST)
	else:
		_segment(img, Vector2i(x-24,y+51), rear_hand, 17, OUTLINE); _segment(img, Vector2i(x-24,y+51), rear_hand, 9, IRON)
	_segment(img, Vector2i(x+23,y+52), front_hand, 17, OUTLINE); _segment(img, Vector2i(x+23,y+52), front_hand, 9, IRON_LIT)
	_draw_key_halberd(img, rear_hand if p2 else front_hand, tip, p2)
	if stage == "transition":
		for spark: int in range(9):
			var a: float = float(spark) * TAU / 9.0
			var radius: float = 35.0 + 50.0 * t
			_ellipse(img, Vector2i(x+roundi(cos(a)*radius),y+64+roundi(sin(a)*radius)), 2, 2, SOUL_LIT)


func _draw_key_halberd(img: Image, grip: Vector2i, tip: Vector2i, p2: bool) -> void:
	_segment(img, grip, tip, 10 if p2 else 9, OUTLINE)
	_segment(img, grip, tip, 5 if p2 else 4, RUST_LIT if p2 else GOLD)
	var direction: Vector2 = Vector2(tip - grip).normalized()
	var normal := Vector2(-direction.y, direction.x)
	var base: Vector2 = Vector2(tip) - direction * 25.0
	var a := Vector2i(base + normal * 16.0)
	var b := Vector2i(base - normal * 16.0)
	_poly(img, PackedVector2Array([Vector2(tip)+direction*7.0, Vector2(a), base-direction*10.0, Vector2(b)]), OUTLINE)
	_poly(img, PackedVector2Array([Vector2(tip)+direction*3.0, Vector2(base+normal*11.0), base-direction*5.0, Vector2(base-normal*11.0)]), STEEL)
	_ellipse(img, grip, 7, 7, OUTLINE); _ellipse(img, grip, 4, 4, SOUL if p2 else GOLD)


func _draw_death(img: Image, animation: String, frame: int, t: float) -> void:
	var x: int = 92
	var floor_y: int = 168
	if animation == "death_start":
		_draw_ormund(img, true, "idle_p2", "hurt", frame, t, roundi(t*4.0))
		return
	if animation == "death_collapse":
		var cx: int = x + roundi(t*32.0)
		var cy: int = 70 + roundi(t*78.0)
		_poly(img, _pts([cx-45,cy-22,cx+24,cy-18,cx+43,cy+15,cx+22,cy+27,cx-44,cy+21]), OUTLINE)
		_poly(img, _pts([cx-37,cy-16,cx+18,cy-12,cx+35,cy+12,cx+18,cy+21,cx-36,cy+16]), IRON)
		_draw_key_halberd(img, Vector2i(cx+11,cy), Vector2i(mini(188,cx+79),floor_y-4), true)
		return
	# Soul release leaves readable armor fragments while the jailer spirit rises.
	_poly(img, _pts([40,floor_y-19,125,floor_y-21,154,floor_y-5,42,floor_y-3]), OUTLINE)
	_poly(img, _pts([48,floor_y-16,121,floor_y-17,143,floor_y-7,49,floor_y-6]), IRON)
	var sy: int = floor_y - 33 - roundi(t*88.0)
	_ellipse(img, Vector2i(95,sy), 18, 25, Color(0.45,0.82,0.84,0.72*(1.0-t*0.55)))
	for bar: int in range(4): _segment(img,Vector2i(86+bar*6,sy-7),Vector2i(86+bar*6,sy+10),2,SOUL_LIT)


func _write_reference_sheet() -> void:
	var sheet := Image.create(1152, 576, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("0b1219"))
	var samples: Array[String] = ["idle_p1","halberd_sweep_active","chain_anchor_slam_active","phase_transition","idle_p2","chainstorm_cleave_active","flooded_judgment_active","death_collapse"]
	for i: int in range(samples.size()):
		var frame: Image = _draw_frame(samples[i], 1, 3)
		sheet.blit_rect(frame, Rect2i(0,0,192,192), Vector2i((i%4)*288+48,(i/4)*288+48))
	var path: String = "%s/reference/ormund_runtime_reference_sheet.png" % ROOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	sheet.save_png(ProjectSettings.globalize_path(path))


func _write_phase_comparison() -> void:
	var sheet := Image.create(768, 384, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("091018"))
	sheet.blit_rect(_draw_frame("idle_p1",0,5),Rect2i(0,0,192,192),Vector2i(96,96))
	sheet.blit_rect(_draw_frame("idle_p2",0,5),Rect2i(0,0,192,192),Vector2i(480,96))
	var path: String="%s/reference/ormund_phase_runtime_comparison.png" % ROOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	sheet.save_png(ProjectSettings.globalize_path(path))


func _action_prefix(animation: String) -> String:
	for suffix: String in ["_windup","_active","_recovery"]:
		if animation.ends_with(suffix): return animation.trim_suffix(suffix)
	return animation


func PRISON_COLOR(p2: bool) -> Color:
	return Color("4c2530") if p2 else Color("352630")


func _rect(img: Image, rect: Rect2i, color: Color) -> void:
	img.fill_rect(rect,color)


func _pixel(img: Image,x:int,y:int,color:Color)->void:
	if x>=0 and y>=0 and x<img.get_width() and y<img.get_height(): img.set_pixel(x,y,color)


func _pts(values:Array)->PackedVector2Array:
	var out:=PackedVector2Array()
	for i:int in range(0,values.size(),2):
		out.append(Vector2(values[i],values[i+1]))
	return out


func _poly(img:Image,points:PackedVector2Array,color:Color)->void:
	if points.size() < 3:
		return
	var min_x: int = img.get_width() - 1
	var max_x: int = 0
	var min_y: int = img.get_height() - 1
	var max_y: int = 0
	for point: Vector2 in points:
		min_x = mini(min_x, floori(point.x))
		max_x = maxi(max_x, ceili(point.x))
		min_y = mini(min_y, floori(point.y))
		max_y = maxi(max_y, ceili(point.y))
	for y: int in range(clampi(min_y,0,img.get_height()-1),clampi(max_y,0,img.get_height()-1)+1):
		for x: int in range(clampi(min_x,0,img.get_width()-1),clampi(max_x,0,img.get_width()-1)+1):
			if Geometry2D.is_point_in_polygon(Vector2(x+0.5,y+0.5),points):
				img.set_pixel(x,y,color)


func _segment(img:Image,a:Vector2i,b:Vector2i,width:int,color:Color)->void:
	var d:=Vector2(b-a)
	var steps:int=maxi(1,ceili(d.length()))
	for i:int in range(steps+1):
		var p:=Vector2(a).lerp(Vector2(b),float(i)/steps)
		img.fill_rect(Rect2i(roundi(p.x)-width/2,roundi(p.y)-width/2,width,width),color)


func _ellipse(img:Image,c:Vector2i,rx:int,ry:int,color:Color)->void:
	for y:int in range(-ry,ry+1):
		for x:int in range(-rx,rx+1):
			if float(x*x)/float(maxi(1,rx*rx))+float(y*y)/float(maxi(1,ry*ry))<=1.0: _pixel(img,c.x+x,c.y+y,color)


func _chain(img:Image,a:Vector2i,b:Vector2i)->void:
	var d:=Vector2(b-a)
	var count:int=maxi(2,roundi(d.length()/9.0))
	for i:int in range(count+1):
		var p:=Vector2i(Vector2(a).lerp(Vector2(b),float(i)/count))
		_ellipse(img,p,4,3,OUTLINE)
		_ellipse(img,p,2,1,STEEL)


func _draw_key_sigils(img:Image,c:Vector2i)->void:
	_ellipse(img,c,8,8,OUTLINE); _ellipse(img,c,5,5,GOLD); _rect(img,Rect2i(c.x-2,c.y+5,4,15),GOLD); _rect(img,Rect2i(c.x+1,c.y+14,8,3),GOLD)
