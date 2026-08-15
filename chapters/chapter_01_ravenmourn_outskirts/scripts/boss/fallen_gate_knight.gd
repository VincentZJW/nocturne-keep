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
@export_node_path("HitboxComponent") var shield_bash_hitbox_path: NodePath = NodePath(
	"FacingRoot/ShieldBashHitbox"
)
@export_node_path("HitboxComponent") var slash_hitbox_path: NodePath = NodePath(
	"FacingRoot/SlashHitbox"
)
@export_node_path("HitboxComponent") var thrust_hitbox_path: NodePath = NodePath(
	"FacingRoot/ThrustHitbox"
)
@export_node_path("HitboxComponent") var shockwave_hitbox_path: NodePath = NodePath("FacingRoot/ShockwaveHitbox")
@export_node_path("BossAttackGeometryDebugDraw") var attack_geometry_debug_path: NodePath = NodePath(
	"FacingRoot/AttackGeometryDebug"
)
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
@onready var shield_bash_hitbox: HitboxComponent = get_node_or_null(
	shield_bash_hitbox_path
) as HitboxComponent
@onready var slash_hitbox: HitboxComponent = get_node_or_null(slash_hitbox_path) as HitboxComponent
@onready var thrust_hitbox: HitboxComponent = get_node_or_null(thrust_hitbox_path) as HitboxComponent
@onready var shockwave_hitbox: HitboxComponent = get_node_or_null(shockwave_hitbox_path) as HitboxComponent
@onready var attack_geometry_debug: BossAttackGeometryDebugDraw = get_node_or_null(
	attack_geometry_debug_path
) as BossAttackGeometryDebugDraw

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
var _turn_facing_committed: bool = false
var _turn_animation_elapsed: float = 0.0
var _initial_position: Vector2 = Vector2.ZERO
var _defeat_emitted: bool = false
var _combo_second_step: bool = false
var _light_hit_reaction_cooldown: float = 0.0
var _heavy_hit_reaction_cooldown: float = 0.0
var _last_hurt_reaction_type: StringName = &"none"
var _attack_gap_remaining: float = 0.0
var _last_completed_attack: StringName = &"None"
var _combat_clock: float = 0.0
var _last_attack_active_end_time: float = -1.0
var _next_attack_windup_start_time: float = -1.0
var _measured_attack_gap: float = -1.0
var _player_counter_action: StringName = &"none"
var _player_escape_success: bool = false
var _attack_gap_source_id: int = 0
var _shield_bash_cooldown_remaining: float = 0.0
var _last_selected_attack: StringName = &"None"
var _attack_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var far_pressure: float = 0.0
var close_pressure: float = 0.0
var air_pressure: float = 0.0
var crossup_pressure: float = 0.0
var dash_pressure: float = 0.0
var attack_pressure: float = 0.0
var _behavior_clock: float = 0.0
var _behavior_sample_timer: float = 0.0
var _behavior_events: Array[Dictionary] = []
var _previous_target_side: float = 0.0
var _previous_target_action: StringName = &"None"
var _previous_target_movement: StringName = &"idle"
var _adaptive_decision_reason: StringName = &"base"
var _gate_wave_spawned_for_id: int = -1
var observed_jump_count: int = 0
var observed_double_jump_count: int = 0
var observed_crossup_count: int = 0
var observed_dash_through_count: int = 0

const BEHAVIOR_REACTION_DELAY: float = 0.40
const BEHAVIOR_DECAY_PER_SECOND: float = 0.14
const BEHAVIOR_SAMPLE_INTERVAL: float = 0.20


func _ready() -> void:
	if not _validate_dependencies():
		set_physics_process(false)
		return
	_initial_position = global_position
	health_component.max_health = config.max_health
	health_component.reset_to_full()
	shield_component.shield_max_health = config.boss_shield_max_health
	shield_component.reset_shield()
	_configure_attack_geometry()
	_attack_rng.seed = config.attack_selection_seed
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
	_light_hit_reaction_cooldown = maxf(0.0, _light_hit_reaction_cooldown - delta)
	_heavy_hit_reaction_cooldown = maxf(0.0, _heavy_hit_reaction_cooldown - delta)
	_shield_bash_cooldown_remaining = maxf(0.0, _shield_bash_cooldown_remaining - delta)
	_combat_clock += delta
	_attack_gap_remaining = maxf(0.0, _attack_gap_remaining - delta)
	_observe_target_behavior(delta)
	match current_state:
		BOSS_INTRO, SHIELD_BLOCK, SHIELD_BREAK, PHASE_TRANSITION, HURT_SHIELDED, HURT_UNSHIELDED:
			_process_timed_state(delta)
		GUARD_RECOVERY, RECOVERY:
			_process_post_attack_gap(delta)
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
	_reset_behavior_context()
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
	_turn_facing_committed = false
	_turn_animation_elapsed = 0.0
	_defeat_emitted = false
	_light_hit_reaction_cooldown = 0.0
	_heavy_hit_reaction_cooldown = 0.0
	_last_hurt_reaction_type = &"none"
	_attack_gap_remaining = 0.0
	_last_completed_attack = &"None"
	_combat_clock = 0.0
	_last_attack_active_end_time = -1.0
	_next_attack_windup_start_time = -1.0
	_measured_attack_gap = -1.0
	_player_counter_action = &"none"
	_player_escape_success = false
	_attack_gap_source_id = 0
	_shield_bash_cooldown_remaining = 0.0
	_last_selected_attack = &"None"
	_attack_rng.seed = config.attack_selection_seed
	_reset_behavior_context()
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
	var active_hitbox: HitboxComponent = _get_active_hitbox()
	return active_hitbox.damage if active_hitbox != null else 0


