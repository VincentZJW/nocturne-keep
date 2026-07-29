class_name EdranBossSummon
extends CharacterBody2D

signal retired(summon: EdranBossSummon)
signal state_changed(state_name: StringName)

enum State { SPAWNING, IDLE, APPROACH, ATTACK, STAGGER, DISSOLVING, DEAD }

@export var config: BossSummonConfig
@export var projectile_scene: PackedScene

@onready var sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite2D as AnimatedSprite2D
@onready var facing_root: Node2D = $FacingRoot as Node2D
@onready var attack_hitbox: HitboxComponent = $FacingRoot/AttackHitbox as HitboxComponent
@onready var health_component: HealthComponent = $HealthComponent as HealthComponent
@onready var hurtbox: HurtboxComponent = $Hurtbox as HurtboxComponent

var current_state: State = State.SPAWNING
var target: Player
var lifetime_remaining: float = 0.0
var current_poise: int = 0
var facing: float = -1.0
var _attack_cooldown: float = 0.0
var _action_locked: bool = false
var _attack_index: int = 0
var _next_attack_id: int = 1
var _retired_emitted: bool = false


func _ready() -> void:
	if config == null:
		push_error("EdranBossSummon requires a BossSummonConfig")
		set_physics_process(false)
		return
	add_to_group("chapter_03_boss_summon")
	health_component.max_health = config.max_health
	health_component.reset_to_full()
	current_poise = config.max_poise
	health_component.died.connect(_on_died)
	hurtbox.hit_resolving.connect(_on_hit_resolving)
	hurtbox.set_enabled(false)
	_set_facing(facing)


func initialize_summon(player: Player, lifetime: float) -> void:
	target = player
	lifetime_remaining = lifetime
	_run_summon_sequence()


func force_dissolve() -> void:
	if current_state in [State.DISSOLVING, State.DEAD]:
		return
	_action_locked = true
	velocity = Vector2.ZERO
	attack_hitbox.end_attack()
	hurtbox.set_enabled(false)
	_set_state(State.DISSOLVING, &"forced_dissolve")
	await get_tree().create_timer(0.42).timeout
	_retire()


func _physics_process(delta: float) -> void:
	if current_state in [State.DISSOLVING, State.DEAD]:
		return
	if current_state != State.SPAWNING:
		lifetime_remaining -= delta
		if lifetime_remaining <= 0.0:
			force_dissolve()
			return
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	if config.gravity > 0.0 and not is_on_floor():
		velocity.y += config.gravity * delta
	else:
		velocity.y = 0.0
	if current_state in [State.SPAWNING, State.ATTACK, State.STAGGER] or _action_locked:
		velocity.x = move_toward(velocity.x, 0.0, config.move_speed * 8.0 * delta)
		move_and_slide()
		return
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Player
	if target == null:
		_set_state(State.IDLE, &"idle")
		return
	var delta_x: float = target.global_position.x - global_position.x
	var distance: float = absf(delta_x)
	_set_facing(delta_x)
	if _attack_cooldown <= 0.0 and distance <= config.attack_range:
		_run_attack()
		move_and_slide()
		return
	var desired_velocity: float = 0.0
	if config.actor_kind == &"choir_husk" and distance < 100.0:
		desired_velocity = -facing * config.move_speed
	elif distance > config.preferred_range:
		desired_velocity = facing * config.move_speed
	if not is_zero_approx(desired_velocity):
		_set_state(State.APPROACH, &"drift" if config.actor_kind == &"choir_husk" else &"walk")
	else:
		_set_state(State.IDLE, &"idle")
	velocity.x = move_toward(velocity.x, desired_velocity, config.move_speed * 7.0 * delta)
	move_and_slide()


func get_state_name() -> StringName:
	return State.keys()[current_state].to_snake_case()


func _run_summon_sequence() -> void:
	_action_locked = true
	_set_state(State.SPAWNING, &"summon_telegraph")
	await get_tree().create_timer(config.summon_telegraph_duration).timeout
	if current_state != State.SPAWNING:
		return
	_set_state(State.SPAWNING, &"rise")
	await get_tree().create_timer(config.rise_duration).timeout
	if current_state != State.SPAWNING:
		return
	hurtbox.set_enabled(true)
	_action_locked = false
	_set_state(State.IDLE, &"idle")


func _run_attack() -> void:
	if _action_locked:
		return
	_action_locked = true
	_set_state(State.ATTACK)
	if config.actor_kind == &"choir_husk":
		await _run_ranged_attack()
	else:
		await _run_melee_attack()
	if current_state != State.ATTACK:
		return
	_action_locked = false
	_attack_cooldown = config.attack_cooldown
	_set_state(State.IDLE, &"idle")


func _run_melee_attack() -> void:
	var uses_lunge: bool = _attack_index % 2 == 1
	_attack_index += 1
	var prefix: String = "lunge" if uses_lunge else "claw"
	_play_animation(StringName("%s_windup" % prefix))
	await get_tree().create_timer(config.windup).timeout
	if current_state != State.ATTACK:
		return
	_play_animation(StringName("%s_active" % prefix))
	_next_attack_id += 1
	var damage: int = config.secondary_damage if uses_lunge else config.primary_damage
	attack_hitbox.begin_attack(_next_attack_id, damage, facing, self)
	await get_tree().create_timer(config.active).timeout
	attack_hitbox.end_attack()
	_play_animation(StringName("%s_recovery" % prefix))
	await get_tree().create_timer(config.recovery).timeout


func _run_ranged_attack() -> void:
	_play_animation(&"aim")
	await get_tree().create_timer(config.windup).timeout
	if current_state != State.ATTACK:
		return
	_play_animation(&"shoot")
	_spawn_projectile()
	await get_tree().create_timer(config.active).timeout
	_play_animation(&"recovery")
	await get_tree().create_timer(config.recovery).timeout


func _spawn_projectile() -> void:
	if projectile_scene == null or target == null:
		return
	var projectile: Chapter03EnemyProjectile = projectile_scene.instantiate() as Chapter03EnemyProjectile
	if projectile == null:
		return
	get_parent().add_child(projectile)
	projectile.global_position = global_position + Vector2(facing * 22.0, -31.0)
	_next_attack_id += 1
	projectile.launch(Vector2(facing, 0.0), config.projectile_speed, config.primary_damage, _next_attack_id, self, &"choir_resonance")


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	if hitbox == null or current_state in [State.SPAWNING, State.DISSOLVING, State.DEAD]:
		return
	var impact: int = 14 if hitbox.attack_kind != &"dash_attack" else 28
	current_poise = maxi(0, current_poise - impact)
	if current_poise <= 0:
		_run_stagger()
	else:
		_play_animation(&"hurt")


func _run_stagger() -> void:
	if current_state in [State.DISSOLVING, State.DEAD]:
		return
	_action_locked = true
	attack_hitbox.end_attack()
	_set_state(State.STAGGER, &"stagger")
	await get_tree().create_timer(config.stagger_duration).timeout
	if current_state != State.STAGGER:
		return
	current_poise = config.max_poise
	_action_locked = false
	_attack_cooldown = 0.35
	_set_state(State.IDLE, &"idle")


func _on_died() -> void:
	if current_state in [State.DISSOLVING, State.DEAD]:
		return
	_action_locked = true
	attack_hitbox.end_attack()
	hurtbox.set_enabled(false)
	_set_state(State.DEAD, &"death")
	await get_tree().create_timer(0.66).timeout
	_retire()


func _retire() -> void:
	if _retired_emitted:
		return
	_retired_emitted = true
	retired.emit(self)
	queue_free()


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
