extends SceneTree

## M1.5 asset, preview, double-jump, ground/air Dash, and standalone Attack regressions.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const PREVIEW_SCENE: PackedScene = preload("res://scenes/tools/player_animation_preview.tscn")
const PlayerScript: Script = preload("res://scripts/player/player.gd")
const Concept: Script = preload("res://scripts/tools/pixel_character_generator.gd")
const SPRITE_FRAMES_PATH: String = "res://resources/player/player_sprite_frames.tres"

var _failures: Array[String] = []
var _double_jump_events: int = 0
var _action_started_events: Array[StringName] = []
var _action_finished_events: Array[StringName] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_validate_inputs_and_assets()
	await _validate_preview_controls()
	await _test_double_jump_contract()
	await _test_ground_dash_contract()
	await _test_air_dash_contract()
	await _test_attack_contract()
	_release_all_inputs()
	_finish()


func _validate_inputs_and_assets() -> void:
	_expect(PlayerScript.DASH_ACTION == &"dash", "Gameplay Dash action is not the approved Input Map name")
	_expect(PlayerScript.ATTACK_ACTION == &"attack", "Gameplay Attack action is not the approved Input Map name")
	_expect(not InputMap.has_action(&"player_dash"), "Deprecated player_dash Input Map action still exists")
	_expect(not InputMap.has_action(&"player_attack"), "Deprecated player_attack Input Map action still exists")
	for action_name: StringName in [PlayerScript.DASH_ACTION, PlayerScript.ATTACK_ACTION]:
		_expect(InputMap.has_action(action_name), "Missing action: %s" % action_name)
		_expect(not InputMap.action_get_events(action_name).is_empty(), "Input action has no events: %s" % action_name)
	_expect(
		_action_has_physical_key(PlayerScript.DASH_ACTION, KEY_SHIFT, KEY_LOCATION_LEFT),
		"Dash is not mapped to physical Left Shift"
	)
	_expect(
		_action_has_physical_key(PlayerScript.DASH_ACTION, KEY_SHIFT, KEY_LOCATION_RIGHT),
		"Dash optional Right Shift binding is missing"
	)
	_expect(
		_action_has_physical_key(PlayerScript.ATTACK_ACTION, KEY_J, KEY_LOCATION_UNSPECIFIED),
		"Attack is not mapped to physical J"
	)
	for frame_index: int in range(1, 7):
		_validate_asset("res://assets/sprites/player/assassin/attack/attack_%02d.png" % frame_index)
		_validate_asset(
			"res://assets/sprites/player/assassin/reference/deprecated_attack_slash/attack_slash_%02d.png"
			% frame_index
		)
	for animation_name: String in ["ground_dash", "air_dash"]:
		for frame_index: int in range(1, 6):
			_validate_asset(
				"res://assets/sprites/player/assassin/%s/%s_%02d.png"
				% [animation_name, animation_name, frame_index]
			)
	for frame_index: int in range(1, 7):
		_validate_asset("res://assets/sprites/player/assassin/dash_attack/dash_attack_%02d.png" % frame_index)
	var sprite_frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	_expect(sprite_frames != null, "Player SpriteFrames resource is unreadable")
	if sprite_frames == null:
		return
	_validate_sprite_animation(sprite_frames, &"ground_dash", 5, 20.0)
	_validate_sprite_animation(sprite_frames, &"air_dash", 5, 20.0)
	_validate_sprite_animation(sprite_frames, &"attack", 6, 12.0)
	_validate_sprite_animation(sprite_frames, &"dash_attack", 6, 16.0)
	_expect(not sprite_frames.has_animation(&"dash"), "Ambiguous legacy dash animation alias still exists")
	_expect(PlayerScript.DOUBLE_JUMP_ANIMATION == &"double_jump", "Future double_jump name is not reserved")
	_validate_attack_thrust_art()