func get_health_component() -> HealthComponent:
	return health_component


func get_current_animation_name() -> StringName:
	return animated_sprite.animation if animated_sprite != null else &""


func get_attack_phase_name() -> StringName:
	return current_state if current_state in ATTACK_STATES else &"None"


func is_attack_window_active() -> bool:
	return _get_active_hitbox() != null


func get_debug_summary() -> String:
	var profile: Dictionary[StringName, Variant] = get_current_attack_geometry_profile()
	var base_summary: String = "%s  P%d  STATE %s  BODY %d/%d  SH %d/%d %s  ANIM %s  ATTACK %s  RANGE %.0f  HIT %s %s W%.0f OFF %.0f  BASH CD %.2f WT %.0f%%  ACTIVE END %.2f  GAP %.2f  NEXT %s  MEASURED %.3f  REACT %s L%.2f H%.2f  TURN %s R%.2f A%.2f T%.2f COMMIT %s  FACE %+.0f  SIDE %s  DIST %.0f  COUNTER %s ESC %s" % [
		get_enemy_type_name(), current_phase, current_state,
		health_component.current_health, health_component.max_health,
		shield_component.shield_current_health, shield_component.shield_max_health,
		_get_shield_visual_state().to_upper(), animated_sprite.animation,
		get_attack_phase_name(), float(profile.get(&"effective_range", 0.0)),
		"ON" if is_attack_window_active() else "off", String(profile.get(&"name", &"none")),
		float(profile.get(&"width", 0.0)), float(profile.get(&"offset_x", 0.0)),
		_shield_bash_cooldown_remaining, config.shield_bash_selection_weight * 100.0,
		_last_attack_active_end_time, _attack_gap_remaining,
		"YES" if _can_start_next_attack() else "no", _measured_attack_gap,
		_last_hurt_reaction_type, _light_hit_reaction_cooldown, _heavy_hit_reaction_cooldown,
		_get_turn_phase_name(),
		config.boss_turn_reaction_delay if _get_turn_phase_name() == "REACT" else 0.0,
		config.boss_turn_animation_duration if current_state in [TURN_SHIELDED, TURN_UNSHIELDED] else 0.0,
		_get_current_turn_total_remaining(), "YES" if _turn_facing_committed else "no",
		facing_direction, shield_component.last_hit_side, _get_player_distance(),
		_player_counter_action, "YES" if _player_escape_success else "no",
	]
	return "%s  AI[%s F%.2f C%.2f A%.2f X%.2f D%.2f J%d DJ%d X%d DT%d]" % [
		base_summary, _adaptive_decision_reason, far_pressure, close_pressure,
		air_pressure, crossup_pressure, dash_pressure, observed_jump_count,
		observed_double_jump_count, observed_crossup_count, observed_dash_through_count,
	]


func get_shield_bash_cooldown_remaining() -> float:
	return _shield_bash_cooldown_remaining


func set_attack_geometry_debug_visible(enabled: bool) -> void:
	if attack_geometry_debug != null:
		attack_geometry_debug.set_debug_visible(enabled)


func get_current_attack_geometry_profile() -> Dictionary[StringName, Variant]:
	var hitbox: HitboxComponent = _get_hitbox_for_attack_state(current_state)
	if hitbox == null:
		return {
			&"name": &"none", &"width": 0.0, &"height": 0.0,
			&"offset_x": 0.0, &"effective_range": 0.0,
		}
	var collision: CollisionShape2D = hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var rectangle: RectangleShape2D = collision.shape as RectangleShape2D if collision != null else null
	var size: Vector2 = rectangle.size if rectangle != null else Vector2.ZERO
	var target_half_width: float = 0.0
	if _has_target():
		var target_collision: CollisionShape2D = target.get_node_or_null(
			"Hurtbox/CollisionShape2D"
		) as CollisionShape2D
		var target_rectangle: RectangleShape2D = (
			target_collision.shape as RectangleShape2D if target_collision != null else null
		)
		if target_rectangle != null:
			target_half_width = target_rectangle.size.x * 0.5
	return {
		&"name": hitbox.name, &"width": size.x, &"height": size.y,
		&"offset_x": hitbox.position.x,
		&"effective_range": hitbox.position.x + size.x * 0.5 + target_half_width,
	}


