extends SceneTree

## Deterministic low-resolution production art for Edran's three chapel rites.
## Runtime visuals are authored on their native pixel canvas and never downscaled.

const CHAPTER: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const BOSS_ROOT: String = CHAPTER + "/assets/bosses/thirteenth_pontiff_edran"
const EFFECT_ROOT: String = BOSS_ROOT + "/effects"
const SHARED_STATUS_ROOT: String = "res://shared/assets/status_effects"
const CLEAR: Color = Color(0, 0, 0, 0)
const OUTLINE: Color = Color("090a12")
const BONE: Color = Color("d5ccba")
const STEEL: Color = Color("9cb3c1")
const FIRE_DARK: Color = Color("6e1f29")
const FIRE: Color = Color("c34d31")
const EMBER: Color = Color("e99b55")
const ASH: Color = Color("b8afa5")
const ICE_DARK: Color = Color("31546b")
const ICE: Color = Color("73a9bd")
const FROST: Color = Color("d5edf0")
const MIRE_DARK: Color = Color("352f24")
const MIRE: Color = Color("5b5940")
const MIRE_LIT: Color = Color("817653")
const PRAYER_GOLD: Color = Color("b09255")

const BOSS_MAGIC_ANIMATIONS: Dictionary[StringName, int] = {
	&"fire_spell_windup": 4,
	&"fire_spell_release": 3,
	&"fire_spell_recovery": 3,
	&"ice_spell_windup": 4,
	&"ice_spell_release": 3,
	&"ice_spell_recovery": 3,
	&"mire_spell_windup": 4,
	&"mire_spell_target_lock": 3,
	&"mire_spell_activate": 3,
	&"mire_spell_recovery": 3,
}

const FX_ANIMATIONS: Dictionary[String, Dictionary] = {
	"fire/fireball": {"size": Vector2i(48, 24), "frames": 4},
	"fire/impact": {"size": Vector2i(48, 48), "frames": 4},
	"fire/cast_circle": {"size": Vector2i(64, 64), "frames": 4},
	"ice/ice_lance": {"size": Vector2i(56, 24), "frames": 4},
	"ice/impact": {"size": Vector2i(48, 48), "frames": 4},
	"ice/cast_circle": {"size": Vector2i(64, 64), "frames": 4},
	"mire/summon_circle": {"size": Vector2i(224, 56), "frames": 4},
	"mire/mire_zone": {"size": Vector2i(224, 56), "frames": 4},
	"mire/disappear": {"size": Vector2i(224, 56), "frames": 4},
}

const STATUS_ANIMATIONS: Dictionary[String, Dictionary] = {
	"burn": {"size": Vector2i(64, 64), "frames": 5},
	"freeze": {"size": Vector2i(64, 64), "frames": 5},
	"mire": {"size": Vector2i(64, 64), "frames": 4},
}
const STATUS_EXIT_ANIMATIONS: Dictionary[String, Dictionary] = {
	"burn": {"animation": "extinguish", "frames": 4},
	"freeze": {"animation": "shatter", "frames": 4},
	"mire": {"animation": "fade", "frames": 4},
}


