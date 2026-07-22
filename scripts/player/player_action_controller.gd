class_name PlayerActionController
extends Node

## M1.5 action prototype: buffered Attack, Ground/Air Dash, and one Dash Attack transition.

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

const GROUND_DASH_ANIMATION: StringName = &"ground_dash"
const AIR_DASH_ANIMATION: StringName = &"air_dash"
const ATTACK_ANIMATION: StringName = &"attack"
const DASH_ATTACK_ANIMATION: StringName = &"dash_attack"

@export var action_config: PlayerActionPrototypeConfig
@export_node_path("PlayerAnimationController") var animation_controller_path: NodePath = NodePath("../AnimationController")

@onready var animation_controller: PlayerAnimationController = get_node_or_null(
	animation_controller_path
) as PlayerAnimationController

var _action_state: ActionState = ActionState.NONE
var _dash_direction: float = 1.0
var _dash_motion_remaining: float = 0.0
var _dash_cooldown_remaining: float = 0.0
var _dash_attack_window_remaining: float = 0.0
var _dash_attack_elapsed: float = 0.0
var _dash_attack_used: bool = false
var _dash_attack_started_airborne: bool = false
var _attack_buffer_remaining: float = 0.0
var _attack_buffer_pending: bool = false


func _ready() -> void:
	if action_config == null:
		push_error("PlayerActionController requires a PlayerActionPrototypeConfig resource")
		return
	if animation_controller == null:
		push_error("PlayerActionController requires a PlayerAnimationController")
		return
	animation_controller.one_shot_finished.connect(_on_one_shot_finished)


func advance(delta: float) -> void:
	_dash_cooldown_remaining = maxf(0.0, _dash_cooldown_remaining - delta)
	if is_dash_active():
		_dash_motion_remaining = maxf(0.0, _dash_motion_remaining - delta)
		_dash_attack_window_remaining = maxf(0.0, _dash_attack_window_remaining - delta)
	elif is_dash_attack_active():
		_dash_attack_elapsed += delta
	if _attack_buffer_pending:
		_attack_buffer_remaining = maxf(0.0, _attack_buffer_remaining - delta)


func try_start_actions(
	attack_pressed: bool,
	dash_pressed: bool,
	is_grounded: bool,
	air_dash_available: bool,
	facing_left: bool
) -> bool:
	if animation_controller == null:
		return false
	if is_dash_attack_active() or _action_state == ActionState.ATTACK:
		return false
	if is_dash_active():
		if attack_pressed and is_dash_attack_input_window_open():
			return _transition_dash_to_dash_attack()
		return false
	if _action_state != ActionState.NONE:
		return false
	if attack_pressed and not _attack_buffer_pending:
		_attack_buffer_pending = true
		_attack_buffer_remaining = action_config.dash_attack_buffer_time
	if _attack_buffer_pending and _attack_buffer_remaining <= 0.0:
		_clear_attack_buffer()
		return _start_action(ActionState.ATTACK, ATTACK_ANIMATION)
	if dash_pressed:
		if not is_grounded and not air_dash_available:
			return false
		if _dash_cooldown_remaining > 0.0:
			return false
		_dash_direction = -1.0 if facing_left else 1.0
		if _attack_buffer_pending:
			return _start_direct_dash_attack(not is_grounded)
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


func is_attack_buffer_pending() -> bool:
	return _attack_buffer_pending


func get_action_name() -> StringName:
	match _action_state:
		ActionState.GROUND_DASH:
			return GROUND_DASH_ANIMATION
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
		if _dash_motion_remaining <= 0.0:
			return 0.0
		return _dash_direction * action_config.dash_speed
	if not is_dash_attack_active():
		return 0.0
	if _dash_attack_elapsed <= action_config.dash_attack_move_duration:
		return _dash_direction * action_config.dash_attack_speed
	var recovery_elapsed: float = _dash_attack_elapsed - action_config.dash_attack_move_duration
	if recovery_elapsed >= action_config.dash_attack_recovery_duration:
		return 0.0
	var recovery_ratio: float = 1.0 - (
		recovery_elapsed / action_config.dash_attack_recovery_duration
	)
	return _dash_direction * action_config.dash_attack_speed * maxf(0.0, recovery_ratio)


func get_dash_horizontal_velocity() -> float:
	return get_action_horizontal_velocity() if is_dash_active() else 0.0


func get_dash_motion_remaining() -> float:
	return _dash_motion_remaining


func get_dash_cooldown_remaining() -> float:
	return _dash_cooldown_remaining


func get_dash_attack_window_remaining() -> float:
	return _dash_attack_window_remaining


func get_attack_buffer_remaining() -> float:
	return _attack_buffer_remaining


func get_dash_direction() -> float:
	return _dash_direction


func _start_dash(is_grounded: bool) -> bool:
	var dash_state: ActionState = ActionState.GROUND_DASH if is_grounded else ActionState.AIR_DASH
	var dash_animation: StringName = GROUND_DASH_ANIMATION if is_grounded else AIR_DASH_ANIMATION
	if not _start_action(dash_state, dash_animation):
		return false
	_dash_motion_remaining = action_config.dash_duration
	_dash_cooldown_remaining = action_config.dash_cooldown
	_dash_attack_window_remaining = action_config.dash_attack_input_window
	_dash_attack_used = false
	_dash_attack_started_airborne = not is_grounded
	return true


func _start_direct_dash_attack(started_airborne: bool) -> bool:
	_clear_attack_buffer()
	if not animation_controller.play_one_shot(DASH_ATTACK_ANIMATION):
		return false
	_dash_cooldown_remaining = action_config.dash_cooldown
	_dash_attack_used = true
	_dash_attack_started_airborne = started_airborne
	_dash_attack_elapsed = 0.0
	_dash_attack_window_remaining = 0.0
	_action_state = ActionState.DASH_ATTACK
	action_started.emit(DASH_ATTACK_ANIMATION)
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
	_clear_attack_buffer()
	action_transitioned.emit(previous_action, DASH_ATTACK_ANIMATION)
	action_started.emit(DASH_ATTACK_ANIMATION)
	return true


func _start_action(next_state: ActionState, animation_name: StringName) -> bool:
	if not animation_controller.play_one_shot(animation_name):
		return false
	_action_state = next_state
	action_started.emit(animation_name)
	return true


func _clear_attack_buffer() -> void:
	_attack_buffer_pending = false
	_attack_buffer_remaining = 0.0


func _on_one_shot_finished(animation_name: StringName) -> void:
	if animation_name != get_action_name():
		return
	_action_state = ActionState.NONE
	_dash_motion_remaining = 0.0
	_dash_attack_window_remaining = 0.0
	_dash_attack_elapsed = 0.0
	action_finished.emit(animation_name)
