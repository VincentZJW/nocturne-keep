class_name GroundEnemyBase
extends EnemyCombatant

## Shared grounded-enemy lifecycle: detection, gravity, edges, Hurt, Death, and facing.

signal state_changed(previous_state: StringName, current_state: StringName)

const IDLE: StringName = &"Idle"
const PATROL: StringName = &"Patrol"
const CHASE: StringName = &"Chase"
const HURT: StringName = &"Hurt"
const DEATH: StringName = &"Death"

@export var config: EnemyGroundConfig
@export_node_path("AnimatedSprite2D") var animated_sprite_path: NodePath = NodePath(
	"VisualRoot/AnimatedSprite2D"
)
@export_node_path("Node2D") var facing_root_path: NodePath = NodePath("FacingRoot")
@export_node_path("HealthComponent") var health_component_path: NodePath = NodePath("HealthComponent")
@export_node_path("HurtboxComponent") var hurtbox_path: NodePath = NodePath("Hurtbox")
@export_node_path("Area2D") var detection_area_path: NodePath = NodePath("DetectionArea")
@export_node_path("RayCast2D") var wall_check_path: NodePath = NodePath("WallCheck")
@export_node_path("RayCast2D") var floor_check_path: NodePath = NodePath("FloorCheck")

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(
	animated_sprite_path
) as AnimatedSprite2D
@onready var facing_root: Node2D = get_node_or_null(facing_root_path) as Node2D
@onready var health_component: HealthComponent = get_node_or_null(
	health_component_path
) as HealthComponent
@onready var hurtbox: HurtboxComponent = get_node_or_null(hurtbox_path) as HurtboxComponent
@onready var detection_area: Area2D = get_node_or_null(detection_area_path) as Area2D
@onready var wall_check: RayCast2D = get_node_or_null(wall_check_path) as RayCast2D
@onready var floor_check: RayCast2D = get_node_or_null(floor_check_path) as RayCast2D

var target: Player
var facing_direction: float = -1.0
var state_timer: float = 0.0
var home_x: float = 0.0
var current_state: StringName = IDLE
var ai_active: bool = true
var death_presentation_complete: bool = false


func _ready() -> void:
	if not _validate_common_dependencies():
		set_physics_process(false)
		return
	home_x = global_position.x
	health_component.max_health = config.max_health
	health_component.reset_to_full()
	_configure_detection_radius()
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.frame_changed.connect(_on_animation_frame_changed)
	health_component.died.connect(_on_health_died)
	hurtbox.hit_received.connect(_on_hurtbox_hit_received)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	state_timer = config.initial_idle_duration
	set_facing_direction(facing_direction)
	play_animation(&"idle")
	_on_common_ready()


func _physics_process(delta: float) -> void:
	if is_dead():
		velocity = Vector2.ZERO
		return
	if not is_on_floor():
		velocity.y += config.gravity * delta
	else:
		velocity.y = 0.0
	if current_state == HURT:
		state_timer = maxf(0.0, state_timer - delta)
		velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
		if state_timer <= 0.0:
			_recover_from_hurt()
	else:
		_process_enemy_state(delta)
	move_and_slide()


func set_target(new_target: Player) -> void:
	if target == new_target:
		return
	target = new_target
	target_changed.emit(target)
	if target != null and not is_dead():
		_on_target_acquired()


func set_ai_active(active: bool) -> void:
	if is_dead() or ai_active == active:
		return
	ai_active = active
	_on_ai_active_changed(active)
	if not active:
		target = null
		velocity = Vector2.ZERO
		transition_state(IDLE)
		state_timer = config.initial_idle_duration
		play_animation(&"idle")
		detection_area.set_deferred("monitoring", false)
		set_physics_process(false)
		return
	detection_area.set_deferred("monitoring", true)
	set_physics_process(true)


func is_ai_active() -> bool:
	return ai_active


func is_dead() -> bool:
	return current_state == DEATH


func get_state_name() -> StringName:
	return current_state


func get_enemy_type_name() -> StringName:
	return config.display_name if config != null else &"GroundEnemy"


func get_detection_range() -> float:
	return config.detection_range if config != null else 0.0


func get_attack_damage() -> int:
	return config.attack_damage if config != null else 0


func get_health_component() -> HealthComponent:
	return health_component


func get_current_animation_name() -> StringName:
	return animated_sprite.animation if animated_sprite != null else &""


