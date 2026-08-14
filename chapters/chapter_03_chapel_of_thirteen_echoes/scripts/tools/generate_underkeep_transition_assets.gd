extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/water_transition"
const CH4_ROOT: String = "res://chapters/chapter_04_drowned_underkeep/assets/environment/threshold"

const VOID: Color = Color("050b12")
const STONE_0: Color = Color("111923")
const STONE_1: Color = Color("1a2732")
const STONE_2: Color = Color("263744")
const STONE_3: Color = Color("38505c")
const STONE_WET: Color = Color("1b4249")
const WATER_0: Color = Color("061b29")
const WATER_1: Color = Color("0b3040")
const WATER_2: Color = Color("155064")
const WATER_3: Color = Color("3c8494")
const IRON_0: Color = Color("1b2026")
const IRON_1: Color = Color("394149")
const RUST_0: Color = Color("55362f")
const RUST_1: Color = Color("8a5c43")
const BONE_0: Color = Color("8d8b7d")
const BONE_1: Color = Color("c1bda8")
const COLD_LIGHT: Color = Color("73adba")


func _init() -> void:
	var failures: int = 0
	failures += _save(_draw_backdrop(), ROOT + "/underkeep_descent_backdrop_v2.png")
	failures += _save(_draw_water_bed(), ROOT + "/water/water_bed/water_bed_2304x108.png")
	for frame: int in range(4):
		failures += _save(_draw_water_body(frame), ROOT + "/water/water_body/water_body_%02d.png" % (frame + 1))
		failures += _save(_draw_highlights(frame), ROOT + "/water/highlights/highlight_%02d.png" % (frame + 1))
	for frame: int in range(6):
		failures += _save(_draw_surface(frame, false), ROOT + "/water/water_surface/surface_back_%02d.png" % (frame + 1))
		failures += _save(_draw_surface(frame, true), ROOT + "/water/water_surface/surface_front_%02d.png" % (frame + 1))
	for frame: int in range(4):
		failures += _save(_draw_foam(frame), ROOT + "/water/foam/drain_foam_%02d.png" % (frame + 1))
	for frame: int in range(5):
		failures += _save(_draw_ripple(frame), ROOT + "/water/ripples/ripple_%02d.png" % (frame + 1))
		failures += _save(_draw_splash(frame, 0), ROOT + "/water/splashes/step_%02d.png" % (frame + 1))
		failures += _save(_draw_splash(frame, 1), ROOT + "/water/splashes/dash_%02d.png" % (frame + 1))
		failures += _save(_draw_splash(frame, 2), ROOT + "/water/splashes/landing_%02d.png" % (frame + 1))
	failures += _save(_draw_drain_grate(), ROOT + "/props/drainage_grates/wall_drain_grate.png")
	failures += _save(_draw_reliquary(), ROOT + "/props/submerged_reliquaries/drowned_reliquary.png")
	failures += _save(_draw_broken_beam(), ROOT + "/props/broken_beams/collapsed_oak_beam.png")
	failures += _save(_draw_rusted_bars(), ROOT + "/props/rusted_bars/half_submerged_bars.png")
	failures += _save(_draw_chain(), ROOT + "/props/chains/hanging_chain.png")
	failures += _save(_draw_statue(), ROOT + "/props/submerged_statues/bell_saint_statue.png")
	failures += _save(_draw_gate(), ROOT + "/props/underkeep_gate/drowned_underkeep_gate.png")
	failures += _save(_draw_drop(), ROOT + "/fx/dripping_water/water_drop.png")
	failures += _save(_draw_ch4_threshold(), CH4_ROOT + "/drowned_underkeep_threshold.png")
	if failures == 0:
		print("UNDERKEEP_ASSET_GENERATION PASS assets=54 original=true nearest_ready=true")
	else:
		push_error("UNDERKEEP_ASSET_GENERATION FAIL failures=%d" % failures)
	quit(failures)


func _save(image: Image, path: String) -> int:
	var error: Error = image.save_png(path)
	if error != OK:
		push_error("Unable to save %s: %s" % [path, error_string(error)])
		return 1
	return 0


