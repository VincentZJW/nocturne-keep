class_name PlayerActionController
extends Node

## M1.5 action prototype: mutually exclusive Attack, ground Dash, and air Dash.

signal action_started(action_name: StringName)
signal action_finished(action_name: StringName)

enum ActionState {
	NONE,
	GROUND_DASH,
	AIR_DASH,
	ATTACK,
}

const GROUND_DASH_ANIMATION: StringName = &"ground_dash"
const AIR_DASH_ANIMATION: StringName = &"air_dash"
const ATTACK_ANIMATION: StringName = &"attack"

@export var action_config: PlayerActionPrototypeConfig
@export_node_path("PlayerAnimationController") var animation_controller_path: NodePath = NodePath("../AnimationController")

@onready var animation_controller: PlayerAnimationController = get_node_or_null(
	animation_controller_path
) as PlayerAnimationController

var _action_state: ActionState = ActionState.NONE
var _dash_direction: float = 1.0
var _dash_motion_remaining: float = 0.0
var _dash_cooldown_remaining: float = 0.0


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


func try_start_actions(
	attack_pressed: bool,
	dash_pressed: bool,
	is_grounded: bool,
	air_dash_available: bool,
	facing_left: bool
) -> bool:
	if _action_state != ActionState.NONE or animation_controller == null:
		return false
	# Attack wins when both actions are requested on the same physics frame.
	if attack_pressed:
		return _start_action(ActionState.ATTACK, ATTACK_ANIMATION)
	if dash_pressed and (is_grounded or air_dash_available) and _dash_cooldown_remaining <= 0.0:
		_dash_direction = -1.0 if facing_left else 1.0
		var dash_state: ActionState = ActionState.GROUND_DASH if is_grounded else ActionState.AIR_DASH
		var dash_animation: StringName = GROUND_DASH_ANIMATION if is_grounded else AIR_DASH_ANIMATION
		if _start_action(dash_state, dash_animation):
			_dash_motion_remaining = action_config.dash_duration
			_dash_cooldown_remaining = action_config.dash_cooldown
			return true
	return false


func is_action_active() -> bool:
	return _action_state != ActionState.NONE


func is_dash_active() -> bool:
	return _action_state == ActionState.GROUND_DASH or _action_state == ActionState.AIR_DASH


func is_ground_dash_active() -> bool:
	return _action_state == ActionState.GROUND_DASH


func is_air_dash_active() -> bool:
	return _action_state == ActionState.AIR_DASH


func get_action_name() -> StringName:
	match _action_state:
		ActionState.GROUND_DASH:
			return GROUND_DASH_ANIMATION
		ActionState.AIR_DASH:
			return AIR_DASH_ANIMATION
		ActionState.ATTACK:
			return ATTACK_ANIMATION
	return &""


func get_dash_horizontal_velocity() -> float:
	if not is_dash_active() or _dash_motion_remaining <= 0.0:
		return 0.0
	return _dash_direction * action_config.dash_speed


func get_dash_motion_remaining() -> float:
	return _dash_motion_remaining


func get_dash_cooldown_remaining() -> float:
	return _dash_cooldown_remaining


func get_dash_direction() -> float:
	return _dash_direction


func _start_action(next_state: ActionState, animation_name: StringName) -> bool:
	if not animation_controller.play_one_shot(animation_name):
		return false
	_action_state = next_state
	action_started.emit(animation_name)
	return true


func _on_one_shot_finished(animation_name: StringName) -> void:
	if animation_name != get_action_name():
		return
	_action_state = ActionState.NONE
	_dash_motion_remaining = 0.0
	action_finished.emit(animation_name)