func _initialize() -> void:
	var saved: int = 0
	for phase: int in [1, 2]:
		var root: String = "%s/magic_phase_%02d" % [BOSS_ROOT, phase]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(root))
		for animation: StringName in BOSS_MAGIC_ANIMATIONS:
			var directory: String = "%s/%s" % [root, animation]
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
			var count: int = BOSS_MAGIC_ANIMATIONS[animation]
			for frame: int in range(count):
				var boss_image: Image = _draw_boss_magic_frame(phase, animation, frame, count)
				_save(boss_image, "%s/%s_%02d.png" % [directory, animation, frame + 1])
				saved += 1
	for relative_path: String in FX_ANIMATIONS:
		var spec: Dictionary = FX_ANIMATIONS[relative_path]
		var directory: String = "%s/%s" % [EFFECT_ROOT, relative_path]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		for frame: int in range(int(spec.frames)):
			_save(
				_draw_effect(relative_path, frame, int(spec.frames), spec.size as Vector2i),
				"%s/%s_%02d.png" % [directory, relative_path.get_file(), frame + 1]
			)
			saved += 1
	for effect_id: String in STATUS_ANIMATIONS:
		var status_spec: Dictionary = STATUS_ANIMATIONS[effect_id]
		var status_dir: String = "%s/%s" % [SHARED_STATUS_ROOT, effect_id]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(status_dir))
		for frame: int in range(int(status_spec.frames)):
			_save(
				_draw_status(effect_id, frame, int(status_spec.frames), status_spec.size as Vector2i),
				"%s/%s_%02d.png" % [status_dir, effect_id, frame + 1]
			)
			saved += 1
		var exit_spec: Dictionary = STATUS_EXIT_ANIMATIONS[effect_id]
		var exit_name: String = exit_spec.animation as String
		for frame: int in range(int(exit_spec.frames)):
			_save(
				_draw_status_exit(effect_id, frame, int(exit_spec.frames), status_spec.size as Vector2i),
				"%s/%s_%02d.png" % [status_dir, exit_name, frame + 1]
			)
			saved += 1
		_save(_draw_status_icon(effect_id), "%s/%s_icon.png" % [status_dir, effect_id])
		saved += 1
	_write_concept_board()
	print("EDRAN_ELEMENTAL_MAGIC_ART | PASS files=%d original_pixel=true" % saved)
	quit(0)


func _draw_boss_magic_frame(phase: int, animation: StringName, frame: int, count: int) -> Image:
	var source_path: String = (
		BOSS_ROOT + "/previews/edran_phase_01_sprite_master.png"
		if phase == 1 else BOSS_ROOT + "/previews/edran_phase_02_sprite_master.png"
	)
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(source_path))
	if image == null or image.is_empty():
		image = Image.create(96, 96, false, Image.FORMAT_RGBA8)
		image.fill(CLEAR)
	var progress: float = float(frame + 1) / float(count)
	var center: Vector2i = Vector2i(49, 39)
	if animation.begins_with("fire_"):
		_draw_prayer_ring(image, center + Vector2i(18, -3), 7 + roundi(progress * 5.0), FIRE, EMBER)
		_draw_flame(image, center + Vector2i(18, -4), 6 + frame, frame)
	elif animation.begins_with("ice_"):
		_draw_prayer_ring(image, center + Vector2i(-16, 0), 7 + roundi(progress * 4.0), ICE, FROST)
		_draw_ice_lance(image, center + Vector2i(-25, -1), 18 + frame * 3)
	else:
		_draw_mire_glyph(image, Vector2i(48, 82), 20 + roundi(progress * 15.0), frame)
		_line(image, Vector2i(33, 48), Vector2i(48, 76), 2, MIRE_LIT)
	return image


func _draw_effect(kind: String, frame: int, count: int, size: Vector2i) -> Image:
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var center: Vector2i = size / 2
	var progress: float = float(frame + 1) / float(count)
	if kind == "fire/fireball":
		_draw_flame(image, center + Vector2i(6, 0), 9 + frame, frame)
		for trail: int in range(4):
			_fill(image, Rect2i(5 + trail * 5, center.y - 2 + (trail + frame) % 3, 5, 3), FIRE_DARK if trail < 2 else FIRE)
	elif kind == "fire/impact":
		for ray: int in range(10):
			var angle: float = TAU * float(ray) / 10.0
			var length: int = 7 + roundi(progress * 15.0)
			_line(image, center, center + Vector2i(roundi(cos(angle) * length), roundi(sin(angle) * length)), 2, EMBER if ray % 2 == 0 else FIRE)
		_draw_prayer_ring(image, center, 5 + frame * 3, FIRE_DARK, ASH)
	elif kind == "fire/cast_circle":
		_draw_prayer_ring(image, center, 12 + frame * 3, FIRE_DARK, EMBER)
	elif kind == "ice/ice_lance":
		_draw_ice_lance(image, Vector2i(4, center.y), 42 + frame * 2)
	elif kind == "ice/impact":
		for shard: int in range(9):
			var sx: int = center.x - 20 + shard * 5
			var sy: int = center.y + 15 - ((shard * 7 + frame * 3) % 24)
			_poly(image, [Vector2i(sx, sy + 5), Vector2i(sx + 2, sy - 4), Vector2i(sx + 5, sy + 4)], ICE if shard % 2 == 0 else FROST)
	elif kind == "ice/cast_circle":
		_draw_prayer_ring(image, center, 11 + frame * 3, ICE_DARK, FROST)
		for shard: int in range(6):
			var angle: float = TAU * float(shard) / 6.0
			_fill(image, Rect2i(center + Vector2i(roundi(cos(angle) * 21.0), roundi(sin(angle) * 21.0)) - Vector2i.ONE, Vector2i(3, 3)), ICE)
	elif kind == "mire/summon_circle":
		_draw_mire_glyph(image, center, 42 + frame * 18, frame)
	elif kind == "mire/mire_zone":
		_draw_mire_pool(image, frame, false)
	else:
		_draw_mire_pool(image, frame, true)
	return image


