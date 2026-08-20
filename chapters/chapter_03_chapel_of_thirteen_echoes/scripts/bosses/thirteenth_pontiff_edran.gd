class_name ThirteenthPontiffEdran
extends CharacterBody2D

signal activated
signal phase_transition_requested(current_health: int)
signal phase_transition_started
signal phase_transition_stage_reached(stage_name: StringName)
signal phase_changed(phase: int)
signal phase_transition_finished
signal death_sequence_started
signal defeated
signal state_changed(state_name: StringName)
signal attack_window_changed(attack_name: StringName, active: bool)
signal phase_02_flow_event(event_name: StringName)

enum State {
	DORMANT,
	IDLE,
	APPROACH,
	TURN,
	ATTACK,
	SUMMON,
	FIRE_SPELL_WINDUP,
	FIRE_SPELL_RELEASE,
	FIRE_SPELL_RECOVERY,
	ICE_SPELL_WINDUP,
	ICE_SPELL_RELEASE,
	ICE_SPELL_RECOVERY,
	MIRE_SPELL_WINDUP,
	MIRE_TARGET_LOCK,
	MIRE_SPELL_ACTIVATE,
	MIRE_SPELL_RECOVERY,
	LIGHTNING_SPELL_WINDUP,
	LIGHTNING_SPELL_RELEASE,
	LIGHTNING_SPELL_RECOVERY,
	GRAVITY_SPELL_WINDUP,
	GRAVITY_FINAL_SEAL,
	GRAVITY_SPELL_RECOVERY,
	STAGGER,
	TRANSITION_PENDING,
	PHASE_TRANSITION,
	DEATH_SEQUENCE,
	DEAD,
}

enum Attack {
	SWEEP,
	THRUST,
	CENSER,
	LITANY,
	THIRTEENFOLD,
	SUMMON,
	BELL_CLEAVE,
	HOLLOW_TOLL,
	CHAIN_JUDGMENT,
	SCRIPTURE_BURIAL,
	PROCESSION,
	FOURTEENTH_SEAT,
	FIRE_SPELL,
	ICE_SPELL,
	MIRE_SPELL,
	THREEFOLD_JUDGMENT,
	WEIGHT_OF_ABSOLUTION,
}

@export var config: ThirteenthPontiffEdranConfig
@export var timed_field_scene: PackedScene
@export var phase_transition_frames: SpriteFrames
@export var phase_02_frames: SpriteFrames
@export var fireball_scene: PackedScene
@export var ice_lance_scene: PackedScene
@export var mire_telegraph_scene: PackedScene
@export var mire_zone_scene: PackedScene
@export var lightning_strike_scene: PackedScene
@export var gravity_judgment_scene: PackedScene
@export var auto_activate: bool = false

@onready var sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite2D as AnimatedSprite2D
@onready var facing_root: Node2D = $FacingRoot as Node2D
@onready var health_component: HealthComponent = $HealthComponent as HealthComponent
@onready var hurtbox: HurtboxComponent = $Hurtbox as HurtboxComponent
@onready var sweep_hitbox: HitboxComponent = $FacingRoot/SweepHitbox as HitboxComponent
@onready var thrust_hitbox: HitboxComponent = $FacingRoot/ThrustHitbox as HitboxComponent
@onready var censer_hitbox: HitboxComponent = $FacingRoot/CenserHitbox as HitboxComponent
@onready var phase_02_cleave_hitbox: HitboxComponent = $FacingRoot/Phase2CleaveHitbox as HitboxComponent
@onready var phase_02_chain_hitbox: HitboxComponent = $FacingRoot/Phase2ChainHitbox as HitboxComponent
@onready var summon_director: ThirteenthPontiffSummonDirector = $SummonDirector as ThirteenthPontiffSummonDirector

var current_state: State = State.DORMANT
var current_poise: int = 0
var target: Player
var facing: float = -1.0
var _spawn_position: Vector2
var _attack_gap_timer: float = 0.0
var _stagger_protection_timer: float = 0.0
var _censer_cooldown: float = 0.0
var _litany_cooldown: float = 0.0
var _thirteenfold_cooldown: float = 0.0
var _summon_cooldown: float = 0.0
var _summon_interrupt_progress: int = 0
var _summon_sequence_id: int = 0
var _attack_cursor: int = 0
var _chain_count: int = 0
var _action_locked: bool = false
var _next_attack_id: int = 1
var _transition_emitted: bool = false
var _phase: int = 1
var _hollow_toll_cooldown: float = 0.0
var _scripture_burial_cooldown: float = 0.0
var _procession_cooldown: float = 0.0
var _fourteenth_seat_cooldown: float = 0.0
var _last_phase_02_attack: Attack = Attack.SWEEP
var _last_phase_01_attack: Attack = Attack.SWEEP
var _defeat_emitted: bool = false
var _fire_cooldown: float = 0.0
var _ice_cooldown: float = 0.0
var _mire_cooldown: float = 0.0
var _lightning_cooldown: float = 0.0
var _gravity_cooldown: float = 0.0
var _magic_global_cooldown: float = 0.0
var _frozen_major_grace: float = 0.0
var _ice_suppression_timer: float = 0.0
var _post_gravity_pressure_lock: float = 0.0
var _phase_02_elapsed: float = 0.0
var _last_magic: Attack = Attack.SWEEP
var _spell_sequence_id: int = 0
var _mire_telegraph: PontiffMireTelegraph
var _active_mire: PontiffMireZone
var _active_lightning_strikes: Array[PontiffLightningStrike] = []
var _gravity_judgment: PontiffGravityJudgment
var _gravity_final_seal: bool = false
var _phase_02_transition_complete: bool = false
var _phase_02_dialogue_active: bool = false
var _phase_02_dialogue_complete: bool = false
var _phase_02_opening_gravity_started: bool = false
var _phase_02_opening_gravity_completed: bool = false
var _phase_02_opening_cast_active: bool = false
var _phase_02_normal_ai_enabled: bool = false
var _debug_magic_mode: StringName = &""
var _target_was_frozen: bool = false
var far_pressure: float = 0.0
var close_pressure: float = 0.0
var air_pressure: float = 0.0
var crossup_pressure: float = 0.0
var dash_pressure: float = 0.0
var attack_pressure: float = 0.0
var _behavior_clock: float = 0.0
var _behavior_sample_timer: float = 0.0
var _position_sample_timer: float = 0.0
var _player_position_history: Array[Dictionary] = []
var _lightning_targets: Array[Vector2] = []
var _behavior_events: Array[Dictionary] = []
var _previous_target_side: float = 0.0
var _previous_target_action: StringName = &"None"
var _previous_target_movement: StringName = &"idle"
var _adaptive_decision_reason: StringName = &"base"
var observed_jump_count: int = 0
var observed_double_jump_count: int = 0
var observed_crossup_count: int = 0
var observed_dash_through_count: int = 0

const BEHAVIOR_REACTION_DELAY: float = 0.32
const BEHAVIOR_DECAY_PER_SECOND: float = 0.15
const BEHAVIOR_SAMPLE_INTERVAL: float = 0.20


func _ready() -> void:
	if config == null:
		push_error("ThirteenthPontiffEdran requires a typed config Resource")
		set_physics_process(false)
		return
	_spawn_position = global_position
	current_poise = config.max_poise
	health_component.max_health = config.max_health
	health_component.reset_to_full()
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	hurtbox.hit_resolving.connect(_on_hit_resolving)
	_set_facing(facing)
	_set_state(State.DORMANT, &"prayer_idle")
	if auto_activate:
		call_deferred("activate", get_tree().get_first_node_in_group("player") as Player)


func _physics_process(delta: float) -> void:
	_tick_cooldowns(delta)
	_observe_target_behavior(delta)
	if not is_on_floor():
		velocity.y += config.gravity * delta
	if current_state in [State.DORMANT, State.TRANSITION_PENDING, State.PHASE_TRANSITION, State.DEATH_SEQUENCE, State.DEAD]:
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		move_and_slide()
		return
	if _phase == 2 and not _phase_02_normal_ai_enabled and not _is_spell_state(current_state):
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		move_and_slide()
		return
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Player
	if current_state in [State.ATTACK, State.SUMMON, State.TURN, State.STAGGER] or _action_locked:
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		move_and_slide()
		return
	if target == null:
		_set_state(State.IDLE, _idle_animation())
		move_and_slide()
		return
	var horizontal_distance: float = absf(target.global_position.x - global_position.x)
	var desired_facing: float = signf(target.global_position.x - global_position.x)
	if not is_zero_approx(desired_facing) and desired_facing != facing:
		_run_turn(desired_facing)
		move_and_slide()
		return
	if _attack_gap_timer <= 0.0 and horizontal_distance <= _selection_range():
		if _phase == 2:
			_start_selected_phase_02_attack(horizontal_distance)
		else:
			_start_selected_attack(horizontal_distance)
	elif horizontal_distance > config.preferred_distance:
		_set_state(State.APPROACH, &"distorted_walk" if _phase == 2 else &"slow_walk")
		velocity.x = move_toward(velocity.x, facing * config.approach_speed, config.acceleration * delta)
	else:
		_set_state(State.IDLE, _idle_animation())
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
	global_position.x = clampf(
		global_position.x, _spawn_position.x - config.arena_half_width, _spawn_position.x + config.arena_half_width
	)
	move_and_slide()


