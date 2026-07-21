class_name Player
extends CharacterBody2D

## M1 player movement and six-state locomotion animation integration only.

signal movement_state_changed(state_name: StringName)
signal jump_performed(from_coyote_time: bool)
signal landed

enum MovementState {
	IDLE,
	RUN,
	JUMP_START,
	JUMP_LOOP,
	FALL,
	LAND,
}

const STATE_ANIMATIONS: Dictionary[MovementState, StringName] = {
	MovementState.IDLE: &"idle",
	MovementState.RUN: &"run",
	MovementState.JUMP_START: &"jump_start",
	MovementState.JUMP_LOOP: &"jump_loop",
	MovementState.FALL: &"fall",
	MovementState.LAND: &"land",
}
const MOVE_LEFT_ACTION: StringName = &"player_move_left"
const MOVE_RIGHT_ACTION: StringName = &"player_move_right"
const JUMP_ACTION: StringName = &"player_jump"

@export var movement_config: PlayerMovementConfig
@export_node_path("PlayerAnimationController") var animation_controller_path: NodePath = NodePath("AnimationController")

@onready var animation_controller: PlayerAnimationController = get_node_or_null(
	animation_controller_path
) as PlayerAnimationController

var _movement_state: MovementState = MovementState.IDLE
var _coyote_time_remaining: float = 0.0
var _jump_buffer_remaining: float = 0.0
var _last_horizontal_input: float = 0.0


func _ready() -> void:
	if movement_config == null:
		push_error("Player requires a PlayerMovementConfig resource")
		set_physics_process(false)
		return
	if animation_controller == null:
		push_error("Player requires a PlayerAnimationController")
		set_physics_process(false)
		return
	animation_controller.one_shot_finished.connect(_on_one_shot_finished)
	animation_controller.play_loop(&"idle", true)


func _physics_process(delta: float) -> void:
	var was_on_floor: bool = is_on_floor()
	var horizontal_input: float = Input.get_axis(MOVE_LEFT_ACTION, MOVE_RIGHT_ACTION)
	var jump_pressed: bool = Input.is_action_just_pressed(JUMP_ACTION)
	_last_horizontal_input = horizontal_input
	_update_jump_assist_timers(delta, was_on_floor, jump_pressed)
	_apply_horizontal_velocity(horizontal_input, delta, was_on_floor)
	_apply_gravity(delta, was_on_floor)
	var jumped_before_move: bool = _try_consume_jump()
	move_and_slide()
	var landed_this_frame: bool = not was_on_floor and is_on_floor()
	if landed_this_frame and not jumped_before_move:
		if not _try_consume_jump():
			_enter_state(MovementState.LAND)
			landed.emit()
	_update_movement_animation(horizontal_input)


func get_movement_state_name() -> StringName:
	return STATE_ANIMATIONS[_movement_state]


func get_coyote_time_remaining() -> float:
	return _coyote_time_remaining


func get_jump_buffer_remaining() -> float:
	return _jump_buffer_remaining


func _update_jump_assist_timers(delta: float, was_on_floor: bool, jump_pressed: bool) -> void:
	if was_on_floor:
		_coyote_time_remaining = movement_config.coyote_time
	else:
		_coyote_time_remaining = maxf(0.0, _coyote_time_remaining - delta)
	if jump_pressed:
		_jump_buffer_remaining = movement_config.jump_buffer_time
	else:
		_jump_buffer_remaining = maxf(0.0, _jump_buffer_remaining - delta)


func _apply_horizontal_velocity(horizontal_input: float, delta: float, was_on_floor: bool) -> void:
	var has_input: bool = absf(horizontal_input) > movement_config.input_deadzone
	if has_input:
		var acceleration: float = (
			movement_config.ground_acceleration if was_on_floor else movement_config.air_acceleration
		)
		velocity.x = move_toward(velocity.x, horizontal_input * movement_config.move_speed, acceleration * delta)
		animation_controller.set_facing_left(horizontal_input < 0.0)
	elif was_on_floor:
		velocity.x = move_toward(velocity.x, 0.0, movement_config.ground_deceleration * delta)


func _apply_gravity(delta: float, was_on_floor: bool) -> void:
	if not was_on_floor:
		velocity.y += movement_config.gravity * delta


func _try_consume_jump() -> bool:
	if _jump_buffer_remaining <= 0.0:
		return false
	var can_jump: bool = is_on_floor() or _coyote_time_remaining > 0.0
	if not can_jump:
		return false
	var from_coyote_time: bool = not is_on_floor()
	_jump_buffer_remaining = 0.0
	_coyote_time_remaining = 0.0
	velocity.y = movement_config.jump_velocity
	if _movement_state == MovementState.LAND:
		_reset_animation_lock_to_idle()
	_enter_state(MovementState.JUMP_START)
	jump_performed.emit(from_coyote_time)
	return true


func _update_movement_animation(horizontal_input: float) -> void:
	if is_on_floor():
		if _movement_state == MovementState.LAND:
			if absf(horizontal_input) > movement_config.input_deadzone:
				_reset_animation_lock_to_idle()
				_enter_state(MovementState.RUN)
			return
		var ground_state: MovementState = (
			MovementState.RUN
			if absf(horizontal_input) > movement_config.input_deadzone
			else MovementState.IDLE
		)
		_enter_state(ground_state)
		return
	if _movement_state == MovementState.JUMP_START:
		return
	_enter_state(MovementState.FALL if velocity.y >= 0.0 else MovementState.JUMP_LOOP)


func _enter_state(next_state: MovementState) -> void:
	if next_state == _movement_state:
		return
	var animation_name: StringName = STATE_ANIMATIONS[next_state]
	var accepted: bool = false
	if animation_name in PlayerAnimationController.LOOP_ANIMATIONS:
		accepted = animation_controller.play_loop(animation_name, true)
	else:
		accepted = animation_controller.play_one_shot(animation_name)
	if not accepted and animation_controller.animated_sprite.animation != animation_name:
		return
	_movement_state = next_state
	movement_state_changed.emit(animation_name)


func _reset_animation_lock_to_idle() -> void:
	animation_controller.reset_to_idle()
	_movement_state = MovementState.IDLE


func _on_one_shot_finished(animation_name: StringName) -> void:
	if animation_name == &"jump_start" and not is_on_floor():
		_enter_state(MovementState.FALL if velocity.y >= 0.0 else MovementState.JUMP_LOOP)
	elif animation_name == &"land" and is_on_floor():
		var next_state: MovementState = (
			MovementState.RUN
			if absf(_last_horizontal_input) > movement_config.input_deadzone
			else MovementState.IDLE
		)
		_enter_state(next_state)
