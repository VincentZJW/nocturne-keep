class_name CursedShieldGuard
extends GroundEnemyBase

## Slow shield defender with independent shield Health and delayed target-facing turns.

const BLOCK: StringName = &"Block"
const TURN: StringName = &"Turn"
const GUARD_BREAK: StringName = &"GuardBreak"
const ATTACK: StringName = &"Attack"
const ATTACK_HIT_FRAMES: Array[int] = [2, 3]

@export_node_path("HitboxComponent") var attack_hitbox_path: NodePath = NodePath(
	"FacingRoot/AttackHitbox"
)
@export_node_path("ShieldComponent") var shield_component_path: NodePath = NodePath(
	"ShieldComponent"
)
@export_node_path("AnimatedSprite2D") var shield_visual_path: NodePath = NodePath(
	"FacingRoot/ShieldVisual"
)
@export_node_path("AnimatedSprite2D") var shield_hit_effect_path: NodePath = NodePath(
	"FacingRoot/ShieldHitEffect"
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
@onready var shield_component: ShieldComponent = get_node_or_null(
	shield_component_path
) as ShieldComponent
@onready var shield_visual: AnimatedSprite2D = get_node_or_null(
	shield_visual_path
) as AnimatedSprite2D
@onready var shield_hit_effect: AnimatedSprite2D = get_node_or_null(
	shield_hit_effect_path
) as AnimatedSprite2D
@onready var shield_break_effect: AnimatedSprite2D = get_node_or_null(
	shield_break_effect_path
) as AnimatedSprite2D
@onready var guard_break_marker: Sprite2D = get_node_or_null(
	guard_break_marker_path
) as Sprite2D

var next_attack_id: int = 1
var current_attack_id: int = 0
var pending_turn_direction: float = 0.0
var shield_break_flash_tween: Tween
var shield_hit_tween: Tween


func _on_common_ready() -> void:
	if (
		attack_hitbox == null or shield_component == null or shield_visual == null
		or shield_hit_effect == null or shield_break_effect == null
		or guard_break_marker == null
	):
		push_error("CursedShieldGuard scene composition is incomplete")
		set_physics_process(false)
		return
	var shield_config: CursedShieldGuardConfig = config as CursedShieldGuardConfig
	shield_component.shield_max_health = shield_config.shield_max_health
	shield_component.center_tolerance = shield_config.shield_center_tolerance
	shield_component.shield_health_changed.connect(_on_shield_health_changed)
	shield_component.shield_hit.connect(_on_shield_hit)
	shield_component.shield_broken.connect(_on_shield_broken)
	shield_component.reset_shield()
	attack_hitbox.damage = config.attack_damage
	attack_hitbox.end_attack()
	shield_visual.visible = true
	shield_visual.play(&"intact")
	shield_visual.animation_finished.connect(_on_shield_visual_animation_finished)
	shield_hit_effect.visible = false
	shield_hit_effect.animation_finished.connect(_on_shield_hit_effect_finished)
	shield_break_effect.visible = false
	shield_break_effect.animation_finished.connect(_on_shield_break_effect_finished)
	guard_break_marker.visible = false


func _process_enemy_state(delta: float) -> void:
	match current_state:
		IDLE:
			_process_idle(delta)
		PATROL:
			_process_patrol(delta)
		CHASE:
			_process_chase(delta)
		TURN:
			_process_turn(delta)
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
	velocity.x = move_toward(
		velocity.x,
		facing_direction * config.patrol_speed,
		config.ground_acceleration * delta
	)


func _process_chase(delta: float) -> void:
	if not _validate_target_distance():
		return
	var offset: Vector2 = target.global_position - global_position
	var desired_direction: float = facing_direction if is_zero_approx(offset.x) else signf(offset.x)
	if desired_direction != facing_direction:
		_enter_turn(desired_direction)
		return
	if absf(offset.x) <= config.attack_range:
		_enter_attack()
		return
	if not can_advance(desired_direction):
		velocity.x = 0.0
		return
	velocity.x = move_toward(
		velocity.x,
		desired_direction * config.chase_speed,
		config.ground_acceleration * delta
	)


func _process_turn(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	if not _validate_target_distance():
		return
	var offset_x: float = target.global_position.x - global_position.x
	var desired_direction: float = facing_direction if is_zero_approx(offset_x) else signf(offset_x)
	if desired_direction == facing_direction:
		pending_turn_direction = 0.0
		_enter_chase()
		return
	if desired_direction != pending_turn_direction:
		pending_turn_direction = desired_direction
		state_timer = (config as CursedShieldGuardConfig).turn_delay
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0:
		return
	set_facing_direction(pending_turn_direction)
	pending_turn_direction = 0.0
	_enter_chase()


func _process_reaction(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0:
		return
	if current_state == GUARD_BREAK:
		_finish_guard_break_feedback()
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
	pending_turn_direction = 0.0
	play_animation(&"idle")


func _enter_patrol() -> void:
	if _is_guard_break_locked():
		return
	transition_state(PATROL)
	state_timer = 0.0
	pending_turn_direction = 0.0
	play_animation(&"walk")


func _enter_chase() -> void:
	if _is_guard_break_locked():
		return
	transition_state(CHASE)
	state_timer = 0.0
	play_animation(&"walk")


func _enter_turn(direction: float) -> void:
	if _is_guard_break_locked() or is_zero_approx(direction):
		return
	pending_turn_direction = signf(direction)
	transition_state(TURN)
	state_timer = (config as CursedShieldGuardConfig).turn_delay
	velocity.x = 0.0
	play_animation(&"idle")


func _enter_attack() -> void:
	if _is_guard_break_locked():
		return
	if not transition_state(ATTACK):
		return
	velocity.x = 0.0
	pending_turn_direction = 0.0
	current_attack_id = next_attack_id
	next_attack_id += 1
	attack_hitbox.end_attack()
	play_animation(&"attack", true)


func _on_shield_hit(
	_hitbox: HitboxComponent,
	_applied_damage: int,
	remaining: int
) -> void:
	if is_dead() or remaining <= 0:
		return
	_on_attack_cancelled()
	transition_state(BLOCK)
	state_timer = (config as CursedShieldGuardConfig).block_reaction_duration
	pending_turn_direction = 0.0
	velocity.x = 0.0
	_play_shield_hit_feedback()
	play_animation(&"block", true)


func _on_shield_broken(_hitbox: HitboxComponent) -> void:
	if is_dead() or current_state == GUARD_BREAK:
		return
	_on_attack_cancelled()
	transition_state(GUARD_BREAK)
	state_timer = (config as CursedShieldGuardConfig).guard_break_duration
	pending_turn_direction = 0.0
	velocity.x = 0.0
	_play_shield_break_effect()
	_play_shield_break_flash()
	shield_visual.visible = true
	shield_visual.play(&"shield_break")
	play_animation(&"guard_break", true)


func _on_shield_health_changed(current: int, _maximum: int) -> void:
	if shield_visual == null or current <= 0 or shield_component.is_shield_broken():
		return
	shield_visual.visible = true
	shield_visual.play(shield_component.get_visual_state())


func enter_death() -> void:
	_finish_guard_break_feedback()
	_finish_shield_hit_feedback()
	if shield_visual != null:
		shield_visual.visible = false
	super.enter_death()


func enter_hurt(source_position: Vector2) -> void:
	if current_state == GUARD_BREAK:
		velocity.x = 0.0
		return
	pending_turn_direction = 0.0
	super.enter_hurt(source_position)


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
		attack_hitbox.begin_attack(current_attack_id, config.attack_damage, facing_direction)
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
	if has_valid_target():
		_enter_chase()
	else:
		_enter_patrol()


func is_attack_window_active() -> bool:
	return attack_hitbox != null and attack_hitbox.is_active


func is_blocking() -> bool:
	return shield_component != null and not shield_component.is_shield_broken()


func is_shield_broken() -> bool:
	return shield_component != null and shield_component.is_shield_broken()


func get_shield_current_health() -> int:
	return shield_component.shield_current_health if shield_component != null else 0


func get_shield_max_health() -> int:
	return shield_component.shield_max_health if shield_component != null else 0


func get_turn_remaining() -> float:
	return state_timer if current_state == TURN else 0.0


func get_current_side_name() -> StringName:
	if shield_component == null:
		return &"none"
	if has_valid_target():
		return shield_component.classify_source_side(target.global_position)
	return shield_component.last_hit_side


func get_attack_phase_name() -> StringName:
	if current_state == GUARD_BREAK:
		return &"GuardBreak"
	if current_state == BLOCK:
		return &"ShieldHit"
	if current_state == TURN:
		return &"Turning"
	if current_state == ATTACK:
		return &"Active" if is_attack_window_active() else &"WindupOrRecovery"
	return &"None"


func get_compact_debug_summary() -> String:
	return "SG BODY %d/%d | SH %d/%d %s | SIDE %s | %s | TURN %.2f" % [
		health_component.current_health,
		health_component.max_health,
		get_shield_current_health(),
		get_shield_max_health(),
		shield_component.get_visual_state(),
		get_current_side_name(),
		current_state,
		get_turn_remaining(),
	]


func get_debug_summary() -> String:
	return (
		"%s STATE %s BODY %d/%d SH %d/%d SHIELD %s BLOCK %s SIDE %s TURN %.2f "
		+ "ANIM %s DMG %d HIT %s | LAST %s SRC(%.0f,%.0f) DIR %.0f ID %d "
		+ "SHDMG %d BODYDMG %d OVERFLOW %s GB %.2f"
	) % [
		get_enemy_type_name(), current_state,
		health_component.current_health, health_component.max_health,
		get_shield_current_health(), get_shield_max_health(),
		shield_component.get_visual_state(), "ON" if is_blocking() else "OFF",
		get_current_side_name(), get_turn_remaining(),
		animated_sprite.animation, config.attack_damage,
		"ON" if is_attack_window_active() else "OFF",
		shield_component.last_attack_kind,
		shield_component.last_source_position.x, shield_component.last_source_position.y,
		shield_component.last_attack_direction, shield_component.last_attack_id,
		shield_component.last_shield_damage, shield_component.last_body_damage,
		"discard %d" % shield_component.last_overflow_discarded
		if shield_component.last_overflow_discarded > 0 else "none",
		state_timer if current_state == GUARD_BREAK else 0.0,
	]


func play_animation(animation_name: StringName, restart: bool = false) -> void:
	var resolved_name: StringName = animation_name
	if is_shield_broken():
		var unshielded_name: StringName = StringName("%s_unshielded" % animation_name)
		if animated_sprite != null and animated_sprite.sprite_frames.has_animation(unshielded_name):
			resolved_name = unshielded_name
	super.play_animation(resolved_name, restart)


func _play_shield_hit_feedback() -> void:
	if shield_hit_effect != null:
		shield_hit_effect.visible = true
		shield_hit_effect.stop()
		shield_hit_effect.frame = 0
		shield_hit_effect.play(&"shield_hit")
	if shield_hit_tween != null and shield_hit_tween.is_valid():
		shield_hit_tween.kill()
	shield_visual.position = Vector2.ZERO
	shield_visual.modulate = Color(1.8, 1.65, 1.25, 1.0)
	shield_hit_tween = create_tween()
	shield_hit_tween.tween_property(shield_visual, "position", Vector2(2.0, 0.0), 0.035)
	shield_hit_tween.tween_property(shield_visual, "position", Vector2(-2.0, 0.0), 0.035)
	shield_hit_tween.tween_property(shield_visual, "position", Vector2.ZERO, 0.04)
	shield_hit_tween.parallel().tween_property(shield_visual, "modulate", Color.WHITE, 0.11)


func _finish_shield_hit_feedback() -> void:
	if shield_hit_effect != null:
		shield_hit_effect.stop()
		shield_hit_effect.visible = false
	if shield_hit_tween != null and shield_hit_tween.is_valid():
		shield_hit_tween.kill()
	if shield_visual != null:
		shield_visual.position = Vector2.ZERO
		shield_visual.modulate = Color.WHITE


func _on_shield_hit_effect_finished() -> void:
	shield_hit_effect.visible = false


func _play_shield_break_effect() -> void:
	_finish_shield_hit_feedback()
	shield_break_effect.visible = true
	guard_break_marker.visible = true
	shield_break_effect.stop()
	shield_break_effect.frame = 0
	shield_break_effect.play(&"shield_break")


func _on_shield_break_effect_finished() -> void:
	shield_break_effect.visible = false


func _on_shield_visual_animation_finished() -> void:
	if shield_visual.animation == &"shield_break":
		shield_visual.visible = false


func _play_shield_break_flash() -> void:
	if shield_break_flash_tween != null and shield_break_flash_tween.is_valid():
		shield_break_flash_tween.kill()
	animated_sprite.modulate = Color(1.8, 1.65, 1.25, 1.0)
	shield_break_flash_tween = create_tween()
	shield_break_flash_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.12)


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
	if shield_visual != null and is_shield_broken():
		shield_visual.visible = false


func _is_guard_break_locked() -> bool:
	return current_state == GUARD_BREAK and state_timer > 0.0


func _validate_target_distance() -> bool:
	if not has_valid_target():
		clear_target()
		_enter_patrol()
		return false
	var offset: Vector2 = target.global_position - global_position
	if (
		offset.length() > config.lose_target_range
		or absf(offset.y) > config.platform_height_tolerance
	):
		clear_target()
		_enter_patrol()
		return false
	return true