func activate(player: Player = null) -> void:
	if current_state != State.DORMANT:
		return
	_reset_behavior_context()
	_reset_phase_02_opening_flow()
	target = player if player != null else get_tree().get_first_node_in_group("player") as Player
	hurtbox.set_enabled(true)
	_attack_gap_timer = 0.45
	_configure_debug_mode_from_run()
	_set_state(State.IDLE, &"phase_01_idle")
	activated.emit()


func debug_force_attack(attack_name: StringName) -> bool:
	if current_state in [State.DORMANT, State.TRANSITION_PENDING, State.PHASE_TRANSITION, State.DEATH_SEQUENCE, State.DEAD] or _action_locked:
		return false
	match attack_name:
		&"pontifical_sweep": _run_melee_attack(Attack.SWEEP)
		&"crozier_thrust": _run_melee_attack(Attack.THRUST)
		&"censer_procession": _run_melee_attack(Attack.CENSER)
		&"litany_of_ash": _run_litany()
		&"thirteenfold_sentence": _run_thirteenfold()
		&"raise_the_absolved", &"raise_the_unconfessed": _run_summon()
		&"bell_bound_cleave": _run_phase_02_cleave()
		&"hollow_toll": _run_hollow_toll()
		&"censer_chain_judgment": _run_chain_judgment()
		&"scripture_burial": _run_scripture_burial()
		&"procession_of_the_unburied": _run_procession()
		&"fourteenth_seat": _run_fourteenth_seat()
		&"cinder_absolution": _run_fire_spell()
		&"litany_of_stillness": _run_ice_spell()
		&"mire_of_the_unburied": _run_mire_spell()
		&"threefold_judgment": _run_threefold_judgment()
		&"weight_of_absolution": _run_weight_of_absolution()
		_: return false
	return true


func debug_force_phase_02() -> void:
	if _phase == 2 or current_state == State.DEAD:
		return
	health_component.set_current_health(config.phase_transition_health)


func debug_enter_phase_02_immediate() -> void:
	if not OS.is_debug_build() or current_state == State.DEAD:
		return
	_transition_emitted = true
	_phase = 2
	_phase_02_elapsed = 0.0
	_phase_02_transition_complete = true
	_phase_02_dialogue_complete = true
	_phase_02_opening_gravity_started = true
	_phase_02_opening_gravity_completed = true
	_phase_02_opening_cast_active = false
	_phase_02_normal_ai_enabled = true
	health_component.set_current_health(config.phase_transition_health)
	current_poise = config.phase_02_max_poise
	if phase_02_frames != null:
		sprite.sprite_frames = phase_02_frames
	hurtbox.set_invulnerable(false)
	_action_locked = false
	_set_state(State.IDLE,&"phase_02_idle")
	phase_changed.emit(2)


func is_phase_02() -> bool:
	return _phase == 2


func get_phase() -> int:
	return _phase


func notify_phase_02_dialogue_started() -> void:
	if _transition_emitted and not _phase_02_dialogue_complete:
		_phase_02_dialogue_active = true
		_trace_phase_02_flow(&"PHASE_2_DIALOGUE_BEGIN")


func notify_phase_02_dialogue_finished() -> void:
	if not _transition_emitted or _phase_02_dialogue_complete:
		return
	_phase_02_dialogue_active = false
	_phase_02_dialogue_complete = true
	_trace_phase_02_flow(&"PHASE_2_DIALOGUE_END")


func is_phase_02_opening_gravity_started() -> bool:
	return _phase_02_opening_gravity_started


func is_phase_02_opening_gravity_completed() -> bool:
	return _phase_02_opening_gravity_completed


func is_phase_02_normal_ai_enabled() -> bool:
	return _phase_02_normal_ai_enabled


func play_cinematic_animation(animation_name: StringName) -> void:
	if current_state == State.DORMANT:
		_play_animation(animation_name)


func get_state_name() -> StringName:
	return State.keys()[current_state].to_snake_case()


func get_current_poise() -> int:
	return current_poise


func get_summon_interrupt_progress() -> int:
	return _summon_interrupt_progress


func get_active_summon_count() -> int:
	return summon_director.get_active_count() if summon_director != null else 0


func get_active_mire_count() -> int:
	return 1 if _has_active_mire() else 0


func get_magic_global_cooldown() -> float:
	return _magic_global_cooldown


func get_debug_magic_mode() -> StringName:
	return _debug_magic_mode


func configure_debug_magic_mode(mode: StringName) -> void:
	_debug_magic_mode = mode


func is_transition_pending() -> bool:
	return current_state == State.TRANSITION_PENDING


func _tick_cooldowns(delta: float) -> void:
	_attack_gap_timer = maxf(0.0, _attack_gap_timer - delta)
	_stagger_protection_timer = maxf(0.0, _stagger_protection_timer - delta)
	_censer_cooldown = maxf(0.0, _censer_cooldown - delta)
	_litany_cooldown = maxf(0.0, _litany_cooldown - delta)
	_thirteenfold_cooldown = maxf(0.0, _thirteenfold_cooldown - delta)
	_summon_cooldown = maxf(0.0, _summon_cooldown - delta)
	_hollow_toll_cooldown = maxf(0.0, _hollow_toll_cooldown - delta)
	_scripture_burial_cooldown = maxf(0.0, _scripture_burial_cooldown - delta)
	_procession_cooldown = maxf(0.0, _procession_cooldown - delta)
	_fourteenth_seat_cooldown = maxf(0.0, _fourteenth_seat_cooldown - delta)
	_fire_cooldown = maxf(0.0, _fire_cooldown - delta)
	_ice_cooldown = maxf(0.0, _ice_cooldown - delta)
	_mire_cooldown = maxf(0.0, _mire_cooldown - delta)
	_lightning_cooldown = maxf(0.0, _lightning_cooldown - delta)
	_gravity_cooldown = maxf(0.0, _gravity_cooldown - delta)
	_magic_global_cooldown = maxf(0.0, _magic_global_cooldown - delta)
	_frozen_major_grace = maxf(0.0, _frozen_major_grace - delta)
	_ice_suppression_timer = maxf(0.0, _ice_suppression_timer - delta)
	_post_gravity_pressure_lock = maxf(0.0, _post_gravity_pressure_lock - delta)
	if _phase == 2:
		_phase_02_elapsed += delta
	var frozen_now: bool = _target_is_frozen()
	if _target_was_frozen and not frozen_now:
		_frozen_major_grace = config.frozen_major_attack_grace
	_target_was_frozen = frozen_now


func _start_selected_attack(distance: float) -> void:
	if not _debug_magic_mode.is_empty():
		_start_debug_magic()
		return
	var candidates: Array[Attack] = []
	if distance <= config.sweep_range:
		candidates.append(Attack.SWEEP)
	if distance <= config.thrust_range:
		candidates.append(Attack.THRUST)
	if distance <= config.censer_range and _censer_cooldown <= 0.0:
		candidates.append(Attack.CENSER)
	if _litany_cooldown <= 0.0 and not _target_is_frozen() and _frozen_major_grace <= 0.0:
		candidates.append(Attack.LITANY)
	if _thirteenfold_cooldown <= 0.0 and not _has_active_mire() and not _target_is_frozen() and _frozen_major_grace <= 0.0:
		candidates.append(Attack.THIRTEENFOLD)
	if _can_select_summon(false):
		candidates.append(Attack.SUMMON)
	_append_magic_candidates(candidates)
	if candidates.is_empty():
		_attack_gap_timer = 0.20
		return
	if candidates.size() > 1:
		candidates.erase(_last_phase_01_attack)
	if candidates.is_empty():
		_attack_gap_timer = 0.20
		return
	var selected: Attack = _select_weighted_attack(candidates, false)
	_attack_cursor += 1
	_last_phase_01_attack = selected
	match selected:
		Attack.LITANY: _run_litany()
		Attack.THIRTEENFOLD: _run_thirteenfold()
		Attack.SUMMON: _run_summon()
		Attack.FIRE_SPELL: _run_fire_spell()
		Attack.ICE_SPELL: _run_ice_spell()
		Attack.MIRE_SPELL: _run_mire_spell()
		Attack.THREEFOLD_JUDGMENT: _run_threefold_judgment()
		_: _run_melee_attack(selected)


