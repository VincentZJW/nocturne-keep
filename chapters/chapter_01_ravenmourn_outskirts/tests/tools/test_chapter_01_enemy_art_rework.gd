extends SceneTree

const CHAPTER_ROOT: String = "res://chapters/chapter_01_ravenmourn_outskirts"
const LEVEL_PATH: String = CHAPTER_ROOT + "/scenes/level/ravenmourn_outskirts.tscn"
const ROLES: Array[String] = [
	"castle_guard",
	"cursed_shield_guard",
	"decayed_spearman",
	"fallen_crossbowman",
	"gargoyle_sentinel",
	"fallen_gate_knight",
]
const FRAME_COUNTS: Dictionary = {
	"castle_guard": 24,
	"cursed_shield_guard": 55,
	"decayed_spearman": 25,
	"fallen_crossbowman": 30,
	"gargoyle_sentinel": 41,
	"fallen_gate_knight": 165,
}
const FRAME_RESOURCES: Dictionary = {
	"castle_guard": CHAPTER_ROOT + "/resources/enemies/castle_guard_sprite_frames.tres",
	"cursed_shield_guard": "res://shared/resources/enemies/cursed_shield_guard_sprite_frames.tres",
	"decayed_spearman": CHAPTER_ROOT + "/resources/enemies/decayed_spearman_sprite_frames.tres",
	"fallen_crossbowman": "res://shared/resources/enemies/fallen_crossbowman_sprite_frames.tres",
	"gargoyle_sentinel": "res://shared/resources/enemies/gargoyle_sentinel_sprite_frames.tres",
	"fallen_gate_knight": CHAPTER_ROOT + "/resources/boss/fallen_gate_knight_sprite_frames.tres",
}
const SCENES: Dictionary = {
	"castle_guard": CHAPTER_ROOT + "/scenes/enemies/castle_guard.tscn",
	"cursed_shield_guard": "res://shared/scenes/enemies/cursed_shield_guard.tscn",
	"decayed_spearman": CHAPTER_ROOT + "/scenes/enemies/decayed_spearman.tscn",
	"fallen_crossbowman": "res://shared/scenes/enemies/fallen_crossbowman.tscn",
	"gargoyle_sentinel": "res://shared/scenes/enemies/gargoyle_sentinel.tscn",
	"fallen_gate_knight": CHAPTER_ROOT + "/scenes/boss/fallen_gate_knight.tscn",
}
const REPRESENTATIVE_IDLE: Dictionary = {
	"castle_guard": "idle/idle_01.png",
	"cursed_shield_guard": "idle/idle_01.png",
	"decayed_spearman": "idle/idle_01.png",
	"fallen_crossbowman": "idle/idle_01.png",
	"gargoyle_sentinel": "hover/hover_01.png",
	"fallen_gate_knight": "idle_shielded/idle_shielded_01.png",
}

var _failed: bool = false


