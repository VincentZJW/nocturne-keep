extends SceneTree

const ROOT: String = "res://chapters/chapter_01_ravenmourn_outskirts"
const ROLE_DATA: Dictionary[String, Dictionary] = {
	"castle_guard": {"scene": ROOT + "/scenes/enemies/castle_guard.tscn", "idle": "idle", "size": 128},
	"cursed_shield_guard": {"scene": "res://shared/scenes/enemies/cursed_shield_guard.tscn", "idle": "idle", "size": 128},
	"decayed_spearman": {"scene": ROOT + "/scenes/enemies/decayed_spearman.tscn", "idle": "idle", "size": 128},
	"fallen_crossbowman": {"scene": "res://shared/scenes/enemies/fallen_crossbowman.tscn", "idle": "idle", "size": 128},
	"gargoyle_sentinel": {"scene": "res://shared/scenes/enemies/gargoyle_sentinel.tscn", "idle": "hover", "size": 128},
	"fallen_gate_knight": {"scene": ROOT + "/scenes/boss/fallen_gate_knight.tscn", "idle": "idle_shielded", "size": 192},
}

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for role: String in ROLE_DATA:
		_validate_role(role, ROLE_DATA[role])
	var main: PackedScene = load("res://scenes/bootstrap/main_bootstrap.tscn") as PackedScene
	_expect(main != null, "Main bootstrap loads with the Chapter I formal assets")
	print("CH1 CHARACTER REPLICATION 95 GATE | %s" % ("PASS" if _failures == 0 else "FAIL %d" % _failures))
	quit(0 if _failures == 0 else 1)


func _validate_role(role: String, data: Dictionary) -> void:
	var packed: PackedScene = load(data["scene"] as String) as PackedScene
	_expect(packed != null, "%s formal scene loads" % role)
	if packed == null:
		return
	var actor: Node = packed.instantiate()
	var sprite: AnimatedSprite2D = actor.get_node_or_null("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	_expect(sprite != null and sprite.sprite_frames != null, "%s owns formal SpriteFrames" % role)
	if sprite == null or sprite.sprite_frames == null:
		actor.free()
		return
	var idle: StringName = StringName(data["idle"] as String)
	_expect(sprite.sprite_frames.has_animation(idle), "%s owns %s" % [role, idle])
	var image: Image = sprite.sprite_frames.get_frame_texture(idle, 0).get_image()
	var expected_size: int = data["size"] as int
	_expect(image.get_size() == Vector2i(expected_size, expected_size), "%s uses %dx%d formal frames" % [role, expected_size, expected_size])
	_expect(is_zero_approx(image.get_pixel(0, 0).a), "%s retains transparent corners" % role)
	var used: Rect2i = image.get_used_rect()
	_expect(used.size.x >= (34 if expected_size == 128 else 78) and used.size.y >= (48 if expected_size == 128 else 70), "%s retains a readable signature silhouette" % role)
	_expect(_opaque_color_count(image) >= 8, "%s retains layered material colors" % role)
	var source: String = FileAccess.get_file_as_string(data["scene"] as String)
	_expect(not source.contains("archive_legacy"), "%s scene has no archived runtime reference" % role)
	actor.free()


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