func _start_selected_phase_02_attack(distance: float) -> void:
	if not _debug_magic_mode.is_empty():
		_start_debug_magic()
		return
	var candidates: Array[Attack] = []
	if distance <= config.bell_cleave_range:
		candidates.append(Attack.BELL_CLEAVE)
	if distance <= config.chain_judgment_range:
		candidates.append(Attack.CHAIN_JUDGMENT)
	if _hollow_toll_cooldown <= 0.0 and _post_gravity_pressure_lock <= 0.0 and not _target_is_frozen() and _frozen_major_grace <= 0.0:
		candidates.append(Attack.HOLLOW_TOLL)
	if (
		_scripture_burial_cooldown <= 0.0
		and _post_gravity_pressure_lock <= 0.0
		and _hollow_toll_cooldown > 0.0
		and not _has_active_mire()
		and not _target_is_frozen()
		and _active_danger_zone_count() < 2
	):
		candidates.append(Attack.SCRIPTURE_BURIAL)
	if _can_select_summon(true):
		candidates.append(Attack.PROCESSION)
	if (
		float(health_component.current_health) / float(config.max_health) <= config.fourteenth_seat_health_ratio
		and _fourteenth_seat_cooldown <= 0.0
		and _post_gravity_pressure_lock <= 0.0
		and not _has_active_mire()
		and not _target_is_frozen()
		and _frozen_major_grace <= 0.0
	):
		candidates.append(Attack.FOURTEENTH_SEAT)
	_append_magic_candidates(candidates)
	if candidates.size() > 1:
		candidates.erase(_last_phase_02_attack)
	if candidates.is_empty():
		_attack_gap_timer = 0.18
		return
	var selected: Attack = _select_weighted_attack(candidates, true)
	_attack_cursor += 1
	_last_phase_02_attack = selected
	match selected:
		Attack.BELL_CLEAVE: _run_phase_02_cleave()
		Attack.CHAIN_JUDGMENT: _run_chain_judgment()
		Attack.HOLLOW_TOLL: _run_hollow_toll()
		Attack.SCRIPTURE_BURIAL: _run_scripture_burial()
		Attack.PROCESSION: _run_procession()
		Attack.FOURTEENTH_SEAT: _run_fourteenth_seat()
		Attack.FIRE_SPELL: _run_fire_spell()
		Attack.ICE_SPELL: _run_ice_spell()
		Attack.MIRE_SPELL: _run_mire_spell()
		Attack.THREEFOLD_JUDGMENT: _run_threefold_judgment()
		Attack.WEIGHT_OF_ABSOLUTION: _run_weight_of_absolution()


func _append_magic_candidates(candidates: Array[Attack]) -> void:
	if _magic_global_cooldown > 0.0:
		return
	var statuses: PlayerStatusEffectController = _target_status_controller()
	if _fire_cooldown <= 0.0 and _last_magic != Attack.FIRE_SPELL:
		if statuses == null or not statuses.is_burning():
			candidates.append(Attack.FIRE_SPELL)
	if _ice_cooldown <= 0.0 and _ice_suppression_timer <= 0.0 and _last_magic != Attack.ICE_SPELL and not _target_is_frozen():
		if summon_director == null or summon_director.get_active_count() <= 1:
			candidates.append(Attack.ICE_SPELL)
	if (
		_mire_cooldown <= 0.0
		and _last_magic != Attack.MIRE_SPELL
		and not _has_active_mire()
		and _active_danger_zone_count() < 2
	):
		candidates.append(Attack.MIRE_SPELL)
	if (
		_lightning_cooldown <= 0.0
		and _last_magic != Attack.THREEFOLD_JUDGMENT
		and _post_gravity_pressure_lock <= 0.0
	):
		candidates.append(Attack.THREEFOLD_JUDGMENT)
	if (
		_phase == 2
		and _phase_02_opening_gravity_completed
		and _gravity_cooldown <= 0.0
		and _phase_02_elapsed >= config.gravity_first_cast_delay
		and _last_magic != Attack.WEIGHT_OF_ABSOLUTION
		and not _target_is_frozen()
		and _post_gravity_pressure_lock <= 0.0
	):
		candidates.append(Attack.WEIGHT_OF_ABSOLUTION)


func _can_select_summon(phase_02: bool) -> bool:
	if _target_is_frozen() or summon_director == null:
		return false
	if phase_02:
		return (
			_last_phase_02_attack != Attack.PROCESSION
			and _procession_cooldown <= 0.0
			and summon_director.can_summon_phase_2()
		)
	return (
		_last_phase_01_attack != Attack.SUMMON
		and _summon_cooldown <= 0.0
		and summon_director.can_summon_phase_1()
	)


func _select_weighted_attack(candidates: Array[Attack], phase_02: bool) -> Attack:
	var utility_count: int = 0
	for candidate: Attack in candidates:
		if candidate not in [Attack.SUMMON, Attack.PROCESSION, Attack.FIRE_SPELL, Attack.ICE_SPELL, Attack.MIRE_SPELL, Attack.THREEFOLD_JUDGMENT, Attack.WEIGHT_OF_ABSOLUTION]:
			utility_count += 1
	var weights: Array[float] = []
	var total_weight: float = 0.0
	for candidate: Attack in candidates:
		var weight: float = 1.0
		match candidate:
			Attack.SUMMON: weight = 22.0
			Attack.PROCESSION: weight = 27.0
			Attack.FIRE_SPELL: weight = 18.0
			Attack.ICE_SPELL: weight = 13.0 if phase_02 else 10.0
			Attack.MIRE_SPELL: weight = 15.0 if phase_02 else 10.0
			Attack.THREEFOLD_JUDGMENT: weight = 18.0 if phase_02 else 13.0
			Attack.WEIGHT_OF_ABSOLUTION:
				weight = 8.0
				if target != null and target.health_component.current_health > 75:
					weight *= 1.20
			_: weight = maxf(1.0, float(27 if phase_02 else 40) / float(maxi(1, utility_count)))
		weight *= _adaptive_attack_multiplier(candidate)
		weights.append(weight)
		total_weight += weight
	var rebuke_index: int = candidates.find(Attack.BELL_CLEAVE)
	if rebuke_index >= 0 and candidates.size() > 1:
		var ordinary_weight: float = total_weight - weights[rebuke_index]
		weights[rebuke_index] = minf(weights[rebuke_index], ordinary_weight * 0.70 / 0.30)
		total_weight = ordinary_weight + weights[rebuke_index]
	var roll: float = randf_range(0.0, maxf(0.01, total_weight))
	for index: int in range(candidates.size()):
		roll -= weights[index]
		if roll <= 0:
			_record_adaptive_decision(candidates[index], candidates, weights)
			return candidates[index]
	_record_adaptive_decision(candidates.back(), candidates, weights)
	return candidates.back()


func _active_danger_zone_count() -> int:
	var count: int = 1 if _has_active_mire() else 0
	if is_inside_tree():
		count += get_tree().get_nodes_in_group(&"chapter_03_boss_danger_zone").size()
	return count


func _start_debug_magic() -> void:
	if _action_locked:
		return
	match _debug_magic_mode:
		&"fire": _run_fire_spell()
		&"ice": _run_ice_spell()
		&"mire": _run_mire_spell()
		&"lightning": _run_threefold_judgment()
		&"gravity":
			if _phase == 2:
				_run_weight_of_absolution()
			else:
				_run_threefold_judgment()
		&"combo":
			var cycle: int = _attack_cursor % 4
			_attack_cursor += 1
			match cycle:
				0:
					if _can_select_summon(_phase == 2):
						if _phase == 2: _run_procession()
						else: _run_summon()
					else: _run_fire_spell()
				1: _run_fire_spell()
				2: _run_ice_spell() if not _target_is_frozen() else _run_fire_spell()
				_: _run_mire_spell() if not _has_active_mire() else _run_fire_spell()
		_:
			var magic_cycle: int = _attack_cursor % 4
			_attack_cursor += 1
			if magic_cycle == 0: _run_fire_spell()
			elif magic_cycle == 1: _run_ice_spell()
			elif magic_cycle == 2: _run_mire_spell()
			else: _run_threefold_judgment()


func _run_fire_spell() -> void:
	if not _begin_spell(State.FIRE_SPELL_WINDUP, &"fire_spell_windup", Attack.FIRE_SPELL):
		return
	_fire_cooldown = config.fire_cooldown
	var sequence_id: int = _spell_sequence_id
	if not await _spell_wait(config.fire_windup, sequence_id):
		return
	_set_state(State.FIRE_SPELL_RELEASE, &"fire_spell_release")
	_spawn_status_projectile(fireball_scene, config.fire_impact_damage, true)
	if not await _spell_wait(0.08, sequence_id):
		return
	_set_state(State.FIRE_SPELL_RECOVERY, &"fire_spell_recovery")
	if not await _spell_wait(config.fire_recovery, sequence_id):
		return
	_finish_spell(Attack.FIRE_SPELL)


func _run_ice_spell() -> void:
	if _target_is_frozen():
		_attack_gap_timer = 0.20
		return
	if not _begin_spell(State.ICE_SPELL_WINDUP, &"ice_spell_windup", Attack.ICE_SPELL):
		return
	_ice_cooldown = config.phase_2_ice_cooldown if _phase == 2 else config.phase_1_ice_cooldown
	var sequence_id: int = _spell_sequence_id
	if not await _spell_wait(config.ice_windup, sequence_id):
		return
	_set_state(State.ICE_SPELL_RELEASE, &"ice_spell_release")
	_spawn_status_projectile(ice_lance_scene, config.ice_impact_damage, false)
	if not await _spell_wait(0.08, sequence_id):
		return
	_set_state(State.ICE_SPELL_RECOVERY, &"ice_spell_recovery")
	if not await _spell_wait(config.ice_recovery, sequence_id):
		return
	_finish_spell(Attack.ICE_SPELL)


