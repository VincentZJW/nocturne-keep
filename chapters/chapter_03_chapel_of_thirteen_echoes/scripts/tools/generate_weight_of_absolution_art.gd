extends SceneTree

## Deterministic formal pixel-art authoring for Edran's signature Phase 2 rite.
## Runtime uses the saved PNGs; no procedural geometry remains in the spell scene.

const ROOT: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/"
	+ "thirteenth_pontiff_edran/effects/weight_of_absolution"
)
const QA_PATH: String = (
	"res://docs/qa/chapter_03_weight_of_absolution_art_rework/"
	+ "weight_of_absolution_asset_sheet.png"
)
const CLEAR: Color = Color(0.0, 0.0, 0.0, 0.0)
const VOID: Color = Color("070a14")
const DEEP_BLUE: Color = Color("101a2b")
const SACRED_BLUE: Color = Color("526b83")
const SILVER_DARK: Color = Color("718596")
const SILVER: Color = Color("c6d3db")
const SILVER_LIGHT: Color = Color("edf3f3")
const ANTIQUE_GOLD: Color = Color("9a7b45")
const PALE_GOLD: Color = Color("c3aa6a")
const VIOLET_GREY: Color = Color("625d76")


func _initialize() -> void:
	var failures: int = 0
	for frame: int in range(4):
		failures += _save(_draw_bell(frame), "bell/bell_%02d.png" % (frame + 1))
		failures += _save(_draw_seal(frame), "seal/seal_%02d.png" % (frame + 1))
		failures += _save(_draw_cast_aura(frame), "cast_aura/cast_aura_%02d.png" % (frame + 1))
		failures += _save(_draw_compression(frame), "compression/compression_%02d.png" % (frame + 1))
		failures += _save(_draw_impact(frame), "impact/impact_%02d.png" % (frame + 1))
	failures += _save(_draw_vignette(), "ui/judgment_vignette.png")
	failures += _save_contact_sheet()
	if failures > 0:
		push_error("WEIGHT_OF_ABSOLUTION_ART: FAIL files=%d" % failures)
		quit(1)
		return
	print("WEIGHT_OF_ABSOLUTION_ART: PASS sprites=21 qa=1")
	quit(0)


func _save(image: Image, relative_path: String) -> int:
	var path: String = ROOT.path_join(relative_path)
	var error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(path.get_base_dir())
	)
	if error != OK:
		return 1
	return 0 if image.save_png(ProjectSettings.globalize_path(path)) == OK else 1