func _validate_preview_controls() -> void:
	var preview: Control = PREVIEW_SCENE.instantiate() as Control
	get_root().add_child(preview)
	await process_frame
	var sprite: AnimatedSprite2D = preview.get_node("Player/VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	var ground_button: Button = preview.get_node(
		"Margin/Layout/AnimationButtons/GroundDashButton"
	) as Button
	var air_button: Button = preview.get_node("Margin/Layout/AnimationButtons/AirDashButton") as Button
	var attack_button: Button = preview.get_node("Margin/Layout/AnimationButtons/AttackButton") as Button
	var dash_attack_button: Button = preview.get_node(
		"Margin/Layout/AnimationButtons/DashAttackButton"
	) as Button
	ground_button.pressed.emit()
	await process_frame
	_expect(sprite.animation == &"ground_dash" and sprite.is_playing(), "Preview did not play ground_dash")
	air_button.pressed.emit()
	await process_frame
	_expect(sprite.animation == &"air_dash" and sprite.is_playing(), "Preview did not play air_dash")
	attack_button.pressed.emit()
	await process_frame
	_expect(sprite.animation == &"attack" and sprite.is_playing(), "Preview did not play attack")
	dash_attack_button.pressed.emit()
	await process_frame
	_expect(sprite.animation == &"dash_attack" and sprite.is_playing(), "Preview did not play dash_attack")
	preview.queue_free()
	await process_frame