func _run_mire_spell() -> void:
	if _has_active_mire():
		_attack_gap_timer = 0.20
		return
	if not _begin_spell(State.MIRE_SPELL_WINDUP, &"mire_spell_windup", Attack.MIRE_SPELL):
		return
	_mire_cooldown = config.mire_cooldown
	var sequence_id: int = _spell_sequence_id
	if not await _spell_wait(config.mire_telegraph_delay, sequence_id):
		return
	_spawn_mire_telegraph()
	var follow_time: float = config.mire_target_lock_time - config.mire_telegraph_delay
	while follow_time > 0.0:
		if not _can_continue_spell(sequence_id):
			_cleanup_pending_magic()
			return
		if _mire_telegraph != null and target != null:
			_mire_telegraph.follow_target(target.global_position)
		var step: float = minf(0.05, follow_time)
		await get_tree().create_timer(step).timeout
		follow_time -= step
	_set_state(State.MIRE_TARGET_LOCK, &"mire_spell_target_lock")
	if _mire_telegraph != null:
		_mire_telegraph.lock_target()
	if not await _spell_wait(config.mire_cast_time - config.mire_target_lock_time, sequence_id):
		return
	_set_state(State.MIRE_SPELL_ACTIVATE, &"mire_spell_activate")
	_activate_mire_zone()
	if not await _spell_wait(0.10, sequence_id):
		return
	_set_state(State.MIRE_SPELL_RECOVERY, &"mire_spell_recovery")
	if not await _spell_wait(config.mire_recovery, sequence_id):
		return
	_finish_spell(Attack.MIRE_SPELL)


func _run_threefold_judgment() -> void:
	if not _begin_spell(State.LIGHTNING_SPELL_WINDUP, &"ice_spell_windup", Attack.THREEFOLD_JUDGMENT):
		return
	_lightning_cooldown = (
		config.phase_2_lightning_cooldown if _phase == 2
		else config.phase_1_lightning_cooldown
	)
	_lightning_targets.clear()
	var sequence_id: int = _spell_sequence_id
	if not await _spell_wait(config.lightning_windup, sequence_id):
		return
	_set_state(State.LIGHTNING_SPELL_RELEASE, &"ice_spell_release")
	for bolt_index: int in range(3):
		if not _can_continue_spell(sequence_id):
			_cleanup_pending_magic()
			return
		var target_position: Vector2 = get_historical_player_position(config.lightning_position_delay)
		_lightning_targets.append(target_position)
		_spawn_lightning_strike(target_position)
		if OS.is_debug_build():
			print("[THREEFOLD_JUDGMENT] bolt=%d now=%.2f sample_time=%.2f target=%s current=%s error=%.2f" % [
				bolt_index + 1, _behavior_clock, _behavior_clock - config.lightning_position_delay,
				target_position, target.global_position if target != null else Vector2.ZERO,
				get_historical_sample_error(config.lightning_position_delay),
			])
		if bolt_index < 2 and not await _spell_wait(config.lightning_strike_interval, sequence_id):
			return
	if not await _spell_wait(config.lightning_telegraph_duration, sequence_id):
		return
	_set_state(State.LIGHTNING_SPELL_RECOVERY, &"ice_spell_recovery")
	var recovery: float = config.phase_2_lightning_recovery if _phase == 2 else config.phase_1_lightning_recovery
	if not await _spell_wait(recovery, sequence_id):
		return
	_finish_spell(Attack.THREEFOLD_JUDGMENT)


func _spawn_lightning_strike(target_position: Vector2) -> void:
	if lightning_strike_scene == null:
		return
	var strike: PontiffLightningStrike = lightning_strike_scene.instantiate() as PontiffLightningStrike
	if strike == null:
		return
	_next_attack_id += 1
	strike.telegraph_duration = config.lightning_telegraph_duration
	strike.active_duration = config.lightning_active_duration
	strike.visual_duration = config.lightning_visual_duration
	strike.initialize(_next_attack_id, config.lightning_damage, self)
	strike.tree_exited.connect(_on_lightning_strike_exited.bind(strike), CONNECT_ONE_SHOT)
	get_parent().add_child(strike)
	strike.global_position = target_position
	_active_lightning_strikes.append(strike)


func _on_lightning_strike_exited(strike: PontiffLightningStrike) -> void:
	_active_lightning_strikes.erase(strike)


func _run_weight_of_absolution(forced_opening: bool = false) -> void:
	if _phase != 2 or (not forced_opening and _target_is_frozen()):
		_attack_gap_timer = 0.20
		return
	if forced_opening:
		if _phase_02_opening_gravity_started or current_state in [State.DEATH_SEQUENCE, State.DEAD]:
			return
		_phase_02_opening_gravity_started = true
		_phase_02_opening_cast_active = true
		_action_locked = true
		_spell_sequence_id += 1
		_last_magic = Attack.WEIGHT_OF_ABSOLUTION
		_set_state(State.GRAVITY_SPELL_WINDUP, &"weight_of_absolution_windup")
		_trace_phase_02_flow(&"GRAVITY_STATE_ENTER")
		_trace_phase_02_flow(&"GRAVITY_CAST_ANIMATION_BEGIN")
	elif not _begin_spell(
		State.GRAVITY_SPELL_WINDUP,
		&"weight_of_absolution_windup",
		Attack.WEIGHT_OF_ABSOLUTION
	):
		return
	else:
		_gravity_cooldown = config.gravity_cooldown
	_gravity_final_seal = false
	var sequence_id: int = _spell_sequence_id
	_spawn_gravity_judgment()
	if not await _spell_wait(config.gravity_final_seal_time, sequence_id):
		return
	_gravity_final_seal = true
	_set_state(State.GRAVITY_FINAL_SEAL, &"weight_of_absolution_final_seal")
	_trace_phase_02_flow(&"GRAVITY_FINAL_SEAL")
	if _gravity_judgment != null:
		_gravity_judgment.set_final_seal()
	if not await _spell_wait(config.gravity_cast_time - config.gravity_final_seal_time, sequence_id):
		return
	var result: Dictionary = resolve_weight_of_absolution_for_player(target)
	_trace_phase_02_flow(&"GRAVITY_HP_RESOLVE")
	if _gravity_judgment != null:
		_gravity_judgment.show_resolution(bool(result.get(&"compressed", false)))
	_set_state(State.GRAVITY_SPELL_RECOVERY, &"weight_of_absolution_recovery")
	_trace_phase_02_flow(&"GRAVITY_RECOVERY_BEGIN")
	_ice_suppression_timer = config.gravity_post_pressure_lock
	_post_gravity_pressure_lock = config.gravity_post_pressure_lock
	if not await _spell_wait(config.gravity_recovery, sequence_id):
		return
	_cleanup_gravity_judgment()
	_gravity_final_seal = false
	_finish_spell(Attack.WEIGHT_OF_ABSOLUTION)
	if forced_opening:
		_gravity_cooldown = config.gravity_cooldown
		_phase_02_opening_cast_active = false
		_phase_02_opening_gravity_completed = true
		_trace_phase_02_flow(&"GRAVITY_COMPLETE")


func _spawn_gravity_judgment() -> void:
	_cleanup_gravity_judgment()
	if gravity_judgment_scene == null or target == null:
		return
	_gravity_judgment = gravity_judgment_scene.instantiate() as PontiffGravityJudgment
	if _gravity_judgment == null:
		return
	_gravity_judgment.initialize(target, config.gravity_cast_time, self)
	get_parent().add_child(_gravity_judgment)


func resolve_weight_of_absolution_for_player(player: Player) -> Dictionary:
	var result: Dictionary = {
		&"hp_before": 0,
		&"target_hp": 0,
		&"hp_after": 0,
		&"amount_changed": 0,
		&"compressed": false,
		&"branch": &"INVALID_TARGET",
	}
	if player == null or not is_instance_valid(player) or player.health_component == null:
		return result
	var hp_before: int = player.health_component.current_health
	var target_hp: int = hp_before
	var branch: StringName = &"ALREADY_AT_OR_BELOW_FLOOR"
	if hp_before > config.gravity_health_threshold:
		target_hp = config.gravity_health_threshold
		branch = &"FORCE_TO_50"
		result[&"compressed"] = true
	elif hp_before > config.gravity_health_floor:
		target_hp = maxi(hp_before - config.gravity_direct_damage, config.gravity_health_floor)
		branch = &"DAMAGE_20_WITH_FLOOR"
	# This is one bounded HealthComponent mutation. It never routes through
	# Hurtbox/PlayerHurtController, so the judgment cannot emit physical hit,
	# knockback, hit-stop, blood, death, or healing events.
	player.health_component.set_current_health(target_hp)
	var hp_after: int = player.health_component.current_health
	result[&"hp_before"] = hp_before
	result[&"target_hp"] = target_hp
	result[&"hp_after"] = hp_after
	result[&"amount_changed"] = hp_before - hp_after
	result[&"branch"] = branch
	if OS.is_debug_build():
		print("[EDRAN_WEIGHT_OF_ABSOLUTION] implementation_state=IMPLEMENTED phase=%d hp_before=%d branch=%s target_hp=%d hp_after=%d cooldown=%.2f" % [
			_phase, hp_before, branch, target_hp, hp_after, config.gravity_cooldown,
		])
	return result


func _cleanup_gravity_judgment() -> void:
	if _gravity_judgment != null and is_instance_valid(_gravity_judgment):
		_gravity_judgment.finish()
	_gravity_judgment = null


func _begin_spell(state: State, animation: StringName, attack: Attack) -> bool:
	if _action_locked or current_state in [State.DORMANT, State.TRANSITION_PENDING, State.PHASE_TRANSITION, State.DEATH_SEQUENCE, State.DEAD, State.SUMMON]:
		return false
	_action_locked = true
	_spell_sequence_id += 1
	_last_magic = attack
	_set_state(state, animation)
	return true


