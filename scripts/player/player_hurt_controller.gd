class_name PlayerHurtController
extends Node

## Owns non-lethal hit reaction timing and presentation; Player owns collision movement.

signal hurt_started(knockback_velocity: Vector2, damage: int, source_position: Vector2)
signal hurt_finished
signal hurt_audio_requested(damage: int)

@export var config: PlayerHurtConfig
@export_node_path("Player") var player_path: NodePath = NodePath("..")
@export_node_path("HealthComponent") var health_component_path: NodePath = NodePath("../HealthComponent")
@export_node_path("HurtboxComponent") var hurtbox_path: NodePath = NodePath("../Hurtbox")
@export_node_path("PlayerAnimationController") var animation_controller_path: NodePath = NodePath("../AnimationController")
@export_node_path("PlayerActionController") var action_controller_path: NodePath = NodePath("../ActionController")
@export_node_path("AnimatedSprite2D") var animated_sprite_path: NodePath = NodePath("../VisualRoot/AnimatedSprite2D")
@export_node_path("Camera2D") var camera_path: NodePath = NodePath("../Camera2D")

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var health_component: HealthComponent = get_node_or_null(
	 health_component_path
) as HealthComponent
@onready var hurtbox: HurtboxComponent = get_node_or_null(hurtbox_path) as HurtboxComponent
@onready var animation_controller: PlayerAnimationController = get_node_or_null(
	 animation_controller_path
) as PlayerAnimationController
@onready var action_controller: PlayerActionController = get_node_or_null(
	 action_controller_path
) as PlayerActionController
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(
	 animated_sprite_path
) as AnimatedSprite2D
@onready var player_camera: Camera2D = get_node_or_null(camera_path) as Camera2D

var _hurt_remaining: float = 0.0
var _hurt_stun_remaining: float = 0.0
var _invulnerability_remaining: float = 0.0
var _flash_remaining: float = 0.0
var _shake_remaining: float = 0.0
var _camera_base_offset: Vector2 = Vector2.ZERO
var _last_damage: int = 0
var _last_source_position: Vector2 = Vector2.ZERO
var _last_knockback_velocity: Vector2 = Vector2.ZERO
var _is_hurt_active: bool = false


func _ready() -> void:
	if not _validate_dependencies():
		set_physics_process(false)
		return
	_camera_base_offset = player_camera.offset
	hurtbox.hit_received.connect(_on_hit_received)
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	_hurt_remaining = maxf(0.0, _hurt_remaining - delta)
	_hurt_stun_remaining = maxf(0.0, _hurt_stun_remaining - delta)
	_invulnerability_remaining = maxf(0.0, _invulnerability_remaining - delta)
	_flash_remaining = maxf(0.0, _flash_remaining - delta)
	_shake_remaining = maxf(0.0, _shake_remaining - delta)
	_update_sprite_feedback()
	_update_camera_shake()
	if _is_hurt_active and _hurt_remaining <= 0.0:
		_is_hurt_active = false
		hurt_finished.emit()
	if _invulnerability_remaining <= 0.0 and hurtbox.is_invulnerable:
		hurtbox.set_invulnerable(false)
	if not _is_hurt_active and _invulnerability_remaining <= 0.0 and _shake_remaining <= 0.0:
		_reset_presentation()
		set_physics_process(false)


func cancel_for_death() -> void:
	_reset_runtime_state(false)


func reset_after_respawn() -> void:
	_reset_runtime_state(true)


func is_hurt_active() -> bool:
	return _is_hurt_active


func is_control_locked() -> bool:
	return _hurt_remaining > 0.0


func is_stunned() -> bool:
	return _hurt_stun_remaining > 0.0


func get_hurt_remaining() -> float:
	return _hurt_remaining


func get_hurt_stun_remaining() -> float:
	return _hurt_stun_remaining


func get_invulnerability_remaining() -> float:
	return _invulnerability_remaining


func get_last_damage() -> int:
	return _last_damage


func get_last_source_position() -> Vector2:
	return _last_source_position


func get_last_knockback_velocity() -> Vector2:
	return _last_knockback_velocity


