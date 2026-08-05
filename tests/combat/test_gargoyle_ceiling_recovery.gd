extends SceneTree

## Deterministic ten-cycle regression for the formal Gargoyle top-limit recovery contract.

const GARGOYLE_SCENE: PackedScene = preload("res://shared/scenes/enemies/gargoyle_sentinel.tscn")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const BOUNDS_SCENE: PackedScene = preload("res://shared/scenes/world/world_bounds_2d.tscn")

var _failures: PackedStringArray = []
var _cycle_rows: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var host := Node2D.new()
	root.add_child(host)
	var bounds: WorldBounds2D = BOUNDS_SCENE.instantiate() as WorldBounds2D
	bounds.actor_bounds = Rect2(0.0, 0.0, 1280.0, 720.0)
	bounds.flight_margin = 56.0
	host.add_child(bounds)
	var player: Player = PLAYER_SCENE.instantiate() as Player
	player.position = Vector2(640.0, 610.0)
	host.add_child(player)
	var gargoyle: GargoyleSentinel = GARGOYLE_SCENE.instantiate() as GargoyleSentinel
	gargoyle.position = Vector2(640.0, 260.0)
	host.add_child(gargoyle)
	await physics_frame
	gargoyle.set_physics_process(false)
	gargoyle.set_target(player)
	gargoyle.animated_sprite.animation_finished.emit()
	var safe_top: float = bounds.get_safe_flight_top_y()
	var expected_anchor: Vector2 = gargoyle.home_position

	for cycle: int in range(1, 11):
		gargoyle.cooldown_timer = 0.0
		gargoyle._enter_dive_windup()
		gargoyle._process_windup(gargoyle.config.dive_windup + 0.01)
		_check(gargoyle.current_state == gargoyle.DIVE, "Cycle %d did not begin Dive" % cycle)
		gargoyle.global_position = Vector2(420.0 + float(cycle * 28), safe_top - 8.0)
		gargoyle.velocity = Vector2(20.0 if cycle % 2 == 0 else -20.0, -320.0)
		gargoyle._enforce_flight_bounds()
		var legal_return: bool = (
			gargoyle.return_target.y >= safe_top
			and gargoyle.return_target.y <= bounds.get_bottom_limit_y() - gargoyle.config.minimum_hover_height
		)
		_check(gargoyle.current_state == gargoyle.RETURN_TO_PLAYABLE_ALTITUDE, "Cycle %d did not enter ceiling Return" % cycle)
		_check(not gargoyle.dive_hitbox.is_active, "Cycle %d left DiveHitbox active" % cycle)
		_check(legal_return, "Cycle %d produced illegal Return Target %s" % [cycle, gargoyle.return_target])
		_check(gargoyle.return_target.is_equal_approx(expected_anchor), "Cycle %d did not retain the original Hover Anchor" % cycle)
		gargoyle.global_position = gargoyle.return_target
		gargoyle._process_return(0.0)
		_check(gargoyle.current_state == gargoyle.HOVER_RECOVER, "Cycle %d did not enter HoverRecover" % cycle)
		var wait_time: float = gargoyle.state_timer
		gargoyle._process_hover_recover(gargoyle.config.ceiling_recovery_wait + 0.01)
		_check(gargoyle.current_state == gargoyle.TRACK, "Cycle %d did not reacquire Player" % cycle)
		_check(gargoyle.target == player, "Cycle %d lost Player target" % cycle)
		_cycle_rows.append(
			"%02d | Dive | (%.1f,%.1f) | yes | %.2f | yes | %s"
			% [cycle, gargoyle.return_target.x, gargoyle.return_target.y, wait_time, gargoyle.current_state]
		)

	_check(gargoyle.attack_cycle_count == 10, "Expected ten complete attack starts")
	_check(gargoyle.ceiling_recovery_count == 10, "Expected ten top-limit recovery events")
	gargoyle.set_target(null)
	gargoyle._process_hover_recover(gargoyle.config.ceiling_recovery_wait + 0.01)
	gargoyle.set_target(player)
	gargoyle._enter_hurt(player.global_position + Vector2.LEFT * 20.0)
	gargoyle._process_hurt(gargoyle.config.hurt_duration + 0.01)
	_check(gargoyle.current_state == gargoyle.RETURN_TO_AIR, "Hurt did not recover through ReturnToAir")
	gargoyle.global_position = gargoyle.return_target
	gargoyle._process_return(0.0)
	gargoyle._process_hover_recover(gargoyle.config.ceiling_recovery_wait + 0.01)
	_check(gargoyle.current_state == gargoyle.TRACK, "Hurt recovery did not return to Track")
	gargoyle._ceiling_recovery_latched = true
	gargoyle.set_ai_active(false)
	_check(not gargoyle._ceiling_recovery_latched, "Checkpoint reset retained the ceiling latch")
	gargoyle.set_ai_active(true)
	gargoyle.set_target(player)
	gargoyle.animated_sprite.animation_finished.emit()
	_check(gargoyle.current_state == gargoyle.TRACK, "Room re-entry did not re-arm tracking")

	for row: String in _cycle_rows:
		print("GARGOYLE_CYCLE | ", row)
	host.queue_free()
	await process_frame
	_finish()


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("GARGOYLE_CEILING_RECOVERY_TEST: PASS cycles=10 ceiling=10 reacquire=yes hurt_recovery=yes")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)
