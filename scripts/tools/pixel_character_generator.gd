class_name PixelCharacterGenerator
extends RefCounted

## Generates the original Night Warden concept as low-resolution pixel clusters.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")

const HOOD_BLACK: Color = Color("08101a")
const MIDNIGHT_NAVY: Color = Color("172b3d")
const MOONLIT_SLATE: Color = Color("607a90")
const PALE_STEEL: Color = Color("d5dee3")
const MUTED_AMBER: Color = Color("b98243")
const SILHOUETTE_BLACK: Color = Color("020407")

const OUTPUT_DIRECTORY: String = "res://assets/sprites/player/concept_c"


static func generate_all() -> Dictionary[String, Image]:
	var assets: Dictionary[String, Image] = {}
	assets["assassin_front_64.png"] = _draw_front()
	assets["assassin_side_64.png"] = _draw_side("idle")
	assets["assassin_silhouette_64.png"] = PixelCanvas.silhouette(
		assets["assassin_side_64.png"], SILHOUETTE_BLACK
	)
	assets["dagger_main.png"] = _draw_dagger(true)
	assets["dagger_offhand.png"] = _draw_dagger(false)
	assets["assassin_front_48.png"] = PixelCanvas.resize_nearest(
		assets["assassin_front_64.png"], Vector2i(48, 48)
	)
	assets["assassin_side_48.png"] = PixelCanvas.resize_nearest(
		assets["assassin_side_64.png"], Vector2i(48, 48)
	)
	assets["palette_preview.png"] = _draw_palette()
	assets["assassin_idle_pose.png"] = assets["assassin_side_64.png"].duplicate()
	assets["assassin_attack_anticipation.png"] = _draw_side("anticipation")
	assets["assassin_dash_pose.png"] = _draw_side("dash")
	return assets


static func save_all(assets: Dictionary[String, Image]) -> Dictionary[String, int]:
	var absolute_directory: String = ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK:
		push_error("PixelCharacterGenerator: unable to create output directory: %s" % directory_error)
		return {}
	var results: Dictionary[String, int] = {}
	for file_name: String in assets:
		var path: String = OUTPUT_DIRECTORY.path_join(file_name)
		results[path] = assets[file_name].save_png(path)
	return results


static func palette() -> Dictionary[String, Color]:
	return {
		"HOOD_BLACK": HOOD_BLACK,
		"MIDNIGHT_NAVY": MIDNIGHT_NAVY,
		"MOONLIT_SLATE": MOONLIT_SLATE,
		"PALE_STEEL": PALE_STEEL,
		"MUTED_AMBER": MUTED_AMBER,
	}


static func _draw_front() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var blocks: Array[Rect2i] = []
	_draw_front_hood(image)
	blocks = [Rect2i(17, 22, 30, 4), Rect2i(15, 25, 34, 3)]
	PixelCanvas.fill_rects(image, blocks, HOOD_BLACK)
	blocks = [Rect2i(19, 24, 26, 5), Rect2i(22, 28, 20, 16)]
	PixelCanvas.fill_rects(image, blocks, MIDNIGHT_NAVY)
	blocks = [Rect2i(17, 29, 6, 15), Rect2i(41, 29, 6, 15)]
	PixelCanvas.fill_rects(image, blocks, MIDNIGHT_NAVY)
	blocks = [Rect2i(18, 30, 4, 8), Rect2i(42, 30, 4, 8), Rect2i(24, 30, 16, 3)]
	PixelCanvas.fill_rects(image, blocks, MOONLIT_SLATE)
	blocks = [Rect2i(25, 34, 6, 7), Rect2i(33, 34, 6, 7), Rect2i(22, 42, 20, 3)]
	PixelCanvas.fill_rects(image, blocks, MOONLIT_SLATE)
	PixelCanvas.fill_rect(image, Rect2i(31, 31, 2, 4), MUTED_AMBER)
	blocks = [Rect2i(23, 44, 8, 14), Rect2i(34, 44, 8, 14)]
	PixelCanvas.fill_rects(image, blocks, MIDNIGHT_NAVY)
	blocks = [Rect2i(24, 46, 3, 9), Rect2i(35, 46, 3, 9)]
	PixelCanvas.fill_rects(image, blocks, MOONLIT_SLATE)
	blocks = [Rect2i(21, 57, 10, 3), Rect2i(34, 57, 10, 3)]
	PixelCanvas.fill_rects(image, blocks, HOOD_BLACK)
	_draw_front_daggers(image)
	return image


