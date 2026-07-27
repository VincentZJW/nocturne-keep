class_name SilentCourtGroundEnemy
extends GroundEnemyBase

## Four-role Chapter II ground prototype. Shared locomotion/combat lifecycle stays in
## GroundEnemyBase; this script owns only role selection and bounded attack cadence.

const ALERT: StringName = &"Alert"
const APPROACH: StringName = &"Approach"
const TURN: StringName = &"Turn"
const RETREAT: StringName = &"Retreat"
const RECOVERY: StringName = &"Recovery"
const STAGGER: StringName = &"Stagger"
const BUFF_CHANNEL: StringName = &"BuffChannel"

@export_node_path("HitboxComponent") var primary_hitbox_path: NodePath = NodePath("FacingRoot/PrimaryHitbox")
@export_node_path("HitboxComponent") var secondary_hitbox_path: NodePath = NodePath("FacingRoot/SecondaryHitbox")
@export_node_path("Marker2D") var muzzle_path: NodePath = NodePath("FacingRoot/Muzzle")
@export var projectile_scene: PackedScene

@onready var primary_hitbox: HitboxComponent = get_node_or_null(primary_hitbox_path) as HitboxComponent
@onready var secondary_hitbox: HitboxComponent = get_node_or_null(secondary_hitbox_path) as HitboxComponent
@onready var muzzle: Marker2D = get_node_or_null(muzzle_path) as Marker2D

var attack_phase: StringName = &"None"
var active_action: StringName = &""
var action_timer: float = 0.0
var action_damage: int = 0
var action_windup: float = 0.0
var action_active: float = 0.0
var action_recovery: float = 0.0
var current_attack_id: int = 0
var _next_attack_id: int = 1
var _combo_second_pending: bool = false
var poise_current: int = 0
var windup_multiplier: float = 1.0
var _buff_source_id: int = 0
var _buff_target: SilentCourtGroundEnemy
var active_projectiles: int = 0
var _last_resolving_hitbox: HitboxComponent
var _poise_broken_this_hit: bool = false


func _on_common_ready() -> void:
	if primary_hitbox == null or secondary_hitbox == null:
		push_error("%s requires PrimaryHitbox and SecondaryHitbox" % get_enemy_type_name())
		set_physics_process(false)
		return
	primary_hitbox.end_attack()
	secondary_hitbox.end_attack()
	poise_current = (config as SilentCourtEnemyConfig).poise_max
	hurtbox.hit_resolving.connect(_on_hit_resolving)
	var policy: MourningArmorHitPolicy = hurtbox.hit_policy as MourningArmorHitPolicy
	if policy != null:
		policy.poise_impact.connect(_on_poise_impact)


func _process_enemy_state(delta: float) -> void:
	_update_support_buff()
	if _is_action_state():
		_process_action(delta)
		return
	match current_state:
		IDLE:
			_process_idle(delta)
		PATROL:
			_process_patrol(delta)
		CHASE, APPROACH:
			_process_approach(delta)
		TURN:
			_process_turn(delta)
		RETREAT:
			_process_retreat(delta)
		STAGGER:
			_process_stagger(delta)
		BUFF_CHANNEL:
			_process_buff_channel(delta)


func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	if has_valid_target():
		_enter_approach()
		return
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		transition_state(PATROL)
		play_animation(&"walk")


func _process_patrol(delta: float) -> void:
	if has_valid_target():
		_enter_approach()
		return
	if reached_patrol_boundary() or not can_advance(facing_direction):
		set_facing_direction(-facing_direction)
		transition_state(IDLE)
		state_timer = config.patrol_turn_pause
		velocity.x = 0.0
		play_animation(&"idle")
		return
	velocity.x = move_toward(velocity.x, facing_direction * config.patrol_speed, config.ground_acceleration * delta)


