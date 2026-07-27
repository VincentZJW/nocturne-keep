class_name FallenCrossbowman
extends GroundEnemyBase

## Grounded ranged enemy: telegraphed Aim, one bolt, long Reload, close retreat.

const AIM: StringName = &"Aim"
const SHOOT: StringName = &"Shoot"
const RELOAD: StringName = &"Reload"
const RETREAT: StringName = &"Retreat"

@export var projectile_scene: PackedScene
@export_node_path("Marker2D") var muzzle_path: NodePath = NodePath("FacingRoot/Muzzle")

@onready var muzzle: Marker2D = get_node_or_null(muzzle_path) as Marker2D

var bolt_fired_this_shot: bool = false
var active_projectiles: int = 0


func _on_common_ready() -> void:
	if projectile_scene == null or muzzle == null:
		push_error("FallenCrossbowman requires projectile scene and Muzzle")
		set_physics_process(false)


func _process_enemy_state(delta: float) -> void:
	match current_state:
		IDLE:
			_process_idle(delta)
		PATROL:
			_process_patrol(delta)
		CHASE:
			_process_chase(delta)
		AIM:
			_process_aim(delta)
		SHOOT:
			velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
		RELOAD:
			_process_reload(delta)
		RETREAT:
			_process_retreat(delta)


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
	var ranged_config: FallenCrossbowmanConfig = config as FallenCrossbowmanConfig
	var offset: Vector2 = target.global_position - global_position
	var distance_x: float = absf(offset.x)
	set_facing_direction(signf(offset.x))
	if distance_x < ranged_config.minimum_safe_distance:
		transition_state(RETREAT)
		play_animation(&"walk")
		return
	if distance_x <= config.attack_range:
		_enter_aim()
		return
	var direction: float = signf(offset.x)
	if not can_advance(direction):
		velocity.x = 0.0
		return
	velocity.x = move_toward(velocity.x, direction * config.chase_speed, config.ground_acceleration * delta)


func _process_aim(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	if not _validate_target_distance():
		return
	var ranged_config: FallenCrossbowmanConfig = config as FallenCrossbowmanConfig
	var offset: Vector2 = target.global_position - global_position
	if absf(offset.x) < ranged_config.minimum_safe_distance:
		transition_state(RETREAT)
		play_animation(&"walk")
		return
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > ranged_config.aim_lock_duration:
		set_facing_direction(signf(offset.x))
	if state_timer <= 0.0:
		_enter_shoot()


func _process_reload(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		if has_valid_target():
			_enter_chase()
		else:
			_enter_patrol()


func _process_retreat(delta: float) -> void:
	if not _validate_target_distance():
		return
	var ranged_config: FallenCrossbowmanConfig = config as FallenCrossbowmanConfig
	var offset: Vector2 = target.global_position - global_position
	if absf(offset.x) >= ranged_config.retreat_distance:
		_enter_aim()
		return
	var retreat_direction: float = -signf(offset.x)
	set_facing_direction(signf(offset.x))
	if not can_advance(retreat_direction):
		velocity.x = 0.0
		_enter_aim()
		return
	velocity.x = move_toward(velocity.x, retreat_direction * config.chase_speed, config.ground_acceleration * delta)


func _on_target_acquired() -> void:
	_enter_chase()


func _enter_patrol() -> void:
	transition_state(PATROL)
	play_animation(&"walk")


func _enter_chase() -> void:
	transition_state(CHASE)
	play_animation(&"walk")


func _enter_aim() -> void:
	transition_state(AIM)
	state_timer = (config as FallenCrossbowmanConfig).aim_duration
	velocity.x = 0.0
	play_animation(&"aim", true)


func _enter_shoot() -> void:
	transition_state(SHOOT)
	bolt_fired_this_shot = false
	velocity.x = 0.0
	play_animation(&"shoot", true)


func _enter_reload() -> void:
	transition_state(RELOAD)
	state_timer = (config as FallenCrossbowmanConfig).reload_duration
	play_animation(&"reload", true)


func _on_enemy_animation_frame_changed() -> void:
	if current_state == SHOOT and animated_sprite.frame >= 1 and not bolt_fired_this_shot:
		_spawn_bolt()


func _on_enemy_animation_finished(animation_name: StringName) -> void:
	if animation_name == &"shoot" and current_state == SHOOT:
		_enter_reload()


func _spawn_bolt() -> void:
	if projectile_scene == null or muzzle == null or get_parent() == null:
		return
	var bolt: CrossbowBolt = projectile_scene.instantiate() as CrossbowBolt
	if bolt == null:
		push_error("FallenCrossbowman projectile scene is not CrossbowBolt")
		return
	bolt_fired_this_shot = true
	get_parent().add_child(bolt)
	bolt.global_position = muzzle.global_position
	var ranged_config: FallenCrossbowmanConfig = config as FallenCrossbowmanConfig
	bolt.initialize(
		facing_direction,
		ranged_config.projectile_speed,
		ranged_config.projectile_damage,
		ranged_config.projectile_lifetime
	)
	active_projectiles += 1
	bolt.tree_exited.connect(_on_bolt_tree_exited)


func _on_bolt_tree_exited() -> void:
	active_projectiles = maxi(0, active_projectiles - 1)


func get_attack_damage() -> int:
	return (config as FallenCrossbowmanConfig).projectile_damage if config != null else 0


func get_attack_phase_name() -> StringName:
	if current_state == AIM:
		return StringName("Aim %.2f" % state_timer)
	if current_state == RELOAD:
		return StringName("Reload %.2f" % state_timer)
	if current_state == SHOOT:
		return &"Shoot"
	return &"None"


func get_active_projectile_count() -> int:
	return active_projectiles


func get_debug_summary() -> String:
	return "%s  %s  HP %d/%d  ANIM %s  DMG %d  PHASE %s  BOLTS %d" % [
		get_enemy_type_name(), current_state, health_component.current_health,
		health_component.max_health, animated_sprite.animation, get_attack_damage(),
		get_attack_phase_name(), active_projectiles,
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