func get_attack_gap_remaining() -> float:
	return _attack_gap_remaining


func get_last_attack_active_end_time() -> float:
	return _last_attack_active_end_time


func get_next_attack_windup_start_time() -> float:
	return _next_attack_windup_start_time


func get_measured_attack_gap() -> float:
	return _measured_attack_gap


func record_counter_test(action_name: StringName, escape_success: bool) -> void:
	_player_counter_action = action_name
	_player_escape_success = escape_success


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
	animated_sprite.speed_scale = 1.0
	if animation_name in [&"turn_shielded", &"turn_unshielded"]:
		var source_duration: float = _get_animation_duration(animation_name)
		if source_duration > 0.0 and config.boss_turn_animation_duration > 0.0:
			animated_sprite.speed_scale = source_duration / config.boss_turn_animation_duration
	animated_sprite.play(animation_name)


func _get_animation_duration(animation_name: StringName) -> float:
	var frames: SpriteFrames = animated_sprite.sprite_frames
	var speed: float = frames.get_animation_speed(animation_name)
	if speed <= 0.0:
		return 0.0
	var duration_units: float = 0.0
	for frame_index: int in range(frames.get_frame_count(animation_name)):
		duration_units += frames.get_frame_duration(animation_name, frame_index)
	return duration_units / speed


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
	if state_timer > 0.0:
		return
	match current_state:
		BOSS_INTRO:
			_enter_idle()
		SHIELD_BLOCK:
			_enter_idle()
		HURT_SHIELDED, HURT_UNSHIELDED:
			if _attack_gap_remaining > 0.0:
				_enter_post_attack_gap()
			else:
				_enter_idle()
		SHIELD_BREAK:
			transition_state(PHASE_TRANSITION)
			state_timer = config.phase_transition_duration
			play_animation(&"phase_transition", true)
		PHASE_TRANSITION:
			current_phase = 2
			phase_changed.emit(current_phase)
			_enter_idle()


func _process_post_attack_gap(delta: float) -> void:
	if not _has_target():
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		return
	if _process_turn_request(delta):
		velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		return
	var offset_x: float = target.global_position.x - global_position.x
	if _attack_gap_remaining > 0.0:
		var phase_speed: float = (
			config.shielded_move_speed if current_phase == 1 else config.unshielded_move_speed
		)
		var recovery_speed: float = phase_speed * config.post_attack_move_multiplier
		if absf(offset_x) > config.attack_range * 0.75:
			velocity.x = move_toward(
				velocity.x,
				facing_direction * recovery_speed,
				config.acceleration * config.post_attack_move_multiplier * delta
			)
		else:
			velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
		return
	velocity.x = 0.0
	if absf(offset_x) <= _get_attack_engagement_range() and _start_next_attack():
		return
	transition_state(APPROACH_SHIELDED if current_phase == 1 else APPROACH_UNSHIELDED)
	play_animation(&"walk_shielded" if current_phase == 1 else &"walk_unshielded")


func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
	if not _has_target():
		return
	if _process_turn_request(delta):
		return
	if _attack_gap_remaining > 0.0:
		_enter_post_attack_gap()
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
	if _attack_gap_remaining > 0.0:
		_enter_post_attack_gap()
		return
	if absf(offset.x) <= _get_attack_engagement_range():
		velocity.x = 0.0
		if _start_next_attack():
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
	_turn_return_timer = _attack_gap_remaining
	var turn_state: StringName = TURN_SHIELDED if current_phase == 1 else TURN_UNSHIELDED
	transition_state(turn_state)
	_turn_timer = config.boss_turn_animation_duration
	_turn_animation_elapsed = 0.0
	_turn_facing_committed = false
	velocity.x = 0.0
	play_animation(&"turn_shielded" if current_phase == 1 else &"turn_unshielded", true)


func _process_turn_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.deceleration * delta)
	if _turn_commit_queued:
		return
	_turn_animation_elapsed = minf(
		config.boss_turn_animation_duration,
		_turn_animation_elapsed + delta
	)
	_turn_timer = maxf(0.0, config.boss_turn_animation_duration - _turn_animation_elapsed)
	var facing_commit_time: float = (
		config.boss_turn_animation_duration * config.boss_turn_facing_commit_ratio
	)
	if not _turn_facing_committed and _turn_animation_elapsed + 0.000001 >= facing_commit_time:
		_commit_turn_facing()
	if _turn_timer <= 0.0:
		_turn_commit_queued = true
		call_deferred("_commit_turn")


