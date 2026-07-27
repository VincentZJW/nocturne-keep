class_name HollowDuchess
extends CharacterBody2D

## Two-phase ballroom duelist. Explicit states keep telegraph, active and recovery windows auditable.

signal combat_started
signal phase_changed(phase: int)
signal poise_changed(current: int, maximum: int)
signal attack_started(attack_name: StringName)
signal attack_active(attack_name: StringName, attack_id: int)
signal attack_finished(attack_name: StringName)
signal intro_line_requested(text: String)
signal death_line_requested(speaker: String, text: String)
signal boss_defeated

enum State {
	DORMANT,
	INTRO,
	IDLE,
	EVALUATE,
	ELEGANT_APPROACH,
	ELEGANT_RETREAT,
	TURN,
	SIDE_STEP,
	BACKSTEP,
	RAPIER_THRUST_WINDUP,
	RAPIER_THRUST_ACTIVE,
	RAPIER_THRUST_RECOVERY,
	FAN_SLASH_WINDUP,
	FAN_SLASH_ACTIVE,
	FAN_SLASH_RECOVERY,
	BACKSTEP_RIPOSTE_PREPARE,
	BACKSTEP_RIPOSTE_WINDUP,
	BACKSTEP_RIPOSTE_ACTIVE,
	BACKSTEP_RIPOSTE_RECOVERY,
	SIDE_STEP_CUT_PREPARE,
	SIDE_STEP_CUT_WINDUP,
	SIDE_STEP_CUT_ACTIVE,
	SIDE_STEP_CUT_RECOVERY,
	PHASE_TRANSITION,
	DOUBLE_LUNGE_WINDUP,
	DOUBLE_LUNGE_HIT_1,
	DOUBLE_LUNGE_GAP,
	DOUBLE_LUNGE_HIT_2,
	DOUBLE_LUNGE_RECOVERY,
	PHANTOM_DANCE_PREPARE,
	PHANTOM_DANCE_ACTIVE,
	PHANTOM_DANCE_RECOVERY,
	FINAL_WALTZ_PREPARE,
	FINAL_WALTZ_ACTIVE,
	FINAL_WALTZ_RECOVERY,
	LIGHT_HIT_REACTION,
	STAGGER,
	DEATH,
}

const STATE_NAMES: Dictionary[State, StringName] = {
	State.DORMANT: &"Dormant",
	State.INTRO: &"Intro",
	State.IDLE: &"Idle",
	State.EVALUATE: &"Evaluate",
	State.ELEGANT_APPROACH: &"ElegantApproach",
	State.ELEGANT_RETREAT: &"ElegantRetreat",
	State.TURN: &"Turn",
	State.SIDE_STEP: &"SideStep",
	State.BACKSTEP: &"Backstep",
	State.RAPIER_THRUST_WINDUP: &"RapierThrustWindup",
	State.RAPIER_THRUST_ACTIVE: &"RapierThrustActive",
	State.RAPIER_THRUST_RECOVERY: &"RapierThrustRecovery",
	State.FAN_SLASH_WINDUP: &"FanSlashWindup",
	State.FAN_SLASH_ACTIVE: &"FanSlashActive",
	State.FAN_SLASH_RECOVERY: &"FanSlashRecovery",
	State.BACKSTEP_RIPOSTE_PREPARE: &"BackstepRipostePrepare",
	State.BACKSTEP_RIPOSTE_WINDUP: &"BackstepRiposteWindup",
	State.BACKSTEP_RIPOSTE_ACTIVE: &"BackstepRiposteActive",
	State.BACKSTEP_RIPOSTE_RECOVERY: &"BackstepRiposteRecovery",
	State.SIDE_STEP_CUT_PREPARE: &"SideStepCutPrepare",
	State.SIDE_STEP_CUT_WINDUP: &"SideStepCutWindup",
	State.SIDE_STEP_CUT_ACTIVE: &"SideStepCutActive",
	State.SIDE_STEP_CUT_RECOVERY: &"SideStepCutRecovery",
	State.PHASE_TRANSITION: &"PhaseTransition",
	State.DOUBLE_LUNGE_WINDUP: &"DoubleLungeWindup",
	State.DOUBLE_LUNGE_HIT_1: &"DoubleLungeHit1",
	State.DOUBLE_LUNGE_GAP: &"DoubleLungeGap",
	State.DOUBLE_LUNGE_HIT_2: &"DoubleLungeHit2",
	State.DOUBLE_LUNGE_RECOVERY: &"DoubleLungeRecovery",
	State.PHANTOM_DANCE_PREPARE: &"PhantomDancePrepare",
	State.PHANTOM_DANCE_ACTIVE: &"PhantomDanceActive",
	State.PHANTOM_DANCE_RECOVERY: &"PhantomDanceRecovery",
	State.FINAL_WALTZ_PREPARE: &"FinalWaltzPrepare",
	State.FINAL_WALTZ_ACTIVE: &"FinalWaltzActive",
	State.FINAL_WALTZ_RECOVERY: &"FinalWaltzRecovery",
	State.LIGHT_HIT_REACTION: &"LightHitReaction",
	State.STAGGER: &"Stagger",
	State.DEATH: &"Death",
}