func _initialize() -> void:
	var total_frames: int = 0
	var archived_frames: int = 0
	for role: String in ROLES:
		var role_root: String = _role_root(role)
		var size: Vector2i = Vector2i(128, 96) if role == "fallen_gate_knight" else Vector2i(64, 64)
		var paths: PackedStringArray = _png_paths(role_root + "/sprites")
		_assert(paths.size() == int(FRAME_COUNTS[role]), "%s formal frame count" % role)
		for path: String in paths:
			var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
			_assert(image != null and image.get_size() == size, "invalid formal frame %s" % path)
			_assert(_nontransparent_pixels(image) >= (180 if role == "fallen_gate_knight" else 70), "under-drawn frame %s" % path)
			total_frames += 1
		var representative: Image = Image.load_from_file(ProjectSettings.globalize_path(
			role_root + "/sprites/" + String(REPRESENTATIVE_IDLE[role])
		))
		_assert(_unique_visible_colors(representative) >= 7, "%s lacks material palette" % role)
		_assert(FileAccess.file_exists(role_root + "/concept_art/%s_concept.png" % role), "%s concept sheet" % role)
		_assert(FileAccess.file_exists(role_root + "/concept_art/%s_silhouette.png" % role), "%s silhouette" % role)
		_assert(FileAccess.file_exists(role_root + "/concept_art/%s_action_reference.png" % role), "%s action reference" % role)
		_assert(FileAccess.file_exists(role_root + "/effects/%s_effect_reference.png" % role), "%s effect reference" % role)
		var archive: PackedStringArray = _png_paths(role_root + "/reference/deprecated_v1/sprites")
		_assert(not archive.is_empty(), "%s legacy archive missing" % role)
		archived_frames += archive.size()
		var frames: SpriteFrames = load(String(FRAME_RESOURCES[role])) as SpriteFrames
		_assert(frames != null, "missing SpriteFrames %s" % role)
		_assert(_sprite_frame_count(frames) == int(FRAME_COUNTS[role]), "%s SpriteFrames count" % role)
		for animation: StringName in frames.get_animation_names():
			for index: int in range(frames.get_frame_count(animation)):
				var texture: Texture2D = frames.get_frame_texture(animation, index)
				_assert(texture != null, "%s null texture" % role)
				_assert(texture.resource_path.begins_with(role_root + "/sprites/"), "%s runtime texture outside formal directory: %s" % [role, texture.resource_path])
				_assert(not texture.resource_path.contains("deprecated"), "%s legacy texture still referenced" % role)
		var packed: PackedScene = load(String(SCENES[role])) as PackedScene
		_assert(packed != null, "missing scene %s" % role)
		var instance: Node = packed.instantiate()
		var sprite: AnimatedSprite2D = instance.get_node_or_null("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
		_assert(sprite != null and sprite.sprite_frames == frames, "%s scene does not use formal SpriteFrames" % role)
		instance.free()
	_assert(total_frames == 340, "formal frame total is not 340")
	_assert(archived_frames == 290, "legacy archive total is not 290")
	var level_text: String = FileAccess.get_file_as_string(LEVEL_PATH)
	_assert(level_text.contains("first_level_encounters.tscn"), "Main level does not instance first-level encounters")
	_assert(level_text.contains("fallen_gate_knight.tscn"), "Main level does not instance Fallen Gate Knight")
	var encounter_text: String = FileAccess.get_file_as_string(CHAPTER_ROOT + "/scenes/encounters/first_level_encounters.tscn")
	for scene_path: String in SCENES.values():
		if scene_path.ends_with("fallen_gate_knight.tscn"):
			continue
		_assert(encounter_text.contains(scene_path), "Main encounters missing %s" % scene_path)
	if _failed:
		quit(1)
		return
	print("CH1_ENEMY_ART_REWORK_TEST: PASS roles=6 formal_frames=340 archived_frames=290 main_refs=6")
	quit(0)


func _role_root(role: String) -> String:
	if role == "fallen_gate_knight":
		return CHAPTER_ROOT + "/assets/boss/fallen_gate_knight"
	return CHAPTER_ROOT + "/assets/enemies/" + role


func _png_paths(root_path: String) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	_walk(ProjectSettings.globalize_path(root_path), result)
	result.sort()
	return result


func _walk(directory_path: String, result: PackedStringArray) -> void:
	var directory: DirAccess = DirAccess.open(directory_path)
	_assert(directory != null, "cannot open %s" % directory_path)
	if directory == null:
		return
	directory.list_dir_begin()
	var name: String = directory.get_next()
	while not name.is_empty():
		var full: String = directory_path.path_join(name)
		if directory.current_is_dir():
			_walk(full, result)
		elif name.ends_with(".png"):
			result.append(full)
		name = directory.get_next()
	directory.list_dir_end()


func _nontransparent_pixels(image: Image) -> int:
	var count: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.01:
				count += 1
	return count


func _unique_visible_colors(image: Image) -> int:
	var colors: Dictionary = {}
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if color.a > 0.1:
				colors[color.to_html()] = true
	return colors.size()


func _sprite_frame_count(frames: SpriteFrames) -> int:
	var total: int = 0
	for animation: StringName in frames.get_animation_names():
		total += frames.get_frame_count(animation)
	return total


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error("CH1_ENEMY_ART_REWORK_TEST: %s" % message)
