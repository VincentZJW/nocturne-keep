class_name FallenGateKnight
extends EnemyCombatant

## Resettable two-phase Boss. Shared components remain the sole Health/Shield authorities.

signal state_changed(previous_state: StringName, current_state: StringName)
signal phase_changed(phase: int)
signal combat_started
signal boss_defeated

const BOSS_INTRO: StringName = &"BossIntro"
const IDLE_SHIELDED: StringName = &"IdleShielded"
const APPROACH_SHIELDED: StringName = &"ApproachShielded"
const TURN_SHIELDED: StringName = &"TurnShielded"
const SHIELD_BLOCK: StringName = &"ShieldBlock"
const SHIELD_BASH: StringName = &"ShieldBash"
const SWORD_SLASH: StringName = &"SwordSlash"
const HEAVY_OVERHEAD: StringName = &"HeavyOverhead"
const GUARD_RECOVERY: StringName = &"GuardRecovery"
const SHIELD_BREAK: StringName = &"ShieldBreak"
const PHASE_TRANSITION: StringName = &"PhaseTransition"
const HURT_SHIELDED: StringName = &"HurtShielded"
const IDLE_UNSHIELDED: StringName = &"IdleUnshielded"
const APPROACH_UNSHIELDED: StringName = &"ApproachUnshielded"
const TURN_UNSHIELDED: StringName = &"TurnUnshielded"
const COMBO_SLASH: StringName = &"ComboSlash"
const JUMP_SMASH: StringName = &"JumpSmash"
const CHARGE_THRUST: StringName = &"ChargeThrust"
const SHOCKWAVE_STRIKE: StringName = &"ShockwaveStrike"
const RECOVERY: StringName = &"Recovery"
const HURT_UNSHIELDED: StringName = &"HurtUnshielded"
const DEATH: StringName = &"Death"

const ATTACK_STATES: Array[StringName] = [
	SHIELD_BASH, SWORD_SLASH, HEAVY_OVERHEAD, COMBO_SLASH,
	JUMP_SMASH, CHARGE_THRUST, SHOCKWAVE_STRIKE,
]

@export var config: FallenGateKnightConfig
@export_node_path("AnimatedSprite2D") var animated_sprite_path: NodePath = NodePath("VisualRoot/AnimatedSprite2D")
@export_node_path("AnimatedSprite2D") var shield_damage_overlay_path: NodePath = NodePath(
	"VisualRoot/ShieldDamageOverlay"
)
@export_node_path("Node2D") var facing_root_path: NodePath = NodePath("FacingRoot")
@export_node_path("HealthComponent") var health_component_path: NodePath = NodePath("HealthComponent")
@export_node_path("ShieldComponent") var shield_component_path: NodePath = NodePath("ShieldComponent")
@export_node_path("HurtboxComponent") var hurtbox_path: NodePath = NodePath("Hurtbox")
@export_node_path("HitboxComponent") var melee_hitbox_path: NodePath = NodePath("FacingRoot/MeleeHitbox")
@export_node_path("HitboxComponent") var shockwave_hitbox_path: NodePath = NodePath("FacingRoot/ShockwaveHitbox")
@export var bridge_bounds_enabled: bool = false
@export var bridge_min_x: float = 0.0
@export var bridge_max_x: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(animated_sprite_path) as AnimatedSprite2D
@onready var shield_damage_overlay: AnimatedSprite2D = get_node_or_null(
	shield_damage_overlay_path
) as AnimatedSprite2D
@onready var facing_root: Node2D = get_node_or_null(facing_root_path) as Node2D
@onready var health_component: HealthComponent = get_node_or_null(health_component_path) as HealthComponent
@onready var shield_component: ShieldComponent = get_node_or_null(shield_component_path) as ShieldComponent
@onready var hurtbox: HurtboxComponent = get_node_or_null(hurtbox_path) as HurtboxComponent
@onready var melee_hitbox: HitboxComponent = get_node_or_null(melee_hitbox_path) as HitboxComponent
@onready var shockwave_hitbox: HitboxComponent = get_node_or_null(shockwave_hitbox_path) as HitboxComponent

