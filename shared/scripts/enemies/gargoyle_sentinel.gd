class_name GargoyleSentinel
extends EnemyCombatant

## Airborne ambusher with a readable dive, ground punish window, and return loop.

signal state_changed(previous_state: StringName, current_state: StringName)

const DORMANT: StringName = &"Dormant"
const HOVER: StringName = &"Hover"
const TRACK: StringName = &"Track"
const DIVE_WINDUP: StringName = &"DiveWindup"
const DIVE: StringName = &"Dive"
const GROUND_STUN: StringName = &"GroundStun"
const RETURN_TO_AIR: StringName = &"ReturnToAir"
const HURT: StringName = &"Hurt"
const DEATH: StringName = &"Death"

@export var config: GargoyleSentinelConfig
@export_node_path("AnimatedSprite2D") var animated_sprite_path: NodePath = NodePath(
	"VisualRoot/AnimatedSprite2D"
)
@export_node_path("HealthComponent") var health_component_path: NodePath = NodePath("HealthComponent")
@export_node_path("HurtboxComponent") var hurtbox_path: NodePath = NodePath("Hurtbox")
@export_node_path("HitboxComponent") var dive_hitbox_path: NodePath = NodePath("FacingRoot/DiveHitbox")
@export_node_path("Area2D") var detection_area_path: NodePath = NodePath("DetectionArea")
@export_node_path("Node2D") var facing_root_path: NodePath = NodePath("FacingRoot")

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(animated_sprite_path) as AnimatedSprite2D
@onready var health_component: HealthComponent = get_node_or_null(health_component_path) as HealthComponent
@onready var hurtbox: HurtboxComponent = get_node_or_null(hurtbox_path) as HurtboxComponent
@onready var dive_hitbox: HitboxComponent = get_node_or_null(dive_hitbox_path) as HitboxComponent
@onready var detection_area: Area2D = get_node_or_null(detection_area_path) as Area2D
@onready var facing_root: Node2D = get_node_or_null(facing_root_path) as Node2D

var target: Player
var current_state: StringName = DORMANT
var state_timer: float = 0.0
var cooldown_timer: float = 0.0
var facing_direction: float = -1.0
var ai_active: bool = true
var home_position: Vector2 = Vector2.ZERO
var dive_direction: Vector2 = Vector2.DOWN
var current_attack_id: int = 0
var _next_attack_id: int = 1
var _death_shatter_started: bool = false
var world_bounds: WorldBounds2D


func _ready() -> void:
	if not _validate_dependencies():
		set_physics_process(false)
		return
	home_position = global_position
	world_bounds = _find_world_bounds()
	if world_bounds != null:
		home_position = world_bounds.clamp_flight_anchor(home_position)
		global_position = home_position
	health_component.max_health = config.max_health
	health_component.reset_to_full()
	dive_hitbox.damage = config.dive_damage
	dive_hitbox.end_attack()
	_configure_detection_radius()
	animated_sprite.animation_finished.connect(_on_animation_finished)
	health_component.died.connect(_on_health_died)
	hurtbox.hit_received.connect(_on_hurtbox_hit_received)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	set_facing_direction(facing_direction)
	play_animation(&"dormant")
	if not ai_active:
		detection_area.set_deferred("monitoring", false)
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	if current_state == DEATH:
		return
	cooldown_timer = maxf(0.0, cooldown_timer - delta)
	match current_state:
		DORMANT:
			velocity = Vector2.ZERO
		HOVER, TRACK:
			_process_tracking(delta)
		DIVE_WINDUP:
			_process_windup(delta)
		DIVE:
			_process_dive()
		GROUND_STUN:
			_process_ground_stun(delta)
		RETURN_TO_AIR:
			_process_return(delta)
		HURT:
			_process_hurt(delta)
	move_and_slide()
	_enforce_flight_bounds()
	if current_state == DIVE:
		for index: int in range(get_slide_collision_count()):
			var collision: KinematicCollision2D = get_slide_collision(index)
			if collision.get_collider() is StaticBody2D:
				_enter_ground_stun()
				break


