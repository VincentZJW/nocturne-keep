extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons"
const SIZE: int = 64
const OUTLINE: Color = Color("0c0d12")
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
	var origin: Vector2i = Vector2i(31, 57)
	if animation == &"rise": origin.y += roundi((1.0 - progress) * 24.0)
	if animation in [&"idle", &"walk"]: origin.y += 1 if frame % 4 == 1 else 0
	if animation == &"walk": origin.x += [-2, -1, 0, 2, 1, 0][frame]
	if animation in [&"hurt", &"stagger"]: origin.x -= [2, 4, 1, 3][mini(frame, 3)]
	if animation == &"death":
		origin.y += roundi(progress * 11.0)
		origin.x -= roundi(progress * 7.0)
	var lean: int = 0
	if animation in [&"claw_windup", &"lunge_windup"]: lean = -frame
	if animation in [&"claw_active", &"lunge_active"]: lean = 5 + frame * 3
	if animation in [&"claw_recovery", &"lunge_recovery"]: lean = 4 - frame
	var torso: Vector2i = origin + Vector2i(lean, -24)
	# Heavy shoulder reliquaries and ragged penitential mantle.
	_fill(image, Rect2i(torso.x - 12, torso.y - 2, 24, 22), OUTLINE)
	_fill(image, Rect2i(torso.x - 10, torso.y, 20, 18), BURGUNDY_DARK)
	_fill(image, Rect2i(torso.x - 13, torso.y, 6, 11), BONE_DARK)
	_fill(image, Rect2i(torso.x + 7, torso.y, 6, 11), BONE_DARK)
	_fill(image, Rect2i(torso.x - 11, torso.y + 3, 5, 7), BONE)
	_fill(image, Rect2i(torso.x + 6, torso.y + 3, 5, 7), BONE)
	# Thirteen-seal chest chain, kept as readable brass beats.
	for index: int in range(5):
		_pixel(image, torso.x, torso.y + 2 + index * 3, BRASS)
	# Mask and cold sockets.
	_fill(image, Rect2i(torso.x - 6, torso.y - 12, 12, 12), OUTLINE)
	_fill(image, Rect2i(torso.x - 5, torso.y - 11, 10, 10), BONE)
	_fill(image, Rect2i(torso.x - 4, torso.y - 9, 8, 4), BONE_DARK)
	_pixel(image, torso.x - 2, torso.y - 7, SOUL_LIGHT)
	_pixel(image, torso.x + 2, torso.y - 7, SOUL_LIGHT)
	_fill(image, Rect2i(torso.x - 1, torso.y - 4, 3, 3), OUTLINE)
	# Shackled arms and asymmetric grave claws.
	var left_hand: Vector2i = torso + Vector2i(-16, 14)
	var right_hand: Vector2i = torso + Vector2i(17, 13)
	if animation == &"claw_windup": right_hand = torso + Vector2i(10 - frame * 3, 6 - frame)
	if animation == &"claw_active": right_hand = torso + Vector2i(24 + frame * 3, 8)
	if animation == &"lunge_windup":
		left_hand = torso + Vector2i(-11, 5); right_hand = torso + Vector2i(-5, 9)
	if animation == &"lunge_active":
		left_hand = torso + Vector2i(19 + frame * 4, 7); right_hand = torso + Vector2i(25 + frame * 4, 12)
	_draw_segment(image, torso + Vector2i(-9, 7), left_hand, 4, OUTLINE)
	_draw_segment(image, torso + Vector2i(-9, 7), left_hand, 2, METAL)
	_draw_segment(image, torso + Vector2i(9, 7), right_hand, 4, OUTLINE)
	_draw_segment(image, torso + Vector2i(9, 7), right_hand, 2, METAL)
	_draw_claws(image, left_hand, -1, 3)
	_draw_claws(image, right_hand, 1, 4)
	# Split legs keep the silhouette readable.
	var stride: int = 3 if animation == &"walk" and frame < 3 else -3 if animation == &"walk" else 1
	_draw_segment(image, torso + Vector2i(-5, 17), origin + Vector2i(-5 - stride, 0), 6, OUTLINE)
	_draw_segment(image, torso + Vector2i(-5, 17), origin + Vector2i(-5 - stride, 0), 3, BONE_DARK)
	_draw_segment(image, torso + Vector2i(5, 17), origin + Vector2i(6 + stride, 0), 6, OUTLINE)
	_draw_segment(image, torso + Vector2i(5, 17), origin + Vector2i(6 + stride, 0), 3, BONE_DARK)
	_fill(image, Rect2i(origin.x - 12, origin.y - 2, 10, 4), OUTLINE)
	_fill(image, Rect2i(origin.x + 2, origin.y - 2, 11, 4), OUTLINE)
	if animation in [&"rise", &"forced_dissolve"]:
		_draw_seal(image, frame)
	if animation == &"forced_dissolve": _dissolve(image, frame + 1)
	return image


