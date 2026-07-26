class_name PixelPlayerDeathGenerator
extends RefCounted

## Generates the production five-frame death fall and hooded-face ghost texture.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const Concept: Script = preload("res://scripts/tools/pixel_character_generator.gd")
const Renderer: Script = preload("res://scripts/tools/pixel_assassin_renderer.gd")

const OUTPUT_ROOT: String = "res://assets/sprites/player/assassin/death"
const DEATH_FRAME_COUNT: int = 5
const GHOST_FILE_NAME: String = "ghost_hooded_face.png"


static func generate_death_frames(weapon_style: StringName = &"veilbound") -> Array[Image]:
	return [
		_draw_death_01(weapon_style),
		_draw_death_02(weapon_style),
		_draw_death_03(weapon_style),
		_draw_death_04(weapon_style),
		_draw_death_05(weapon_style),
	]


static func generate_ghost() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var glow_soft: Color = Color(0.68, 0.84, 0.94, 0.18)
	var glow_mid: Color = Color(0.75, 0.89, 0.98, 0.38)
	var spirit_slate: Color = Color(0.62, 0.78, 0.90, 0.68)
	var spirit_steel: Color = Color(0.84, 0.93, 0.98, 0.88)
	PixelCanvas.fill_rect(image, Rect2i(25, 18, 14, 2), glow_soft)
	PixelCanvas.fill_rect(image, Rect2i(21, 20, 22, 3), glow_soft)
	PixelCanvas.fill_rect(image, Rect2i(18, 24, 28, 13), glow_soft)
	PixelCanvas.fill_rect(image, Rect2i(21, 37, 22, 5), glow_soft)
	PixelCanvas.fill_rect(image, Rect2i(28, 15, 8, 3), spirit_slate)
	PixelCanvas.fill_rect(image, Rect2i(24, 18, 16, 3), spirit_slate)
	PixelCanvas.fill_rect(image, Rect2i(21, 21, 22, 4), spirit_steel)
	PixelCanvas.fill_rect(image, Rect2i(20, 25, 24, 9), spirit_slate)
	PixelCanvas.fill_rect(image, Rect2i(23, 34, 18, 5), spirit_slate)
	PixelCanvas.fill_rect(image, Rect2i(24, 25, 16, 10), Color(0.08, 0.16, 0.23, 0.58))
	PixelCanvas.fill_rect(image, Rect2i(27, 28, 3, 2), spirit_steel)
	PixelCanvas.fill_rect(image, Rect2i(35, 28, 3, 2), spirit_steel)
	PixelCanvas.fill_rect(image, Rect2i(27, 39, 3, 4), glow_mid)
	PixelCanvas.fill_rect(image, Rect2i(35, 39, 3, 5), glow_mid)
	PixelCanvas.fill_rect(image, Rect2i(31, 39, 3, 7), glow_soft)
	return image


static func save_all() -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(OUTPUT_ROOT)
	)
	if directory_error != OK:
		results[OUTPUT_ROOT] = directory_error
		return results
	var frames: Array[Image] = generate_death_frames()
	for frame_index: int in range(frames.size()):
		var path: String = OUTPUT_ROOT.path_join("death_%02d.png" % (frame_index + 1))
		results[path] = frames[frame_index].save_png(path)
	results[OUTPUT_ROOT.path_join(GHOST_FILE_NAME)] = generate_ghost().save_png(
		OUTPUT_ROOT.path_join(GHOST_FILE_NAME)
	)
	return results