func _commit_turn_facing() -> void:
	if _turn_facing_committed or current_state not in [TURN_SHIELDED, TURN_UNSHIELDED]:
		return
	_turn_facing_committed = true
	if not is_zero_approx(_pending_facing):
		set_facing_direction(_pending_facing)


func _commit_turn() -> void:
	if not _turn_commit_queued or current_state not in [TURN_SHIELDED, TURN_UNSHIELDED]:
		return
	_turn_commit_queued = false
	_commit_turn_facing()
	_turn_cooldown_timer = config.boss_turn_cooldown
	_pending_facing = 0.0
	_turn_timer = 0.0
	_turn_animation_elapsed = 0.0
	_turn_facing_committed = false
	_restore_state_after_turn()


func _restore_state_after_turn() -> void:
	var return_state: StringName = _turn_return_state
	_turn_return_state = &""
	_turn_return_timer = 0.0
	if return_state in [GUARD_RECOVERY, RECOVERY] and _attack_gap_remaining > 0.0:
		_enter_post_attack_gap()
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
	_turn_facing_committed = false
	_turn_animation_elapsed = 0.0


func _interrupt_turn() -> void:
	_turn_timer = 0.0
	_pending_facing = 0.0
	_turn_return_state = &""
	_turn_return_timer = 0.0
	_turn_commit_queued = false
	_turn_facing_committed = false
	_turn_animation_elapsed = 0.0


func _get_turn_phase_name() -> String:
	if current_state in [TURN_SHIELDED, TURN_UNSHIELDED]:
		if _turn_commit_queued:
			return "COMPLETE"
		return "FACING" if _turn_facing_committed else "ANIM"
	if not is_zero_approx(_pending_facing):
		return "REACT"
	return "OFF"


func _get_current_turn_total_remaining() -> float:
	if current_state in [TURN_SHIELDED, TURN_UNSHIELDED]:
		return _turn_timer
	if not is_zero_approx(_pending_facing):
		return _turn_timer + config.boss_turn_animation_duration
	return 0.0


func _start_next_attack() -> bool:
	if not _can_start_next_attack():
		return false
	var started: bool = false
	if current_phase == 1:
		var selected: StringName = _select_phase_one_attack(_get_player_distance())
		if not selected.is_empty():
			started = _start_attack(selected)
	else:
		var phase_two: Array[StringName] = [COMBO_SLASH, JUMP_SMASH, CHARGE_THRUST, SHOCKWAVE_STRIKE]
		started = _start_attack(_select_adaptive_phase_two_attack(phase_two))
	if started:
		attack_cycle += 1
	return started


func _select_phase_one_attack(distance: float) -> StringName:
	var candidates: Array[StringName] = []
	var weights: Array[float] = []
	if (
		distance <= config.shield_bash_trigger_range
		and _shield_bash_cooldown_remaining <= 0.0
		and _last_selected_attack != SHIELD_BASH
	):
		candidates.append(SHIELD_BASH)
		weights.append(config.shield_bash_selection_weight)
	if distance <= config.sword_slash_trigger_range:
		candidates.append(SWORD_SLASH)
		weights.append(config.sword_slash_selection_weight)
	if distance <= config.heavy_overhead_trigger_range:
		candidates.append(HEAVY_OVERHEAD)
		weights.append(config.heavy_overhead_selection_weight)
	if distance >= 112.0:
		# Gate Severance reuses the formal shockwave windup, then releases a
		# low, non-tracking ground blade.  The direction locks with the windup.
		# The remaining roll deliberately keeps the approach option alive, so
		# learned spacing cannot turn the counter into a deterministic answer.
		var severance_offer_chance: float = lerpf(0.55, 0.70, far_pressure)
		if _attack_rng.randf() <= severance_offer_chance:
			candidates.append(SHOCKWAVE_STRIKE)
			weights.append(0.34 * (1.0 + far_pressure * 1.2))
	if candidates.is_empty():
		return &""
	var total_weight: float = 0.0
	for candidate_index: int in range(candidates.size()):
		weights[candidate_index] *= _adaptive_phase_one_multiplier(candidates[candidate_index])
		total_weight += weights[candidate_index]
	_cap_counter_weight(candidates, weights, HEAVY_OVERHEAD, 0.70)
	total_weight = _sum_weights(weights)
	var adaptive_roll: float = _attack_rng.randf() * total_weight
	for candidate_index: int in range(candidates.size()):
		adaptive_roll -= weights[candidate_index]
		if adaptive_roll <= 0.0:
			_record_adaptive_decision(candidates[candidate_index], candidates, weights)
			return candidates[candidate_index]
	_record_adaptive_decision(candidates.back(), candidates, weights)
	return candidates.back()


