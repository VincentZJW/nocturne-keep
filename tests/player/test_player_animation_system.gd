extends SceneTree

## Headless contract tests for SpriteFrames metadata and PlayerAnimationController.

const SpriteFramesBuilder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")
const ControllerScript: Script = preload("res://scripts/player/player_animation_controller.gd")
const RESOURCE_PATH: String = "res://resources/player/player_sprite_frames.tres"

var _failures: Array[String] = []
var _finished_events: Array[StringName] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var sprite_frames: SpriteFrames = load(RESOURCE_PATH) as SpriteFrames
	if sprite_frames == null:
		_failures.append("SpriteFrames resource is missing or unreadable")
		_finish()
		return
	_validate_resource(sprite_frames)
	_validate_source_frames(sprite_frames)
	await _validate_controller(sprite_frames)
	_finish()


func _validate_resource(sprite_frames: SpriteFrames) -> void:
	var actual_names: PackedStringArray = sprite_frames.get_animation_names()
	for animation_name: StringName in SpriteFramesBuilder.ANIMATION_ORDER:
		_expect(actual_names.has(str(animation_name)), "Missing animation: %s" % animation_name)
		_expect(
			sprite_frames.get_frame_count(animation_name) == SpriteFramesBuilder.FRAME_COUNTS[animation_name],
			"Wrong frame count for %s" % animation_name
		)
		_expect(
			is_equal_approx(sprite_frames.get_animation_speed(animation_name), SpriteFramesBuilder.SPEEDS[animation_name]),
			"Wrong FPS for %s" % animation_name
		)
		_expect(
			sprite_frames.get_animation_loop(animation_name) == SpriteFramesBuilder.LOOPING[animation_name],
			"Wrong loop flag for %s" % animation_name
		)
	for actual_name: String in actual_names:
		_expect(StringName(actual_name) in SpriteFramesBuilder.ANIMATION_ORDER, "Unexpected animation name: %s" % actual_name)
	_expect(sprite_frames.get_animation_loop(&"dash_loop"), "dash_loop is not configured to loop")
	_expect(not sprite_frames.get_animation_loop(&"dash_start"), "dash_start unexpectedly loops")
	_expect(not sprite_frames.get_animation_loop(&"dash_end"), "dash_end unexpectedly loops")


func _validate_source_frames(sprite_frames: SpriteFrames) -> void:
	for animation_name: StringName in SpriteFramesBuilder.ANIMATION_ORDER:
		for frame_index: int in range(sprite_frames.get_frame_count(animation_name)):
			var texture: Texture2D = sprite_frames.get_frame_texture(animation_name, frame_index)
			_expect(texture != null, "Null frame texture: %s[%d]" % [animation_name, frame_index])
			if texture == null:
				continue
			var image: Image = texture.get_image()
			_expect(image.get_size() == Vector2i(64, 64), "Wrong texture size: %s[%d]" % [animation_name, frame_index])
			_expect(not image.has_mipmaps(), "Mipmaps enabled: %s[%d]" % [animation_name, frame_index])
			_expect(_has_binary_alpha(image), "Non-binary or empty alpha: %s[%d]" % [animation_name, frame_index])
	for grounded_animation: StringName in [
		&"idle", &"run", &"dash_start", &"dash_loop", &"dash_end", &"attack",
		&"dash_attack", &"land", &"hurt",
	]:
		for frame_index: int in range(sprite_frames.get_frame_count(grounded_animation)):
			var image: Image = sprite_frames.get_frame_texture(grounded_animation, frame_index).get_image()
			_expect(
				_visible_bottom(image) == 60,
				"Ground baseline changed: %s[%d] bottom=%d" % [grounded_animation, frame_index, _visible_bottom(image)]
			)