func _draw_status(effect_id: String, frame: int, count: int, size: Vector2i) -> Image:
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	if effect_id == "burn":
		for flame_index: int in range(6):
			var x: int = 18 + flame_index * 6
			var y: int = 52 - ((flame_index * 5 + frame * 3) % 13)
			_draw_flame(image, Vector2i(x, y), 4 + (flame_index + frame) % 4, frame + flame_index)
		for spark: int in range(5):
			_pixel(image, 16 + (spark * 11 + frame * 3) % 34, 18 + (spark * 7 + frame * 5) % 27, ASH)
	elif effect_id == "freeze":
		var pulse: int = frame % 3
		_poly(image, [Vector2i(20, 56), Vector2i(13, 42), Vector2i(18, 18), Vector2i(28, 8), Vector2i(38, 12), Vector2i(49, 28), Vector2i(51, 50), Vector2i(43, 58)], Color(ICE.r, ICE.g, ICE.b, 0.58))
		_line(image, Vector2i(28, 10), Vector2i(24 + pulse, 47), 2, FROST)
		_line(image, Vector2i(25 + pulse, 32), Vector2i(43, 20), 1, ICE_DARK)
		_line(image, Vector2i(25, 39), Vector2i(43 - pulse, 51), 1, FROST)
	else:
		for blob: int in range(8):
			var bx: int = 9 + blob * 6
			var by: int = 54 - ((blob + frame) % 3)
			_fill(image, Rect2i(bx, by, 7, 4), MIRE if blob % 2 == 0 else MIRE_LIT)
			if blob % 3 == frame % 3:
				_circle(image, Vector2i(bx + 3, by - 4), 2, Color(MIRE_LIT.r, MIRE_LIT.g, MIRE_LIT.b, 0.75))
	return image


func _draw_status_exit(effect_id: String, frame: int, count: int, size: Vector2i) -> Image:
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var progress: float = float(frame + 1) / float(count)
	if effect_id == "burn":
		for ember: int in range(9 - frame * 2):
			var x: int = 12 + (ember * 7 + frame * 3) % 42
			var y: int = 52 - frame * 6 - (ember * 5) % 17
			_fill(image, Rect2i(x, y, 2, 2), Color(ASH.r, ASH.g, ASH.b, 1.0 - progress * 0.65))
	elif effect_id == "freeze":
		for shard: int in range(12):
			var direction: int = -1 if shard % 2 == 0 else 1
			var sx: int = 32 + direction * (4 + (shard % 6) * (frame + 2))
			var sy: int = 48 - (shard * 7) % 31 + frame * 3
			var shard_size: int = maxi(1, 4 - frame)
			_poly(image, [
				Vector2i(sx, sy + shard_size * 2),
				Vector2i(sx + shard_size, sy - shard_size),
				Vector2i(sx + shard_size * 2, sy + shard_size * 2),
			], Color(FROST.r, FROST.g, FROST.b, 1.0 - progress * 0.45))
	else:
		for drop: int in range(10 - frame * 2):
			var dx: int = 8 + (drop * 7 + frame * 5) % 48
			var dy: int = 53 + (drop + frame) % 4
			_fill(image, Rect2i(dx, dy, maxi(1, 5 - frame), 2), Color(MIRE.r, MIRE.g, MIRE.b, 1.0 - progress * 0.7))
	return image