func _get_attack_engagement_range() -> float:
	if current_phase == 1:
		return 330.0
	return 360.0


func _select_adaptive_phase_two_attack(candidates: Array[StringName]) -> StringName:
	if candidates.is_empty():
		return &""
	var weights: Array[float] = []
	var total_weight: float = 0.0
	for attack_state: StringName in candidates:
		var weight: float = _adaptive_phase_two_multiplier(attack_state)
		weights.append(weight)
		total_weight += weight
	_cap_counter_weight(candidates, weights, JUMP_SMASH, 0.70)
	total_weight = _sum_weights(weights)
	var roll: float = _attack_rng.randf() * total_weight
	for index: int in range(candidates.size()):
		roll -= weights[index]
		if roll <= 0.0:
			_record_adaptive_decision(candidates[index], candidates, weights)
			return candidates[index]
	_record_adaptive_decision(candidates.back(), candidates, weights)
	return candidates.back()


func _adaptive_phase_one_multiplier(attack_state: StringName) -> float:
	var multiplier: float = 1.0
	match attack_state:
		SHIELD_BASH:
			multiplier *= 1.0 + close_pressure * 0.45 + attack_pressure * 0.25
		SWORD_SLASH:
			multiplier *= 1.0 + close_pressure * 0.35
		HEAVY_OVERHEAD:
			# Rising Gate Cleave: the authored overhead remains committed and
			# punishable, but becomes more likely after repeated aerial cross-ups.
			multiplier *= 1.0 + air_pressure * 0.55 + crossup_pressure * 1.25
		SHOCKWAVE_STRIKE:
			multiplier *= 1.0 + far_pressure * 0.85
	return clampf(multiplier, 0.35, 2.50)


func _adaptive_phase_two_multiplier(attack_state: StringName) -> float:
	var multiplier: float = 1.0
	match attack_state:
		COMBO_SLASH:
			multiplier *= 1.0 + close_pressure * 0.55 + attack_pressure * 0.20
		JUMP_SMASH:
			multiplier *= 1.0 + air_pressure * 0.50 + crossup_pressure * 1.20
		CHARGE_THRUST:
			multiplier *= 1.0 + dash_pressure * 0.42 + far_pressure * 0.28
		SHOCKWAVE_STRIKE:
			multiplier *= 1.0 + far_pressure * 0.95
	return clampf(multiplier, 0.35, 2.55)


func _cap_counter_weight(
	candidates: Array[StringName], weights: Array[float], counter_action: StringName, probability_cap: float
) -> void:
	var counter_index: int = candidates.find(counter_action)
	if counter_index < 0 or candidates.size() < 2:
		return
	var other_weight: float = _sum_weights(weights) - weights[counter_index]
	var maximum_counter_weight: float = other_weight * probability_cap / (1.0 - probability_cap)
	weights[counter_index] = minf(weights[counter_index], maximum_counter_weight)


func _sum_weights(weights: Array[float]) -> float:
	var total: float = 0.0
	for weight: float in weights:
		total += weight
	return total


func _start_attack(attack_state: StringName) -> bool:
	if not _can_start_next_attack():
		return false
	if not transition_state(attack_state):
		return false
	_interrupt_turn()
	velocity.x = 0.0
	_next_attack_windup_start_time = _combat_clock
	if _last_attack_active_end_time >= 0.0:
		_measured_attack_gap = maxf(
			0.0, _next_attack_windup_start_time - _last_attack_active_end_time
		)
	current_attack_id = _next_attack_id
	_next_attack_id += 1
	_last_selected_attack = attack_state
	if attack_state == SHIELD_BASH:
		_shield_bash_cooldown_remaining = config.shield_bash_repeat_cooldown
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
	return true


func _can_start_next_attack() -> bool:
	return (
		_attack_gap_remaining <= 0.0
		and current_state in [
			IDLE_SHIELDED, APPROACH_SHIELDED, GUARD_RECOVERY,
			IDLE_UNSHIELDED, APPROACH_UNSHIELDED, RECOVERY,
		]
	)


func _on_animation_frame_changed() -> void:
	_update_shield_overlay_pose()
	if current_state not in ATTACK_STATES:
		_end_attack_window()
		return
	var active: bool = false
	var damage: int = 1
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
			if active and _gate_wave_spawned_for_id != current_attack_id:
				_gate_wave_spawned_for_id = current_attack_id
				_spawn_gate_severance_wave()
			_end_attack_window()
			return
	_set_attack_window(active, damage)


