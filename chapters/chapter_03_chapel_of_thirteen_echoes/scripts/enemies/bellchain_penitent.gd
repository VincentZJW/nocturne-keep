class_name BellchainPenitent
extends GroundEnemyBase

## Bell-and-chain pressure unit. Each attack owns one locked direction, one
## active window, and one unique attack id.

const ALERT: StringName = &"Alert"
const APPROACH: StringName = &"Approach"
const TURN: StringName = &"Turn"
const LIGHT_HIT: StringName = &"LightHitReaction"
const STAGGER: StringName = &"Stagger"

const CHAIN_LASH: StringName = &"chain_lash"
const BELL_SLAM: StringName = &"bell_slam"
const CHAIN_PULL: StringName = &"chain_pull"

@export_node_path("HitboxComponent") var chain_lash_hitbox_path: NodePath = NodePath(
	"FacingRoot/ChainLashHitbox"
)
@export_node_path("HitboxComponent") var bell_slam_hitbox_path: NodePath = NodePath(
	"FacingRoot/BellSlamHitbox"
)
@export_node_path("HitboxComponent") var chain_pull_hitbox_path: NodePath = NodePath(
	"FacingRoot/ChainPullHitbox"
)
@export_node_path("Chapter03PoiseComponent") var poise_component_path: NodePath = NodePath(
	"PoiseComponent"
)

@onready var chain_lash_hitbox: HitboxComponent = get_node_or_null(
	chain_lash_hitbox_path
) as HitboxComponent
@onready var bell_slam_hitbox: HitboxComponent = get_node_or_null(
	bell_slam_hitbox_path
) as HitboxComponent
@onready var chain_pull_hitbox: HitboxComponent = get_node_or_null(
	chain_pull_hitbox_path
) as HitboxComponent
@onready var poise_component: Chapter03PoiseComponent = get_node_or_null(
	poise_component_path
) as Chapter03PoiseComponent

var attack_phase: StringName = &"None"
var active_action: StringName = &""
var action_timer: float = 0.0
var action_damage: int = 0
var action_active_duration: float = 0.0
var action_recovery: float = 0.0
var current_attack_id: int = 0
var poise_current: int:
	get:
		return poise_component.current_poise if poise_component != null else 0

var _next_attack_id: int = 1
var _chain_pull_cooldown_timer: float = 0.0
var _poise_broken_this_hit: bool = false


func _on_common_ready() -> void:
	if (
		chain_lash_hitbox == null or bell_slam_hitbox == null
		or chain_pull_hitbox == null or poise_component == null
	):
		push_error("Bellchain Penitent requires three hitboxes and PoiseComponent")
		set_physics_process(false)
		return
	_end_all_hitboxes()
	poise_component.configure(
		_bell_config().max_poise, _bell_config().poise_recovery_delay
	)
	hurtbox.hit_resolving.connect(_on_hit_resolving)
	chain_pull_hitbox.hit_confirmed.connect(_on_chain_pull_confirmed)


func _process_enemy_state(delta: float) -> void:
	_chain_pull_cooldown_timer = maxf(0.0, _chain_pull_cooldown_timer - delta)
	_update_poise(delta)
	if attack_phase != &"None":
		_process_action(delta)
		return
	match current_state:
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
			_process_light_hit(delta)
		STAGGER:
			_process_stagger(delta)


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
	if reached_patrol_boundary() or not can_advance(facing_direction):
		set_facing_direction(-facing_direction)
		transition_state(IDLE)
		state_timer = config.patrol_turn_pause
		velocity.x = 0.0
		play_animation(&"idle")
		return
	velocity.x = move_toward(
		velocity.x, facing_direction * config.patrol_speed, config.ground_acceleration * delta
	)


