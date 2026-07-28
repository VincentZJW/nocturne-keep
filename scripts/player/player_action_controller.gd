class_name PlayerActionController
extends Node

## Edge-triggered Ground/Air Dash chains plus Attack arbitration.

signal action_started(action_name: StringName)
signal action_finished(action_name: StringName)
signal action_transitioned(previous_action: StringName, next_action: StringName)

enum ActionState {
	NONE,
	GROUND_DASH,
	AIR_DASH,
	ATTACK,
	ATTACK_RECOVERY,
	DASH_ATTACK,
}

const GROUND_DASH_ACTION: StringName = &"ground_dash"
const AIR_DASH_ACTION: StringName = &"air_dash"
const DASH_START_ANIMATION: StringName = &"dash_start"
const DASH_LOOP_ANIMATION: StringName = &"dash_loop"
const DASH_END_ANIMATION: StringName = &"dash_end"
const AIR_DASH_START_ANIMATION: StringName = &"air_dash_start"
const AIR_DASH_LOOP_ANIMATION: StringName = &"air_dash_loop"
const AIR_DASH_END_ANIMATION: StringName = &"air_dash_end"
const ATTACK_ANIMATION: StringName = &"attack"
const DASH_ATTACK_ANIMATION: StringName = &"dash_attack"

@export var action_config: PlayerActionPrototypeConfig
@export_node_path("PlayerAnimationController") var animation_controller_path: NodePath = NodePath("../AnimationController")
@export_node_path("PlayerStaminaComponent") var stamina_component_path: NodePath = NodePath("../StaminaComponent")
@export_node_path("Node2D") var combat_root_path: NodePath = NodePath("../CombatRoot")
@export_node_path("Node2D") var attack_owner_path: NodePath = NodePath("..")
@export_node_path("HitboxComponent") var attack_hitbox_path: NodePath = NodePath(
	"../CombatRoot/AttackHitbox"
)
@export_node_path("HitboxComponent") var dash_attack_hitbox_path: NodePath = NodePath(
	"../CombatRoot/DashAttackHitbox"
)

@onready var animation_controller: PlayerAnimationController = get_node_or_null(
	animation_controller_path
) as PlayerAnimationController
@onready var stamina_component: PlayerStaminaComponent = get_node_or_null(
	stamina_component_path
) as PlayerStaminaComponent
@onready var combat_root: Node2D = get_node_or_null(combat_root_path) as Node2D
@onready var attack_owner: Node2D = get_node_or_null(attack_owner_path) as Node2D
@onready var attack_hitbox: HitboxComponent = get_node_or_null(
	attack_hitbox_path
) as HitboxComponent
@onready var dash_attack_hitbox: HitboxComponent = get_node_or_null(
	dash_attack_hitbox_path
) as HitboxComponent

var _action_state: ActionState = ActionState.NONE
var _dash_direction: float = 1.0
var _buffered_dash_direction: float = 1.0
var _dash_motion_remaining: float = 0.0
var _dash_attack_window_remaining: float = 0.0
var _dash_attack_elapsed: float = 0.0
var _dash_attack_used: bool = false
var _dash_attack_started_airborne: bool = false
var _dash_buffered: bool = false
var _dash_buffer_timer: float = 0.0
var _dash_segment_elapsed: float = 0.0
var _dash_ending: bool = false
var _current_dash_number: int = 0
var _latest_is_grounded: bool = true
var _attack_buffer_timer: float = 0.0
var _attack_buffered: bool = false
var _attack_elapsed: float = 0.0
var _attack_recovery_timer: float = 0.0
var _attack_chain_queued: bool = false
var _last_attack_input_to_hit_time: float = -1.0
var _attack_hit_time_recorded: bool = false
var _next_attack_id: int = 1
var _current_attack_id: int = 0
var _normal_combo_step: int = 0


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
	if (
		combat_root == null or attack_owner == null
		or attack_hitbox == null or dash_attack_hitbox == null
	):
		push_error("PlayerActionController requires attack owner, CombatRoot, and both Hitboxes")
		return
	animation_controller.one_shot_finished.connect(_on_one_shot_finished)
	animation_controller.animated_sprite.frame_changed.connect(_on_animation_frame_changed)
	animation_controller.facing_changed.connect(_on_facing_changed)
	_on_facing_changed(animation_controller.animated_sprite.flip_h)
	_deactivate_attack_hitboxes()