static func _draw_front_hood(image: Image) -> void:
	var blocks: Array[Rect2i] = [
		Rect2i(30, 6, 4, 2), Rect2i(27, 8, 10, 2), Rect2i(24, 10, 16, 2),
		Rect2i(22, 12, 20, 4), Rect2i(20, 16, 24, 5), Rect2i(22, 21, 20, 3),
	]
	PixelCanvas.fill_rects(image, blocks, HOOD_BLACK)
	blocks = [Rect2i(23, 13, 3, 7), Rect2i(38, 13, 3, 7)]
	PixelCanvas.fill_rects(image, blocks, MIDNIGHT_NAVY)
	PixelCanvas.fill_rect(image, Rect2i(25, 15, 14, 7), Color("04080d"))
	blocks = [Rect2i(27, 17, 4, 1), Rect2i(34, 17, 4, 1)]
	PixelCanvas.fill_rects(image, blocks, PALE_STEEL)
	blocks = [Rect2i(22, 20, 3, 2), Rect2i(39, 20, 3, 2)]
	PixelCanvas.fill_rects(image, blocks, MOONLIT_SLATE)


static func _draw_front_daggers(image: Image) -> void:
	var guards: Array[Rect2i] = [Rect2i(46, 35, 5, 3), Rect2i(13, 35, 5, 3)]
	PixelCanvas.fill_rects(image, guards, MOONLIT_SLATE)
	PixelCanvas.draw_line(image, Vector2i(50, 36), Vector2i(61, 29), PALE_STEEL, 2)
	PixelCanvas.draw_line(image, Vector2i(14, 37), Vector2i(6, 45), PALE_STEEL, 2)
	PixelCanvas.fill_rect(image, Rect2i(49, 34, 2, 5), HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(13, 34, 2, 5), HOOD_BLACK)


static func _draw_side(pose: String) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var shift_y: int = 0
	if pose == "dash":
		shift_y = 7
	_draw_side_hood(image, shift_y, pose)
	_draw_side_body(image, shift_y, pose)
	_draw_side_limbs(image, shift_y, pose)
	_draw_side_weapons(image, shift_y, pose)
	return image


static func _draw_side_hood(image: Image, y: int, pose: String) -> void:
	var x: int = 1 if pose == "dash" else 0
	var blocks: Array[Rect2i] = [
		Rect2i(33 + x, 7 + y, 4, 2), Rect2i(30 + x, 9 + y, 10, 2),
		Rect2i(27 + x, 11 + y, 16, 3), Rect2i(25 + x, 14 + y, 20, 6),
		Rect2i(27 + x, 20 + y, 17, 4),
	]
	PixelCanvas.fill_rects(image, blocks, HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(36 + x, 15 + y, 7, 6), Color("04080d"))
	PixelCanvas.fill_rect(image, Rect2i(40 + x, 17 + y, 3, 1), PALE_STEEL)
	PixelCanvas.fill_rect(image, Rect2i(27 + x, 13 + y, 3, 7), MIDNIGHT_NAVY)


static func _draw_side_body(image: Image, y: int, pose: String) -> void:
	var body_x: int = 28 if pose != "anticipation" else 26
	var blocks: Array[Rect2i] = [Rect2i(18, 23 + y, 22, 4), Rect2i(16, 27 + y, 19, 4)]
	PixelCanvas.fill_rects(image, blocks, HOOD_BLACK)
	blocks = [Rect2i(body_x, 23 + y, 16, 7), Rect2i(body_x - 2, 30 + y, 18, 14)]
	PixelCanvas.fill_rects(image, blocks, MIDNIGHT_NAVY)
	blocks = [Rect2i(body_x + 1, 26 + y, 13, 4), Rect2i(body_x + 10, 31 + y, 5, 9)]
	PixelCanvas.fill_rects(image, blocks, MOONLIT_SLATE)
	PixelCanvas.fill_rect(image, Rect2i(body_x + 8, 29 + y, 2, 3), MUTED_AMBER)
	blocks = [Rect2i(16, 30 + y, 4, 3), Rect2i(20, 31 + y, 4, 2)]
	PixelCanvas.fill_rects(image, blocks, MIDNIGHT_NAVY)


