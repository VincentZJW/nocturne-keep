extends SceneTree

## Integration tests for M1-only movement, jumping, collision, camera, and animation flow.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")
const SpriteFramesBuilder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")

const M1_ANIMATIONS: Array[StringName] = [
	&"idle", &"run", &"jump_start", &"jump_loop", &"fall", &"land",
]

var _failures: Array[String] = []
var _state_events: Array[StringName] = []
var _jump_origins: Array[bool] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_validate_input_map()
	_validate_animation_art_contract()
	await _test_ground_move_jump_and_animation()
	await _test_coyote_time()
	await _test_jump_buffer()
	await _test_land_interrupt()
	_release_all_inputs()
	_finish()


func _validate_input_map() -> void:
	_expect(PlayerScript.STATE_ANIMATIONS.size() == M1_ANIMATIONS.size(), "Player FSM has unexpected state count")
	for animation_name: StringName in PlayerScript.STATE_ANIMATIONS.values():
		_expect(animation_name in M1_ANIMATIONS, "Player FSM references non-M1 animation: %s" % animation_name)
	for action_name: StringName in [PlayerScript.MOVE_LEFT_ACTION, PlayerScript.MOVE_RIGHT_ACTION, PlayerScript.JUMP_ACTION]:
		_expect(InputMap.has_action(action_name), "Missing M1 input action: %s" % action_name)
		_expect(not InputMap.action_get_events(action_name).is_empty(), "Input action has no events: %s" % action_name)


func _validate_animation_art_contract() -> void:
	var sprite_frames: SpriteFrames = load(SpriteFramesBuilder.RESOURCE_PATH) as SpriteFrames
	for animation_name: StringName in M1_ANIMATIONS:
		_expect(not SpriteFramesBuilder.is_placeholder(animation_name), "%s is still marked placeholder" % animation_name)
		for frame_index: int in range(sprite_frames.get_frame_count(animation_name)):
			var texture: Texture2D = sprite_frames.get_frame_texture(animation_name, frame_index)
			var image: Image = texture.get_image()
			_expect(image.get_size() == Vector2i(64, 64), "Wrong M1 frame size: %s[%d]" % [animation_name, frame_index])
			_expect(not image.has_mipmaps(), "Mipmap found: %s[%d]" % [animation_name, frame_index])
			var resized: Image = image.duplicate()
			resized.resize(48, 48, Image.INTERPOLATE_NEAREST)
			_expect(_visible_pixel_count(resized) > 120, "48px readability failed: %s[%d]" % [animation_name, frame_index])
	var idle_hash: String = FileAccess.get_sha256(ProjectSettings.globalize_path(SpriteFramesBuilder.frame_path(&"idle", 0)))
	var jump_hash: String = FileAccess.get_sha256(ProjectSettings.globalize_path(SpriteFramesBuilder.frame_path(&"jump_start", 0)))
	var rise_hash: String = FileAccess.get_sha256(ProjectSettings.globalize_path(SpriteFramesBuilder.frame_path(&"jump_loop", 0)))
	var fall_hash: String = FileAccess.get_sha256(ProjectSettings.globalize_path(SpriteFramesBuilder.frame_path(&"fall", 0)))
	var land_hash: String = FileAccess.get_sha256(ProjectSettings.globalize_path(SpriteFramesBuilder.frame_path(&"land", 0)))
	_expect(idle_hash != jump_hash, "Jump Start is identical to Idle")
	_expect(rise_hash != fall_hash, "Jump Loop is identical to Fall")
	_expect(land_hash != fall_hash, "Land is identical to Fall")
	for grounded_name: StringName in [&"idle", &"run", &"jump_start", &"fall", &"land"]:
		for frame_index: int in range(sprite_frames.get_frame_count(grounded_name)):
			var image: Image = sprite_frames.get_frame_texture(grounded_name, frame_index).get_image()
			_expect(_visible_bottom(image) == 60, "Ground/extended baseline mismatch: %s[%d]" % [grounded_name, frame_index])