func _draw_bell(frame: int) -> Image:
	var image: Image = _canvas(Vector2i(128, 128))
	var pulse: int = frame % 2
	# Reliquary crown and suspension eye.
	_ring(image, Vector2i(64, 13), 9, 5, VOID, ANTIQUE_GOLD)
	_line(image, Vector2i(56, 17), Vector2i(48, 28), 5, VOID)
	_line(image, Vector2i(72, 17), Vector2i(80, 28), 5, VOID)
	_line(image, Vector2i(56, 17), Vector2i(48, 28), 2, PALE_GOLD)
	_line(image, Vector2i(72, 17), Vector2i(80, 28), 2, PALE_GOLD)
	# Bell body: hand-shaped horizontal slices, thick lip and cold metal planes.
	for y: int in range(24, 91):
		var t: float = float(y - 24) / 66.0
		var half_width: int = 16 + roundi(pow(t, 0.78) * 31.0)
		var left: int = 64 - half_width
		var right: int = 64 + half_width
		_fill(image, Rect2i(left, y, right - left + 1, 1), VOID)
		if y > 27 and y < 87:
			_fill(image, Rect2i(left + 3, y, half_width - 2, 1), DEEP_BLUE)
			_fill(image, Rect2i(64, y, half_width - 3, 1), Color("27384b"))
			if y % 7 in [0, 1]:
				_pixel(image, left + 6, y, SACRED_BLUE)
				_pixel(image, right - 5, y, SILVER_DARK)
	# Crown ridges and gothic shoulder ribs.
	_line(image, Vector2i(48, 28), Vector2i(80, 28), 4, ANTIQUE_GOLD)
	_line(image, Vector2i(43, 38), Vector2i(85, 38), 2, SILVER_DARK)
	_line(image, Vector2i(36, 55), Vector2i(92, 55), 3, ANTIQUE_GOLD)
	_line(image, Vector2i(30, 73), Vector2i(98, 73), 2, SILVER_DARK)
	for rib: int in range(7):
		var x: int = 40 + rib * 8
		_line(image, Vector2i(x, 40), Vector2i(x - 3 + rib, 70), 1, SACRED_BLUE)
	# Thirteen pointed chapel seals around the waist band.
	for mark: int in range(13):
		var x: int = 28 + mark * 6
		var y: int = 77 + (mark % 2)
		_pointed_glyph(image, Vector2i(x, y), ANTIQUE_GOLD if mark != 6 else SILVER_LIGHT)
	# Central judgment relief: closed eye beneath a three-pronged mitre.
	_line(image, Vector2i(51, 49), Vector2i(64, 42), 2, PALE_GOLD)
	_line(image, Vector2i(64, 42), Vector2i(77, 49), 2, PALE_GOLD)
	_line(image, Vector2i(51, 49), Vector2i(77, 49), 2, PALE_GOLD)
	_ring(image, Vector2i(64, 59), 7, 3, VOID, SILVER)
	_line(image, Vector2i(58, 59), Vector2i(70, 59), 2, SILVER_LIGHT)
	# Age cracks and engraved count lines.
	_line(image, Vector2i(45, 58), Vector2i(40, 66), 1, VIOLET_GREY)
	_line(image, Vector2i(40, 66), Vector2i(44, 71), 1, VIOLET_GREY)
	_line(image, Vector2i(82, 45), Vector2i(87, 52), 1, VIOLET_GREY)
	_line(image, Vector2i(87, 52), Vector2i(84, 61), 1, VIOLET_GREY)
	# Heavy stepped lip and hanging clapper.
	_fill(image, Rect2i(19, 88, 90, 5), VOID)
	_fill(image, Rect2i(22, 89, 84, 4), ANTIQUE_GOLD)
	_fill(image, Rect2i(27, 93, 74, 5), VOID)
	_fill(image, Rect2i(31, 93, 66, 3), SILVER_DARK)
	_line(image, Vector2i(64, 91), Vector2i(64, 108), 3, VOID)
	_line(image, Vector2i(64, 93), Vector2i(64, 106), 1, PALE_GOLD)
	_ring(image, Vector2i(64, 112), 8 + pulse, 4, VOID, ANTIQUE_GOLD)
	_pixel(image, 62, 109, SILVER_LIGHT)
	# Cold inner glow is inset, never a neon outer blob.
	_line(image, Vector2i(35, 86), Vector2i(93, 86), 1, Color(SILVER_LIGHT, 0.75))
	for spark: int in range(5):
		var sx: int = 44 + spark * 10
		var sy: int = 102 + ((spark + frame) % 3) * 4
		_pixel(image, sx, sy, Color(SILVER_LIGHT, 0.75))
	return image


