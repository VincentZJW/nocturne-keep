extends SceneTree

## Deterministic production-pixel authoring for Edran's structural transformation and Phase 2.
## Every frame is delivered on a 192x192 Boss canvas; no concept image is downscaled into runtime art.

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran"
const TRANSITION_ROOT: String = ROOT + "/phase_transition"
const PHASE_02_ROOT: String = ROOT + "/phase_02"
const CONCEPT_ROOT: String = ROOT + "/concept_art"
const PREVIEW_ROOT: String = ROOT + "/previews"
const SIZE: int = 96
const FRAME_SIZE: int = 192
const ART_OFFSET: Vector2i = Vector2i(48, 48)
const CLEAR: Color = Color(0, 0, 0, 0)
const OUTLINE: Color = Color("070810")
const VOID: Color = Color("0b0c14")
const CLOTH: Color = Color("252530")
const CLOTH_LIT: Color = Color("42424d")
const OXBLOOD: Color = Color("572131")
const BONE_DARK: Color = Color("777061")
const BONE: Color = Color("d1c7b3")
const GOLD: Color = Color("886632")
const GOLD_LIT: Color = Color("c5a65e")
const IRON: Color = Color("3b4651")
const STEEL: Color = Color("8798a3")
const SOUL: Color = Color("65a3bc")
const SOUL_LIT: Color = Color("b5e0e7")
const WAX: Color = Color("8a263b")

const TRANSITION_ANIMATIONS: Dictionary[StringName, int] = {
	&"seals_break": 4,
	&"crown_crack": 4,
	&"mask_void_reveal": 4,
	&"vestment_split": 4,
	&"chest_open": 4,
	&"rib_frame_extend": 4,
	&"black_bell_reveal": 4,
	&"arm_lengthen": 4,
	&"crozier_fuse": 4,
	&"censer_chain_bind": 4,
	&"phase_02_rise": 5,
}

const PHASE_02_ANIMATIONS: Dictionary[StringName, int] = {
	&"phase_02_idle": 4,
	&"distorted_walk": 6,
	&"phase_02_turn": 4,
	&"bell_bound_cleave": 7,
	&"hollow_toll": 7,
	&"censer_chain_hit_01": 6,
	&"censer_chain_hit_02": 6,
	&"scripture_burial": 7,
	&"procession_summon": 7,
	&"fourteenth_seat": 8,
	&"light_hit": 2,
	&"hurt": 3,
	&"stagger": 4,
	&"death_crozier_break": 4,
	&"death_censer_drop": 4,
	&"death_bell_fall": 4,
	&"death_collapse": 5,
	&"death_dissolve": 6,
}


func _initialize() -> void:
	var total: int = 0
	for transition: bool in [true, false]:
		var root: String = TRANSITION_ROOT if transition else PHASE_02_ROOT
		var animations: Dictionary[StringName, int] = TRANSITION_ANIMATIONS if transition else PHASE_02_ANIMATIONS
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(root))
		for animation: StringName in animations:
			var count: int = animations[animation]
			var directory: String = "%s/%s" % [root, animation]
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
			for frame: int in range(count):
				var image: Image = _draw_frame(animation, frame, count, transition)
				var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
				if image.save_png(ProjectSettings.globalize_path(path)) != OK:
					push_error("Unable to save Edran Phase 2 frame: %s" % path)
					quit(1)
					return
				total += 1
	_write_previews_and_concepts()
	print("EDRAN_PHASE_02_ART | PASS animations=%d frames=%d" % [TRANSITION_ANIMATIONS.size() + PHASE_02_ANIMATIONS.size(), total])
	quit(0)


