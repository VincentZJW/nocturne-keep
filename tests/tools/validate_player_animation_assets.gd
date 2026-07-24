extends SceneTree

## Headless validation for the Night Warden production animation and death assets.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const Concept: Script = preload("res://scripts/tools/pixel_character_generator.gd")
const Generator: Script = preload("res://scripts/tools/pixel_player_animation_generator.gd")
const DeathGenerator: Script = preload("res://scripts/tools/pixel_player_death_generator.gd")

const REFERENCE_MAPPING: Dictionary[String, String] = {
	"front_reference.png": "assassin_front_64.png",
	"side_reference.png": "assassin_side_64.png",
	"dash_pose_reference.png": "assassin_dash_pose.png",
	"attack_pose_reference.png": "assassin_attack_anticipation.png",
}


func _initialize() -> void:
	call_deferred("_run_validation")


func _run_validation() -> void:
	var failures: Array[String] = []
	var total_frames: int = 0
	for animation_name: String in Generator.ANIMATION_ORDER:
		total_frames += _validate_animation(animation_name, failures)
	total_frames += _validate_death_assets(failures)
	_validate_references(failures)
	_validate_fast_attack_archives(failures)
	_validate_ground_dash_archive(failures)
	_validate_air_dash_archive(failures)
	_validate_action_distinction(failures)
	_validate_project_isolation(failures)
	if failures.is_empty():
		print(
			"PLAYER_ANIMATION_VALIDATION: PASS (%d frames + ghost + 4 byte-identical references)"
			% total_frames
		)
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("PLAYER_ANIMATION_VALIDATION: FAIL (%d issues)" % failures.size())
	quit(1)


func _validate_animation(animation_name: String, failures: Array[String]) -> int:
	var expected_count: int = Generator.FRAME_COUNTS[animation_name]
	var hashes: Dictionary[String, bool] = {}
	for index: int in range(expected_count):
		var path: String = Generator.OUTPUT_ROOT.path_join(animation_name).path_join(
			"%s_%02d.png" % [animation_name, index + 1]
		)
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null or image.is_empty():
			failures.append("Missing animation frame: %s" % path)
			continue
		_validate_image(path, image, failures)
		_validate_import(path, image, failures)
		var digest: String = FileAccess.get_sha256(ProjectSettings.globalize_path(path))
		hashes[digest] = true
	if hashes.size() != expected_count:
		failures.append("%s contains duplicate frame files: %d/%d unique" % [animation_name, hashes.size(), expected_count])
	return expected_count


func _validate_death_assets(failures: Array[String]) -> int:
	var hashes: Dictionary[String, bool] = {}
	for frame_index: int in range(DeathGenerator.DEATH_FRAME_COUNT):
		var path: String = DeathGenerator.OUTPUT_ROOT.path_join(
			"death_%02d.png" % (frame_index + 1)
		)
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null or image.is_empty():
			failures.append("Missing death frame: %s" % path)
			continue
		_validate_image(path, image, failures)
		_validate_import(path, image, failures)
		hashes[FileAccess.get_sha256(ProjectSettings.globalize_path(path))] = true
	if hashes.size() != DeathGenerator.DEATH_FRAME_COUNT:
		failures.append("Death animation frames are missing or duplicated")
	var final_path: String = DeathGenerator.OUTPUT_ROOT.path_join("death_05.png")
	var final_frame: Image = Image.load_from_file(ProjectSettings.globalize_path(final_path))
	if final_frame != null and not final_frame.is_empty():
		var final_width: int = _visible_right(final_frame) - _visible_left(final_frame) + 1
		var final_height: int = _visible_bottom(final_frame) - _visible_top(final_frame) + 1
		if final_width < 54 or final_height > 20:
			failures.append(
				"death_05 does not read as a horizontal corpse: %dx%d" % [final_width, final_height]
			)
		if _visible_bottom(final_frame) != 60:
			failures.append("death_05 ground baseline is not y=60")
	_validate_ghost_asset(failures)
	return DeathGenerator.DEATH_FRAME_COUNT