const ATTACK_RAPIER: StringName = &"rapier_thrust"
const ATTACK_FAN: StringName = &"fan_slash"
const ATTACK_RIPOSTE: StringName = &"backstep_riposte"
const ATTACK_SIDE_CUT: StringName = &"side_step_cut"
const ATTACK_DOUBLE: StringName = &"double_waltz_lunge"
const ATTACK_PHANTOM: StringName = &"phantom_dancer_sweep"
const ATTACK_FINAL: StringName = &"final_waltz_crossing"

@export var config: HollowDuchessConfig
@export var phantom_route_scene: PackedScene
@export_node_path("AnimatedSprite2D") var sprite_path: NodePath = NodePath("VisualRoot/AnimatedSprite2D")
@export_node_path("Node2D") var facing_root_path: NodePath = NodePath("FacingRoot")
@export_node_path("HealthComponent") var health_path: NodePath = NodePath("HealthComponent")
@export_node_path("HurtboxComponent") var hurtbox_path: NodePath = NodePath("Hurtbox")
@export_node_path("Line2D") var route_telegraph_path: NodePath = NodePath("RouteTelegraph")

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(sprite_path) as AnimatedSprite2D
@onready var facing_root: Node2D = get_node_or_null(facing_root_path) as Node2D
@onready var health_component: HealthComponent = get_node_or_null(health_path) as HealthComponent
@onready var hurtbox: HurtboxComponent = get_node_or_null(hurtbox_path) as HurtboxComponent
@onready var route_telegraph: Line2D = get_node_or_null(route_telegraph_path) as Line2D
@onready var rapier_hitbox: HitboxComponent = %RapierThrustHitbox as HitboxComponent
@onready var fan_hitbox: HitboxComponent = %FanSlashHitbox as HitboxComponent
@onready var riposte_hitbox: HitboxComponent = %RiposteHitbox as HitboxComponent
@onready var side_cut_hitbox: HitboxComponent = %SideStepCutHitbox as HitboxComponent
@onready var double_hitbox_1: HitboxComponent = %DoubleLungeHitbox1 as HitboxComponent
@onready var double_hitbox_2: HitboxComponent = %DoubleLungeHitbox2 as HitboxComponent
@onready var final_hitbox: HitboxComponent = %FinalWaltzHitbox as HitboxComponent

var _state: State = State.DORMANT
var _state_elapsed: float = 0.0
var _target: Player
var _spawn_position: Vector2 = Vector2.ZERO
var _arena_left: float = 0.0
var _arena_right: float = 0.0
var _facing_direction: float = -1.0
var _turn_target_direction: float = -1.0
var _turn_committed: bool = false
var _phase: int = 1
var _phase_transition_pending: bool = false
var _current_poise: int = 60
var _stagger_protection_remaining: float = 0.0
var _attack_gap_remaining: float = 0.0
var _chain_count: int = 0
var _last_attack: StringName = &""
var _same_attack_count: int = 0
var _current_attack: StringName = &""
var _next_attack_id: int = 1
var _active_attack_id: int = 0
var _riposte_cooldown: float = 0.0
var _side_step_cooldown: float = 0.0
var _phantom_cooldown: float = 0.0
var _final_cooldown: float = 0.0
var _defensive_moves_in_row: int = 0
var _movement_direction: float = 0.0
var _intro_retry: bool = false
var _final_pass_index: int = 0
var _final_pass_direction: float = 1.0
var _final_pass_active: bool = false
var _final_pass_elapsed: float = 0.0
var _last_incoming_attack_kind: StringName = &""
var _light_hit_return_state: State = State.IDLE
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _active_phantoms: Array[DuchessPhantomRoute] = []
var _debug_forced_attack: StringName = &""
var _death_player_line_emitted: bool = false
var _death_boss_line_emitted: bool = false
var _death_passage_line_emitted: bool = false
var _death_echo_line_emitted: bool = false
var _defeat_emitted: bool = false


func _ready() -> void:
	if not _validate_dependencies():
		set_physics_process(false)
		return
	_spawn_position = global_position
	_arena_left = _spawn_position.x + config.arena_left_offset
	_arena_right = _spawn_position.x + config.arena_right_offset
	_rng.seed = 20260727
	health_component.max_health = config.max_health
	health_component.reset_to_full()
	_current_poise = config.max_poise
	hurtbox.hit_resolving.connect(_on_hit_resolving)
	hurtbox.hit_received.connect(_on_hit_received)
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	_disable_all_hitboxes()
	_apply_facing()
	_play_animation(&"idle")
	poise_changed.emit(_current_poise, config.max_poise)


