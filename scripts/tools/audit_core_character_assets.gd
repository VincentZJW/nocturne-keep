extends SceneTree

## Read-only Stage 0 audit for the shared Player, its equipped weapon variants,
## the Chapter I swordsman scale reference, and the prologue Candle Warden.

const PLAYER_SCENE_PATH: String = "res://scenes/player/player.tscn"
const GUARD_SCENE_PATH: String = (
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn"
)
const CANDLE_WARDEN_SCENE_PATH: String = "res://scenes/npcs/candle_warden.tscn"
const PLAYER_FRAME_PATHS: Array[String] = [
	"res://resources/player/player_sprite_frames.tres",
	"res://resources/player/ravenfang_player_sprite_frames.tres",
	(
		"res://chapters/chapter_02_silent_court/resources/weapons/"
		+ "crimson_masque_player_sprite_frames.tres"
	),
]
const GUARD_FRAMES_PATH: String = (
	"res://chapters/chapter_01_ravenmourn_outskirts/resources/enemies/"
	+ "castle_guard_sprite_frames.tres"
)

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_audit")


func _run_audit() -> void:
	print("CORE_CHARACTER_AUDIT_BEGIN")
	print(
		"MAIN_SCENE|%s"
		% str(ProjectSettings.get_setting("application/run/main_scene", "<unset>"))
	)
	for resource_path: String in PLAYER_FRAME_PATHS:
		_audit_sprite_frames(resource_path)
	_audit_sprite_frames(GUARD_FRAMES_PATH)
	_audit_visual_ratio()
	await _audit_scene_composition()
	if _failures.is_empty():
		print("CORE_CHARACTER_AUDIT: PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CORE_CHARACTER_AUDIT: FAIL (%d issues)" % _failures.size())
	quit(1)


func _audit_sprite_frames(resource_path: String) -> void:
	var frames: SpriteFrames = load(resource_path) as SpriteFrames
	if frames == null:
		_failures.append("Could not load SpriteFrames: %s" % resource_path)
		return
	var animation_names: PackedStringArray = frames.get_animation_names()
	animation_names.sort()
	print("SPRITE_FRAMES|%s|animations=%d" % [resource_path, animation_names.size()])
	for animation_text: String in animation_names:
		var animation_name: StringName = StringName(animation_text)
		var frame_count: int = frames.get_frame_count(animation_name)
		var bounds: Rect2i = _animation_bounds(frames, animation_name)
		print(
			"ANIMATION|%s|%s|frames=%d|fps=%.3f|loop=%s|bounds=%s|height=%d"
			% [
				resource_path,
				animation_name,
				frame_count,
				frames.get_animation_speed(animation_name),
				str(frames.get_animation_loop(animation_name)),
				str(bounds),
				bounds.size.y,
			]
		)


func _audit_visual_ratio() -> void:
	var player_frames: SpriteFrames = load(PLAYER_FRAME_PATHS[0]) as SpriteFrames
	var guard_frames: SpriteFrames = load(GUARD_FRAMES_PATH) as SpriteFrames
	if player_frames == null or guard_frames == null:
		return
	var player_idle: Rect2i = _animation_bounds(player_frames, &"idle")
	var guard_idle: Rect2i = _animation_bounds(guard_frames, &"idle")
	var ratio: float = (
		float(player_idle.size.y) / float(guard_idle.size.y)
		if guard_idle.size.y > 0
		else 0.0
	)
	print(
		"VISUAL_RATIO|player_idle_height=%d|guard_idle_height=%d|ratio=%.4f"
		% [player_idle.size.y, guard_idle.size.y, ratio]
	)


func _audit_scene_composition() -> void:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	var guard_scene: PackedScene = load(GUARD_SCENE_PATH) as PackedScene
	var warden_scene: PackedScene = load(CANDLE_WARDEN_SCENE_PATH) as PackedScene
	if player_scene == null or guard_scene == null or warden_scene == null:
		_failures.append("One or more formal character scenes could not be loaded")
		return
	var player: Node = player_scene.instantiate()
	var guard: Node = guard_scene.instantiate()
	var warden: Node = warden_scene.instantiate()
	(player as Node2D).position = Vector2(-1000.0, 0.0)
	(guard as Node2D).position = Vector2(1000.0, 0.0)
	get_root().add_child(player)
	get_root().add_child(guard)
	get_root().add_child(warden)
	await process_frame
	_print_scene_tree("PLAYER_TREE", player)
	_print_scene_tree("GUARD_TREE", guard)
	_print_scene_tree("CANDLE_WARDEN_TREE", warden)
	_print_collision_shape("PLAYER_BODY", player.get_node_or_null("CollisionShape2D"))
	_print_collision_shape("PLAYER_HURTBOX", player.get_node_or_null("Hurtbox/CollisionShape2D"))
	_print_collision_shape(
		"PLAYER_ATTACK", player.get_node_or_null("CombatRoot/AttackHitbox/CollisionShape2D")
	)
	_print_collision_shape(
		"PLAYER_DASH_ATTACK",
		player.get_node_or_null("CombatRoot/DashAttackHitbox/CollisionShape2D")
	)
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		print("PLAYER_CAMERA|position=%s|offset=%s" % [str(camera.position), str(camera.offset)])
	player.queue_free()
	guard.queue_free()
	warden.queue_free()
	await process_frame


func _print_scene_tree(prefix: String, root_node: Node) -> void:
	print("%s|root=%s|script=%s" % [prefix, root_node.name, _script_path(root_node)])
	_print_children(prefix, root_node, root_node)


func _print_children(prefix: String, root_node: Node, current: Node) -> void:
	for child: Node in current.get_children():
		print(
			"%s|node=%s|type=%s|script=%s"
			% [prefix, str(root_node.get_path_to(child)), child.get_class(), _script_path(child)]
		)
		_print_children(prefix, root_node, child)


func _print_collision_shape(label: String, node: Node) -> void:
	var collision: CollisionShape2D = node as CollisionShape2D
	if collision == null or collision.shape == null:
		_failures.append("Missing collision shape: %s" % label)
		return
	var size_description: String = "shape=%s" % collision.shape.get_class()
	if collision.shape is RectangleShape2D:
		size_description = "size=%s" % str((collision.shape as RectangleShape2D).size)
	elif collision.shape is CapsuleShape2D:
		var capsule: CapsuleShape2D = collision.shape as CapsuleShape2D
		size_description = "radius=%.2f,height=%.2f" % [capsule.radius, capsule.height]
	var owner_position: Vector2 = Vector2.ZERO
	if collision.get_parent() is Node2D and collision.get_parent() != collision.owner:
		owner_position = (collision.get_parent() as Node2D).position
	print(
		"COLLISION|%s|owner_position=%s|shape_position=%s|%s"
		% [label, str(owner_position), str(collision.position), size_description]
	)


func _animation_bounds(frames: SpriteFrames, animation_name: StringName) -> Rect2i:
	var combined: Rect2i = Rect2i()
	for frame_index: int in range(frames.get_frame_count(animation_name)):
		var texture: Texture2D = frames.get_frame_texture(animation_name, frame_index)
		if texture == null:
			_failures.append("Null texture in %s frame %d" % [animation_name, frame_index])
			continue
		var image: Image = texture.get_image()
		if image == null or image.is_empty():
			_failures.append("Empty image in %s frame %d" % [animation_name, frame_index])
			continue
		var used: Rect2i = image.get_used_rect()
		combined = used if combined.size == Vector2i.ZERO else combined.merge(used)
	return combined


func _script_path(node: Node) -> String:
	var script: Script = node.get_script() as Script
	return script.resource_path if script != null else "<none>"