var target: Player
var current_state: StringName = BOSS_INTRO
var current_phase: int = 1
var state_timer: float = 0.0
var facing_direction: float = -1.0
var ai_active: bool = false
var room_engaged: bool = false
var attack_cycle: int = 0
var current_attack_id: int = 0
var _next_attack_id: int = 1
var _turn_timer: float = 0.0
var _turn_cooldown_timer: float = 0.0
var _pending_facing: float = 0.0
var _turn_return_state: StringName = &""
var _turn_return_timer: float = 0.0
var _turn_commit_queued: bool = false
var _initial_position: Vector2 = Vector2.ZERO
var _defeat_emitted: bool = false
var _combo_second_step: bool = false


func _ready() -> void:
	if not _validate_dependencies():
		set_physics_process(false)
		return
	_initial_position = global_position
	health_component.max_health = config.max_health
	health_component.reset_to_full()
	shield_component.shield_max_health = config.boss_shield_max_health
	shield_component.reset_shield()
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.frame_changed.connect(_on_animation_frame_changed)
	health_component.died.connect(_on_health_died)
	hurtbox.hit_received.connect(_on_hurtbox_hit_received)
	shield_component.shield_hit.connect(_on_shield_hit)
	shield_component.shield_broken.connect(_on_shield_broken)
	shield_component.shield_health_changed.connect(_on_shield_health_changed)
	set_facing_direction(facing_direction)
	_update_shield_visual(shield_component.shield_current_health)
	_end_attack_window()
	play_animation(&"idle_shielded")
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if current_state == DEATH:
		velocity = Vector2.ZERO
		return
	if not is_on_floor():
		velocity.y += config.gravity * delta
	else:
		velocity.y = 0.0
	_turn_cooldown_timer = maxf(0.0, _turn_cooldown_timer - delta)
	match current_state:
		BOSS_INTRO, SHIELD_BLOCK, GUARD_RECOVERY, SHIELD_BREAK, PHASE_TRANSITION, RECOVERY, HURT_SHIELDED, HURT_UNSHIELDED:
			_process_timed_state(delta)
		IDLE_SHIELDED, IDLE_UNSHIELDED:
			_process_idle(delta)
		APPROACH_SHIELDED, APPROACH_UNSHIELDED:
			_process_approach(delta)
		TURN_SHIELDED, TURN_UNSHIELDED:
			_process_turn_state(delta)
		SHIELD_BASH, SWORD_SLASH, HEAVY_OVERHEAD, COMBO_SLASH, JUMP_SMASH, CHARGE_THRUST, SHOCKWAVE_STRIKE:
			_process_attack_motion(delta)
	move_and_slide()
	_enforce_bridge_bounds()


func activate(new_target: Player) -> void:
	if is_dead():
		return
	set_target(new_target)
	room_engaged = true
	ai_active = true
	visible = true
	set_physics_process(true)
	transition_state(BOSS_INTRO)
	state_timer = 0.70
	velocity = Vector2.ZERO
	play_animation(&"idle_shielded")
	combat_started.emit()


func reset_boss() -> void:
	_end_attack_window()
	global_position = _initial_position
	velocity = Vector2.ZERO
	visible = true
	modulate = Color.WHITE
	collision_layer = 4
	collision_mask = 3
	hurtbox.set_enabled(true)
	health_component.max_health = config.max_health
	health_component.reset_to_full()
	shield_component.shield_max_health = config.boss_shield_max_health
	shield_component.reset_shield()
	current_phase = 1
	current_state = BOSS_INTRO
	state_timer = 0.0
	attack_cycle = 0
	_combo_second_step = false
	_turn_timer = 0.0
	_turn_cooldown_timer = 0.0
	_pending_facing = 0.0
	_turn_return_state = &""
	_turn_return_timer = 0.0
	_turn_commit_queued = false
	_defeat_emitted = false
	room_engaged = false
	ai_active = false
	target = null
	set_facing_direction(-1.0)
	_update_shield_visual(shield_component.shield_current_health)
	play_animation(&"idle_shielded", true)
	set_physics_process(false)
	phase_changed.emit(current_phase)


func set_target(new_target: Player) -> void:
	if target == new_target:
		return
	target = new_target
	target_changed.emit(target)


func set_ai_active(active: bool) -> void:
	if active:
		ai_active = true
		set_physics_process(true)
	else:
		ai_active = false
		velocity = Vector2.ZERO
		_end_attack_window()
		_interrupt_turn()
		set_physics_process(false)


