class_name PlayerAnimationContactSheet
extends RefCounted

## Exports a deterministic QA sheet: 64px frames at 2× plus 48px checks at right.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const Concept: Script = preload("res://scripts/tools/pixel_character_generator.gd")
const Generator: Script = preload("res://scripts/tools/pixel_player_animation_generator.gd")

const OUTPUT_PATH: String = "res://docs/qa/player_animation_contact_sheet.png"
const SHEET_SIZE: Vector2i = Vector2i(1200, 1840)


static func export(sequences: Dictionary[String, Array]) -> Error:
	var sheet: Image = Image.create_empty(SHEET_SIZE.x, SHEET_SIZE.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("09111c"))
	var row_colors: Array[Color] = [
		Concept.MUTED_AMBER, Concept.MOONLIT_SLATE, Concept.MIDNIGHT_NAVY,
		Concept.MOONLIT_SLATE, Concept.PALE_STEEL, Concept.MIDNIGHT_NAVY,
		Concept.MOONLIT_SLATE, Concept.PALE_STEEL, Concept.MUTED_AMBER,
		Concept.PALE_STEEL,
	]
	for row: int in range(Generator.ANIMATION_ORDER.size()):
		var animation_name: String = Generator.ANIMATION_ORDER[row]
		var frames: Array = sequences[animation_name]
		var y: int = 26 + row * 168
		PixelCanvas.fill_rect(sheet, Rect2i(28, y, 10, 128), row_colors[row])
		PixelCanvas.fill_rect(sheet, Rect2i(46, y, 96, 128), Color("101d2b"))
		for index: int in range(frames.size()):
			var frame: Image = frames[index] as Image
			var frame_position: Vector2i = Vector2i(160 + index * 138, y)
			PixelCanvas.fill_rect(sheet, Rect2i(frame_position, Vector2i(128, 128)), Color("101d2b"))
			PixelCanvas.blend_scaled(sheet, frame, frame_position, 2)
		var representative: Image = frames[mini(2, frames.size() - 1)] as Image
		var resized: Image = PixelCanvas.resize_nearest(representative, Vector2i(48, 48))
		var check_position: Vector2i = Vector2i(1068, y + 16)
		PixelCanvas.fill_rect(sheet, Rect2i(check_position - Vector2i(8, 8), Vector2i(112, 112)), Color("101d2b"))
		PixelCanvas.blend_scaled(sheet, resized, check_position, 2)
	return sheet.save_png(OUTPUT_PATH)
