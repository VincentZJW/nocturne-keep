extends SceneTree

const ROOT: String = "res://assets/sprites/enemies"
const DEFINITIONS: Dictionary[String, Dictionary] = {
	"cursed_shield_guard": {
		"idle": [4, 4.0, true], "walk": [6, 7.0, true], "block": [3, 12.0, false],
		"attack": [5, 10.0, false], "guard_break": [4, 10.0, false],
		"hurt": [3, 16.666667, false], "death": [6, 8.0, false],
		"idle_unshielded": [4, 4.0, true], "walk_unshielded": [6, 7.0, true],
		"attack_unshielded": [5, 10.0, false],
		"hurt_unshielded": [3, 16.666667, false], "death_unshielded": [6, 8.0, false],
	},
	"decayed_spearman": {
		"idle": [4, 4.0, true], "walk": [6, 8.0, true],
		"attack_thrust": [6, 10.0, false], "hurt": [3, 16.666667, false],
		"death": [6, 8.0, false],
	},
	"fallen_crossbowman": {
		"idle": [4, 4.0, true], "walk": [6, 8.0, true], "aim": [4, 6.0, true],
		"shoot": [3, 12.0, false], "reload": [4, 4.0, false],
		"hurt": [3, 16.666667, false], "death": [6, 8.0, false],
	},
}

var _failures: Array[String] = []
var _validated_frames: int = 0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	for enemy_name: String in DEFINITIONS:
		_validate_enemy(enemy_name, DEFINITIONS[enemy_name])
	_validate_shield_break_effect()
	_validate_bolt()
	_finish()


func _validate_enemy(enemy_name: String, definitions: Dictionary) -> void:
	var frames_path: String = "res://resources/enemies/%s_sprite_frames.tres" % enemy_name
	var sprite_frames: SpriteFrames = load(frames_path) as SpriteFrames
	_expect(sprite_frames != null, "Cannot load %s" % frames_path)
	if sprite_frames == null:
		return
	for animation_name: String in definitions:
		var metadata: Array = definitions[animation_name] as Array
		var count: int = metadata[0] as int
		var speed: float = metadata[1] as float
		var looping: bool = metadata[2] as bool
		var animation: StringName = StringName(animation_name)
		_expect(sprite_frames.has_animation(animation), "%s lacks %s" % [enemy_name, animation_name])
		_expect(sprite_frames.get_frame_count(animation) == count, "%s/%s frame count mismatch" % [enemy_name, animation_name])
		_expect(is_equal_approx(sprite_frames.get_animation_speed(animation), speed), "%s/%s FPS mismatch" % [enemy_name, animation_name])
		_expect(sprite_frames.get_animation_loop(animation) == looping, "%s/%s loop mismatch" % [enemy_name, animation_name])
		for frame_index: int in range(count):
			_validate_png(enemy_name, animation_name, frame_index + 1)
	if enemy_name == "cursed_shield_guard":
		var guard_break_duration: float = 0.0
		var guard_break_speed: float = sprite_frames.get_animation_speed(&"guard_break")
		for frame_index: int in range(sprite_frames.get_frame_count(&"guard_break")):
			guard_break_duration += (
				sprite_frames.get_frame_duration(&"guard_break", frame_index) / guard_break_speed
			)
		_expect(
			is_equal_approx(guard_break_duration, 0.70),
			"Shield GuardBreak animation duration is not 0.70 seconds"
		)


func _validate_png(enemy_name: String, animation_name: String, frame_number: int) -> void:
	var path: String = ROOT.path_join(enemy_name).path_join(animation_name).path_join(
		"%s_%02d.png" % [animation_name, frame_number]
	)
	_expect(FileAccess.file_exists(path), "Missing %s" % path)
	if not FileAccess.file_exists(path):
		return
	var image: Image = Image.new()
	var error: Error = image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	_expect(error == OK, "Cannot decode %s" % path)
	if error != OK:
		return
	_validated_frames += 1
	_expect(image.get_size() == Vector2i(64, 64), "%s is not 64x64" % path)
	_expect(_visible_pixel_count(image) > 0, "%s is empty" % path)
	_expect(_has_transparency(image), "%s lacks transparent background" % path)
	var reduced: Image = image.duplicate()
	reduced.resize(48, 48, Image.INTERPOLATE_NEAREST)
	_expect(_visible_pixel_count(reduced) >= 12, "%s is unreadable at 48x48" % path)
	var import_path: String = path + ".import"
	_expect(FileAccess.file_exists(import_path), "%s import sidecar missing" % path)
	if FileAccess.file_exists(import_path):
		var import_text: String = FileAccess.get_file_as_string(import_path)
		_expect(import_text.contains("compress/mode=0"), "%s is not lossless" % path)
		_expect(import_text.contains("mipmaps/generate=false"), "%s enables mipmaps" % path)


func _validate_bolt() -> void:
	var path: String = "res://assets/sprites/projectiles/crossbow_bolt.png"
	var image: Image = Image.new()
	var error: Error = image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	_expect(error == OK, "Cannot decode crossbow bolt")
	if error == OK:
		_expect(image.get_size() == Vector2i(24, 8), "Crossbow bolt size mismatch")
		_expect(_has_transparency(image), "Crossbow bolt lacks transparency")


func _validate_shield_break_effect() -> void:
	var frames_path: String = (
		"res://resources/enemies/cursed_shield_guard_shield_break_fx_sprite_frames.tres"
	)
	var frames: SpriteFrames = load(frames_path) as SpriteFrames
	_expect(frames != null, "Cannot load Shield Guard break effect SpriteFrames")
	if frames != null:
		_expect(frames.has_animation(&"shield_break"), "Shield break effect animation is missing")
		_expect(frames.get_frame_count(&"shield_break") == 4, "Shield break effect is not four frames")
		_expect(not frames.get_animation_loop(&"shield_break"), "Shield break effect unexpectedly loops")
	for frame_number: int in range(1, 5):
		_validate_png("cursed_shield_guard", "shield_break_fx", frame_number)


func _visible_pixel_count(image: Image) -> int:
	var count: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.01:
				count += 1
	return count


func _has_transparency(image: Image) -> bool:
	return _visible_pixel_count(image) < image.get_width() * image.get_height()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("ENEMY_VARIETY_ASSET_TEST: PASS (%d 64x64 frames + bolt, lossless/no mipmaps, 48px floor)" % _validated_frames)
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("ENEMY_VARIETY_ASSET_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