func _spell_wait(duration: float, sequence_id: int) -> bool:
	var remaining: float = maxf(0.0, duration)
	while remaining > 0.0:
		var step: float = minf(0.05, remaining)
		await get_tree().create_timer(step).timeout
		remaining -= step
		if not _can_continue_spell(sequence_id):
			_cleanup_pending_magic()
			return false
	return true


func _can_continue_spell(sequence_id: int) -> bool:
	return (
		sequence_id == _spell_sequence_id
		and _is_spell_state(current_state)
		and health_component.current_health > (0 if _phase == 2 else config.phase_transition_health)
	)


func _finish_spell(attack: Attack) -> void:
	if not _is_spell_state(current_state):
		return
	_last_magic = attack
	_magic_global_cooldown = randf_range(
		config.phase_2_magic_global_cooldown_min if _phase == 2 else config.phase_1_magic_global_cooldown_min,
		config.phase_2_magic_global_cooldown_max if _phase == 2 else config.phase_1_magic_global_cooldown_max
	)
	_action_locked = false
	_chain_count = 0
	_attack_gap_timer = 0.35
	_set_state(State.IDLE, _idle_animation())


func _spawn_status_projectile(scene: PackedScene, damage: int, fire: bool) -> void:
	if scene == null:
		return
	var projectile: PontiffStatusProjectile = scene.instantiate() as PontiffStatusProjectile
	if projectile == null:
		return
	projectile.impact_damage = damage
	if fire:
		projectile.status_duration = config.burn_duration
		projectile.burn_tick_damage = config.burn_tick_damage
		projectile.burn_tick_interval = config.burn_tick_interval
	else:
		projectile.status_duration = config.freeze_duration
		projectile.freeze_immunity_duration = config.freeze_immunity_duration
	_next_attack_id += 1
	get_parent().add_child(projectile)
	projectile.global_position = global_position + Vector2(facing * 42.0, -48.0)
	projectile.initialize(facing, _next_attack_id, self)


func _spawn_mire_telegraph() -> void:
	if mire_telegraph_scene == null or target == null:
		return
	_cleanup_pending_magic()
	_mire_telegraph = mire_telegraph_scene.instantiate() as PontiffMireTelegraph
	if _mire_telegraph == null:
		return
	get_parent().add_child(_mire_telegraph)
	_mire_telegraph.global_position = target.global_position


func _activate_mire_zone() -> void:
	if _mire_telegraph == null or mire_zone_scene == null:
		_cleanup_pending_magic()
		return
	var locked_position: Vector2 = _mire_telegraph.global_position
	_mire_telegraph.finish()
	_mire_telegraph = null
	_active_mire = mire_zone_scene.instantiate() as PontiffMireZone
	if _active_mire == null:
		return
	_active_mire.duration = config.mire_duration
	_active_mire.movement_multiplier = config.mire_move_multiplier
	_active_mire.dash_multiplier = config.mire_dash_multiplier
	get_parent().add_child(_active_mire)
	_active_mire.global_position = locked_position
	_active_mire.expired.connect(_on_mire_expired)


func _cleanup_pending_magic() -> void:
	if _mire_telegraph != null and is_instance_valid(_mire_telegraph):
		_mire_telegraph.finish()
	_mire_telegraph = null
	for strike: PontiffLightningStrike in _active_lightning_strikes.duplicate():
		if strike != null and is_instance_valid(strike):
			strike.cancel()
	_active_lightning_strikes.clear()
	_cleanup_gravity_judgment()
	_gravity_final_seal = false


func _clear_all_magic() -> void:
	_spell_sequence_id += 1
	_cleanup_pending_magic()
	if _active_mire != null and is_instance_valid(_active_mire):
		_active_mire.force_expire()
	_active_mire = null
	var statuses: PlayerStatusEffectController = _target_status_controller()
	if statuses != null:
		statuses.clear_all()


func _on_mire_expired() -> void:
	_active_mire = null


func _has_active_mire() -> bool:
	return _active_mire != null and is_instance_valid(_active_mire) and not _active_mire.is_queued_for_deletion()


func _target_status_controller() -> PlayerStatusEffectController:
	return target.status_effect_controller if target != null and is_instance_valid(target) else null


func _target_is_frozen() -> bool:
	var statuses: PlayerStatusEffectController = _target_status_controller()
	return statuses != null and statuses.is_frozen()


func _is_spell_state(state: State) -> bool:
	return state in [
		State.FIRE_SPELL_WINDUP, State.FIRE_SPELL_RELEASE, State.FIRE_SPELL_RECOVERY,
		State.ICE_SPELL_WINDUP, State.ICE_SPELL_RELEASE, State.ICE_SPELL_RECOVERY,
		State.MIRE_SPELL_WINDUP, State.MIRE_TARGET_LOCK, State.MIRE_SPELL_ACTIVATE,
		State.MIRE_SPELL_RECOVERY,
		State.LIGHTNING_SPELL_WINDUP, State.LIGHTNING_SPELL_RELEASE,
		State.LIGHTNING_SPELL_RECOVERY, State.GRAVITY_SPELL_WINDUP,
		State.GRAVITY_FINAL_SEAL, State.GRAVITY_SPELL_RECOVERY,
	]


func _configure_debug_mode_from_run() -> void:
	if not OS.is_debug_build():
		return
	var debug: DebugRunConfigState = get_node_or_null("/root/DebugRunConfig") as DebugRunConfigState
	if debug == null:
		return
	match debug.debug_start_spawn_id:
		&"CH3_BOSS_FIRE_TEST": _debug_magic_mode = &"fire"
		&"CH3_BOSS_ICE_TEST": _debug_magic_mode = &"ice"
		&"CH3_BOSS_MIRE_TEST": _debug_magic_mode = &"mire"
		&"CH3_BOSS_LIGHTNING_TEST": _debug_magic_mode = &"lightning"
		&"CH3_BOSS_GRAVITY_TEST": _debug_magic_mode = &"gravity"
		&"CH3_BOSS_MAGIC_TEST": _debug_magic_mode = &"magic"
		&"CH3_BOSS_SUMMON_MAGIC_COMBO": _debug_magic_mode = &"combo"


func _run_phase_02_cleave() -> void:
	if not _begin_phase_02_action(&"bell_bound_cleave"):
		return
	await get_tree().create_timer(config.bell_cleave_windup).timeout
	if not _can_finish_action():
		_end_action()
		return
	_next_attack_id += 1
	phase_02_cleave_hitbox.begin_attack(_next_attack_id, config.bell_cleave_damage, facing, self)
	attack_window_changed.emit(&"bell_bound_cleave", true)
	await get_tree().create_timer(config.bell_cleave_active).timeout
	phase_02_cleave_hitbox.end_attack()
	attack_window_changed.emit(&"bell_bound_cleave", false)
	await get_tree().create_timer(config.bell_cleave_recovery).timeout
	_end_action()


func _run_hollow_toll() -> void:
	if not _begin_phase_02_action(&"hollow_toll"):
		return
	_hollow_toll_cooldown = config.hollow_toll_cooldown
	await get_tree().create_timer(config.hollow_toll_windup).timeout
	if _can_finish_action():
		var field_position: Vector2 = target.global_position if target != null else global_position + Vector2(facing * 100.0,0.0)
		_spawn_field(field_position,config.hollow_toll_damage,0.20)
	await get_tree().create_timer(config.hollow_toll_recovery).timeout
	_end_action()


func _run_chain_judgment() -> void:
	if not _begin_phase_02_action(&"censer_chain_hit_01"):
		return
	await get_tree().create_timer(config.chain_judgment_windup).timeout
	if not _can_finish_action():
		_end_action()
		return
	_next_attack_id += 1
	phase_02_chain_hitbox.begin_attack(_next_attack_id,config.chain_judgment_first_damage,facing,self)
	attack_window_changed.emit(&"censer_chain_judgment_01",true)
	await get_tree().create_timer(config.chain_judgment_first_active).timeout
	phase_02_chain_hitbox.end_attack()
	attack_window_changed.emit(&"censer_chain_judgment_01",false)
	await get_tree().create_timer(config.chain_judgment_stage_gap).timeout
	if not _can_finish_action():
		_end_action()
		return
	_play_animation(&"censer_chain_hit_02")
	_next_attack_id += 1
	phase_02_chain_hitbox.begin_attack(_next_attack_id,config.chain_judgment_second_damage,facing,self)
	attack_window_changed.emit(&"censer_chain_judgment_02",true)
	await get_tree().create_timer(config.chain_judgment_second_active).timeout
	phase_02_chain_hitbox.end_attack()
	attack_window_changed.emit(&"censer_chain_judgment_02",false)
	await get_tree().create_timer(config.chain_judgment_recovery).timeout
	_end_action()


func _run_scripture_burial() -> void:
	if not _begin_phase_02_action(&"scripture_burial"):
		return
	_scripture_burial_cooldown = config.scripture_burial_cooldown
	await get_tree().create_timer(config.scripture_burial_cast).timeout
	if _can_finish_action() and target != null:
		for index: int in range(config.scripture_burial_zone_count):
			var offset: float = -64.0 if index == 0 else 64.0
			_spawn_field(target.global_position + Vector2(offset,0.0),config.scripture_burial_damage,config.scripture_burial_delay)
	await get_tree().create_timer(0.72).timeout
	_end_action()