func _image(size: Vector2i, color: Color = Color.TRANSPARENT) -> Image:
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return image


func _rect(image: Image, rect: Rect2i, color: Color) -> void:
	image.fill_rect(rect, color)


func _line(image: Image, from: Vector2i, to: Vector2i, color: Color, width: int = 1) -> void:
	var delta: Vector2i = to - from
	var steps: int = maxi(absi(delta.x), absi(delta.y))
	if steps == 0:
		_rect(image, Rect2i(from - Vector2i(width / 2, width / 2), Vector2i(width, width)), color)
		return
	for step: int in range(steps + 1):
		var point: Vector2i = from + Vector2i(
			roundi(float(delta.x) * float(step) / float(steps)),
			roundi(float(delta.y) * float(step) / float(steps))
		)
		_rect(image, Rect2i(point - Vector2i(width / 2, width / 2), Vector2i(width, width)), color)


func _circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y: int in range(-radius, radius + 1):
		var half: int = floori(sqrt(float(radius * radius - y * y)))
		_rect(image, Rect2i(center + Vector2i(-half, y), Vector2i(half * 2 + 1, 1)), color)


func _circle_outline(image: Image, center: Vector2i, rx: int, ry: int, color: Color) -> void:
	for x: int in range(-rx, rx + 1):
		var factor: float = sqrt(maxf(0.0, 1.0 - float(x * x) / float(rx * rx)))
		var y: int = roundi(float(ry) * factor)
		image.set_pixelv(center + Vector2i(x, y), color)
		image.set_pixelv(center + Vector2i(x, -y), color)


func _draw_bricks(image: Image, rect: Rect2i, brick: Vector2i, base: Color) -> void:
	_rect(image, rect, base)
	var rows: int = ceili(float(rect.size.y) / float(brick.y))
	for row: int in range(rows + 1):
		var y: int = rect.position.y + row * brick.y
		_rect(image, Rect2i(rect.position.x, y, rect.size.x, 3), STONE_0)
		var offset: int = 0 if row % 2 == 0 else brick.x / 2
		for x: int in range(rect.position.x - offset, rect.end.x, brick.x):
			_rect(image, Rect2i(x, y - brick.y + 3, 3, brick.y - 3), STONE_0)
			if (x / brick.x + row) % 5 == 0:
				_rect(image, Rect2i(x + 8, y - 10, brick.x / 2, 2), STONE_2)


func _draw_pointed_arch(image: Image, center_x: int, base_y: int, width: int, height: int, broken: bool = false) -> void:
	var left: int = center_x - width / 2
	var right: int = center_x + width / 2
	_rect(image, Rect2i(left, base_y - height / 2, 24, height / 2), STONE_3)
	_rect(image, Rect2i(right - 24, base_y - height / 2, 24, height / 2), STONE_3)
	_line(image, Vector2i(left + 12, base_y - height / 2), Vector2i(center_x, base_y - height), STONE_3, 22)
	_line(image, Vector2i(right - 12, base_y - height / 2), Vector2i(center_x, base_y - height), STONE_3, 22)
	_line(image, Vector2i(left + 18, base_y - height / 2), Vector2i(center_x, base_y - height + 14), STONE_1, 5)
	_line(image, Vector2i(right - 18, base_y - height / 2), Vector2i(center_x, base_y - height + 14), STONE_1, 5)
	if broken:
		_rect(image, Rect2i(right - 28, base_y - height / 3, 34, 46), STONE_0)