func _validate_ghost_asset(failures: Array[String]) -> void:
	var path: String = DeathGenerator.OUTPUT_ROOT.path_join(DeathGenerator.GHOST_FILE_NAME)
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		failures.append("Missing hooded ghost texture: %s" % path)
		return
	if image.get_size() != Vector2i(64, 64) or image.has_mipmaps():
		failures.append("Ghost texture is not a 64x64 mipmap-free source")
	var visible_pixels: int = 0
	var partial_alpha_pixels: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var alpha: float = image.get_pixel(x, y).a
			if alpha <= 0.0:
				continue
			visible_pixels += 1
			if alpha < 1.0:
				partial_alpha_pixels += 1
	if visible_pixels < 120 or partial_alpha_pixels == 0:
		failures.append("Ghost texture lacks a readable semi-transparent silhouette")
	_validate_import(path, image, failures)


func _validate_image(path: String, image: Image, failures: Array[String]) -> void:
	if image.get_size() != Vector2i(64, 64):
		failures.append("Wrong frame size for %s: %s" % [path, image.get_size()])
	if image.has_mipmaps():
		failures.append("Source PNG unexpectedly has mipmaps: %s" % path)
	var allowed_colors: Dictionary[Color, bool] = {
		Concept.HOOD_BLACK: true,
		Concept.MIDNIGHT_NAVY: true,
		Concept.MOONLIT_SLATE: true,
		Concept.PALE_STEEL: true,
		Concept.MUTED_AMBER: true,
	}
	var transparent_pixels: int = 0
	var visible_pixels: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if is_zero_approx(color.a):
				transparent_pixels += 1
				continue
			visible_pixels += 1
			if not is_equal_approx(color.a, 1.0):
				failures.append("Partial alpha found in %s at %s" % [path, Vector2i(x, y)])
				return
			if not allowed_colors.has(color):
				failures.append("Out-of-palette pixel found in %s: %s" % [path, color.to_html()])
				return
	if transparent_pixels == 0 or visible_pixels == 0:
		failures.append("Frame lacks transparent background or visible pixels: %s" % path)
	var readability: Image = PixelCanvas.resize_nearest(image, Vector2i(48, 48))
	if not _has_binary_visible_pixels(readability):
		failures.append("48px nearest-neighbor readability conversion failed: %s" % path)


func _validate_import(path: String, source: Image, failures: Array[String]) -> void:
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		failures.append("Godot did not import frame as Texture2D: %s" % path)
		return
	var imported: Image = texture.get_image()
	if imported.has_mipmaps():
		failures.append("Imported animation frame has mipmaps: %s" % path)
	if imported.get_size() != source.get_size():
		failures.append("Imported animation frame changed dimensions: %s" % path)


func _has_binary_visible_pixels(image: Image) -> bool:
	var visible_pixels: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var alpha: float = image.get_pixel(x, y).a
			if alpha > 0.0:
				visible_pixels += 1
				if not is_equal_approx(alpha, 1.0):
					return false
	return visible_pixels > 120


func _validate_references(failures: Array[String]) -> void:
	for reference_name: String in REFERENCE_MAPPING:
		var reference_path: String = Generator.OUTPUT_ROOT.path_join("reference").path_join(reference_name)
		var source_path: String = Generator.REFERENCE_SOURCE.path_join(REFERENCE_MAPPING[reference_name])
		var reference_hash: String = FileAccess.get_sha256(ProjectSettings.globalize_path(reference_path))
		var source_hash: String = FileAccess.get_sha256(ProjectSettings.globalize_path(source_path))
		if reference_hash.is_empty() or reference_hash != source_hash:
			failures.append("Reference is missing or not byte-identical: %s" % reference_path)


func _validate_fast_attack_archives(failures: Array[String]) -> void:
	for frame_index: int in range(1, 7):
		for archive_path: String in [
			Generator.DEPRECATED_ATTACK_SIX_FRAME_ROOT.path_join("attack_6f_%02d.png" % frame_index),
			Generator.DEPRECATED_DASH_ATTACK_SIX_FRAME_ROOT.path_join("dash_attack_6f_%02d.png" % frame_index),
		]:
			var image: Image = Image.load_from_file(ProjectSettings.globalize_path(archive_path))
			if image == null or image.get_size() != Vector2i(64, 64):
				failures.append("Missing or invalid six-frame archive: %s" % archive_path)


