extends SceneTree

const ROOT := "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets"
const INK := Color("111522")
const STONE := Color("283143")
const STONE_LIGHT := Color("45536a")
const MORTAR := Color("151b2a")
const GOLD := Color("9a7838")
const GOLD_LIGHT := Color("c4a75c")
const BLOOD := Color("5b2532")
const BLUE := Color("4f7898")
const WOOD := Color("3b2830")


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ROOT + "/environment/structural_r2"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ROOT + "/doors/structural_r2"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ROOT + "/props/structural_r2"))
	_make_backdrop("vestibule_backdrop", Vector2i(2048, 720), 5, Color("171b29"), Color("252b3a"))
	_make_backdrop("nave_backdrop", Vector2i(2304, 720), 7, Color("141925"), Color("242d3b"))
	_make_backdrop("choir_gallery_backdrop", Vector2i(2432, 720), 6, Color("121722"), Color("222a38"))
	_make_backdrop("boss_checkpoint_backdrop", Vector2i(896, 720), 3, Color("121521"), Color("272839"))
	_make_door("mirror_back_door", Color("26394e"), BLUE)
	_make_door("nave_iron_door", Color("32242d"), GOLD)
	_make_door("choir_screen_door", Color("2b2937"), GOLD_LIGHT)
	_make_door("boss_vestry_door", Color("38232c"), BLOOD)
	_make_stair()
	_make_platform("platform_96", 96)
	_make_platform("platform_144", 144)
	_make_platform("platform_160", 160)
	_make_platform("platform_192", 192)
	_make_bench()
	_make_font()
	_make_lectern()
	_make_emblem()
	_make_choir_seat()
	_make_organ_layers()
	print("CH3_R2_ASSET_GENERATION PASS files=20")
	quit()


func _new_image(size: Vector2i, color: Color = Color(0, 0, 0, 0)) -> Image:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return image


func _save(image: Image, folder: String, name: String) -> void:
	var path := ROOT + "/" + folder + "/" + name + ".png"
	var error := image.save_png(path)
	assert(error == OK, "Failed to save %s" % path)


func _line(image: Image, a: Vector2i, b: Vector2i, color: Color, width: int = 1) -> void:
	var dx: int = absi(b.x - a.x)
	var sx: int = 1 if a.x < b.x else -1
	var dy: int = -absi(b.y - a.y)
	var sy: int = 1 if a.y < b.y else -1
	var error: int = dx + dy
	var point: Vector2i = a
	while true:
		image.fill_rect(Rect2i(point.x - width / 2, point.y - width / 2, width, width), color)
		if point == b:
			break
		var e2: int = 2 * error
		if e2 >= dy:
			error += dy
			point.x += sx
		if e2 <= dx:
			error += dx
			point.y += sy


func _make_backdrop(name: String, size: Vector2i, bays: int, upper: Color, lower: Color) -> void:
	var image := _new_image(size, upper)
	image.fill_rect(Rect2i(0, 94, size.x, size.y - 94), lower)
	for y in range(94, 612, 48):
		_line(image, Vector2i(0, y), Vector2i(size.x - 1, y), MORTAR, 3)
		var row_index: int = int((y - 94) / 48)
		var offset := 0 if row_index % 2 == 0 else 64
		for x in range(offset, size.x, 128):
			_line(image, Vector2i(x, y), Vector2i(x, min(y + 48, 611)), MORTAR, 3)
	image.fill_rect(Rect2i(0, 604, size.x, 8), STONE_LIGHT)
	image.fill_rect(Rect2i(0, 612, size.x, 108), Color("202635"))
	for x in range(0, size.x, 96):
		_line(image, Vector2i(x, 620), Vector2i(x - 24, 719), Color("30394b"), 2)
	var bay_width := size.x / bays
	for bay in range(bays):
		var cx := bay * bay_width + bay_width / 2
		_line(image, Vector2i(cx - bay_width / 3, 604), Vector2i(cx - bay_width / 3, 252), STONE_LIGHT, 12)
		_line(image, Vector2i(cx + bay_width / 3, 604), Vector2i(cx + bay_width / 3, 252), STONE_LIGHT, 12)
		_line(image, Vector2i(cx - bay_width / 3, 252), Vector2i(cx, 158), STONE_LIGHT, 12)
		_line(image, Vector2i(cx, 158), Vector2i(cx + bay_width / 3, 252), STONE_LIGHT, 12)
		_line(image, Vector2i(cx - bay_width / 3 + 10, 252), Vector2i(cx, 174), Color("68758a"), 3)
		_line(image, Vector2i(cx, 174), Vector2i(cx + bay_width / 3 - 10, 252), Color("68758a"), 3)
		image.fill_rect(Rect2i(cx - 22, 286, 44, 154), Color("101725"))
		image.fill_rect(Rect2i(cx - 15, 294, 11, 138), BLUE.darkened(0.35))
		image.fill_rect(Rect2i(cx + 4, 294, 11, 138), BLUE.darkened(0.52))
		_line(image, Vector2i(cx - 20, 366), Vector2i(cx + 20, 366), STONE_LIGHT, 3)
	for x in range(56, size.x, 128):
		image.fill_rect(Rect2i(x, 112, 6, 24), GOLD.darkened(0.25))
		image.fill_rect(Rect2i(x - 5, 110, 16, 5), GOLD_LIGHT)
	_save(image, "environment/structural_r2", name)