func set_target(new_target: Player) -> void:
	if target == new_target:
		return
	target = new_target
	target_changed.emit(target)
	if target != null and ai_active and current_state == DORMANT:
		play_animation(&"wake", true)


func set_ai_active(active: bool) -> void:
	if current_state == DEATH or ai_active == active:
		return
	ai_active = active
	if not active:
		target = null
		velocity = Vector2.ZERO
		transition_state(DORMANT)
		play_animation(&"dormant")
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
	return config.display_name if config != null else &"GargoyleSentinel"


func get_detection_range() -> float:
	return config.detection_range if config != null else 0.0


func get_attack_damage() -> int:
	return config.dive_damage if config != null else 0


func get_health_component() -> HealthComponent:
	return health_component


func get_current_animation_name() -> StringName:
	return animated_sprite.animation if animated_sprite != null else &""


func get_attack_phase_name() -> StringName:
	if current_state == DIVE_WINDUP:
		return StringName("Windup %.2f" % state_timer)
	if current_state == DIVE:
		return &"DiveActive"
	if current_state == GROUND_STUN:
		return StringName("Stun %.2f" % state_timer)
	return &"None"


func is_attack_window_active() -> bool:
	return dive_hitbox != null and dive_hitbox.is_active


func get_debug_summary() -> String:
	return "%s  %s  HP %d/%d  ANIM %s  DIVE_LOCK %.2f  STUN %.2f  TARGET %s  H %.0f" % [
		get_enemy_type_name(), current_state, health_component.current_health,
		health_component.max_health, animated_sprite.animation,
		state_timer if current_state == DIVE_WINDUP else 0.0,
		state_timer if current_state == GROUND_STUN else 0.0,
		"yes" if _has_target() else "no", home_position.y - global_position.y,
	]


func transition_state(next_state: StringName) -> bool:
	if next_state == current_state or current_state == DEATH:
		return false
	var previous_state: StringName = current_state
	current_state = next_state
	state_changed.emit(previous_state, current_state)
	return true


func play_animation(animation_name: StringName, restart: bool = false) -> void:
	if animated_sprite.sprite_frames == null or not animated_sprite.sprite_frames.has_animation(animation_name):
		push_error("GargoyleSentinel missing animation %s" % animation_name)
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


func _process_tracking(delta: float) -> void:
	if not _has_target():
		velocity = global_position.direction_to(home_position) * config.hover_speed
		if global_position.distance_to(home_position) <= 3.0:
			velocity = Vector2.ZERO
		return
	var offset: Vector2 = target.global_position - global_position
	if offset.length() > config.lose_target_range:
		set_target(null)
		return
	set_facing_direction(signf(offset.x))
	var hover_target: Vector2 = Vector2(target.global_position.x, home_position.y)
	velocity = global_position.direction_to(hover_target) * config.hover_speed
	if cooldown_timer <= 0.0 and absf(offset.x) <= config.detection_range * 0.75:
		_enter_dive_windup()


func _process_windup(delta: float) -> void:
	velocity = Vector2.ZERO
	state_timer = maxf(0.0, state_timer - delta)
	if _has_target() and state_timer > config.dive_direction_lock_duration:
		set_facing_direction(signf(target.global_position.x - global_position.x))
	if state_timer <= 0.0:
		var target_position: Vector2 = target.global_position if _has_target() else global_position + Vector2(facing_direction * 90.0, 90.0)
		dive_direction = global_position.direction_to(target_position + Vector2(0.0, 14.0))
		if absf(dive_direction.x) < 0.25:
			dive_direction.x = facing_direction * 0.25
		dive_direction = dive_direction.normalized()
		transition_state(DIVE)
		velocity = dive_direction * config.dive_speed
		current_attack_id = _next_attack_id
		_next_attack_id += 1
		dive_hitbox.begin_attack(current_attack_id, config.dive_damage, facing_direction, self)
		attack_window_changed.emit(true)
		play_animation(&"dive", true)


func _process_dive() -> void:
	velocity = dive_direction * config.dive_speed


func _process_ground_stun(delta: float) -> void:
	velocity = Vector2.ZERO
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		transition_state(RETURN_TO_AIR)
		play_animation(&"return_to_air", true)