func _draw_seal(frame: int) -> Image:
	var image: Image = _canvas(Vector2i(160, 96))
	var center: Vector2i = Vector2i(80, 48)
	# Three architecturally different rings, not a stack of identical circles.
	_ellipse_outline(image, center, Vector2i(72, 35), 3, VOID)
	_ellipse_outline(image, center, Vector2i(69, 32), 2, ANTIQUE_GOLD)
	_ellipse_outline(image, center, Vector2i(58, 27), 2, SACRED_BLUE)
	_ellipse_outline(image, center, Vector2i(42, 20), 2, SILVER_DARK)
	# Thirteen chapels, radial spokes and alternating verdict marks.
	for sector: int in range(13):
		var angle: float = -PI * 0.5 + TAU * float(sector) / 13.0
		var inner: Vector2i = center + Vector2i(
			roundi(cos(angle) * 43.0), roundi(sin(angle) * 20.0)
		)
		var outer: Vector2i = center + Vector2i(
			roundi(cos(angle) * 67.0), roundi(sin(angle) * 31.0)
		)
		_line(image, inner, outer, 1, VIOLET_GREY)
		var glyph: Vector2i = center + Vector2i(
			roundi(cos(angle) * 54.0), roundi(sin(angle) * 25.0)
		)
		_pointed_glyph(
			image,
			glyph,
			SILVER_LIGHT if sector == (frame * 3) % 13 else ANTIQUE_GOLD
		)
	# Central absolution seal: closed bell, scales and descending verdict blade.
	_diamond(image, center, Vector2i(20, 13), VOID, SACRED_BLUE)
	_diamond(image, center, Vector2i(14, 9), DEEP_BLUE, SILVER)
	_line(image, Vector2i(80, 33), Vector2i(80, 63), 3, ANTIQUE_GOLD)
	_line(image, Vector2i(64, 42), Vector2i(96, 42), 2, SILVER)
	_line(image, Vector2i(68, 42), Vector2i(63, 52), 1, PALE_GOLD)
	_line(image, Vector2i(92, 42), Vector2i(97, 52), 1, PALE_GOLD)
	_ring(image, Vector2i(63, 54), 5, 2, VOID, SACRED_BLUE)
	_ring(image, Vector2i(97, 54), 5, 2, VOID, SACRED_BLUE)
	_line(image, Vector2i(73, 62), Vector2i(87, 62), 2, SILVER_LIGHT)
	# Liturgical script blocks follow the ellipse and visibly count to thirteen.
	for rune: int in range(13):
		var x: int = 21 + rune * 9
		var y: int = 18 if rune % 2 == 0 else 77
		_fill(image, Rect2i(x, y, 4, 2), PALE_GOLD)
		_pixel(image, x + 1, y + (-2 if y > 48 else 3), SILVER_DARK)
	return image


func _draw_cast_aura(frame: int) -> Image:
	var image: Image = _canvas(Vector2i(128, 128))
	var center: Vector2i = Vector2i(64, 61)
	# Pointed apse halo with thirteen falling votive shards.
	_line(image, Vector2i(34, 80), Vector2i(34, 43), 3, SILVER_DARK)
	_line(image, Vector2i(34, 43), Vector2i(64, 15), 3, PALE_GOLD)
	_line(image, Vector2i(64, 15), Vector2i(94, 43), 3, PALE_GOLD)
	_line(image, Vector2i(94, 43), Vector2i(94, 80), 3, SILVER_DARK)
	_ellipse_outline(image, center, Vector2i(24, 31), 2, SACRED_BLUE)
	for shard: int in range(13):
		var angle: float = TAU * float(shard) / 13.0
		var radius_x: float = 43.0
		var radius_y: float = 47.0
		var p: Vector2i = center + Vector2i(
			roundi(cos(angle) * radius_x),
			roundi(sin(angle) * radius_y) + ((shard + frame) % 3)
		)
		_fill(image, Rect2i(p.x - 1, p.y - 2, 3, 5), Color(SILVER, 0.82))
		_pixel(image, p.x, p.y + 3, Color(PALE_GOLD, 0.72))
	# Crozier focus sigil.
	_ring(image, center, 11 + (frame % 2), 4, VOID, ANTIQUE_GOLD)
	_pointed_glyph(image, center + Vector2i(0, -14), SILVER_LIGHT)
	_line(image, center + Vector2i(0, 11), center + Vector2i(0, 30), 2, SILVER)
	return image