func _draw_status_icon(effect_id: String) -> Image:
	var image: Image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	if effect_id == "burn":
		_draw_flame(image, Vector2i(8, 10), 7, 1)
	elif effect_id == "freeze":
		_line(image, Vector2i(8, 2), Vector2i(8, 13), 2, FROST)
		_line(image, Vector2i(3, 5), Vector2i(13, 11), 2, ICE)
		_line(image, Vector2i(13, 5), Vector2i(3, 11), 2, ICE)
	else:
		_fill(image, Rect2i(2, 9, 12, 4), MIRE)
		_circle(image, Vector2i(5, 7), 2, MIRE_LIT)
		_circle(image, Vector2i(11, 6), 2, MIRE_LIT)
	return image


func _write_concept_board() -> void:
	var board: Image = Image.create(1440, 720, false, Image.FORMAT_RGBA8)
	board.fill(Color("0c0d15"))
	for panel: int in range(3):
		var left: int = 45 + panel * 465
		_fill(board, Rect2i(left, 55, 420, 610), Color("171925"))
		var accent: Color = FIRE if panel == 0 else ICE if panel == 1 else MIRE_LIT
		_fill(board, Rect2i(left, 55, 420, 5), accent)
		var relative: String = "fire/fireball" if panel == 0 else "ice/ice_lance" if panel == 1 else "mire/mire_zone"
		var spec: Dictionary = FX_ANIMATIONS[relative]
		var effect: Image = _draw_effect(relative, 2, int(spec.frames), spec.size as Vector2i)
		board.blit_rect(effect, effect.get_used_rect(), Vector2i(left + 95, 235))
		for row: int in range(13):
			_fill(board, Rect2i(left + 34 + (row % 7) * 51, 510 + (row / 7) * 28, 28, 5), accent.darkened(float(row % 3) * 0.12))
	_save(board, BOSS_ROOT + "/concept_art/edran_elemental_rites_concept_board.png")


func _draw_flame(image: Image, center: Vector2i, radius: int, frame: int) -> void:
	_poly(image, [center + Vector2i(-radius / 2, radius / 2), center + Vector2i(-radius / 3, -radius / 3), center + Vector2i((frame % 3) - 2, -radius), center + Vector2i(radius / 2, -radius / 3), center + Vector2i(radius / 2, radius / 2)], OUTLINE)
	_poly(image, [center + Vector2i(-radius / 3, radius / 3), center + Vector2i(-1, -radius + 2), center + Vector2i(radius / 3, radius / 3)], FIRE)
	_fill(image, Rect2i(center.x - 2, center.y, 5, maxi(2, radius / 3)), EMBER)


func _draw_ice_lance(image: Image, origin: Vector2i, length: int) -> void:
	_poly(image, [origin, origin + Vector2i(length - 6, -6), origin + Vector2i(length, 0), origin + Vector2i(length - 6, 6)], OUTLINE)
	_poly(image, [origin + Vector2i(3, 0), origin + Vector2i(length - 8, -4), origin + Vector2i(length - 2, 0), origin + Vector2i(length - 8, 3)], ICE)
	_line(image, origin + Vector2i(5, -1), origin + Vector2i(length - 7, -2), 1, FROST)


func _draw_prayer_ring(image: Image, center: Vector2i, radius: int, dark: Color, light: Color) -> void:
	_circle_outline(image, center, radius, dark)
	for mark: int in range(13):
		var angle: float = TAU * float(mark) / 13.0
		var point: Vector2i = center + Vector2i(roundi(cos(angle) * radius), roundi(sin(angle) * radius))
		_fill(image, Rect2i(point - Vector2i.ONE, Vector2i(3, 3)), light if mark % 3 == 0 else dark)


