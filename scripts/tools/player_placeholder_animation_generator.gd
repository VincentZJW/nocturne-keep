class_name PlayerPlaceholderAnimationGenerator
extends RefCounted

## Creates explicitly temporary frames for actions that do not have final art yet.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")

const OUTPUT_DIRECTORY: String = "res://assets/sprites/player/assassin/placeholder"
const SOURCE_DIRECTORY: String = "res://assets/sprites/player/assassin"
const PLACEHOLDER_COUNTS: Dictionary[String, int] = {
	"hurt": 3,
	"death": 8,
}


static func generate_and_save() -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	)
	if directory_error != OK:
		results[OUTPUT_DIRECTORY] = directory_error
		return results
	var recipes: Dictionary[String, Array] = _recipes()
	for animation_name: String in PLACEHOLDER_COUNTS:
		var animation_recipes: Array = recipes[animation_name]
		for index: int in range(animation_recipes.size()):
			var recipe: Dictionary = animation_recipes[index] as Dictionary
			var source_path: String = SOURCE_DIRECTORY.path_join(str(recipe["source"]))
			var source: Image = Image.load_from_file(ProjectSettings.globalize_path(source_path))
			var output_path: String = OUTPUT_DIRECTORY.path_join(
				"placeholder_%s_%02d.png" % [animation_name, index + 1]
			)
			if source == null or source.is_empty():
				results[output_path] = ERR_FILE_CANT_READ
				continue
			var offset: Vector2i = recipe["offset"] as Vector2i
			results[output_path] = _shift_binary(source, offset).save_png(output_path)
	return results


static func _shift_binary(source: Image, offset: Vector2i) -> Image:
	var result: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	for y: int in range(source.get_height()):
		for x: int in range(source.get_width()):
			var color: Color = source.get_pixel(x, y)
			if color.a <= 0.0:
				continue
			var destination: Vector2i = Vector2i(x, y) + offset
			if Rect2i(Vector2i.ZERO, result.get_size()).has_point(destination):
				result.set_pixelv(destination, color)
	return result


static func _recipes() -> Dictionary[String, Array]:
	return {
		"hurt": [
			{"source": "attack/attack_02.png", "offset": Vector2i(1, 0)},
			{"source": "attack/attack_01.png", "offset": Vector2i(-1, 0)},
			{"source": "attack/attack_06.png", "offset": Vector2i.ZERO},
		],
		"death": [
			{"source": "idle/idle_04.png", "offset": Vector2i.ZERO},
			{"source": "attack/attack_02.png", "offset": Vector2i(0, 1)},
			{"source": "dash/dash_01.png", "offset": Vector2i(-1, 1)},
			{"source": "dash/dash_02.png", "offset": Vector2i(-2, 2)},
			{"source": "dash/dash_03.png", "offset": Vector2i(-3, 3)},
			{"source": "dash/dash_04.png", "offset": Vector2i(-4, 3)},
			{"source": "dash/dash_05.png", "offset": Vector2i(-5, 2)},
			{"source": "dash/dash_03.png", "offset": Vector2i(-6, 4)},
		],
	}