func _make_door(name: String, panel: Color, accent: Color) -> void:
	var image := _new_image(Vector2i(192, 448))
	image.fill_rect(Rect2i(10, 76, 172, 372), STONE_LIGHT)
	image.fill_rect(Rect2i(20, 68, 152, 380), panel)
	_line(image, Vector2i(20, 72), Vector2i(96, 8), STONE_LIGHT, 12)
	_line(image, Vector2i(96, 8), Vector2i(172, 72), STONE_LIGHT, 12)
	_line(image, Vector2i(31, 80), Vector2i(96, 26), accent, 4)
	_line(image, Vector2i(96, 26), Vector2i(161, 80), accent, 4)
	for x in [32, 68, 104, 140]:
		image.fill_rect(Rect2i(x, 102, 16, 322), panel.lightened(0.08))
		image.fill_rect(Rect2i(x + 4, 108, 4, 310), panel.darkened(0.18))
	for y in range(118, 420, 60):
		image.fill_rect(Rect2i(24, y, 144, 5), accent.darkened(0.18))
	image.fill_rect(Rect2i(82, 254, 28, 10), accent)
	image.fill_rect(Rect2i(92, 244, 8, 30), accent.lightened(0.2))
	_save(image, "doors/structural_r2", name)


func _make_stair() -> void:
	var image := _new_image(Vector2i(512, 160))
	for index in range(8):
		var x := index * 64
		var y := index * 10
		image.fill_rect(Rect2i(x, y, 64, 160 - y), Color("323b4c"))
		image.fill_rect(Rect2i(x, y, 64, 5), Color("6a7489"))
		_line(image, Vector2i(x, y + 8), Vector2i(x + 58, y + 8), Color("202838"), 2)
	_save(image, "environment/structural_r2", "vestibule_nave_stair")


func _make_platform(name: String, width: int) -> void:
	var image := _new_image(Vector2i(width, 48))
	image.fill_rect(Rect2i(0, 0, width, 8), Color("7a8190"))
	image.fill_rect(Rect2i(0, 8, width, 28), Color("343d4d"))
	for x in range(0, width, 32):
		image.fill_rect(Rect2i(x + 3, 12, 26, 18), Color("465166"))
		_line(image, Vector2i(x + 4, 30), Vector2i(x + 28, 13), Color("252d3c"), 2)
	image.fill_rect(Rect2i(8, 36, width - 16, 5), GOLD.darkened(0.25))
	_save(image, "environment/structural_r2", name)


func _make_bench() -> void:
	var image := _new_image(Vector2i(200, 96))
	image.fill_rect(Rect2i(12, 42, 176, 16), WOOD.lightened(0.15))
	image.fill_rect(Rect2i(18, 12, 164, 28), WOOD)
	for x in [24, 78, 132, 174]:
		image.fill_rect(Rect2i(x, 58, 10, 36), WOOD.darkened(0.15))
		image.fill_rect(Rect2i(x - 3, 8, 16, 8), GOLD.darkened(0.25))
	_save(image, "props/structural_r2", "mourner_bench")