static func _draw_death_01(weapon_style: StringName) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	_draw_vertical_hood(image, Vector2i(29, 22))
	PixelCanvas.draw_line(image, Vector2i(30, 31), Vector2i(34, 47), Concept.MIDNIGHT_NAVY, 10)
	PixelCanvas.draw_line(image, Vector2i(31, 34), Vector2i(34, 45), Concept.MOONLIT_SLATE, 3)
	PixelCanvas.fill_rect(image, Rect2i(31, 39, 3, 3), Concept.MUTED_AMBER)
	PixelCanvas.draw_line(image, Vector2i(29, 34), Vector2i(20, 43), Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.draw_line(image, Vector2i(36, 34), Vector2i(42, 42), Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.draw_line(image, Vector2i(32, 46), Vector2i(25, 58), Concept.MIDNIGHT_NAVY, 6)
	PixelCanvas.draw_line(image, Vector2i(36, 46), Vector2i(42, 59), Concept.MIDNIGHT_NAVY, 6)
	PixelCanvas.fill_rect(image, Rect2i(21, 58, 9, 3), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(39, 58, 9, 3), Concept.HOOD_BLACK)
	PixelCanvas.draw_line(image, Vector2i(28, 32), Vector2i(20, 38), Concept.HOOD_BLACK, 5)
	_draw_dagger(image, Vector2i(20, 43), Vector2i(10, 48), false, weapon_style)
	_draw_dagger(image, Vector2i(42, 42), Vector2i(55, 38), true, weapon_style)
	return image


static func _draw_death_02(weapon_style: StringName) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	_draw_vertical_hood(image, Vector2i(23, 34))
	PixelCanvas.draw_line(image, Vector2i(28, 38), Vector2i(40, 49), Concept.MIDNIGHT_NAVY, 10)
	PixelCanvas.draw_line(image, Vector2i(30, 39), Vector2i(39, 47), Concept.MOONLIT_SLATE, 3)
	PixelCanvas.fill_rect(image, Rect2i(35, 44, 3, 3), Concept.MUTED_AMBER)
	PixelCanvas.draw_line(image, Vector2i(29, 39), Vector2i(21, 48), Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.draw_line(image, Vector2i(34, 42), Vector2i(44, 45), Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.draw_line(image, Vector2i(39, 49), Vector2i(39, 59), Concept.MIDNIGHT_NAVY, 6)
	PixelCanvas.draw_line(image, Vector2i(42, 49), Vector2i(51, 58), Concept.MIDNIGHT_NAVY, 6)
	PixelCanvas.fill_rect(image, Rect2i(35, 58, 9, 3), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(48, 57, 9, 3), Concept.HOOD_BLACK)
	PixelCanvas.draw_line(image, Vector2i(28, 38), Vector2i(18, 43), Concept.HOOD_BLACK, 5)
	_draw_dagger(image, Vector2i(21, 48), Vector2i(10, 52), false, weapon_style)
	_draw_dagger(image, Vector2i(44, 45), Vector2i(58, 42), true, weapon_style)
	return image


static func _draw_death_03(weapon_style: StringName) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	_draw_horizontal_hood(image, Vector2i(18, 46))
	PixelCanvas.draw_line(image, Vector2i(25, 47), Vector2i(43, 54), Concept.MIDNIGHT_NAVY, 9)
	PixelCanvas.draw_line(image, Vector2i(27, 47), Vector2i(41, 52), Concept.MOONLIT_SLATE, 3)
	PixelCanvas.fill_rect(image, Rect2i(34, 50, 3, 3), Concept.MUTED_AMBER)
	PixelCanvas.draw_line(image, Vector2i(27, 48), Vector2i(22, 56), Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.draw_line(image, Vector2i(35, 51), Vector2i(45, 49), Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.draw_line(image, Vector2i(42, 54), Vector2i(48, 59), Concept.MIDNIGHT_NAVY, 6)
	PixelCanvas.draw_line(image, Vector2i(43, 55), Vector2i(57, 58), Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.fill_rect(image, Rect2i(44, 58, 9, 3), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(54, 57, 8, 3), Concept.HOOD_BLACK)
	_draw_dagger(image, Vector2i(14, 57), Vector2i(4, 55), false, weapon_style)
	_draw_dagger(image, Vector2i(48, 47), Vector2i(62, 43), true, weapon_style)
	return image


static func _draw_death_04(weapon_style: StringName) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	_draw_horizontal_corpse(image, false)
	_draw_dagger(image, Vector2i(18, 57), Vector2i(5, 58), false, weapon_style)
	_draw_dagger(image, Vector2i(48, 48), Vector2i(62, 45), true, weapon_style)
	return image


static func _draw_death_05(weapon_style: StringName) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	_draw_horizontal_corpse(image, true)
	_draw_dagger(image, Vector2i(18, 58), Vector2i(5, 59), false, weapon_style)
	_draw_dagger(image, Vector2i(49, 50), Vector2i(63, 47), true, weapon_style)
	return image


static func _draw_vertical_hood(image: Image, center: Vector2i) -> void:
	PixelCanvas.fill_rect(image, Rect2i(center.x - 3, center.y - 9, 6, 2), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 6, center.y - 7, 12, 3), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 8, center.y - 4, 16, 8), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 5, center.y - 1, 11, 5), Concept.MIDNIGHT_NAVY)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 2, center.y, 3, 1), Concept.PALE_STEEL)


static func _draw_horizontal_hood(image: Image, center: Vector2i) -> void:
	PixelCanvas.fill_rect(image, Rect2i(center.x - 8, center.y - 5, 3, 4), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 6, center.y - 7, 11, 4), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 7, center.y - 3, 16, 9), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(center.x, center.y - 2, 8, 6), Concept.MIDNIGHT_NAVY)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 4, center.y, 3, 1), Concept.PALE_STEEL)


