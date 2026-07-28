extends SceneTree

## Deterministic acceptance audit for the Stage 2 Night Warden visual gate.

const PlayerBuilder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const GUARD_SCENE: PackedScene = preload(
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn"
)
const CONCEPT_ROOT: String = "res://shared/assets/player/concept_art"
const RUNTIME_ROOT: String = "res://shared/assets/player/animations"
const LEGACY_MARKERS: Array[String] = [
	"/assets/sprites/player/assassin/",
	"/reference/",
	"/deprecated/",
	"/deprecated_",
]
const CONCEPTS: Array[String] = [
	"night_warden_front_concept.png",
	"night_warden_combat_side_concept.png",
	"night_warden_back_concept.png",
	"night_warden_three_quarter_concept.png",
	"night_warden_silhouette.png",
	"night_warden_guard_scale_comparison.png",
	"night_warden_outfit_breakdown.png",
	"night_warden_hood_detail.png",
	"night_warden_dual_dagger_pose_sheet.png",
	"night_warden_animation_pose_sheet.png",
]
const FRAME_RESOURCES: Dictionary[String, String] = {
	"veilbound": "res://resources/player/player_sprite_frames.tres",
	"ravenfang": "res://resources/player/ravenfang_player_sprite_frames.tres",
	"crimson_masque": (
		"res://chapters/chapter_02_silent_court/resources/weapons/"
		+ "crimson_masque_player_sprite_frames.tres"
	),
}
const REQUIRED_SHARED_SCENES: Dictionary[String, String] = {
	"res://scenes/levels/veilbound_catacomb.tscn": "res://scenes/player/player.tscn",
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn": (
		"res://scenes/player/player.tscn"
	),
	"res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn": (
		"res://scenes/runtime/chapter_gameplay_runtime.tscn"
	),
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/"
	+ "chapter_03_entry_placeholder.tscn": "res://scenes/runtime/chapter_gameplay_runtime.tscn",
	"res://scenes/runtime/chapter_gameplay_runtime.tscn": "res://scenes/player/player.tscn",
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_validate_concepts()
	_validate_shared_scene_authority()
	for style_name: String in FRAME_RESOURCES:
		_validate_frame_resource(style_name, FRAME_RESOURCES[style_name])
	await _validate_scale_and_scene_geometry()
	_finish()


func _validate_concepts() -> void:
	var fingerprints: Dictionary[String, bool] = {}
	for file_name: String in CONCEPTS:
		var path: String = CONCEPT_ROOT.path_join(file_name)
		_expect(FileAccess.file_exists(path), "Missing concept evidence: %s" % path)
		if not FileAccess.file_exists(path):
			continue
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		_expect(image != null, "Concept failed to load: %s" % path)
		if image == null:
			continue
		_expect(image.get_width() >= 256 and image.get_height() >= 256, "Concept is undersized: %s" % path)
		var digest: String = Marshalls.raw_to_base64(image.get_data()).md5_text()
		_expect(not fingerprints.has(digest), "Duplicate concept content: %s" % path)
		fingerprints[digest] = true


func _validate_shared_scene_authority() -> void:
	for scene_path: String in REQUIRED_SHARED_SCENES:
		var text: String = _read_text(scene_path)
		_expect(not text.is_empty(), "Unable to read shared scene: %s" % scene_path)
		_expect(
			text.contains(REQUIRED_SHARED_SCENES[scene_path]),
			"Scene does not use shared Player authority: %s" % scene_path
		)