func _draw_compression(frame: int) -> Image:
	var image: Image = _canvas(Vector2i(128, 160))
	# Architectural pressure ribs converge toward the target rather than reading as lasers.
	for rib: int in range(7):
		var top_x: int = 18 + rib * 15
		var end_x: int = 49 + rib * 5
		var top_y: int = 10 + ((rib + frame) % 3) * 5
		_line(image, Vector2i(top_x, top_y), Vector2i(end_x, 142), 5, Color(VOID, 0.72))
		_line(image, Vector2i(top_x + 1, top_y), Vector2i(end_x + 1, 140), 2, Color(VIOLET_GREY, 0.66))
	# Falling script fragments and compressed gothic arches.
	for mark: int in range(13):
		var x: int = 12 + (mark * 29) % 106
		var y: int = 15 + (mark * 17 + frame * 7) % 128
		_fill(image, Rect2i(x, y, 3, 6), Color(SILVER_DARK, 0.75))
		_pixel(image, x + 1, y + 7, Color(PALE_GOLD, 0.70))
	_line(image, Vector2i(29, 137), Vector2i(42, 124), 2, SACRED_BLUE)
	_line(image, Vector2i(42, 124), Vector2i(55, 137), 2, SACRED_BLUE)
	_line(image, Vector2i(73, 137), Vector2i(86, 124), 2, SACRED_BLUE)
	_line(image, Vector2i(86, 124), Vector2i(99, 137), 2, SACRED_BLUE)
	return image


func _draw_impact(frame: int) -> Image:
	var image: Image = _canvas(Vector2i(160, 144))
	var center: Vector2i = Vector2i(80, 78)
	var extent: int = 58 - frame * 7
	# Final judgment is a closing reliquary: upper bell ribs and lower seal jaws meet.
	for side: int in [-1, 1]:
		_line(
			image,
			Vector2i(80 + side * extent, 18 + frame * 8),
			Vector2i(80 + side * 18, 68),
			5,
			VOID
		)
		_line(
			image,
			Vector2i(80 + side * extent, 18 + frame * 8),
			Vector2i(80 + side * 18, 68),
			2,
			SILVER
		)
		_line(
			image,
			Vector2i(80 + side * extent, 127 - frame * 6),
			Vector2i(80 + side * 18, 88),
			3,
			ANTIQUE_GOLD
		)
	_diamond(image, center, Vector2i(20 + frame * 2, 13 + frame), VOID, SACRED_BLUE)
	_ring(image, center, 13 + frame * 2, 5, DEEP_BLUE, SILVER_LIGHT)
	_line(image, Vector2i(80, 21 + frame * 8), Vector2i(80, 121 - frame * 6), 4, PALE_GOLD)
	for shard: int in range(13):
		var angle: float = TAU * float(shard) / 13.0
		var p: Vector2i = center + Vector2i(
			roundi(cos(angle) * (27.0 + frame * 5.0)),
			roundi(sin(angle) * (19.0 + frame * 3.0))
		)
		_pointed_glyph(image, p, SILVER if shard % 2 == 0 else PALE_GOLD)
	return image


func _draw_vignette() -> Image:
	var image: Image = _canvas(Vector2i(320, 180))
	for y: int in range(180):
		for x: int in range(320):
			var nx: float = absf(float(x) - 159.5) / 159.5
			var ny: float = absf(float(y) - 89.5) / 89.5
			var edge: float = clampf(maxf(nx, ny) - 0.54, 0.0, 0.46) / 0.46
			if edge > 0.0:
				image.set_pixel(x, y, Color(0.025, 0.035, 0.075, edge * edge * 0.86))
	# Gothic corner tracery prevents the overlay reading as a generic vignette.
	for corner_x: int in [0, 319]:
		var direction: int = 1 if corner_x == 0 else -1
		for offset: int in range(0, 54, 6):
			_line(
				image,
				Vector2i(corner_x + direction * offset, 0),
				Vector2i(corner_x, offset),
				1,
				Color(ANTIQUE_GOLD, 0.22)
			)
	return image


