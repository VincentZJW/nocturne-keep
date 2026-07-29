extends SceneTree

const BOSS_FRAMES: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran/animations/edran_phase_01_sprite_frames.tres"
const PENITENT_FRAMES: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons/ossuary_penitent/animations/ossuary_penitent_sprite_frames.tres"
const HUSK_FRAMES: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons/choir_husk/animations/choir_husk_sprite_frames.tres"

const BOSS_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/thirteenth_pontiff_edran.tscn"
const PENITENT_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/ossuary_penitent.tscn"
const HUSK_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/choir_husk.tscn"

const BOSS_IDLE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran/phase_01/phase_01_idle/phase_01_idle_01.png"
const BOSS_SWEEP: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran/phase_01/pontifical_sweep_active/pontifical_sweep_active_02.png"
const BOSS_THRUST: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran/phase_01/crozier_thrust_active/crozier_thrust_active_02.png"
const PENITENT_IDLE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons/ossuary_penitent/sprites/idle/idle_01.png"
const PENITENT_CLAW: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons/ossuary_penitent/sprites/claw_active/claw_active_02.png"
const HUSK_IDLE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons/choir_husk/sprites/idle/idle_01.png"
const HUSK_SHOOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons/choir_husk/sprites/shoot/shoot_03.png"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_validate_frames(BOSS_FRAMES, 27, 114, Vector2(96.0, 96.0), "Edran")
	_validate_frames(PENITENT_FRAMES, 14, 58, Vector2(64.0, 64.0), "Ossuary Penitent")
	_validate_frames(HUSK_FRAMES, 11, 50, Vector2(64.0, 64.0), "Choir Husk")

	_validate_art(BOSS_IDLE, Vector2i(96, 96), Vector2i(34, 61), 800, 32, "Edran idle")
	_validate_art(BOSS_SWEEP, Vector2i(96, 96), Vector2i(62, 67), 800, 32, "Edran sweep")
	_validate_art(BOSS_THRUST, Vector2i(96, 96), Vector2i(61, 70), 800, 32, "Edran thrust")
	_validate_art(PENITENT_IDLE, Vector2i(64, 64), Vector2i(42, 50), 500, 18, "Penitent idle")
	_validate_art(PENITENT_CLAW, Vector2i(64, 64), Vector2i(48, 50), 430, 24, "Penitent claw")
	_validate_art(HUSK_IDLE, Vector2i(64, 64), Vector2i(38, 55), 420, 18, "Choir Husk idle")
	_validate_art(HUSK_SHOOT, Vector2i(64, 64), Vector2i(44, 55), 420, 24, "Choir Husk shoot")

	_validate_scene(BOSS_SCENE, Vector2(36.0, 78.0), Vector2(40.0, 76.0), "Edran")
	_validate_scene(PENITENT_SCENE, Vector2(28.0, 44.0), Vector2(32.0, 46.0), "Ossuary Penitent")
	_validate_scene(HUSK_SCENE, Vector2(24.0, 42.0), Vector2(28.0, 44.0), "Choir Husk")

	var route_text: String = FileAccess.get_file_as_string("res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/level/chapter_03_route.gd")
	_check("CH3_BOSS_SUMMON_TEST" in route_text, "Main debug route retains CH3_BOSS_SUMMON_TEST")
	_finish()


func _validate_frames(path: String, expected_animations: int, expected_frames: int, expected_size: Vector2, label: String) -> void:
	var frames: SpriteFrames = load(path) as SpriteFrames
	_check(frames != null, "%s SpriteFrames load" % label)
	if frames == null:
		return
	var frame_total: int = 0
	for animation_name: StringName in frames.get_animation_names():
		frame_total += frames.get_frame_count(animation_name)
		for frame_index: int in range(frames.get_frame_count(animation_name)):
			var texture: Texture2D = frames.get_frame_texture(animation_name, frame_index)
			_check(texture != null and texture.get_size() == expected_size, "%s %s frame %d has stable canvas" % [label, animation_name, frame_index])
	_check(frames.get_animation_names().size() == expected_animations, "%s animation count remains %d" % [label, expected_animations])
	_check(frame_total == expected_frames, "%s frame total remains %d" % [label, expected_frames])


func _validate_art(path: String, expected_size: Vector2i, minimum_span: Vector2i, minimum_pixels: int, maximum_edge_pixels: int, label: String) -> void:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	_check(image != null and image.get_size() == expected_size, "%s PNG has expected canvas" % label)
	if image == null or image.is_empty():
		return
	var bounds: Rect2i = _alpha_bounds(image)
	_check(bounds.size.x >= minimum_span.x and bounds.size.y >= minimum_span.y, "%s silhouette span is substantial" % label)
	_check(_opaque_pixel_count(image) >= minimum_pixels, "%s contains production detail density" % label)
	var edge_pixels: int = _edge_pixel_count(image)
	_check(edge_pixels <= maximum_edge_pixels, "%s limits canvas-edge contact (%d/%d)" % [label, edge_pixels, maximum_edge_pixels])


func _validate_scene(path: String, expected_body: Vector2, expected_hurtbox: Vector2, label: String) -> void:
	var packed: PackedScene = load(path) as PackedScene
	_check(packed != null, "%s scene loads" % label)
	if packed == null:
		return
	var actor: Node = packed.instantiate()
	root.add_child(actor)
	var body_shape_node: CollisionShape2D = actor.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var hurt_shape_node: CollisionShape2D = actor.get_node_or_null("Hurtbox/CollisionShape2D") as CollisionShape2D
	_check(body_shape_node != null and body_shape_node.shape is RectangleShape2D, "%s body collision remains rectangular" % label)
	_check(hurt_shape_node != null and hurt_shape_node.shape is RectangleShape2D, "%s hurtbox remains rectangular" % label)
	if body_shape_node != null and body_shape_node.shape is RectangleShape2D:
		_check((body_shape_node.shape as RectangleShape2D).size == expected_body, "%s body collision size is unchanged" % label)
	if hurt_shape_node != null and hurt_shape_node.shape is RectangleShape2D:
		_check((hurt_shape_node.shape as RectangleShape2D).size == expected_hurtbox, "%s hurtbox size is unchanged" % label)
	actor.queue_free()


func _alpha_bounds(image: Image) -> Rect2i:
	var minimum: Vector2i = image.get_size()
	var maximum: Vector2i = Vector2i(-1, -1)
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.01:
				minimum.x = mini(minimum.x, x)
				minimum.y = mini(minimum.y, y)
				maximum.x = maxi(maximum.x, x)
				maximum.y = maxi(maximum.y, y)
	if maximum.x < 0:
		return Rect2i()
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)


func _opaque_pixel_count(image: Image) -> int:
	var total: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.01:
				total += 1
	return total


func _edge_pixel_count(image: Image) -> int:
	var total: int = 0
	for x: int in range(image.get_width()):
		if image.get_pixel(x, 0).a > 0.01:
			total += 1
		if image.get_pixel(x, image.get_height() - 1).a > 0.01:
			total += 1
	for y: int in range(1, image.get_height() - 1):
		if image.get_pixel(0, y).a > 0.01:
			total += 1
		if image.get_pixel(image.get_width() - 1, y).a > 0.01:
			total += 1
	return total


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("EDRAN_ART_REWORK | PASS boss_frames=114 summon_frames=108 main_spawn=true collisions_unchanged=true")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("EDRAN_ART_REWORK | FAIL count=%d" % _failures.size())
	quit(1)
