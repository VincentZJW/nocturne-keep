class_name PlayerActionController
extends Node

## Edge-triggered player actions. Dash stamina is delegated to PlayerStaminaComponent.

signal action_started(action_name: StringName)
signal action_finished(action_name: StringName)
signal action_transitioned(previous_action: StringName, next_action: StringName)

enum ActionState {
	NONE,
	GROUND_DASH,
	AIR_DASH,
	ATTACK,
	DASH_ATTACK,
}

const GROUND_DASH_ACTION: StringName = &"ground_dash"
const DASH_START_ANIMATION: StringName = &"dash_start"
const DASH_LOOP_ANIMATION: StringName = &"dash_loop"
const DASH_END_ANIMATION: StringName = &"dash_end"
const AIR_DASH_ANIMATION: StringName = &"air_dash"
const ATTACK_ANIMATION: StringName = &"attack"
const DASH_ATTACK_ANIMATION: StringName = &"dash_attack"

@export var action_config: PlayerActionPrototypeConfig
@export_node_path("PlayerAnimationController") var animation_controller_path: NodePath = NodePath("../AnimationController")
@export_node_path("PlayerStaminaComponent") var stamina_component_path: NodePath = NodePath("../StaminaComponent")

@onready var animation_controller: PlayerAnimationController = get_node_or_null(
	animation_controller_path
) as PlayerAnimationController
@onready var stamina_component: PlayerStaminaComponent = get_node_or_null(
	stamina_component_path
) as PlayerStaminaComponent

var _action_state: ActionState = ActionState.NONE
var _dash_direction: float = 1.0
var _dash_motion_remaining: float = 0.0
var _dash_attack_window_remaining: float = 0.0
var _dash_attack_elapsed: float = 0.0
var _dash_attack_used: bool = false
var _dash_attack_started_airborne: bool = false
var _dash_buffered: bool = false
var _dash_buffer_timer: float = 0.0
var _dash_segment_elapsed: float = 0.0
var _ground_dash_ending: bool = false
var _current_dash_number: int = 0
var _attack_buffer_timer: float = 0.0
var _attack_buffered: bool = false
var _last_attack_input_to_hit_time: float = -1.0
var _attack_hit_time_recorded: bool = false


func _ready() -> void:
	if action_config == null:
		push_error("PlayerActionController requires a PlayerActionPrototypeConfig resource")
		return
	if animation_controller == null:
		push_error("PlayerActionController requires a PlayerAnimationController")
		return
	if stamina_component == null:
		push_error("PlayerActionController requires a PlayerStaminaComponent")
		return
	animation_controller.one_shot_finished.connect(_on_one_shot_finished)
	animation_controller.animated_sprite.frame_changed.connect(_on_animation_frame_changed)


func advance(delta: float) -> void:
	if is_dash_active():
		_dash_motion_remaining = maxf(0.0, _dash_motion_remaining - delta)
		_dash_attack_window_remaining = maxf(0.0, _dash_attack_window_remaining - delta)
		_dash_segment_elapsed += delta
	elif is_dash_attack_active():
		_dash_attack_elapsed += delta
	if _dash_buffered:
		_dash_buffer_timer = maxf(0.0, _dash_buffer_timer - delta)
		if _dash_buffer_timer <= 0.0:
			_clear_dash_buffer()
	if _attack_buffered:
		_attack_buffer_timer = maxf(0.0, _attack_buffer_timer - delta)


func try_start_actions(
	attack_pressed: bool,
	dash_pressed: bool,
	is_grounded: bool,
	air_dash_available: bool,
	facing_left: bool
) -> bool:
	if animation_controller == null or stamina_component == null:
		return false
	if is_dash_attack_active():
		return false
	if _action_state == ActionState.ATTACK:
		if attack_pressed and not _attack_buffered:
			_attack_buffered = true
			_attack_buffer_timer = action_config.attack_buffer_time
		if _attack_buffered and can_chain_attack():
			return _chain_attack()
		if _attack_buffered and _attack_buffer_timer <= 0.0:
			_clear_attack_buffer()
		return false
	if _action_state == ActionState.GROUND_DASH:
		if attack_pressed and is_dash_attack_input_window_open():
			return _transition_dash_to_dash_attack()
		if dash_pressed and not _dash_buffered:
			_dash_buffered = true
			_dash_buffer_timer = action_config.dash_input_buffer_time
		if _ground_dash_ending and dash_pressed:
			return _continue_ground_dash()
		if not _ground_dash_ending and _dash_motion_remaining <= 0.0:
			return _resolve_ground_dash_segment()
		return false
	if _action_state == ActionState.AIR_DASH:
		if attack_pressed and is_dash_attack_input_window_open():
			return _transition_dash_to_dash_attack()
		return false
	if _action_state != ActionState.NONE:
		return false
	if attack_pressed and dash_pressed:
		if not is_grounded and not air_dash_available:
			return _start_attack()
		_dash_direction = -1.0 if facing_left else 1.0
		return _start_direct_dash_attack(not is_grounded)
	if attack_pressed:
		return _start_attack()
	if dash_pressed:
		if not is_grounded and not air_dash_available:
			return false
		_dash_direction = -1.0 if facing_left else 1.0
		return _start_dash(is_grounded)
	return false


