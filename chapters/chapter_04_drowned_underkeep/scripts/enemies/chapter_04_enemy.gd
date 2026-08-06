class_name Chapter04Enemy
extends GroundEnemyBase

const ALERT: StringName = &"Alert"
const APPROACH: StringName = &"Approach"
const TURN: StringName = &"Turn"
const LIGHT_HIT: StringName = &"LightHitReaction"
const STAGGER: StringName = &"Stagger"
const HIDDEN: StringName = &"Hidden"
const GUARD_BREAK: StringName = &"GuardBreak"

@export_node_path("HitboxComponent") var primary_hitbox_path: NodePath = NodePath("FacingRoot/PrimaryHitbox")
@export_node_path("HitboxComponent") var secondary_hitbox_path: NodePath = NodePath("FacingRoot/SecondaryHitbox")
@export_node_path("Chapter04PoiseComponent") var poise_component_path: NodePath = NodePath("PoiseComponent")
@export_node_path("ShieldComponent") var shield_component_path: NodePath
@export_node_path("AnimatedSprite2D") var shield_visual_path: NodePath
@export var projectile_scene: PackedScene

@onready var primary_hitbox: HitboxComponent = get_node_or_null(primary_hitbox_path) as HitboxComponent
@onready var secondary_hitbox: HitboxComponent = get_node_or_null(secondary_hitbox_path) as HitboxComponent
@onready var poise_component: Chapter04PoiseComponent = get_node_or_null(poise_component_path) as Chapter04PoiseComponent
@onready var shield_component: ShieldComponent = (
	get_node_or_null(shield_component_path) as ShieldComponent if not shield_component_path.is_empty() else null
)
@onready var shield_visual: AnimatedSprite2D = (
	get_node_or_null(shield_visual_path) as AnimatedSprite2D if not shield_visual_path.is_empty() else null
)

var attack_phase: StringName = &"None"
var active_action: StringName = &""
var action_timer: float = 0.0
var action_damage: int = 0
var action_active_duration: float = 0.0
var action_recovery: float = 0.0
var current_attack_id: int = 0
var _next_attack_id: int = 1
var _secondary_cooldown: float = 0.0
var _special_cooldown: float = 0.0
var _poise_broken_this_hit: bool = false
var _hidden: bool = false
var _hover_origin_y: float = 0.0
var _hover_time: float = 0.0
var _primary_hitbox_default_position: Vector2 = Vector2.ZERO
var _primary_hitbox_default_size: Vector2 = Vector2.ZERO
var _secondary_hitbox_default_position: Vector2 = Vector2.ZERO
var _secondary_hitbox_default_size: Vector2 = Vector2.ZERO
var _hitbox_geometry_ready: bool = false
var world_bounds: WorldBounds2D


func _on_common_ready() -> void:
	if primary_hitbox == null or secondary_hitbox == null or poise_component == null:
		push_error("%s requires two hitboxes and Chapter04PoiseComponent" % get_enemy_type_name())
		set_physics_process(false)
		return
	health_component.max_health = _chapter_config().chapter_max_health
	health_component.reset_to_full()
	poise_component.configure(_chapter_config().max_poise, _chapter_config().poise_recovery_delay)
	hurtbox.hit_resolving.connect(_on_hit_resolving)
	_capture_runtime_hitbox_geometry()
	_end_hitboxes()
	_hover_origin_y = global_position.y
	world_bounds = _find_world_bounds()
	if world_bounds != null and _chapter_config().airborne:
		var safe_anchor: Vector2 = world_bounds.clamp_flight_anchor(global_position)
		global_position = safe_anchor
		_hover_origin_y = safe_anchor.y
	if shield_component != null:
		shield_component.shield_max_health = _chapter_config().shield_max_health
		shield_component.shield_health_changed.connect(_on_shield_health_changed)
		shield_component.shield_broken.connect(_on_shield_broken)
		shield_component.reset_shield()
		_update_shield_visual()
	if _chapter_config().starts_hidden:
		_enter_hidden()