func _draw_husk(animation: StringName, frame: int, count: int) -> Image:
	var image: Image = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	if animation == &"summon_telegraph":
		_draw_seal(image, frame)
		return image
	var progress: float = float(frame) / float(maxi(1, count - 1))
	var origin: Vector2i = Vector2i(29, 54)
	if animation == &"rise": origin.y += roundi((1.0 - progress) * 25.0)
	if animation in [&"idle", &"drift"]: origin.y += roundi(sin(progress * TAU) * 2.0)
	if animation == &"drift": origin.x += [-2, -1, 0, 1, 2, 0][frame]
	if animation in [&"hurt", &"stagger"]: origin.x -= [2, 4, 1, 3][mini(frame, 3)]
	if animation == &"death": origin.y += roundi(progress * 10.0)
	var head: Vector2i = origin + Vector2i(0, -35)
	# Narrow cracked funerary mask.
	_fill(image, Rect2i(head.x - 6, head.y - 7, 12, 15), OUTLINE)
	_fill(image, Rect2i(head.x - 5, head.y - 6, 10, 13), BONE)
	_draw_segment(image, head + Vector2i(-1, -5), head + Vector2i(1, 5), 1, BONE_DARK)
	_fill(image, Rect2i(head.x - 2, head.y, 4, 5), SOUL)
	_pixel(image, head.x, head.y + 2, SOUL_LIGHT)
	# Exposed rib cage and long choir stole with thirteen seal rhythm.
	_fill(image, Rect2i(origin.x - 9, origin.y - 28, 18, 25), OUTLINE)
	_fill(image, Rect2i(origin.x - 7, origin.y - 26, 14, 21), BURGUNDY_DARK)
	for rib: int in range(4):
		_draw_segment(image, origin + Vector2i(-6, -23 + rib * 4), origin + Vector2i(6, -23 + rib * 4), 1, BONE_DARK)
	_fill(image, Rect2i(origin.x - 2, origin.y - 27, 4, 25), BONE_DARK)
	for seal: int in range(6):
		_pixel(image, origin.x, origin.y - 24 + seal * 4, BRASS)
	# Tattered lower vestment.
	for strip: int in range(5):
		var strip_x: int = origin.x - 9 + strip * 4
		var length: int = 10 + ((strip + frame) % 3) * 3
		_fill(image, Rect2i(strip_x, origin.y - 8, 3, length), BURGUNDY if strip % 2 == 0 else BONE_DARK)
	# Broken-chorister arms; aim/shoot reaches forward but remains fragile.
	var left_hand: Vector2i = origin + Vector2i(-15, -14)
	var right_hand: Vector2i = origin + Vector2i(15, -14)
	if animation == &"aim": right_hand = origin + Vector2i(15 + frame * 2, -19)
	if animation == &"shoot":
		right_hand = origin + Vector2i(24, -20); left_hand = origin + Vector2i(17, -14)
	_draw_segment(image, origin + Vector2i(-7, -22), left_hand, 3, OUTLINE)
	_draw_segment(image, origin + Vector2i(-7, -22), left_hand, 1, BONE_DARK)
	_draw_segment(image, origin + Vector2i(7, -22), right_hand, 3, OUTLINE)
	_draw_segment(image, origin + Vector2i(7, -22), right_hand, 1, BONE_DARK)
	_circle(image, origin + Vector2i(0, -27), 3, OUTLINE)
	_circle(image, origin + Vector2i(0, -27), 2, BRASS)
	if animation == &"aim":
		_circle(image, right_hand + Vector2i(7, 0), 2 + frame / 2, Color(SOUL, 0.65))
	if animation == &"shoot":
		var orb: Vector2i = right_hand + Vector2i(7 + frame * 5, 0)
		_circle(image, orb, 4, Color(SOUL, 0.45))
		_circle(image, orb, 2, SOUL_LIGHT)
	if animation in [&"rise", &"forced_dissolve"]: _draw_seal(image, frame)
	if animation == &"forced_dissolve": _dissolve(image, frame + 1)
	return image


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