func _draw_backdrop() -> Image:
	var image: Image = _image(Vector2i(2304, 720), VOID)
	_draw_bricks(image, Rect2i(0, 0, 2304, 612), Vector2i(72, 38), STONE_1)
	# Three narrative zones: chapel crypt, ossuary drainage, prison threshold.
	_draw_pointed_arch(image, 300, 596, 430, 450, true)
	_draw_pointed_arch(image, 780, 596, 380, 390)
	_draw_pointed_arch(image, 1280, 596, 420, 430, true)
	_draw_pointed_arch(image, 1800, 596, 390, 360)
	for x: int in [130, 486, 940, 1450, 1980]:
		var stain_height: int = 90 + (x % 170)
		_rect(image, Rect2i(x, 506 - stain_height, 12, stain_height), Color(0.06, 0.28, 0.30, 0.48))
		_rect(image, Rect2i(x + 12, 520 - stain_height / 2, 5, stain_height / 2), Color(0.19, 0.46, 0.47, 0.28))
	for x: int in range(90, 2240, 230):
		_line(image, Vector2i(x, 270 + (x % 3) * 34), Vector2i(x - 26, 330 + (x % 5) * 15), STONE_0, 3)
		_line(image, Vector2i(x - 26, 330 + (x % 5) * 15), Vector2i(x + 12, 370), STONE_0, 2)
	# Waterline deposits and a lower course show long-term flooding without drawing the water itself.
	_rect(image, Rect2i(0, 574, 2304, 38), STONE_0)
	for x: int in range(0, 2304, 96):
		_rect(image, Rect2i(x + 8, 580 + (x / 96) % 3 * 3, 64, 4), STONE_WET)
	return image


func _draw_water_bed() -> Image:
	var image: Image = _image(Vector2i(2304, 108), STONE_0)
	for x: int in range(0, 2304, 96):
		var shade: Color = STONE_1 if (x / 96) % 2 == 0 else Color("16242d")
		_rect(image, Rect2i(x, 0, 94, 108), shade)
		_line(image, Vector2i(x + 8, 10), Vector2i(x + 80, 94), STONE_2, 2)
		if (x / 96) % 3 == 0:
			_line(image, Vector2i(x + 70, 4), Vector2i(x + 40, 55), Color("0c3036"), 3)
	return image


func _draw_water_body(frame: int) -> Image:
	var image: Image = _image(Vector2i(768, 108), Color("072535"))
	_rect(image, Rect2i(0, 8, 768, 100), Color("0a3445"))
	for row: int in range(5):
		var start: int = (frame * 23 + row * 71) % 126
		for x: int in range(start - 100, 768, 154):
			var length: int = 34 + ((x + row * 19 + frame * 7) % 56)
			_rect(image, Rect2i(x, 18 + row * 18, length, 2), WATER_2 if row < 3 else WATER_1)
	return image


func _draw_highlights(frame: int) -> Image:
	var image: Image = _image(Vector2i(768, 32))
	for strand: int in range(7):
		var x: int = (strand * 119 + frame * (11 + strand % 3)) % 760
		var y: int = 3 + ((strand * 7 + frame * 2) % 23)
		var length: int = 18 + (strand * 13) % 48
		_rect(image, Rect2i(x, y, length, 2), Color(0.28, 0.66, 0.72, 0.34))
	return image


func _draw_surface(frame: int, front: bool) -> Image:
	var height: int = 4 if front else 16
	var image: Image = _image(Vector2i(768, height))
	for segment: int in range(12):
		var x: int = segment * 64 + ((segment * 7 + frame * 5) % 17) - 8
		var y: int = 1 + ((segment + frame) % (2 if front else 4))
		var length: int = 25 + ((segment * 17 + frame * 9) % 34)
		_rect(image, Rect2i(x, y, length, 1 if front else 2), COLD_LIGHT if front else Color(0.22, 0.58, 0.65, 0.62))
		if not front and segment % 3 == 0:
			_rect(image, Rect2i(x + 8, y + 5, maxi(8, length / 2), 1), Color(0.11, 0.38, 0.47, 0.42))
	return image


func _draw_foam(frame: int) -> Image:
	var image: Image = _image(Vector2i(192, 32))
	for bubble: int in range(9):
		var x: int = 8 + bubble * 20 + ((bubble + frame) % 3) * 2
		var radius: int = 2 + (bubble + frame) % 3
		_circle_outline(image, Vector2i(x, 16 + (bubble % 2) * 4), radius * 2, radius, Color(0.56, 0.78, 0.79, 0.55))
	return image