func is_ai_active() -> bool:
	return ai_active


func is_dead() -> bool:
	return current_state == DEATH


func get_state_name() -> StringName:
	return current_state


func get_enemy_type_name() -> StringName:
	return config.display_name if config != null else &"FallenGateKnight"


func get_detection_range() -> float:
	return config.detection_range if config != null else 0.0


func get_attack_damage() -> int:
	return melee_hitbox.damage if melee_hitbox != null else 0


func get_health_component() -> HealthComponent:
	return health_component


func get_current_animation_name() -> StringName:
	return animated_sprite.animation if animated_sprite != null else &""


func get_attack_phase_name() -> StringName:
	return current_state if current_state in ATTACK_STATES else &"None"


func is_attack_window_active() -> bool:
	return (melee_hitbox != null and melee_hitbox.is_active) or (shockwave_hitbox != null and shockwave_hitbox.is_active)


func get_debug_summary() -> String:
	return "%s  P%d  %s  BODY %d/%d  SH %d/%d %s  ANIM %s  HIT %s  TURN %s %.2f  CD %.2f" % [
		get_enemy_type_name(), current_phase, current_state,
		health_component.current_health, health_component.max_health,
		shield_component.shield_current_health, shield_component.shield_max_health,
		_get_shield_visual_state().to_upper(), animated_sprite.animation,
		"ON" if is_attack_window_active() else "off", _get_turn_phase_name(), _turn_timer,
		_turn_cooldown_timer,
	]


func get_bridge_bounds() -> Vector2:
	return Vector2(bridge_min_x, bridge_max_x)


func transition_state(next_state: StringName) -> bool:
	if next_state == current_state or current_state == DEATH:
		return false
	var previous_state: StringName = current_state
	current_state = next_state
	state_changed.emit(previous_state, current_state)
	return true


func play_animation(animation_name: StringName, restart: bool = false) -> void:
	if animated_sprite.sprite_frames == null or not animated_sprite.sprite_frames.has_animation(animation_name):
		push_error("FallenGateKnight missing animation %s" % animation_name)
		return
	if animated_sprite.animation == animation_name and animated_sprite.is_playing() and not restart:
		return
	animated_sprite.play(animation_name)


func set_facing_direction(direction: float) -> void:
	if is_zero_approx(direction):
		return
	facing_direction = signf(direction)
	animated_sprite.flip_h = facing_direction < 0.0
	shield_damage_overlay.flip_h = facing_direction < 0.0
	facing_root.scale.x = facing_direction
	_update_shield_overlay_pose()


func _process_timed_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if current_state in [GUARD_RECOVERY, RECOVERY] and _process_turn_request(delta):
		return
	if state_timer > 0.0:
		return
	match current_state:
		BOSS_INTRO:
			_enter_idle()
		SHIELD_BLOCK, HURT_SHIELDED:
			_enter_idle()
		SHIELD_BREAK:
			transition_state(PHASE_TRANSITION)
			state_timer = config.phase_transition_duration
			play_animation(&"phase_transition", true)
		PHASE_TRANSITION:
			current_phase = 2
			phase_changed.emit(current_phase)
			_enter_idle()
		GUARD_RECOVERY, RECOVERY, HURT_UNSHIELDED:
			_enter_idle()


func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
	if not _has_target():
		return
	if _process_turn_request(delta):
		return
	transition_state(APPROACH_SHIELDED if current_phase == 1 else APPROACH_UNSHIELDED)
	play_animation(&"walk_shielded" if current_phase == 1 else &"walk_unshielded")


func _process_approach(delta: float) -> void:
	if not _has_target():
		_enter_idle()
		return
	var offset: Vector2 = target.global_position - global_position
	if _process_turn_request(delta):
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		return
	if absf(offset.x) <= config.attack_range:
		velocity.x = 0.0
		_start_next_attack()
		return
	var speed: float = config.shielded_move_speed if current_phase == 1 else config.unshielded_move_speed
	velocity.x = move_toward(velocity.x, facing_direction * speed, config.acceleration * delta)


