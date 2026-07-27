extends SceneTree

## Headless validation for generated concept assets and project isolation.

const ASSET_DIRECTORY: String = "res://assets/sprites/player/concept_c"
const BOARD_PATH: String = "res://docs/design/hooded_assassin_character_board.png"

const EXPECTED_SIZES: Dictionary[String, Vector2i] = {
	"assassin_front_64.png": Vector2i(64, 64),
	"assassin_side_64.png": Vector2i(64, 64),
	"assassin_silhouette_64.png": Vector2i(64, 64),
	"dagger_main.png": Vector2i(40, 16),
	"dagger_offhand.png": Vector2i(32, 16),
	"assassin_front_48.png": Vector2i(48, 48),
	"assassin_side_48.png": Vector2i(48, 48),
	"palette_preview.png": Vector2i(160, 32),
	"assassin_idle_pose.png": Vector2i(64, 64),
	"assassin_attack_anticipation.png": Vector2i(64, 64),
	"assassin_dash_pose.png": Vector2i(64, 64),
}


func _initialize() -> void:
	call_deferred("_run_validation")


func _run_validation() -> void:
	var failures: Array[String] = []
	for file_name: String in EXPECTED_SIZES:
		_validate_asset(file_name, EXPECTED_SIZES[file_name], failures)
	_validate_silhouette(failures)
	_validate_board(failures)
	_validate_project_settings(failures)
	if failures.is_empty():
		print("PIXEL_CHARACTER_VALIDATION: PASS (%d assets + board)" % EXPECTED_SIZES.size())
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("PIXEL_CHARACTER_VALIDATION: FAIL (%d issues)" % failures.size())
	quit(1)


func _validate_asset(file_name: String, expected_size: Vector2i, failures: Array[String]) -> void:
	var path: String = ASSET_DIRECTORY.path_join(file_name)
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		failures.append("Missing or unreadable image: %s" % path)
		return
	if image.get_size() != expected_size:
		failures.append("Wrong size for %s: %s" % [path, image.get_size()])
	if image.has_mipmaps():
		failures.append("Unexpected mipmaps in source image: %s" % path)
	var imported_texture: Texture2D = load(path) as Texture2D
	if imported_texture == null:
		failures.append("Godot import did not produce a Texture2D: %s" % path)
	else:
		var imported_image: Image = imported_texture.get_image()
		if imported_image.has_mipmaps():
			failures.append("Imported texture has mipmaps enabled: %s" % path)
		if imported_image.get_size() != image.get_size():
			failures.append("Imported texture changed dimensions: %s" % path)
		if not _visible_pixels_match(image, imported_image):
			failures.append("Imported texture pixels differ from lossless PNG source: %s" % path)
	var transparent_pixels: int = 0
	var opaque_pixels: int = 0
	var partial_alpha_pixels: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var alpha: float = image.get_pixel(x, y).a
			if is_zero_approx(alpha):
				transparent_pixels += 1
			elif is_equal_approx(alpha, 1.0):
				opaque_pixels += 1
			else:
				partial_alpha_pixels += 1
	if file_name != "palette_preview.png" and transparent_pixels == 0:
		failures.append("Transparent background missing: %s" % path)
	if opaque_pixels == 0:
		failures.append("No visible pixels: %s" % path)
	if partial_alpha_pixels > 0:
		failures.append("Soft/blurred alpha pixels found in %s: %d" % [path, partial_alpha_pixels])


func _visible_pixels_match(source: Image, imported: Image) -> bool:
	for y: int in range(source.get_height()):
		for x: int in range(source.get_width()):
			var source_color: Color = source.get_pixel(x, y)
			var imported_color: Color = imported.get_pixel(x, y)
			if not is_equal_approx(source_color.a, imported_color.a):
				return false
			if source_color.a > 0.0 and not source_color.is_equal_approx(imported_color):
				return false
	return true


func _validate_silhouette(failures: Array[String]) -> void:
	var silhouette_path: String = ASSET_DIRECTORY.path_join("assassin_silhouette_64.png")
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(silhouette_path))
	var visible_colors: Dictionary[Color, bool] = {}
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if color.a > 0.0:
				visible_colors[color] = true
	if visible_colors.size() != 1:
		failures.append("Silhouette must contain exactly one opaque color; found %d" % visible_colors.size())


func _validate_board(failures: Array[String]) -> void:
	var board: Image = Image.load_from_file(ProjectSettings.globalize_path(BOARD_PATH))
	if board == null or board.is_empty():
		failures.append("Missing design board: %s" % BOARD_PATH)
		return
	if board.get_size() != Vector2i(1600, 1000):
		failures.append("Wrong design board size: %s" % board.get_size())
	if board.has_mipmaps():
		failures.append("Design board source unexpectedly has mipmaps")


func _validate_project_settings(failures: Array[String]) -> void:
	var filter_value: int = int(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", -1))
	if filter_value != 0:
		failures.append("Canvas texture filter is not Nearest: %d" % filter_value)
	var main_scene: String = str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene != "res://scenes/bootstrap/main_bootstrap.tscn":
		failures.append("Formal MainBootstrap scene was changed: %s" % main_scene)
