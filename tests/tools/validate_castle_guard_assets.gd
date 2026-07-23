extends SceneTree

## Validates Castle Guard production PNGs, imports, timings, and scene composition.

const FRAMES_PATH: String = "res://resources/enemies/castle_guard_sprite_frames.tres"
const SCENE: PackedScene = preload("res://scenes/enemies/castle_guard.tscn")
const ANIMATION_COUNTS: Dictionary[StringName, int] = {
	&"idle": 4,
	&"walk": 6,
	&"attack": 5,
	&"hurt": 3,
	&"death": 6,
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var sprite_frames: SpriteFrames = load(FRAMES_PATH) as SpriteFrames
	_expect(sprite_frames != null, "Castle Guard SpriteFrames resource did not load")
	if sprite_frames != null:
		_validate_sprite_frames(sprite_frames)
	_validate_sources()
	await _validate_scene()
	_finish()


func _validate_sprite_frames(sprite_frames: SpriteFrames) -> void:
	for animation_name: StringName in ANIMATION_COUNTS:
		_expect(sprite_frames.has_animation(animation_name), "Missing animation %s" % animation_name)
		_expect(
			sprite_frames.get_frame_count(animation_name) == ANIMATION_COUNTS[animation_name],
			"Wrong frame count for %s" % animation_name
		)
	_expect(sprite_frames.get_animation_loop(&"idle"), "idle is not looping")
	_expect(sprite_frames.get_animation_loop(&"walk"), "walk is not looping")
	for animation_name: StringName in [&"attack", &"hurt", &"death"]:
		_expect(not sprite_frames.get_animation_loop(animation_name), "%s incorrectly loops" % animation_name)
	var attack_duration: float = 0.0
	for frame_index: int in range(sprite_frames.get_frame_count(&"attack")):
		attack_duration += sprite_frames.get_frame_duration(&"attack", frame_index) / sprite_frames.get_animation_speed(&"attack")
	_expect(is_equal_approx(attack_duration, 0.90), "Attack total is not 0.90 seconds")
	var active_duration: float = (
		sprite_frames.get_frame_duration(&"attack", 2)
		+ sprite_frames.get_frame_duration(&"attack", 3)
	) / sprite_frames.get_animation_speed(&"attack")
	_expect(is_equal_approx(active_duration, 0.10), "Attack active frames are not 0.10 seconds")


func _validate_sources() -> void:
	for animation_name: StringName in ANIMATION_COUNTS:
		for frame_index: int in range(ANIMATION_COUNTS[animation_name]):
			var image_path: String = "res://assets/sprites/enemies/castle_guard/%s/%s_%02d.png" % [
				animation_name,
				animation_name,
				frame_index + 1,
			]
			_expect(FileAccess.file_exists(image_path), "Missing source %s" % image_path)
			var image: Image = Image.new()
			var image_error: Error = image.load_png_from_buffer(
				FileAccess.get_file_as_bytes(image_path)
			)
			_expect(image_error == OK, "Could not decode %s" % image_path)
			_expect(image != null and image.get_size() == Vector2i(64, 64), "%s is not 64x64" % image_path)
			_expect(_has_transparency(image), "%s has no transparent background" % image_path)
			var import_path: String = image_path + ".import"
			_expect(FileAccess.file_exists(import_path), "Missing import sidecar %s" % import_path)
			if FileAccess.file_exists(import_path):
				var import_text: String = FileAccess.get_file_as_string(import_path)
				_expect(import_text.contains("compress/mode=0"), "%s is not lossless" % import_path)
				_expect(import_text.contains("mipmaps/generate=false"), "%s enables mipmaps" % import_path)


func _validate_scene() -> void:
	var guard: CastleGuard = SCENE.instantiate() as CastleGuard
	get_root().add_child(guard)
	await process_frame
	_expect(guard != null, "Castle Guard scene did not instantiate")
	if guard != null:
		_expect(guard.texture_filter == CanvasItem.TEXTURE_FILTER_PARENT_NODE, "Unexpected root texture filter override")
		_expect(guard.animated_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Guard sprite is not nearest-filtered")
		_expect(guard.health_component.max_health == 3, "Guard max Health is not three")
		_expect(guard.hurtbox != null, "Guard Hurtbox is missing")
		_expect(guard.attack_hitbox != null, "Guard AttackHitbox is missing")
		_expect(guard.state_machine != null, "Guard StateMachine is missing")
		guard.queue_free()
	await process_frame


func _has_transparency(image: Image) -> bool:
	if image == null:
		return false
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a < 1.0:
				return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CASTLE_GUARD_ASSET_TEST: PASS (24 PNGs, imports, 5 animations, timing, scene)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CASTLE_GUARD_ASSET_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
