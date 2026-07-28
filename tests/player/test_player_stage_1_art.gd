extends SceneTree

const Builder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const RESOURCES: Array[String] = [
	"res://resources/player/player_sprite_frames.tres",
	"res://resources/player/ravenfang_player_sprite_frames.tres",
	"res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_player_sprite_frames.tres",
]
const REQUIRED_CONCEPTS: Array[String] = [
	"night_warden_front_concept.png", "night_warden_combat_side_concept.png",
	"night_warden_back_concept.png", "night_warden_three_quarter_concept.png",
	"night_warden_silhouette.png", "night_warden_guard_scale_comparison.png",
	"night_warden_outfit_breakdown.png", "night_warden_hood_detail.png",
	"night_warden_dual_dagger_pose_sheet.png", "night_warden_animation_pose_sheet.png",
]
const REQUIRED_REVIVAL_POSES: Array[String] = [
	"revival_corpse.png", "revival_twitch.png", "revival_breath.png",
	"revival_sit_up.png", "revival_look_hands.png", "revival_kneel.png",
	"revival_stand.png", "revival_unarmed.png",
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_validate_concepts()
	_validate_revival_poses()
	for resource_path: String in RESOURCES:
		_validate_sprite_frames(resource_path)
	await _validate_player_scene()
	_finish()


func _validate_concepts() -> void:
	for file_name: String in REQUIRED_CONCEPTS:
		var path: String = "res://shared/assets/player/concept_art/" + file_name
		_expect(FileAccess.file_exists(path), "Missing concept deliverable: %s" % path)


func _validate_revival_poses() -> void:
	for file_name: String in REQUIRED_REVIVAL_POSES:
		var path: String = "res://shared/assets/player/revival/" + file_name
		_expect(FileAccess.file_exists(path), "Missing revival pose: %s" % path)
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		_expect(image != null and image.get_size() == Vector2i(64, 64), "Invalid revival pose: %s" % path)


func _validate_sprite_frames(resource_path: String) -> void:
	var frames: SpriteFrames = load(resource_path) as SpriteFrames
	_expect(frames != null, "Missing SpriteFrames: %s" % resource_path)
	if frames == null:
		return
	for animation_name: StringName in Builder.ANIMATION_ORDER:
		_expect(frames.has_animation(animation_name), "%s missing %s" % [resource_path, animation_name])
		if not frames.has_animation(animation_name):
			continue
		_expect(
			frames.get_frame_count(animation_name) == Builder.FRAME_COUNTS[animation_name],
			"%s wrong count for %s" % [resource_path, animation_name]
		)
		for frame_index: int in range(frames.get_frame_count(animation_name)):
			var texture: Texture2D = frames.get_frame_texture(animation_name, frame_index)
			_expect(texture != null, "%s %s[%d] is null" % [resource_path, animation_name, frame_index])
			if texture == null:
				continue
			var image: Image = texture.get_image()
			_expect(image.get_size() == Vector2i(64, 64), "%s %s[%d] is not 64x64" % [resource_path, animation_name, frame_index])
			_expect(not image.has_mipmaps(), "%s %s[%d] has mipmaps" % [resource_path, animation_name, frame_index])
	var idle: Image = frames.get_frame_texture(&"idle", 0).get_image()
	var visible_height: int = _visible_bottom(idle) - _visible_top(idle) + 1
	_expect(visible_height >= 55 and visible_height <= 61, "%s idle height %d is outside target" % [resource_path, visible_height])
	for variant: StringName in [&"attack_1", &"attack_2", &"attack_3"]:
		_expect(
			frames.get_frame_texture(variant, 2).get_image().get_data()
			!= frames.get_frame_texture(&"idle", 0).get_image().get_data(),
			"%s %s lacks a distinct silhouette" % [resource_path, variant]
		)
	_expect(
		frames.get_frame_texture(&"attack_1", 2).get_image().get_data()
		!= frames.get_frame_texture(&"attack_2", 2).get_image().get_data(),
		"%s Attack 1 and Attack 2 are visually identical" % resource_path
	)
	_expect(
		frames.get_frame_texture(&"attack_2", 2).get_image().get_data()
		!= frames.get_frame_texture(&"attack_3", 2).get_image().get_data(),
		"%s Attack 2 and Attack 3 are visually identical" % resource_path
	)


func _validate_player_scene() -> void:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	await process_frame
	_expect(player != null, "Player scene did not instantiate")
	if player == null:
		return
	var body_shape: RectangleShape2D = player.get_node("CollisionShape2D").shape as RectangleShape2D
	var hurt_shape: RectangleShape2D = player.get_node("Hurtbox/CollisionShape2D").shape as RectangleShape2D
	var attack_shape: RectangleShape2D = player.get_node("CombatRoot/AttackHitbox/CollisionShape2D").shape as RectangleShape2D
	var dash_shape: RectangleShape2D = player.get_node("CombatRoot/DashAttackHitbox/CollisionShape2D").shape as RectangleShape2D
	_expect(body_shape.size == Vector2(24, 52), "Player body collision changed")
	_expect(hurt_shape.size == Vector2(22, 50), "Player Hurtbox changed")
	_expect(attack_shape.size == Vector2(42, 14), "Normal Attack reach changed")
	_expect(dash_shape.size == Vector2(58, 16), "Dash Attack reach changed")
	var frames: SpriteFrames = player.animation_controller.animated_sprite.sprite_frames
	var attack_one: Texture2D = frames.get_frame_texture(&"attack_1", 2)
	var attack_two: Texture2D = frames.get_frame_texture(&"attack_2", 2)
	_expect(player.animation_controller.select_attack_variant(1), "Attack 1 variant routing failed")
	_expect(frames.get_frame_texture(&"attack", 2) == attack_one, "Attack 1 did not route to gameplay animation")
	_expect(player.animation_controller.select_attack_variant(2), "Attack 2 variant routing failed")
	_expect(frames.get_frame_texture(&"attack", 2) == attack_two, "Attack 2 did not route to gameplay animation")
	player.queue_free()


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


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PLAYER_STAGE_1_ART_TEST: PASS concepts=10 revival=8 resources=3 animations=30 collisions=preserved")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)
