extends SceneTree

## W2 contract: formal pixels and runtime visuals exist without granting the weapon.

const Builder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const ANIMATION_ROOT: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/"
	+ "thirteenfold_absolution/animations/player"
)
const SPRITE_ROOT: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/"
	+ "thirteenfold_absolution/sprites"
)
const EFFECT_ROOT: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/"
	+ "thirteenfold_absolution/effects"
)
const FRAMES_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/"
	+ "thirteenfold_absolution_player_sprite_frames.tres"
)
const PRESENTATION_SIZES: Dictionary[String, Vector2i] = {
	"inventory_icon.png": Vector2i(32, 32),
	"hud_icon.png": Vector2i(24, 24),
	"weapon_pair_reference.png": Vector2i(64, 48),
	"world_pickup.png": Vector2i(64, 64),
	"reliquary_display.png": Vector2i(96, 64),
}
const EFFECT_SIZES: Dictionary[String, Vector2i] = {
	"bone_gold_thrust_trail.png": Vector2i(64, 32),
	"hollow_bell_afterimage.png": Vector2i(32, 32),
	"reliquary_pickup_glow.png": Vector2i(64, 64),
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_validate_sprite_frames()
	_validate_asset_files()
	_validate_w3_boundary()
	await _validate_player_visual_preview()
	_finish()


func _validate_sprite_frames() -> void:
	var sprite_frames: SpriteFrames = load(FRAMES_PATH) as SpriteFrames
	_expect(sprite_frames != null, "Missing formal Thirteenfold SpriteFrames")
	if sprite_frames == null:
		return
	var names: PackedStringArray = sprite_frames.get_animation_names()
	_expect(names.size() == Builder.ANIMATION_ORDER.size(), "SpriteFrames animation count is not 30")
	var total_frames: int = 0
	for animation_name: StringName in Builder.ANIMATION_ORDER:
		_expect(sprite_frames.has_animation(animation_name), "Missing animation: %s" % animation_name)
		if not sprite_frames.has_animation(animation_name):
			continue
		var expected_count: int = Builder.FRAME_COUNTS[animation_name]
		var actual_count: int = sprite_frames.get_frame_count(animation_name)
		total_frames += actual_count
		_expect(actual_count == expected_count, "%s frame count %d != %d" % [animation_name, actual_count, expected_count])
		_expect(is_equal_approx(sprite_frames.get_animation_speed(animation_name), Builder.SPEEDS[animation_name]), "%s FPS mismatch" % animation_name)
		_expect(sprite_frames.get_animation_loop(animation_name) == Builder.LOOPING[animation_name], "%s loop mismatch" % animation_name)
		for frame_index: int in range(actual_count):
			var texture: Texture2D = sprite_frames.get_frame_texture(animation_name, frame_index)
			_expect(texture != null, "%s[%d] texture is null" % [animation_name, frame_index])
			if texture == null:
				continue
			_expect(texture.resource_path.begins_with(ANIMATION_ROOT), "Frame outside W2 root: %s" % texture.resource_path)
			var image: Image = texture.get_image()
			_expect(image.get_size() == Vector2i(64, 64), "Frame is not 64x64: %s" % texture.resource_path)
			_expect(not image.has_mipmaps(), "Frame contains mipmaps: %s" % texture.resource_path)
			_expect(image.get_used_rect().size != Vector2i.ZERO, "Frame is empty: %s" % texture.resource_path)
			_expect(image.get_pixel(0, 0).a == 0.0, "Frame corner is not transparent: %s" % texture.resource_path)
	_expect(total_frames == 97, "Formal frame total %d != 97" % total_frames)


func _validate_asset_files() -> void:
	_expect(_count_png_files(ANIMATION_ROOT) == 97, "Animation source PNG count is not 97")
	for file_name: String in PRESENTATION_SIZES:
		_validate_image(SPRITE_ROOT.path_join(file_name), PRESENTATION_SIZES[file_name])
	for file_name: String in EFFECT_SIZES:
		_validate_image(EFFECT_ROOT.path_join(file_name), EFFECT_SIZES[file_name])


func _validate_image(path: String, expected_size: Vector2i) -> void:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	_expect(image != null and not image.is_empty(), "Missing image: %s" % path)
	if image == null or image.is_empty():
		return
	_expect(image.get_size() == expected_size, "Unexpected image size: %s" % path)
	_expect(image.get_used_rect().size != Vector2i.ZERO, "Image has no visible pixels: %s" % path)
	_expect(image.get_pixel(0, 0).a == 0.0, "Image corner is not transparent: %s" % path)


func _validate_w3_boundary() -> void:
	_expect(
		not FileAccess.file_exists(
			"res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/"
			+ "thirteenfold_absolution.tres"
		),
		"W2 must not create formal WeaponData"
	)
	var equipment: PlayerEquipmentManager = root.get_node_or_null("EquipmentManager") as PlayerEquipmentManager
	_expect(equipment != null, "EquipmentManager autoload is unavailable")
	if equipment != null:
		_expect(equipment.get_weapon(&"thirteenfold_absolution") == null, "W2 must not register the weapon")


func _validate_player_visual_preview() -> void:
	var equipment: PlayerEquipmentManager = root.get_node_or_null("EquipmentManager") as PlayerEquipmentManager
	var equipped_before: StringName = equipment.equipped_weapon_id if equipment != null else &""
	var player: Node = PLAYER_SCENE.instantiate()
	root.add_child(player)
	await process_frame
	var visual: PlayerWeaponVisual = player.get_node_or_null("VisualRoot/WeaponVisual") as PlayerWeaponVisual
	_expect(visual != null, "Player WeaponVisual is unavailable")
	if visual != null:
		_expect(visual.set_visual_preview(&"thirteenfold_absolution"), "Preview visual rejected")
		_expect(visual.get_visual_id() == &"thirteenfold_absolution", "Preview visual ID mismatch")
		_expect(visual.get_active_sprite_frames_path() == FRAMES_PATH, "Preview frame path mismatch")
		var sprite: AnimatedSprite2D = player.get_node("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
		_expect(sprite.sprite_frames == load(FRAMES_PATH), "Player did not swap to W2 SpriteFrames")
	if equipment != null:
		_expect(equipment.equipped_weapon_id == equipped_before, "Preview mutated equipped weapon")
	player.queue_free()


func _count_png_files(directory: String) -> int:
	var access: DirAccess = DirAccess.open(directory)
	if access == null:
		return 0
	var count: int = 0
	access.list_dir_begin()
	var entry: String = access.get_next()
	while not entry.is_empty():
		if access.current_is_dir() and not entry.begins_with("."):
			count += _count_png_files(directory.path_join(entry))
		elif entry.ends_with(".png"):
			count += 1
		entry = access.get_next()
	access.list_dir_end()
	return count


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("THIRTEENFOLD_ABSOLUTION_W2 | PASS animations=30 frames=97 assets=8 preview=nonpersistent")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("THIRTEENFOLD_ABSOLUTION_W2 | FAIL count=%d" % _failures.size())
	quit(1)