func _draw_ripple(frame: int) -> Image:
	var image: Image = _image(Vector2i(64, 24))
	var alpha: float = 0.75 - float(frame) * 0.13
	_circle_outline(image, Vector2i(32, 12), 8 + frame * 5, 2 + frame, Color(0.40, 0.82, 0.86, alpha))
	if frame >= 2:
		_circle_outline(image, Vector2i(32, 12), 3 + frame * 2, 1 + frame / 2, Color(0.65, 0.90, 0.90, alpha * 0.7))
	return image


func _draw_splash(frame: int, kind: int) -> Image:
	var size: Vector2i = Vector2i(64, 32) if kind == 0 else Vector2i(96, 48)
	var image: Image = _image(size)
	var center: Vector2i = Vector2i(size.x / 2, size.y - 5)
	var spread: int = 10 + kind * 8 + frame * (3 + kind)
	var height: int = maxi(2, (4 - frame) * (4 + kind * 3))
	_circle_outline(image, center, mini(size.x / 2 - 2, spread), 2 + frame / 2, Color(0.42, 0.82, 0.87, 0.78 - frame * 0.12))
	for drop: int in range(3 + kind * 2):
		var direction: int = -1 if drop % 2 == 0 else 1
		var x: int = center.x + direction * (5 + drop * 5 + frame * 2)
		var y: int = center.y - height + (drop % 3) * 4
		_circle(image, Vector2i(x, y), 1 + kind / 2, Color(0.60, 0.90, 0.90, 0.72 - frame * 0.1))
	return image


func _draw_drain_grate() -> Image:
	var image: Image = _image(Vector2i(192, 144))
	_rect(image, Rect2i(8, 10, 176, 124), IRON_0)
	_rect(image, Rect2i(14, 16, 164, 112), Color("06141b"))
	for x: int in range(24, 176, 22):
		_rect(image, Rect2i(x, 18, 8, 108), IRON_1)
		_rect(image, Rect2i(x + 2, 20, 2, 92), RUST_0)
	for y: int in [20, 68, 116]:
		_rect(image, Rect2i(14, y, 164, 7), RUST_1.darkened(0.25))
	return image


func _draw_reliquary() -> Image:
	var image: Image = _image(Vector2i(224, 136))
	_rect(image, Rect2i(12, 42, 200, 82), STONE_2)
	_rect(image, Rect2i(20, 50, 184, 66), Color("20232a"))
	_line(image, Vector2i(12, 42), Vector2i(62, 10), STONE_3, 10)
	_line(image, Vector2i(212, 42), Vector2i(162, 10), STONE_3, 10)
	_rect(image, Rect2i(62, 6, 100, 10), STONE_3)
	_circle(image, Vector2i(112, 76), 18, BONE_0)
	_rect(image, Rect2i(103, 58, 18, 40), BONE_1)
	_line(image, Vector2i(94, 76), Vector2i(130, 76), BONE_1, 5)
	for x: int in range(24, 202, 34):
		_rect(image, Rect2i(x, 116, 20, 4), STONE_WET)
	return image


func _draw_broken_beam() -> Image:
	var image: Image = _image(Vector2i(288, 96))
	_line(image, Vector2i(10, 72), Vector2i(270, 18), Color("4b3329"), 18)
	_line(image, Vector2i(18, 66), Vector2i(256, 18), Color("765044"), 5)
	for x: int in [48, 116, 180, 238]:
		_line(image, Vector2i(x, 53), Vector2i(x + 8, 70), Color("2d2423"), 3)
	_line(image, Vector2i(264, 13), Vector2i(282, 30), Color("342326"), 8)
	return image


func _draw_rusted_bars() -> Image:
	var image: Image = _image(Vector2i(224, 240))
	for x: int in range(18, 218, 32):
		_rect(image, Rect2i(x, 20 + (x % 3) * 6, 9, 214), RUST_0)
		_rect(image, Rect2i(x + 2, 28, 2, 178), RUST_1)
		_line(image, Vector2i(x - 4, 20 + (x % 3) * 6), Vector2i(x + 4, 6 + (x % 4) * 4), RUST_1, 6)
	for y: int in [64, 142, 218]:
		_rect(image, Rect2i(6, y, 212, 9), IRON_0)
	return image