func get_recovery_horizontal_velocity(current_velocity_x: float, delta: float) -> float:
	if is_stunned():
		return current_velocity_x
	var recovery_duration: float = maxf(config.hurt_control_recovery_duration, 0.001)
	var recovery_rate: float = config.hurt_knockback_horizontal / recovery_duration
	return move_toward(current_velocity_x, 0.0, recovery_rate * delta)


func _on_hit_received(damage: int, source_position: Vector2, _attack_id: int) -> void:
	if player.is_dead() or health_component.is_dead() or _is_hurt_active:
		return
	_last_damage = damage
	_last_source_position = source_position
	action_controller.cancel_all_actions()
	var source_is_left: bool = source_position.x < player.global_position.x
	animation_controller.set_facing_left(source_is_left)
	animation_controller.play_one_shot(&"hurt")
	var knockback_direction: float = signf(player.global_position.x - source_position.x)
	if is_zero_approx(knockback_direction):
		knockback_direction = 1.0 if animation_controller.animated_sprite.flip_h else -1.0
	var vertical_knockback: float = config.hurt_knockback_vertical
	if not player.is_on_floor():
		vertical_knockback *= config.airborne_vertical_multiplier
	_last_knockback_velocity = Vector2(
		knockback_direction * config.hurt_knockback_horizontal,
		vertical_knockback
	)
	_hurt_stun_remaining = config.hurt_stun_duration
	_hurt_remaining = config.hurt_stun_duration + config.hurt_control_recovery_duration
	_invulnerability_remaining = config.invulnerability_duration
	_flash_remaining = config.hit_flash_duration
	_shake_remaining = config.camera_shake_duration
	_is_hurt_active = true
	hurtbox.set_invulnerable(true)
	set_physics_process(true)
	hurt_started.emit(_last_knockback_velocity, damage, source_position)
	hurt_audio_requested.emit(damage)


func _update_sprite_feedback() -> void:
	if _flash_remaining > 0.0:
		animated_sprite.modulate = Color(1.0, 0.72, 0.72, 1.0)
		return
	if _invulnerability_remaining > 0.0:
		var flicker_phase: int = floori(_invulnerability_remaining * 24.0)
		animated_sprite.modulate = Color(1.0, 1.0, 1.0, 0.48 if flicker_phase % 2 == 0 else 1.0)
		return
	animated_sprite.modulate = Color.WHITE


func _update_camera_shake() -> void:
	if _shake_remaining <= 0.0 or config.camera_shake_duration <= 0.0:
		player_camera.offset = _camera_base_offset
		return
	var strength: float = config.camera_shake_strength * (
		_shake_remaining / config.camera_shake_duration
	)
	var phase: float = _shake_remaining * 180.0
	player_camera.offset = _camera_base_offset + Vector2(
		roundf(sin(phase) * strength),
		roundf(cos(phase * 1.37) * strength * 0.65)
	)


func _reset_runtime_state(clear_history: bool) -> void:
	_is_hurt_active = false
	_hurt_remaining = 0.0
	_hurt_stun_remaining = 0.0
	_invulnerability_remaining = 0.0
	_flash_remaining = 0.0
	_shake_remaining = 0.0
	if hurtbox != null:
		hurtbox.set_invulnerable(false)
	if clear_history:
		_last_damage = 0
		_last_source_position = Vector2.ZERO
		_last_knockback_velocity = Vector2.ZERO
	_reset_presentation()
	set_physics_process(false)


func _reset_presentation() -> void:
	if animated_sprite != null:
		animated_sprite.modulate = Color.WHITE
	if player_camera != null:
		player_camera.offset = _camera_base_offset


func _validate_dependencies() -> bool:
	if config == null:
		push_error("PlayerHurtController requires PlayerHurtConfig")
		return false
	if (
		player == null
		or health_component == null
		or hurtbox == null
		or animation_controller == null
		or action_controller == null
		or animated_sprite == null
		or player_camera == null
	):
		push_error("PlayerHurtController scene composition is incomplete")
		return false
	return true