func _test_double_jump_contract() -> void:
	var world: Node2D = _create_world_with_floor(1800.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	_double_jump_events = 0
	player.double_jump_performed.connect(_on_double_jump_performed)
	await _wait_physics_frames(4)
	_expect(not player.has_double_jump, "Formal double-jump ability should default false")
	_expect(player.debug_enable_double_jump, "Debug double-jump switch should be enabled")
	_expect(player.air_jumps_remaining == 1, "Start did not provision one debug air jump")
	await _press_for_physics(PlayerScript.JUMP_ACTION)
	_expect(player.velocity.y < 0.0, "First ground jump failed")
	_expect(player.air_jumps_remaining == 1, "Ground jump consumed the air jump")
	await _wait_physics_frames(12)
	_expect(player.get_coyote_time_remaining() <= 0.0, "Coyote timer did not expire before air jump")
	await _press_for_physics(PlayerScript.JUMP_ACTION)
	_expect(_double_jump_events == 1, "Legal second jump did not use the air-jump path")
	_expect(player.air_jumps_remaining == 0, "Second jump did not consume the air jump")
	var velocity_after_second_jump: float = player.velocity.y
	await _wait_physics_frames(2)
	await _press_for_physics(PlayerScript.JUMP_ACTION)
	_expect(_double_jump_events == 1, "A third airborne jump was incorrectly accepted")
	_expect(player.velocity.y > velocity_after_second_jump, "Rejected third jump reset upward velocity")
	await _wait_until_grounded(player, 180)
	_expect(player.air_jumps_remaining == 1, "Landing did not restore the air jump")
	_cleanup_world(world)
	await process_frame


func _test_ground_dash_contract() -> void:
	var world: Node2D = _create_world_with_floor(2200.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	var action_controller: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	_connect_action_events(action_controller)
	await _wait_physics_frames(4)
	await _press_for_physics(PlayerScript.DASH_ACTION)
	_expect(action_controller.is_ground_dash_active(), "Ground Dash did not start")
	_expect(sprite.animation == &"ground_dash", "Ground Dash selected the wrong animation")
	_expect(is_equal_approx(player.velocity.x, 480.0), "Ground Dash did not apply 480 px/s")
	_expect(player.air_dash_available, "Ground Dash consumed the air Dash")
	Input.action_press(PlayerScript.MOVE_LEFT_ACTION)
	await _wait_physics_frames(5)
	_expect(not sprite.flip_h, "Ground Dash facing changed while locked")
	_expect(is_equal_approx(player.velocity.x, 480.0), "Horizontal control overrode Ground Dash")
	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	await _wait_until_action_finished(action_controller, 20)
	_expect(_action_finished_events.has(&"ground_dash"), "Ground Dash did not finish")
	_expect(_action_started_events.count(&"ground_dash") == 1, "Ground Dash restarted while active")
	_expect(sprite.animation == &"idle", "Ground Dash did not return to idle")
	await _press_for_physics(PlayerScript.DASH_ACTION)
	_expect(not action_controller.is_dash_active(), "Shared Dash cooldown allowed immediate restart")
	_cleanup_world(world)
	await process_frame


func _test_air_dash_contract() -> void:
	var world: Node2D = _create_world_with_floor(2600.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	var action_controller: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	_connect_action_events(action_controller)
	await _wait_physics_frames(4)

	# Rising, no horizontal input: Dash follows current right-facing direction.
	await _press_for_physics(PlayerScript.JUMP_ACTION)
	await _wait_physics_frames(5)
	_expect(player.velocity.y < 0.0, "Rising Air Dash setup is not ascending")
	await _press_for_physics(PlayerScript.DASH_ACTION)
	_expect(action_controller.is_air_dash_active(), "Rising Air Dash did not start")
	_expect(sprite.animation == &"air_dash", "Rising Air Dash used the wrong animation")
	_expect(is_equal_approx(player.velocity.x, 480.0), "Facing-directed Air Dash used wrong horizontal speed")
	_expect(is_zero_approx(player.velocity.y), "Air Dash did not freeze vertical velocity")
	_expect(not player.air_dash_available, "Air Dash availability was not consumed")
	await _press_for_physics(PlayerScript.DASH_ACTION)
	_expect(_action_started_events.count(&"air_dash") == 1, "Repeated Shift restarted Air Dash")
	await _wait_until_action_finished(action_controller, 24)
	_expect(_action_finished_events.has(&"air_dash"), "Rising Air Dash did not finish")
	_expect(not player.air_dash_available, "Coyote/air state incorrectly restored Air Dash")
	await _wait_physics_frames(4)
	_expect(player.velocity.y > 0.0, "Gravity did not resume after Air Dash")
	_expect(sprite.animation == &"fall", "Air Dash did not return to Fall after vertical freeze")
	await _press_for_physics(PlayerScript.DASH_ACTION)
	_expect(not action_controller.is_dash_active(), "Second Air Dash was accepted before landing")
	await _wait_until_grounded(player, 180)
	_expect(player.air_dash_available, "Landing did not restore Air Dash")

	# Falling with left input: input direction overrides previous facing.
	await _press_for_physics(PlayerScript.JUMP_ACTION)
	await _wait_until_falling(player, 120)
	Input.action_press(PlayerScript.MOVE_LEFT_ACTION)
	await _wait_physics_frames(3)
	await _press_for_physics(PlayerScript.DASH_ACTION)
	_expect(action_controller.is_air_dash_active(), "Falling Air Dash did not start")
	_expect(sprite.animation == &"air_dash", "Falling Air Dash used a grounded pose")
	_expect(is_equal_approx(player.velocity.x, -480.0), "Left input did not choose Air Dash direction")
	_expect(is_zero_approx(player.velocity.y), "Falling Air Dash did not cancel vertical speed")
	_expect(sprite.flip_h, "Falling Air Dash did not face left")
	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	Input.action_press(PlayerScript.MOVE_RIGHT_ACTION)
	await _wait_physics_frames(4)
	_expect(sprite.flip_h, "Air Dash facing unlocked before completion")
	_expect(player.velocity.x < 0.0, "Air Dash direction changed during the action")
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	await _wait_until_action_finished(action_controller, 24)
	await _wait_until_grounded(player, 180)
	_expect(player.air_dash_available, "Second landing did not reliably reset Air Dash")
	_cleanup_world(world)
	await process_frame


func _test_attack_contract() -> void:
	var world: Node2D = _create_world_with_floor(1800.0)
	var player: Player = _spawn_player(world, Vector2(0, 252))
	var action_controller: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	_connect_action_events(action_controller)
	await _wait_physics_frames(4)
	await _press_for_physics(PlayerScript.ATTACK_ACTION)
	_expect(action_controller.is_attack_buffer_pending(), "Standalone Attack did not enter its chord buffer")
	await _wait_until_action_named(action_controller, &"attack", 12)
	_expect(action_controller.get_action_name() == &"attack", "Standalone J did not resolve to Attack")
	_expect(sprite.animation == &"attack", "Attack did not select its animation")
	Input.action_press(PlayerScript.MOVE_LEFT_ACTION)
	await _wait_physics_frames(8)
	_expect(sprite.animation == &"attack", "Movement animation overrode Attack")
	_expect(not sprite.flip_h, "Attack facing changed while locked")
	await _press_for_physics(PlayerScript.ATTACK_ACTION)
	_expect(_action_started_events.count(&"attack") == 1, "Repeated input restarted Attack")
	await _wait_until_action_finished(action_controller, 40)
	_expect(_action_finished_events.has(&"attack"), "Attack did not emit completion")
	await process_frame
	_expect(sprite.animation == &"run", "Attack did not return to run")
	_expect(sprite.flip_h, "Queued left facing was not applied after Attack")
	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	_cleanup_world(world)
	await process_frame


func _validate_asset(path: String) -> void:
	_expect(ResourceLoader.exists(path), "Missing asset: %s" % path)


func _validate_sprite_animation(
		sprite_frames: SpriteFrames,
		animation_name: StringName,
		expected_frames: int,
		expected_fps: float
	) -> void:
	_expect(sprite_frames.has_animation(animation_name), "SpriteFrames lacks %s" % animation_name)
	_expect(sprite_frames.get_frame_count(animation_name) == expected_frames, "%s frame count mismatch" % animation_name)
	_expect(is_equal_approx(sprite_frames.get_animation_speed(animation_name), expected_fps), "%s FPS mismatch" % animation_name)
	_expect(not sprite_frames.get_animation_loop(animation_name), "%s unexpectedly loops" % animation_name)


func _validate_attack_thrust_art() -> void:
	var current_path: String = "res://assets/sprites/player/assassin/attack/attack_04.png"
	var archived_path: String = (
		"res://assets/sprites/player/assassin/reference/deprecated_attack_slash/attack_slash_04.png"
	)
	var current_hash: String = FileAccess.get_sha256(ProjectSettings.globalize_path(current_path))
	var archived_hash: String = FileAccess.get_sha256(ProjectSettings.globalize_path(archived_path))
	_expect(current_hash != archived_hash, "Production Attack was not changed from archived slash art")
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(current_path))
	_expect(_color_count(image, Concept.PALE_STEEL, Rect2i(52, 29, 12, 5)) >= 4, "Attack core lacks upper forward blade")
	_expect(_color_count(image, Concept.PALE_STEEL, Rect2i(51, 34, 12, 5)) >= 3, "Attack core lacks lower forward blade")
	_expect(_visible_right(image) >= 62, "Attack dagger tips do not extend beyond the body")


func _color_count(image: Image, color: Color, area: Rect2i) -> int:
	var count: int = 0
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			if image.get_pixel(x, y) == color:
				count += 1
	return count


func _visible_right(image: Image) -> int:
	for x: int in range(image.get_width() - 1, -1, -1):
		for y: int in range(image.get_height()):
			if image.get_pixel(x, y).a > 0.0:
				return x
	return -1


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


func _connect_action_events(action_controller: PlayerActionController) -> void:
	_action_started_events.clear()
	_action_finished_events.clear()
	action_controller.action_started.connect(_on_action_started)
	action_controller.action_finished.connect(_on_action_finished)


func _press_for_physics(action_name: StringName) -> void:
	Input.action_press(action_name)
	await _wait_physics_frames(2)
	Input.action_release(action_name)
	await physics_frame


func _wait_physics_frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame


func _wait_until_grounded(player: Player, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if player.is_on_floor():
			return
	_failures.append("Player did not land within test budget")


func _wait_until_falling(player: Player, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if not player.is_on_floor() and player.velocity.y > 0.0:
			return
	_failures.append("Player did not enter falling state within test budget")


func _wait_until_action_finished(action_controller: PlayerActionController, maximum_frames: int) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if not action_controller.is_action_active():
			return
	_failures.append("Player action did not finish within test budget")


func _wait_until_action_named(
	action_controller: PlayerActionController,
	action_name: StringName,
	maximum_frames: int
) -> void:
	for frame_index: int in range(maximum_frames):
		await physics_frame
		if action_controller.get_action_name() == action_name:
			return
	_failures.append("Player action did not enter %s within test budget" % action_name)


func _action_has_physical_key(action_name: StringName, keycode: Key, location: KeyLocation) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		var key_event: InputEventKey = event as InputEventKey
		if (
			key_event != null
			and key_event.physical_keycode == keycode
			and key_event.location == location
		):
			return true
	return false


func _on_double_jump_performed(_air_jumps_remaining: int) -> void:
	_double_jump_events += 1


func _on_action_started(action_name: StringName) -> void:
	_action_started_events.append(action_name)


func _on_action_finished(action_name: StringName) -> void:
	_action_finished_events.append(action_name)


func _cleanup_world(world: Node2D) -> void:
	_release_all_inputs()
	world.queue_free()


func _release_all_inputs() -> void:
	Input.action_release(PlayerScript.MOVE_LEFT_ACTION)
	Input.action_release(PlayerScript.MOVE_RIGHT_ACTION)
	Input.action_release(PlayerScript.JUMP_ACTION)
	Input.action_release(PlayerScript.DASH_ACTION)
	Input.action_release(PlayerScript.ATTACK_ACTION)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("M15_PLAYER_ACTION_TEST: PASS (ground/air Dash, reset/cooldown, thrust Attack)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("M15_PLAYER_ACTION_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