func _process_attack_motion(delta: float) -> void:
	if current_state == CHARGE_THRUST and animated_sprite.frame in [1, 2, 3]:
		velocity.x = facing_direction * 175.0
	elif current_state == SHIELD_BASH and animated_sprite.frame in [2, 3]:
		velocity.x = facing_direction * 80.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)


func _enforce_bridge_bounds() -> void:
	if not bridge_bounds_enabled or bridge_max_x <= bridge_min_x:
		return
	var clamped_x: float = clampf(global_position.x, bridge_min_x, bridge_max_x)
	if not is_equal_approx(clamped_x, global_position.x):
		global_position.x = clamped_x
	if global_position.x <= bridge_min_x and velocity.x < 0.0:
		velocity.x = 0.0
	elif global_position.x >= bridge_max_x and velocity.x > 0.0:
		velocity.x = 0.0


func _process_turn_request(delta: float) -> bool:
	if not _has_target() or _turn_cooldown_timer > 0.0:
		_cancel_turn_request()
		return false
	var offset_x: float = target.global_position.x - global_position.x
	if absf(offset_x) <= config.turn_side_threshold:
		_cancel_turn_request()
		return false
	var desired_direction: float = signf(offset_x)
	if desired_direction == facing_direction:
		_cancel_turn_request()
		return false
	if _pending_facing != desired_direction:
		_pending_facing = desired_direction
		_turn_timer = config.boss_turn_reaction_delay
	if _turn_timer <= delta + 0.000001:
		_turn_timer = 0.0
		_start_turn_state()
	else:
		_turn_timer -= delta
	return true


func _start_turn_state() -> void:
	_turn_return_state = current_state
	_turn_return_timer = maxf(0.0, state_timer - config.boss_turn_animation_duration)
	var turn_state: StringName = TURN_SHIELDED if current_phase == 1 else TURN_UNSHIELDED
	transition_state(turn_state)
	_turn_timer = config.boss_turn_animation_duration
	velocity.x = 0.0
	play_animation(&"turn_shielded" if current_phase == 1 else &"turn_unshielded", true)


func _process_turn_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
	if _turn_commit_queued:
		return
	if _turn_timer > delta + 0.000001:
		_turn_timer -= delta
		return
	_turn_timer = 0.0
	_turn_commit_queued = true
	call_deferred("_commit_turn")


func _commit_turn() -> void:
	if not _turn_commit_queued or current_state not in [TURN_SHIELDED, TURN_UNSHIELDED]:
		return
	_turn_commit_queued = false
	if not is_zero_approx(_pending_facing):
		set_facing_direction(_pending_facing)
	_turn_cooldown_timer = config.boss_turn_cooldown
	_pending_facing = 0.0
	_turn_timer = 0.0
	_restore_state_after_turn()


func _restore_state_after_turn() -> void:
	var return_state: StringName = _turn_return_state
	var return_timer: float = _turn_return_timer
	_turn_return_state = &""
	_turn_return_timer = 0.0
	if return_state in [GUARD_RECOVERY, RECOVERY] and return_timer > 0.0:
		transition_state(return_state)
		state_timer = return_timer
		play_animation(&"idle_shielded" if current_phase == 1 else &"idle_unshielded", true)
		return
	if return_state in [APPROACH_SHIELDED, APPROACH_UNSHIELDED]:
		transition_state(APPROACH_SHIELDED if current_phase == 1 else APPROACH_UNSHIELDED)
		play_animation(&"walk_shielded" if current_phase == 1 else &"walk_unshielded", true)
		return
	_enter_idle()


func _cancel_turn_request() -> void:
	if current_state in [TURN_SHIELDED, TURN_UNSHIELDED]:
		return
	_turn_timer = 0.0
	_pending_facing = 0.0
	_turn_return_state = &""
	_turn_return_timer = 0.0
	_turn_commit_queued = false


func _interrupt_turn() -> void:
	_turn_timer = 0.0
	_pending_facing = 0.0
	_turn_return_state = &""
	_turn_return_timer = 0.0
	_turn_commit_queued = false


func _get_turn_phase_name() -> String:
	if current_state in [TURN_SHIELDED, TURN_UNSHIELDED]:
		return "COMMIT" if _turn_commit_queued else "ANIM"
	if not is_zero_approx(_pending_facing):
		return "REACT"
	return "OFF"