func _set_attack_window(active: bool, damage: int) -> void:
	var selected: HitboxComponent = _get_hitbox_for_attack_state(current_state)
	if selected == null:
		_end_attack_window()
		return
	for hitbox: HitboxComponent in _get_attack_hitboxes():
		if hitbox != selected and hitbox.is_active:
			hitbox.end_attack()
	if active and not selected.is_active:
		selected.begin_attack(current_attack_id, damage, facing_direction, self)
		attack_window_changed.emit(true)
	elif not active and selected.is_active:
		selected.end_attack()
		attack_window_changed.emit(false)
		_record_natural_attack_active_end()


func _get_hitbox_for_attack_state(attack_state: StringName) -> HitboxComponent:
	match attack_state:
		SHIELD_BASH:
			return shield_bash_hitbox
		SWORD_SLASH, HEAVY_OVERHEAD, COMBO_SLASH, JUMP_SMASH:
			return slash_hitbox
		CHARGE_THRUST:
			return thrust_hitbox
		SHOCKWAVE_STRIKE:
			return shockwave_hitbox
	return null


func _get_attack_hitboxes() -> Array[HitboxComponent]:
	return [shield_bash_hitbox, slash_hitbox, thrust_hitbox, shockwave_hitbox]


func _get_active_hitbox() -> HitboxComponent:
	for hitbox: HitboxComponent in _get_attack_hitboxes():
		if hitbox != null and hitbox.is_active:
			return hitbox
	return null


func _record_natural_attack_active_end() -> void:
	if current_state not in ATTACK_STATES or _attack_gap_source_id == current_attack_id:
		return
	if (
		current_state == COMBO_SLASH
		and animated_sprite.animation == &"combo_slash_1"
	):
		return
	_attack_gap_source_id = current_attack_id
	_last_completed_attack = current_state
	_last_attack_active_end_time = _combat_clock
	_attack_gap_remaining = _get_attack_gap_for_state(current_state)


func _get_attack_gap_for_state(attack_state: StringName) -> float:
	match attack_state:
		SHIELD_BASH:
			return config.shield_bash_attack_gap
		SWORD_SLASH:
			return config.sword_slash_attack_gap
		HEAVY_OVERHEAD:
			return config.heavy_overhead_attack_gap
		COMBO_SLASH:
			return config.combo_slash_attack_gap
		CHARGE_THRUST:
			return config.charge_thrust_attack_gap
		JUMP_SMASH:
			return config.jump_smash_attack_gap
		SHOCKWAVE_STRIKE:
			return config.shockwave_strike_attack_gap
	return config.attack_recovery


func _end_attack_window() -> void:
	var changed: bool = false
	for hitbox: HitboxComponent in _get_attack_hitboxes():
		if hitbox != null and hitbox.is_active:
			hitbox.end_attack()
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
		if _attack_gap_source_id != current_attack_id:
			# Defensive fallback for tests or skipped frame callbacks. Runtime normally
			# records the exact close when the active frame advances.
			_attack_gap_source_id = current_attack_id
			_last_completed_attack = current_state
			_last_attack_active_end_time = _combat_clock
			_attack_gap_remaining = _get_attack_gap_for_state(current_state)
		_enter_post_attack_gap()


func _on_shield_hit(_hitbox: HitboxComponent, _damage: int, _remaining: int) -> void:
	if current_state in [DEATH, SHIELD_BREAK, PHASE_TRANSITION]:
		return
	var attack_kind: StringName = shield_component.last_attack_kind
	if attack_kind == &"normal_attack":
		_apply_light_hit_feedback()
		return
	if attack_kind in [&"dash_attack", &"ground_dash_attack", &"air_dash_attack"]:
		_apply_heavy_hit_feedback(false, shield_component.last_source_position)
		return
	_apply_light_hit_feedback()


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
	var attack_kind: StringName = shield_component.last_attack_kind
	if attack_kind == &"normal_attack":
		_apply_light_hit_feedback()
		return
	if attack_kind in [&"dash_attack", &"ground_dash_attack", &"air_dash_attack"]:
		_apply_heavy_hit_feedback(true, source_position)
		return
	_apply_light_hit_feedback()


func _apply_light_hit_feedback() -> void:
	_last_hurt_reaction_type = &"light_ignored" if _light_hit_reaction_cooldown > 0.0 else &"light"
	if _light_hit_reaction_cooldown > 0.0:
		return
	_light_hit_reaction_cooldown = config.boss_light_hit_reaction_cooldown
	_flash_hit(Color(0.90, 0.94, 1.0, 1.0), 0.055)


