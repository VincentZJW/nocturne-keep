extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons"
const SIZE: int = 64
const OUTLINE: Color = Color("0c0d12")
const VOID: Color = Color("05060a")
const BONE: Color = Color("c8c0aa")
const BONE_DARK: Color = Color("756f64")
const METAL: Color = Color("4b4b50")
const BURGUNDY: Color = Color("572a35")
const BURGUNDY_DARK: Color = Color("291821")
const BRASS: Color = Color("a77a35")
const SOUL: Color = Color("7ec4d9")
const SOUL_LIGHT: Color = Color("c8edf2")

const PENITENT: Dictionary[StringName, int] = {
	&"summon_telegraph": 4, &"rise": 6, &"idle": 4, &"walk": 6,
	&"claw_windup": 4, &"claw_active": 2, &"claw_recovery": 4,
	&"lunge_windup": 4, &"lunge_active": 2, &"lunge_recovery": 4,
	&"hurt": 3, &"stagger": 4, &"death": 6, &"forced_dissolve": 5,
}
const HUSK: Dictionary[StringName, int] = {
	&"summon_telegraph": 4, &"rise": 6, &"idle": 4, &"drift": 6,
	&"aim": 5, &"shoot": 3, &"recovery": 4, &"hurt": 3,
	&"stagger": 4, &"death": 6, &"forced_dissolve": 5,
}

var _saved: int = 0


func _initialize() -> void:
	for actor: StringName in [&"ossuary_penitent", &"choir_husk"]:
		var animations: Dictionary[StringName, int] = PENITENT if actor == &"ossuary_penitent" else HUSK
		for animation: StringName in animations:
			var count: int = animations[animation]
			var directory: String = "%s/%s/sprites/%s" % [ROOT, actor, animation]
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
			for frame: int in range(count):
				var image: Image = _draw_penitent(animation, frame, count) if actor == &"ossuary_penitent" else _draw_husk(animation, frame, count)
				var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
				if image.save_png(ProjectSettings.globalize_path(path)) != OK:
					push_error("Unable to save %s" % path)
					quit(1)
					return
				_saved += 1
	_write_previews()
	print("EDRAN_SUMMON_ART | PASS actors=2 frames=%d canvas=64" % _saved)
	quit(0)