func _process_approach(delta: float) -> void:
	if not _validate_target():
		return
	var role_config: SilentCourtEnemyConfig = config as SilentCourtEnemyConfig
	var offset: Vector2 = target.global_position - global_position
	var direction: float = signf(offset.x)
	var distance_x: float = absf(offset.x)
	if role_config.archetype in [SilentCourtEnemyConfig.Archetype.COURT_HALBERDIER, SilentCourtEnemyConfig.Archetype.MOURNING_ARMOR] and direction != facing_direction:
		transition_state(TURN)
		state_timer = role_config.turn_duration
		velocity.x = 0.0
		play_animation(&"turn", true)
		return
	set_facing_direction(direction)
	if role_config.archetype == SilentCourtEnemyConfig.Archetype.BLOOD_CANDLE_ACOLYTE:
		if distance_x < role_config.close_range:
			transition_state(RETREAT)
			play_animation(&"walk")
			return
		if distance_x <= config.attack_range:
			if _find_buff_candidate() != null and _buff_target == null:
				transition_state(BUFF_CHANNEL)
				state_timer = role_config.buff_channel_duration
				velocity.x = 0.0
				play_animation(&"buff_channel", true)
			else:
				_start_attack(&"cast", config.attack_damage, config.attack_windup, config.attack_active_duration, config.attack_recovery)
			return
	else:
		if distance_x <= config.attack_range:
			_choose_melee_attack(distance_x)
			return
	if not can_advance(direction):
		velocity.x = 0.0
		return
	velocity.x = move_toward(velocity.x, direction * config.chase_speed, config.ground_acceleration * delta)
	play_animation(&"walk")