func is_action_active() -> bool:
	return _action_state != ActionState.NONE


func is_dash_active() -> bool:
	return _action_state == ActionState.GROUND_DASH or _action_state == ActionState.AIR_DASH


func is_ground_dash_active() -> bool:
	return _action_state == ActionState.GROUND_DASH


func is_air_dash_active() -> bool:
	return _action_state == ActionState.AIR_DASH


func is_dash_attack_active() -> bool:
	return _action_state == ActionState.DASH_ATTACK


func is_airborne_dash_attack_active() -> bool:
	return is_dash_attack_active() and _dash_attack_started_airborne


func is_dash_attack_input_window_open() -> bool:
	return is_dash_active() and _dash_attack_window_remaining > 0.0 and not _dash_attack_used


func is_dash_attack_used() -> bool:
	return _dash_attack_used


func is_attack_buffered() -> bool:
	return _attack_buffered


func is_dash_buffered() -> bool:
	return _dash_buffered


func get_action_name() -> StringName:
	match _action_state:
		ActionState.GROUND_DASH:
			return GROUND_DASH_ACTION
		ActionState.AIR_DASH:
			return AIR_DASH_ANIMATION
		ActionState.ATTACK:
			return ATTACK_ANIMATION
		ActionState.DASH_ATTACK:
			return DASH_ATTACK_ANIMATION
	return &""


func get_action_state_name() -> StringName:
	match _action_state:
		ActionState.GROUND_DASH:
			return &"GroundDash"
		ActionState.AIR_DASH:
			return &"AirDash"
		ActionState.ATTACK:
			return &"Attack"
		ActionState.DASH_ATTACK:
			return &"DashAttack"
	return &"None"


func get_action_horizontal_velocity() -> float:
	if is_dash_active():
		return _dash_direction * action_config.dash_speed if _dash_motion_remaining > 0.0 else 0.0
	if not is_dash_attack_active():
		return 0.0
	if _dash_attack_elapsed <= action_config.dash_attack_move_duration:
		return _dash_direction * action_config.dash_attack_speed
	var recovery_elapsed: float = _dash_attack_elapsed - action_config.dash_attack_move_duration
	if recovery_elapsed >= action_config.dash_attack_recovery_duration:
		return 0.0
	var recovery_ratio: float = 1.0 - recovery_elapsed / action_config.dash_attack_recovery_duration
	return _dash_direction * action_config.dash_attack_speed * maxf(0.0, recovery_ratio)


func get_dash_horizontal_velocity() -> float:
	return get_action_horizontal_velocity() if is_dash_active() else 0.0


func get_dash_motion_remaining() -> float:
	return _dash_motion_remaining


func get_dash_cooldown_remaining() -> float:
	return 0.0


func get_dash_attack_window_remaining() -> float:
	return _dash_attack_window_remaining


func get_dash_buffer_remaining() -> float:
	return _dash_buffer_timer


func get_current_dash_number() -> int:
	return _current_dash_number


func get_attack_buffer_remaining() -> float:
	return _attack_buffer_timer


func get_current_attack_frame() -> int:
	if _action_state != ActionState.ATTACK or animation_controller == null:
		return 0
	return animation_controller.animated_sprite.frame + 1


func can_chain_attack() -> bool:
	return (
		_action_state == ActionState.ATTACK
		and animation_controller != null
		and animation_controller.animated_sprite.animation == ATTACK_ANIMATION
		and animation_controller.animated_sprite.frame >= 2
	)


func get_attack_input_to_hit_time() -> float:
	return _last_attack_input_to_hit_time


func get_dash_direction() -> float:
	return _dash_direction


func _start_dash(is_grounded: bool) -> bool:
	if not stamina_component.try_consume_dash():
		return false
	var dash_state: ActionState = ActionState.GROUND_DASH if is_grounded else ActionState.AIR_DASH
	var dash_animation: StringName = DASH_START_ANIMATION if is_grounded else AIR_DASH_ANIMATION
	if not _start_action(dash_state, dash_animation):
		# The resource was already validated at startup; refund only this impossible presentation failure.
		stamina_component.refund_dash_charge()
		return false
	_dash_motion_remaining = action_config.dash_duration
	_dash_attack_window_remaining = action_config.dash_attack_input_window
	_dash_attack_used = false
	_dash_attack_started_airborne = not is_grounded
	_dash_segment_elapsed = 0.0
	_ground_dash_ending = false
	_current_dash_number = 1
	_clear_dash_buffer()
	return true


func _continue_ground_dash() -> bool:
	if _dash_segment_elapsed < action_config.dash_min_interval:
		return false
	if not stamina_component.try_consume_dash():
		_clear_dash_buffer()
		if not _ground_dash_ending:
			_start_ground_dash_end()
		return false
	_clear_dash_buffer()
	_ground_dash_ending = false
	_dash_motion_remaining = action_config.dash_duration
	_dash_attack_window_remaining = action_config.dash_attack_input_window
	_dash_attack_used = false
	_dash_segment_elapsed = 0.0
	_current_dash_number += 1
	if animation_controller.animated_sprite.animation != DASH_LOOP_ANIMATION:
		animation_controller.transition_locked_animation(DASH_LOOP_ANIMATION)
	action_started.emit(GROUND_DASH_ACTION)
	return true