func _draw_penitent(animation: StringName, frame: int, count: int) -> Image:
	var image: Image = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	if animation == &"summon_telegraph":
		_draw_seal(image, frame)
		return image
	var progress: float = float(frame) / float(maxi(1, count - 1))
	var origin: Vector2i = Vector2i(31, 59)
	if animation == &"rise":
		origin.y += roundi((1.0 - progress) * 23.0)
	if animation in [&"idle", &"walk"]:
		origin.y += [0, 1, 1, 0, -1, 0][frame % 6]
	if animation in [&"hurt", &"stagger"]:
		origin.x -= [2, 5, 3, 1][mini(frame, 3)]
	if animation == &"death":
		origin.y += roundi(progress * 8.0)
		origin.x -= roundi(progress * 8.0)
	var lean: int = 0
	if animation in [&"claw_windup", &"lunge_windup"]:
		lean = -frame
	if animation in [&"claw_active", &"lunge_active"]:
		lean = 3 + frame
	if animation in [&"claw_recovery", &"lunge_recovery"]:
		lean = 4 - frame
	var torso: Vector2i = origin + Vector2i(lean, -27)
	var stride: int = 0
	if animation == &"walk":
		stride = [-4, -2, 1, 4, 2, -1][frame]

	# Broad, weight-bearing legs and slab-like grave feet establish the summon
	# before any upper-body detail is added.
	_draw_segment(image, torso + Vector2i(-7, 15), origin + Vector2i(-7 - stride, -2), 9, OUTLINE)
	_draw_segment(image, torso + Vector2i(-7, 15), origin + Vector2i(-7 - stride, -3), 5, METAL)
	_draw_segment(image, torso + Vector2i(7, 15), origin + Vector2i(8 + stride, -2), 9, OUTLINE)
	_draw_segment(image, torso + Vector2i(7, 15), origin + Vector2i(8 + stride, -3), 5, BONE_DARK)
	_poly(image, PackedVector2Array([origin+Vector2i(-15-stride,-4), origin+Vector2i(-3-stride,-4), origin+Vector2i(-1-stride,0), origin+Vector2i(-16-stride,0)]), OUTLINE)
	_poly(image, PackedVector2Array([origin+Vector2i(2+stride,-4), origin+Vector2i(14+stride,-4), origin+Vector2i(16+stride,0), origin+Vector2i(1+stride,0)]), OUTLINE)
	_fill(image, Rect2i(origin.x-12-stride, origin.y-3, 8, 2), BONE_DARK)
	_fill(image, Rect2i(origin.x+4+stride, origin.y-3, 9, 2), BONE)

	# Rear ossuary slab, seal stone, and layered penitential mantle. These are
	# the concept's defining burden and remain visible in every animation.
	_poly(image, PackedVector2Array([torso+Vector2i(-13,-13), torso+Vector2i(8,-16), torso+Vector2i(14,-8), torso+Vector2i(12,13), torso+Vector2i(-12,13), torso+Vector2i(-17,-4)]), OUTLINE)
	_poly(image, PackedVector2Array([torso+Vector2i(-11,-11), torso+Vector2i(7,-14), torso+Vector2i(11,-7), torso+Vector2i(9,10), torso+Vector2i(-10,10), torso+Vector2i(-14,-3)]), BONE_DARK)
	_fill(image, Rect2i(torso.x-7, torso.y-12, 13, 17), METAL)
	_draw_seal_mark(image, torso + Vector2i(0,-4), 5)
	_poly(image, PackedVector2Array([torso+Vector2i(-16,-5), torso+Vector2i(15,-6), torso+Vector2i(12,14), torso+Vector2i(5,20), torso+Vector2i(0,16), torso+Vector2i(-6,21), torso+Vector2i(-13,13)]), OUTLINE)
	_poly(image, PackedVector2Array([torso+Vector2i(-14,-3), torso+Vector2i(13,-4), torso+Vector2i(10,12), torso+Vector2i(4,17), torso+Vector2i(0,13), torso+Vector2i(-5,18), torso+Vector2i(-11,11)]), BURGUNDY_DARK)
	for tear: int in range(5):
		var tear_x: int = torso.x - 10 + tear * 5
		_draw_segment(image, Vector2i(tear_x,torso.y+8), Vector2i(tear_x-2+tear%2,torso.y+18+tear%3), 2, BONE_DARK if tear%2 else BURGUNDY)

	# Heavy reliquary shoulders and a recessed ribbed chest.
	_poly(image, PackedVector2Array([torso+Vector2i(-19,-6), torso+Vector2i(-10,-12), torso+Vector2i(-3,-7), torso+Vector2i(-8,3), torso+Vector2i(-18,4)]), OUTLINE)
	_poly(image, PackedVector2Array([torso+Vector2i(19,-7), torso+Vector2i(10,-12), torso+Vector2i(3,-7), torso+Vector2i(8,3), torso+Vector2i(18,4)]), OUTLINE)
	_fill(image, Rect2i(torso.x-16,torso.y-7,8,8),BONE)
	_fill(image, Rect2i(torso.x+8,torso.y-8,8,8),BONE_DARK)
	_fill(image,Rect2i(torso.x-9,torso.y-5,18,18),OUTLINE)
	_fill(image,Rect2i(torso.x-7,torso.y-4,14,15),BURGUNDY_DARK)
	for rib: int in range(4):
		_draw_segment(image,torso+Vector2i(-6,-1+rib*3),torso+Vector2i(6,-2+rib*3),1,BONE_DARK)

	# Hunched skull with recognisable brow, sockets, nasal cavity, and teeth.
	var skull: Vector2i = torso + Vector2i(3,-15)
	_draw_penitent_skull(image,skull)

	# Long shackled arms end in deliberately oversized asymmetric grave claws.
	var left_hand: Vector2i = torso + Vector2i(-18,14)
	var right_hand: Vector2i = torso + Vector2i(18,12)
	if animation == &"claw_windup":
		right_hand = torso + Vector2i(12-frame*4,2-frame*2)
	if animation == &"claw_active":
		right_hand = torso + Vector2i(14+frame*2,5+frame*3)
		left_hand = torso + Vector2i(-16,15)
	if animation == &"lunge_windup":
		left_hand = torso + Vector2i(-12,4); right_hand = torso + Vector2i(-5,8)
	if animation == &"lunge_active":
		left_hand = torso + Vector2i(10+frame*2,5); right_hand = torso + Vector2i(14+frame*2,12)
	_draw_segment(image,torso+Vector2i(-13,0),left_hand,7,OUTLINE)
	_draw_segment(image,torso+Vector2i(-13,0),left_hand,4,METAL)
	_draw_segment(image,torso+Vector2i(13,0),right_hand,7,OUTLINE)
	_draw_segment(image,torso+Vector2i(13,0),right_hand,4,BONE_DARK)
	_draw_penitent_claw(image,left_hand,-1,7)
	_draw_penitent_claw(image,right_hand,1,8)
	_draw_chain_links(image,torso+Vector2i(-15,2),torso+Vector2i(15,6),6)
	if animation in [&"rise", &"forced_dissolve"]:
		_draw_seal(image, frame)
	if animation == &"forced_dissolve":
		_dissolve(image, frame + 1)
	return image


