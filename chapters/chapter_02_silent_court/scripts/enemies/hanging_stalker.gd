class_name HangingStalker
extends EnemyCombatant

## Ceiling ambusher with a telegraphed, direction-locked drop and one-claw limit.

signal state_changed(previous_state: StringName, current_state: StringName)

const HANG: StringName = &"Hang"
const ALERT_TELEGRAPH: StringName = &"AlertTelegraph"
const DROP: StringName = &"Drop"
const GROUND_RECOVERY: StringName = &"GroundRecovery"
const CLAW_WINDUP: StringName = &"ClawWindup"
const CLAW_ACTIVE: StringName = &"ClawActive"
const RETREAT: StringName = &"Retreat"
const RETURN_TO_ANCHOR: StringName = &"ReturnToAnchor"
const HURT: StringName = &"Hurt"
const DEATH: StringName = &"Death"

@export var config: HangingStalkerConfig
@export_node_path("AnimatedSprite2D") var animated_sprite_path: NodePath = NodePath("VisualRoot/AnimatedSprite2D")
@export_node_path("HealthComponent") var health_component_path: NodePath = NodePath("HealthComponent")
@export_node_path("HurtboxComponent") var hurtbox_path: NodePath = NodePath("Hurtbox")
@export_node_path("HitboxComponent") var drop_hitbox_path: NodePath = NodePath("FacingRoot/DropHitbox")
@export_node_path("HitboxComponent") var claw_hitbox_path: NodePath = NodePath("FacingRoot/ClawHitbox")
@export_node_path("Area2D") var detection_area_path: NodePath = NodePath("DetectionArea")
@export_node_path("Node2D") var facing_root_path: NodePath = NodePath("FacingRoot")
@export_node_path("Polygon2D") var telegraph_shadow_path: NodePath = NodePath("TelegraphShadow")

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(animated_sprite_path) as AnimatedSprite2D
@onready var health_component: HealthComponent = get_node_or_null(health_component_path) as HealthComponent
@onready var hurtbox: HurtboxComponent = get_node_or_null(hurtbox_path) as HurtboxComponent
@onready var drop_hitbox: HitboxComponent = get_node_or_null(drop_hitbox_path) as HitboxComponent
@onready var claw_hitbox: HitboxComponent = get_node_or_null(claw_hitbox_path) as HitboxComponent
@onready var detection_area: Area2D = get_node_or_null(detection_area_path) as Area2D
@onready var facing_root: Node2D = get_node_or_null(facing_root_path) as Node2D
@onready var telegraph_shadow: Polygon2D = get_node_or_null(telegraph_shadow_path) as Polygon2D

var target: Player
var current_state: StringName = HANG
var state_timer: float = 0.0
var facing_direction: float = -1.0
var ai_active: bool = true
var ceiling_anchor: Vector2 = Vector2.ZERO
var locked_drop_x: float = 0.0
var _direction_locked: bool = false
var _used_ground_claw: bool = false
var _next_attack_id: int = 1
var world_bounds: WorldBounds2D


func _ready() -> void:
	if not _validate_dependencies():
		set_physics_process(false)
		return
	ceiling_anchor = global_position
	world_bounds = _find_world_bounds()
	if world_bounds != null:
		ceiling_anchor = world_bounds.clamp_flight_anchor(ceiling_anchor)
		global_position = ceiling_anchor
	health_component.max_health = config.max_health
	health_component.reset_to_full()
	drop_hitbox.end_attack()
	claw_hitbox.end_attack()
	telegraph_shadow.visible = false
	var detection_shape: CollisionShape2D = detection_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var circle: CircleShape2D = detection_shape.shape as CircleShape2D if detection_shape != null else null
	if circle != null:
		circle.radius = config.detection_range
	animated_sprite.animation_finished.connect(_on_animation_finished)
	health_component.died.connect(_enter_death)
	hurtbox.hit_received.connect(_on_hit_received)
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	_set_facing(facing_direction)
	_play(&"hang")


func _physics_process(delta: float) -> void:
	if current_state == DEATH:
		return
	match current_state:
		HANG:
			_process_hang(delta)
		ALERT_TELEGRAPH:
			_process_telegraph(delta)
		DROP:
			_process_drop()
		GROUND_RECOVERY:
			_process_ground_recovery(delta)
		CLAW_WINDUP:
			_process_claw_windup(delta)
		CLAW_ACTIVE:
			_process_claw_active(delta)
		RETREAT:
			_process_retreat(delta)
		RETURN_TO_ANCHOR:
			_process_return()
		HURT:
			_process_hurt(delta)
	move_and_slide()
	_enforce_flight_bounds()
	if current_state == DROP and is_on_floor():
		_end_drop()


