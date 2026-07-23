class_name CastleGuard
extends CharacterBody2D

## Cursed Castle Guard: bounded patrol, horizontal chase, telegraphed heavy sword cut.

signal enemy_died
signal presentation_finished
signal target_changed(target: Player)
signal attack_window_changed(active: bool)

const ATTACK_HIT_FRAMES: Array[int] = [2, 3]

@export var config: CastleGuardConfig
@export_node_path("AnimatedSprite2D") var animated_sprite_path: NodePath = NodePath(
	"VisualRoot/AnimatedSprite2D"
)
@export_node_path("Node2D") var facing_root_path: NodePath = NodePath("FacingRoot")
@export_node_path("HealthComponent") var health_component_path: NodePath = NodePath("HealthComponent")
@export_node_path("HurtboxComponent") var hurtbox_path: NodePath = NodePath("Hurtbox")
@export_node_path("HitboxComponent") var attack_hitbox_path: NodePath = NodePath(
	"FacingRoot/AttackHitbox"
)
@export_node_path("Area2D") var detection_area_path: NodePath = NodePath("DetectionArea")
@export_node_path("RayCast2D") var wall_check_path: NodePath = NodePath("WallCheck")
@export_node_path("RayCast2D") var floor_check_path: NodePath = NodePath("FloorCheck")
@export_node_path("CastleGuardStateMachine") var state_machine_path: NodePath = NodePath(
	"StateMachine"
)

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(
	animated_sprite_path
) as AnimatedSprite2D
@onready var facing_root: Node2D = get_node_or_null(facing_root_path) as Node2D
@onready var health_component: HealthComponent = get_node_or_null(
	health_component_path
) as HealthComponent
@onready var hurtbox: HurtboxComponent = get_node_or_null(hurtbox_path) as HurtboxComponent
@onready var attack_hitbox: HitboxComponent = get_node_or_null(
	attack_hitbox_path
) as HitboxComponent
@onready var detection_area: Area2D = get_node_or_null(detection_area_path) as Area2D
@onready var wall_check: RayCast2D = get_node_or_null(wall_check_path) as RayCast2D
@onready var floor_check: RayCast2D = get_node_or_null(floor_check_path) as RayCast2D
@onready var state_machine: CastleGuardStateMachine = get_node_or_null(
	state_machine_path
) as CastleGuardStateMachine

var target: Player
var facing_direction: float = -1.0
var _home_x: float = 0.0
var _state_timer: float = 0.0
var _next_attack_id: int = 1
var _current_attack_id: int = 0
var _death_presentation_complete: bool = false


func _ready() -> void:
	if not _validate_dependencies():
		set_physics_process(false)
		return
	_home_x = global_position.x
	health_component.max_health = config.max_health
	health_component.reset_to_full()
	attack_hitbox.damage = config.attack_damage
	_configure_detection_radius()
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.frame_changed.connect(_on_animation_frame_changed)
	health_component.died.connect(_on_health_died)
	hurtbox.hit_received.connect(_on_hurtbox_hit_received)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	_state_timer = config.initial_idle_duration
	_set_facing_direction(facing_direction)
	_play_animation(&"idle")
	attack_hitbox.end_attack()


func _physics_process(delta: float) -> void:
	if state_machine.is_state(CastleGuardStateMachine.State.DEATH):
		velocity = Vector2.ZERO
		return
	if not is_on_floor():
		velocity.y += config.gravity * delta
	else:
		velocity.y = 0.0
	match state_machine.current_state:
		CastleGuardStateMachine.State.IDLE:
			_process_idle(delta)
		CastleGuardStateMachine.State.PATROL:
			_process_patrol(delta)
		CastleGuardStateMachine.State.CHASE:
			_process_chase(delta)
		CastleGuardStateMachine.State.ATTACK:
			velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
		CastleGuardStateMachine.State.HURT:
			_process_hurt(delta)
	move_and_slide()


func set_target(new_target: Player) -> void:
	if target == new_target:
		return
	target = new_target
	target_changed.emit(target)
	if target != null and not state_machine.is_state(CastleGuardStateMachine.State.DEATH):
		_enter_chase()