func _process_return(_delta: float) -> void:
	var return_target: Vector2 = Vector2(global_position.x, home_position.y)
	velocity = global_position.direction_to(return_target) * config.return_speed
	if global_position.distance_to(return_target) <= 4.0:
		global_position = return_target
		velocity = Vector2.ZERO
		transition_state(TRACK)
		cooldown_timer = config.attack_cooldown
		play_animation(&"hover")


func _process_hurt(delta: float) -> void:
	state_timer = maxf(0.0, state_timer - delta)
	velocity = velocity.move_toward(Vector2.ZERO, config.knockback_speed * delta * 5.0)
	if state_timer <= 0.0:
		transition_state(TRACK)
		play_animation(&"hover")


func _enter_dive_windup() -> void:
	if not transition_state(DIVE_WINDUP):
		return
	velocity = Vector2.ZERO
	state_timer = config.dive_windup
	play_animation(&"dive_windup", true)


func _enter_ground_stun() -> void:
	if current_state != DIVE:
		return
	dive_hitbox.end_attack()
	attack_window_changed.emit(false)
	transition_state(GROUND_STUN)
	velocity = Vector2.ZERO
	state_timer = config.ground_stun_duration
	play_animation(&"ground_stun", true)


func _enter_hurt(source_position: Vector2) -> void:
	if is_dead():
		return
	dive_hitbox.end_attack()
	attack_window_changed.emit(false)
	transition_state(HURT)
	var knockback: float = signf(global_position.x - source_position.x)
	velocity = Vector2(knockback * config.knockback_speed, -35.0)
	state_timer = config.hurt_duration
	play_animation(&"hurt", true)


func _enter_death() -> void:
	if not transition_state(DEATH):
		return
	dive_hitbox.end_attack()
	attack_window_changed.emit(false)
	hurtbox.set_enabled(false)
	detection_area.set_deferred("monitoring", false)
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO
	_death_shatter_started = false
	play_animation(&"death_fall", true)
	enemy_died.emit()


func _on_animation_finished() -> void:
	if current_state == DORMANT and animated_sprite.animation == &"wake":
		transition_state(TRACK)
		play_animation(&"hover")
	elif current_state == DEATH and animated_sprite.animation == &"death_fall":
		_death_shatter_started = true
		play_animation(&"death_shatter", true)
	elif current_state == DEATH and animated_sprite.animation == &"death_shatter":
		visible = false
		presentation_finished.emit()
		queue_free()


func _on_health_died() -> void:
	_enter_death()


func _on_hurtbox_hit_received(_damage: int, source_position: Vector2, _attack_id: int) -> void:
	_enter_hurt(source_position)


func _on_detection_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player != null and not player.is_dead():
		set_target(player)


func _on_detection_body_exited(body: Node2D) -> void:
	if body == target and global_position.distance_to(body.global_position) > config.lose_target_range:
		set_target(null)


func _has_target() -> bool:
	return target != null and is_instance_valid(target) and not target.is_dead()


func _configure_detection_radius() -> void:
	var shape_node: CollisionShape2D = detection_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var circle: CircleShape2D = shape_node.shape as CircleShape2D if shape_node != null else null
	if circle != null:
		circle.radius = config.detection_range


func _validate_dependencies() -> bool:
	if config == null:
		push_error("GargoyleSentinel requires GargoyleSentinelConfig")
		return false
	if animated_sprite == null or health_component == null or hurtbox == null or dive_hitbox == null or detection_area == null or facing_root == null:
		push_error("GargoyleSentinel scene composition is incomplete")
		return false
	return true


func _find_world_bounds() -> WorldBounds2D:
	var bounds_nodes: Array[Node] = get_tree().get_nodes_in_group(&"world_bounds")
	for node: Node in bounds_nodes:
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
		home_position = world_bounds.clamp_flight_anchor(home_position)
		if current_state in [HOVER, TRACK, RETURN_TO_AIR]:
			transition_state(RETURN_TO_AIR)
			play_animation(&"return_to_air")