func _validate_ground_dash_archive(failures: Array[String]) -> void:
	for frame_index: int in range(1, 6):
		var archive_path: String = Generator.DEPRECATED_GROUND_DASH_ROOT.path_join(
			"ground_dash_5f_%02d.png" % frame_index
		)
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(archive_path))
		if image == null or image.get_size() != Vector2i(64, 64):
			failures.append("Missing or invalid Ground Dash archive: %s" % archive_path)


func _validate_air_dash_archive(failures: Array[String]) -> void:
	for frame_index: int in range(1, 6):
		var archive_path: String = Generator.DEPRECATED_AIR_DASH_ROOT.path_join(
			"air_dash_5f_%02d.png" % frame_index
		)
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(archive_path))
		if image == null or image.get_size() != Vector2i(64, 64):
			failures.append("Missing or invalid Air Dash archive: %s" % archive_path)


func _validate_action_distinction(failures: Array[String]) -> void:
	var ground_dash_path: String = Generator.OUTPUT_ROOT.path_join("dash_loop/dash_loop_02.png")
	var air_dash_path: String = Generator.OUTPUT_ROOT.path_join("air_dash_loop/air_dash_loop_02.png")
	var attack_path: String = Generator.OUTPUT_ROOT.path_join("attack/attack_03.png")
	var dash_attack_path: String = Generator.OUTPUT_ROOT.path_join("dash_attack/dash_attack_03.png")
	var action_hashes: Dictionary[String, bool] = {}
	for path: String in [ground_dash_path, air_dash_path, attack_path, dash_attack_path]:
		action_hashes[FileAccess.get_sha256(ProjectSettings.globalize_path(path))] = true
	if action_hashes.size() != 4:
		failures.append("Ground Dash, Air Dash, Attack, and Dash Attack core frames are not distinct")
	var idle: Image = Image.load_from_file(ProjectSettings.globalize_path(Generator.OUTPUT_ROOT.path_join("idle/idle_01.png")))
	var ground_dash: Image = Image.load_from_file(ProjectSettings.globalize_path(ground_dash_path))
	var air_dash: Image = Image.load_from_file(ProjectSettings.globalize_path(air_dash_path))
	if _visible_top(ground_dash) <= _visible_top(idle) + 3:
		failures.append("Ground Dash core is not visibly lower than idle stance")
	if _visible_bottom(air_dash) >= 60:
		failures.append("Air Dash core reads as grounded instead of airborne")
	var dash_attack: Image = Image.load_from_file(ProjectSettings.globalize_path(dash_attack_path))
	if _visible_right(dash_attack) < 62:
		failures.append("Dash Attack core does not form a forward weapon point")


func _visible_top(image: Image) -> int:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.0:
				return y
	return image.get_height()


func _visible_bottom(image: Image) -> int:
	for y: int in range(image.get_height() - 1, -1, -1):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.0:
				return y
	return -1


func _visible_left(image: Image) -> int:
	for x: int in range(image.get_width()):
		for y: int in range(image.get_height()):
			if image.get_pixel(x, y).a > 0.0:
				return x
	return image.get_width()


func _visible_right(image: Image) -> int:
	for x: int in range(image.get_width() - 1, -1, -1):
		for y: int in range(image.get_height()):
			if image.get_pixel(x, y).a > 0.0:
				return x
	return -1


func _validate_project_isolation(failures: Array[String]) -> void:
	var filter_value: int = int(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", -1))
	if filter_value != 0:
		failures.append("Canvas texture filter is not nearest: %d" % filter_value)
	var main_scene: String = str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene != "res://scenes/cinematics/opening_cinematic.tscn":
		failures.append("Formal Chapter I opening scene changed: %s" % main_scene)
