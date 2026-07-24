class_name DecayedSpearman
extends GroundEnemyBase

## Tall polearm enemy with long narrow thrust and a close-range dead zone.

const ATTACK: StringName = &"Attack"
const ATTACK_HIT_FRAMES: Array[int] = [3, 4]

@export_node_path("HitboxComponent") var attack_hitbox_path: NodePath = NodePath(
	"FacingRoot/AttackHitbox"
)

@onready var attack_hitbox: HitboxComponent = get_node_or_null(
	attack_hitbox_path
) as HitboxComponent

var next_attack_id: int = 1
var current_attack_id: int = 0
var attack_direction_locked: bool = false


func _on_common_ready() -> void:
	if attack_hitbox == null:
		push_error("DecayedSpearman requires AttackHitbox")
		set_physics_process(false)
		return
	attack_hitbox.damage = config.attack_damage
	attack_hitbox.end_attack()


func _process_enemy_state(delta: float) -> void:
	match current_state:
		IDLE:
			_process_idle(delta)
		PATROL:
			_process_patrol(delta)
		CHASE:
			_process_chase(delta)
		ATTACK:
			velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
			_update_attack_direction_lock()


func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	if has_valid_target():
		_enter_chase()
		return
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		_enter_patrol()


func _process_patrol(delta: float) -> void:
	if has_valid_target():
		_enter_chase()
		return
	if reached_patrol_boundary() or not can_advance(facing_direction):
		set_facing_direction(-facing_direction)
		transition_state(IDLE)
		state_timer = config.patrol_turn_pause
		play_animation(&"idle")
		return
	velocity.x = move_toward(velocity.x, facing_direction * config.patrol_speed, config.ground_acceleration * delta)


func _process_chase(delta: float) -> void:
	if not _validate_target_distance():
		return
	var spear_config: DecayedSpearmanConfig = config as DecayedSpearmanConfig
	var offset: Vector2 = target.global_position - global_position
	var distance_x: float = absf(offset.x)
	var direction: float = signf(offset.x)
	set_facing_direction(direction)
	if distance_x < spear_config.minimum_attack_distance:
		var retreat_direction: float = -direction
		velocity.x = (
			retreat_direction * spear_config.close_retreat_speed
			if can_advance(retreat_direction)
			else 0.0
		)
		return
	if distance_x <= config.attack_range:
		_enter_attack()
		return
	if not can_advance(direction):
		velocity.x = 0.0
		return
	velocity.x = move_toward(velocity.x, direction * config.chase_speed, config.ground_acceleration * delta)


func _on_target_acquired() -> void:
	_enter_chase()


func _enter_patrol() -> void:
	transition_state(PATROL)
	play_animation(&"walk")


func _enter_chase() -> void:
	transition_state(CHASE)
	play_animation(&"walk")


func _enter_attack() -> void:
	if not transition_state(ATTACK):
		return
	velocity.x = 0.0
	current_attack_id = next_attack_id
	next_attack_id += 1
	attack_direction_locked = false
	attack_hitbox.end_attack()
	play_animation(&"attack_thrust", true)


func _update_attack_direction_lock() -> void:
	if attack_direction_locked or not has_valid_target():
		return
	# Three equal windup frames span 0.45 s; the final 0.15 s is frame 02 (zero-based).
	if animated_sprite.frame >= 2:
		attack_direction_locked = true
		return
	set_facing_direction(signf(target.global_position.x - global_position.x))


func _on_attack_cancelled() -> void:
	if attack_hitbox != null:
		attack_hitbox.end_attack()
	attack_window_changed.emit(false)


func _on_enemy_animation_frame_changed() -> void:
	if current_state != ATTACK:
		if attack_hitbox.is_active:
			attack_hitbox.end_attack()
		return
	var active: bool = animated_sprite.frame in ATTACK_HIT_FRAMES
	if active and not attack_hitbox.is_active:
		attack_hitbox.begin_attack(current_attack_id, config.attack_damage)
		attack_window_changed.emit(true)
	elif not active and attack_hitbox.is_active:
		attack_hitbox.end_attack()
		attack_window_changed.emit(false)


func _on_enemy_animation_finished(animation_name: StringName) -> void:
	if animation_name == &"attack_thrust" and current_state == ATTACK:
		_on_attack_cancelled()
		if has_valid_target():
			_enter_chase()
		else:
			_enter_patrol()


func is_attack_window_active() -> bool:
	return attack_hitbox != null and attack_hitbox.is_active


func get_attack_phase_name() -> StringName:
	if current_state != ATTACK:
		return &"None"
	return &"Active" if is_attack_window_active() else &"WindupOrRecovery"


func get_debug_summary() -> String:
	return "%s  %s  HP %d/%d  ANIM %s  DMG %d  RANGE %.0f  HIT %s" % [
		get_enemy_type_name(), current_state, health_component.current_health,
		health_component.max_health, animated_sprite.animation, config.attack_damage,
		config.attack_range, "ON" if is_attack_window_active() else "off",
	]


func _validate_target_distance() -> bool:
	if not has_valid_target():
		clear_target()
		_enter_patrol()
		return false
	var offset: Vector2 = target.global_position - global_position
	if offset.length() > config.lose_target_range or absf(offset.y) > config.platform_height_tolerance:
		clear_target()
		_enter_patrol()
		return false
	return true