func _physics_process(delta: float) -> void:
	_tick_cooldowns(delta)
	_state_elapsed += delta
	_apply_gravity(delta)
	match _state:
		State.DORMANT:
			velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		State.INTRO:
			_process_intro()
		State.IDLE:
			_process_idle()
		State.EVALUATE:
			_evaluate_next_action()
		State.ELEGANT_APPROACH:
			_process_approach(delta)
		State.ELEGANT_RETREAT:
			_process_retreat(delta)
		State.TURN:
			_process_turn()
		State.SIDE_STEP:
			_process_side_step(delta)
		State.BACKSTEP:
			_process_backstep(delta)
		State.RAPIER_THRUST_WINDUP:
			_timed_transition(config.rapier_thrust_windup, State.RAPIER_THRUST_ACTIVE)
		State.RAPIER_THRUST_ACTIVE:
			_process_lunge_active(delta, config.rapier_thrust_active, State.RAPIER_THRUST_RECOVERY)
		State.RAPIER_THRUST_RECOVERY:
			_finish_attack_after(config.rapier_thrust_recovery)
		State.FAN_SLASH_WINDUP:
			_timed_transition(config.fan_slash_windup, State.FAN_SLASH_ACTIVE)
		State.FAN_SLASH_ACTIVE:
			_timed_transition(config.fan_slash_active, State.FAN_SLASH_RECOVERY)
		State.FAN_SLASH_RECOVERY:
			_finish_attack_after(config.fan_slash_recovery)
		State.BACKSTEP_RIPOSTE_PREPARE:
			_timed_transition(config.pause_after_backstep, State.BACKSTEP_RIPOSTE_WINDUP)
		State.BACKSTEP_RIPOSTE_WINDUP:
			_timed_transition(config.riposte_windup, State.BACKSTEP_RIPOSTE_ACTIVE)
		State.BACKSTEP_RIPOSTE_ACTIVE:
			_process_lunge_active(delta, config.riposte_active, State.BACKSTEP_RIPOSTE_RECOVERY)
		State.BACKSTEP_RIPOSTE_RECOVERY:
			_finish_attack_after(config.riposte_recovery)
		State.SIDE_STEP_CUT_PREPARE:
			_timed_transition(config.side_step_cut_prepare, State.SIDE_STEP_CUT_WINDUP)
		State.SIDE_STEP_CUT_WINDUP:
			_timed_transition(config.side_step_cut_windup, State.SIDE_STEP_CUT_ACTIVE)
		State.SIDE_STEP_CUT_ACTIVE:
			_timed_transition(config.side_step_cut_active, State.SIDE_STEP_CUT_RECOVERY)
		State.SIDE_STEP_CUT_RECOVERY:
			_finish_attack_after(config.side_step_cut_recovery)
		State.PHASE_TRANSITION:
			_process_phase_transition(delta)
		State.DOUBLE_LUNGE_WINDUP:
			_timed_transition(config.double_lunge_windup, State.DOUBLE_LUNGE_HIT_1)
		State.DOUBLE_LUNGE_HIT_1:
			_process_lunge_active(delta, config.double_lunge_hit_1_active, State.DOUBLE_LUNGE_GAP)
		State.DOUBLE_LUNGE_GAP:
			_process_double_lunge_gap()
		State.DOUBLE_LUNGE_HIT_2:
			_process_lunge_active(delta, config.double_lunge_hit_2_active, State.DOUBLE_LUNGE_RECOVERY)
		State.DOUBLE_LUNGE_RECOVERY:
			_finish_attack_after(config.double_lunge_recovery)
		State.PHANTOM_DANCE_PREPARE:
			_timed_transition(config.phantom_telegraph, State.PHANTOM_DANCE_ACTIVE)
		State.PHANTOM_DANCE_ACTIVE:
			_timed_transition(config.phantom_active, State.PHANTOM_DANCE_RECOVERY)
		State.PHANTOM_DANCE_RECOVERY:
			_finish_attack_after(config.phantom_recovery)
		State.FINAL_WALTZ_PREPARE:
			_process_final_prepare(delta)
		State.FINAL_WALTZ_ACTIVE:
			_process_final_active(delta)
		State.FINAL_WALTZ_RECOVERY:
			_finish_attack_after(config.final_waltz_recovery)
		State.LIGHT_HIT_REACTION:
			_process_light_hit()
		State.STAGGER:
			_process_stagger()
		State.DEATH:
			_process_death()
	_clamp_arena_velocity()
	move_and_slide()


func activate(target: Player, retry_intro: bool = false) -> void:
	if target == null or _state != State.DORMANT:
		return
	_target = target
	_intro_retry = retry_intro
	_enter_state(State.INTRO)
	intro_line_requested.emit("你果然回来了。")


func reset_boss() -> void:
	set_physics_process(true)
	_clear_phantoms()
	_disable_all_hitboxes()
	global_position = _spawn_position
	velocity = Vector2.ZERO
	_target = null
	_phase = 1
	_phase_transition_pending = false
	_current_poise = config.max_poise
	_stagger_protection_remaining = 0.0
	_attack_gap_remaining = 0.0
	_chain_count = 0
	_last_attack = &""
	_same_attack_count = 0
	_current_attack = &""
	_riposte_cooldown = 0.0
	_side_step_cooldown = 0.0
	_phantom_cooldown = 0.0
	_final_cooldown = 0.0
	_defensive_moves_in_row = 0
	_final_pass_elapsed = 0.0
	_death_player_line_emitted = false
	_death_boss_line_emitted = false
	_death_passage_line_emitted = false
	_death_echo_line_emitted = false
	_defeat_emitted = false
	_facing_direction = -1.0
	_apply_facing()
	health_component.reset_to_full()
	hurtbox.set_enabled(true)
	hurtbox.set_invulnerable(false)
	animated_sprite.modulate = Color.WHITE
	_enter_state(State.DORMANT)
	phase_changed.emit(_phase)
	poise_changed.emit(_current_poise, config.max_poise)