func transition_state(next_state: StringName) -> bool:
	if next_state == current_state or current_state == DEATH:
		return false
	var previous_state: StringName = current_state
	current_state = next_state
	state_changed.emit(previous_state, current_state)
	return true


func play_animation(animation_name: StringName, restart: bool = false) -> void:
	if animated_sprite.sprite_frames == null or not animated_sprite.sprite_frames.has_animation(animation_name):
		push_error("%s missing animation %s" % [get_enemy_type_name(), animation_name])
		return
	if animated_sprite.animation == animation_name and animated_sprite.is_playing() and not restart:
		return
	animated_sprite.play(animation_name)


func set_facing_direction(direction: float) -> void:
	if is_zero_approx(direction):
		return
	facing_direction = signf(direction)
	animated_sprite.flip_h = facing_direction < 0.0
	facing_root.scale.x = facing_direction
	wall_check.target_position.x = absf(wall_check.target_position.x) * facing_direction
	floor_check.position.x = absf(floor_check.position.x) * facing_direction


func can_advance(direction: float) -> bool:
	set_facing_direction(direction)
	wall_check.force_raycast_update()
	floor_check.force_raycast_update()
	return not wall_check.is_colliding() and floor_check.is_colliding()


func has_valid_target() -> bool:
	return target != null and is_instance_valid(target) and not target.is_dead()


func reached_patrol_boundary() -> bool:
	return (
		global_position.x <= home_x - config.patrol_half_width and facing_direction < 0.0
	) or (
		global_position.x >= home_x + config.patrol_half_width and facing_direction > 0.0
	)


func enter_hurt(source_position: Vector2) -> void:
	if is_dead():
		return
	transition_state(HURT)
	_on_attack_cancelled()
	var knockback_direction: float = signf(global_position.x - source_position.x)
	if is_zero_approx(knockback_direction):
		knockback_direction = -facing_direction
	velocity.x = knockback_direction * config.knockback_speed
	state_timer = config.hurt_duration
	play_animation(&"hurt", true)


func enter_death() -> void:
	if not transition_state(DEATH):
		return
	velocity = Vector2.ZERO
	_on_attack_cancelled()
	hurtbox.set_enabled(false)
	detection_area.set_deferred("monitoring", false)
	collision_layer = 0
	collision_mask = 1
	death_presentation_complete = false
	play_animation(&"death", true)
	enemy_died.emit()


func _on_common_ready() -> void:
	pass


func _process_enemy_state(_delta: float) -> void:
	pass


func _on_target_acquired() -> void:
	pass


func _on_ai_active_changed(_active: bool) -> void:
	pass


func _on_attack_cancelled() -> void:
	attack_window_changed.emit(false)


func _on_enemy_animation_frame_changed() -> void:
	pass


func _on_enemy_animation_finished(_animation_name: StringName) -> void:
	pass


func _recover_from_hurt() -> void:
	if has_valid_target():
		transition_state(CHASE)
		play_animation(&"walk")
	else:
		transition_state(PATROL)
		play_animation(&"walk")


func _validate_common_dependencies() -> bool:
	if config == null:
		push_error("GroundEnemyBase requires EnemyGroundConfig")
		return false
	if (
		animated_sprite == null
		or facing_root == null
		or health_component == null
		or hurtbox == null
		or detection_area == null
		or wall_check == null
		or floor_check == null
	):
		push_error("%s common scene composition is incomplete" % config.display_name)
		return false
	return true


func _configure_detection_radius() -> void:
	var shape_node: CollisionShape2D = detection_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null:
		return
	var circle: CircleShape2D = shape_node.shape as CircleShape2D
	if circle != null:
		circle.radius = config.detection_range


func _on_animation_frame_changed() -> void:
	_on_enemy_animation_frame_changed()


func _on_animation_finished() -> void:
	var animation_name: StringName = animated_sprite.animation
	if animation_name == &"death" and is_dead():
		death_presentation_complete = true
		visible = false
		set_physics_process(false)
		presentation_finished.emit()
		queue_free()
		return
	_on_enemy_animation_finished(animation_name)


func _on_health_died() -> void:
	enter_death()


func _on_hurtbox_hit_received(_damage: int, source_position: Vector2, _attack_id: int) -> void:
	enter_hurt(source_position)


func _on_detection_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player != null and not player.is_dead():
		set_target(player)


func _on_detection_body_exited(body: Node2D) -> void:
	if body == target and global_position.distance_to(body.global_position) > config.lose_target_range:
		clear_target()