static func _draw_horizontal_corpse(image: Image, settled: bool) -> void:
	var body_y: int = 51 if settled else 50
	_draw_horizontal_hood(image, Vector2i(17, body_y))
	PixelCanvas.fill_rect(image, Rect2i(23, body_y - 3, 22, 9), Concept.MIDNIGHT_NAVY)
	PixelCanvas.fill_rect(image, Rect2i(25, body_y - 2, 16, 3), Concept.MOONLIT_SLATE)
	PixelCanvas.fill_rect(image, Rect2i(32, body_y, 3, 3), Concept.MUTED_AMBER)
	PixelCanvas.draw_line(image, Vector2i(28, body_y + 1), Vector2i(20, body_y + 6), Concept.MIDNIGHT_NAVY, 4)
	PixelCanvas.draw_line(image, Vector2i(38, body_y + 1), Vector2i(47, body_y - 1), Concept.MIDNIGHT_NAVY, 4)
	PixelCanvas.draw_line(image, Vector2i(43, body_y + 1), Vector2i(57, body_y + 4), Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.draw_line(image, Vector2i(43, body_y + 4), Vector2i(56, body_y + 7), Concept.MIDNIGHT_NAVY, 5)
	PixelCanvas.fill_rect(image, Rect2i(53, body_y + 3, 9, 3), Concept.HOOD_BLACK)
	PixelCanvas.fill_rect(image, Rect2i(52, body_y + 6, 10, 3), Concept.HOOD_BLACK)
	PixelCanvas.draw_line(image, Vector2i(25, body_y - 2), Vector2i(14, body_y - 4), Concept.HOOD_BLACK, 4)


static func _draw_dagger(
		image: Image, handle: Vector2i, tip: Vector2i, is_main: bool,
		weapon_style: StringName = &"veilbound"
	) -> void:
	if weapon_style == &"ravenfang":
		Renderer.draw_ravenfang_dagger(image, handle, tip, is_main)
		return
	var direction: Vector2 = Vector2(tip - handle).normalized()
	var blade_start: Vector2i = handle + Vector2i(
		roundi(direction.x * 3.0), roundi(direction.y * 3.0)
	)
	PixelCanvas.draw_line(image, blade_start, tip, Concept.PALE_STEEL, 2)
	PixelCanvas.draw_line(image, blade_start, tip, Concept.MOONLIT_SLATE, 1)
	PixelCanvas.fill_rect(image, Rect2i(handle.x - 2, handle.y - 2, 4, 4), Concept.HOOD_BLACK)
	if is_main:
		PixelCanvas.fill_rect(image, Rect2i(handle.x - 1, handle.y - 1, 2, 2), Concept.MUTED_AMBER)
