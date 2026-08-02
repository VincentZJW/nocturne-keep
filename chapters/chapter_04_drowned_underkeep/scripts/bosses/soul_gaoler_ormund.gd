class_name SoulGaolerOrmund
extends GroundEnemyBase

signal phase_changed(phase: int)
signal boss_action_started(action: StringName, phase: int)
signal boss_action_active(action: StringName, active: bool)

const INTRO: StringName = &"Intro"
const COMBAT: StringName = &"Combat"
const TURN: StringName = &"Turn"
const PHASE_TRANSITION: StringName = &"PhaseTransition"
const STAGGER: StringName = &"Stagger"

@export_node_path("HitboxComponent") var melee_hitbox_path: NodePath = NodePath("FacingRoot/MeleeHitbox")
@export_node_path("HitboxComponent") var area_hitbox_path: NodePath = NodePath("AreaHitbox")
@export_node_path("Chapter04PoiseComponent") var poise_component_path: NodePath = NodePath("PoiseComponent")
@export_node_path("Chapter04BossDamagePolicy") var damage_policy_path: NodePath = NodePath("DamagePolicy")

@onready var melee_hitbox: HitboxComponent = get_node_or_null(melee_hitbox_path) as HitboxComponent
@onready var area_hitbox: HitboxComponent = get_node_or_null(area_hitbox_path) as HitboxComponent
@onready var poise_component: Chapter04PoiseComponent = get_node_or_null(poise_component_path) as Chapter04PoiseComponent
@onready var damage_policy: Chapter04BossDamagePolicy = get_node_or_null(damage_policy_path) as Chapter04BossDamagePolicy

var phase: int = 1
var attack_phase: StringName = &"None"
var active_action: StringName = &""
var action_timer: float = 0.0
var action_damage: int = 0
var action_active_duration: float = 0.0
var action_recovery_duration: float = 0.0
var current_attack_id: int = 0
var _next_attack_id: int = 1
var _judgment_cooldown: float = 0.0
var _stagger_protection: float = 0.0
var _transition_started: bool = false


func complete_debug_phase_transition() -> void:
	if current_state == PHASE_TRANSITION:
		_finish_phase_transition()


func _on_common_ready() -> void:
	if melee_hitbox == null or area_hitbox == null or poise_component == null or damage_policy == null:
		push_error("SoulGaolerOrmund requires hitboxes, poise and damage policy")
		set_physics_process(false)
		return
	health_component.max_health = _boss_config().total_health
	health_component.reset_to_full()
	damage_policy.damage_multiplier = _boss_config().phase_one_damage_multiplier
	poise_component.configure(_boss_config().phase_one_poise, 1.35)
	hurtbox.hit_resolving.connect(_on_hit_resolving)
	health_component.health_changed.connect(_on_health_changed)
	_end_hitboxes()
	transition_state(INTRO)
	state_timer = 1.05
	play_animation(&"intro", true)


func _process_enemy_state(delta: float) -> void:
	_judgment_cooldown = maxf(0.0, _judgment_cooldown - delta)
	_stagger_protection = maxf(0.0, _stagger_protection - delta)
	poise_component.advance(delta, current_state in [STAGGER, PHASE_TRANSITION])
	if current_state == INTRO:
		state_timer = maxf(0.0, state_timer - delta)
		if state_timer <= 0.0:
			transition_state(COMBAT)
			play_animation(&"idle_p1")
		return
	if current_state == PHASE_TRANSITION:
		state_timer = maxf(0.0, state_timer - delta)
		velocity = Vector2.ZERO
		if state_timer <= 0.0:
			_finish_phase_transition()
		return
	if current_state == STAGGER:
		state_timer = maxf(0.0, state_timer - delta)
		velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
		if state_timer <= 0.0:
			transition_state(COMBAT)
			play_animation(_idle_animation())
		return
	if attack_phase != &"None":
		_process_action(delta)
		return
	_process_combat(delta)


func _process_combat(delta: float) -> void:
	if not _validate_target():
		velocity.x = 0.0
		play_animation(_idle_animation())
		return
	var offset: Vector2 = target.global_position - global_position
	var direction: float = signf(offset.x)
	var distance_x: float = absf(offset.x)
	if direction != facing_direction:
		transition_state(TURN)
		state_timer = 0.22 if phase == 1 else 0.16
		velocity.x = 0.0
		play_animation(&"turn_p1" if phase == 1 else &"turn_p2", true)
		set_facing_direction(direction)
		return
	if current_state == TURN:
		state_timer = maxf(0.0, state_timer - delta)
		if state_timer > 0.0:
			return
		transition_state(COMBAT)
	var selected: StringName = _select_action(distance_x)
	if not selected.is_empty():
		_start_action(selected)
		return
	if can_advance(direction):
		velocity.x = move_toward(velocity.x, direction * (48.0 if phase == 1 else 64.0), config.ground_acceleration * delta)
		play_animation(&"walk_p1" if phase == 1 else &"move_p2")
	else:
		velocity.x = 0.0
		play_animation(_idle_animation())