func _run_procession() -> void:
	if not _begin_phase_02_action(&"procession_summon"):
		return
	_procession_cooldown = randf_range(
		config.phase_02_summon_cooldown_min, config.phase_02_summon_cooldown_max
	)
	await get_tree().create_timer(config.procession_windup).timeout
	if _can_finish_action() and summon_director != null and not _target_is_frozen():
		summon_director.summon_phase_2(target)
	await get_tree().create_timer(config.procession_recovery).timeout
	_end_action()


func _run_fourteenth_seat() -> void:
	if not _begin_phase_02_action(&"fourteenth_seat"):
		return
	_fourteenth_seat_cooldown = config.fourteenth_seat_cooldown
	await get_tree().create_timer(config.fourteenth_seat_warning).timeout
	if _can_finish_action() and target != null:
		_spawn_field(target.global_position,config.fourteenth_seat_damage,0.18)
	await get_tree().create_timer(0.88).timeout
	_end_action()


func _begin_phase_02_action(animation_name: StringName) -> bool:
	if _phase != 2 or _action_locked or current_state in [State.PHASE_TRANSITION,State.DEATH_SEQUENCE,State.DEAD]:
		return false
	_action_locked = true
	_set_state(State.ATTACK,animation_name)
	return true


func _run_turn(desired_facing: float) -> void:
	if _action_locked:
		return
	_action_locked = true
	_set_state(State.TURN, &"phase_02_turn" if _phase == 2 else &"turn")
	var reaction_delay: float = config.phase_02_turn_reaction_delay if _phase == 2 else config.turn_reaction_delay
	var duration: float = config.phase_02_turn_animation_duration if _phase == 2 else config.turn_animation_duration
	await get_tree().create_timer(reaction_delay).timeout
	await get_tree().create_timer(duration * config.turn_facing_commit_ratio).timeout
	if current_state != State.TURN:
		_action_locked = false
		return
	_set_facing(desired_facing)
	await get_tree().create_timer(duration * (1.0 - config.turn_facing_commit_ratio)).timeout
	_action_locked = false
	if current_state == State.TURN:
		_set_state(State.IDLE, _idle_animation())


func _run_melee_attack(attack: Attack) -> void:
	if _action_locked:
		return
	_action_locked = true
	_set_state(State.ATTACK)
	var windup_animation: StringName
	var active_animation: StringName
	var recovery_animation: StringName
	var attack_name: StringName
	var windup: float
	var active: float
	var recovery: float
	var damage: int
	var hitbox: HitboxComponent
	match attack:
		Attack.SWEEP:
			attack_name = &"pontifical_sweep"; windup_animation = &"pontifical_sweep_windup"; active_animation = &"pontifical_sweep_active"; recovery_animation = &"pontifical_sweep_recovery"
			windup = config.sweep_windup; active = config.sweep_active; recovery = config.sweep_recovery; damage = config.sweep_damage; hitbox = sweep_hitbox
		Attack.THRUST:
			attack_name = &"crozier_thrust"; windup_animation = &"crozier_thrust_windup"; active_animation = &"crozier_thrust_active"; recovery_animation = &"crozier_thrust_recovery"
			windup = config.thrust_windup; active = config.thrust_active; recovery = config.thrust_recovery; damage = config.thrust_damage; hitbox = thrust_hitbox
		_:
			attack_name = &"censer_procession"; windup_animation = &"censer_procession_windup"; active_animation = &"censer_procession_active"; recovery_animation = &"censer_procession_recovery"
			windup = config.censer_windup; active = config.censer_active; recovery = config.censer_recovery; damage = config.censer_damage; hitbox = censer_hitbox
			_censer_cooldown = randf_range(config.censer_cooldown_min, config.censer_cooldown_max)
	_play_animation(windup_animation)
	await get_tree().create_timer(windup).timeout
	if not _can_finish_action():
		_end_action()
		return
	_play_animation(active_animation)
	_next_attack_id += 1
	hitbox.begin_attack(_next_attack_id, damage, facing, self)
	attack_window_changed.emit(attack_name, true)
	await get_tree().create_timer(active).timeout
	hitbox.end_attack()
	attack_window_changed.emit(attack_name, false)
	_play_animation(recovery_animation)
	await get_tree().create_timer(recovery).timeout
	_end_action()


func _run_litany() -> void:
	if _action_locked:
		return
	_action_locked = true
	_litany_cooldown = config.litany_cooldown
	_set_state(State.ATTACK, &"litany_cast")
	await get_tree().create_timer(config.litany_cast_duration).timeout
	if _can_finish_action() and target != null:
		var seal_count: int = randi_range(config.litany_seal_count_min, config.litany_seal_count_max)
		for index: int in range(seal_count):
			_spawn_field(target.global_position + Vector2((index - 1) * 54.0, -4.0), config.litany_damage, randf_range(config.litany_seal_delay_min, config.litany_seal_delay_max))
	_end_action()


func _run_thirteenfold() -> void:
	if _action_locked:
		return
	_action_locked = true
	_thirteenfold_cooldown = config.thirteenfold_cooldown
	_set_state(State.ATTACK, &"thirteenfold_sentence")
	await get_tree().create_timer(config.thirteenfold_cast_duration).timeout
	for wave: int in range(config.thirteenfold_wave_count):
		if not _can_finish_action():
			break
		var center: Vector2 = target.global_position if target != null else global_position
		_spawn_field(center + Vector2((wave - 1) * 88.0, -4.0), config.thirteenfold_damage, 0.18)
		await get_tree().create_timer(config.thirteenfold_wave_gap).timeout
	_end_action()


func _run_summon() -> void:
	if _action_locked or summon_director == null or not summon_director.can_summon_phase_1():
		return
	_action_locked = true
	_summon_interrupt_progress = 0
	_summon_sequence_id += 1
	var sequence_id: int = _summon_sequence_id
	_set_state(State.SUMMON, &"summon_start")
	await get_tree().create_timer(config.summon_windup).timeout
	if current_state != State.SUMMON or sequence_id != _summon_sequence_id:
		return
	if _target_is_frozen():
		_finish_summon_action(true)
		return
	summon_director.summon_phase_1(target)
	_play_animation(&"summon_success")
	await get_tree().create_timer(config.summon_recovery).timeout
	if current_state != State.SUMMON or sequence_id != _summon_sequence_id:
		return
	_finish_summon_action(false)


func _interrupt_summon() -> void:
	if current_state != State.SUMMON:
		return
	_summon_sequence_id += 1
	_end_all_hitboxes()
	_play_animation(&"summon_interrupt")
	await get_tree().create_timer(config.summon_interrupt_recovery).timeout
	if current_state != State.SUMMON:
		return
	_finish_summon_action(true)


func _finish_summon_action(interrupted: bool) -> void:
	_summon_cooldown = (
		config.summon_interrupt_cooldown
		if interrupted
		else randf_range(config.summon_cooldown_min, config.summon_cooldown_max)
	)
	_summon_interrupt_progress = 0
	if not interrupted:
		_thirteenfold_cooldown = maxf(_thirteenfold_cooldown, config.post_summon_major_lock)
	_action_locked = false
	_attack_gap_timer = config.summon_interrupt_recovery if interrupted else config.summon_recovery
	_set_state(State.IDLE, &"phase_01_idle")


func _spawn_field(position: Vector2, damage: int, delay: float) -> void:
	if timed_field_scene == null:
		return
	var field: Chapter03TimedField = timed_field_scene.instantiate() as Chapter03TimedField
	if field == null:
		return
	field.mode = Chapter03TimedField.Mode.SEAL
	field.duration = delay + 0.20
	field.damage = damage
	field.z_index = Chapter03LayerContract.COMBAT_FX
	field.add_to_group(&"chapter_03_boss_danger_zone")
	get_parent().add_child(field)
	field.global_position = position


func _end_action() -> void:
	for hitbox: HitboxComponent in [sweep_hitbox, thrust_hitbox, censer_hitbox, phase_02_cleave_hitbox, phase_02_chain_hitbox]:
		hitbox.end_attack()
	_action_locked = false
	if current_state != State.ATTACK:
		return
	_chain_count += 1
	var chain_limit: int = config.phase_02_chain_limit if _phase == 2 else config.chain_limit
	if _chain_count >= chain_limit:
		_chain_count = 0
		_attack_gap_timer = randf_range(config.phase_02_chain_recovery_min,config.phase_02_chain_recovery_max) if _phase == 2 else config.chain_recovery
	else:
		_attack_gap_timer = randf_range(config.phase_02_min_attack_gap,config.phase_02_max_attack_gap) if _phase == 2 else randf_range(config.phase_1_min_attack_gap, config.phase_1_max_attack_gap)
	_set_state(State.IDLE, _idle_animation())