func clear_target() -> void:
	set_target(null)


func get_state_name() -> StringName:
	return state_machine.get_state_name() if state_machine != null else &"Invalid"


func is_attack_window_active() -> bool:
	return attack_hitbox != null and attack_hitbox.is_active


func is_dead() -> bool:
	return state_machine != null and state_machine.is_state(CastleGuardStateMachine.State.DEATH)


func is_death_presentation_complete() -> bool:
	return _death_presentation_complete


func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	if _has_valid_target():
		_enter_chase()
		return
	_state_timer = maxf(0.0, _state_timer - delta)
	if _state_timer <= 0.0:
		_enter_patrol()


func _process_patrol(delta: float) -> void:
	if _has_valid_target():
		_enter_chase()
		return
	var reached_boundary: bool = (
		global_position.x <= _home_x - config.patrol_half_width and facing_direction < 0.0
	) or (
		global_position.x >= _home_x + config.patrol_half_width and facing_direction > 0.0
	)
	if reached_boundary or not _can_advance(facing_direction):
		_turn_around()
		_enter_idle(config.patrol_turn_pause)
		return
	velocity.x = move_toward(
		velocity.x,
		facing_direction * config.patrol_speed,
		config.ground_acceleration * delta
	)


func _process_chase(delta: float) -> void:
	if not _has_valid_target():
		clear_target()
		_enter_patrol()
		return
	var offset: Vector2 = target.global_position - global_position
	if offset.length() > config.lose_target_range or absf(offset.y) > config.platform_height_tolerance:
		clear_target()
		_enter_patrol()
		return
	if absf(offset.x) <= config.attack_range:
		if not is_zero_approx(offset.x):
			_set_facing_direction(signf(offset.x))
		velocity.x = 0.0
		_enter_attack()
		return
	var chase_direction: float = signf(offset.x)
	if is_zero_approx(chase_direction):
		velocity.x = 0.0
		return
	_set_facing_direction(chase_direction)
	if not _can_advance(chase_direction):
		velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
		return
	velocity.x = move_toward(
		velocity.x,
		chase_direction * config.chase_speed,
		config.ground_acceleration * delta
	)


func _process_hurt(delta: float) -> void:
	_state_timer = maxf(0.0, _state_timer - delta)
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	if _state_timer > 0.0:
		return
	if _has_valid_target():
		_enter_chase()
	else:
		_enter_patrol()


func _enter_idle(duration: float = -1.0) -> void:
	state_machine.transition(CastleGuardStateMachine.State.IDLE)
	_state_timer = config.initial_idle_duration if duration < 0.0 else duration
	_play_animation(&"idle")


func _enter_patrol() -> void:
	if state_machine.transition(CastleGuardStateMachine.State.PATROL):
		_play_animation(&"walk")


func _enter_chase() -> void:
	if state_machine.is_state(CastleGuardStateMachine.State.DEATH):
		return
	if state_machine.transition(CastleGuardStateMachine.State.CHASE):
		_play_animation(&"walk")


func _enter_attack() -> void:
	if not state_machine.transition(CastleGuardStateMachine.State.ATTACK):
		return
	velocity.x = 0.0
	_current_attack_id = _next_attack_id
	_next_attack_id += 1
	attack_hitbox.end_attack()
	_play_animation(&"attack", true)


func _enter_hurt(source_position: Vector2) -> void:
	if is_dead():
		return
	state_machine.transition(CastleGuardStateMachine.State.HURT)
	attack_hitbox.end_attack()
	attack_window_changed.emit(false)
	var knockback_direction: float = signf(global_position.x - source_position.x)
	if is_zero_approx(knockback_direction):
		knockback_direction = -facing_direction
	velocity.x = knockback_direction * config.knockback_speed
	_state_timer = config.hurt_duration
	_play_animation(&"hurt", true)