func _resolve_ground_dash_segment() -> bool:
	if _dash_buffered and _dash_buffer_timer > 0.0:
		return _continue_ground_dash()
	_start_ground_dash_end()
	return false


func _start_ground_dash_end() -> void:
	_clear_dash_buffer()
	_ground_dash_ending = true
	_dash_motion_remaining = 0.0
	_dash_attack_window_remaining = 0.0
	animation_controller.transition_locked_animation(DASH_END_ANIMATION)


func _start_direct_dash_attack(started_airborne: bool) -> bool:
	if not stamina_component.try_consume_dash():
		return false
	_clear_dash_buffer()
	_clear_attack_buffer()
	if not animation_controller.play_one_shot(DASH_ATTACK_ANIMATION):
		stamina_component.refund_dash_charge()
		return false
	_dash_attack_used = true
	_dash_attack_started_airborne = started_airborne
	_dash_attack_elapsed = 0.0
	_dash_attack_window_remaining = 0.0
	_current_dash_number = 1
	_action_state = ActionState.DASH_ATTACK
	action_started.emit(DASH_ATTACK_ANIMATION)
	return true


func _start_attack() -> bool:
	_clear_attack_buffer()
	if not _start_action(ActionState.ATTACK, ATTACK_ANIMATION):
		return false
	_reset_attack_response_measurement()
	return true


func _chain_attack() -> bool:
	if not animation_controller.restart_locked_one_shot(ATTACK_ANIMATION):
		return false
	_clear_attack_buffer()
	_reset_attack_response_measurement()
	action_started.emit(ATTACK_ANIMATION)
	return true


func _transition_dash_to_dash_attack() -> bool:
	var previous_action: StringName = get_action_name()
	if not animation_controller.play_one_shot(DASH_ATTACK_ANIMATION):
		return false
	_dash_attack_used = true
	_dash_attack_started_airborne = _action_state == ActionState.AIR_DASH
	_dash_attack_elapsed = 0.0
	_dash_motion_remaining = 0.0
	_dash_attack_window_remaining = 0.0
	_action_state = ActionState.DASH_ATTACK
	_clear_dash_buffer()
	_clear_attack_buffer()
	action_transitioned.emit(previous_action, DASH_ATTACK_ANIMATION)
	action_started.emit(DASH_ATTACK_ANIMATION)
	return true


func _start_action(next_state: ActionState, animation_name: StringName) -> bool:
	if not animation_controller.play_one_shot(animation_name):
		return false
	_action_state = next_state
	action_started.emit(get_action_name())
	return true


func _clear_dash_buffer() -> void:
	_dash_buffered = false
	_dash_buffer_timer = 0.0


func _clear_attack_buffer() -> void:
	_attack_buffered = false
	_attack_buffer_timer = 0.0


func _reset_attack_response_measurement() -> void:
	_last_attack_input_to_hit_time = -1.0
	_attack_hit_time_recorded = false


func _finish_action(finished_action: StringName) -> void:
	_action_state = ActionState.NONE
	_clear_attack_buffer()
	_clear_dash_buffer()
	_dash_motion_remaining = 0.0
	_dash_attack_window_remaining = 0.0
	_dash_attack_elapsed = 0.0
	_ground_dash_ending = false
	_current_dash_number = 0
	action_finished.emit(finished_action)


func _on_animation_frame_changed() -> void:
	if (
		_action_state != ActionState.ATTACK
		or _attack_hit_time_recorded
		or animation_controller.animated_sprite.animation != ATTACK_ANIMATION
		or animation_controller.animated_sprite.frame < 1
	):
		return
	var sprite_frames: SpriteFrames = animation_controller.animated_sprite.sprite_frames
	var animation_speed: float = sprite_frames.get_animation_speed(ATTACK_ANIMATION)
	var effective_speed: float = animation_speed * absf(animation_controller.animated_sprite.speed_scale)
	_last_attack_input_to_hit_time = 1.0 / effective_speed if effective_speed > 0.0 else -1.0
	_attack_hit_time_recorded = true


func _on_one_shot_finished(animation_name: StringName) -> void:
	if _action_state == ActionState.GROUND_DASH:
		if animation_name == DASH_START_ANIMATION and not _ground_dash_ending:
			animation_controller.transition_locked_animation(DASH_LOOP_ANIMATION)
			return
		if animation_name == DASH_END_ANIMATION and _ground_dash_ending:
			_finish_action(GROUND_DASH_ACTION)
		return
	if animation_name != get_action_name():
		return
	if animation_name == ATTACK_ANIMATION and _attack_buffered and _attack_buffer_timer > 0.0:
		_action_state = ActionState.NONE
		_clear_attack_buffer()
		_start_attack()
		return
	_finish_action(animation_name)