func _test_ground_move_jump_and_animation() -> void:
	var world: Node2D = _create_world_with_floor(1200.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	await _wait_physics_frames(4)
	_expect(player.is_on_floor(), "Player did not settle on floor")
	_expect(absf(player.position.y - 252.0) < 0.5, "Player penetrated or floated above floor")
	var camera: Camera2D = player.get_node("Camera2D") as Camera2D
	_expect(camera != null and camera.enabled, "Player Camera2D is not enabled")
	var camera_offset: Vector2 = camera.global_position - player.global_position

	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	await _wait_physics_frames(12)
	_expect(is_equal_approx(player.velocity.x, player.movement_config.move_speed), "Ground acceleration did not reach move_speed")
	_expect(player.get_movement_state_name() == &"run", "Ground movement did not select run")
	_expect((player.get_node("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D).animation == &"run", "Run animation not synchronized")
	_expect(camera.global_position - player.global_position == camera_offset, "Camera2D did not follow player transform")
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	await _wait_physics_frames(10)
	_expect(absf(player.velocity.x) < 0.1, "Ground deceleration did not stop player")
	_expect(player.get_movement_state_name() == &"idle", "Stopped player did not select idle")

	Input.action_press(PlayerScript.MOVE_LEFT_ACTION)
	await _wait_physics_frames(2)
	var sprite: AnimatedSprite2D = player.get_node("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	_expect(sprite.flip_h, "Left input did not flip the player")
	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	await physics_frame

	_state_events.clear()
	player.movement_state_changed.connect(_on_state_changed)
	Input.action_press(PlayerScript.JUMP_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(PlayerScript.JUMP_ACTION)
	_expect(player.velocity.y < 0.0, "Ground jump did not apply upward velocity")
	_expect(player.get_movement_state_name() == &"jump_start", "Jump did not enter jump_start")
	await _wait_until_grounded_after_jump(player, 120)
	await _wait_physics_frames(14)
	for required_state: StringName in [&"jump_start", &"jump_loop", &"fall", &"land", &"idle"]:
		_expect(_state_events.has(required_state), "Jump flow missed animation state: %s" % required_state)
	_cleanup_world(world)
	await process_frame


func _test_coyote_time() -> void:
	var world: Node2D = _create_world_with_floor(300.0)
	var player: Player = _spawn_player(world, Vector2(120, 252))
	_jump_origins.clear()
	player.jump_performed.connect(_on_jump_performed)
	await _wait_physics_frames(4)
	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	var left_floor: bool = false
	for frame_index: int in range(60):
		await physics_frame
		if not player.is_on_floor():
			left_floor = true
			break
	_expect(left_floor, "Coyote test player did not leave platform")
	Input.action_press(PlayerScript.JUMP_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(PlayerScript.JUMP_ACTION)
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	_expect(player.velocity.y < 0.0, "Coyote-time jump was not accepted")
	_expect(_jump_origins.has(true), "Jump was not identified as coyote-time jump")
	_cleanup_world(world)
	await process_frame


func _test_jump_buffer() -> void:
	var world: Node2D = _create_world_with_floor(600.0)
	var player: Player = _spawn_player(world, Vector2(0, 170))
	player.velocity.y = 250.0
	_jump_origins.clear()
	player.jump_performed.connect(_on_jump_performed)
	while player.position.y < 225.0:
		await physics_frame
	Input.action_press(PlayerScript.JUMP_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(PlayerScript.JUMP_ACTION)
	var buffered_jump_happened: bool = false
	for frame_index: int in range(30):
		await physics_frame
		if player.velocity.y < 0.0:
			buffered_jump_happened = true
			break
	_expect(buffered_jump_happened, "Buffered jump did not fire on landing")
	_expect(_jump_origins.has(false), "Buffered landing jump was misclassified as coyote jump")
	_cleanup_world(world)
	await process_frame


func _test_land_interrupt() -> void:
	var world: Node2D = _create_world_with_floor(600.0)
	var player: Player = _spawn_player(world, Vector2(0, 215))
	player.velocity.y = 260.0
	_state_events.clear()
	player.movement_state_changed.connect(_on_state_changed)
	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	for frame_index: int in range(45):
		await physics_frame
		if player.is_on_floor() and player.get_movement_state_name() == &"run":
			break
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	_expect(_state_events.has(&"land"), "Landing did not enter land state")
	_expect(player.get_movement_state_name() == &"run", "Horizontal input did not interrupt land into run")
	_cleanup_world(world)
	await process_frame


func _create_world_with_floor(width: float) -> Node2D:
	var world: Node2D = Node2D.new()
	var floor: StaticBody2D = StaticBody2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(width, 40.0)
	collision.position = Vector2(0, 300)
	collision.shape = shape
	floor.add_child(collision)
	world.add_child(floor)
	get_root().add_child(world)
	return world


func _spawn_player(world: Node2D, position: Vector2) -> Player:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	player.position = position
	world.add_child(player)
	return player


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _wait_until_grounded_after_jump(player: Player, maximum_frames: int) -> void:
	var left_floor: bool = false
	for frame_index: int in range(maximum_frames):
		await physics_frame
		left_floor = left_floor or not player.is_on_floor()
		if left_floor and player.is_on_floor():
			return
	_failures.append("Player did not return to floor after jump")


func _visible_pixel_count(image: Image) -> int:
	var count: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.0:
				count += 1
	return count


func _visible_bottom(image: Image) -> int:
	for y: int in range(image.get_height() - 1, -1, -1):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.0:
				return y
	return -1


func _on_state_changed(state_name: StringName) -> void:
	_state_events.append(state_name)


func _on_jump_performed(from_coyote_time: bool) -> void:
	_jump_origins.append(from_coyote_time)


func _cleanup_world(world: Node2D) -> void:
	_release_all_inputs()
	world.queue_free()


func _release_all_inputs() -> void:
	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	Input.action_release(PlayerScript.JUMP_ACTION)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("M1_PLAYER_MOVEMENT_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