func _apply_heavy_hit_feedback(body_hit: bool, source_position: Vector2) -> void:
	_last_hurt_reaction_type = &"heavy_ignored" if _heavy_hit_reaction_cooldown > 0.0 else &"heavy"
	if _heavy_hit_reaction_cooldown > 0.0:
		return
	_heavy_hit_reaction_cooldown = config.boss_heavy_hit_reaction_cooldown
	_flash_hit(Color(1.0, 0.92, 0.75, 1.0), 0.075)
	if not body_hit or not _can_heavy_hit_interrupt():
		return
	_end_attack_window()
	_interrupt_turn()
	var hurt_state: StringName = HURT_SHIELDED if current_phase == 1 else HURT_UNSHIELDED
	transition_state(hurt_state)
	state_timer = config.boss_heavy_hit_reaction_duration
	velocity.x = signf(global_position.x - source_position.x) * 45.0
	play_animation(&"hurt_shielded" if current_phase == 1 else &"hurt_unshielded", true)


func _can_heavy_hit_interrupt() -> bool:
	return current_state in [
		IDLE_SHIELDED, APPROACH_SHIELDED, GUARD_RECOVERY,
		IDLE_UNSHIELDED, APPROACH_UNSHIELDED, RECOVERY,
	]


func _flash_hit(color: Color, duration: float) -> void:
	modulate = color
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, duration)


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


func _enter_post_attack_gap() -> void:
	transition_state(GUARD_RECOVERY if current_phase == 1 else RECOVERY)
	state_timer = 0.0
	play_animation(&"idle_shielded" if current_phase == 1 else &"idle_unshielded", true)


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
	var ratio: float = float(shield_health) / float(shield_component.shield_max_health)
	if ratio >= 0.8:
		return &"intact"
	if ratio >= 0.5:
		return &"damaged"
	return &"critical"


func _get_player_distance() -> float:
	if not _has_target():
		return INF
	return absf(target.global_position.x - global_position.x)


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
	if not _has_target():
		return
	_behavior_sample_timer -= delta
	if _behavior_sample_timer <= 0.0:
		_behavior_sample_timer = BEHAVIOR_SAMPLE_INTERVAL
		var distance: float = _get_player_distance()
		if distance >= 205.0:
			_queue_behavior_event(&"far", 0.055)
		elif distance <= 68.0:
			_queue_behavior_event(&"close", 0.055)
		if not target.is_on_floor():
			_queue_behavior_event(&"air", 0.045)
	var side: float = signf(target.global_position.x - global_position.x)
	var action_name: StringName = (
		target.action_controller.get_action_state_name()
		if target.action_controller != null else &"None"
	)
	var movement_name: StringName = target.get_movement_state_name()
	if (
		not is_zero_approx(_previous_target_side)
		and side != _previous_target_side
		and not target.is_on_floor()
		and absf(target.global_position.y - global_position.y) < 112.0
	):
		observed_crossup_count += 1
		_queue_behavior_event(&"crossup", 0.30)
	if movement_name != _previous_target_movement:
		if movement_name in [&"jump_start", &"double_jump"]:
			observed_jump_count += 1
		if movement_name == &"double_jump":
			observed_double_jump_count += 1
	if action_name != _previous_target_action:
		if String(action_name).contains("Dash"):
			_queue_behavior_event(&"dash", 0.22)
		elif String(action_name).contains("Attack"):
			_queue_behavior_event(&"attack", 0.15)
	if not is_zero_approx(_previous_target_side) and side != _previous_target_side and String(action_name).contains("Dash"):
		observed_dash_through_count += 1
	_previous_target_side = side
	_previous_target_action = action_name
	_previous_target_movement = movement_name


func _queue_behavior_event(kind_name: StringName, amount: float) -> void:
	_behavior_events.append({
		&"at": _behavior_clock + BEHAVIOR_REACTION_DELAY,
		&"kind": kind_name,
		&"amount": amount * (1.12 if current_phase == 2 else 1.0),
	})


func _apply_due_behavior_events() -> void:
	while (
		not _behavior_events.is_empty()
		and float(_behavior_events.front().get(&"at", INF)) <= _behavior_clock
	):
		var event: Dictionary = _behavior_events.pop_front()
		var amount: float = float(event.get(&"amount", 0.0))
		var kind_name: StringName = StringName(event.get(&"kind", &""))
		match kind_name:
			&"far": far_pressure = minf(1.0, far_pressure + amount)
			&"close": close_pressure = minf(1.0, close_pressure + amount)
			&"air": air_pressure = minf(1.0, air_pressure + amount)
			&"crossup": crossup_pressure = minf(1.0, crossup_pressure + amount)
			&"dash": dash_pressure = minf(1.0, dash_pressure + amount)
			&"attack": attack_pressure = minf(1.0, attack_pressure + amount)