func _make_font() -> void:
	var image := _new_image(Vector2i(112, 144))
	image.fill_rect(Rect2i(34, 72, 44, 64), STONE_LIGHT)
	image.fill_rect(Rect2i(20, 46, 72, 34), Color("59657a"))
	image.fill_rect(Rect2i(28, 52, 56, 17), Color("172132"))
	image.fill_rect(Rect2i(46, 18, 20, 30), GOLD.darkened(0.1))
	_line(image, Vector2i(56, 8), Vector2i(56, 39), GOLD_LIGHT, 5)
	_save(image, "props/structural_r2", "thirteen_bell_font")


func _make_lectern() -> void:
	var image := _new_image(Vector2i(112, 144))
	image.fill_rect(Rect2i(30, 108, 52, 12), WOOD)
	_line(image, Vector2i(42, 108), Vector2i(57, 50), WOOD.lightened(0.18), 10)
	image.fill_rect(Rect2i(20, 35, 78, 22), WOOD.lightened(0.1))
	_line(image, Vector2i(28, 36), Vector2i(90, 50), GOLD.darkened(0.2), 3)
	_save(image, "props/structural_r2", "votive_lectern")


func _make_emblem() -> void:
	var image := _new_image(Vector2i(320, 112))
	for i in range(13):
		var x := 16 + i * 24
		image.fill_rect(Rect2i(x, 30 + abs(6 - i) * 3, 12, 20), GOLD)
		image.fill_rect(Rect2i(x + 3, 51 + abs(6 - i) * 3, 6, 6), GOLD_LIGHT)
	_line(image, Vector2i(14, 78), Vector2i(306, 78), BLOOD, 7)
	_line(image, Vector2i(42, 91), Vector2i(278, 91), GOLD.darkened(0.25), 3)
	_save(image, "props/structural_r2", "thirteen_bell_emblem")


func _make_choir_seat() -> void:
	var image := _new_image(Vector2i(192, 96))
	image.fill_rect(Rect2i(8, 32, 176, 48), WOOD)
	for x in range(14, 180, 28):
		image.fill_rect(Rect2i(x, 16, 20, 58), WOOD.lightened(0.09))
		_line(image, Vector2i(x, 16), Vector2i(x + 10, 4), GOLD.darkened(0.3), 4)
		_line(image, Vector2i(x + 10, 4), Vector2i(x + 20, 16), GOLD.darkened(0.3), 4)
	image.fill_rect(Rect2i(0, 80, 192, 8), GOLD.darkened(0.25))
	_save(image, "props/structural_r2", "choir_seat")


func _make_organ_layers() -> void:
	var pipes := _new_image(Vector2i(640, 360))
	for i in range(19):
		var height: int = 120 + (9 - absi(9 - i)) * 19
		var x := 22 + i * 32
		pipes.fill_rect(Rect2i(x, 340 - height, 18, height), Color("6e604d"))
		pipes.fill_rect(Rect2i(x + 4, 344 - height, 5, height - 10), GOLD.darkened(0.15))
		_line(pipes, Vector2i(x, 340 - height), Vector2i(x + 9, 330 - height), GOLD_LIGHT, 3)
	pipes.fill_rect(Rect2i(6, 326, 628, 24), WOOD)
	_save(pipes, "props/structural_r2", "organ_pipes_far")
	var organ := _new_image(Vector2i(704, 448))
	organ.fill_rect(Rect2i(20, 82, 664, 344), WOOD.darkened(0.12))
	for x in range(44, 680, 64):
		organ.fill_rect(Rect2i(x, 112, 38, 270), WOOD.lightened(0.08))
		_line(organ, Vector2i(x, 112), Vector2i(x + 19, 86), GOLD.darkened(0.2), 4)
		_line(organ, Vector2i(x + 19, 86), Vector2i(x + 38, 112), GOLD.darkened(0.2), 4)
	organ.fill_rect(Rect2i(0, 390, 704, 34), GOLD.darkened(0.32))
	_save(organ, "props/structural_r2", "organ_case_behind")