func _enter_death() -> void:
	if not state_machine.transition(CastleGuardStateMachine.State.DEATH):
		return
	velocity = Vector2.ZERO
	attack_hitbox.end_attack()
	hurtbox.set_enabled(false)
	detection_area.set_deferred("monitoring", false)
	collision_layer = 0
	collision_mask = 1
	_death_presentation_complete = false
	_play_animation(&"death", true)
	enemy_died.emit()


func _play_animation(animation_name: StringName, restart: bool = false) -> void:
	if animated_sprite.sprite_frames == null or not animated_sprite.sprite_frames.has_animation(animation_name):
		push_error("CastleGuard missing animation %s" % animation_name)
		return
	if animated_sprite.animation == animation_name and animated_sprite.is_playing() and not restart:
		return
	animated_sprite.play(animation_name)


func _set_facing_direction(direction: float) -> void:
	if is_zero_approx(direction):
		return
	facing_direction = signf(direction)
	animated_sprite.flip_h = facing_direction < 0.0
	facing_root.scale.x = facing_direction
	wall_check.target_position.x = absf(wall_check.target_position.x) * facing_direction
	floor_check.position.x = absf(floor_check.position.x) * facing_direction


func _turn_around() -> void:
	_set_facing_direction(-facing_direction)
	velocity.x = 0.0


func _can_advance(direction: float) -> bool:
	_set_facing_direction(direction)
	wall_check.force_raycast_update()
	floor_check.force_raycast_update()
	return not wall_check.is_colliding() and floor_check.is_colliding()


func _has_valid_target() -> bool:
	return target != null and is_instance_valid(target) and not target.is_dead()


func _configure_detection_radius() -> void:
	var collision_shape: CollisionShape2D = detection_area.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	if collision_shape == null:
		return
	var circle: CircleShape2D = collision_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = config.detection_range


func _validate_dependencies() -> bool:
	if config == null:
		push_error("CastleGuard requires CastleGuardConfig")
		return false
	if (
		animated_sprite == null
		or facing_root == null
		or health_component == null
		or hurtbox == null
		or attack_hitbox == null
		or detection_area == null
		or wall_check == null
		or floor_check == null
		or state_machine == null
	):
		push_error("CastleGuard scene composition is incomplete")
		return false
	return true


func _on_animation_frame_changed() -> void:
	if not state_machine.is_state(CastleGuardStateMachine.State.ATTACK):
		if attack_hitbox.is_active:
			attack_hitbox.end_attack()
			attack_window_changed.emit(false)
		return
	var should_be_active: bool = animated_sprite.frame in ATTACK_HIT_FRAMES
	if should_be_active and not attack_hitbox.is_active:
		attack_hitbox.begin_attack(_current_attack_id, config.attack_damage)
		attack_window_changed.emit(true)
	elif not should_be_active and attack_hitbox.is_active:
		attack_hitbox.end_attack()
		attack_window_changed.emit(false)


func _on_animation_finished() -> void:
	match animated_sprite.animation:
		&"attack":
			if state_machine.is_state(CastleGuardStateMachine.State.ATTACK):
				attack_hitbox.end_attack()
				attack_window_changed.emit(false)
				if _has_valid_target():
					_enter_chase()
				else:
					_enter_patrol()
		&"hurt":
			if state_machine.is_state(CastleGuardStateMachine.State.HURT) and _state_timer <= 0.0:
				if _has_valid_target():
					_enter_chase()
				else:
					_enter_patrol()
		&"death":
			if state_machine.is_state(CastleGuardStateMachine.State.DEATH):
				_death_presentation_complete = true
				visible = false
				set_physics_process(false)
				presentation_finished.emit()
				queue_free()


func _on_health_died() -> void:
	_enter_death()


func _on_hurtbox_hit_received(_damage: int, source_position: Vector2, _attack_id: int) -> void:
	if not is_dead():
		_enter_hurt(source_position)


func _on_detection_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player != null and not player.is_dead():
		set_target(player)


func _on_detection_body_exited(body: Node2D) -> void:
	if body == target and global_position.distance_to(body.global_position) > config.lose_target_range:
		clear_target()
