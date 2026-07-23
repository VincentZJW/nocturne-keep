extends SceneTree

## Player Hurt, knockback, invulnerability, interruption, and Death precedence regression.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var world: Node2D = _create_world()
	var player: Player = PLAYER_SCENE.instantiate() as Player
	var enemy_hitbox: HitboxComponent = _make_enemy_hitbox()
	player.position = Vector2(22.0, 270.0)
	world.add_child(player)
	world.add_child(enemy_hitbox)
	await _wait_physics_frames(5)
	_test_asset_contract(player)
	await _test_ground_hurt_and_invulnerability(player, enemy_hitbox)
	await _test_air_hurt(player, enemy_hitbox)
	await _test_death_precedence(player, enemy_hitbox)
	world.queue_free()
	await process_frame
	_finish()


func _test_asset_contract(player: Player) -> void:
	var frames: SpriteFrames = player.animation_controller.animated_sprite.sprite_frames
	var frame_hashes: Dictionary[String, bool] = {}
	_expect(frames.get_frame_count(&"hurt") == 3, "Hurt does not contain three frames")
	_expect(is_equal_approx(frames.get_animation_speed(&"hurt"), 16.0), "Hurt is not 16 FPS")
	_expect(not frames.get_animation_loop(&"hurt"), "Hurt must not loop")
	for frame_index: int in range(3):
		var expected_path: String = "res://assets/sprites/player/assassin/hurt/hurt_%02d.png" % (frame_index + 1)
		_expect(
			PlayerSpriteFramesBuilder.frame_path(&"hurt", frame_index) == expected_path,
			"Hurt frame %d is not sourced from production art" % (frame_index + 1)
		)
		var source_image: Image = Image.load_from_file(ProjectSettings.globalize_path(expected_path))
		_expect(source_image != null and source_image.get_size() == Vector2i(64, 64), "Hurt source is not 64x64")
		if source_image != null:
			var readability: Image = PixelCanvas.resize_nearest(source_image, Vector2i(48, 48))
			_expect(_has_binary_visible_pixels(readability), "Hurt frame lost 48px nearest-neighbor readability")
		frame_hashes[FileAccess.get_sha256(ProjectSettings.globalize_path(expected_path))] = true
		var archived_path: String = (
			"res://assets/sprites/player/assassin/reference/deprecated_hurt_placeholder/"
			+ "placeholder_hurt_%02d.png" % (frame_index + 1)
		)
		_expect(FileAccess.file_exists(archived_path), "Archived Hurt placeholder is missing")
		var placeholder_path: String = (
			"res://assets/sprites/player/assassin/placeholder/"
			+ "placeholder_hurt_%02d.png" % (frame_index + 1)
		)
		_expect(
			FileAccess.get_sha256(ProjectSettings.globalize_path(archived_path))
			== FileAccess.get_sha256(ProjectSettings.globalize_path(placeholder_path)),
			"Archived Hurt placeholder is not byte-identical"
		)
	_expect(frame_hashes.size() == 3, "Production Hurt contains duplicate frame files")


func _test_ground_hurt_and_invulnerability(
	player: Player,
	enemy_hitbox: HitboxComponent
) -> void:
	var actions: PlayerActionController = player.action_controller
	_expect(actions.try_start_actions(true, false, true, 1.0, false), "Attack setup did not start")
	enemy_hitbox.global_position = player.global_position + Vector2(40.0, 0.0)
	enemy_hitbox.begin_attack(9001, 5)
	_expect(enemy_hitbox.try_hit(player.hurtbox), "First enemy hit was rejected")
	_expect(player.health_component.current_health == 95, "First hit did not deal five damage")
	_expect(player.get_life_state_name() == &"Hurt", "Accepted damage did not enter Hurt")
	_expect(player.animation_controller.animated_sprite.animation == &"hurt", "Hurt animation did not start")
	_expect(not actions.is_action_active(), "Hurt did not cancel the active Attack")
	_expect(not actions.attack_hitbox.is_active and not actions.dash_attack_hitbox.is_active, "Hurt retained a Player attack Hitbox")
	_expect(player.velocity.x < 0.0 and player.velocity.y < 0.0, "Right-side hit did not knock Player left/up")
	_expect(player.hurt_controller.get_last_damage() == 5, "Hurt debug damage did not record five")
	var second_hitbox: HitboxComponent = _make_enemy_hitbox()
	get_root().add_child(second_hitbox)
	second_hitbox.global_position = player.global_position + Vector2(-40.0, 0.0)
	second_hitbox.begin_attack(9002, 5)
	_expect(not second_hitbox.try_hit(player.hurtbox), "Invulnerability accepted a second enemy hit")
	_expect(player.health_component.current_health == 95, "Invulnerability failed to prevent repeated damage")
	await physics_frame
	_expect(player.animation_controller.animated_sprite.modulate != Color.WHITE, "Hit flash/flicker did not affect Sprite modulation")
	_expect(player.player_camera.offset != Vector2.ZERO, "Hit reaction did not apply Camera2D shake")
	await _wait_physics_frames(18)
	_expect(player.get_life_state_name() == &"Alive", "Hurt did not restore control after recovery")
	_expect(player.global_position.x >= 21.9, "Knockback bypassed the left wall collision")
	_expect(player.hurt_controller.get_invulnerability_remaining() > 0.0, "Hurt invulnerability ended too early")
	await _wait_physics_frames(16)
	_expect(player.hurt_controller.get_invulnerability_remaining() <= 0.0, "Invulnerability exceeded 0.5 seconds")
	_expect(not player.hurtbox.is_invulnerable, "Hurtbox remained invulnerable after timer expiry")
	_expect(player.animation_controller.animated_sprite.modulate == Color.WHITE, "Sprite modulation did not restore after Hurt")
	_expect(player.player_camera.offset == Vector2.ZERO, "Camera2D offset did not restore after Hurt")
	second_hitbox.queue_free()


