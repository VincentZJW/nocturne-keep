extends SceneTree

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep"
const SCENE_PATH: String = ROOT + "/scenes/enemies/mirefin_raider.tscn"
const CONCEPT_PATH: String = ROOT + "/assets/enemies/mirefin_raider/concept_art/mirefin_raider_concept_sheet.png"
const FRAME_ROOT: String = ROOT + "/assets/enemies/mirefin_raider/sprites"
const EXPECTED_SIZE: Vector2i = Vector2i(128, 128)
const EXPECTED_ANIMATIONS: Dictionary = {
	"idle": 4,
	"walk": 6,
	"alert": 3,
	"turn": 3,
	"light_hit": 2,
	"stagger": 4,
	"hurt": 3,
	"death": 6,
	"claw_swipe_windup": 5,
	"claw_swipe_active": 2,
	"claw_swipe_recovery": 5,
	"mire_lunge_windup": 5,
	"mire_lunge_active": 2,
	"mire_lunge_recovery": 5,
	"fin_bite_windup": 5,
	"fin_bite_active": 2,
	"fin_bite_recovery": 5,
}

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(FileAccess.file_exists(CONCEPT_PATH), "primary concept exists")
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	_expect(packed != null, "formal Mirefin scene loads")
	if packed == null:
		_finish()
		return
	var enemy: Chapter04Enemy = packed.instantiate() as Chapter04Enemy
	_expect(enemy != null, "formal Mirefin scene instantiates")
	if enemy == null:
		_finish()
		return
	root.add_child(enemy)
	await process_frame
	_expect(enemy.animated_sprite.position == Vector2(0.0, -38.0), "visual anchor remains stable")
	var body_shape: CollisionShape2D = enemy.get_node("CollisionShape2D") as CollisionShape2D
	var hurtbox_shape: CollisionShape2D = enemy.get_node("Hurtbox/CollisionShape2D") as CollisionShape2D
	_expect(body_shape.position == Vector2(0.0, -30.0), "body collision remains stable")
	_expect(hurtbox_shape.position == Vector2(0.0, -30.0), "hurtbox anchor remains stable")
	var frames: SpriteFrames = enemy.animated_sprite.sprite_frames
	var total_frames: int = 0
	for animation_variant: Variant in EXPECTED_ANIMATIONS.keys():
		var animation: StringName = StringName(str(animation_variant))
		var expected_count: int = int(EXPECTED_ANIMATIONS[animation_variant])
		_expect(frames.has_animation(animation), "%s animation exists" % animation)
		if not frames.has_animation(animation):
			continue
		_expect(frames.get_frame_count(animation) == expected_count, "%s keeps %d frames" % [animation, expected_count])
		for frame_index: int in range(frames.get_frame_count(animation)):
			var texture: Texture2D = frames.get_frame_texture(animation, frame_index)
			var image: Image = texture.get_image()
			_expect(image.get_size() == EXPECTED_SIZE, "%s[%d] is 128x128" % [animation, frame_index])
			_expect(is_zero_approx(image.get_pixel(0, 0).a), "%s[%d] has transparent corner" % [animation, frame_index])
			_expect(_opaque_pixel_count(image) >= 240, "%s[%d] retains complete creature mass" % [animation, frame_index])
			total_frames += 1
	_expect(total_frames == 67, "all 67 formal frames are audited")
	var idle: Image = frames.get_frame_texture(&"idle", 0).get_image()
	_expect(_opaque_in_rect(idle, Rect2i(28, 8, 50, 35)) >= 110, "idle retains complete dorsal ridge")
	_expect(_opaque_in_rect(idle, Rect2i(78, 18, 42, 35)) >= 170, "idle retains long skull, jaws and teeth")
	_expect(_opaque_in_rect(idle, Rect2i(66, 38, 24, 26)) >= 90, "idle retains exposed gill cage")
	_expect(_opaque_in_rect(idle, Rect2i(4, 88, 38, 22)) >= 45, "idle retains ankle chain and rear claw")
	_expect(_opaque_in_rect(idle, Rect2i(82, 72, 44, 34)) >= 55, "idle retains four-finger near claw")
	var trial_source: String = FileAccess.get_file_as_string(ROOT + "/scenes/trials/chapter_04_character_trial.tscn")
	_expect(trial_source.contains("mirefin_raider.tscn"), "formal Main trial uses Mirefin PackedScene")
	_expect(not trial_source.contains("mirefin_raider/archive_legacy"), "Main trial has zero legacy Mirefin references")
	var scene_source: String = FileAccess.get_file_as_string(SCENE_PATH)
	_expect(not scene_source.contains("archive_legacy"), "formal Mirefin scene has zero legacy references")
	enemy.queue_free()
	await process_frame
	_finish()


func _opaque_pixel_count(image: Image) -> int:
	return _opaque_in_rect(image, Rect2i(Vector2i.ZERO, image.get_size()))


func _opaque_in_rect(image: Image, rect: Rect2i) -> int:
	var count: int = 0
	var clipped: Rect2i = rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	for y: int in range(clipped.position.y, clipped.end.y):
		for x: int in range(clipped.position.x, clipped.end.x):
			if image.get_pixel(x, y).a > 0.05:
				count += 1
	return count


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error(message)


func _finish() -> void:
	print("MIRE FIN REPLICATION TEST | %s" % ("PASS" if _failures == 0 else "FAIL %d" % _failures))
	quit(0 if _failures == 0 else 1)