static func _draw_side_limbs(image: Image, y: int, pose: String) -> void:
	if pose == "dash":
		PixelCanvas.draw_line(image, Vector2i(31, 43 + y), Vector2i(20, 54 + y), MIDNIGHT_NAVY, 5)
		PixelCanvas.draw_line(image, Vector2i(39, 42 + y), Vector2i(52, 51 + y), MIDNIGHT_NAVY, 5)
		PixelCanvas.draw_line(image, Vector2i(22, 53 + y), Vector2i(15, 55 + y), HOOD_BLACK, 4)
		PixelCanvas.draw_line(image, Vector2i(50, 51 + y), Vector2i(57, 51 + y), HOOD_BLACK, 4)
	else:
		var blocks: Array[Rect2i] = [Rect2i(27, 43 + y, 7, 14), Rect2i(37, 43 + y, 7, 14)]
		PixelCanvas.fill_rects(image, blocks, MIDNIGHT_NAVY)
		blocks = [Rect2i(28, 46 + y, 3, 8), Rect2i(38, 46 + y, 3, 8)]
		PixelCanvas.fill_rects(image, blocks, MOONLIT_SLATE)
		blocks = [Rect2i(24, 56 + y, 10, 3), Rect2i(37, 56 + y, 11, 3)]
		PixelCanvas.fill_rects(image, blocks, HOOD_BLACK)


static func _draw_side_weapons(image: Image, y: int, pose: String) -> void:
	if pose == "anticipation":
		PixelCanvas.draw_line(image, Vector2i(33, 31 + y), Vector2i(22, 36 + y), MOONLIT_SLATE, 4)
		PixelCanvas.draw_line(image, Vector2i(22, 36 + y), Vector2i(9, 28 + y), PALE_STEEL, 2)
		PixelCanvas.draw_line(image, Vector2i(40, 32 + y), Vector2i(48, 41 + y), MOONLIT_SLATE, 4)
		PixelCanvas.draw_line(image, Vector2i(48, 41 + y), Vector2i(56, 48 + y), PALE_STEEL, 2)
	else:
		PixelCanvas.draw_line(image, Vector2i(41, 31 + y), Vector2i(50, 35 + y), MOONLIT_SLATE, 4)
		PixelCanvas.draw_line(image, Vector2i(49, 34 + y), Vector2i(63, 28 + y), PALE_STEEL, 2)
		PixelCanvas.draw_line(image, Vector2i(29, 31 + y), Vector2i(22, 37 + y), MOONLIT_SLATE, 4)
		PixelCanvas.draw_line(image, Vector2i(22, 37 + y), Vector2i(11, 46 + y), PALE_STEEL, 2)
	PixelCanvas.fill_rect(image, Rect2i(48, 32 + y, 2, 5), HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(20, 35 + y, 4, 2), HOOD_BLACK)


static func _draw_dagger(is_main: bool) -> Image:
	var size: Vector2i = Vector2i(40, 16) if is_main else Vector2i(32, 16)
	var image: Image = PixelCanvas.create_transparent(size)
	var tip_x: int = size.x - 2
	PixelCanvas.fill_rect(image, Rect2i(2, 6, 8, 4), MIDNIGHT_NAVY)
	PixelCanvas.fill_rect(image, Rect2i(8, 4, 3, 8), MOONLIT_SLATE)
	PixelCanvas.fill_rect(image, Rect2i(11, 6, tip_x - 11, 4), PALE_STEEL)
	PixelCanvas.draw_line(image, Vector2i(12, 6), Vector2i(tip_x, 7), Color("f2f5f6"), 1)
	PixelCanvas.draw_line(image, Vector2i(12, 10), Vector2i(tip_x, 8), MOONLIT_SLATE, 1)
	PixelCanvas.fill_rect(image, Rect2i(tip_x, 7, 2, 2), PALE_STEEL)
	PixelCanvas.fill_rect(image, Rect2i(4, 7, 2, 2), MUTED_AMBER)
	return image


static func _draw_palette() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(160, 32))
	var colors: Array[Color] = [HOOD_BLACK, MIDNIGHT_NAVY, MOONLIT_SLATE, PALE_STEEL, MUTED_AMBER]
	for index: int in range(colors.size()):
		PixelCanvas.fill_rect(image, Rect2i(index * 32, 0, 32, 32), colors[index])
	return image