func _can_finish_action() -> bool:
	return current_state == State.ATTACK and health_component.current_health > (0 if _phase == 2 else config.phase_transition_health)


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	if hitbox == null or current_state in [State.DORMANT, State.TRANSITION_PENDING, State.PHASE_TRANSITION, State.DEATH_SEQUENCE, State.DEAD]:
		return
	var poise_damage: int = config.dash_attack_poise_damage if hitbox.attack_kind == &"dash_attack" else config.normal_attack_poise_damage
	if current_state == State.SUMMON:
		_summon_interrupt_progress += poise_damage
		if _summon_interrupt_progress >= config.summon_interrupt_poise:
			_interrupt_summon()
		else:
			_play_animation(&"light_hit")
		return
	current_poise = maxi(0, current_poise - poise_damage)
	if _phase_02_opening_cast_active and _is_spell_state(current_state):
		current_poise = maxi(1, current_poise)
		return
	if current_state == State.GRAVITY_FINAL_SEAL and _gravity_final_seal:
		current_poise = maxi(1, current_poise)
		return
	if current_poise <= 0 and _stagger_protection_timer <= 0.0:
		_run_stagger()
	elif not _is_spell_state(current_state):
		_play_animation(&"light_hit")


func _run_stagger() -> void:
	if current_state in [State.TRANSITION_PENDING, State.PHASE_TRANSITION, State.DEATH_SEQUENCE, State.DEAD]:
		return
	if _phase_02_opening_cast_active:
		return
	var interrupted_gravity: bool = current_state == State.GRAVITY_SPELL_WINDUP and not _gravity_final_seal
	if interrupted_gravity:
		_gravity_cooldown = config.gravity_interrupt_cooldown
	_action_locked = true
	_spell_sequence_id += 1
	_cleanup_pending_magic()
	_end_all_hitboxes()
	_set_state(State.STAGGER, &"stagger")
	var duration: float = config.phase_02_stagger_duration if _phase == 2 else config.stagger_duration
	await get_tree().create_timer(duration).timeout
	if current_state != State.STAGGER:
		return
	current_poise = config.phase_02_max_poise if _phase == 2 else config.max_poise
	_stagger_protection_timer = config.phase_02_stagger_protection_duration if _phase == 2 else config.stagger_protection_duration
	_action_locked = false
	_attack_gap_timer = 0.42
	_set_state(State.IDLE, _idle_animation())


func _on_health_changed(current: int, _maximum: int) -> void:
	if _phase != 1 or current > config.phase_transition_health or _transition_emitted or current_state == State.DEAD:
		return
	_transition_emitted = true
	_reset_phase_02_opening_flow()
	_trace_phase_02_flow(&"PHASE_2_THRESHOLD_REACHED")
	health_component.set_current_health(config.phase_transition_health)
	_action_locked = true
	velocity = Vector2.ZERO
	_end_all_hitboxes()
	_clear_all_magic()
	if summon_director != null:
		summon_director.force_dissolve_all()
	hurtbox.set_invulnerable(true)
	_set_state(State.TRANSITION_PENDING, &"phase_transition_start")
	phase_transition_requested.emit(config.phase_transition_health)
	call_deferred("_run_phase_transition")


