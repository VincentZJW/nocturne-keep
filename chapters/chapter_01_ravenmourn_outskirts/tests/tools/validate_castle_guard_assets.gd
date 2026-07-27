extends SceneTree

## Validates Castle Guard production PNGs, imports, timings, and scene composition.

const FRAMES_PATH: String = "res://chapters/chapter_01_ravenmourn_outskirts/resources/enemies/castle_guard_sprite_frames.tres"
const ASSET_ROOT: String = "res://chapters/chapter_01_ravenmourn_outskirts/assets/enemies/castle_guard"
const REFERENCE_PATH: String = (
	ASSET_ROOT + "/reference/cursed_castle_guard_reference.png"
)
const SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn")
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
	_validate_reference()
	_validate_attack_art()
	_validate_death_dissolve()
	_validate_grounded_baselines()
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
			var image_path: String = ASSET_ROOT + "/%s/%s_%02d.png" % [
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


func _validate_reference() -> void:
	_expect(FileAccess.file_exists(REFERENCE_PATH), "Missing Cursed Castle Guard reference image")
	var reference: Image = _load_png(REFERENCE_PATH)
	_expect(reference != null, "Could not decode Cursed Castle Guard reference image")
	if reference != null:
		_expect(reference.get_size() == Vector2i(816, 552), "Reference image size changed unexpectedly")
	var import_path: String = REFERENCE_PATH + ".import"
	_expect(FileAccess.file_exists(import_path), "Reference image import sidecar is missing")
	if FileAccess.file_exists(import_path):
		var import_text: String = FileAccess.get_file_as_string(import_path)
		_expect(import_text.contains("compress/mode=0"), "Reference image is not lossless")
		_expect(import_text.contains("mipmaps/generate=false"), "Reference image enables mipmaps")


func _validate_attack_art() -> void:
	var attack_03: Image = _load_png(ASSET_ROOT + "/attack/attack_03.png")
	var attack_04: Image = _load_png(ASSET_ROOT + "/attack/attack_04.png")
	_expect(attack_03 != null and attack_04 != null, "Could not load active Attack art")
	if attack_03 == null or attack_04 == null:
		return
	var steel: Color = Color("bac4c5")
	_expect(
		_count_color_in_rect(attack_03, steel, Rect2i(48, 38, 16, 19)) >= 5,
		"attack_03 does not carry a readable downward-forward steel blade"
	)
	_expect(
		_count_color_in_rect(attack_04, steel, Rect2i(48, 40, 16, 19)) >= 5,
		"attack_04 does not extend the heavy sword cut"
	)


func _validate_death_dissolve() -> void:
	var grounded: Image = _load_png(ASSET_ROOT + "/death/death_04.png")
	var dissolving: Image = _load_png(ASSET_ROOT + "/death/death_05.png")
	var fragments: Image = _load_png(ASSET_ROOT + "/death/death_06.png")
	_expect(grounded != null and dissolving != null and fragments != null, "Could not load Death art")
	if grounded == null or dissolving == null or fragments == null:
		return
	var grounded_pixels: int = _count_visible_pixels(grounded)
	var dissolving_pixels: int = _count_visible_pixels(dissolving)
	var fragment_pixels: int = _count_visible_pixels(fragments)
	_expect(_lowest_visible_y(grounded) >= 59, "death_04 is not visibly grounded")
	_expect(dissolving_pixels < grounded_pixels, "death_05 does not remove body pixels")
	_expect(fragment_pixels > 0, "death_06 has no final dissolve fragments")
	_expect(fragment_pixels * 4 < dissolving_pixels, "death_06 still reads as a complete corpse")
	_expect(_maximum_alpha(dissolving) < 0.80, "death_05 does not visibly fade")


func _validate_grounded_baselines() -> void:
	for animation_name: StringName in [&"idle", &"walk", &"attack", &"hurt"]:
		for frame_index: int in range(ANIMATION_COUNTS[animation_name]):
			var image_path: String = ASSET_ROOT + "/%s/%s_%02d.png" % [
				animation_name,
				animation_name,
				frame_index + 1,
			]
			var frame: Image = _load_png(image_path)
			_expect(frame != null, "Could not load baseline frame %s" % image_path)
			if frame != null:
				_expect(_lowest_visible_y(frame) == 60, "%s changed the shared foot baseline" % image_path)


func _validate_scene() -> void:
	var guard: CastleGuard = SCENE.instantiate() as CastleGuard
	get_root().add_child(guard)
	await process_frame
	_expect(guard != null, "Castle Guard scene did not instantiate")
	if guard != null:
		_expect(guard.texture_filter == CanvasItem.TEXTURE_FILTER_PARENT_NODE, "Unexpected root texture filter override")
		_expect(guard.animated_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Guard sprite is not nearest-filtered")
		_expect(guard.health_component.max_health == 30, "Guard max Health is not thirty")
		_expect(guard.hurtbox != null, "Guard Hurtbox is missing")
		_expect(guard.attack_hitbox != null, "Guard AttackHitbox is missing")
		_expect(guard.state_machine != null, "Guard StateMachine is missing")
		_expect(guard.find_child("*Ghost*", true, false) == null, "Enemy scene contains a Player-style ghost")
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


func _load_png(image_path: String) -> Image:
	if not FileAccess.file_exists(image_path):
		return null
	var image: Image = Image.new()
	var image_error: Error = image.load_png_from_buffer(FileAccess.get_file_as_bytes(image_path))
	return image if image_error == OK else null


func _count_visible_pixels(image: Image) -> int:
	var count: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.01:
				count += 1
	return count


func _lowest_visible_y(image: Image) -> int:
	var lowest: int = -1
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.01:
				lowest = maxi(lowest, y)
	return lowest


func _maximum_alpha(image: Image) -> float:
	var maximum: float = 0.0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			maximum = maxf(maximum, image.get_pixel(x, y).a)
	return maximum


func _count_color_in_rect(image: Image, color: Color, rect: Rect2i) -> int:
	var count: int = 0
	var clipped: Rect2i = rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	for y: int in range(clipped.position.y, clipped.end.y):
		for x: int in range(clipped.position.x, clipped.end.x):
			if image.get_pixel(x, y).is_equal_approx(color):
				count += 1
	return count


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CASTLE_GUARD_ASSET_TEST: PASS (24 frames + reference, heavy cut, dissolve, timing, scene)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CASTLE_GUARD_ASSET_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