func advance(delta: float) -> void:
	if is_dash_active():
		_dash_motion_remaining = maxf(0.0, _dash_motion_remaining - delta)
		_dash_attack_window_remaining = maxf(0.0, _dash_attack_window_remaining - delta)
		_dash_segment_elapsed += delta
	elif is_dash_attack_active():
		_dash_attack_elapsed += delta
	elif _action_state == ActionState.ATTACK:
		_attack_elapsed += delta
	elif _action_state == ActionState.ATTACK_RECOVERY:
		_attack_recovery_timer = maxf(0.0, _attack_recovery_timer - delta)
		if _attack_recovery_timer <= 0.0:
			_finish_attack_recovery()
	if _dash_buffered and not is_dash_attack_active():
		_dash_buffer_timer = maxf(0.0, _dash_buffer_timer - delta)
		if _dash_buffer_timer <= 0.0:
			_clear_dash_buffer()
	if _attack_buffered:
		_attack_buffer_timer = maxf(0.0, _attack_buffer_timer - delta)


func try_start_actions(
	attack_pressed: bool,
	dash_pressed: bool,
	is_grounded: bool,
	horizontal_input: float,
	facing_left: bool
) -> bool:
	_latest_is_grounded = is_grounded
	if animation_controller == null or stamina_component == null:
		return false
	if is_dash_attack_active():
		if dash_pressed and not _dash_buffered:
			_buffer_dash(horizontal_input, facing_left)
		return false
	if _action_state == ActionState.ATTACK:
		if (
			attack_pressed and can_chain_attack() and not _attack_buffered
			and _normal_combo_step < action_config.maximum_normal_combo
		):
			_attack_buffered = true
			_attack_buffer_timer = action_config.attack_buffer_time
		if _attack_buffered and _attack_buffer_timer <= 0.0:
			_clear_attack_buffer()
		return false
	if _action_state == ActionState.ATTACK_RECOVERY:
		return false
	if is_dash_active():
		if attack_pressed and is_dash_attack_input_window_open():
			return _transition_dash_to_dash_attack()
		if dash_pressed and not _dash_buffered:
			_buffer_dash(horizontal_input, facing_left)
		if _dash_ending and dash_pressed:
			return _continue_dash()
		if not _dash_ending and _dash_motion_remaining <= 0.0:
			return _resolve_dash_segment()
		return false
	if _action_state != ActionState.NONE:
		return false
	var requested_direction: float = _select_dash_direction(horizontal_input, facing_left)
	if attack_pressed and dash_pressed:
		return _start_direct_dash_attack(not is_grounded, requested_direction)
	if attack_pressed:
		return _start_attack()
	if dash_pressed:
		return _start_dash(is_grounded, requested_direction)
	return false


func is_action_active() -> bool:
	return _action_state != ActionState.NONE


func cancel_all_actions() -> void:
	_action_state = ActionState.NONE
	_clear_attack_buffer()
	_clear_dash_buffer()
	_dash_motion_remaining = 0.0
	_dash_attack_window_remaining = 0.0
	_dash_attack_elapsed = 0.0
	_dash_attack_used = false
	_dash_attack_started_airborne = false
	_dash_segment_elapsed = 0.0
	_dash_ending = false
	_current_dash_number = 0
	_attack_elapsed = 0.0
	_attack_recovery_timer = 0.0
	_attack_chain_queued = false
	_normal_combo_step = 0
	_reset_attack_response_measurement()
	_deactivate_attack_hitboxes()


