class_name Chapter03SpecialistEnemy
extends GroundEnemyBase

const ALERT: StringName = &"Alert"
const APPROACH: StringName = &"Approach"
const TURN: StringName = &"Turn"
const LIGHT_HIT: StringName = &"LightHitReaction"
const STAGGER: StringName = &"Stagger"
const HIDDEN: StringName = &"Hidden"

@export_node_path("HitboxComponent") var primary_hitbox_path: NodePath = NodePath("FacingRoot/PrimaryHitbox")
@export_node_path("HitboxComponent") var secondary_hitbox_path: NodePath = NodePath("FacingRoot/SecondaryHitbox")
@export_node_path("Chapter03PoiseComponent") var poise_component_path: NodePath = NodePath("PoiseComponent")
@export_node_path("Chapter03ScribeWardPolicy") var ward_policy_path: NodePath
@export var projectile_scene: PackedScene
@export var field_scene: PackedScene

@onready var primary_hitbox: HitboxComponent = get_node_or_null(primary_hitbox_path) as HitboxComponent
@onready var secondary_hitbox: HitboxComponent = get_node_or_null(secondary_hitbox_path) as HitboxComponent
@onready var poise_component: Chapter03PoiseComponent = get_node_or_null(poise_component_path) as Chapter03PoiseComponent
@onready var ward_policy: Chapter03ScribeWardPolicy = (
	get_node_or_null(ward_policy_path) as Chapter03ScribeWardPolicy
	if not ward_policy_path.is_empty() else null
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
var _hover_origin_y: float = 0.0
var _hover_time: float = 0.0
var _poise_broken_this_hit: bool = false
var _hidden: bool = false
var _shared_volley_ledger: Dictionary[int, bool] = {}
var _spawned_fields: Array[Chapter03TimedField] = []


func _on_common_ready() -> void:
	if primary_hitbox == null or secondary_hitbox == null or poise_component == null:
		push_error("%s requires two hitboxes and PoiseComponent" % get_enemy_type_name())
		set_physics_process(false)
		return
	health_component.max_health = _specialist_config().chapter_max_health
	health_component.reset_to_full()
	poise_component.configure(_specialist_config().max_poise, _specialist_config().poise_recovery_delay)
	hurtbox.hit_resolving.connect(_on_hit_resolving)
	_end_hitboxes()
	_hover_origin_y = global_position.y
	if ward_policy != null:
		ward_policy.cooldown = _specialist_config().ward_cooldown
	if _specialist_config().starts_hidden:
		_enter_hidden()


func _process_enemy_state(delta: float) -> void:
	_secondary_cooldown = maxf(0.0, _secondary_cooldown - delta)
	_special_cooldown = maxf(0.0, _special_cooldown - delta)
	poise_component.advance(delta, current_state == STAGGER)
	if ward_policy != null:
		ward_policy.advance(delta)
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
		LIGHT_HIT:
			_process_reaction(delta, false)
		STAGGER:
			_process_reaction(delta, true)


func _update_airborne_motion(delta: float) -> void:
	if not _specialist_config().airborne:
		return
	_hover_time += delta
	var desired_y: float = _hover_origin_y + sin(_hover_time * 2.2) * _specialist_config().hover_amplitude
	velocity.y = clampf((desired_y - global_position.y) * 5.0, -42.0, 42.0)


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
	if not _specialist_config().airborne and (reached_patrol_boundary() or not can_advance(facing_direction)):
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
	var direction: float = signf(offset.x)
	var distance_x: float = absf(offset.x)
	if direction != facing_direction:
		transition_state(TURN)
		state_timer = _specialist_config().turn_duration
		velocity.x = 0.0
		play_animation(&"turn", true)
		return
	set_facing_direction(direction)
	if _special_cooldown <= 0.0 and distance_x <= _specialist_config().special_range and _next_attack_id % 5 == 0:
		_start_action(
			_specialist_config().special_action,
			_specialist_config().special_damage,
			_specialist_config().special_windup,
			_specialist_config().special_active_duration,
			_specialist_config().special_recovery
		)
		_special_cooldown = _specialist_config().special_cooldown
		return
	if _secondary_cooldown <= 0.0 and distance_x <= _specialist_config().secondary_range and _next_attack_id % 2 == 0:
		_start_action(
			_specialist_config().secondary_action,
			_specialist_config().secondary_damage,
			_specialist_config().secondary_windup,
			_specialist_config().secondary_active_duration,
			_specialist_config().secondary_recovery
		)
		_secondary_cooldown = _specialist_config().secondary_cooldown
		return
	if distance_x <= config.attack_range:
		_start_action(_specialist_config().primary_action, config.attack_damage, config.attack_windup, config.attack_active_duration, config.attack_recovery)
		return
	if not _specialist_config().airborne and not can_advance(direction):
		velocity.x = 0.0
		return
	velocity.x = move_toward(velocity.x, direction * config.chase_speed, config.ground_acceleration * delta)
	play_animation(&"walk")


func _process_turn(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		if has_valid_target():
			set_facing_direction(signf(target.global_position.x - global_position.x))
		transition_state(APPROACH)
		play_animation(&"walk")


func _process_reaction(delta: float, staggered: bool) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		if staggered:
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
	if not (active_action in [&"spectral_dash", &"dive"] and attack_phase == &"Active"):
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
		_spawn_projectiles()
	elif _is_field_action(active_action):
		_spawn_field()
	else:
		var selected: HitboxComponent = secondary_hitbox if active_action == _specialist_config().secondary_action else primary_hitbox
		selected.attack_kind = StringName("enemy_%s" % active_action)
		selected.begin_attack(current_attack_id, action_damage, facing_direction, self)
		if active_action in [&"spectral_dash", &"dive"]:
			velocity.x = facing_direction * (220.0 if active_action == &"spectral_dash" else 250.0)
		attack_window_changed.emit(true)


func _is_projectile_action(action: StringName) -> bool:
	return action in [&"silent_wave", &"crescent_hymn", &"shard_volley", &"ink_lance", &"binding_script"] and _specialist_config().archetype in [
		Chapter03SpecialistConfig.Archetype.SILENT_CHORISTER,
		Chapter03SpecialistConfig.Archetype.STAINED_GLASS_SERAPH,
		Chapter03SpecialistConfig.Archetype.THIRTEENTH_SCRIBE,
	]


func _is_field_action(action: StringName) -> bool:
	return action in [&"smoke_release", &"hush_field", &"thirteenth_seal"]


func _spawn_projectiles() -> void:
	if projectile_scene == null or not has_valid_target():
		return
	var count: int = 3 if active_action == &"shard_volley" else 1
	_shared_volley_ledger = {}
	for index: int in range(count):
		var projectile: Chapter03EnemyProjectile = projectile_scene.instantiate() as Chapter03EnemyProjectile
		if projectile == null:
			continue
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = global_position + Vector2(facing_direction * 22.0, -8.0)
		var base_direction: Vector2 = (target.global_position - projectile.global_position).normalized()
		var angle_offset: float = deg_to_rad(float(index - 1) * 11.0) if count == 3 else 0.0
		projectile.lifetime = _specialist_config().projectile_lifetime
		projectile.slow_multiplier = _specialist_config().movement_slow_multiplier
		projectile.slow_duration = _specialist_config().movement_slow_duration
		projectile.launch(
			base_direction.rotated(angle_offset), _specialist_config().projectile_speed,
			action_damage, current_attack_id, self, active_action, _shared_volley_ledger
		)


func _spawn_field() -> void:
	if field_scene == null:
		return
	var field: Chapter03TimedField = field_scene.instantiate() as Chapter03TimedField
	if field == null:
		return
	field.damage = action_damage
	field.duration = _specialist_config().special_duration
	field.stamina_multiplier = _specialist_config().support_multiplier
	if active_action == &"hush_field":
		field.mode = Chapter03TimedField.Mode.HUSH
	elif active_action == &"thirteenth_seal":
		field.mode = Chapter03TimedField.Mode.SEAL
	else:
		field.mode = Chapter03TimedField.Mode.DAMAGE
	get_tree().current_scene.add_child(field)
	if active_action == &"hush_field":
		field.global_position = global_position
	elif active_action == &"thirteenth_seal":
		field.global_position = target.global_position if has_valid_target() else global_position
	else:
		field.global_position = global_position + Vector2(facing_direction * 34.0, 16.0)
	_spawned_fields.append(field)
	field.tree_exiting.connect(func() -> void: _spawned_fields.erase(field))


func enter_death() -> void:
	for field: Chapter03TimedField in _spawned_fields.duplicate():
		if is_instance_valid(field):
			field.queue_free()
	_spawned_fields.clear()
	super.enter_death()


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	if hitbox == null or is_dead():
		return
	var impact: int = _specialist_config().dash_attack_poise_damage if hitbox.attack_kind == &"dash_attack" else _specialist_config().normal_attack_poise_damage
	if not poise_component.apply_impact(impact):
		return
	_poise_broken_this_hit = true
	_on_attack_cancelled()
	transition_state(STAGGER)
	state_timer = _specialist_config().stagger_duration
	velocity.x = 0.0
	play_animation(&"stagger", true)


func _on_hurtbox_hit_received(_damage: int, source_position: Vector2, _attack_id: int) -> void:
	if is_dead() or _poise_broken_this_hit:
		_poise_broken_this_hit = false
		return
	if current_state == STAGGER:
		return
	if _specialist_config().protected_active_frames and attack_phase == &"Active":
		return
	_on_attack_cancelled()
	transition_state(LIGHT_HIT)
	state_timer = config.hurt_duration
	velocity.x = signf(global_position.x - source_position.x) * config.knockback_speed * 0.35
	play_animation(&"light_hit", true)


func _enter_alert() -> void:
	transition_state(ALERT)
	state_timer = _specialist_config().alert_duration
	velocity.x = 0.0
	play_animation(&"alert", true)


func _enter_hidden() -> void:
	_hidden = true
	transition_state(HIDDEN)
	state_timer = _specialist_config().hidden_duration
	velocity = Vector2.ZERO
	hurtbox.set_enabled(false)
	play_animation(&"hidden", true)


func _validate_target() -> bool:
	if not has_valid_target():
		clear_target()
		transition_state(PATROL)
		play_animation(&"walk")
		return false
	var offset: Vector2 = target.global_position - global_position
	if offset.length() > config.lose_target_range:
		clear_target()
		transition_state(PATROL)
		play_animation(&"walk")
		return false
	return true


func _end_hitboxes() -> void:
	if primary_hitbox != null:
		primary_hitbox.end_attack()
	if secondary_hitbox != null:
		secondary_hitbox.end_attack()
	attack_window_changed.emit(false)


func _on_attack_cancelled() -> void:
	_end_hitboxes()
	attack_phase = &"None"
	active_action = &""
	super._on_attack_cancelled()


func is_attack_window_active() -> bool:
	return (primary_hitbox != null and primary_hitbox.is_active) or (secondary_hitbox != null and secondary_hitbox.is_active)


func get_attack_phase_name() -> StringName:
	return attack_phase


func get_active_projectile_count() -> int:
	return get_tree().get_nodes_in_group("chapter_03_enemy_projectile").size()


func get_debug_summary() -> String:
	return "%s %s HP %d/%d POISE %d/%d ACTION %s/%s WARD %s" % [
		get_enemy_type_name(), current_state, health_component.current_health,
		health_component.max_health, poise_component.current_poise,
		_specialist_config().max_poise, active_action, attack_phase,
		("ON" if ward_policy != null and ward_policy.ward_active else "OFF"),
	]


func _specialist_config() -> Chapter03SpecialistConfig:
	return config as Chapter03SpecialistConfig
