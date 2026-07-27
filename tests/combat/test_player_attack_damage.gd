extends SceneTree

## Connects existing Player Attack frame windows to Castle Guard Health.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const GUARD_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var world: Node2D = Node2D.new()
	get_root().add_child(world)
	var player: Player = PLAYER_SCENE.instantiate() as Player
	var guard: CastleGuard = GUARD_SCENE.instantiate() as CastleGuard
	world.add_child(player)
	world.add_child(guard)
	await process_frame
	player.set_physics_process(false)
	guard.set_physics_process(false)
	_test_normal_attack(player, guard)
	_test_dash_attack(player, guard)
	_test_facing_and_cancel_cleanup(player)
	world.queue_free()
	await process_frame
	_finish()


func _test_normal_attack(player: Player, guard: CastleGuard) -> void:
	guard.health_component.reset_to_full()
	var actions: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	_expect(actions.try_start_actions(true, false, true, 1.0, false), "J did not start Attack")
	sprite.frame = 0
	sprite.frame_changed.emit()
	_expect(not actions.attack_hitbox.is_active, "attack_01 opened Hitbox during windup")
	sprite.frame = 1
	sprite.frame_changed.emit()
	_expect(actions.attack_hitbox.is_active, "attack_02 did not open normal Attack Hitbox")
	_expect(actions.attack_hitbox.damage == 10, "Normal Attack damage is not ten")
	_expect(actions.attack_hitbox.try_hit(guard.hurtbox), "Normal Attack did not hit Castle Guard")
	_expect(guard.health_component.current_health == 20, "Normal Attack did not remove ten Guard Health")
	sprite.frame = 2
	sprite.frame_changed.emit()
	_expect(not actions.attack_hitbox.try_hit(guard.hurtbox), "Same normal Attack hit twice")
	_expect(guard.health_component.current_health == 20, "Normal Attack duplicate changed Health")
	sprite.frame = 3
	sprite.frame_changed.emit()
	_expect(not actions.attack_hitbox.is_active, "attack_04 recovery retained normal Hitbox")
	actions.cancel_all_actions()
	player.animation_controller.reset_to_idle()


func _test_dash_attack(player: Player, guard: CastleGuard) -> void:
	guard.health_component.reset_to_full()
	var actions: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	_expect(actions.try_start_actions(true, true, true, 1.0, false), "Shift+J did not start Dash Attack")
	sprite.frame = 1
	sprite.frame_changed.emit()
	_expect(not actions.dash_attack_hitbox.is_active, "dash_attack_02 opened Hitbox too early")
	sprite.frame = 2
	sprite.frame_changed.emit()
	_expect(actions.dash_attack_hitbox.is_active, "dash_attack_03 did not open Dash Attack Hitbox")
	_expect(actions.dash_attack_hitbox.damage == 20, "Dash Attack damage is not twenty")
	var stable_attack_id: int = actions.dash_attack_hitbox.attack_id
	_expect(actions.dash_attack_hitbox.attacker == player, "Dash Attack did not retain Player as source")
	_expect(
		actions.dash_attack_hitbox.get_source_position().is_equal_approx(player.global_position),
		"Dash Attack source position did not resolve to Player root"
	)
	_expect(actions.dash_attack_hitbox.try_hit(guard.hurtbox), "Dash Attack did not hit Castle Guard")
	_expect(guard.health_component.current_health == 10, "Dash Attack did not remove twenty Guard Health")
	sprite.frame = 3
	sprite.frame_changed.emit()
	_expect(
		actions.dash_attack_hitbox.attack_id == stable_attack_id,
		"Dash Attack generated a new attack id on its second active frame"
	)
	_expect(not actions.dash_attack_hitbox.try_hit(guard.hurtbox), "Same Dash Attack hit twice")
	sprite.frame = 4
	sprite.frame_changed.emit()
	_expect(not actions.dash_attack_hitbox.is_active, "dash_attack_05 retained Hitbox")
	actions.cancel_all_actions()
	player.animation_controller.reset_to_idle()


func _test_facing_and_cancel_cleanup(player: Player) -> void:
	player.animation_controller.set_facing_left(true)
	_expect(player.action_controller.combat_root.scale.x < 0.0, "Left facing did not mirror Player hitboxes")
	player.action_controller.try_start_actions(true, false, true, -1.0, true)
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	sprite.frame = 1
	sprite.frame_changed.emit()
	_expect(player.action_controller.attack_hitbox.is_active, "Left Attack did not open Hitbox")
	player.action_controller.cancel_all_actions()
	_expect(not player.action_controller.attack_hitbox.is_active, "Action cancel left normal Hitbox active")
	_expect(not player.action_controller.dash_attack_hitbox.is_active, "Action cancel left Dash Hitbox active")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PLAYER_ATTACK_DAMAGE_TEST: PASS (Attack 10, Dash Attack 20, windows, dedup, facing)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("PLAYER_ATTACK_DAMAGE_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