func get_state_name() -> StringName:
	return STATE_NAMES[_state]


func get_phase() -> int:
	return _phase


func get_current_poise() -> int:
	return _current_poise


func get_current_attack() -> StringName:
	return _current_attack


func get_attack_gap_remaining() -> float:
	return _attack_gap_remaining


func get_chain_count() -> int:
	return _chain_count


func get_facing_direction() -> float:
	return _facing_direction


func get_turn_total_duration() -> float:
	return config.turn_reaction_delay + config.turn_animation_duration


func get_player_distance() -> float:
	return absf(_target.global_position.x - global_position.x) if _target != null else INF


func get_debug_status() -> String:
	return "DUCHESS | %s | P%d | HP %d/%d | POISE %d/%d | ATK %s | GAP %.2f | CHAIN %d | FACE %+.0f | DIST %.1f | TURN %.2f | SIDE %.2f | RIP %.2f | PHANTOM %.2f | FINAL %.2f" % [
		get_state_name(), _phase, health_component.current_health, health_component.max_health,
		_current_poise, config.max_poise, _current_attack, _attack_gap_remaining, _chain_count,
		_facing_direction, get_player_distance(), _state_elapsed if _state == State.TURN else 0.0,
		_side_step_cooldown, _riposte_cooldown, _phantom_cooldown, _final_cooldown,
	]


func debug_force_attack(attack_name: StringName) -> bool:
	if _state == State.DORMANT or _state == State.INTRO or _state == State.DEATH:
		return false
	_debug_forced_attack = attack_name
	_enter_state(State.EVALUATE)
	return true


func debug_set_health(value: int) -> void:
	health_component.set_current_health(value)


func _process_intro() -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * get_physics_process_delta_time())
	var duration: float = config.intro_retry_duration if _intro_retry else config.intro_full_duration
	if _state_elapsed >= duration:
		combat_started.emit()
		_attack_gap_remaining = config.intro_attack_gap
		_enter_state(State.IDLE)


func _process_idle() -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * get_physics_process_delta_time())
	if _state_elapsed >= config.idle_decision_delay:
		_enter_state(State.EVALUATE)


func _evaluate_next_action() -> void:
	if _phase_transition_pending:
		_enter_state(State.PHASE_TRANSITION)
		return
	if _target == null or _target.is_dead():
		_enter_state(State.IDLE)
		return
	var desired_direction: float = signf(_target.global_position.x - global_position.x)
	if _should_turn(desired_direction):
		_turn_target_direction = desired_direction
		_enter_state(State.TURN)
		return
	var distance: float = get_player_distance()
	if _attack_gap_remaining > 0.0:
		if distance > config.preferred_distance + config.approach_gap_margin:
			_enter_state(State.ELEGANT_APPROACH)
		elif distance < config.preferred_distance - config.retreat_gap_margin and _defensive_moves_in_row < 2:
			_enter_state(State.ELEGANT_RETREAT)
		else:
			_enter_state(State.IDLE)
		return
	var attack_name: StringName = _select_attack(distance)
	if attack_name.is_empty():
		_enter_state(State.ELEGANT_APPROACH)
		return
	_start_attack(attack_name)


func _select_attack(distance: float) -> StringName:
	if not _debug_forced_attack.is_empty():
		var forced: StringName = _debug_forced_attack
		_debug_forced_attack = &""
		return forced
	var candidates: Array[StringName] = []
	var weights: Array[float] = []
	if distance <= config.rapier_thrust_range + config.rapier_selection_padding:
		candidates.append(ATTACK_RAPIER)
		weights.append(0.35)
	if distance <= config.fan_slash_range:
		candidates.append(ATTACK_FAN)
		weights.append(0.35)
	if distance <= config.riposte_selection_range and _riposte_cooldown <= 0.0 and _can_backstep():
		candidates.append(ATTACK_RIPOSTE)
		weights.append(0.15)
	if distance <= config.side_cut_selection_range and _side_step_cooldown <= 0.0 and _defensive_moves_in_row < 2:
		candidates.append(ATTACK_SIDE_CUT)
		weights.append(0.15)
	if _phase >= 2:
		if distance <= config.double_lunge_selection_range:
			candidates.append(ATTACK_DOUBLE)
			weights.append(0.30)
		if _phantom_cooldown <= 0.0:
			candidates.append(ATTACK_PHANTOM)
			weights.append(0.18)
		var health_ratio: float = float(health_component.current_health) / float(health_component.max_health)
		if health_ratio <= config.final_waltz_health_threshold and _final_cooldown <= 0.0:
			candidates.append(ATTACK_FINAL)
			weights.append(0.22)
	if candidates.is_empty():
		return &""
	for index: int in range(candidates.size()):
		if candidates[index] == _last_attack:
			weights[index] *= config.overused_attack_weight if _same_attack_count >= 2 else config.repeated_attack_weight
	var total: float = 0.0
	for weight: float in weights:
		total += weight
	var roll: float = _rng.randf_range(0.0, total)
	for index: int in range(candidates.size()):
		roll -= weights[index]
		if roll <= 0.0:
			return candidates[index]
	return candidates.back()