func _process_enemy_state(delta: float) -> void:
	# Encounter dormancy resets the shared base state to Idle.  Ambush enemies
	# must re-enter their authored hidden state before any target-driven action,
	# otherwise the disabled Hurtbox can survive while combat proceeds.
	if _hidden and current_state != HIDDEN:
		transition_state(HIDDEN)
		state_timer = _chapter_config().hidden_duration
		velocity = Vector2.ZERO
		play_animation(&"hidden", true)
	_secondary_cooldown = maxf(0.0, _secondary_cooldown - delta)
	_special_cooldown = maxf(0.0, _special_cooldown - delta)
	poise_component.advance(delta, current_state == STAGGER or current_state == GUARD_BREAK)
	_update_airborne_motion(delta)
	if attack_phase != &"None":
		_process_action(delta)
		return
	match current_state:
		HIDDEN:
			_process_hidden(delta)
		IDLE:
			_process_idle(delta)
		PATROL:
			_process_patrol(delta)
		ALERT:
			_process_alert(delta)
		CHASE, APPROACH:
			_process_approach(delta)
		TURN:
			_process_turn(delta)
		LIGHT_HIT, STAGGER, GUARD_BREAK:
			_process_reaction(delta)


func _update_airborne_motion(delta: float) -> void:
	if not _chapter_config().airborne:
		return
	_enforce_flight_bounds()
	_hover_time += delta
	var desired_y: float = _hover_origin_y + sin(_hover_time * 2.0) * _chapter_config().hover_amplitude
	velocity.y = clampf((desired_y - global_position.y) * 5.0, -48.0, 48.0)


func _process_hidden(delta: float) -> void:
	velocity = Vector2.ZERO
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0 and has_valid_target():
		_hidden = false
		hurtbox.set_enabled(true)
		_enter_alert()


func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	if has_valid_target():
		_enter_alert()
		return
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		transition_state(PATROL)
		play_animation(&"walk")


func _process_patrol(delta: float) -> void:
	if has_valid_target():
		_enter_alert()
		return
	if not _chapter_config().airborne and (reached_patrol_boundary() or not can_advance(facing_direction)):
		set_facing_direction(-facing_direction)
		transition_state(IDLE)
		state_timer = config.patrol_turn_pause
		velocity.x = 0.0
		play_animation(&"idle")
		return
	velocity.x = move_toward(velocity.x, facing_direction * config.patrol_speed, config.ground_acceleration * delta)


