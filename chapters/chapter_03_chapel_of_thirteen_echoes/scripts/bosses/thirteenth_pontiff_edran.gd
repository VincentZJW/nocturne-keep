class_name ThirteenthPontiffEdran
extends CharacterBody2D

signal activated
signal phase_transition_requested(current_health: int)
signal phase_transition_started
signal phase_changed(phase: int)
signal phase_transition_finished
signal death_sequence_started
signal defeated
signal state_changed(state_name: StringName)
signal attack_window_changed(attack_name: StringName, active: bool)

enum State {
	DORMANT,
	IDLE,
	APPROACH,
	TURN,
	ATTACK,
	SUMMON,
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
}

@export var config: ThirteenthPontiffEdranConfig
@export var timed_field_scene: PackedScene
@export var phase_transition_frames: SpriteFrames
@export var phase_02_frames: SpriteFrames
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
var _defeat_emitted: bool = false


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
	if not is_on_floor():
		velocity.y += config.gravity * delta
	if current_state in [State.DORMANT, State.TRANSITION_PENDING, State.PHASE_TRANSITION, State.DEATH_SEQUENCE, State.DEAD]:
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
	target = player if player != null else get_tree().get_first_node_in_group("player") as Player
	hurtbox.set_enabled(true)
	_attack_gap_timer = 0.45
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


func _start_selected_attack(distance: float) -> void:
	var candidates: Array[Attack] = []
	if distance <= config.sweep_range:
		candidates.append(Attack.SWEEP)
	if distance <= config.thrust_range:
		candidates.append(Attack.THRUST)
	if distance <= config.censer_range and _censer_cooldown <= 0.0:
		candidates.append(Attack.CENSER)
	if _litany_cooldown <= 0.0:
		candidates.append(Attack.LITANY)
	if _thirteenfold_cooldown <= 0.0:
		candidates.append(Attack.THIRTEENFOLD)
	if _summon_cooldown <= 0.0 and summon_director != null and summon_director.can_summon_phase_1():
		candidates.append(Attack.SUMMON)
	if candidates.is_empty():
		_attack_gap_timer = 0.20
		return
	var selected: Attack = candidates[_attack_cursor % candidates.size()]
	_attack_cursor += 1
	match selected:
		Attack.LITANY: _run_litany()
		Attack.THIRTEENFOLD: _run_thirteenfold()
		Attack.SUMMON: _run_summon()
		_: _run_melee_attack(selected)


func _start_selected_phase_02_attack(distance: float) -> void:
	var candidates: Array[Attack] = []
	if distance <= config.bell_cleave_range:
		candidates.append(Attack.BELL_CLEAVE)
	if distance <= config.chain_judgment_range:
		candidates.append(Attack.CHAIN_JUDGMENT)
	if _hollow_toll_cooldown <= 0.0:
		candidates.append(Attack.HOLLOW_TOLL)
	if _scripture_burial_cooldown <= 0.0 and _hollow_toll_cooldown > 0.0:
		candidates.append(Attack.SCRIPTURE_BURIAL)
	if _procession_cooldown <= 0.0 and summon_director != null and summon_director.can_summon_phase_2():
		candidates.append(Attack.PROCESSION)
	if (
		float(health_component.current_health) / float(config.max_health) <= config.fourteenth_seat_health_ratio
		and _fourteenth_seat_cooldown <= 0.0
	):
		candidates.append(Attack.FOURTEENTH_SEAT)
	if candidates.size() > 1:
		candidates.erase(_last_phase_02_attack)
	if candidates.is_empty():
		_attack_gap_timer = 0.18
		return
	var selected: Attack = candidates[_attack_cursor % candidates.size()]
	_attack_cursor += 1
	_last_phase_02_attack = selected
	match selected:
		Attack.BELL_CLEAVE: _run_phase_02_cleave()
		Attack.CHAIN_JUDGMENT: _run_chain_judgment()
		Attack.HOLLOW_TOLL: _run_hollow_toll()
		Attack.SCRIPTURE_BURIAL: _run_scripture_burial()
		Attack.PROCESSION: _run_procession()
		Attack.FOURTEENTH_SEAT: _run_fourteenth_seat()


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
	_procession_cooldown = config.procession_cooldown
	await get_tree().create_timer(config.procession_windup).timeout
	if _can_finish_action() and summon_director != null:
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
		config.summon_cooldown_min * 0.5
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
	if current_poise <= 0 and _stagger_protection_timer <= 0.0:
		_run_stagger()
	else:
		_play_animation(&"light_hit")


func _run_stagger() -> void:
	if current_state in [State.TRANSITION_PENDING, State.PHASE_TRANSITION, State.DEATH_SEQUENCE, State.DEAD]:
		return
	_action_locked = true
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
	health_component.set_current_health(config.phase_transition_health)
	_action_locked = true
	velocity = Vector2.ZERO
	_end_all_hitboxes()
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
		await get_tree().create_timer(step_duration).timeout
	_phase = 2
	current_poise = config.phase_02_max_poise
	if phase_02_frames != null:
		sprite.sprite_frames = phase_02_frames
	_set_state(State.IDLE,&"phase_02_idle")
	phase_changed.emit(2)
	await get_tree().create_timer(config.phase_02_ready_delay).timeout
	hurtbox.set_invulnerable(false)
	_action_locked = false
	_attack_gap_timer = config.phase_02_min_attack_gap
	if target != null:
		if target.hurtbox != null and not player_was_invulnerable:
			target.hurtbox.set_invulnerable(false)
		target.set_input_profile(previous_input_profile)
	phase_transition_finished.emit()


func _on_died() -> void:
	if current_state in [State.DEATH_SEQUENCE,State.DEAD]:
		return
	call_deferred("_run_death_sequence")


func _run_death_sequence() -> void:
	_action_locked = true
	_end_all_hitboxes()
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