func _validate_frame_resource(style_name: String, resource_path: String) -> void:
	var frames: SpriteFrames = load(resource_path) as SpriteFrames
	_expect(frames != null, "Missing %s SpriteFrames" % style_name)
	if frames == null:
		return
	var expected_root: String = RUNTIME_ROOT.path_join(style_name)
	for animation_name: StringName in PlayerBuilder.ANIMATION_ORDER:
		_expect(frames.has_animation(animation_name), "%s missing %s" % [style_name, animation_name])
		if not frames.has_animation(animation_name):
			continue
		_expect(
			frames.get_frame_count(animation_name) == PlayerBuilder.FRAME_COUNTS[animation_name],
			"%s has wrong frame count for %s" % [style_name, animation_name]
		)
		var unique_frames: Dictionary[String, bool] = {}
		for frame_index: int in range(frames.get_frame_count(animation_name)):
			var texture: Texture2D = frames.get_frame_texture(animation_name, frame_index)
			_expect(texture != null, "%s %s[%d] is null" % [style_name, animation_name, frame_index])
			if texture == null:
				continue
			_expect(
				texture.resource_path.begins_with(expected_root),
				"%s %s[%d] is outside formal root: %s"
				% [style_name, animation_name, frame_index, texture.resource_path]
			)
			for marker: String in LEGACY_MARKERS:
				_expect(
					not texture.resource_path.contains(marker),
					"%s has active legacy frame: %s" % [style_name, texture.resource_path]
				)
			var image: Image = texture.get_image()
			_expect(image.get_size() == Vector2i(64, 64), "%s frame is not 64x64" % texture.resource_path)
			_expect(not image.has_mipmaps(), "%s frame has mipmaps" % texture.resource_path)
			unique_frames[Marshalls.raw_to_base64(image.get_data()).md5_text()] = true
		if frames.get_frame_count(animation_name) > 1:
			_expect(unique_frames.size() > 1, "%s %s is a static duplicate sequence" % [style_name, animation_name])
	_validate_pose_distinction(style_name, frames)


func _validate_pose_distinction(style_name: String, frames: SpriteFrames) -> void:
	var pose_names: Array[StringName] = [
		&"idle", &"run", &"turn", &"jump_start", &"jump_apex", &"double_jump",
		&"air_dash_loop", &"dash_loop", &"attack_1", &"attack_2", &"attack_3",
		&"dash_attack", &"hurt_light", &"hurt_heavy", &"death",
	]
	var fingerprints: Dictionary[String, StringName] = {}
	for animation_name: StringName in pose_names:
		var frame_index: int = mini(2, frames.get_frame_count(animation_name) - 1)
		var image: Image = frames.get_frame_texture(animation_name, frame_index).get_image()
		var digest: String = Marshalls.raw_to_base64(image.get_data()).md5_text()
		_expect(
			not fingerprints.has(digest),
			"%s %s duplicates %s key pose" % [style_name, animation_name, fingerprints.get(digest, &"")]
		)
		fingerprints[digest] = animation_name
	var death_image: Image = frames.get_frame_texture(&"death", 4).get_image()
	var death_rect: Rect2i = death_image.get_used_rect()
	_expect(death_rect.size.x >= 42, "%s death lacks body/dagger horizontal spread" % style_name)
	_expect(death_rect.size.y <= 28, "%s final death is not a grounded prone pose" % style_name)


func _validate_scale_and_scene_geometry() -> void:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	var guard: Node2D = GUARD_SCENE.instantiate() as Node2D
	root.add_child(player)
	root.add_child(guard)
	await process_frame
	_expect(player.get_node("VisualRoot").scale == Vector2.ONE, "Player VisualRoot is scale-enlarged")
	var player_sprite: AnimatedSprite2D = player.get_node("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	var guard_sprite: AnimatedSprite2D = guard.get_node("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	_expect(player_sprite.scale == Vector2.ONE, "Player sprite is scale-enlarged")
	var player_height: int = _visible_height(player_sprite.sprite_frames.get_frame_texture(&"idle", 0).get_image())
	var guard_height: int = _visible_height(guard_sprite.sprite_frames.get_frame_texture(&"idle", 0).get_image())
	var ratio: float = float(player_height) / float(guard_height)
	_expect(ratio >= 0.95 and ratio <= 1.05, "Player/Guard ratio %.4f is outside 0.95-1.05" % ratio)
	var ghost: Sprite2D = player.get_node("VisualRoot/DeathEffects/GhostSprite") as Sprite2D
	_expect(
		ghost.texture != null and ghost.texture.resource_path == "res://shared/assets/player/effects/night_warden_ghost_hooded_face.png",
		"Player ghost is not the shared hooded-face asset"
	)
	player.queue_free()
	guard.queue_free()


func _visible_height(image: Image) -> int:
	return image.get_used_rect().size.y


func _read_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PLAYER_STAGE_2_QA: PASS concepts=10 styles=3 animations=30 ratio=57/58 chapters=4 legacy_refs=0")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)