func _draw_chain() -> Image:
	var image: Image = _image(Vector2i(48, 320))
	for index: int in range(15):
		var center: Vector2i = Vector2i(24 + (index % 2) * 2, 12 + index * 20)
		_circle_outline(image, center, 8 if index % 2 == 0 else 5, 11, RUST_1)
		_circle_outline(image, center, 5 if index % 2 == 0 else 2, 8, IRON_0)
	return image


func _draw_statue() -> Image:
	var image: Image = _image(Vector2i(256, 300))
	_circle(image, Vector2i(128, 48), 30, STONE_3)
	_rect(image, Rect2i(116, 72, 24, 25), STONE_2)
	_line(image, Vector2i(80, 220), Vector2i(92, 104), STONE_2, 42)
	_line(image, Vector2i(176, 220), Vector2i(164, 104), STONE_2, 42)
	_rect(image, Rect2i(83, 90, 90, 118), STONE_2)
	_line(image, Vector2i(95, 108), Vector2i(152, 178), STONE_3, 12)
	_circle(image, Vector2i(160, 176), 20, RUST_1)
	_rect(image, Rect2i(28, 218, 200, 54), STONE_1)
	_rect(image, Rect2i(20, 256, 216, 30), WATER_1)
	for x: int in range(32, 230, 46):
		_rect(image, Rect2i(x, 263 + (x % 3), 28, 2), WATER_3)
	return image


func _draw_gate() -> Image:
	var image: Image = _image(Vector2i(320, 360))
	# Thick low prison arch and inset black passage.
	_rect(image, Rect2i(20, 112, 34, 238), STONE_3)
	_rect(image, Rect2i(266, 112, 34, 238), STONE_3)
	_line(image, Vector2i(36, 120), Vector2i(126, 32), STONE_3, 30)
	_line(image, Vector2i(284, 120), Vector2i(194, 32), STONE_3, 30)
	_rect(image, Rect2i(126, 18, 68, 28), STONE_3)
	_rect(image, Rect2i(56, 126, 208, 224), VOID)
	for x: int in range(78, 256, 30):
		_rect(image, Rect2i(x, 138, 7, 202), RUST_0)
		_rect(image, Rect2i(x + 2, 144, 2, 170), RUST_1)
	_rect(image, Rect2i(62, 202, 196, 10), IRON_0)
	_rect(image, Rect2i(62, 306, 196, 10), IRON_0)
	_circle(image, Vector2i(160, 256), 18, Color("132d37"))
	_circle(image, Vector2i(160, 256), 7, COLD_LIGHT)
	return image


func _draw_drop() -> Image:
	var image: Image = _image(Vector2i(8, 16))
	_line(image, Vector2i(4, 1), Vector2i(4, 9), COLD_LIGHT, 2)
	_circle(image, Vector2i(4, 11), 3, Color(0.48, 0.82, 0.87, 0.82))
	return image


func _draw_ch4_threshold() -> Image:
	var image: Image = _image(Vector2i(1280, 720), Color("030810"))
	_draw_bricks(image, Rect2i(0, 0, 1280, 612), Vector2i(80, 42), Color("121e28"))
	for x: int in [120, 470, 820, 1170]:
		_rect(image, Rect2i(x, 80, 26, 510), Color("26333c"))
		_rect(image, Rect2i(x + 7, 96, 7, 470), Color("3a4a51"))
	for x: int in [250, 640, 1030]:
		_rect(image, Rect2i(x - 75, 210, 150, 290), Color("06111a"))
		_line(image, Vector2i(x - 75, 210), Vector2i(x, 140), STONE_3, 18)
		_line(image, Vector2i(x + 75, 210), Vector2i(x, 140), STONE_3, 18)
		for bar_x: int in range(x - 56, x + 57, 28):
			_rect(image, Rect2i(bar_x, 228, 7, 250), RUST_0)
	_rect(image, Rect2i(0, 590, 1280, 130), WATER_0)
	for x: int in range(0, 1280, 110):
		_rect(image, Rect2i(x + 12, 600 + (x % 4) * 6, 52, 2), WATER_3)
	return image
