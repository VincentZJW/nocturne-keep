class_name CursedShieldGuard
extends GroundEnemyBase

## Slow shield defender: frontal normal block, frontal Dash guard break, back vulnerability.

const BLOCK: StringName = &"Block"
const GUARD_BREAK: StringName = &"GuardBreak"
const ATTACK: StringName = &"Attack"
const ATTACK_HIT_FRAMES: Array[int] = [2, 3]

@export_node_path("HitboxComponent") var attack_hitbox_path: NodePath = NodePath(
	"FacingRoot/AttackHitbox"
)
@export_node_path("ShieldBlockComponent") var shield_policy_path: NodePath = NodePath(
	"ShieldBlockComponent"
)

@onready var attack_hitbox: HitboxComponent = get_node_or_null(
	attack_hitbox_path
) as HitboxComponent
@onready var shield_policy: ShieldBlockComponent = get_node_or_null(
	shield_policy_path
) as ShieldBlockComponent

var next_attack_id: int = 1
var current_attack_id: int = 0


func _on_common_ready() -> void:
	if attack_hitbox == null or shield_policy == null:
		push_error("CursedShieldGuard scene composition is incomplete")
		set_physics_process(false)
		return
	attack_hitbox.damage = config.attack_damage
	attack_hitbox.end_attack()
	shield_policy.block_successful.connect(_on_block_successful)
	shield_policy.guard_broken.connect(_on_guard_broken)
	_set_blocking(true)


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
		BLOCK, GUARD_BREAK:
			_process_reaction(delta)


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
		_enter_idle(config.patrol_turn_pause)
		return
	velocity.x = move_toward(velocity.x, facing_direction * config.patrol_speed, config.ground_acceleration * delta)


func _process_chase(delta: float) -> void:
	if not _validate_target_distance():
		return
	var offset: Vector2 = target.global_position - global_position
	if absf(offset.x) <= config.attack_range:
		set_facing_direction(signf(offset.x))
		_enter_attack()
		return
	var direction: float = signf(offset.x)
	set_facing_direction(direction)
	if not can_advance(direction):
		velocity.x = 0.0
		return
	velocity.x = move_toward(velocity.x, direction * config.chase_speed, config.ground_acceleration * delta)


func _process_reaction(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0:
		return
	_set_blocking(true)
	if has_valid_target():
		_enter_chase()
	else:
		_enter_patrol()


func _on_target_acquired() -> void:
	_enter_chase()


func _enter_idle(duration: float = -1.0) -> void:
	transition_state(IDLE)
	state_timer = config.initial_idle_duration if duration < 0.0 else duration
	_set_blocking(true)
	play_animation(&"idle")


func _enter_patrol() -> void:
	transition_state(PATROL)
	_set_blocking(true)
	play_animation(&"walk")


func _enter_chase() -> void:
	transition_state(CHASE)
	_set_blocking(true)
	play_animation(&"walk")


func _enter_attack() -> void:
	if not transition_state(ATTACK):
		return
	velocity.x = 0.0
	_set_blocking(false)
	current_attack_id = next_attack_id
	next_attack_id += 1
	attack_hitbox.end_attack()
	play_animation(&"attack", true)


func _on_block_successful(_hitbox: HitboxComponent) -> void:
	if is_dead() or current_state == GUARD_BREAK:
		return
	_on_attack_cancelled()
	transition_state(BLOCK)
	state_timer = (config as CursedShieldGuardConfig).block_reaction_duration
	_set_blocking(true)
	play_animation(&"block", true)


func _on_guard_broken(_hitbox: HitboxComponent) -> void:
	if is_dead() or current_state == GUARD_BREAK:
		return
	_on_attack_cancelled()
	transition_state(GUARD_BREAK)
	state_timer = (config as CursedShieldGuardConfig).guard_break_duration
	_set_blocking(false)
	play_animation(&"guard_break", true)


func _on_attack_cancelled() -> void:
	if attack_hitbox != null:
		attack_hitbox.end_attack()
	attack_window_changed.emit(false)
	if current_state == HURT or current_state == DEATH:
		_set_blocking(false)


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
	if animation_name == &"attack" and current_state == ATTACK:
		_on_attack_cancelled()
		if has_valid_target():
			_enter_chase()
		else:
			_enter_patrol()


func _recover_from_hurt() -> void:
	_set_blocking(true)
	if has_valid_target():
		_enter_chase()
	else:
		_enter_patrol()


func is_attack_window_active() -> bool:
	return attack_hitbox != null and attack_hitbox.is_active


func is_blocking() -> bool:
	return shield_policy != null and shield_policy.is_blocking


func get_attack_phase_name() -> StringName:
	if current_state == GUARD_BREAK:
		return &"GuardBreak"
	if current_state == BLOCK:
		return &"Blocked"
	if current_state == ATTACK:
		return &"Active" if is_attack_window_active() else &"WindupOrRecovery"
	return &"None"


func get_debug_summary() -> String:
	return "%s  %s  HP %d/%d  ANIM %s  DMG %d  BLOCK %s  HIT %s" % [
		get_enemy_type_name(), current_state, health_component.current_health,
		health_component.max_health, animated_sprite.animation, config.attack_damage,
		"ON" if is_blocking() else "off", "ON" if is_attack_window_active() else "off",
	]


func _set_blocking(enabled: bool) -> void:
	if shield_policy != null:
		shield_policy.set_blocking(enabled)


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