func _draw_frame(animation: StringName, frame: int, count: int, transition: bool) -> Image:
	var legacy: Image = _draw_frame_legacy(animation, frame, count, transition)
	var image: Image = Image.create(FRAME_SIZE, FRAME_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	image.blit_rect(legacy, Rect2i(Vector2i.ZERO, legacy.get_size()), ART_OFFSET)
	_draw_replication_details(image, animation, frame, transition)
	return image


func _draw_frame_legacy(animation: StringName, frame: int, count: int, transition: bool) -> Image:
	var image: Image = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var progress: float = float(frame) / float(maxi(1, count - 1))
	var x: int = 48
	var y: int = 4
	var lean: int = 0
	var stride: int = 0
	if animation == &"distorted_walk":
		stride = [-5, -2, 2, 5, 2, -2][frame]
		y += [0, -1, 0, 1, 0, -1][frame]
	if animation in [&"bell_bound_cleave", &"censer_chain_hit_01", &"censer_chain_hit_02"]:
		lean = roundi(sin(progress * PI) * 8.0)
	if animation in [&"light_hit", &"hurt", &"stagger"]:
		x -= frame * 2
		lean = -4
	if animation.begins_with("death_"):
		y += roundi(progress * 10.0)
		lean = -roundi(progress * 10.0)
	_draw_phase_02(image, animation, frame, progress, x, y, lean, stride, transition)
	return image


func _draw_replication_details(image: Image, animation: StringName, frame: int, transition: bool) -> void:
	var o: Vector2i = ART_OFFSET
	# The broken crown, void mask, external ribs and black-bell reliquary are
	# permanent Phase II anatomy, not a colour modulation of Phase I.
	for point: int in range(7):
		var crown_x: int = o.x + 31 + point * 5
		_line(image, Vector2i(crown_x, o.y + 14), Vector2i(crown_x + (1 if point % 2 else -1), o.y + 4 + abs(point - 3)), 2, GOLD)
	_line(image, o + Vector2i(38, 20), o + Vector2i(55, 20), 2, VOID)
	_pixel(image, o.x + 42, o.y + 21, SOUL_LIT)
	_pixel(image, o.x + 51, o.y + 21, SOUL_LIT)
	for rib: int in range(5):
		_line(image, o + Vector2i(46, 37 + rib * 3), o + Vector2i(25 - rib * 2, 31 + rib * 2), 2, BONE)
		_line(image, o + Vector2i(49, 37 + rib * 3), o + Vector2i(69 + rib * 2, 31 + rib * 2), 2, BONE_DARK)
	_circle_outline(image, o + Vector2i(48, 48), 7, IRON)
	_fill(image, Rect2i(o.x + 44, o.y + 44, 8, 9), VOID)
	if transition:
		for shard: int in range(3 + frame):
			_pixel(image, o.x + 25 + (shard * 11) % 48, o.y + 12 + (shard * 7) % 35, BONE)


func _draw_phase_02(image: Image, animation: StringName, frame: int, progress: float, x: int, y: int, lean: int, stride: int, transition: bool) -> void:
	var reveal: float = progress if transition else 1.0
	var dissolve: float = progress if animation == &"death_dissolve" else 0.0
	# Split burial vestments: asymmetric, skeletal and materially different from Phase 1.
	_poly(image, [Vector2i(x-18,y+43),Vector2i(x+17,y+42),Vector2i(x+25,y+82),Vector2i(x+13,y+78),Vector2i(x+5,y+89),Vector2i(x-3,y+80),Vector2i(x-18,y+89),Vector2i(x-24,y+79)], OUTLINE)
	_poly(image, [Vector2i(x-15,y+44),Vector2i(x+14,y+44),Vector2i(x+20,y+79),Vector2i(x+10,y+76),Vector2i(x+4,y+85),Vector2i(x-3,y+77),Vector2i(x-15,y+85),Vector2i(x-20,y+78)], CLOTH)
	_poly(image, [Vector2i(x-3,y+44),Vector2i(x+13,y+43),Vector2i(x+18,y+78),Vector2i(x+8,y+75),Vector2i(x+3,y+84),Vector2i(x-2,y+76)], OXBLOOD)
	for tear: int in range(5):
		_line(image, Vector2i(x-16+tear*7,y+69), Vector2i(x-20+tear*8,y+84-tear%2), 1, BONE_DARK)
	_line(image, Vector2i(x-7,y+78), Vector2i(x-10-stride,y+90), 5, OUTLINE)
	_line(image, Vector2i(x+7,y+77), Vector2i(x+11+stride,y+90), 5, OUTLINE)
	_line(image, Vector2i(x-7,y+79), Vector2i(x-10-stride,y+88), 2, IRON)
	_line(image, Vector2i(x+7,y+78), Vector2i(x+11+stride,y+88), 2, STEEL)
	# Open chest and external rib frame enclosing the black bell.
	_poly(image, [Vector2i(x-17+lean,y+26),Vector2i(x-9+lean,y+18),Vector2i(x+9+lean,y+18),Vector2i(x+18+lean,y+29),Vector2i(x+12+lean,y+52),Vector2i(x-13+lean,y+52)], OUTLINE)
	_poly(image, [Vector2i(x-13+lean,y+28),Vector2i(x-8+lean,y+21),Vector2i(x+7+lean,y+21),Vector2i(x+14+lean,y+29),Vector2i(x+9+lean,y+48),Vector2i(x-10+lean,y+48)], CLOTH_LIT)
	var rib_spread: int = 6 + roundi(7.0 * reveal)
	for rib: int in range(4):
		var ry: int = y + 29 + rib * 5
		_line(image, Vector2i(x-3+lean,ry), Vector2i(x-rib_spread+lean,ry+4), 2, BONE)
		_line(image, Vector2i(x+3+lean,ry), Vector2i(x+rib_spread+lean,ry+4), 2, BONE_DARK)
	_fill(image, Rect2i(x-5+lean,y+29,11,16), VOID)
	_fill(image, Rect2i(x-3+lean,y+32,7,10), OUTLINE)
	_line(image, Vector2i(x+lean,y+32), Vector2i(x+lean,y+45), 2, SOUL)
	_fill(image, Rect2i(x-4+lean,y+43,9,4), IRON)
	# Empty split mitre/crown: face is a void and blue soul points leak through fractures.
	_poly(image, [Vector2i(x-10+lean,y+11),Vector2i(x-4+lean,y-7),Vector2i(x+1+lean,y+1),Vector2i(x+7+lean,y-10),Vector2i(x+11+lean,y+10),Vector2i(x+7+lean,y+24),Vector2i(x-7+lean,y+24)], OUTLINE)
	_poly(image, [Vector2i(x-7+lean,y+11),Vector2i(x-3+lean,y-3),Vector2i(x+1+lean,y+5),Vector2i(x+6+lean,y-5),Vector2i(x+8+lean,y+11),Vector2i(x+5+lean,y+21),Vector2i(x-5+lean,y+21)], VOID)
	_line(image, Vector2i(x-7+lean,y+8), Vector2i(x+8+lean,y+8), 2, GOLD)
	_line(image, Vector2i(x+1+lean,y-1), Vector2i(x-2+lean,y+10), 1, SOUL_LIT)
	_fill(image, Rect2i(x+2+lean,y+13,4,2), SOUL)
	_pixel(image, x+5+lean, y+13, SOUL_LIT)
	# Elongated arms, fused crozier blade on the right and chain-bound censer on the left.
	var right_hand: Vector2i = Vector2i(x+22+lean,y+43)
	var left_hand: Vector2i = Vector2i(x-22+lean,y+45)
	if animation == &"bell_bound_cleave":
		right_hand = Vector2i(x+24+roundi(progress*19.0), y+18+roundi(progress*28.0))
	if animation == &"censer_chain_hit_01":
		left_hand = Vector2i(x-20+roundi(progress*34.0), y+36+roundi(progress*18.0))
	if animation == &"censer_chain_hit_02":
		left_hand = Vector2i(x+roundi(progress*20.0), y+38+roundi(progress*32.0))
	_line(image, Vector2i(x+13+lean,y+28), right_hand, 9, OUTLINE)
	_line(image, Vector2i(x+13+lean,y+28), right_hand, 5, BONE_DARK)
	_line(image, Vector2i(x-13+lean,y+29), left_hand, 9, OUTLINE)
	_line(image, Vector2i(x-13+lean,y+29), left_hand, 5, BONE)
	var blade_tip: Vector2i = right_hand + Vector2i(24, -13)
	_line(image, right_hand, blade_tip, 8, OUTLINE)
	_line(image, right_hand, blade_tip, 5, IRON)
	_line(image, right_hand + Vector2i(2,-1), blade_tip - Vector2i(2,-1), 2, STEEL)
	_line(image, blade_tip-Vector2i(4,-1), blade_tip, 2, SOUL_LIT)
	_line(image, right_hand-Vector2i(5,5), right_hand+Vector2i(6,5), 3, GOLD)
	var censer: Vector2i = left_hand + Vector2i(-8, 25)
	if animation == &"censer_chain_hit_01":
		censer = left_hand + Vector2i(22, 10)
	elif animation == &"censer_chain_hit_02":
		censer = left_hand + Vector2i(5, 23)
	_line(image, left_hand, censer, 1, STEEL)
	for link: int in range(4):
		var lp: Vector2i = Vector2(left_hand).lerp(Vector2(censer), float(link+1)/5.0).round()
		_fill(image, Rect2i(lp.x-1,lp.y-1,3,2), IRON)
	_fill(image, Rect2i(censer.x-6,censer.y-4,13,8), OUTLINE)
	_fill(image, Rect2i(censer.x-4,censer.y-3,9,6), GOLD)
	_fill(image, Rect2i(censer.x-2,censer.y-1,5,3), WAX)
	_draw_action_fx(image, animation, frame, progress, Vector2i(x+lean,y))
	if dissolve > 0.0:
		for py: int in range(SIZE):
			for px: int in range(SIZE):
				if image.get_pixel(px,py).a > 0.0 and float((px*17+py*31)%100)/100.0 < dissolve*0.72:
					image.set_pixel(px,py,CLEAR)


func _draw_action_fx(image: Image, animation: StringName, frame: int, progress: float, center: Vector2i) -> void:
	if animation in [&"hollow_toll", &"fourteenth_seat"]:
		var radius: int = 8 + roundi(progress * 31.0)
		_circle_outline(image, center + Vector2i(0,42), radius, SOUL if frame%2==0 else GOLD)
	if animation in [&"scripture_burial", &"procession_summon"]:
		for mark: int in range(6):
			var mx: int = center.x-24+mark*9
			var my: int = center.y+75-(mark+frame)%4*3
			_fill(image,Rect2i(mx,my,3,3),WAX if mark%2==0 else SOUL)
	if animation == &"fourteenth_seat":
		for seal: int in range(13):
			var angle: float = TAU*float(seal)/13.0
			var p: Vector2i = center+Vector2i(roundi(cos(angle)*25.0),45+roundi(sin(angle)*14.0))
			_fill(image,Rect2i(p.x-1,p.y-1,3,3),GOLD_LIT)


func _write_previews_and_concepts() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PREVIEW_ROOT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CONCEPT_ROOT))
	var idle: Image = _draw_frame(&"phase_02_idle",0,4,false)
	idle.save_png(ProjectSettings.globalize_path(PREVIEW_ROOT+"/edran_phase_02_sprite_master.png"))
	var silhouette: Image = idle.duplicate()
	for y: int in range(silhouette.get_height()):
		for x: int in range(silhouette.get_width()):
			if silhouette.get_pixel(x,y).a > 0.0:
				silhouette.set_pixel(x,y,Color.BLACK)
	silhouette.save_png(ProjectSettings.globalize_path(PREVIEW_ROOT+"/edran_phase_02_sprite_silhouette.png"))
	var board: Image = Image.create(1280,800,false,Image.FORMAT_RGBA8)
	board.fill(Color("11131d"))
	_blit_nearest(board,_draw_frame(&"phase_02_rise",4,5,true),Vector2i(20,100),3)
	_blit_nearest(board,idle,Vector2i(650,100),3)
	_draw_label_blocks(board,Vector2i(70,42),520,GOLD_LIT)
	_draw_label_blocks(board,Vector2i(640,42),530,SOUL_LIT)
	board.save_png(ProjectSettings.globalize_path(CONCEPT_ROOT+"/edran_phase_transition_and_phase_02_board.png"))
	var anatomy: Image = Image.create(1280,640,false,Image.FORMAT_RGBA8)
	anatomy.fill(Color("10121b"))
	_blit_nearest(anatomy,_draw_frame(&"crown_crack",3,4,true),Vector2i(0,40),3)
	_blit_nearest(anatomy,_draw_frame(&"chest_open",3,4,true),Vector2i(410,40),3)
	_blit_nearest(anatomy,_draw_frame(&"crozier_fuse",3,4,true),Vector2i(820,40),3)
	anatomy.save_png(ProjectSettings.globalize_path(CONCEPT_ROOT+"/edran_phase_02_anatomy_and_weapon_board.png"))