func _process_alert(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		transition_state(APPROACH)
		play_animation(&"walk")


func _process_approach(delta: float) -> void:
	if not _validate_target():
		return
	var offset: Vector2 = target.global_position - global_position
	var direction: float = _horizontal_target_direction()
	var distance_x: float = absf(offset.x)
	if direction != facing_direction:
		transition_state(TURN)
		state_timer = _chapter_config().turn_duration
		velocity.x = 0.0
		play_animation(&"turn", true)
		return
	set_facing_direction(direction)
	if _special_cooldown <= 0.0 and distance_x <= _chapter_config().special_range and _next_attack_id % 5 == 0:
		_start_action(_chapter_config().special_action, _chapter_config().special_damage, _chapter_config().special_windup, _chapter_config().special_active_duration, _chapter_config().special_recovery)
		_special_cooldown = _chapter_config().special_cooldown
		return
	if _secondary_cooldown <= 0.0 and distance_x <= _chapter_config().secondary_range and _next_attack_id % 2 == 0:
		_start_action(_chapter_config().secondary_action, _chapter_config().secondary_damage, _chapter_config().secondary_windup, _chapter_config().secondary_active_duration, _chapter_config().secondary_recovery)
		_secondary_cooldown = _chapter_config().secondary_cooldown
		return
	if distance_x <= config.attack_range:
		_start_action(_chapter_config().primary_action, config.attack_damage, config.attack_windup, config.attack_active_duration, config.attack_recovery)
		return
	if not _chapter_config().airborne and not can_advance(direction):
		velocity.x = 0.0
		return
	velocity.x = move_toward(velocity.x, direction * config.chase_speed, config.ground_acceleration * delta)
	play_animation(&"walk")


func _process_turn(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		if has_valid_target():
			set_facing_direction(_horizontal_target_direction())
		transition_state(APPROACH if has_valid_target() else PATROL)
		play_animation(&"walk")


func _process_reaction(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		if current_state in [STAGGER, GUARD_BREAK]:
			poise_component.reset_to_full()
		transition_state(APPROACH if has_valid_target() else PATROL)
		play_animation(&"walk")


func _start_action(action: StringName, damage: int, windup: float, active_duration: float, recovery: float) -> void:
	active_action = action
	action_damage = damage
	action_active_duration = active_duration
	action_recovery = recovery
	attack_phase = &"Windup"
	action_timer = windup
	velocity.x = 0.0
	transition_state(StringName("%sWindup" % action))
	play_animation(StringName("%s_windup" % action), true)


func _process_action(delta: float) -> void:
	if attack_phase == &"Active":
		velocity.x = facing_direction * _active_motion_speed()
	else:
		velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	action_timer = maxf(0.0, action_timer - delta)
	if action_timer > 0.0:
		return
	match attack_phase:
		&"Windup":
			_begin_active_window()
		&"Active":
			_end_hitboxes()
			attack_phase = &"Recovery"
			action_timer = action_recovery
			transition_state(StringName("%sRecovery" % active_action))
			play_animation(StringName("%s_recovery" % active_action), true)
		&"Recovery":
			attack_phase = &"None"
			active_action = &""
			transition_state(APPROACH if has_valid_target() else PATROL)
			play_animation(&"walk")


func _begin_active_window() -> void:
	attack_phase = &"Active"
	action_timer = action_active_duration
	current_attack_id = _next_attack_id
	_next_attack_id += 1
	transition_state(StringName("%sActive" % active_action))
	play_animation(StringName("%s_active" % active_action), true)
	if _is_projectile_action(active_action):
		_spawn_projectile()
	else:
		var selected: HitboxComponent = secondary_hitbox if active_action != _chapter_config().primary_action else primary_hitbox
		_configure_active_hitbox_geometry(selected)
		selected.attack_kind = StringName("enemy_%s" % active_action)
		selected.begin_attack(current_attack_id, action_damage, facing_direction, self)
		attack_window_changed.emit(true)
	_apply_pull_if_needed()


func _is_projectile_action(action: StringName) -> bool:
	return action in [&"harpoon_shot", &"hooked_harpoon", &"tongue_lash"]


func _spawn_projectile() -> void:
	if projectile_scene == null or not has_valid_target():
		return
	var projectile: Chapter04EnemyProjectile = projectile_scene.instantiate() as Chapter04EnemyProjectile
	if projectile == null:
		return
	get_tree().current_scene.add_child(projectile)
	projectile.z_index = 16
	projectile.global_position = global_position + Vector2(facing_direction * 30.0, -8.0)
	projectile.lifetime = _chapter_config().projectile_lifetime
	projectile.launch((target.global_position - projectile.global_position).normalized(), _chapter_config().projectile_speed, action_damage, current_attack_id, self, active_action)


func _apply_pull_if_needed() -> void:
	if _chapter_config().pull_strength <= 0.0 or not has_valid_target():
		return
	if active_action in [&"hook_drag", &"drag", &"tongue_lash", &"hooked_harpoon"]:
		target.velocity.x = move_toward(target.velocity.x, global_position.x - target.global_position.x, _chapter_config().pull_strength)


func _active_motion_speed() -> float:
	if active_action == _chapter_config().primary_action:
		return _chapter_config().primary_motion_speed
	if active_action == _chapter_config().secondary_action:
		return _chapter_config().secondary_motion_speed
	return _chapter_config().special_motion_speed


func _active_action_range() -> float:
	if active_action == _chapter_config().primary_action:
		return config.attack_range
	if active_action == _chapter_config().secondary_action:
		return _chapter_config().secondary_range
	return _chapter_config().special_range


func _capture_runtime_hitbox_geometry() -> void:
	var primary_shape: CollisionShape2D = _get_hitbox_collision_shape(primary_hitbox)
	var secondary_shape: CollisionShape2D = _get_hitbox_collision_shape(secondary_hitbox)
	if primary_shape == null or secondary_shape == null:
		push_error("%s requires CollisionShape2D children on both attack Hitboxes" % get_enemy_type_name())
		return
	var primary_rectangle: RectangleShape2D = primary_shape.shape as RectangleShape2D
	var secondary_rectangle: RectangleShape2D = secondary_shape.shape as RectangleShape2D
	if primary_rectangle == null or secondary_rectangle == null:
		push_error("%s requires rectangular attack Hitboxes" % get_enemy_type_name())
		return
	# Scene subresources are shared between instances. Each combatant owns a
	# runtime copy so one long-range action cannot resize another actor's shape.
	primary_rectangle = primary_rectangle.duplicate(true) as RectangleShape2D
	secondary_rectangle = secondary_rectangle.duplicate(true) as RectangleShape2D
	primary_shape.shape = primary_rectangle
	secondary_shape.shape = secondary_rectangle
	_primary_hitbox_default_position = primary_hitbox.position
	_primary_hitbox_default_size = primary_rectangle.size
	_secondary_hitbox_default_position = secondary_hitbox.position
	_secondary_hitbox_default_size = secondary_rectangle.size
	_hitbox_geometry_ready = true


func _configure_active_hitbox_geometry(hitbox: HitboxComponent) -> void:
	_restore_default_hitbox_geometry(hitbox)
	if not _hitbox_geometry_ready or not is_zero_approx(_active_motion_speed()):
		return
	var collision_shape: CollisionShape2D = _get_hitbox_collision_shape(hitbox)
	var rectangle: RectangleShape2D = collision_shape.shape as RectangleShape2D if collision_shape != null else null
	if rectangle == null:
		return
	var default_position: Vector2 = (
		_primary_hitbox_default_position
		if hitbox == primary_hitbox
		else _secondary_hitbox_default_position
	)
	var default_size: Vector2 = (
		_primary_hitbox_default_size
		if hitbox == primary_hitbox
		else _secondary_hitbox_default_size
	)
	var near_edge: float = default_position.x - default_size.x * 0.5
	var default_far_edge: float = default_position.x + default_size.x * 0.5
	var required_far_edge: float = maxf(default_far_edge, _active_action_range())
	if is_equal_approx(required_far_edge, default_far_edge):
		return
	var resized_width: float = required_far_edge - near_edge
	hitbox.position.x = (near_edge + required_far_edge) * 0.5
	rectangle.size.x = resized_width


func _restore_default_hitbox_geometry(hitbox: HitboxComponent) -> void:
	if not _hitbox_geometry_ready or hitbox == null:
		return
	var collision_shape: CollisionShape2D = _get_hitbox_collision_shape(hitbox)
	var rectangle: RectangleShape2D = collision_shape.shape as RectangleShape2D if collision_shape != null else null
	if rectangle == null:
		return
	if hitbox == primary_hitbox:
		hitbox.position = _primary_hitbox_default_position
		rectangle.size = _primary_hitbox_default_size
		return
	hitbox.position = _secondary_hitbox_default_position
	rectangle.size = _secondary_hitbox_default_size


func _get_hitbox_collision_shape(hitbox: HitboxComponent) -> CollisionShape2D:
	return hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D if hitbox != null else null


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	if hitbox == null or is_dead() or current_state == GUARD_BREAK:
		return
	var impact: int = _chapter_config().dash_attack_poise_damage if hitbox.attack_kind in [&"dash_attack", &"ground_dash_attack", &"air_dash_attack"] else _chapter_config().normal_attack_poise_damage
	if not poise_component.apply_impact(impact):
		return
	_poise_broken_this_hit = true
	_on_attack_cancelled()
	transition_state(STAGGER)
	state_timer = _chapter_config().stagger_duration
	velocity.x = 0.0
	play_animation(&"stagger", true)


func _on_hurtbox_hit_received(_damage: int, source_position: Vector2, _attack_id: int) -> void:
	if is_dead() or _poise_broken_this_hit:
		_poise_broken_this_hit = false
		return
	if current_state in [STAGGER, GUARD_BREAK]:
		return
	if _chapter_config().protected_active_frames and attack_phase == &"Active":
		return
	_on_attack_cancelled()
	transition_state(LIGHT_HIT)
	state_timer = config.hurt_duration
	velocity.x = signf(global_position.x - source_position.x) * config.knockback_speed * 0.35
	play_animation(&"light_hit", true)


func _on_shield_health_changed(_current: int, _maximum: int) -> void:
	_update_shield_visual()


func _on_shield_broken(_hitbox: HitboxComponent) -> void:
	_on_attack_cancelled()
	transition_state(GUARD_BREAK)
	state_timer = _chapter_config().guard_break_duration
	velocity = Vector2.ZERO
	play_animation(&"guard_break", true)
	_update_shield_visual()


func _update_shield_visual() -> void:
	if shield_visual == null or shield_component == null:
		return
	var visual_state: StringName = shield_component.get_visual_state()
	shield_visual.visible = visual_state != &"broken"
	if shield_visual.visible and shield_visual.sprite_frames.has_animation(visual_state):
		shield_visual.play(visual_state)


func _enter_alert() -> void:
	transition_state(ALERT)
	state_timer = _chapter_config().alert_duration
	velocity.x = 0.0
	play_animation(&"alert", true)


func _enter_hidden() -> void:
	_hidden = true
	transition_state(HIDDEN)
	state_timer = _chapter_config().hidden_duration
	velocity = Vector2.ZERO
	hurtbox.set_enabled(false)
	play_animation(&"hidden", true)


func _horizontal_target_direction() -> float:
	if not has_valid_target():
		return facing_direction
	var horizontal_offset: float = target.global_position.x - global_position.x
	# Player and Enemy can share an X coordinate while separated vertically on
	# authored platforms. A zero sign must retain the current facing; treating it
	# as a new direction creates an endless Approach -> Turn cycle.
	return facing_direction if is_zero_approx(horizontal_offset) else signf(horizontal_offset)


func _find_world_bounds() -> WorldBounds2D:
	for node: Node in get_tree().get_nodes_in_group(&"world_bounds"):
		if node is WorldBounds2D:
			return node as WorldBounds2D
	return null


func _enforce_flight_bounds() -> void:
	if world_bounds == null or not _chapter_config().airborne or is_dead():
		return
	var safe_top_y: float = world_bounds.get_safe_flight_top_y()
	if global_position.y < safe_top_y:
		global_position.y = safe_top_y
		velocity.y = maxf(0.0, velocity.y)
		_hover_origin_y = maxf(_hover_origin_y, safe_top_y + _chapter_config().hover_amplitude)


func _validate_target() -> bool:
	if not has_valid_target() or global_position.distance_to(target.global_position) > config.lose_target_range:
		clear_target()
		transition_state(PATROL)
		play_animation(&"walk")
		return false
	return true


func _end_hitboxes() -> void:
	if primary_hitbox != null:
		primary_hitbox.end_attack()
		_restore_default_hitbox_geometry(primary_hitbox)
	if secondary_hitbox != null:
		secondary_hitbox.end_attack()
		_restore_default_hitbox_geometry(secondary_hitbox)
	attack_window_changed.emit(false)


func _on_attack_cancelled() -> void:
	_end_hitboxes()
	attack_phase = &"None"
	active_action = &""
	action_timer = 0.0
	action_damage = 0
	action_active_duration = 0.0
	action_recovery = 0.0
	super._on_attack_cancelled()


func _on_ai_active_changed(active: bool) -> void:
	if active:
		return
	# Encounter rollback and room suspension are allowed during any combat
	# phase. Clear Chapter IV's action state before the shared base enters Idle,
	# otherwise reactivation can resume a stale Windup/Active/Recovery phase.
	_on_attack_cancelled()
	_poise_broken_this_hit = false
	if poise_component != null:
		poise_component.reset_to_full()


func is_attack_window_active() -> bool:
	return (primary_hitbox != null and primary_hitbox.is_active) or (secondary_hitbox != null and secondary_hitbox.is_active)


func get_attack_phase_name() -> StringName:
	return attack_phase


func get_active_projectile_count() -> int:
	return get_tree().get_nodes_in_group("chapter_04_enemy_projectile").size()


func get_debug_summary() -> String:
	var shield_text: String = ""
	if shield_component != null:
		shield_text = " SHIELD %d/%d %s" % [shield_component.shield_current_health, shield_component.shield_max_health, shield_component.get_visual_state()]
	return "%s %s HP %d/%d POISE %d/%d ACTION %s/%s%s" % [get_enemy_type_name(), current_state, health_component.current_health, health_component.max_health, poise_component.current_poise, _chapter_config().max_poise, active_action, attack_phase, shield_text]


func _chapter_config() -> Chapter04EnemyConfig:
	return config as Chapter04EnemyConfig