func _start_attack(attack_name: StringName) -> void:
	_current_attack = attack_name
	_chain_count += 1
	_same_attack_count = _same_attack_count + 1 if _last_attack == attack_name else 1
	_last_attack = attack_name
	attack_started.emit(attack_name)
	match attack_name:
		ATTACK_RAPIER:
			_defensive_moves_in_row = 0
			_enter_state(State.RAPIER_THRUST_WINDUP)
		ATTACK_FAN:
			_defensive_moves_in_row = 0
			_enter_state(State.FAN_SLASH_WINDUP)
		ATTACK_RIPOSTE:
			_riposte_cooldown = config.backstep_riposte_cooldown
			_defensive_moves_in_row += 1
			_enter_state(State.BACKSTEP)
		ATTACK_SIDE_CUT:
			_side_step_cooldown = config.side_step_cut_cooldown
			_defensive_moves_in_row += 1
			_enter_state(State.SIDE_STEP)
		ATTACK_DOUBLE:
			_defensive_moves_in_row = 0
			_enter_state(State.DOUBLE_LUNGE_WINDUP)
		ATTACK_PHANTOM:
			_phantom_cooldown = config.phantom_dance_cooldown
			_defensive_moves_in_row = 0
			_enter_state(State.PHANTOM_DANCE_PREPARE)
		ATTACK_FINAL:
			_final_cooldown = config.final_waltz_cooldown
			_defensive_moves_in_row = 0
			_final_pass_index = 0
			_final_pass_direction = -_facing_direction
			_enter_state(State.FINAL_WALTZ_PREPARE)


func _process_approach(delta: float) -> void:
	if _target == null:
		_enter_state(State.IDLE)
		return
	var direction: float = signf(_target.global_position.x - global_position.x)
	velocity.x = move_toward(velocity.x, direction * config.approach_speed, config.acceleration * delta)
	if _state_elapsed >= config.approach_evaluation_time or get_player_distance() <= config.preferred_distance:
		_enter_state(State.EVALUATE)


func _process_retreat(delta: float) -> void:
	if _target == null:
		_enter_state(State.IDLE)
		return
	var direction: float = -signf(_target.global_position.x - global_position.x)
	if not _can_move_direction(direction, 52.0):
		_enter_state(State.EVALUATE)
		return
	velocity.x = move_toward(velocity.x, direction * config.retreat_speed, config.acceleration * delta)
	if _state_elapsed >= config.retreat_duration:
		_defensive_moves_in_row += 1
		_enter_state(State.EVALUATE)


func _process_turn() -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * get_physics_process_delta_time())
	var commit_time: float = config.turn_reaction_delay + config.turn_animation_duration * config.turn_facing_commit_ratio
	if not _turn_committed and _state_elapsed >= commit_time:
		_facing_direction = _turn_target_direction
		_apply_facing()
		_turn_committed = true
	if _state_elapsed >= get_turn_total_duration():
		_enter_state(State.EVALUATE)


func _process_side_step(delta: float) -> void:
	var direction: float = _movement_direction
	velocity.x = move_toward(velocity.x, direction * config.side_step_speed, config.acceleration * delta)
	if _state_elapsed >= config.side_step_duration or not _can_move_direction(direction, 16.0):
		_enter_state(State.SIDE_STEP_CUT_PREPARE)


func _process_backstep(delta: float) -> void:
	var direction: float = -_facing_direction
	velocity.x = move_toward(velocity.x, direction * config.backstep_speed, config.acceleration * delta)
	if _state_elapsed >= config.backstep_duration or not _can_move_direction(direction, 16.0):
		_lock_facing_to_target()
		_enter_state(State.BACKSTEP_RIPOSTE_PREPARE)


func _process_lunge_active(delta: float, duration: float, next_state: State) -> void:
	velocity.x = move_toward(velocity.x, _facing_direction * config.lunge_speed, config.acceleration * delta)
	if _state_elapsed >= duration:
		_enter_state(next_state)


func _process_double_lunge_gap() -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * get_physics_process_delta_time())
	if _state_elapsed >= config.double_lunge_gap:
		_lock_facing_to_target()
		_enter_state(State.DOUBLE_LUNGE_HIT_2)


