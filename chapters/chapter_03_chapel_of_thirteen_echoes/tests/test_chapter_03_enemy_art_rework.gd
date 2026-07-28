extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies"
const ROLES: Array[String] = [
	"bellchain_penitent", "censer_executioner", "silent_chorister",
	"stained_glass_seraph", "confessional_wraith", "thirteenth_scribe",
]
const EXPECTED_TOTALS: Dictionary = {
	"bellchain_penitent": 70,
	"censer_executioner": 71,
	"silent_chorister": 69,
	"stained_glass_seraph": 67,
	"confessional_wraith": 71,
	"thirteenth_scribe": 67,
}
const SCENES: Dictionary = {
	"bellchain_penitent": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/bellchain_penitent.tscn",
	"censer_executioner": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/censer_executioner.tscn",
	"silent_chorister": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/silent_chorister.tscn",
	"stained_glass_seraph": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/stained_glass_seraph.tscn",
	"confessional_wraith": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/confessional_wraith.tscn",
	"thirteenth_scribe": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/thirteenth_scribe.tscn",
}


func _initialize() -> void:
	var total: int = 0
	for role: String in ROLES:
		var sprite_root: String = "%s/%s/sprites" % [ROOT,role]
		var legacy_root: String = "%s/%s/reference/deprecated_phase_2/sprites" % [ROOT,role]
		var paths: PackedStringArray = _png_paths(sprite_root)
		var legacy_paths: PackedStringArray = _png_paths(legacy_root)
		_assert(paths.size()==int(EXPECTED_TOTALS[role]),"%s formal frame count" % role)
		_assert(legacy_paths.size()==int(EXPECTED_TOTALS[role]),"%s archived frame count" % role)
		for path: String in paths:
			var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
			_assert(image!=null and image.get_size()==Vector2i(64,64),"invalid formal frame %s" % path)
			_assert(_nontransparent_pixels(image)>70,"under-drawn formal frame %s" % path)
			total += 1
		var new_idle: String = "%s/idle/idle_01.png" % sprite_root
		var old_idle: String = "%s/idle/idle_01.png" % legacy_root
		_assert(FileAccess.get_sha256(new_idle)!=FileAccess.get_sha256(old_idle),"%s idle still legacy" % role)
		var idle_image: Image = Image.load_from_file(ProjectSettings.globalize_path(new_idle))
		_assert(_unique_visible_colors(idle_image)>=8,"%s lacks material palette" % role)
		var frames_path: String = "%s/%s/animations/%s_sprite_frames.tres" % [ROOT,role,role]
		var frames: SpriteFrames = load(frames_path) as SpriteFrames
		_assert(frames!=null,"missing SpriteFrames %s" % role)
		_assert(_sprite_frame_count(frames)==int(EXPECTED_TOTALS[role]),"%s SpriteFrames total" % role)
		for animation: StringName in frames.get_animation_names():
			for index: int in range(frames.get_frame_count(animation)):
				var texture: Texture2D = frames.get_frame_texture(animation,index)
				_assert(texture!=null and not texture.resource_path.contains("deprecated_phase_2"),"%s legacy texture reference" % role)
		var packed: PackedScene = load(SCENES[role]) as PackedScene
		_assert(packed!=null,"missing enemy scene %s" % role)
		var enemy: Node = packed.instantiate()
		var sprite: AnimatedSprite2D = enemy.get_node_or_null("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
		_assert(sprite!=null and sprite.sprite_frames==frames,"%s scene does not use formal SpriteFrames" % role)
		enemy.free()
		_assert(FileAccess.file_exists("%s/%s/concept_art/%s_action_reference.png" % [ROOT,role,role]),"%s action reference" % role)
		_assert(FileAccess.file_exists("%s/%s/effects/%s_effect_reference.png" % [ROOT,role,role]),"%s effect reference" % role)
		_assert(DirAccess.dir_exists_absolute(ProjectSettings.globalize_path("%s/%s/docs" % [ROOT,role])),"%s docs directory" % role)
	_assert(total==415,"formal total is not 415")
	var level_text: String = FileAccess.get_file_as_string("res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn")
	for role: String in ROLES:
		_assert(level_text.contains("scenes/enemies/%s.tscn" % role),"Main target missing %s" % role)
	_assert(ResourceLoader.exists("res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/tests/chapter_03_enemy_trial_hall.tscn"),"trial hall missing")
	print("CH3_ENEMY_ART_REWORK_TEST: PASS roles=6 frames=415 archives=415 main_refs=6")
	quit(0)


func _png_paths(root_path: String) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	_walk(ProjectSettings.globalize_path(root_path),result)
	result.sort()
	return result


func _walk(directory_path: String,result: PackedStringArray) -> void:
	var directory: DirAccess = DirAccess.open(directory_path)
	_assert(directory!=null,"cannot open %s" % directory_path)
	if directory==null: return
	directory.list_dir_begin()
	var name: String = directory.get_next()
	while not name.is_empty():
		var full: String = directory_path.path_join(name)
		if directory.current_is_dir():
			_walk(full,result)
		elif name.ends_with(".png"):
			result.append(full)
		name = directory.get_next()
	directory.list_dir_end()


func _nontransparent_pixels(image: Image) -> int:
	var count: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x,y).a>0.01: count += 1
	return count


func _unique_visible_colors(image: Image) -> int:
	var colors: Dictionary = {}
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x,y)
			if color.a>0.1: colors[color.to_html()] = true
	return colors.size()


func _sprite_frame_count(frames: SpriteFrames) -> int:
	var total: int = 0
	for animation: StringName in frames.get_animation_names(): total += frames.get_frame_count(animation)
	return total


func _assert(condition: bool,message: String) -> void:
	if not condition:
		push_error("CH3_ENEMY_ART_REWORK_TEST: %s" % message)
		quit(1)