func _start_next_attack() -> void:
	if current_phase == 1:
		var phase_one: Array[StringName] = [SHIELD_BASH, SWORD_SLASH, HEAVY_OVERHEAD]
		_start_attack(phase_one[attack_cycle % phase_one.size()])
	else:
		var phase_two: Array[StringName] = [COMBO_SLASH, JUMP_SMASH, CHARGE_THRUST, SHOCKWAVE_STRIKE]
		_start_attack(phase_two[attack_cycle % phase_two.size()])
	attack_cycle += 1


func _start_attack(attack_state: StringName) -> void:
	if not transition_state(attack_state):
		return
	_interrupt_turn()
	velocity.x = 0.0
	current_attack_id = _next_attack_id
	_next_attack_id += 1
	_combo_second_step = false
	_end_attack_window()
	match attack_state:
		SHIELD_BASH:
			play_animation(&"shield_bash", true)
		SWORD_SLASH:
			play_animation(&"sword_slash", true)
		HEAVY_OVERHEAD:
			play_animation(&"heavy_overhead", true)
		COMBO_SLASH:
			play_animation(&"combo_slash_1", true)
		JUMP_SMASH:
			velocity.y = -220.0
			play_animation(&"jump_smash", true)
		CHARGE_THRUST:
			play_animation(&"charge_thrust", true)
		SHOCKWAVE_STRIKE:
			play_animation(&"shockwave_strike", true)


func _on_animation_frame_changed() -> void:
	_update_shield_overlay_pose()
	if current_state not in ATTACK_STATES:
		_end_attack_window()
		return
	var active: bool = false
	var damage: int = 1
	var use_shockwave: bool = false
	match current_state:
		SHIELD_BASH:
			active = animated_sprite.frame in [2, 3]
			damage = config.shield_bash_damage
		SWORD_SLASH:
			active = animated_sprite.frame in [2, 3]
			damage = config.sword_slash_damage
		HEAVY_OVERHEAD:
			active = animated_sprite.frame in [3, 4]
			damage = config.heavy_overhead_damage
		COMBO_SLASH:
			active = animated_sprite.frame in [2, 3]
			damage = config.sword_slash_damage
		JUMP_SMASH:
			active = animated_sprite.frame in [3, 4]
			damage = config.heavy_overhead_damage
		CHARGE_THRUST:
			active = animated_sprite.frame in [2, 3]
			damage = config.charge_thrust_damage
		SHOCKWAVE_STRIKE:
			active = animated_sprite.frame in [3, 4]
			damage = config.shockwave_damage
			use_shockwave = true
	_set_attack_window(active, damage, use_shockwave)


func _set_attack_window(active: bool, damage: int, use_shockwave: bool) -> void:
	var selected: HitboxComponent = shockwave_hitbox if use_shockwave else melee_hitbox
	var other: HitboxComponent = melee_hitbox if use_shockwave else shockwave_hitbox
	if other.is_active:
		other.end_attack()
	if active and not selected.is_active:
		selected.begin_attack(current_attack_id, damage, facing_direction, self)
		attack_window_changed.emit(true)
	elif not active and selected.is_active:
		selected.end_attack()
		attack_window_changed.emit(false)


func _end_attack_window() -> void:
	var changed: bool = false
	if melee_hitbox != null and melee_hitbox.is_active:
		melee_hitbox.end_attack()
		changed = true
	if shockwave_hitbox != null and shockwave_hitbox.is_active:
		shockwave_hitbox.end_attack()
		changed = true
	if changed:
		attack_window_changed.emit(false)


func _on_animation_finished() -> void:
	if current_state == DEATH and animated_sprite.animation == &"death":
		visible = false
		set_physics_process(false)
		presentation_finished.emit()
		if not _defeat_emitted:
			_defeat_emitted = true
			boss_defeated.emit()
		return
	if current_state == COMBO_SLASH and animated_sprite.animation == &"combo_slash_1" and not _combo_second_step:
		_combo_second_step = true
		current_attack_id = _next_attack_id
		_next_attack_id += 1
		play_animation(&"combo_slash_2", true)
		return
	if current_state in ATTACK_STATES:
		_end_attack_window()
		transition_state(GUARD_RECOVERY if current_phase == 1 else RECOVERY)
		state_timer = config.attack_recovery
		play_animation(&"idle_shielded" if current_phase == 1 else &"idle_unshielded")


