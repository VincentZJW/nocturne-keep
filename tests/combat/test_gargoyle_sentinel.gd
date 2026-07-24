extends SceneTree

## Deterministic Gargoyle state, damage, one-hit, stun, return, and death checks.

const GARGOYLE_SCENE: PackedScene = preload("res://scenes/enemies/gargoyle_sentinel.tscn")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var root: Node2D = Node2D.new()
	get_root().add_child(root)
	var player: Player = PLAYER_SCENE.instantiate() as Player
	var gargoyle: GargoyleSentinel = GARGOYLE_SCENE.instantiate() as GargoyleSentinel
	root.add_child(player)
	root.add_child(gargoyle)
	await physics_frame
	_expect(gargoyle.config.max_health == 3 and gargoyle.config.dive_damage == 7, "Gargoyle balance mismatch")
	_expect(is_equal_approx(gargoyle.config.dive_windup, 0.45), "Gargoyle windup mismatch")
	_expect(is_equal_approx(gargoyle.config.dive_direction_lock_duration, 0.15), "Gargoyle direction lock mismatch")
	_expect(is_equal_approx(gargoyle.config.ground_stun_duration, 0.65), "Gargoyle stun mismatch")
	var required: Array[StringName] = [&"dormant", &"wake", &"hover", &"dive_windup", &"dive", &"ground_stun", &"return_to_air", &"hurt", &"death_fall", &"death_shatter"]
	for animation_name: StringName in required:
		_expect(gargoyle.animated_sprite.sprite_frames.has_animation(animation_name), "Gargoyle animation missing: %s" % animation_name)
	gargoyle.set_target(player)
	gargoyle.animated_sprite.animation_finished.emit()
	_expect(gargoyle.get_state_name() == &"Track", "Gargoyle did not wake into Track")
	gargoyle._enter_dive_windup()
	gargoyle._process_windup(0.46)
	_expect(gargoyle.get_state_name() == &"Dive", "Gargoyle did not enter Dive")
	var health_before: int = player.health_component.current_health
	_expect(gargoyle.dive_hitbox.try_hit(player.hurtbox), "Gargoyle Dive did not hit Player")
	_expect(not gargoyle.dive_hitbox.try_hit(player.hurtbox), "Gargoyle Dive hit Player twice")
	_expect(player.health_component.current_health == health_before - 7, "Gargoyle Dive damage is not seven")
	gargoyle._enter_ground_stun()
	_expect(gargoyle.get_state_name() == &"GroundStun", "Gargoyle world impact did not stun")
	gargoyle._process_ground_stun(0.66)
	_expect(gargoyle.get_state_name() == &"ReturnToAir", "Gargoyle did not leave stun")
	gargoyle.health_component.take_damage(3)
	_expect(gargoyle.is_dead() and gargoyle.animated_sprite.animation == &"death_fall", "Gargoyle did not start death fall")
	_expect(gargoyle.find_child("*Ghost*", true, false) == null, "Gargoyle death created a ghost")
	gargoyle.animated_sprite.animation_finished.emit()
	_expect(gargoyle.animated_sprite.animation == &"death_shatter", "Gargoyle did not shatter")
	gargoyle.animated_sprite.animation_finished.emit()
	_expect(not gargoyle.visible, "Gargoyle did not complete cleanup")
	root.queue_free()
	await process_frame
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("GARGOYLE_SENTINEL_TEST: PASS (wake, dive 7 once, stun 0.65, return, shatter)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("GARGOYLE_SENTINEL_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