func set_target(new_target: Player) -> void:
	if target == new_target:
		return
	target = new_target
	target_changed.emit(target)
	if target != null and current_state == HANG and ai_active:
		_enter_telegraph()


func set_ai_active(active: bool) -> void:
	if current_state == DEATH or ai_active == active:
		return
	ai_active = active
	if not active:
		target = null
		velocity = Vector2.ZERO
		_transition(HANG)
		global_position = ceiling_anchor
		telegraph_shadow.visible = false
		detection_area.set_deferred("monitoring", false)
		set_physics_process(false)
		_play(&"hang")
	else:
		detection_area.set_deferred("monitoring", true)
		set_physics_process(true)


func is_ai_active() -> bool:
	return ai_active


func is_dead() -> bool:
	return current_state == DEATH


func get_state_name() -> StringName:
	return current_state


func get_enemy_type_name() -> StringName:
	return config.display_name if config != null else &"Hanging Stalker"


func get_detection_range() -> float:
	return config.detection_range if config != null else 0.0


func get_attack_damage() -> int:
	return config.drop_damage if config != null else 0


func get_health_component() -> HealthComponent:
	return health_component


func get_current_animation_name() -> StringName:
	return animated_sprite.animation if animated_sprite != null else &""


func get_attack_phase_name() -> StringName:
	if current_state in [ALERT_TELEGRAPH, CLAW_WINDUP]:
		return StringName("Windup %.2f" % state_timer)
	if current_state in [DROP, CLAW_ACTIVE]:
		return &"Active"
	return &"None"


func is_attack_window_active() -> bool:
	return drop_hitbox.is_active or claw_hitbox.is_active


func _enter_telegraph() -> void:
	_transition(ALERT_TELEGRAPH)
	state_timer = config.telegraph_duration
	_direction_locked = false
	_used_ground_claw = false
	telegraph_shadow.visible = true
	telegraph_shadow.global_position = Vector2(target.global_position.x, ceiling_anchor.y + 370.0)
	_play(&"telegraph", true)


func _process_hang(delta: float) -> void:
	velocity = Vector2.ZERO
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0 and _has_target() and ai_active:
		_enter_telegraph()


func _process_telegraph(delta: float) -> void:
	velocity = Vector2.ZERO
	state_timer = maxf(0.0, state_timer - delta)
	if not _direction_locked and state_timer <= config.direction_lock_lead:
		locked_drop_x = target.global_position.x if _has_target() else global_position.x
		_direction_locked = true
		_set_facing(signf(locked_drop_x - global_position.x))
		telegraph_shadow.global_position.x = locked_drop_x
	if state_timer <= 0.0:
		_transition(DROP)
		velocity = global_position.direction_to(Vector2(locked_drop_x, ceiling_anchor.y + 420.0)) * config.drop_speed
		drop_hitbox.begin_attack(_consume_attack_id(), config.drop_damage, facing_direction, self)
		attack_window_changed.emit(true)
		_play(&"drop", true)


func _process_drop() -> void:
	# Direction is fixed after telegraph; no mid-air tracking.
	velocity = velocity.normalized() * config.drop_speed


func _end_drop() -> void:
	drop_hitbox.end_attack()
	attack_window_changed.emit(false)
	telegraph_shadow.visible = false
	_transition(GROUND_RECOVERY)
	state_timer = config.ground_recovery_duration
	velocity = Vector2.ZERO
	_play(&"ground_recovery", true)


func _process_ground_recovery(delta: float) -> void:
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0:
		return
	if _has_target() and not _used_ground_claw and absf(target.global_position.x - global_position.x) <= 58.0:
		_transition(CLAW_WINDUP)
		state_timer = config.claw_windup
		_set_facing(signf(target.global_position.x - global_position.x))
		_play(&"claw", true)
	else:
		_enter_retreat()


func _process_claw_windup(delta: float) -> void:
	velocity = Vector2.ZERO
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		_transition(CLAW_ACTIVE)
		state_timer = config.claw_active_duration
		_used_ground_claw = true
		claw_hitbox.begin_attack(_consume_attack_id(), config.claw_damage, facing_direction, self)
		attack_window_changed.emit(true)


func _process_claw_active(delta: float) -> void:
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		claw_hitbox.end_attack()
		attack_window_changed.emit(false)
		_enter_retreat()


func _enter_retreat() -> void:
	_transition(RETREAT)
	state_timer = config.retreat_duration
	_play(&"retreat", true)


