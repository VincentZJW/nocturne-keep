class_name ThirteenthPontiffEdran
extends CharacterBody2D

signal activated
signal phase_transition_requested(current_health: int)
signal defeated
signal state_changed(state_name: StringName)
signal attack_window_changed(attack_name: StringName, active: bool)

enum State {
	DORMANT,
	IDLE,
	APPROACH,
	TURN,
	ATTACK,
	STAGGER,
	TRANSITION_PENDING,
	DEAD,
}

enum Attack {
	SWEEP,
	THRUST,
	CENSER,
	LITANY,
	THIRTEENFOLD,
}

@export var config: ThirteenthPontiffEdranConfig
@export var timed_field_scene: PackedScene
@export var auto_activate: bool = false

@onready var sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite2D as AnimatedSprite2D
@onready var facing_root: Node2D = $FacingRoot as Node2D
@onready var health_component: HealthComponent = $HealthComponent as HealthComponent
@onready var hurtbox: HurtboxComponent = $Hurtbox as HurtboxComponent
@onready var sweep_hitbox: HitboxComponent = $FacingRoot/SweepHitbox as HitboxComponent
@onready var thrust_hitbox: HitboxComponent = $FacingRoot/ThrustHitbox as HitboxComponent
@onready var censer_hitbox: HitboxComponent = $FacingRoot/CenserHitbox as HitboxComponent

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
var _attack_cursor: int = 0
var _chain_count: int = 0
var _action_locked: bool = false
var _next_attack_id: int = 1
var _transition_emitted: bool = false


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
	if current_state in [State.DORMANT, State.TRANSITION_PENDING, State.DEAD]:
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		move_and_slide()
		return
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Player
	if current_state in [State.ATTACK, State.TURN, State.STAGGER] or _action_locked:
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		move_and_slide()
		return
	if target == null:
		_set_state(State.IDLE, &"phase_01_idle")
		move_and_slide()
		return
	var horizontal_distance: float = absf(target.global_position.x - global_position.x)
	var desired_facing: float = signf(target.global_position.x - global_position.x)
	if not is_zero_approx(desired_facing) and desired_facing != facing:
		_run_turn(desired_facing)
		move_and_slide()
		return
	if _attack_gap_timer <= 0.0 and horizontal_distance <= config.thrust_range + 80.0:
		_start_selected_attack(horizontal_distance)
	elif horizontal_distance > config.preferred_distance:
		_set_state(State.APPROACH, &"slow_walk")
		velocity.x = move_toward(velocity.x, facing * config.approach_speed, config.acceleration * delta)
	else:
		_set_state(State.IDLE, &"phase_01_idle")
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
	if current_state in [State.DORMANT, State.TRANSITION_PENDING, State.DEAD] or _action_locked:
		return false
	match attack_name:
		&"pontifical_sweep": _run_melee_attack(Attack.SWEEP)
		&"crozier_thrust": _run_melee_attack(Attack.THRUST)
		&"censer_procession": _run_melee_attack(Attack.CENSER)
		&"litany_of_ash": _run_litany()
		&"thirteenfold_sentence": _run_thirteenfold()
		_: return false
	return true


func get_state_name() -> StringName:
	return State.keys()[current_state].to_snake_case()


func get_current_poise() -> int:
	return current_poise


func is_transition_pending() -> bool:
	return current_state == State.TRANSITION_PENDING


func _tick_cooldowns(delta: float) -> void:
	_attack_gap_timer = maxf(0.0, _attack_gap_timer - delta)
	_stagger_protection_timer = maxf(0.0, _stagger_protection_timer - delta)
	_censer_cooldown = maxf(0.0, _censer_cooldown - delta)
	_litany_cooldown = maxf(0.0, _litany_cooldown - delta)
	_thirteenfold_cooldown = maxf(0.0, _thirteenfold_cooldown - delta)


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
	if candidates.is_empty():
		_attack_gap_timer = 0.20
		return
	var selected: Attack = candidates[_attack_cursor % candidates.size()]
	_attack_cursor += 1
	match selected:
		Attack.LITANY: _run_litany()
		Attack.THIRTEENFOLD: _run_thirteenfold()
		_: _run_melee_attack(selected)


func _run_turn(desired_facing: float) -> void:
	if _action_locked:
		return
	_action_locked = true
	_set_state(State.TURN, &"turn")
	await get_tree().create_timer(config.turn_reaction_delay).timeout
	await get_tree().create_timer(config.turn_animation_duration * config.turn_facing_commit_ratio).timeout
	if current_state != State.TURN:
		_action_locked = false
		return
	_set_facing(desired_facing)
	await get_tree().create_timer(config.turn_animation_duration * (1.0 - config.turn_facing_commit_ratio)).timeout
	_action_locked = false
	if current_state == State.TURN:
		_set_state(State.IDLE, &"phase_01_idle")


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
	for hitbox: HitboxComponent in [sweep_hitbox, thrust_hitbox, censer_hitbox]:
		hitbox.end_attack()
	_action_locked = false
	if current_state != State.ATTACK:
		return
	_chain_count += 1
	if _chain_count >= config.chain_limit:
		_chain_count = 0
		_attack_gap_timer = config.chain_recovery
	else:
		_attack_gap_timer = randf_range(config.phase_1_min_attack_gap, config.phase_1_max_attack_gap)
	_set_state(State.IDLE, &"phase_01_idle")


func _can_finish_action() -> bool:
	return current_state == State.ATTACK and health_component.current_health > config.phase_transition_health


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	if hitbox == null or current_state in [State.DORMANT, State.TRANSITION_PENDING, State.DEAD]:
		return
	var poise_damage: int = config.dash_attack_poise_damage if hitbox.attack_kind == &"dash_attack" else config.normal_attack_poise_damage
	current_poise = maxi(0, current_poise - poise_damage)
	if current_poise <= 0 and _stagger_protection_timer <= 0.0:
		_run_stagger()
	else:
		_play_animation(&"light_hit")


func _run_stagger() -> void:
	if current_state in [State.TRANSITION_PENDING, State.DEAD]:
		return
	_action_locked = true
	_end_all_hitboxes()
	_set_state(State.STAGGER, &"stagger")
	await get_tree().create_timer(config.stagger_duration).timeout
	if current_state != State.STAGGER:
		return
	current_poise = config.max_poise
	_stagger_protection_timer = config.stagger_protection_duration
	_action_locked = false
	_attack_gap_timer = 0.42
	_set_state(State.IDLE, &"phase_01_idle")


func _on_health_changed(current: int, _maximum: int) -> void:
	if current > config.phase_transition_health or _transition_emitted or current_state == State.DEAD:
		return
	_transition_emitted = true
	health_component.set_current_health(config.phase_transition_health)
	_action_locked = true
	velocity = Vector2.ZERO
	_end_all_hitboxes()
	hurtbox.set_invulnerable(true)
	_set_state(State.TRANSITION_PENDING, &"phase_transition_start")
	phase_transition_requested.emit(config.phase_transition_health)


func _on_died() -> void:
	_action_locked = true
	_end_all_hitboxes()
	hurtbox.set_enabled(false)
	_set_state(State.DEAD, &"hurt")
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