func _process_phase_transition(delta: float) -> void:
	var safe_direction: float = -_facing_direction
	if _can_move_direction(safe_direction, 24.0) and _state_elapsed < config.phase_transition_retreat_time:
		velocity.x = move_toward(velocity.x, safe_direction * config.retreat_speed, config.acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
	if _state_elapsed >= config.phase_transition_duration:
		_phase = 2
		_phase_transition_pending = false
		hurtbox.set_invulnerable(false)
		phase_changed.emit(_phase)
		_attack_gap_remaining = config.phase_2_entry_gap
		_enter_state(State.IDLE)


func _process_final_prepare(delta: float) -> void:
	velocity.x = move_toward(velocity.x, _final_pass_direction * config.retreat_speed, config.acceleration * delta)
	if _state_elapsed >= config.final_waltz_prepare:
		_enter_state(State.FINAL_WALTZ_ACTIVE)


func _process_final_active(delta: float) -> void:
	if not _final_pass_active and is_zero_approx(_final_pass_elapsed):
		_begin_final_pass()
	_final_pass_elapsed += delta
	if _final_pass_elapsed < config.final_waltz_pass_duration:
		velocity.x = move_toward(velocity.x, _final_pass_direction * config.final_waltz_speed, config.acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		if _final_pass_active:
			final_hitbox.end_attack()
			_final_pass_active = false
		if _final_pass_elapsed >= config.final_waltz_pass_duration + config.final_waltz_pass_gap:
			_final_pass_index += 1
			_final_pass_direction *= -1.0
			_final_pass_elapsed = 0.0
			_update_final_telegraph()
	if _final_pass_index >= config.final_waltz_passes:
		_enter_state(State.FINAL_WALTZ_RECOVERY)


func _begin_final_pass() -> void:
	_final_pass_active = true
	_final_pass_elapsed = 0.0
	_facing_direction = _final_pass_direction
	_apply_facing()
	_active_attack_id = _consume_attack_id()
	final_hitbox.begin_attack(_active_attack_id, config.final_waltz_damage, _facing_direction, self)
	attack_active.emit(ATTACK_FINAL, _active_attack_id)


func _process_light_hit() -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * get_physics_process_delta_time())
	if _state_elapsed >= config.light_hit_reaction_duration:
		_enter_state(_light_hit_return_state)


func _process_stagger() -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * get_physics_process_delta_time())
	if _state_elapsed >= config.stagger_duration:
		_current_poise = config.max_poise
		_stagger_protection_remaining = config.stagger_protection_duration
		poise_changed.emit(_current_poise, config.max_poise)
		_attack_gap_remaining = config.post_stagger_gap
		_enter_state(State.IDLE)


func _process_death() -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * get_physics_process_delta_time())
	if _state_elapsed >= config.death_player_line_time and not _death_player_line_emitted:
		_death_player_line_emitted = true
		death_line_requested.emit("夜巡守卫", "你认识我？")
	if _state_elapsed >= config.death_boss_line_time and not _death_boss_line_emitted:
		_death_boss_line_emitted = true
		death_line_requested.emit("瑟芙琳", "不……但殿下一直在等你。")
	if _state_elapsed >= config.death_passage_line_time and not _death_passage_line_emitted:
		_death_passage_line_emitted = true
		death_line_requested.emit("瑟芙琳", "穿过镜后的礼门。")
	if _state_elapsed >= config.death_echo_line_time and not _death_echo_line_emitted:
		_death_echo_line_emitted = true
		death_line_requested.emit("瑟芙琳", "十三声忏悔，会替她回答。")
	if _state_elapsed >= config.death_duration and not _defeat_emitted:
		_defeat_emitted = true
		boss_defeated.emit()
		set_physics_process(false)


func _finish_attack_after(duration: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * get_physics_process_delta_time())
	if _state_elapsed < duration:
		return
	var finished: StringName = _current_attack
	_current_attack = &""
	attack_finished.emit(finished)
	var mandatory: bool = _chain_count >= config.chain_limit
	if mandatory:
		_attack_gap_remaining = config.phase_2_chain_recovery if _phase >= 2 else config.phase_1_chain_recovery
		_chain_count = 0
	else:
		_attack_gap_remaining = _rng.randf_range(
			config.phase_2_min_attack_gap if _phase >= 2 else config.phase_1_min_attack_gap,
			config.phase_2_max_attack_gap if _phase >= 2 else config.phase_1_max_attack_gap
		)
	_enter_state(State.EVALUATE)


func _timed_transition(duration: float, next_state: State) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * get_physics_process_delta_time())
	if _state_elapsed >= duration:
		_enter_state(next_state)