func _draw_husk(animation: StringName, frame: int, count: int) -> Image:
	var image: Image = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	if animation == &"summon_telegraph":
		_draw_seal(image, frame)
		return image
	var progress: float = float(frame) / float(maxi(1, count - 1))
	var origin: Vector2i = Vector2i(29,56)
	if animation == &"rise":
		origin.y += roundi((1.0-progress)*25.0)
	if animation in [&"idle",&"drift"]:
		origin.y += [0,-1,-2,-1,0,1][frame%6]
	if animation == &"drift":
		origin.x += [-1,0,1,1,0,-1][frame]
	if animation in [&"hurt",&"stagger"]:
		origin.x -= [2,5,3,1][mini(frame,3)]
	if animation == &"death":
		origin.y += roundi(progress*9.0)
	var cast_lean: int = 0
	if animation == &"aim":
		cast_lean = -mini(frame,3)
	if animation == &"shoot":
		cast_lean = 2+frame
	var mask: Vector2i = origin+Vector2i(cast_lean,-40)

	# Layered, torn choir vestments form a tapered floating silhouette instead
	# of rectangular legs. Each strip has a different delayed sway phase.
	_poly(image,PackedVector2Array([origin+Vector2i(-12,-29),origin+Vector2i(11,-29),origin+Vector2i(14,-10),origin+Vector2i(8,4),origin+Vector2i(2,-1),origin+Vector2i(-3,5),origin+Vector2i(-9,0),origin+Vector2i(-15,-11)]),OUTLINE)
	_poly(image,PackedVector2Array([origin+Vector2i(-10,-27),origin+Vector2i(9,-27),origin+Vector2i(11,-11),origin+Vector2i(6,1),origin+Vector2i(2,-4),origin+Vector2i(-3,2),origin+Vector2i(-7,-2),origin+Vector2i(-12,-12)]),BURGUNDY_DARK)
	for strip: int in range(7):
		var strip_x: int = origin.x-10+strip*3
		var sway: int = ((frame+strip)%3)-1
		var strip_length: int = 12+(strip*2+frame)%7
		var strip_color: Color = BONE_DARK if strip%3==0 else BURGUNDY if strip%2==0 else BURGUNDY_DARK
		_draw_segment(image,Vector2i(strip_x,origin.y-12),Vector2i(strip_x+sway,origin.y-12+strip_length),2,OUTLINE)
		_draw_segment(image,Vector2i(strip_x,origin.y-12),Vector2i(strip_x+sway,origin.y-12+strip_length-1),1,strip_color)

	# Exposed ribs, funeral stole, and all thirteen vertical seal nodes.
	_fill(image,Rect2i(origin.x-9,origin.y-31,18,22),OUTLINE)
	_fill(image,Rect2i(origin.x-7,origin.y-29,14,19),BURGUNDY_DARK)
	for rib: int in range(4):
		_draw_segment(image,origin+Vector2i(-7,-26+rib*4),origin+Vector2i(7,-27+rib*4),1,BONE_DARK)
	_draw_segment(image,origin+Vector2i(0,-31),origin+Vector2i(0,-8),3,OUTLINE)
	_draw_segment(image,origin+Vector2i(0,-31),origin+Vector2i(0,-8),1,BRASS)
	for seal: int in range(13):
		var seal_y: int = origin.y-29+seal*2
		_circle(image,Vector2i(origin.x,seal_y),1,OUTLINE)
		_pixel(image,origin.x,seal_y,BRASS if seal%3 else BONE)

	# Elongated cracked funerary mask and the throat bell.
	_draw_husk_mask(image,mask)
	var throat_bell: Vector2i = origin+Vector2i(cast_lean,-31)
	_draw_husk_throat_bell(image,throat_bell)

	# Long suspended arms trail behind movement and gather together for casting.
	var left_hand: Vector2i = origin+Vector2i(-18,-12)
	var right_hand: Vector2i = origin+Vector2i(18,-13)
	if animation == &"drift":
		left_hand += Vector2i(-2,frame%3); right_hand += Vector2i(-3,(frame+1)%3)
	if animation == &"aim":
		left_hand = origin+Vector2i(12+frame,-18-frame/2)
		right_hand = origin+Vector2i(17+frame*2,-21)
	if animation == &"shoot":
		left_hand = origin+Vector2i(14,-17)
		right_hand = origin+Vector2i(17,-21)
	_draw_husk_arm(image,origin+Vector2i(-8,-25),left_hand)
	_draw_husk_arm(image,origin+Vector2i(8,-25),right_hand)
	if animation == &"aim":
		var focus: Vector2i = right_hand+Vector2i(6,0)
		_circle(image,focus,2+frame/2,Color(SOUL,0.50))
		_circle(image,focus,1,SOUL_LIGHT)
		for pulse: int in range(3):
			_pixel(image,focus.x-4-pulse*3,focus.y-2+pulse*2,SOUL)
	if animation == &"shoot":
		var orb: Vector2i = right_hand+Vector2i(4+frame*2,0)
		_circle(image,orb,5,Color(SOUL,0.35))
		_circle(image,orb,3,SOUL)
		_circle(image,orb,1,SOUL_LIGHT)
		_draw_segment(image,right_hand,orb-Vector2i(3,0),1,SOUL_LIGHT)
	if animation in [&"rise",&"forced_dissolve"]:
		_draw_seal(image,frame)
	if animation == &"forced_dissolve":
		_dissolve(image,frame+1)
	return image