func _record_adaptive_decision(
	action: StringName, candidates: Array[StringName], weights: Array[float]
) -> void:
	_adaptive_decision_reason = StringName(
		"%s:F%.2f:C%.2f:A%.2f:X%.2f:D%.2f" % [
			action, far_pressure, close_pressure, air_pressure, crossup_pressure, dash_pressure,
		]
	)
	if OS.is_debug_build():
		print(
			"[BOSS_DECISION] boss=FallenGateKnight phase=%d distance=%.1f pressure=[far=%.2f close=%.2f air=%.2f cross=%.2f dash=%.2f] recent=%s candidates=%s weights=%s selected=%s reason=%s" % [
				current_phase, _get_player_distance(), far_pressure, close_pressure,
				air_pressure, crossup_pressure, dash_pressure, _last_selected_attack,
				candidates, weights, action, _adaptive_decision_reason,
			]
		)


func _reset_behavior_context() -> void:
	far_pressure = 0.0
	close_pressure = 0.0
	air_pressure = 0.0
	crossup_pressure = 0.0
	dash_pressure = 0.0
	attack_pressure = 0.0
	_behavior_clock = 0.0
	_behavior_sample_timer = 0.0
	_behavior_events.clear()
	_previous_target_side = 0.0
	_previous_target_action = &"None"
	_previous_target_movement = &"idle"
	_adaptive_decision_reason = &"base"
	_gate_wave_spawned_for_id = -1
	observed_jump_count = 0
	observed_double_jump_count = 0
	observed_crossup_count = 0
	observed_dash_through_count = 0


func get_behavior_pressures() -> Dictionary[StringName, float]:
	return {
		&"far": far_pressure,
		&"close": close_pressure,
		&"air": air_pressure,
		&"crossup": crossup_pressure,
		&"dash": dash_pressure,
		&"attack": attack_pressure,
	}


func get_adaptive_decision_reason() -> StringName:
	return _adaptive_decision_reason


func _spawn_gate_severance_wave() -> void:
	if not is_inside_tree():
		return
	var wave: HitboxComponent = HitboxComponent.new()
	wave.name = "GateSeveranceWave"
	wave.faction = &"enemy"
	wave.attack_kind = &"boss_gate_severance"
	wave.collision_layer = 64
	wave.collision_mask = 8
	wave.z_index = 3
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(42.0, 18.0)
	collision.shape = shape
	wave.add_child(collision)
	var blade: Polygon2D = Polygon2D.new()
	blade.polygon = PackedVector2Array([
		Vector2(-22.0, 6.0), Vector2(-8.0, -8.0), Vector2(18.0, -5.0),
		Vector2(26.0, 0.0), Vector2(18.0, 5.0), Vector2(-8.0, 8.0),
	])
	blade.color = Color("93a8b8")
	wave.add_child(blade)
	get_parent().add_child(wave)
	wave.global_position = global_position + Vector2(facing_direction * 44.0, -8.0)
	wave.begin_attack(current_attack_id, config.shockwave_damage, facing_direction, self)
	var tween: Tween = wave.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(wave, "global_position:x", wave.global_position.x + facing_direction * 285.0, 0.78)
	tween.finished.connect(func() -> void:
		if is_instance_valid(wave):
			wave.end_attack()
			wave.queue_free()
	)


func _configure_attack_geometry() -> void:
	_configure_rectangle_hitbox(
		shield_bash_hitbox, config.shield_bash_hitbox_offset, config.shield_bash_hitbox_size
	)
	_configure_rectangle_hitbox(slash_hitbox, config.slash_hitbox_offset, config.slash_hitbox_size)
	_configure_rectangle_hitbox(thrust_hitbox, config.thrust_hitbox_offset, config.thrust_hitbox_size)


func _configure_rectangle_hitbox(
	hitbox: HitboxComponent,
	offset: Vector2,
	size: Vector2
) -> void:
	if hitbox == null:
		return
	hitbox.position = offset
	var collision: CollisionShape2D = hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var rectangle: RectangleShape2D = collision.shape as RectangleShape2D if collision != null else null
	if rectangle != null:
		rectangle.size = size


func _has_target() -> bool:
	return target != null and is_instance_valid(target) and not target.is_dead()


func _validate_dependencies() -> bool:
	if config == null:
		push_error("FallenGateKnight requires FallenGateKnightConfig")
		return false
	if animated_sprite == null or shield_damage_overlay == null or facing_root == null or health_component == null or shield_component == null or hurtbox == null or shield_bash_hitbox == null or slash_hitbox == null or thrust_hitbox == null or shockwave_hitbox == null:
		push_error("FallenGateKnight scene composition is incomplete")
		return false
	return true
