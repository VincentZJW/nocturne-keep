class_name Player
extends CharacterBody2D

## M1 locomotion plus the explicitly limited M1.5 action prototype.

signal movement_state_changed(state_name: StringName)
signal jump_performed(from_coyote_time: bool)
signal double_jump_performed(air_jumps_remaining: int)
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
const DASH_ACTION: StringName = &"dash"
const ATTACK_ACTION: StringName = &"attack"
const DOUBLE_JUMP_ANIMATION: StringName = &"double_jump"

@export var movement_config: PlayerMovementConfig
@export var has_double_jump: bool = false
@export var debug_enable_double_jump: bool = true
@export_node_path("PlayerAnimationController") var animation_controller_path: NodePath = NodePath("AnimationController")
@export_node_path("PlayerActionController") var action_controller_path: NodePath = NodePath("ActionController")
@export_node_path("PlayerStaminaComponent") var stamina_component_path: NodePath = NodePath("StaminaComponent")

@onready var animation_controller: PlayerAnimationController = get_node_or_null(
	animation_controller_path
) as PlayerAnimationController
@onready var action_controller: PlayerActionController = get_node_or_null(
	action_controller_path
) as PlayerActionController
@onready var stamina_component: PlayerStaminaComponent = get_node_or_null(
	stamina_component_path
) as PlayerStaminaComponent

var air_jumps_remaining: int = 0
var _movement_state: MovementState = MovementState.IDLE
var _coyote_time_remaining: float = 0.0
var _jump_buffer_remaining: float = 0.0
var _last_horizontal_input: float = 0.0
var _landed_during_action: bool = false


func _ready() -> void:
	if movement_config == null:
		push_error("Player requires a PlayerMovementConfig resource")
		set_physics_process(false)
		return
	if animation_controller == null:
		push_error("Player requires a PlayerAnimationController")
		set_physics_process(false)
		return
	if action_controller == null:
		push_error("Player requires a PlayerActionController")
		set_physics_process(false)
		return
	if stamina_component == null:
		push_error("Player requires a PlayerStaminaComponent")
		set_physics_process(false)
		return
	animation_controller.one_shot_finished.connect(_on_one_shot_finished)
	action_controller.action_finished.connect(_on_action_finished)
	_restore_air_jumps()
	animation_controller.play_loop(&"idle", true)


func _physics_process(delta: float) -> void:
	var was_on_floor: bool = is_on_floor()
	var horizontal_input: float = Input.get_axis(MOVE_LEFT_ACTION, MOVE_RIGHT_ACTION)
	var jump_pressed: bool = Input.is_action_just_pressed(JUMP_ACTION)
	var dash_pressed: bool = Input.is_action_just_pressed(DASH_ACTION)
	var attack_pressed: bool = Input.is_action_just_pressed(ATTACK_ACTION)
	_last_horizontal_input = horizontal_input
	_update_jump_assist_timers(delta, was_on_floor, jump_pressed)
	action_controller.advance(delta)
	_prepare_action_facing(horizontal_input)
	action_controller.try_start_actions(
		attack_pressed,
		dash_pressed,
		was_on_floor,
		horizontal_input,
		animation_controller.animated_sprite.flip_h
	)
	stamina_component.advance(
		delta,
		was_on_floor and not action_controller.is_action_active()
	)
	if (
		action_controller.is_air_dash_gravity_suspended()
		or action_controller.is_airborne_dash_attack_active()
	):
		velocity.y = 0.0
	if action_controller.is_dash_active() or action_controller.is_dash_attack_active():
		velocity.x = action_controller.get_action_horizontal_velocity()
	else:
		_apply_horizontal_velocity(horizontal_input, delta, was_on_floor)
	_apply_gravity(delta, was_on_floor)
	var jumped_before_move: bool = false
	if not action_controller.is_action_active():
		jumped_before_move = _try_consume_jump()
	move_and_slide()
	var landed_this_frame: bool = not was_on_floor and is_on_floor()
	if landed_this_frame and not jumped_before_move:
		_restore_air_jumps()
		_landed_during_action = action_controller.is_action_active()
		if action_controller.is_action_active() or not _try_consume_jump():
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


func _prepare_action_facing(horizontal_input: float) -> void:
	if action_controller.is_action_active():
		return
	if absf(horizontal_input) > movement_config.input_deadzone:
		animation_controller.set_facing_left(horizontal_input < 0.0)


func _apply_gravity(delta: float, was_on_floor: bool) -> void:
	var gravity_suspended: bool = (
		action_controller.is_air_dash_gravity_suspended()
		or action_controller.is_airborne_dash_attack_active()
	)
	if not was_on_floor and not gravity_suspended:
		velocity.y += movement_config.gravity * delta


func _try_consume_jump() -> bool:
	if _jump_buffer_remaining <= 0.0:
		return false
	var can_ground_jump: bool = is_on_floor() or _coyote_time_remaining > 0.0
	var can_air_jump: bool = (
		not can_ground_jump
		and _is_double_jump_enabled()
		and air_jumps_remaining > 0
	)
	if not can_ground_jump and not can_air_jump:
		return false
	var from_coyote_time: bool = can_ground_jump and not is_on_floor()
	_jump_buffer_remaining = 0.0
	_coyote_time_remaining = 0.0
	velocity.y = movement_config.jump_velocity
	if can_air_jump:
		air_jumps_remaining -= 1
		_reset_animation_lock_to_idle()
	elif _movement_state == MovementState.LAND:
		_reset_animation_lock_to_idle()
	_enter_state(MovementState.JUMP_START)
	if can_air_jump:
		double_jump_performed.emit(air_jumps_remaining)
	else:
		jump_performed.emit(from_coyote_time)
	return true


func _update_movement_animation(horizontal_input: float) -> void:
	if action_controller.is_action_active():
		return
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
	var animation_name: StringName = STATE_ANIMATIONS[next_state]
	if (
		next_state == _movement_state
		and animation_controller.animated_sprite.animation == animation_name
		and animation_controller.animated_sprite.is_playing()
	):
		return
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


func _is_double_jump_enabled() -> bool:
	return has_double_jump or debug_enable_double_jump


func _restore_air_jumps() -> void:
	air_jumps_remaining = 1 if _is_double_jump_enabled() else 0


func _resume_locomotion_after_action() -> void:
	if is_on_floor():
		var ground_state: MovementState = (
			MovementState.RUN
			if absf(_last_horizontal_input) > movement_config.input_deadzone
			else MovementState.IDLE
		)
		_enter_state(ground_state)
	else:
		_enter_state(MovementState.FALL if velocity.y >= 0.0 else MovementState.JUMP_LOOP)


func _on_one_shot_finished(animation_name: StringName) -> void:
	if animation_name == &"jump_start" and not is_on_floor():
		_enter_state(MovementState.FALL if velocity.y >= 0.0 else MovementState.JUMP_LOOP)
	elif animation_name == &"land" and is_on_floor():
		_resume_locomotion_after_action()


func _on_action_finished(_animation_name: StringName) -> void:
	if _landed_during_action and is_on_floor():
		_landed_during_action = false
		_enter_state(MovementState.LAND)
		return
	_landed_during_action = false
	_resume_locomotion_after_action()