func _draw_penitent_skull(image: Image, center: Vector2i) -> void:
	_poly(image,PackedVector2Array([center+Vector2i(-6,-6),center+Vector2i(4,-7),center+Vector2i(7,-3),center+Vector2i(5,6),center+Vector2i(1,9),center+Vector2i(-5,6),center+Vector2i(-7,-1)]),OUTLINE)
	_poly(image,PackedVector2Array([center+Vector2i(-4,-5),center+Vector2i(3,-5),center+Vector2i(5,-2),center+Vector2i(3,5),center+Vector2i(0,7),center+Vector2i(-4,4),center+Vector2i(-5,-1)]),BONE)
	_fill(image,Rect2i(center.x-4,center.y-2,3,3),VOID)
	_fill(image,Rect2i(center.x+1,center.y-2,3,3),VOID)
	_pixel(image,center.x-3,center.y-1,SOUL_LIGHT)
	_pixel(image,center.x+2,center.y-1,SOUL_LIGHT)
	_fill(image,Rect2i(center.x-1,center.y+1,2,3),BONE_DARK)
	for tooth: int in range(4):
		_pixel(image,center.x-3+tooth*2,center.y+5,BONE_DARK)


func _draw_penitent_claw(image: Image, palm: Vector2i, direction: int, reach: int) -> void:
	_circle(image,palm,4,OUTLINE)
	_circle(image,palm,2,BONE_DARK)
	for finger: int in range(3):
		var knuckle: Vector2i = palm+Vector2i(direction*(3+finger),-2+finger*2)
		var tip: Vector2i = palm+Vector2i(direction*(reach+finger*2),-5+finger*4)
		_draw_segment(image,palm,knuckle,2,OUTLINE)
		_draw_segment(image,palm,knuckle,1,BONE)
		_draw_segment(image,knuckle,tip,2,OUTLINE)
		_draw_segment(image,knuckle,tip,1,BONE)


