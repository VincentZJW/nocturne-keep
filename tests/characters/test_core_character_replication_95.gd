extends SceneTree

const PLAYER_SCENE: String = "res://scenes/player/player.tscn"
const WARDEN_SCENE: String = "res://scenes/npcs/candle_warden.tscn"
const PLAYER_SAMPLES: Array[String] = [
	"res://shared/assets/player/animations/veilbound/idle/idle_01.png",
	"res://shared/assets/player/animations/ravenfang/attack_3/attack_3_03.png",
	"res://shared/assets/player/animations/crimson_masque/dash_attack/dash_attack_03.png",
]
const WARDEN_SAMPLES: Array[String] = [
	"res://chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden/animations/idle/idle_01.png",
	"res://chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden/animations/offer_key/offer_key_03.png",
]

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for path: String in PLAYER_SAMPLES:
		_validate_image(path, Vector2i(96, 96), Vector2i(44, 46), 8)
	for path: String in WARDEN_SAMPLES:
		_validate_image(path, Vector2i(128, 128), Vector2i(48, 58), 10)
	_validate_scene(PLAYER_SCENE, "VisualRoot/AnimatedSprite2D", &"idle", Vector2i(96, 96))
	_validate_scene(WARDEN_SCENE, "VisualRoot/Body", &"idle", Vector2i(128, 128))
	var bootstrap: PackedScene = load("res://scenes/bootstrap/main_bootstrap.tscn") as PackedScene
	_expect(bootstrap != null, "Main bootstrap resolves with replicated core actors")
	print("CORE CHARACTER REPLICATION 95 GATE | %s" % ("PASS" if _failures == 0 else "FAIL %d" % _failures))
	quit(0 if _failures == 0 else 1)


func _validate_image(
	path: String, expected_size: Vector2i, minimum_used: Vector2i, minimum_colors: int
	) -> void:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	_expect(image != null and not image.is_empty(), "%s resolves" % path)
	if image == null or image.is_empty():
		return
	_expect(image.get_size() == expected_size, "%s uses %s formal canvas" % [path, expected_size])
	_expect(is_zero_approx(image.get_pixel(0, 0).a), "%s retains transparent corners" % path)
	var used: Rect2i = image.get_used_rect()
	_expect(used.size.x >= minimum_used.x and used.size.y >= minimum_used.y, "%s keeps a readable silhouette" % path)
	_expect(_opaque_color_count(image) >= minimum_colors, "%s keeps layered materials" % path)


func _validate_scene(
	path: String, sprite_path: String, animation: StringName, expected_size: Vector2i
	) -> void:
	var packed: PackedScene = load(path) as PackedScene
	_expect(packed != null, "%s loads" % path)
	if packed == null:
		return
	var actor: Node = packed.instantiate()
	var sprite: AnimatedSprite2D = actor.get_node_or_null(sprite_path) as AnimatedSprite2D
	_expect(sprite != null and sprite.sprite_frames != null, "%s owns formal SpriteFrames" % path)
	if sprite != null and sprite.sprite_frames != null:
		_expect(sprite.sprite_frames.has_animation(animation), "%s owns %s" % [path, animation])
		var texture: Texture2D = sprite.sprite_frames.get_frame_texture(animation, 0)
		_expect(
			texture != null and Vector2i(texture.get_size()) == expected_size,
			"%s runtime texture uses %s" % [path, expected_size]
		)
	var source: String = FileAccess.get_file_as_string(path)
	_expect(not source.contains("archive_legacy"), "%s has no archived runtime reference" % path)
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