func _validate_controller(sprite_frames: SpriteFrames) -> void:
	var player: Node2D = Node2D.new()
	player.name = "Player"
	var visual_root: Node2D = Node2D.new()
	visual_root.name = "VisualRoot"
	var sprite: AnimatedSprite2D = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.sprite_frames = sprite_frames
	visual_root.add_child(sprite)
	player.add_child(visual_root)
	var controller: PlayerAnimationController = ControllerScript.new() as PlayerAnimationController
	controller.name = "AnimationController"
	player.add_child(controller)
	get_root().add_child(player)
	await process_frame
	controller.one_shot_finished.connect(_on_one_shot_finished)
	_expect(sprite.animation == &"idle" and sprite.is_playing(), "Controller did not initialize idle")

	_expect(controller.play_loop(&"run"), "Run request was rejected")
	sprite.frame = 3
	_expect(not controller.play_loop(&"run"), "Repeated run request restarted the same animation")
	_expect(sprite.frame == 3, "Repeated run request reset the current frame")
	controller.reset_to_idle()
	_expect(controller.play_loop(&"fall"), "Fall loop request was rejected")
	_expect(not controller.play_loop(&"run"), "Run overrode higher-priority fall")
	_expect(controller.play_loop(&"run", true), "Authorized loop priority release was rejected")

	controller.reset_to_idle()
	_expect(controller.play_one_shot(&"attack"), "Attack request was rejected")
	_expect(controller.is_animation_locked(), "Attack did not lock animation")
	_expect(controller.is_facing_locked(), "Attack did not lock facing")
	_expect(not controller.play_loop(&"run"), "Run overrode attack")
	_expect(not controller.play_one_shot(&"dash_start"), "Dash start overrode higher-priority attack")
	_expect(not controller.play_one_shot(&"air_dash"), "Air Dash overrode higher-priority attack")
	_expect(controller.play_one_shot(&"dash_attack"), "Dash Attack did not override lower-priority attack")
	_expect(controller.play_one_shot(&"hurt"), "Hurt did not override attack")
	_expect(not controller.play_one_shot(&"attack"), "Attack overrode hurt")

	controller.reset_to_idle()
	controller.set_facing_left(false)
	sprite.speed_scale = 100.0
	_finished_events.clear()
	_expect(controller.play_one_shot(&"dash_start"), "Dash start request was rejected")
	var position_before_flip: Vector2 = sprite.position
	_expect(not controller.set_facing_left(true), "Facing changed during dash lock")
	_expect(not sprite.flip_h, "flip_h changed before dash finished")
	await create_timer(0.08).timeout
	_expect(_finished_events.has(&"dash_start"), "Dash start did not emit one_shot_finished")
	_expect(sprite.frame == 1, "Dash start did not reach its second frame")
	_expect(sprite.flip_h, "Queued facing was not applied after Ground Dash")
	_expect(sprite.position == position_before_flip, "Horizontal flip moved the sprite node")
	controller.set_facing_left(false)
	_expect(controller.transition_locked_animation(&"dash_loop"), "Locked dash_loop transition failed")
	_expect(controller.is_animation_locked() and controller.is_facing_locked(), "dash_loop lost Dash locks")
	_expect(controller.transition_locked_animation(&"dash_end"), "Locked dash_end transition failed")
	await create_timer(0.08).timeout
	_expect(_finished_events.has(&"dash_end"), "Dash end did not emit one_shot_finished")

	controller.reset_to_idle()
	_finished_events.clear()
	_expect(controller.play_one_shot(&"air_dash"), "Air Dash request was rejected")
	await create_timer(0.08).timeout
	_expect(_finished_events.has(&"air_dash"), "Air Dash did not emit one_shot_finished")
	_expect(sprite.frame == 4, "Air Dash did not reach its fifth frame")

	controller.reset_to_idle()
	_finished_events.clear()
	_expect(controller.play_one_shot(&"attack"), "Attack replay request was rejected")
	await create_timer(0.08).timeout
	_expect(_finished_events.has(&"attack"), "Attack did not emit one_shot_finished")
	_expect(sprite.frame == 3, "Attack did not reach its fourth frame")
	sprite.animation = &"attack"
	sprite.frame = 1
	_expect(controller.is_attack_hit_window(), "attack_02 is not in reserved hit window")
	sprite.frame = 2
	_expect(controller.is_attack_hit_window(), "attack_03 is not in reserved hit window")
	sprite.frame = 3
	_expect(not controller.is_attack_hit_window(), "attack_04 incorrectly remains in hit window")
	controller.reset_to_idle()
	_expect(controller.play_one_shot(&"attack"), "Attack restart setup was rejected")
	sprite.frame = 2
	_expect(controller.restart_locked_one_shot(&"attack"), "Authorized Attack chain restart was rejected")
	_expect(sprite.frame == 0 and controller.is_animation_locked(), "Attack chain restart lost frame zero or lock")

	controller.reset_to_idle()
	_finished_events.clear()
	_expect(controller.play_one_shot(&"dash_attack"), "Dash Attack request was rejected")
	await create_timer(0.08).timeout
	_expect(_finished_events.has(&"dash_attack"), "Dash Attack did not emit one_shot_finished")
	_expect(sprite.frame == 4, "Dash Attack did not reach its fifth frame")
	sprite.animation = &"dash_attack"
	for active_frame: int in [2, 3]:
		sprite.frame = active_frame
		_expect(controller.is_dash_attack_hit_window(), "Dash Attack active frame is missing")
	sprite.frame = 1
	_expect(not controller.is_dash_attack_hit_window(), "dash_attack_02 entered the future hit window")
	sprite.frame = 4
	_expect(not controller.is_dash_attack_hit_window(), "dash_attack_05 entered the future hit window")

	controller.reset_to_idle()
	_finished_events.clear()
	sprite.speed_scale = 100.0
	await create_timer(0.05).timeout
	_expect(_finished_events.is_empty(), "Loop animation emitted one_shot_finished")
	controller.play_one_shot(&"death")
	await create_timer(0.14).timeout
	_expect(_finished_events.has(&"death"), "Death did not emit one_shot_finished")
	_expect(controller.is_animation_locked(), "Death lock was released after completion")
	_expect(not controller.play_loop(&"idle"), "Idle overrode completed death")
	player.queue_free()


func _has_binary_alpha(image: Image) -> bool:
	var visible_pixels: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var alpha: float = image.get_pixel(x, y).a
			if alpha > 0.0:
				visible_pixels += 1
				if not is_equal_approx(alpha, 1.0):
					return false
	return visible_pixels > 0


func _visible_bottom(image: Image) -> int:
	for y: int in range(image.get_height() - 1, -1, -1):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.0:
				return y
	return -1


func _on_one_shot_finished(animation_name: StringName) -> void:
	_finished_events.append(animation_name)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PLAYER_ANIMATION_SYSTEM_TEST: PASS (14 animations, segmented Dash locks/signals verified)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("PLAYER_ANIMATION_SYSTEM_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