func _process_turn(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0:
		return
	if has_valid_target():
		set_facing_direction(signf(target.global_position.x - global_position.x))
	_enter_approach()


func _process_retreat(delta: float) -> void:
	if not _validate_target():
		return
	var role_config: SilentCourtEnemyConfig = config as SilentCourtEnemyConfig
	var offset: Vector2 = target.global_position - global_position
	if absf(offset.x) >= role_config.retreat_distance:
		_enter_approach()
		return
	var direction: float = -signf(offset.x)
	set_facing_direction(signf(offset.x))
	if not can_advance(direction):
		velocity.x = 0.0
		_enter_approach()
		return
	velocity.x = move_toward(velocity.x, direction * config.chase_speed, config.ground_acceleration * delta)


func _process_stagger(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		poise_current = (config as SilentCourtEnemyConfig).poise_max
		_enter_approach()


func _process_buff_channel(delta: float) -> void:
	velocity.x = 0.0
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0:
		return
	var candidate: SilentCourtGroundEnemy = _find_buff_candidate()
	if candidate != null:
		_apply_buff(candidate)
	_enter_approach()


func _choose_melee_attack(distance_x: float) -> void:
	var role_config: SilentCourtEnemyConfig = config as SilentCourtEnemyConfig
	match role_config.archetype:
		SilentCourtEnemyConfig.Archetype.HOLLOW_RETAINER:
			if _next_attack_id % 2 == 0:
				_start_attack(&"combo", role_config.secondary_damage, role_config.secondary_windup, role_config.secondary_active_duration, role_config.secondary_recovery, true)
			else:
				_start_attack(&"single_stab", config.attack_damage, config.attack_windup, config.attack_active_duration, config.attack_recovery)
		SilentCourtEnemyConfig.Archetype.COURT_HALBERDIER:
			if distance_x <= role_config.close_range:
				_start_attack(&"shaft_push", role_config.tertiary_damage, 0.24, 0.08, 0.42, false, true)
			elif _next_attack_id % 2 == 0:
				_start_attack(&"sweep", role_config.secondary_damage, role_config.secondary_windup, role_config.secondary_active_duration, role_config.secondary_recovery)
			else:
				_start_attack(&"thrust", config.attack_damage, config.attack_windup, config.attack_active_duration, config.attack_recovery)
		SilentCourtEnemyConfig.Archetype.MOURNING_ARMOR:
			var selector: int = _next_attack_id % 3
			if selector == 0:
				_start_attack(&"shoulder_bash", role_config.secondary_damage, 0.42, 0.10, 0.58, false, true)
			elif selector == 1:
				_start_attack(&"heavy_sweep", role_config.tertiary_damage, role_config.secondary_windup, role_config.secondary_active_duration, role_config.secondary_recovery)
			else:
				_start_attack(&"overhead", config.attack_damage, config.attack_windup, config.attack_active_duration, config.attack_recovery)


func _start_attack(
	action_name: StringName,
	damage: int,
	windup: float,
	active_duration: float,
	recovery: float,
	combo: bool = false,
	use_secondary_hitbox: bool = false
) -> void:
	active_action = action_name
	action_damage = damage
	action_windup = windup * windup_multiplier
	action_active = active_duration
	action_recovery = recovery
	_combo_second_pending = combo
	attack_phase = &"Windup"
	action_timer = action_windup
	velocity.x = 0.0
	transition_state(StringName("%sWindup" % action_name))
	play_animation(StringName("attack_%s" % action_name), true)
	secondary_hitbox.set_meta("selected", use_secondary_hitbox)


func _process_action(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	action_timer = maxf(0.0, action_timer - delta)
	if action_timer > 0.0:
		return
	match attack_phase:
		&"Windup":
			_begin_active_window()
		&"Active":
			_end_active_window()
			if _combo_second_pending:
				attack_phase = &"ComboGap"
				action_timer = (config as SilentCourtEnemyConfig).combo_gap
				transition_state(&"ComboGap")
			else:
				_begin_recovery()
		&"ComboGap":
			_combo_second_pending = false
			action_damage = (config as SilentCourtEnemyConfig).tertiary_damage
			_begin_active_window()
		&"Recovery":
			_finish_action()


func _begin_active_window() -> void:
	attack_phase = &"Active"
	action_timer = action_active
	current_attack_id = _next_attack_id
	_next_attack_id += 1
	var selected: HitboxComponent = secondary_hitbox if bool(secondary_hitbox.get_meta("selected", false)) else primary_hitbox
	selected.attack_kind = StringName("enemy_%s" % active_action)
	selected.begin_attack(current_attack_id, action_damage, facing_direction, self)
	transition_state(StringName("%sActive" % active_action))
	attack_window_changed.emit(true)
	if active_action == &"cast":
		_spawn_projectile()


func _end_active_window() -> void:
	primary_hitbox.end_attack()
	secondary_hitbox.end_attack()
	attack_window_changed.emit(false)


func _begin_recovery() -> void:
	attack_phase = &"Recovery"
	action_timer = action_recovery
	transition_state(RECOVERY)


func _finish_action() -> void:
	attack_phase = &"None"
	active_action = &""
	_combo_second_pending = false
	secondary_hitbox.set_meta("selected", false)
	_enter_approach()


func _is_action_state() -> bool:
	return attack_phase != &"None"


func _on_target_acquired() -> void:
	transition_state(ALERT)
	state_timer = 0.10
	play_animation(&"alert", true)
	call_deferred("_enter_approach")


func _enter_approach() -> void:
	if is_dead():
		return
	transition_state(APPROACH if has_valid_target() else PATROL)
	play_animation(&"walk")


func _on_attack_cancelled() -> void:
	_end_active_window()
	attack_phase = &"None"
	active_action = &""
	_combo_second_pending = false
	super._on_attack_cancelled()


func _on_hurtbox_hit_received(_damage: int, source_position: Vector2, _attack_id: int) -> void:
	var role_config: SilentCourtEnemyConfig = config as SilentCourtEnemyConfig
	if current_state == STAGGER or _poise_broken_this_hit:
		_poise_broken_this_hit = false
		return
	if role_config.archetype == SilentCourtEnemyConfig.Archetype.HOLLOW_RETAINER and attack_phase == &"Active":
		return
	if role_config.archetype == SilentCourtEnemyConfig.Archetype.MOURNING_ARMOR and _is_action_state() and poise_current > 0:
		return
	enter_hurt(source_position)


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	_last_resolving_hitbox = hitbox


func _on_poise_impact(amount: int, _attack_kind: StringName) -> void:
	poise_current = maxi(0, poise_current - amount)
	if poise_current > 0 or is_dead():
		return
	_poise_broken_this_hit = true
	_on_attack_cancelled()
	transition_state(STAGGER)
	state_timer = (config as SilentCourtEnemyConfig).stagger_duration
	velocity.x = 0.0
	play_animation(&"stagger", true)


func _recover_from_hurt() -> void:
	_enter_approach()


func _validate_target() -> bool:
	if not has_valid_target():
		clear_target()
		_enter_approach()
		return false
	var offset: Vector2 = target.global_position - global_position
	if offset.length() > config.lose_target_range or absf(offset.y) > config.platform_height_tolerance:
		clear_target()
		_enter_approach()
		return false
	return true


func _spawn_projectile() -> void:
	if projectile_scene == null or muzzle == null or get_parent() == null:
		return
	var projectile: BloodCandleProjectile = projectile_scene.instantiate() as BloodCandleProjectile
	if projectile == null:
		push_error("Blood-Candle projectile scene has wrong root type")
		return
	get_parent().add_child(projectile)
	projectile.global_position = muzzle.global_position
	var role_config: SilentCourtEnemyConfig = config as SilentCourtEnemyConfig
	projectile.initialize(facing_direction, role_config.projectile_speed, config.attack_damage, role_config.projectile_lifetime, role_config.ember_damage, role_config.ember_lifetime)
	active_projectiles += 1
	projectile.tree_exited.connect(_on_projectile_exited)


func _on_projectile_exited() -> void:
	active_projectiles = maxi(0, active_projectiles - 1)


func _find_buff_candidate() -> SilentCourtGroundEnemy:
	var role_config: SilentCourtEnemyConfig = config as SilentCourtEnemyConfig
	var best: SilentCourtGroundEnemy
	var best_distance: float = role_config.buff_radius
	for sibling: Node in get_parent().get_children():
		var candidate: SilentCourtGroundEnemy = sibling as SilentCourtGroundEnemy
		if candidate == null or candidate == self or candidate.is_dead():
			continue
		if (candidate.config as SilentCourtEnemyConfig).archetype == SilentCourtEnemyConfig.Archetype.BLOOD_CANDLE_ACOLYTE:
			continue
		var distance: float = global_position.distance_to(candidate.global_position)
		if distance < best_distance:
			best = candidate
			best_distance = distance
	return best


func _apply_buff(candidate: SilentCourtGroundEnemy) -> void:
	_clear_buff_target()
	_buff_target = candidate
	_buff_source_id = get_instance_id()
	candidate.set_acolyte_buff(_buff_source_id, (config as SilentCourtEnemyConfig).buff_windup_multiplier)


func _update_support_buff() -> void:
	if _buff_target == null:
		return
	var role_config: SilentCourtEnemyConfig = config as SilentCourtEnemyConfig
	if not is_instance_valid(_buff_target) or is_dead() or global_position.distance_to(_buff_target.global_position) > role_config.buff_radius:
		_clear_buff_target()


func set_acolyte_buff(source_id: int, multiplier: float) -> bool:
	if _buff_source_id != 0 and _buff_source_id != source_id:
		return false
	_buff_source_id = source_id
	windup_multiplier = clampf(multiplier, 0.5, 1.0)
	return true


func clear_acolyte_buff(source_id: int) -> void:
	if _buff_source_id != source_id:
		return
	_buff_source_id = 0
	windup_multiplier = 1.0


func _clear_buff_target() -> void:
	if _buff_target != null and is_instance_valid(_buff_target):
		_buff_target.clear_acolyte_buff(_buff_source_id)
	_buff_target = null
	_buff_source_id = 0


func enter_death() -> void:
	_clear_buff_target()
	super.enter_death()


func is_attack_window_active() -> bool:
	return (primary_hitbox != null and primary_hitbox.is_active) or (secondary_hitbox != null and secondary_hitbox.is_active)


func get_attack_phase_name() -> StringName:
	return attack_phase


func get_active_projectile_count() -> int:
	return active_projectiles


func get_debug_summary() -> String:
	return "%s  %s  HP %d/%d  ANIM %s  ACTION %s/%s  DMG %d  POISE %d  BUFF %.2f  SHOTS %d" % [
		get_enemy_type_name(), current_state, health_component.current_health,
		health_component.max_health, animated_sprite.animation, active_action, attack_phase,
		action_damage, poise_current, windup_multiplier, active_projectiles,
	]