func _run_phase_transition() -> void:
	if current_state != State.TRANSITION_PENDING:
		return
	_set_state(State.PHASE_TRANSITION)
	_trace_phase_02_flow(&"PHASE_2_TRANSITION_BEGIN")
	phase_transition_started.emit()
	var previous_input_profile: Player.InputProfile = Player.InputProfile.FULL
	var player_was_invulnerable: bool = false
	if target != null:
		previous_input_profile = target.get_input_profile()
		player_was_invulnerable = target.hurtbox != null and target.hurtbox.is_invulnerable
		target.set_input_profile(Player.InputProfile.LOCKED)
		target.velocity = Vector2.ZERO
		if target.hurtbox != null:
			target.hurtbox.set_invulnerable(true)
	var center_tween: Tween = create_tween()
	center_tween.tween_property(self,"global_position:x",_spawn_position.x,0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await center_tween.finished
	if phase_transition_frames != null:
		sprite.sprite_frames = phase_transition_frames
	var sequence: Array[StringName] = [
		&"seals_break",&"crown_crack",&"mask_void_reveal",&"vestment_split",&"chest_open",
		&"rib_frame_extend",&"black_bell_reveal",&"arm_lengthen",&"crozier_fuse",
		&"censer_chain_bind",&"phase_02_rise",
	]
	var step_duration: float = (config.phase_transition_duration - 0.35) / float(sequence.size())
	for animation: StringName in sequence:
		_play_animation(animation)
		phase_transition_stage_reached.emit(animation)
		await get_tree().create_timer(step_duration).timeout
	_phase = 2
	_phase_02_elapsed = 0.0
	current_poise = config.phase_02_max_poise
	if phase_02_frames != null:
		sprite.sprite_frames = phase_02_frames
	_set_state(State.IDLE,&"phase_02_idle")
	phase_changed.emit(2)
	await get_tree().create_timer(config.phase_02_ready_delay).timeout
	_phase_02_transition_complete = true
	while not _phase_02_dialogue_complete and current_state not in [State.DEATH_SEQUENCE, State.DEAD]:
		await get_tree().process_frame
	if current_state in [State.DEATH_SEQUENCE, State.DEAD]:
		return
	hurtbox.set_invulnerable(false)
	if target != null:
		if target.hurtbox != null and not player_was_invulnerable:
			target.hurtbox.set_invulnerable(false)
		target.set_input_profile(previous_input_profile)
	_trace_phase_02_flow(&"GRAVITY_OPENING_REQUESTED")
	await _run_weight_of_absolution(true)
	if not _phase_02_opening_gravity_completed or current_state in [State.DEATH_SEQUENCE, State.DEAD]:
		return
	_phase_02_normal_ai_enabled = true
	_attack_gap_timer = config.phase_02_min_attack_gap
	_trace_phase_02_flow(&"PHASE_2_NORMAL_AI_BEGIN")
	phase_transition_finished.emit()


func _on_died() -> void:
	if current_state in [State.DEATH_SEQUENCE,State.DEAD]:
		return
	call_deferred("_run_death_sequence")


func _run_death_sequence() -> void:
	_action_locked = true
	_end_all_hitboxes()
	_clear_all_magic()
	if summon_director != null:
		summon_director.force_dissolve_all()
	hurtbox.set_enabled(false)
	velocity = Vector2.ZERO
	_set_state(State.DEATH_SEQUENCE)
	death_sequence_started.emit()
	if phase_02_frames != null:
		sprite.sprite_frames = phase_02_frames
	var sequence: Array[StringName] = [
		&"death_crozier_break",&"death_censer_drop",&"death_bell_fall",&"death_collapse",&"death_dissolve",
	]
	var step_duration: float = config.death_sequence_duration / float(sequence.size())
	for animation: StringName in sequence:
		_play_animation(animation)
		await get_tree().create_timer(step_duration).timeout
	_set_state(State.DEAD)
	sprite.visible = false
	if not _defeat_emitted:
		_defeat_emitted = true
		defeated.emit()


func _reset_phase_02_opening_flow() -> void:
	_phase_02_transition_complete = false
	_phase_02_dialogue_active = false
	_phase_02_dialogue_complete = false
	_phase_02_opening_gravity_started = false
	_phase_02_opening_gravity_completed = false
	_phase_02_opening_cast_active = false
	_phase_02_normal_ai_enabled = false


func _trace_phase_02_flow(event_name: StringName) -> void:
	phase_02_flow_event.emit(event_name)
	if not OS.is_debug_build():
		return
	var player_instance_id: int = 0
	var player_hp: int = -1
	var health_path: String = "<none>"
	if target != null and is_instance_valid(target):
		player_instance_id = target.get_instance_id()
		if target.health_component != null:
			player_hp = target.health_component.current_health
			health_path = String(target.health_component.get_path())
	var message: String = (
		"[EDRAN_PHASE2_FLOW] event=%s time=%.3f phase=%d state=%s dialogue_active=%s "
		+ "transition_complete=%s gravity_started=%s gravity_completed=%s animation=%s "
		+ "player_instance_id=%d health_component_path=%s player_hp=%d"
	) % [
			event_name,
			Time.get_ticks_msec() / 1000.0,
			_phase,
			get_state_name(),
			_phase_02_dialogue_active,
			_phase_02_transition_complete,
			_phase_02_opening_gravity_started,
			_phase_02_opening_gravity_completed,
			sprite.animation,
			player_instance_id,
			health_path,
			player_hp,
		]
	print(message)


func _set_state(next_state: State, animation_name: StringName = &"") -> void:
	if current_state == next_state and animation_name.is_empty():
		return
	current_state = next_state
	if not animation_name.is_empty():
		_play_animation(animation_name)
	state_changed.emit(get_state_name())


func _play_animation(animation_name: StringName) -> void:
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name or not sprite.is_playing():
			sprite.play(animation_name)


func _set_facing(direction: float) -> void:
	if is_zero_approx(direction):
		return
	facing = signf(direction)
	sprite.flip_h = facing < 0.0
	facing_root.scale.x = facing


func _end_all_hitboxes() -> void:
	sweep_hitbox.end_attack()
	thrust_hitbox.end_attack()
	censer_hitbox.end_attack()
	phase_02_cleave_hitbox.end_attack()
	phase_02_chain_hitbox.end_attack()


func _idle_animation() -> StringName:
	return &"phase_02_idle" if _phase == 2 else &"phase_01_idle"


func _selection_range() -> float:
	return config.chain_judgment_range + 80.0 if _phase == 2 else config.thrust_range + 80.0


func _observe_target_behavior(delta: float) -> void:
	_behavior_clock += delta
	var decay: float = BEHAVIOR_DECAY_PER_SECOND * delta
	far_pressure = maxf(0.0, far_pressure - decay)
	close_pressure = maxf(0.0, close_pressure - decay)
	air_pressure = maxf(0.0, air_pressure - decay)
	crossup_pressure = maxf(0.0, crossup_pressure - decay)
	dash_pressure = maxf(0.0, dash_pressure - decay)
	attack_pressure = maxf(0.0, attack_pressure - decay)
	_apply_due_behavior_events()
	if target == null or not is_instance_valid(target) or target.is_dead():
		return
	_position_sample_timer -= delta
	if _position_sample_timer <= 0.0:
		_position_sample_timer = config.lightning_history_sample_interval
		_record_player_position(target.global_position)
	_behavior_sample_timer -= delta
	if _behavior_sample_timer <= 0.0:
		_behavior_sample_timer = BEHAVIOR_SAMPLE_INTERVAL
		var distance: float = absf(target.global_position.x - global_position.x)
		if distance >= 205.0: _queue_behavior_event(&"far", 0.055)
		elif distance <= 78.0: _queue_behavior_event(&"close", 0.055)
		if not target.is_on_floor(): _queue_behavior_event(&"air", 0.045)
		if absf(target.velocity.x) >= 225.0: _queue_behavior_event(&"dash", 0.035)
	var side: float = signf(target.global_position.x - global_position.x)
	var action_name: StringName = target.action_controller.get_action_state_name() if target.action_controller != null else &"None"
	var movement_name: StringName = target.get_movement_state_name()
	if not is_zero_approx(_previous_target_side) and side != _previous_target_side and not target.is_on_floor() and absf(target.global_position.y - global_position.y) < 112.0:
		observed_crossup_count += 1
		_queue_behavior_event(&"crossup", 0.30)
	if movement_name != _previous_target_movement:
		if movement_name in [&"jump_start", &"double_jump"]: observed_jump_count += 1
		if movement_name == &"double_jump": observed_double_jump_count += 1
	if action_name != _previous_target_action:
		if String(action_name).contains("Dash"): _queue_behavior_event(&"dash", 0.22)
		elif String(action_name).contains("Attack"): _queue_behavior_event(&"attack", 0.15)
	if not is_zero_approx(_previous_target_side) and side != _previous_target_side and String(action_name).contains("Dash"):
		observed_dash_through_count += 1
	_previous_target_side = side
	_previous_target_action = action_name
	_previous_target_movement = movement_name


func _queue_behavior_event(kind_name: StringName, amount: float) -> void:
	_behavior_events.append({&"at": _behavior_clock + BEHAVIOR_REACTION_DELAY, &"kind": kind_name, &"amount": amount * (1.14 if _phase == 2 else 1.0)})


func _apply_due_behavior_events() -> void:
	while not _behavior_events.is_empty() and float(_behavior_events.front().get(&"at", INF)) <= _behavior_clock:
		var event: Dictionary = _behavior_events.pop_front()
		var amount: float = float(event.get(&"amount", 0.0))
		var kind_name := StringName(event.get(&"kind", &""))
		match kind_name:
			&"far": far_pressure = minf(1.0, far_pressure + amount)
			&"close": close_pressure = minf(1.0, close_pressure + amount)
			&"air": air_pressure = minf(1.0, air_pressure + amount)
			&"crossup": crossup_pressure = minf(1.0, crossup_pressure + amount)
			&"dash": dash_pressure = minf(1.0, dash_pressure + amount)
			&"attack": attack_pressure = minf(1.0, attack_pressure + amount)


func _adaptive_attack_multiplier(attack: Attack) -> float:
	var multiplier: float = 1.0
	match attack:
		Attack.FIRE_SPELL:
			multiplier *= 1.0 + far_pressure * 0.80
		Attack.ICE_SPELL:
			multiplier *= 1.0 + air_pressure * 0.40
		Attack.MIRE_SPELL:
			multiplier *= 1.0 + dash_pressure * 0.75
		Attack.THREEFOLD_JUDGMENT:
			multiplier *= 1.0 + far_pressure * 0.95
			if get_recent_player_movement_distance(1.0) <= 12.0:
				multiplier *= 1.20
		Attack.WEIGHT_OF_ABSOLUTION:
			multiplier *= 1.0
		Attack.SUMMON, Attack.PROCESSION:
			multiplier *= 1.0 + far_pressure * 0.35
		Attack.SWEEP, Attack.THRUST, Attack.CENSER, Attack.CHAIN_JUDGMENT:
			multiplier *= 1.0 + close_pressure * 0.62 + attack_pressure * 0.25
		Attack.BELL_CLEAVE:
			# Existing crozier/censer art becomes Bellward Rebuke when selected
			# against a learned crossup pattern; its authored windup remains intact.
			multiplier *= 1.0 + crossup_pressure * 1.65 + air_pressure * 0.35
		_:
			pass
	return clampf(multiplier, 0.35, 2.75)


func _record_adaptive_decision(
	attack: Attack, candidates: Array[Attack], weights: Array[float]
) -> void:
	_adaptive_decision_reason = StringName("%s:F%.2f:C%.2f:A%.2f:X%.2f:D%.2f" % [Attack.keys()[attack], far_pressure, close_pressure, air_pressure, crossup_pressure, dash_pressure])
	if OS.is_debug_build():
		var distance: float = absf(target.global_position.x - global_position.x) if target != null and is_instance_valid(target) else INF
		var candidate_names: Array[StringName] = []
		for candidate: Attack in candidates:
			candidate_names.append(StringName(Attack.keys()[candidate]))
		var recent_attack: Attack = _last_phase_02_attack if _phase == 2 else _last_phase_01_attack
		print("[BOSS_DECISION] boss=ThirteenthPontiff phase=%d distance=%.1f pressure=[far=%.2f close=%.2f air=%.2f cross=%.2f dash=%.2f] recent=%s candidates=%s weights=%s selected=%s reason=%s" % [_phase, distance, far_pressure, close_pressure, air_pressure, crossup_pressure, dash_pressure, Attack.keys()[recent_attack], candidate_names, weights, Attack.keys()[attack], _adaptive_decision_reason])


func get_behavior_pressures() -> Dictionary[StringName, float]:
	return {&"far": far_pressure, &"close": close_pressure, &"air": air_pressure, &"crossup": crossup_pressure, &"dash": dash_pressure, &"attack": attack_pressure}


func get_adaptive_decision_reason() -> StringName:
	return _adaptive_decision_reason


func get_debug_summary() -> String:
	var history_position: Vector2 = get_historical_player_position(config.lightning_position_delay)
	return "EDRAN P%d %s HP %d/%d AI[%s F%.2f C%.2f A%.2f X%.2f D%.2f J%d DJ%d X%d DT%d] POS[now=%s past=%s bolts=%s]" % [
		_phase, State.keys()[current_state], health_component.current_health,
		health_component.max_health, _adaptive_decision_reason, far_pressure,
		close_pressure, air_pressure, crossup_pressure, dash_pressure,
		observed_jump_count, observed_double_jump_count, observed_crossup_count, observed_dash_through_count,
		target.global_position if target != null and is_instance_valid(target) else Vector2.ZERO,
		history_position, _lightning_targets,
	]


func _record_player_position(position: Vector2) -> void:
	_player_position_history.append({&"time": _behavior_clock, &"position": position})
	var oldest_time: float = _behavior_clock - config.lightning_history_duration
	while not _player_position_history.is_empty() and float(_player_position_history.front().get(&"time", 0.0)) < oldest_time:
		_player_position_history.pop_front()


func get_historical_player_position(delay: float) -> Vector2:
	if _player_position_history.is_empty():
		return target.global_position if target != null and is_instance_valid(target) else global_position
	var requested_time: float = _behavior_clock - maxf(0.0, delay)
	var best_position: Vector2 = Vector2(_player_position_history.front().get(&"position", global_position))
	var best_error: float = INF
	for sample: Dictionary in _player_position_history:
		var error: float = absf(float(sample.get(&"time", 0.0)) - requested_time)
		if error < best_error:
			best_error = error
			best_position = Vector2(sample.get(&"position", best_position))
	return best_position


func get_historical_sample_error(delay: float) -> float:
	if _player_position_history.is_empty():
		return INF
	var requested_time: float = _behavior_clock - maxf(0.0, delay)
	var best_error: float = INF
	for sample: Dictionary in _player_position_history:
		best_error = minf(best_error, absf(float(sample.get(&"time", 0.0)) - requested_time))
	return best_error


func get_recent_player_movement_distance(duration: float) -> float:
	if _player_position_history.size() < 2:
		return 0.0
	var start: Vector2 = get_historical_player_position(duration)
	var finish: Vector2 = Vector2(_player_position_history.back().get(&"position", start))
	return start.distance_to(finish)


func _reset_behavior_context() -> void:
	far_pressure = 0.0
	close_pressure = 0.0
	air_pressure = 0.0
	crossup_pressure = 0.0
	dash_pressure = 0.0
	attack_pressure = 0.0
	_behavior_clock = 0.0
	_behavior_sample_timer = 0.0
	_position_sample_timer = 0.0
	_behavior_events.clear()
	_player_position_history.clear()
	_lightning_targets.clear()
	_previous_target_side = 0.0
	_previous_target_action = &"None"
	_previous_target_movement = &"idle"
	_adaptive_decision_reason = &"base"
	observed_jump_count = 0
	observed_double_jump_count = 0
	observed_crossup_count = 0
	observed_dash_through_count = 0