func is_stamina_regeneration_blocked() -> bool:
	return is_dash_active() or is_dash_attack_active()


func is_dash_active() -> bool:
	return _action_state == ActionState.GROUND_DASH or _action_state == ActionState.AIR_DASH


func is_ground_dash_active() -> bool:
	return _action_state == ActionState.GROUND_DASH


func is_air_dash_active() -> bool:
	return _action_state == ActionState.AIR_DASH


func is_air_dash_gravity_suspended() -> bool:
	return _action_state == ActionState.AIR_DASH and not _dash_ending


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
			return AIR_DASH_ACTION
		ActionState.ATTACK:
			return ATTACK_ANIMATION
		ActionState.ATTACK_RECOVERY:
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
		ActionState.ATTACK_RECOVERY:
			return &"AttackRecovery"
		ActionState.DASH_ATTACK:
			return &"DashAttack"
	return &"None"


func get_dash_type_name() -> StringName:
	if is_ground_dash_active():
		return &"GroundDash"
	if is_air_dash_active():
		return &"AirDash"
	if is_dash_attack_active():
		return &"AirDashAttack" if _dash_attack_started_airborne else &"GroundDashAttack"
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
		and _normal_combo_step < action_config.maximum_normal_combo
		and _attack_elapsed >= action_config.attack_chain_window_start
		and _attack_elapsed < action_config.attack_chain_window_end
	)


func get_attack_recovery_remaining() -> float:
	return _attack_recovery_timer


func get_normal_combo_step() -> int:
	return _normal_combo_step


func get_maximum_normal_combo() -> int:
	return action_config.maximum_normal_combo if action_config != null else 0


func get_current_attack_id() -> int:
	return _current_attack_id


func is_attack_chain_queued() -> bool:
	return _attack_chain_queued


func get_attack_input_to_hit_time() -> float:
	return _last_attack_input_to_hit_time


func get_dash_direction() -> float:
	return _dash_direction


func _select_dash_direction(horizontal_input: float, facing_left: bool) -> float:
	if absf(horizontal_input) > 0.01:
		return signf(horizontal_input)
	return -1.0 if facing_left else 1.0


func _buffer_dash(horizontal_input: float, facing_left: bool) -> void:
	_dash_buffered = true
	_dash_buffer_timer = action_config.dash_input_buffer_time
	_buffered_dash_direction = _select_dash_direction(horizontal_input, facing_left)


func _start_dash(is_grounded: bool, requested_direction: float) -> bool:
	if not stamina_component.try_consume_dash():
		return false
	var dash_state: ActionState = ActionState.GROUND_DASH if is_grounded else ActionState.AIR_DASH
	var dash_animation: StringName = DASH_START_ANIMATION if is_grounded else AIR_DASH_START_ANIMATION
	if not _start_action(dash_state, dash_animation):
		stamina_component.refund_dash_charge()
		return false
	_dash_direction = requested_direction
	animation_controller.set_locked_facing_left(_dash_direction < 0.0)
	_dash_motion_remaining = action_config.dash_duration
	_dash_attack_window_remaining = action_config.dash_attack_input_window
	_dash_attack_used = false
	_dash_attack_started_airborne = not is_grounded
	_dash_segment_elapsed = 0.0
	_dash_ending = false
	_current_dash_number = 1
	_clear_dash_buffer()
	return true