func _process_alert(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		_enter_approach()


func _process_approach(delta: float) -> void:
	if not _validate_target():
		return
	var offset: Vector2 = target.global_position - global_position
	var direction: float = signf(offset.x)
	var distance_x: float = absf(offset.x)
	if direction != facing_direction:
		transition_state(TURN)
		state_timer = _bell_config().turn_duration
		velocity.x = 0.0
		play_animation(&"turn", true)
		return
	set_facing_direction(direction)
	if distance_x <= _bell_config().bell_slam_range and _next_attack_id % 2 == 0:
		_start_attack(
			BELL_SLAM,
			_bell_config().bell_slam_damage,
			_bell_config().bell_slam_windup,
			_bell_config().bell_slam_active_duration,
			_bell_config().bell_slam_recovery
		)
		return
	if (
		_chain_pull_cooldown_timer <= 0.0
		and distance_x >= _bell_config().chain_pull_min_range
		and distance_x <= _bell_config().chain_pull_max_range
	):
		_start_attack(
			CHAIN_PULL,
			_bell_config().chain_pull_damage,
			_bell_config().chain_pull_windup,
			_bell_config().chain_pull_active_duration,
			_bell_config().chain_pull_recovery
		)
		_chain_pull_cooldown_timer = _bell_config().chain_pull_cooldown
		return
	if distance_x <= config.attack_range:
		_start_attack(
			CHAIN_LASH,
			config.attack_damage,
			config.attack_windup,
			config.attack_active_duration,
			config.attack_recovery
		)
		return
	if not can_advance(direction):
		velocity.x = 0.0
		return
	velocity.x = move_toward(
		velocity.x, direction * config.chase_speed, config.ground_acceleration * delta
	)
	play_animation(&"walk")


func _process_turn(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0:
		return
	if has_valid_target():
		set_facing_direction(signf(target.global_position.x - global_position.x))
	_enter_approach()


func _process_light_hit(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		_enter_approach()


func _process_stagger(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		poise_component.reset_to_full()
		_enter_approach()


func _start_attack(
	action: StringName, damage: int, windup: float, active_duration: float, recovery: float
) -> void:
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
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	action_timer = maxf(0.0, action_timer - delta)
	if action_timer > 0.0:
		return
	match attack_phase:
		&"Windup":
			_begin_active_window()
		&"Active":
			_end_all_hitboxes()
			attack_phase = &"Recovery"
			action_timer = action_recovery
			transition_state(StringName("%sRecovery" % active_action))
			play_animation(StringName("%s_recovery" % active_action), true)
		&"Recovery":
			attack_phase = &"None"
			active_action = &""
			_enter_approach()


func _begin_active_window() -> void:
	attack_phase = &"Active"
	action_timer = action_active_duration
	current_attack_id = _next_attack_id
	_next_attack_id += 1
	var selected: HitboxComponent = _get_hitbox_for_action(active_action)
	selected.attack_kind = StringName("enemy_%s" % active_action)
	selected.begin_attack(current_attack_id, action_damage, facing_direction, self)
	transition_state(StringName("%sActive" % active_action))
	play_animation(StringName("%s_active" % active_action), true)
	attack_window_changed.emit(true)


func _on_target_acquired() -> void:
	_enter_alert()


func _enter_alert() -> void:
	if is_dead():
		return
	transition_state(ALERT)
	state_timer = _bell_config().alert_duration
	velocity.x = 0.0
	play_animation(&"alert", true)


func _enter_approach() -> void:
	if is_dead():
		return
	transition_state(APPROACH if has_valid_target() else PATROL)
	play_animation(&"walk")


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


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	if hitbox == null or is_dead():
		return
	var poise_damage: int = (
		_bell_config().dash_attack_poise_damage
		if hitbox.attack_kind == &"dash_attack"
		else _bell_config().normal_attack_poise_damage
	)
	if not poise_component.apply_impact(poise_damage):
		return
	_poise_broken_this_hit = true
	_on_attack_cancelled()
	transition_state(STAGGER)
	state_timer = _bell_config().stagger_duration
	velocity.x = 0.0
	play_animation(&"stagger", true)


func _on_hurtbox_hit_received(_damage: int, source_position: Vector2, _attack_id: int) -> void:
	if is_dead():
		return
	if _poise_broken_this_hit:
		_poise_broken_this_hit = false
		return
	if current_state == STAGGER:
		return
	if attack_phase == &"Windup":
		_on_attack_cancelled()
		_enter_light_hit(source_position)
		return
	if attack_phase in [&"Active", &"Recovery"]:
		return
	_enter_light_hit(source_position)


func _enter_light_hit(source_position: Vector2) -> void:
	transition_state(LIGHT_HIT)
	var knockback_direction: float = signf(global_position.x - source_position.x)
	if is_zero_approx(knockback_direction):
		knockback_direction = -facing_direction
	velocity.x = knockback_direction * config.knockback_speed * 0.45
	state_timer = _bell_config().light_hit_duration
	play_animation(&"light_hit", true)


func _on_chain_pull_confirmed(
	target_hurtbox: HurtboxComponent, _damage: int, _attack_id: int
) -> void:
	var pulled_player: Player = target_hurtbox.get_parent() as Player
	if pulled_player == null or pulled_player.is_dead():
		return
	if absf(pulled_player.global_position.y - global_position.y) > config.platform_height_tolerance:
		return
	var toward_penitent: float = signf(global_position.x - pulled_player.global_position.x)
	pulled_player.velocity.x = toward_penitent * _bell_config().chain_pull_speed


func _update_poise(delta: float) -> void:
	poise_component.advance(delta, current_state == STAGGER)


func _get_hitbox_for_action(action: StringName) -> HitboxComponent:
	match action:
		BELL_SLAM:
			return bell_slam_hitbox
		CHAIN_PULL:
			return chain_pull_hitbox
		_:
			return chain_lash_hitbox


func _end_all_hitboxes() -> void:
	if chain_lash_hitbox != null:
		chain_lash_hitbox.end_attack()
	if bell_slam_hitbox != null:
		bell_slam_hitbox.end_attack()
	if chain_pull_hitbox != null:
		chain_pull_hitbox.end_attack()
	attack_window_changed.emit(false)


func _on_attack_cancelled() -> void:
	_end_all_hitboxes()
	attack_phase = &"None"
	active_action = &""
	super._on_attack_cancelled()


func _recover_from_hurt() -> void:
	_enter_approach()


func is_attack_window_active() -> bool:
	return (
		(chain_lash_hitbox != null and chain_lash_hitbox.is_active)
		or (bell_slam_hitbox != null and bell_slam_hitbox.is_active)
		or (chain_pull_hitbox != null and chain_pull_hitbox.is_active)
	)


func get_attack_phase_name() -> StringName:
	return attack_phase


func get_debug_summary() -> String:
	return "%s  %s  HP %d/%d  POISE %d/%d  ACTION %s/%s  DMG %d  PULL CD %.2f" % [
		get_enemy_type_name(), current_state, health_component.current_health,
		health_component.max_health, poise_current, _bell_config().max_poise,
		active_action, attack_phase, action_damage, _chain_pull_cooldown_timer,
	]


func _bell_config() -> BellchainPenitentConfig:
	return config as BellchainPenitentConfig