func _draw_chain_links(image: Image, start: Vector2i, finish: Vector2i, links: int) -> void:
	for link: int in range(links+1):
		var ratio: float = float(link)/float(maxi(1,links))
		var point_f: Vector2 = Vector2(start).lerp(Vector2(finish),ratio)
		var point: Vector2i = Vector2i(roundi(point_f.x),roundi(point_f.y))+Vector2i(0,roundi(sin(ratio*PI)*5.0))
		_circle(image,point,1,OUTLINE)
		_pixel(image,point.x,point.y,METAL if link%2 else BRASS)


func _draw_seal_mark(image: Image, center: Vector2i, radius: int) -> void:
	_circle(image,center,radius,OUTLINE)
	_circle(image,center,radius-1,BONE_DARK)
	_draw_segment(image,center+Vector2i(-3,0),center+Vector2i(3,0),1,BRASS)
	_draw_segment(image,center+Vector2i(0,-3),center+Vector2i(0,3),1,BRASS)
	_pixel(image,center.x,center.y,SOUL)


func _draw_husk_mask(image: Image, center: Vector2i) -> void:
	_poly(image,PackedVector2Array([center+Vector2i(-5,-8),center+Vector2i(4,-8),center+Vector2i(7,-4),center+Vector2i(5,8),center+Vector2i(0,12),center+Vector2i(-5,7),center+Vector2i(-7,-4)]),OUTLINE)
	_poly(image,PackedVector2Array([center+Vector2i(-3,-6),center+Vector2i(3,-6),center+Vector2i(5,-3),center+Vector2i(3,7),center+Vector2i(0,10),center+Vector2i(-3,6),center+Vector2i(-5,-3)]),BONE)
	_draw_segment(image,center+Vector2i(-1,-5),center+Vector2i(1,7),1,BONE_DARK)
	_fill(image,Rect2i(center.x-1,center.y-1,3,7),SOUL)
	_pixel(image,center.x,center.y+1,SOUL_LIGHT)
	_pixel(image,center.x+2,center.y-5,OUTLINE)
	_pixel(image,center.x-3,center.y+4,BONE_DARK)


func _draw_husk_throat_bell(image: Image, center: Vector2i) -> void:
	_draw_segment(image,center-Vector2i(0,3),center,1,BRASS)
	_poly(image,PackedVector2Array([center+Vector2i(-2,-1),center+Vector2i(2,-1),center+Vector2i(4,4),center+Vector2i(-4,4)]),OUTLINE)
	_poly(image,PackedVector2Array([center+Vector2i(-1,0),center+Vector2i(1,0),center+Vector2i(2,3),center+Vector2i(-2,3)]),BRASS)
	_draw_segment(image,center+Vector2i(-3,4),center+Vector2i(3,4),1,BONE)
	_pixel(image,center.x,center.y+5,VOID)


func _draw_husk_arm(image: Image, shoulder: Vector2i, hand: Vector2i) -> void:
	var elbow: Vector2i = Vector2i((shoulder.x+hand.x)/2,(shoulder.y+hand.y)/2+4)
	_draw_segment(image,shoulder,elbow,4,OUTLINE)
	_draw_segment(image,shoulder,elbow,2,BONE_DARK)
	_draw_segment(image,elbow,hand,3,OUTLINE)
	_draw_segment(image,elbow,hand,1,BONE)
	_circle(image,hand,2,OUTLINE)
	for finger: int in range(3):
		_draw_segment(image,hand,hand+Vector2i(3+finger, -2+finger*2),1,BONE)