func _on_shield_hit(_hitbox: HitboxComponent, _damage: int, _remaining: int) -> void:
	if current_state in [DEATH, SHIELD_BREAK, PHASE_TRANSITION]:
		return
	_end_attack_window()
	_interrupt_turn()
	transition_state(SHIELD_BLOCK)
	state_timer = 0.22
	velocity.x = 0.0
	play_animation(&"shield_block", true)


func _on_shield_broken(_hitbox: HitboxComponent) -> void:
	if current_state == DEATH:
		return
	_end_attack_window()
	_interrupt_turn()
	transition_state(SHIELD_BREAK)
	state_timer = config.shield_break_stun
	velocity = Vector2.ZERO
	play_animation(&"shield_break", true)
	var flash_color: Color = Color(1.0, 0.91, 0.68, 1.0 + config.shield_break_flash_alpha)
	modulate = flash_color
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, config.shield_break_flash_duration)


func _on_hurtbox_hit_received(_damage: int, source_position: Vector2, _attack_id: int) -> void:
	if current_state in [DEATH, SHIELD_BREAK, PHASE_TRANSITION]:
		return
	_end_attack_window()
	_interrupt_turn()
	var hurt_state: StringName = HURT_SHIELDED if current_phase == 1 else HURT_UNSHIELDED
	transition_state(hurt_state)
	state_timer = 0.20
	velocity.x = signf(global_position.x - source_position.x) * 70.0
	play_animation(&"hurt_shielded" if current_phase == 1 else &"hurt_unshielded", true)


func _on_health_died() -> void:
	if current_state == DEATH:
		return
	_end_attack_window()
	_interrupt_turn()
	transition_state(DEATH)
	ai_active = false
	room_engaged = false
	velocity = Vector2.ZERO
	hurtbox.set_enabled(false)
	collision_layer = 0
	collision_mask = 1
	play_animation(&"death", true)
	enemy_died.emit()


func _enter_idle() -> void:
	transition_state(IDLE_SHIELDED if current_phase == 1 else IDLE_UNSHIELDED)
	velocity.x = 0.0
	play_animation(&"idle_shielded" if current_phase == 1 else &"idle_unshielded")


func _on_shield_health_changed(current: int, _maximum: int) -> void:
	_update_shield_visual(current)


func _update_shield_visual(current: int) -> void:
	if shield_damage_overlay == null:
		return
	var visual_state: StringName = _get_shield_visual_state(current)
	shield_damage_overlay.visible = visual_state not in [&"intact", &"broken"]
	shield_damage_overlay.play(visual_state)
	_update_shield_overlay_pose()


func _update_shield_overlay_pose() -> void:
	if shield_damage_overlay == null or animated_sprite == null:
		return
	var offset: Vector2 = Vector2.ZERO
	if animated_sprite.animation == &"turn_shielded":
		var turn_insets: Array[int] = [0, 5, 2]
		offset.x = -float(turn_insets[mini(animated_sprite.frame, 2)]) * facing_direction
	elif animated_sprite.animation == &"shield_bash" and animated_sprite.frame in [2, 3]:
		offset.x = 5.0 * facing_direction
	if animated_sprite.animation == &"idle_shielded" and animated_sprite.frame in [1, 2]:
		offset.y = 1.0
	shield_damage_overlay.position = offset


func _get_shield_visual_state(current: int = -1) -> StringName:
	var shield_health: int = (
		shield_component.shield_current_health if current < 0 else current
	)
	if shield_component.is_shield_broken() or shield_health <= 0:
		return &"broken"
	if shield_health >= 8:
		return &"intact"
	if shield_health >= 5:
		return &"damaged"
	return &"critical"


func _has_target() -> bool:
	return target != null and is_instance_valid(target) and not target.is_dead()


func _validate_dependencies() -> bool:
	if config == null:
		push_error("FallenGateKnight requires FallenGateKnightConfig")
		return false
	if animated_sprite == null or shield_damage_overlay == null or facing_root == null or health_component == null or shield_component == null or hurtbox == null or melee_hitbox == null or shockwave_hitbox == null:
		push_error("FallenGateKnight scene composition is incomplete")
		return false
	return true