func _select_action(distance_x: float) -> StringName:
	if phase == 1:
		if distance_x > 150.0 and distance_x < 285.0 and _next_attack_id % 3 == 0: return &"floodgate_charge"
		if distance_x < 86.0 and _next_attack_id % 5 == 0: return &"soul_cage_pulse"
		if distance_x < 112.0 and _next_attack_id % 4 == 0: return &"prison_hook_drag"
		if distance_x < 92.0 and _next_attack_id % 2 == 0: return &"chain_anchor_slam"
		if distance_x < 118.0: return &"halberd_sweep"
	else:
		var health_ratio: float = float(health_component.current_health) / float(maxi(1, health_component.max_health))
		if _judgment_cooldown <= 0.0 and health_ratio <= 0.24:
			_judgment_cooldown = _boss_config().judgment_cooldown
			return &"flooded_judgment"
		if distance_x > 150.0 and _next_attack_id % 4 == 0: return &"drowned_cell_rupture"
		if distance_x > 105.0 and _next_attack_id % 3 == 0: return &"undertow_pull"
		if distance_x < 78.0 and _next_attack_id % 5 == 0: return &"soul_shackle"
		if distance_x < 130.0: return &"chainstorm_cleave"
	return &""


func _start_action(action: StringName) -> void:
	var timing: Vector3 = _action_timing(action)
	active_action = action
	action_damage = _action_damage(action)
	action_active_duration = timing.y
	action_recovery_duration = timing.z
	attack_phase = &"Windup"
	action_timer = timing.x
	velocity.x = 0.0
	transition_state(StringName("%sWindup" % action))
	play_animation(StringName("%s_windup" % action), true)
	boss_action_started.emit(action, phase)


