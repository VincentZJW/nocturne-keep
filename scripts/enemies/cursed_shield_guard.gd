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
@export_node_path("AnimatedSprite2D") var shield_break_effect_path: NodePath = NodePath(
	"FacingRoot/ShieldBreakEffect"
)
@export_node_path("Sprite2D") var guard_break_marker_path: NodePath = NodePath(
	"VisualRoot/GuardBreakMarker"
)

@onready var attack_hitbox: HitboxComponent = get_node_or_null(
	attack_hitbox_path
) as HitboxComponent
@onready var shield_policy: ShieldBlockComponent = get_node_or_null(
	shield_policy_path
) as ShieldBlockComponent
@onready var shield_break_effect: AnimatedSprite2D = get_node_or_null(
	shield_break_effect_path
) as AnimatedSprite2D
@onready var guard_break_marker: Sprite2D = get_node_or_null(
	guard_break_marker_path
) as Sprite2D

var next_attack_id: int = 1
var current_attack_id: int = 0
var shield_break_flash_tween: Tween


func _on_common_ready() -> void:
	if (
		attack_hitbox == null or shield_policy == null
		or shield_break_effect == null or guard_break_marker == null
	):
		push_error("CursedShieldGuard scene composition is incomplete")
		set_physics_process(false)
		return
	attack_hitbox.damage = config.attack_damage
	attack_hitbox.end_attack()
	shield_break_effect.visible = false
	guard_break_marker.visible = false
	shield_break_effect.animation_finished.connect(_on_shield_break_effect_finished)
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
	if current_state == GUARD_BREAK:
		_finish_guard_break_feedback()
	_set_blocking(not is_shield_broken())
	if has_valid_target():
		_enter_chase()
	else:
		_enter_patrol()


func _on_target_acquired() -> void:
	if _is_guard_break_locked():
		return
	_enter_chase()


func _enter_idle(duration: float = -1.0) -> void:
	if _is_guard_break_locked():
		return
	transition_state(IDLE)
	state_timer = config.initial_idle_duration if duration < 0.0 else duration
	_set_blocking(true)
	play_animation(&"idle")


func _enter_patrol() -> void:
	if _is_guard_break_locked():
		return
	transition_state(PATROL)
	_set_blocking(true)
	play_animation(&"walk")


func _enter_chase() -> void:
	if _is_guard_break_locked():
		return
	transition_state(CHASE)
	_set_blocking(true)
	play_animation(&"walk")


func _enter_attack() -> void:
	if _is_guard_break_locked():
		return
	if not transition_state(ATTACK):
		return
	velocity.x = 0.0
	_set_blocking(false)
	current_attack_id = next_attack_id
	next_attack_id += 1
	attack_hitbox.end_attack()
	play_animation(&"attack", true)


func _on_block_successful(_hitbox: HitboxComponent) -> void:
	if is_dead() or current_state == GUARD_BREAK or is_shield_broken():
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
	_play_shield_break_effect()
	_play_shield_break_flash()
	play_animation(&"guard_break", true)


func enter_death() -> void:
	_finish_guard_break_feedback()
	super.enter_death()


func enter_hurt(source_position: Vector2) -> void:
	if current_state == GUARD_BREAK:
		velocity.x = 0.0
		return
	super.enter_hurt(source_position)


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
	if (
		animation_name == &"attack" or animation_name == &"attack_unshielded"
	) and current_state == ATTACK:
		_on_attack_cancelled()
		if has_valid_target():
			_enter_chase()
		else:
			_enter_patrol()


func _is_death_animation(animation_name: StringName) -> bool:
	return animation_name == &"death" or animation_name == &"death_unshielded"


func _recover_from_hurt() -> void:
	_set_blocking(not is_shield_broken())
	if has_valid_target():
		_enter_chase()
	else:
		_enter_patrol()


func is_attack_window_active() -> bool:
	return attack_hitbox != null and attack_hitbox.is_active


func is_blocking() -> bool:
	return shield_policy != null and shield_policy.is_blocking


func is_shield_broken() -> bool:
	return shield_policy != null and shield_policy.is_shield_broken()


func get_attack_phase_name() -> StringName:
	if current_state == GUARD_BREAK:
		return &"GuardBreak"
	if current_state == BLOCK:
		return &"Blocked"
	if current_state == ATTACK:
		return &"Active" if is_attack_window_active() else &"WindupOrRecovery"
	return &"None"


func get_debug_summary() -> String:
	return "%s  STATE %s  HP %d/%d  ANIM %s  DMG %d  BLOCK %s  SHIELD BROKEN %s  HIT %s" % [
		get_enemy_type_name(), current_state, health_component.current_health,
		health_component.max_health, animated_sprite.animation, config.attack_damage,
		"ON" if is_blocking() else "OFF", "true" if is_shield_broken() else "false",
		"ON" if is_attack_window_active() else "OFF",
	]


func play_animation(animation_name: StringName, restart: bool = false) -> void:
	var resolved_name: StringName = animation_name
	if is_shield_broken():
		var unshielded_name: StringName = StringName("%s_unshielded" % animation_name)
		if animated_sprite != null and animated_sprite.sprite_frames.has_animation(unshielded_name):
			resolved_name = unshielded_name
	super.play_animation(resolved_name, restart)


func _set_blocking(enabled: bool) -> void:
	if shield_policy != null:
		shield_policy.set_blocking(enabled)


func _play_shield_break_effect() -> void:
	if shield_break_effect == null:
		return
	shield_break_effect.visible = true
	guard_break_marker.visible = true
	shield_break_effect.stop()
	shield_break_effect.frame = 0
	shield_break_effect.play(&"shield_break")


func _on_shield_break_effect_finished() -> void:
	shield_break_effect.visible = false


func _play_shield_break_flash() -> void:
	if animated_sprite == null:
		return
	if shield_break_flash_tween != null and shield_break_flash_tween.is_valid():
		shield_break_flash_tween.kill()
	animated_sprite.modulate = Color(1.8, 1.65, 1.25, 1.0)
	shield_break_flash_tween = create_tween()
	shield_break_flash_tween.tween_property(
		animated_sprite, "modulate", Color.WHITE, 0.12
	)


func _finish_guard_break_feedback() -> void:
	if shield_break_effect != null:
		shield_break_effect.stop()
		shield_break_effect.visible = false
	if guard_break_marker != null:
		guard_break_marker.visible = false
	if shield_break_flash_tween != null and shield_break_flash_tween.is_valid():
		shield_break_flash_tween.kill()
	if animated_sprite != null:
		animated_sprite.modulate = Color.WHITE


func _is_guard_break_locked() -> bool:
	return current_state == GUARD_BREAK and state_timer > 0.0


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