func _test_air_hurt(player: Player, enemy_hitbox: HitboxComponent) -> void:
	player.global_position = Vector2(120.0, 190.0)
	player.velocity = Vector2.ZERO
	await physics_frame
	enemy_hitbox.global_position = player.global_position + Vector2(-40.0, 0.0)
	enemy_hitbox.begin_attack(9003, 5)
	_expect(enemy_hitbox.try_hit(player.hurtbox), "Airborne enemy hit was rejected")
	_expect(player.velocity.x > 0.0, "Left-side airborne hit did not knock Player right")
	_expect(
		is_equal_approx(player.velocity.y, -77.0),
		"Airborne vertical knockback did not use the configured 0.70 multiplier"
	)
	await _wait_physics_frames(34)


func _test_death_precedence(player: Player, enemy_hitbox: HitboxComponent) -> void:
	player.health_component.set_current_health(5)
	player.hurt_controller.reset_after_respawn()
	enemy_hitbox.global_position = player.global_position + Vector2(40.0, 0.0)
	enemy_hitbox.begin_attack(9004, 5)
	_expect(enemy_hitbox.try_hit(player.hurtbox), "Lethal enemy hit was rejected")
	_expect(player.is_dead(), "Lethal hit did not enter Death")
	_expect(not player.is_hurt(), "Death was incorrectly replaced by Hurt")
	_expect(not player.hurt_controller.is_hurt_active(), "Hurt reaction remained active after Death")


func _create_world() -> Node2D:
	var world: Node2D = Node2D.new()
	var floor: StaticBody2D = StaticBody2D.new()
	floor.collision_layer = 1
	var floor_collision: CollisionShape2D = CollisionShape2D.new()
	var floor_shape: RectangleShape2D = RectangleShape2D.new()
	floor_shape.size = Vector2(500.0, 40.0)
	floor_collision.position = Vector2(200.0, 320.0)
	floor_collision.shape = floor_shape
	floor.add_child(floor_collision)
	world.add_child(floor)
	var wall: StaticBody2D = StaticBody2D.new()
	wall.collision_layer = 1
	var wall_collision: CollisionShape2D = CollisionShape2D.new()
	var wall_shape: RectangleShape2D = RectangleShape2D.new()
	wall_shape.size = Vector2(20.0, 400.0)
	wall_collision.position = Vector2(0.0, 120.0)
	wall_collision.shape = wall_shape
	wall.add_child(wall_collision)
	world.add_child(wall)
	get_root().add_child(world)
	return world


func _make_enemy_hitbox() -> HitboxComponent:
	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.faction = &"enemy"
	hitbox.damage = 5
	hitbox.collision_layer = 64
	hitbox.collision_mask = 8
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(40.0, 18.0)
	collision.shape = shape
	hitbox.add_child(collision)
	return hitbox


func _wait_physics_frames(count: int) -> void:
	for _frame_index: int in range(count):
		await physics_frame


func _has_binary_visible_pixels(image: Image) -> bool:
	var visible_pixels: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var alpha: float = image.get_pixel(x, y).a
			if alpha <= 0.0:
				continue
			visible_pixels += 1
			if not is_equal_approx(alpha, 1.0):
				return false
	return visible_pixels > 100


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PLAYER_HURT_TEST: PASS (art, interruption, collision knockback, invulnerability, air, Death precedence)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("PLAYER_HURT_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