func _continue_dash() -> bool:
	if _dash_segment_elapsed < action_config.dash_min_interval:
		return false
	if not stamina_component.try_consume_dash():
		_clear_dash_buffer()
		if not _dash_ending:
			_start_dash_end()
		return false
	var continuing_air_dash: bool = is_air_dash_active()
	if continuing_air_dash:
		_dash_direction = _buffered_dash_direction
		animation_controller.set_locked_facing_left(_dash_direction < 0.0)
	_clear_dash_buffer()
	_dash_ending = false
	_dash_motion_remaining = action_config.dash_duration
	_dash_attack_window_remaining = action_config.dash_attack_input_window
	_dash_attack_used = false
	_dash_segment_elapsed = 0.0
	_current_dash_number += 1
	var loop_animation: StringName = AIR_DASH_LOOP_ANIMATION if continuing_air_dash else DASH_LOOP_ANIMATION
	if animation_controller.animated_sprite.animation != loop_animation:
		animation_controller.transition_locked_animation(loop_animation)
	action_started.emit(get_action_name())
	return true


func _resolve_dash_segment() -> bool:
	if _dash_buffered and _dash_buffer_timer > 0.0:
		return _continue_dash()
	_start_dash_end()
	return false


func _start_dash_end() -> void:
	_clear_dash_buffer()
	_dash_ending = true
	_dash_motion_remaining = 0.0
	_dash_attack_window_remaining = 0.0
	var end_animation: StringName = AIR_DASH_END_ANIMATION if is_air_dash_active() else DASH_END_ANIMATION
	animation_controller.transition_locked_animation(end_animation)


func _start_direct_dash_attack(started_airborne: bool, requested_direction: float) -> bool:
	if not stamina_component.try_consume_dash():
		return false
	_clear_dash_buffer()
	_clear_attack_buffer()
	if not animation_controller.play_one_shot(DASH_ATTACK_ANIMATION):
		stamina_component.refund_dash_charge()
		return false
	_dash_direction = requested_direction
	animation_controller.set_locked_facing_left(_dash_direction < 0.0)
	_dash_attack_used = true
	_dash_attack_started_airborne = started_airborne
	_dash_attack_elapsed = 0.0
	_dash_attack_window_remaining = 0.0
	_current_dash_number = 1
	_action_state = ActionState.DASH_ATTACK
	_prepare_new_attack_id()
	_deactivate_attack_hitboxes()
	action_started.emit(DASH_ATTACK_ANIMATION)
	return true


func _start_attack() -> bool:
	_clear_attack_buffer()
	animation_controller.select_attack_variant(1)
	if not _start_action(ActionState.ATTACK, ATTACK_ANIMATION):
		return false
	_attack_elapsed = 0.0
	_attack_recovery_timer = 0.0
	_attack_chain_queued = false
	_normal_combo_step = 1
	_prepare_new_attack_id()
	_deactivate_attack_hitboxes()
	_reset_attack_response_measurement()
	return true


func _begin_attack_recovery() -> void:
	var reached_combo_limit: bool = _normal_combo_step >= action_config.maximum_normal_combo
	_attack_chain_queued = _attack_buffered and not reached_combo_limit
	_clear_attack_buffer()
	_deactivate_attack_hitboxes()
	_action_state = ActionState.ATTACK_RECOVERY
	_attack_recovery_timer = (
		action_config.combo_end_recovery
		if reached_combo_limit
		else maxf(
			action_config.attack_chain_recovery_duration,
			action_config.minimum_attack_interval - _attack_elapsed
		)
	)


func _finish_attack_recovery() -> void:
	var should_chain: bool = _attack_chain_queued
	_attack_chain_queued = false
	_attack_recovery_timer = 0.0
	if should_chain:
		var next_combo_step: int = _normal_combo_step + 1
		animation_controller.select_attack_variant(next_combo_step)
		if not animation_controller.replay_one_shot(ATTACK_ANIMATION):
			_finish_action(ATTACK_ANIMATION)
			return
		_action_state = ActionState.ATTACK
		_attack_elapsed = 0.0
		_normal_combo_step = next_combo_step
		_prepare_new_attack_id()
		_deactivate_attack_hitboxes()
		_reset_attack_response_measurement()
		action_started.emit(ATTACK_ANIMATION)
		return
	_finish_action(ATTACK_ANIMATION)


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
	_prepare_new_attack_id()
	_deactivate_attack_hitboxes()
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