func _draw_label_blocks(image: Image, origin: Vector2i, width: int, color: Color) -> void:
	_fill(image,Rect2i(origin.x,origin.y,width,4),color)
	_fill(image,Rect2i(origin.x,origin.y+12,width*2/3,3),Color(color,0.62))


func _blit_nearest(target: Image, source: Image, origin: Vector2i, scale: int) -> void:
	for sy: int in range(source.get_height()):
		for sx: int in range(source.get_width()):
			var color: Color = source.get_pixel(sx,sy)
			if color.a > 0.0:
				target.fill_rect(Rect2i(origin+Vector2i(sx*scale,sy*scale),Vector2i(scale,scale)),color)


func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	var min_y: int = SIZE-1
	var max_y: int = 0
	for point: Vector2i in points:
		min_y = mini(min_y,point.y)
		max_y = maxi(max_y,point.y)
	for y: int in range(maxi(0,min_y),mini(SIZE-1,max_y)+1):
		var intersections: Array[int] = []
		for index: int in range(points.size()):
			var a: Vector2i = points[index]
			var b: Vector2i = points[(index+1)%points.size()]
			if (a.y <= y and b.y > y) or (b.y <= y and a.y > y):
				intersections.append(roundi(float(a.x)+float(y-a.y)*float(b.x-a.x)/float(b.y-a.y)))
		intersections.sort()
		for index: int in range(0,intersections.size()-1,2):
			_fill(image,Rect2i(intersections[index],y,intersections[index+1]-intersections[index]+1,1),color)


func _line(image: Image, start: Vector2i, finish: Vector2i, width: int, color: Color) -> void:
	var delta: Vector2 = Vector2(finish-start)
	var steps: int = maxi(absi(finish.x-start.x),absi(finish.y-start.y))
	for step: int in range(steps+1):
		var point: Vector2i = (Vector2(start)+delta*(float(step)/float(maxi(1,steps)))).round()
		_fill(image,Rect2i(point-Vector2i(width/2,width/2),Vector2i(width,width)),color)


func _circle_outline(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for degree: int in range(0,360,4):
		var radians: float = deg_to_rad(float(degree))
		_pixel(image,center.x+roundi(cos(radians)*radius),center.y+roundi(sin(radians)*radius),color)


func _fill(image: Image, rect: Rect2i, color: Color) -> void:
	var clipped: Rect2i = rect.intersection(Rect2i(0,0,image.get_width(),image.get_height()))
	if clipped.size.x > 0 and clipped.size.y > 0:
		image.fill_rect(clipped,color)


func _pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
		image.set_pixel(x,y,color)