func _process_retreat(delta: float) -> void:
	state_timer = maxf(0.0, state_timer - delta)
	velocity = Vector2(-facing_direction * 80.0, -120.0)
	if state_timer <= 0.0:
		_transition(RETURN_TO_ANCHOR)
		_play(&"return_to_anchor", true)


func _process_return() -> void:
	velocity = global_position.direction_to(ceiling_anchor) * config.return_speed
	if global_position.distance_to(ceiling_anchor) <= 4.0:
		global_position = ceiling_anchor
		velocity = Vector2.ZERO
		_transition(HANG)
		state_timer = config.reengage_delay
		_play(&"hang")


func _on_hit_received(_damage: int, source_position: Vector2, _attack_id: int) -> void:
	if is_dead():
		return
	_end_attacks()
	_transition(HURT)
	state_timer = config.hurt_duration
	velocity = Vector2(signf(global_position.x - source_position.x) * config.knockback_speed, -30.0)
	_play(&"hurt", true)


func _process_hurt(delta: float) -> void:
	state_timer = maxf(0.0, state_timer - delta)
	velocity = velocity.move_toward(Vector2.ZERO, config.knockback_speed * 5.0 * delta)
	if state_timer <= 0.0:
		_transition(RETURN_TO_ANCHOR)
		_play(&"return_to_anchor", true)


func _enter_death() -> void:
	if not _transition(DEATH):
		return
	_end_attacks()
	telegraph_shadow.visible = false
	hurtbox.set_enabled(false)
	detection_area.set_deferred("monitoring", false)
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO
	_play(&"death", true)
	enemy_died.emit()


func _on_animation_finished() -> void:
	if current_state == DEATH and animated_sprite.animation == &"death":
		visible = false
		presentation_finished.emit()
		queue_free()


func _end_attacks() -> void:
	drop_hitbox.end_attack()
	claw_hitbox.end_attack()
	attack_window_changed.emit(false)


func _transition(next_state: StringName) -> bool:
	if next_state == current_state or current_state == DEATH:
		return false
	var previous: StringName = current_state
	current_state = next_state
	state_changed.emit(previous, current_state)
	return true


func _play(animation_name: StringName, restart: bool = false) -> void:
	if animated_sprite.sprite_frames == null or not animated_sprite.sprite_frames.has_animation(animation_name):
		push_error("Hanging Stalker missing animation %s" % animation_name)
		return
	if animated_sprite.animation == animation_name and animated_sprite.is_playing() and not restart:
		return
	animated_sprite.play(animation_name)


func _set_facing(direction: float) -> void:
	if is_zero_approx(direction):
		return
	facing_direction = signf(direction)
	animated_sprite.flip_h = facing_direction < 0.0
	facing_root.scale.x = facing_direction


func _consume_attack_id() -> int:
	var result: int = _next_attack_id
	_next_attack_id += 1
	return result


func _has_target() -> bool:
	return target != null and is_instance_valid(target) and not target.is_dead()


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player != null and not player.is_dead():
		set_target(player)


func _on_body_exited(body: Node2D) -> void:
	if body == target and global_position.distance_to(body.global_position) > config.lose_target_range:
		set_target(null)


func _validate_dependencies() -> bool:
	if config == null or animated_sprite == null or health_component == null or hurtbox == null or drop_hitbox == null or claw_hitbox == null or detection_area == null or facing_root == null or telegraph_shadow == null:
		push_error("HangingStalker scene composition is incomplete")
		return false
	return true


func _find_world_bounds() -> WorldBounds2D:
	for node: Node in get_tree().get_nodes_in_group(&"world_bounds"):
		if node is WorldBounds2D:
			return node as WorldBounds2D
	return null


func _enforce_flight_bounds() -> void:
	if world_bounds == null or current_state == DEATH:
		return
	var safe_top_y: float = world_bounds.get_safe_flight_top_y()
	if global_position.y < safe_top_y:
		global_position.y = safe_top_y
		velocity.y = maxf(0.0, velocity.y)
		ceiling_anchor = world_bounds.clamp_flight_anchor(ceiling_anchor)
		if current_state not in [HANG, RETURN_TO_ANCHOR]:
			_end_attacks()
			_transition(RETURN_TO_ANCHOR)
			_play(&"return_to_anchor", true)


func get_debug_summary() -> String:
	return "%s  %s  HP %d/%d  ANIM %s  LOCKED %s  CLAW_USED %s  PHASE %s" % [
		get_enemy_type_name(), current_state, health_component.current_health,
		health_component.max_health, animated_sprite.animation, _direction_locked,
		_used_ground_claw, get_attack_phase_name(),
	]