func _write_previews() -> void:
	for actor: StringName in [&"ossuary_penitent", &"choir_husk"]:
		var source: Image = _draw_penitent(&"idle", 0, 4) if actor == &"ossuary_penitent" else _draw_husk(&"idle", 0, 4)
		var preview: Image = Image.create(256, 256, false, Image.FORMAT_RGBA8)
		preview.fill(Color("10131b"))
		_blit_nearest(preview, source, Vector2i.ZERO, 4)
		var directory: String = "%s/%s/previews" % [ROOT, actor]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		preview.save_png(ProjectSettings.globalize_path("%s/%s_master_preview.png" % [directory, actor]))


func _draw_seal(image: Image, frame: int) -> void:
	var center: Vector2i = Vector2i(31, 58)
	var radius: int = 10 + frame % 3
	for index: int in range(24):
		var angle: float = TAU * float(index) / 24.0
		var point: Vector2i = center + Vector2i(roundi(cos(angle) * radius), roundi(sin(angle) * radius * 0.28))
		_pixel(image, point.x, point.y, SOUL if index % 2 == frame % 2 else BRASS)
	for seal: int in range(13):
		var angle: float = TAU * float(seal) / 13.0
		_pixel(image, center.x + roundi(cos(angle) * 7.0), center.y + roundi(sin(angle) * 2.0), SOUL_LIGHT)


func _draw_claws(image: Image, hand: Vector2i, direction: int, length: int) -> void:
	_circle(image, hand, 2, OUTLINE)
	for claw: int in range(3):
		_draw_segment(image, hand + Vector2i(0, claw - 1), hand + Vector2i(direction * (length + claw), claw * 2 - 2), 1, BONE)


func _dissolve(image: Image, step: int) -> void:
	for y: int in range(SIZE):
		for x: int in range(SIZE):
			var color: Color = image.get_pixel(x, y)
			if color.a > 0.0 and ((x * 3 + y * 5 + step) % 7) < step:
				image.set_pixel(x, y, Color.TRANSPARENT)


func _blit_nearest(target: Image, source: Image, origin: Vector2i, scale: int) -> void:
	for y: int in range(source.get_height()):
		for x: int in range(source.get_width()):
			var color: Color = source.get_pixel(x, y)
			if color.a > 0.0:
				target.fill_rect(Rect2i(origin.x + x * scale, origin.y + y * scale, scale, scale), color)


func _poly(image: Image, points: PackedVector2Array, color: Color) -> void:
	if points.size() < 3:
		return
	var min_x: int = image.get_width()-1
	var min_y: int = image.get_height()-1
	var max_x: int = 0
	var max_y: int = 0
	for point: Vector2 in points:
		min_x = mini(min_x,floori(point.x))
		min_y = mini(min_y,floori(point.y))
		max_x = maxi(max_x,ceili(point.x))
		max_y = maxi(max_y,ceili(point.y))
	for y: int in range(maxi(0,min_y),mini(image.get_height()-1,max_y)+1):
		for x: int in range(maxi(0,min_x),mini(image.get_width()-1,max_x)+1):
			if Geometry2D.is_point_in_polygon(Vector2(x,y),points):
				image.set_pixel(x,y,color)


func _fill(image: Image, rect: Rect2i, color: Color) -> void:
	var clipped: Rect2i = rect.intersection(Rect2i(0, 0, SIZE, SIZE))
	if clipped.has_area(): image.fill_rect(clipped, color)


func _pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < SIZE and y < SIZE: image.set_pixel(x, y, color)


func _circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y: int in range(center.y - radius, center.y + radius + 1):
		for x: int in range(center.x - radius, center.x + radius + 1):
			if Vector2i(x, y).distance_squared_to(center) <= radius * radius: _pixel(image, x, y, color)


func _draw_segment(image: Image, start: Vector2i, finish: Vector2i, width: int, color: Color) -> void:
	var steps: int = maxi(absi(finish.x - start.x), absi(finish.y - start.y))
	for index: int in range(steps + 1):
		var ratio: float = float(index) / float(maxi(1, steps))
		var point: Vector2i = Vector2i(roundi(lerpf(start.x, finish.x, ratio)), roundi(lerpf(start.y, finish.y, ratio)))
		_circle(image, point, maxi(0, width / 2), color)