func _draw_mire_glyph(image: Image, center: Vector2i, radius: int, frame: int) -> void:
	var rx: int = radius
	var ry: int = maxi(5, radius / 4)
	for step: int in range(48):
		var angle: float = TAU * float(step) / 48.0
		var p: Vector2i = center + Vector2i(roundi(cos(angle) * rx), roundi(sin(angle) * ry))
		_pixel(image, p.x, p.y, MIRE_LIT if (step + frame) % 4 == 0 else MIRE)
	for root: int in range(7):
		_line(image, center + Vector2i(-radius + root * radius / 3, 0), center + Vector2i(-radius + root * radius / 3 + (root % 2) * 9, 8), 1, MIRE_DARK)


func _draw_mire_pool(image: Image, frame: int, disappearing: bool) -> void:
	var inset: int = frame * 18 if disappearing else 0
	var rect: Rect2i = Rect2i(8 + inset, 18 + frame % 2, image.get_width() - 16 - inset * 2, 27 - frame % 2)
	if rect.size.x <= 0:
		return
	_fill(image, rect, Color(MIRE_DARK.r, MIRE_DARK.g, MIRE_DARK.b, 0.86))
	_fill(image, Rect2i(rect.position + Vector2i(3, 5), rect.size - Vector2i(6, 10)), Color(MIRE.r, MIRE.g, MIRE.b, 0.82))
	for bubble: int in range(11):
		var bx: int = rect.position.x + 8 + (bubble * 19 + frame * 7) % maxi(10, rect.size.x - 16)
		var by: int = rect.position.y + 5 + (bubble * 5 + frame * 3) % maxi(5, rect.size.y - 10)
		_circle_outline(image, Vector2i(bx, by), 2 + bubble % 2, MIRE_LIT)


func _save(image: Image, path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	if image.save_png(ProjectSettings.globalize_path(path)) != OK:
		push_error("Unable to save elemental magic art: %s" % path)


func _fill(image: Image, rect: Rect2i, color: Color) -> void:
	image.fill_rect(rect.intersection(Rect2i(Vector2i.ZERO, image.get_size())), color)


func _pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
		image.set_pixel(x, y, color)


func _line(image: Image, from: Vector2i, to: Vector2i, width: int, color: Color) -> void:
	var points: int = maxi(abs(to.x - from.x), abs(to.y - from.y))
	for index: int in range(points + 1):
		var point: Vector2i = Vector2(from).lerp(Vector2(to), float(index) / float(maxi(1, points))).round()
		_fill(image, Rect2i(point - Vector2i(width / 2, width / 2), Vector2i(width, width)), color)


func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	if points.size() < 3:
		return
	var min_y: int = image.get_height() - 1
	var max_y: int = 0
	for point: Vector2i in points:
		min_y = mini(min_y, point.y)
		max_y = maxi(max_y, point.y)
	for y: int in range(maxi(0, min_y), mini(image.get_height() - 1, max_y) + 1):
		var intersections: Array[int] = []
		for index: int in range(points.size()):
			var a: Vector2i = points[index]
			var b: Vector2i = points[(index + 1) % points.size()]
			if (a.y <= y and b.y > y) or (b.y <= y and a.y > y):
				intersections.append(roundi(float(a.x) + float(y - a.y) * float(b.x - a.x) / float(b.y - a.y)))
		intersections.sort()
		for index: int in range(0, intersections.size() - 1, 2):
			_fill(image, Rect2i(intersections[index], y, intersections[index + 1] - intersections[index] + 1, 1), color)


func _circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y: int in range(-radius, radius + 1):
		for x: int in range(-radius, radius + 1):
			if x * x + y * y <= radius * radius:
				_pixel(image, center.x + x, center.y + y, color)


func _circle_outline(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for step: int in range(maxi(16, radius * 5)):
		var angle: float = TAU * float(step) / float(maxi(16, radius * 5))
		_pixel(image, center.x + roundi(cos(angle) * radius), center.y + roundi(sin(angle) * radius), color)
