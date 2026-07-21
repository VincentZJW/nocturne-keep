class_name PlayerM1AnimationContactSheet
extends RefCounted

## Six-row M1 QA sheet with exact 2× frames and 48px nearest checks.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const Concept: Script = preload("res://scripts/tools/pixel_character_generator.gd")
const SpriteFramesBuilder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")

const OUTPUT_PATH: String = "res://docs/qa/m1_player_animation_contact_sheet.png"
const SHEET_SIZE: Vector2i = Vector2i(1200, 900)
const M1_ANIMATIONS: Array[StringName] = [
	&"idle", &"run", &"jump_start", &"jump_loop", &"fall", &"land",
]


static func export() -> Error:
	var sheet: Image = Image.create_empty(SHEET_SIZE.x, SHEET_SIZE.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("09111c"))
	var row_colors: Array[Color] = [
		Concept.MUTED_AMBER, Concept.MOONLIT_SLATE, Concept.PALE_STEEL,
		Concept.MIDNIGHT_NAVY, Concept.MOONLIT_SLATE, Concept.MUTED_AMBER,
	]
	for row: int in range(M1_ANIMATIONS.size()):
		var animation_name: StringName = M1_ANIMATIONS[row]
		var y: int = 24 + row * 144
		PixelCanvas.fill_rect(sheet, Rect2i(28, y, 10, 128), row_colors[row])
		for frame_index: int in range(SpriteFramesBuilder.FRAME_COUNTS[animation_name]):
			var source: Image = Image.load_from_file(ProjectSettings.globalize_path(
				SpriteFramesBuilder.frame_path(animation_name, frame_index)
			))
			var position: Vector2i = Vector2i(160 + frame_index * 138, y)
			PixelCanvas.fill_rect(sheet, Rect2i(position, Vector2i(128, 128)), Color("101d2b"))
			PixelCanvas.blend_scaled(sheet, source, position, 2)
		var representative_index: int = mini(1, SpriteFramesBuilder.FRAME_COUNTS[animation_name] - 1)
		var representative: Image = Image.load_from_file(ProjectSettings.globalize_path(
			SpriteFramesBuilder.frame_path(animation_name, representative_index)
		))
		var resized: Image = PixelCanvas.resize_nearest(representative, Vector2i(48, 48))
		var check_position: Vector2i = Vector2i(1068, y + 16)
		PixelCanvas.fill_rect(sheet, Rect2i(check_position - Vector2i(8, 8), Vector2i(112, 112)), Color("101d2b"))
		PixelCanvas.blend_scaled(sheet, resized, check_position, 2)
	return sheet.save_png(OUTPUT_PATH)