func _save_contact_sheet() -> int:
	var sheet: Image = Image.create(1600, 900, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("090c15"))
	var sources: Array[Image] = [
		_draw_bell(3), _draw_seal(3), _draw_cast_aura(3),
		_draw_compression(3), _draw_impact(3), _draw_vignette(),
	]
	var origins: Array[Vector2i] = [
		Vector2i(30, 70), Vector2i(420, 90), Vector2i(900, 70),
		Vector2i(40, 480), Vector2i(500, 470), Vector2i(1010, 500),
	]
	var scales: Array[int] = [3, 3, 3, 3, 3, 1]
	for index: int in range(sources.size()):
		var source: Image = sources[index].duplicate()
		source.resize(
			source.get_width() * scales[index],
			source.get_height() * scales[index],
			Image.INTERPOLATE_NEAREST
		)
		sheet.blend_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), origins[index])
	# Formal palette strip.
	var palette: Array[Color] = [
		VOID, DEEP_BLUE, SACRED_BLUE, SILVER_DARK, SILVER, SILVER_LIGHT,
		ANTIQUE_GOLD, PALE_GOLD, VIOLET_GREY,
	]
	for index: int in range(palette.size()):
		_fill(sheet, Rect2i(1040 + index * 52, 405, 44, 30), palette[index])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_PATH.get_base_dir()))
	return 0 if sheet.save_png(ProjectSettings.globalize_path(QA_PATH)) == OK else 1


func _canvas(size: Vector2i) -> Image:
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	return image


func _pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
		image.set_pixel(x, y, color)


func _fill(image: Image, rect: Rect2i, color: Color) -> void:
	image.fill_rect(rect.intersection(Rect2i(Vector2i.ZERO, image.get_size())), color)


func _line(image: Image, start: Vector2i, finish: Vector2i, thickness: int, color: Color) -> void:
	var distance: int = maxi(abs(finish.x - start.x), abs(finish.y - start.y))
	if distance == 0:
		_fill(image, Rect2i(start - Vector2i(thickness / 2, thickness / 2), Vector2i(thickness, thickness)), color)
		return
	for step: int in range(distance + 1):
		var ratio: float = float(step) / float(distance)
		var point: Vector2i = Vector2(start).lerp(Vector2(finish), ratio).round()
		_fill(
			image,
			Rect2i(point - Vector2i(thickness / 2, thickness / 2), Vector2i(thickness, thickness)),
			color
		)


func _ring(image: Image, center: Vector2i, radius: int, thickness: int, fill_color: Color, edge_color: Color) -> void:
	for y: int in range(-radius, radius + 1):
		for x: int in range(-radius, radius + 1):
			var distance_squared: int = x * x + y * y
			if distance_squared <= radius * radius:
				var color: Color = edge_color if distance_squared >= (radius - thickness) * (radius - thickness) else fill_color
				_pixel(image, center.x + x, center.y + y, color)


func _ellipse_outline(image: Image, center: Vector2i, radius: Vector2i, thickness: int, color: Color) -> void:
	for degree: int in range(360):
		var angle: float = deg_to_rad(float(degree))
		var point: Vector2i = center + Vector2i(
			roundi(cos(angle) * radius.x), roundi(sin(angle) * radius.y)
		)
		_fill(image, Rect2i(point - Vector2i(thickness / 2, thickness / 2), Vector2i(thickness, thickness)), color)


func _pointed_glyph(image: Image, center: Vector2i, color: Color) -> void:
	_line(image, center + Vector2i(-2, 2), center + Vector2i(0, -3), 1, color)
	_line(image, center + Vector2i(0, -3), center + Vector2i(2, 2), 1, color)
	_line(image, center + Vector2i(-2, 2), center + Vector2i(2, 2), 1, color)
	_pixel(image, center.x, center.y + 4, color)


func _diamond(image: Image, center: Vector2i, radius: Vector2i, fill_color: Color, edge_color: Color) -> void:
	for y: int in range(-radius.y, radius.y + 1):
		var width: int = roundi(float(radius.x) * (1.0 - absf(float(y)) / float(radius.y + 1)))
		for x: int in range(-width, width + 1):
			var edge: bool = abs(x) >= width - 1 or abs(y) >= radius.y - 1
			_pixel(image, center.x + x, center.y + y, edge_color if edge else fill_color)