func _continue_after_dash_attack() -> bool:
	if not _dash_buffered:
		return false
	var previous_dash_number: int = _current_dash_number
	var requested_direction: float = _buffered_dash_direction
	var next_grounded: bool = _latest_is_grounded
	var player_body: CharacterBody2D = get_parent() as CharacterBody2D
	if player_body != null:
		next_grounded = player_body.is_on_floor()
	_clear_dash_buffer()
	_action_state = ActionState.NONE
	if not _start_dash(next_grounded, requested_direction):
		return false
	_current_dash_number = previous_dash_number + 1
	action_transitioned.emit(DASH_ATTACK_ANIMATION, get_action_name())
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
	_dash_ending = false
	_current_dash_number = 0
	_attack_elapsed = 0.0
	_attack_recovery_timer = 0.0
	_attack_chain_queued = false
	_normal_combo_step = 0
	_deactivate_attack_hitboxes()
	action_finished.emit(finished_action)


func _on_animation_frame_changed() -> void:
	_sync_attack_hitboxes()
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


func _prepare_new_attack_id() -> void:
	_current_attack_id = _next_attack_id
	_next_attack_id += 1
	if _next_attack_id <= 0:
		_next_attack_id = 1


func _sync_attack_hitboxes() -> void:
	if animation_controller == null:
		_deactivate_attack_hitboxes()
		return
	if _action_state == ActionState.ATTACK and animation_controller.is_attack_hit_window():
		if not attack_hitbox.is_active:
			var equipment: PlayerEquipmentManager = get_node_or_null(
				"/root/EquipmentManager"
			) as PlayerEquipmentManager
			if equipment == null:
				return
			attack_hitbox.begin_attack(
				_current_attack_id,
				equipment.get_normal_attack_damage(),
				combat_root.scale.x,
				attack_owner
			)
		dash_attack_hitbox.end_attack()
		return
	if _action_state == ActionState.DASH_ATTACK and animation_controller.is_dash_attack_hit_window():
		if not dash_attack_hitbox.is_active:
			var equipment: PlayerEquipmentManager = get_node_or_null(
				"/root/EquipmentManager"
			) as PlayerEquipmentManager
			if equipment == null:
				return
			dash_attack_hitbox.begin_attack(
				_current_attack_id,
				equipment.get_dash_attack_damage(),
				_dash_direction,
				attack_owner
			)
		attack_hitbox.end_attack()
		return
	_deactivate_attack_hitboxes()


func _deactivate_attack_hitboxes() -> void:
	if attack_hitbox != null:
		attack_hitbox.end_attack()
	if dash_attack_hitbox != null:
		dash_attack_hitbox.end_attack()


func _on_facing_changed(facing_left: bool) -> void:
	if combat_root != null:
		combat_root.scale.x = -1.0 if facing_left else 1.0


func _on_one_shot_finished(animation_name: StringName) -> void:
	if is_dash_active():
		var start_animation: StringName = AIR_DASH_START_ANIMATION if is_air_dash_active() else DASH_START_ANIMATION
		var loop_animation: StringName = AIR_DASH_LOOP_ANIMATION if is_air_dash_active() else DASH_LOOP_ANIMATION
		var end_animation: StringName = AIR_DASH_END_ANIMATION if is_air_dash_active() else DASH_END_ANIMATION
		if animation_name == start_animation and not _dash_ending:
			animation_controller.transition_locked_animation(loop_animation)
			return
		if animation_name == end_animation and _dash_ending:
			_finish_action(get_action_name())
		return
	if animation_name != get_action_name():
		return
	if animation_name == ATTACK_ANIMATION:
		_begin_attack_recovery()
		return
	if animation_name == DASH_ATTACK_ANIMATION and _continue_after_dash_attack():
		return
	_finish_action(animation_name)