func _enter_state(next_state: State) -> void:
	_exit_state(_state)
	_state = next_state
	_state_elapsed = 0.0
	_turn_committed = false
	match next_state:
		State.DORMANT, State.IDLE, State.EVALUATE:
			_play_animation(&"idle")
		State.INTRO:
			_play_animation(&"intro")
		State.ELEGANT_APPROACH, State.ELEGANT_RETREAT:
			_play_animation(&"elegant_walk")
		State.TURN:
			_play_animation(&"turn")
		State.SIDE_STEP:
			_movement_direction = _choose_side_step_direction()
			_play_animation(&"sidestep")
		State.BACKSTEP:
			_play_animation(&"backstep")
		State.RAPIER_THRUST_WINDUP:
			_lock_facing_to_target()
			_play_animation(&"rapier_thrust_windup")
		State.RAPIER_THRUST_ACTIVE:
			_play_animation(&"rapier_thrust_active")
			_open_hitbox(rapier_hitbox, config.rapier_thrust_damage, ATTACK_RAPIER)
		State.RAPIER_THRUST_RECOVERY:
			_play_animation(&"rapier_thrust_recovery")
		State.FAN_SLASH_WINDUP:
			_lock_facing_to_target()
			_play_animation(&"fan_slash_windup")
		State.FAN_SLASH_ACTIVE:
			_play_animation(&"fan_slash_active")
			_open_hitbox(fan_hitbox, config.fan_slash_damage, ATTACK_FAN)
		State.FAN_SLASH_RECOVERY:
			_play_animation(&"fan_slash_recovery")
		State.BACKSTEP_RIPOSTE_PREPARE, State.BACKSTEP_RIPOSTE_WINDUP:
			_play_animation(&"riposte")
		State.BACKSTEP_RIPOSTE_ACTIVE:
			_open_hitbox(riposte_hitbox, config.riposte_damage, ATTACK_RIPOSTE)
		State.BACKSTEP_RIPOSTE_RECOVERY:
			_play_animation(&"rapier_thrust_recovery")
		State.SIDE_STEP_CUT_PREPARE:
			_lock_facing_to_target()
			_play_animation(&"sidestep")
		State.SIDE_STEP_CUT_WINDUP:
			_play_animation(&"fan_slash_windup")
		State.SIDE_STEP_CUT_ACTIVE:
			_play_animation(&"fan_slash_active")
			_open_hitbox(side_cut_hitbox, config.side_step_cut_damage, ATTACK_SIDE_CUT)
		State.SIDE_STEP_CUT_RECOVERY:
			_play_animation(&"fan_slash_recovery")
		State.PHASE_TRANSITION:
			_disable_all_hitboxes()
			hurtbox.set_invulnerable(true)
			_play_animation(&"phase_transition")
		State.DOUBLE_LUNGE_WINDUP:
			_lock_facing_to_target()
			_play_animation(&"double_lunge")
		State.DOUBLE_LUNGE_HIT_1:
			_open_hitbox(double_hitbox_1, config.double_lunge_damage_1, ATTACK_DOUBLE)
		State.DOUBLE_LUNGE_HIT_2:
			_open_hitbox(double_hitbox_2, config.double_lunge_damage_2, ATTACK_DOUBLE)
		State.DOUBLE_LUNGE_RECOVERY:
			_play_animation(&"rapier_thrust_recovery")
		State.PHANTOM_DANCE_PREPARE:
			_play_animation(&"phantom_dance")
			_spawn_phantom_routes()
		State.PHANTOM_DANCE_ACTIVE:
			_active_attack_id = _consume_attack_id()
			attack_active.emit(ATTACK_PHANTOM, _active_attack_id)
		State.PHANTOM_DANCE_RECOVERY:
			_play_animation(&"fan_slash_recovery")
		State.FINAL_WALTZ_PREPARE:
			_play_animation(&"final_waltz")
			_update_final_telegraph()
		State.FINAL_WALTZ_ACTIVE:
			_final_pass_active = false
			_final_pass_elapsed = 0.0
		State.FINAL_WALTZ_RECOVERY:
			route_telegraph.clear_points()
			_play_animation(&"stagger")
		State.LIGHT_HIT_REACTION:
			_play_animation(&"light_hit")
		State.STAGGER:
			_disable_all_hitboxes()
			_play_animation(&"stagger")
		State.DEATH:
			_disable_all_hitboxes()
			_clear_phantoms()
			hurtbox.set_enabled(false)
			_play_animation(&"death")


func _exit_state(old_state: State) -> void:
	if old_state in [
		State.RAPIER_THRUST_ACTIVE, State.FAN_SLASH_ACTIVE,
		State.BACKSTEP_RIPOSTE_ACTIVE, State.SIDE_STEP_CUT_ACTIVE,
		State.DOUBLE_LUNGE_HIT_1, State.DOUBLE_LUNGE_HIT_2,
	]:
		_disable_all_hitboxes()
	if old_state == State.FINAL_WALTZ_ACTIVE:
		final_hitbox.end_attack()


func _open_hitbox(hitbox: HitboxComponent, damage: int, attack_name: StringName) -> void:
	_disable_all_hitboxes()
	_active_attack_id = _consume_attack_id()
	hitbox.begin_attack(_active_attack_id, damage, _facing_direction, self)
	attack_active.emit(attack_name, _active_attack_id)


func _disable_all_hitboxes() -> void:
	for hitbox: HitboxComponent in [
		rapier_hitbox, fan_hitbox, riposte_hitbox, side_cut_hitbox,
		double_hitbox_1, double_hitbox_2, final_hitbox,
	]:
		if hitbox != null:
			hitbox.end_attack()


func _consume_attack_id() -> int:
	var result: int = _next_attack_id
	_next_attack_id += 1
	if _next_attack_id <= 0:
		_next_attack_id = 1
	return result


func _spawn_phantom_routes() -> void:
	if phantom_route_scene == null or _target == null:
		return
	var center_x: float = clampf(
		_target.global_position.x,
		_arena_left + config.phantom_route_edge_margin,
		_arena_right - config.phantom_route_edge_margin
	)
	# The boss body origin is the floor contact point. Keep one route at body
	# height and one elevated route so the visual and hitbox lanes match Main.
	var lanes: Array[float] = [
		_spawn_position.y,
		_spawn_position.y - config.phantom_elevated_lane_offset,
	]
	for index: int in range(2):
		var route: DuchessPhantomRoute = phantom_route_scene.instantiate() as DuchessPhantomRoute
		if route == null:
			continue
		get_parent().add_child(route)
		var direction: float = 1.0 if index == 0 else -1.0
		var start: Vector2 = Vector2(
			center_x - direction * config.phantom_route_half_length,
			lanes[index]
		)
		var finish: Vector2 = Vector2(
			center_x + direction * config.phantom_route_half_length,
			lanes[index]
		)
		route.configure_route(
			start, finish, config.phantom_telegraph, config.phantom_active,
			config.phantom_damage, _consume_attack_id(), self
		)
		route.route_finished.connect(_on_phantom_finished)
		_active_phantoms.append(route)


