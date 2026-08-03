extends SceneTree

## Structural gate for the seven remaining enemy replications and both Ormund phases.
## Visual scores are recorded in the QA reports; this test protects the measurable
## runtime contract: formal roots, dimensions, animation coverage and signature detail.

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep"
const ROLES: Array[String] = [
	"drowned_gaoler", "chainbound_convict", "mire_harpooner",
	"sunken_shield_penitent", "bog_toad", "sewer_maw", "underkeep_executioner",
]
const BOSS_SCENE: String = ROOT + "/scenes/bosses/soul_gaoler_ormund.tscn"

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for role: String in ROLES:
		_validate_enemy(role)
	_validate_shield_damage_states()
	_validate_ormund()
	print("CH4 REMAINING CHARACTER 95 GATE | %s" % ("PASS" if _failures == 0 else "FAIL %d" % _failures))
	quit(0 if _failures == 0 else 1)


func _validate_enemy(role: String) -> void:
	var scene_path: String = "%s/scenes/enemies/%s.tscn" % [ROOT, role]
	var packed: PackedScene = load(scene_path) as PackedScene
	_expect(packed != null, "%s formal scene loads" % role)
	if packed == null:
		return
	var enemy: Chapter04Enemy = packed.instantiate() as Chapter04Enemy
	_expect(enemy != null, "%s uses the shared Chapter04Enemy runtime" % role)
	if enemy == null:
		return
	var frames: SpriteFrames = enemy.get_node("VisualRoot/AnimatedSprite2D").sprite_frames as SpriteFrames
	_expect(frames.get_animation_names().size() >= 17, "%s retains complete animation coverage" % role)
	for animation: StringName in [&"idle", &"walk", &"light_hit", &"hurt", &"death"]:
		_expect(frames.has_animation(animation), "%s owns %s" % [role, animation])
	var image: Image = frames.get_frame_texture(&"idle", 0).get_image()
	_expect(image.get_size() == Vector2i(128, 128), "%s formal frame is 128x128" % role)
	_expect(is_zero_approx(image.get_pixel(0, 0).a), "%s keeps transparent corners" % role)
	var used: Rect2i = image.get_used_rect()
	_expect(used.size.x >= 50 and used.size.y >= 58, "%s has a gameplay-readable silhouette" % role)
	_expect(_opaque_color_count(image) >= 7, "%s retains layered material colors" % role)
	var source: String = FileAccess.get_file_as_string(scene_path)
	_expect(not source.contains("archive_legacy"), "%s has no archived runtime reference" % role)
	enemy.free()


func _validate_shield_damage_states() -> void:
	for state: String in ["intact", "cracked", "critical", "broken"]:
		var path: String = "%s/assets/enemies/sunken_shield_penitent/shield/%s.png" % [ROOT, state]
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		_expect(image != null and image.get_size() == Vector2i(128, 128), "shield state %s is formal 128x128 art" % state)


func _validate_ormund() -> void:
	var packed: PackedScene = load(BOSS_SCENE) as PackedScene
	_expect(packed != null, "Ormund formal Boss scene loads")
	if packed == null:
		return
	var boss: SoulGaolerOrmund = packed.instantiate() as SoulGaolerOrmund
	var frames: SpriteFrames = boss.get_node("VisualRoot/AnimatedSprite2D").sprite_frames as SpriteFrames
	_expect(frames.get_animation_names().size() == 47, "Ormund retains 47 runtime animations")
	for animation: StringName in [&"idle_p1", &"phase_transition", &"idle_p2", &"halberd_sweep_active", &"chainstorm_cleave_active", &"death_collapse"]:
		_expect(frames.has_animation(animation), "Ormund owns %s" % animation)
	var p1: Image = frames.get_frame_texture(&"idle_p1", 0).get_image()
	var p2: Image = frames.get_frame_texture(&"idle_p2", 0).get_image()
	_expect(p1.get_size() == Vector2i(192, 192) and p2.get_size() == Vector2i(192, 192), "Ormund phases use 192x192 formal frames")
	_expect(hash(p1.get_data()) != hash(p2.get_data()), "Ormund Phase II is structurally redrawn")
	_expect(p1.get_used_rect().size.x >= 100, "Ormund Phase I cage/weapon silhouette is wide")
	_expect(p2.get_used_rect().size.x >= 120, "Ormund Phase II rib-cage silhouette expands")
	_expect(_opaque_color_count(p1) >= 9 and _opaque_color_count(p2) >= 9, "Ormund phases retain layered materials")
	var source: String = FileAccess.get_file_as_string(BOSS_SCENE)
	_expect(not source.contains("archive_legacy"), "Ormund has no archived runtime reference")
	boss.free()


func _opaque_color_count(image: Image) -> int:
	var colors: Dictionary[Color, bool] = {}
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if color.a > 0.5:
				colors[color] = true
	return colors.size()


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error(message)