func _process_action(delta: float) -> void:
	if attack_phase == &"Active" and active_action in [&"floodgate_charge", &"chainstorm_cleave"]:
		velocity.x = facing_direction * (205.0 if active_action == &"floodgate_charge" else 132.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	action_timer = maxf(0.0, action_timer - delta)
	if action_timer > 0.0:
		return
	match attack_phase:
		&"Windup": _begin_active()
		&"Active": _begin_recovery()
		&"Recovery":
			attack_phase = &"None"
			active_action = &""
			transition_state(COMBAT)
			play_animation(_idle_animation())


func _begin_active() -> void:
	attack_phase = &"Active"
	action_timer = action_active_duration
	current_attack_id = _next_attack_id
	_next_attack_id += 1
	transition_state(StringName("%sActive" % active_action))
	play_animation(StringName("%s_active" % active_action), true)
	var hitbox: HitboxComponent = area_hitbox if active_action in [&"soul_cage_pulse", &"drowned_cell_rupture", &"flooded_judgment"] else melee_hitbox
	hitbox.attack_kind = StringName("enemy_%s" % active_action)
	hitbox.begin_attack(current_attack_id, action_damage, facing_direction, self)
	boss_action_active.emit(active_action, true)
	attack_window_changed.emit(true)
	if active_action in [&"prison_hook_drag", &"undertow_pull"] and has_valid_target():
		target.velocity.x = move_toward(target.velocity.x, global_position.x - target.global_position.x, 82.0)
	if active_action == &"soul_shackle" and has_valid_target() and target.status_effect_controller != null:
		target.status_effect_controller.apply_mire(&"ormund_shackle", 1.2, 1.0, 0.1)


func _begin_recovery() -> void:
	_end_hitboxes()
	boss_action_active.emit(active_action, false)
	attack_phase = &"Recovery"
	action_timer = action_recovery_duration
	transition_state(StringName("%sRecovery" % active_action))
	play_animation(StringName("%s_recovery" % active_action), true)


func _on_health_changed(current: int, _maximum: int) -> void:
	if phase == 1 and not _transition_started and current <= roundi(_boss_config().total_health * _boss_config().phase_two_threshold_ratio):
		_transition_started = true
		_on_attack_cancelled()
		transition_state(PHASE_TRANSITION)
		state_timer = _boss_config().phase_transition_duration
		velocity = Vector2.ZERO
		play_animation(&"phase_transition", true)


func _finish_phase_transition() -> void:
	phase = 2
	damage_policy.damage_multiplier = _boss_config().phase_two_damage_multiplier
	poise_component.configure(_boss_config().phase_two_poise, 1.45)
	transition_state(COMBAT)
	play_animation(&"idle_p2", true)
	phase_changed.emit(phase)


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	if hitbox == null or is_dead() or current_state == PHASE_TRANSITION or _stagger_protection > 0.0:
		return
	var impact: int = 28 if hitbox.attack_kind in [&"dash_attack", &"ground_dash_attack", &"air_dash_attack"] else 14
	if not poise_component.apply_impact(impact):
		return
	_on_attack_cancelled()
	transition_state(STAGGER)
	state_timer = _boss_config().phase_one_stagger_duration if phase == 1 else _boss_config().phase_two_stagger_duration
	_stagger_protection = _boss_config().phase_one_stagger_protection if phase == 1 else _boss_config().phase_two_stagger_protection
	play_animation(&"stagger_p1" if phase == 1 else &"stagger_p2", true)


func _on_hurtbox_hit_received(_damage: int, _source_position: Vector2, _attack_id: int) -> void:
	if is_dead() or current_state in [PHASE_TRANSITION, STAGGER]:
		return
	play_animation(&"light_hit_p1" if phase == 1 else &"light_hit_p2", true)


func _action_timing(action: StringName) -> Vector3:
	match action:
		&"halberd_sweep": return Vector3(0.60,0.15,0.76)
		&"chain_anchor_slam": return Vector3(0.82,0.17,1.05)
		&"prison_hook_drag": return Vector3(0.70,0.14,0.88)
		&"floodgate_charge": return Vector3(0.66,0.24,1.05)
		&"soul_cage_pulse": return Vector3(0.78,0.16,0.92)
		&"chainstorm_cleave": return Vector3(0.58,0.22,0.78)
		&"undertow_pull": return Vector3(0.72,0.18,0.86)
		&"drowned_cell_rupture": return Vector3(0.88,0.18,1.00)
		&"soul_shackle": return Vector3(0.64,0.14,0.82)
		&"flooded_judgment": return Vector3(1.02,0.24,1.15)
	return Vector3(0.60,0.15,0.80)


func _action_damage(action: StringName) -> int:
	match action:
		&"halberd_sweep": return _boss_config().halberd_sweep_damage
		&"chain_anchor_slam": return _boss_config().anchor_slam_damage
		&"prison_hook_drag": return _boss_config().hook_drag_damage
		&"floodgate_charge": return _boss_config().floodgate_charge_damage
		&"soul_cage_pulse": return _boss_config().soul_cage_pulse_damage
		&"chainstorm_cleave": return _boss_config().chainstorm_cleave_damage
		&"undertow_pull": return _boss_config().undertow_pull_damage
		&"drowned_cell_rupture": return _boss_config().cell_rupture_damage
		&"soul_shackle": return _boss_config().soul_shackle_damage
		&"flooded_judgment": return _boss_config().flooded_judgment_damage
	return 1


func _end_hitboxes() -> void:
	if melee_hitbox != null: melee_hitbox.end_attack()
	if area_hitbox != null: area_hitbox.end_attack()
	attack_window_changed.emit(false)


func _on_attack_cancelled() -> void:
	_end_hitboxes()
	attack_phase = &"None"
	active_action = &""
	super._on_attack_cancelled()


func _validate_target() -> bool:
	return has_valid_target() and global_position.distance_to(target.global_position) <= config.lose_target_range


func _idle_animation() -> StringName:
	return &"idle_p1" if phase == 1 else &"idle_p2"


func _is_death_animation(animation_name: StringName) -> bool:
	return animation_name == &"soul_release"


func enter_death() -> void:
	if not transition_state(DEATH): return
	velocity=Vector2.ZERO; _on_attack_cancelled(); hurtbox.set_enabled(false); detection_area.set_deferred("monitoring",false); collision_layer=0; collision_mask=1
	play_animation(&"death_start",true); enemy_died.emit(); call_deferred("_play_death_sequence")


func _play_death_sequence() -> void:
	await get_tree().create_timer(0.55).timeout
	if not is_inside_tree(): return
	play_animation(&"death_collapse",true)
	await get_tree().create_timer(0.65).timeout
	if not is_inside_tree(): return
	play_animation(&"soul_release",true)


func get_attack_phase_name() -> StringName: return attack_phase
func is_attack_window_active() -> bool: return (melee_hitbox != null and melee_hitbox.is_active) or (area_hitbox != null and area_hitbox.is_active)
func get_debug_summary() -> String: return "Soul Gaoler Ormund P%d %s HP %d/%d POISE %d/%d %s/%s" % [phase,current_state,health_component.current_health,health_component.max_health,poise_component.current_poise,poise_component.max_poise,active_action,attack_phase]
func _boss_config() -> SoulGaolerOrmundConfig: return config as SoulGaolerOrmundConfig