func _on_phantom_finished(route: DuchessPhantomRoute) -> void:
	_active_phantoms.erase(route)


func _clear_phantoms() -> void:
	for route: DuchessPhantomRoute in _active_phantoms:
		if route != null and is_instance_valid(route):
			route.queue_free()
	_active_phantoms.clear()
	if route_telegraph != null:
		route_telegraph.clear_points()


func _update_final_telegraph() -> void:
	if route_telegraph == null:
		return
	route_telegraph.clear_points()
	route_telegraph.add_point(Vector2(0.0, 28.0))
	route_telegraph.add_point(Vector2(
		_final_pass_direction * config.final_waltz_telegraph_length,
		28.0
	))


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	_last_incoming_attack_kind = hitbox.attack_kind if hitbox != null else &""


func _on_hit_received(_damage: int, _source_position: Vector2, _attack_id: int) -> void:
	if _state == State.DEATH or _state == State.PHASE_TRANSITION:
		return
	var poise_damage: int = (
		config.dash_attack_poise_damage
		if _last_incoming_attack_kind == &"dash_attack"
		else config.normal_attack_poise_damage
	)
	_current_poise = maxi(0, _current_poise - poise_damage)
	poise_changed.emit(_current_poise, config.max_poise)
	_flash_hit()
	if _current_poise <= 0 and _stagger_protection_remaining <= 0.0 and _can_enter_stagger():
		_enter_state(State.STAGGER)
		return
	if _last_incoming_attack_kind == &"dash_attack" and _can_light_react():
		_light_hit_return_state = _state
		_enter_state(State.LIGHT_HIT_REACTION)


func _on_health_changed(current: int, maximum: int) -> void:
	if _phase == 1 and not _phase_transition_pending and current > 0:
		var threshold_hp: int = int(ceil(float(maximum) * config.phase_2_threshold))
		if current <= threshold_hp:
			_phase_transition_pending = true


func _on_died() -> void:
	if _state != State.DEATH:
		_enter_state(State.DEATH)


func apply_persisted_defeat() -> void:
	_clear_phantoms()
	_disable_all_hitboxes()
	velocity = Vector2.ZERO
	hurtbox.set_enabled(false)
	visible = false
	_state = State.DEATH
	_defeat_emitted = true
	set_physics_process(false)


func _flash_hit() -> void:
	animated_sprite.modulate = Color(1.0, 0.76, 0.78, 1.0)
	var tween: Tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, config.light_hit_flash_duration)


func _can_light_react() -> bool:
	return _state in [
		State.IDLE, State.EVALUATE, State.ELEGANT_APPROACH, State.ELEGANT_RETREAT,
	]


func _can_enter_stagger() -> bool:
	return _state not in [State.PHASE_TRANSITION, State.DEATH, State.STAGGER]


func _should_turn(desired_direction: float) -> bool:
	if is_zero_approx(desired_direction) or desired_direction == _facing_direction:
		return false
	return get_player_distance() > config.side_threshold


func _lock_facing_to_target() -> void:
	if _target == null:
		return
	var direction: float = signf(_target.global_position.x - global_position.x)
	if not is_zero_approx(direction):
		_facing_direction = direction
		_apply_facing()


func _choose_side_step_direction() -> float:
	if _target == null:
		return _facing_direction
	var direction: float = signf(_target.global_position.x - global_position.x)
	if get_player_distance() < config.close_clearance:
		direction *= -1.0
	if not _can_move_direction(direction, config.side_step_speed * config.side_step_duration):
		direction *= -1.0
	return direction


func _can_backstep() -> bool:
	return _can_move_direction(-_facing_direction, config.backstep_speed * config.backstep_duration)


func _can_move_direction(direction: float, clearance: float) -> bool:
	var target_x: float = global_position.x + direction * clearance
	return target_x > _arena_left and target_x < _arena_right


func _apply_facing() -> void:
	if animated_sprite != null:
		animated_sprite.flip_h = _facing_direction < 0.0
	if facing_root != null:
		facing_root.scale.x = _facing_direction


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y += config.gravity * delta


func _clamp_arena_velocity() -> void:
	if global_position.x <= _arena_left and velocity.x < 0.0:
		velocity.x = 0.0
	if global_position.x >= _arena_right and velocity.x > 0.0:
		velocity.x = 0.0


func _tick_cooldowns(delta: float) -> void:
	_attack_gap_remaining = maxf(0.0, _attack_gap_remaining - delta)
	_stagger_protection_remaining = maxf(0.0, _stagger_protection_remaining - delta)
	_riposte_cooldown = maxf(0.0, _riposte_cooldown - delta)
	_side_step_cooldown = maxf(0.0, _side_step_cooldown - delta)
	_phantom_cooldown = maxf(0.0, _phantom_cooldown - delta)
	_final_cooldown = maxf(0.0, _final_cooldown - delta)


func _play_animation(animation_name: StringName) -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		return
	if animated_sprite.animation != animation_name or not animated_sprite.is_playing():
		animated_sprite.play(animation_name)


func _validate_dependencies() -> bool:
	if config == null:
		push_error("HollowDuchess requires HollowDuchessConfig")
		return false
	if animated_sprite == null or facing_root == null or health_component == null or hurtbox == null:
		push_error("HollowDuchess scene composition is incomplete")
		return false
	return true
