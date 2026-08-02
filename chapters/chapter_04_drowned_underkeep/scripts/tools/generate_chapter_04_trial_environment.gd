extends SceneTree

const OUTPUT: String = "res://chapters/chapter_04_drowned_underkeep/assets/environment/character_trial/drowned_cellblock_gallery.png"
const CLEAR: Color = Color(0, 0, 0, 0)
const NIGHT: Color = Color("071018")
const STONE: Color = Color("162630")
const STONE_LIT: Color = Color("263d48")
const MORTAR: Color = Color("0e1a23")
const IRON: Color = Color("3c5158")
const RUST: Color = Color("6d4034")
const WATER: Color = Color("092c3a")
const WATER_LIT: Color = Color("1d5d69")
const SOUL: Color = Color("69adb1")


func _initialize() -> void:
	var image: Image = Image.create(1600, 720, false, Image.FORMAT_RGBA8)
	image.fill(NIGHT)
	# Layered masonry: intentionally irregular courses avoid a flat graybox wall.
	for row: int in range(12):
		var y: int = 40 + row * 48
		var offset: int = -52 if row % 2 == 0 else -8
		for column: int in range(19):
			var x: int = offset + column * 96
			image.fill_rect(Rect2i(x, y, 90, 42), STONE if (row + column) % 3 else STONE_LIT)
			image.fill_rect(Rect2i(x, y + 39, 90, 3), MORTAR)
			image.fill_rect(Rect2i(x + 87, y, 3, 42), MORTAR)
	# Prison arches, iron gates, drowned waterlines and soul lamps.
	for bay: int in range(5):
		var center_x: int = 160 + bay * 320
		_draw_arch(image, center_x, 174)
		_draw_cell_gate(image, center_x, 252)
		_draw_soul_lamp(image, center_x - 118, 276)
		for drip: int in range(4):
			var drip_x: int = center_x - 128 + drip * 74
			image.fill_rect(Rect2i(drip_x, 430 + (drip % 2) * 22, 3, 92 - (drip % 2) * 18), WATER_LIT)
	# Foreground-safe floor band and shallow water readable behind characters.
	image.fill_rect(Rect2i(0, 592, 1600, 128), Color("0b1b24"))
	image.fill_rect(Rect2i(0, 600, 1600, 54), WATER)
	for ripple: int in range(26):
		var x: int = 18 + ripple * 63
		image.fill_rect(Rect2i(x, 610 + (ripple % 4) * 9, 38, 2), WATER_LIT)
	image.fill_rect(Rect2i(0, 584, 1600, 8), IRON)
	image.fill_rect(Rect2i(0, 592, 1600, 4), RUST)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.get_base_dir()))
	var error: Error = image.save_png(ProjectSettings.globalize_path(OUTPUT))
	print("CH4 TRIAL ENVIRONMENT | %s" % ("PASS" if error == OK else error_string(error)))
	quit(0 if error == OK else 1)


func _draw_arch(image: Image, center_x: int, top_y: int) -> void:
	for step: int in range(42):
		var angle: float = PI + PI * float(step) / 41.0
		var x: int = center_x + roundi(cos(angle) * 118.0)
		var y: int = top_y + roundi(sin(angle) * 92.0)
		image.fill_rect(Rect2i(x - 6, y - 6, 12, 12), STONE_LIT)
	image.fill_rect(Rect2i(center_x - 124, top_y, 12, 345), STONE_LIT)
	image.fill_rect(Rect2i(center_x + 112, top_y, 12, 345), STONE_LIT)


func _draw_cell_gate(image: Image, center_x: int, y: int) -> void:
	image.fill_rect(Rect2i(center_x - 94, y, 188, 246), MORTAR)
	for bar: int in range(8):
		image.fill_rect(Rect2i(center_x - 82 + bar * 23, y + 8, 7, 226), IRON)
	image.fill_rect(Rect2i(center_x - 88, y + 70, 176, 7), RUST)
	image.fill_rect(Rect2i(center_x - 88, y + 156, 176, 7), RUST)


func _draw_soul_lamp(image: Image, x: int, y: int) -> void:
	image.fill_rect(Rect2i(x - 4, y, 8, 62), IRON)
	image.fill_rect(Rect2i(x - 16, y + 56, 32, 7), RUST)
	for radius: int in range(10, 1, -1):
		var color: Color = Color(SOUL.r, SOUL.g, SOUL.b, 0.08 + float(10 - radius) * 0.08)
		for py: int in range(y - radius, y + radius + 1):
			for px: int in range(x - radius, x + radius + 1):
				if Vector2(px - x, py - y).length() <= radius:
					image.set_pixel(px, py, color)
