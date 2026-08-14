class_name SoulGaolerOrmund
extends GroundEnemyBase

signal phase_changed(phase: int)
signal phase_transition_started(duration: float)
signal phase_transition_cue(cue_name: StringName, elapsed_seconds: float)
signal boss_action_started(action: StringName, phase: int)
signal boss_action_active(action: StringName, active: bool)
signal player_turn_started(duration: float, phase: int)
signal intro_started
signal combat_started
signal death_sequence_started
signal defeated

const INTRO: StringName = &"Intro"
const COMBAT: StringName = &"Combat"
const TURN: StringName = &"Turn"
const PLAYER_TURN: StringName = &"PlayerTurn"
const PHASE_TRANSITION: StringName = &"PhaseTransition"
const STAGGER: StringName = &"Stagger"
const PHASE_TRANSITION_CUE_TIMES: PackedFloat32Array = [1.153846, 2.307692, 4.615385, 6.923077, 8.653846]
const PHASE_TRANSITION_CUES: Array[StringName] = [
	&"first_chain_break",
	&"second_chain_break",
	&"soul_cage_collapse",
	&"flood_surge",
	&"final_iron_impact",
]

@export_node_path("HitboxComponent") var melee_hitbox_path: NodePath = NodePath("FacingRoot/MeleeHitbox")
@export_node_path("HitboxComponent") var area_hitbox_path: NodePath = NodePath("AreaHitbox")
@export_node_path("Chapter04PoiseComponent") var poise_component_path: NodePath = NodePath("PoiseComponent")
@export_node_path("Chapter04BossDamagePolicy") var damage_policy_path: NodePath = NodePath("DamagePolicy")
@export var external_intro_control: bool = false

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
var _soul_cage_pulse_cooldown: float = 0.0
var _cell_rupture_cooldown: float = 0.0
var _stagger_protection: float = 0.0
var _transition_started: bool = false
var _transition_elapsed: float = 0.0
var _transition_cue_index: int = 0
var _combat_enabled: bool = true
var _defeat_emitted: bool = false
var combo_count: int = 0
var combo_budget: int = 2
var player_turn_remaining: float = 0.0
var direction_locked: bool = false
var _combo_sequence_index: int = 0
var _high_pressure_used_in_combo: bool = false
var _pending_facing_direction: float = 0.0
var _turn_remaining: float = 0.0
var _recent_attack_history: Array[StringName] = []


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
	_reset_combo_sequence()
	hurtbox.hit_resolving.connect(_on_hit_resolving)
	health_component.health_changed.connect(_on_health_changed)
	_end_hitboxes()
	transition_state(INTRO)
	_combat_enabled = not external_intro_control
	state_timer = 1.05 if _combat_enabled else 0.0
	play_animation(&"dormant" if external_intro_control else &"intro", true)
	if external_intro_control:
		set_physics_process(false)
		hurtbox.set_enabled(false)
		detection_area.set_deferred("monitoring", false)


func _process_enemy_state(delta: float) -> void:
	if not _combat_enabled:
		velocity = Vector2.ZERO
		return
	_judgment_cooldown = maxf(0.0, _judgment_cooldown - delta)
	_soul_cage_pulse_cooldown = maxf(0.0, _soul_cage_pulse_cooldown - delta)
	_cell_rupture_cooldown = maxf(0.0, _cell_rupture_cooldown - delta)
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
		_transition_elapsed = _boss_config().phase_transition_duration - state_timer
		_emit_due_transition_cues()
		velocity = Vector2.ZERO
		if state_timer <= 0.0:
			_finish_phase_transition()
		return
	if current_state == STAGGER:
		state_timer = maxf(0.0, state_timer - delta)
		velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
		if state_timer <= 0.0:
			_reset_combo_sequence()
			transition_state(COMBAT)
			play_animation(_idle_animation())
		return
	if current_state == PLAYER_TURN:
		_process_player_turn(delta)
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
		if not _process_delayed_turn(direction, delta):
			return
	elif current_state == TURN:
		_pending_facing_direction = 0.0
		_turn_remaining = 0.0
		transition_state(COMBAT)
	var selected: StringName = _select_action(distance_x)
	if not selected.is_empty():
		_start_action(selected)
		return
	if combo_count > 0:
		_start_player_turn()
		return
	if can_advance(direction):
		velocity.x = move_toward(velocity.x, direction * (48.0 if phase == 1 else 64.0), config.ground_acceleration * delta)
		play_animation(&"walk_p1" if phase == 1 else &"move_p2")
	else:
		velocity.x = 0.0
		play_animation(_idle_animation())


func _select_action(distance_x: float) -> StringName:
	var preferred: StringName = &""
	var target_near_edge: bool = _is_target_near_arena_edge()
	if phase == 1:
		if not target_near_edge and distance_x > 150.0 and distance_x < 285.0 and _next_attack_id % 3 == 0:
			preferred = &"floodgate_charge"
		elif distance_x < 86.0 and _soul_cage_pulse_cooldown <= 0.0 and _next_attack_id % 5 == 0:
			preferred = &"soul_cage_pulse"
		elif not target_near_edge and distance_x < 112.0 and _next_attack_id % 4 == 0:
			preferred = &"prison_hook_drag"
		elif distance_x < 92.0 and _next_attack_id % 2 == 0:
			preferred = &"chain_anchor_slam"
		elif distance_x < 118.0:
			preferred = &"halberd_sweep"
	else:
		var health_ratio: float = float(health_component.current_health) / float(maxi(1, health_component.max_health))
		if _judgment_cooldown <= 0.0 and health_ratio <= 0.24:
			preferred = &"flooded_judgment"
		elif distance_x > 150.0 and _cell_rupture_cooldown <= 0.0 and _next_attack_id % 4 == 0:
			preferred = &"drowned_cell_rupture"
		elif distance_x > 105.0 and _next_attack_id % 3 == 0:
			preferred = &"undertow_pull"
		elif distance_x < 78.0 and _next_attack_id % 5 == 0:
			preferred = &"soul_shackle"
		elif distance_x < 130.0:
			preferred = &"chainstorm_cleave"
	return _resolve_action_choice(preferred, distance_x, target_near_edge)


func _resolve_action_choice(
	preferred: StringName,
	distance_x: float,
	target_near_edge: bool
) -> StringName:
	if _can_use_action(preferred, target_near_edge):
		return preferred
	var fallbacks: Array[StringName] = []
	if phase == 1:
		if distance_x < 92.0:
			fallbacks.append(&"chain_anchor_slam")
		if distance_x < 118.0:
			fallbacks.append(&"halberd_sweep")
		if distance_x < 112.0 and not target_near_edge:
			fallbacks.append(&"prison_hook_drag")
		if distance_x < 86.0 and _soul_cage_pulse_cooldown <= 0.0:
			fallbacks.append(&"soul_cage_pulse")
		if distance_x > 150.0 and distance_x < 285.0 and not target_near_edge:
			fallbacks.append(&"floodgate_charge")
	else:
		if distance_x < 78.0:
			fallbacks.append(&"soul_shackle")
		if distance_x < 130.0:
			fallbacks.append(&"chainstorm_cleave")
		if distance_x > 105.0:
			fallbacks.append(&"undertow_pull")
		if distance_x > 150.0 and _cell_rupture_cooldown <= 0.0:
			fallbacks.append(&"drowned_cell_rupture")
	for fallback: StringName in fallbacks:
		if _can_use_action(fallback, target_near_edge):
			return fallback
	return &""


func _can_use_action(action: StringName, target_near_edge: bool) -> bool:
	if action.is_empty():
		return false
	if not _recent_attack_history.is_empty() and _recent_attack_history.back() == action:
		return false
	if _high_pressure_used_in_combo and _is_high_pressure_action(action):
		return false
	if target_near_edge and action in [&"floodgate_charge", &"prison_hook_drag"]:
		return false
	return true


func _record_action(action: StringName) -> void:
	_recent_attack_history.append(action)
	if _recent_attack_history.size() > 3:
		_recent_attack_history.pop_front()


func _is_high_pressure_action(action: StringName) -> bool:
	return action in [&"chainstorm_cleave", &"drowned_cell_rupture", &"flooded_judgment"]


func _is_target_near_arena_edge() -> bool:
	if not has_valid_target() or not has_movement_bounds():
		return false
	var bounds: Vector2 = get_movement_bounds()
	return (
		target.global_position.x - bounds.x <= _boss_config().wall_pressure_margin
		or bounds.y - target.global_position.x <= _boss_config().wall_pressure_margin
	)


func _process_delayed_turn(direction: float, delta: float) -> bool:
	if direction == facing_direction:
		_pending_facing_direction = 0.0
		_turn_remaining = 0.0
		if current_state == TURN:
			transition_state(COMBAT)
		return true
	if _pending_facing_direction != direction:
		_pending_facing_direction = direction
		_turn_remaining = _boss_config().turn_duration(phase)
		transition_state(TURN)
		velocity.x = 0.0
		play_animation(&"turn_p1" if phase == 1 else &"turn_p2", true)
	_turn_remaining = maxf(0.0, _turn_remaining - delta)
	if _turn_remaining > 0.0:
		return false
	set_facing_direction(_pending_facing_direction)
	_pending_facing_direction = 0.0
	transition_state(COMBAT)
	play_animation(_idle_animation())
	return true


func _process_player_turn(delta: float) -> void:
	player_turn_remaining = maxf(0.0, player_turn_remaining - delta)
	velocity.x = move_toward(velocity.x, 0.0, config.ground_deceleration * delta)
	_process_player_turn_facing(delta)
	if player_turn_remaining > 0.0:
		return
	_reset_combo_sequence()
	transition_state(COMBAT)
	play_animation(_idle_animation())


func _process_player_turn_facing(delta: float) -> void:
	if not has_valid_target():
		_pending_facing_direction = 0.0
		_turn_remaining = 0.0
		return
	var desired_direction: float = signf(target.global_position.x - global_position.x)
	if desired_direction == facing_direction:
		_pending_facing_direction = 0.0
		_turn_remaining = 0.0
		return
	if _pending_facing_direction != desired_direction:
		_pending_facing_direction = desired_direction
		_turn_remaining = _boss_config().turn_duration(phase)
		play_animation(&"turn_p1" if phase == 1 else &"turn_p2", true)
	_turn_remaining = maxf(0.0, _turn_remaining - delta)
	if _turn_remaining > 0.0:
		return
	set_facing_direction(_pending_facing_direction)
	_pending_facing_direction = 0.0
	play_animation(_idle_animation())


func _start_player_turn() -> void:
	direction_locked = false
	attack_phase = &"None"
	active_action = &""
	player_turn_remaining = _boss_config().player_turn_duration(phase)
	_pending_facing_direction = 0.0
	_turn_remaining = 0.0
	transition_state(PLAYER_TURN)
	velocity.x = 0.0
	play_animation(_idle_animation(), true)
	player_turn_started.emit(player_turn_remaining, phase)


func _reset_combo_sequence() -> void:
	combo_count = 0
	_high_pressure_used_in_combo = false
	_combo_sequence_index += 1
	if phase == 1:
		combo_budget = _boss_config().phase_one_combo_budget
	elif _combo_sequence_index % _boss_config().phase_two_extended_combo_period == 0:
		combo_budget = _boss_config().phase_two_extended_combo_budget
	else:
		combo_budget = _boss_config().phase_two_combo_budget


func _start_action(action: StringName) -> void:
	var timing: Vector3 = _action_timing(action)
	direction_locked = true
	_pending_facing_direction = 0.0
	_turn_remaining = 0.0
	active_action = action
	action_damage = _action_damage(action)
	action_active_duration = timing.y
	action_recovery_duration = timing.z
	attack_phase = &"Windup"
	action_timer = timing.x
	velocity.x = 0.0
	transition_state(StringName("%sWindup" % action))
	play_animation(StringName("%s_windup" % action), true)
	_record_action(action)
	if action == &"soul_cage_pulse":
		_soul_cage_pulse_cooldown = _boss_config().soul_cage_pulse_cooldown
	elif action == &"drowned_cell_rupture":
		_cell_rupture_cooldown = _boss_config().cell_rupture_cooldown
	elif action == &"flooded_judgment":
		_judgment_cooldown = _boss_config().judgment_cooldown
	if _is_high_pressure_action(action):
		_high_pressure_used_in_combo = true
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
			direction_locked = false
			combo_count += 1
			if combo_count >= combo_budget:
				_start_player_turn()
			else:
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
		_transition_elapsed = 0.0
		_transition_cue_index = 0
		velocity = Vector2.ZERO
		play_animation(&"phase_transition", true)
		phase_transition_started.emit(state_timer)


func _emit_due_transition_cues() -> void:
	while _transition_cue_index < PHASE_TRANSITION_CUE_TIMES.size():
		var cue_time: float = PHASE_TRANSITION_CUE_TIMES[_transition_cue_index]
		if _transition_elapsed + 0.0001 < cue_time:
			return
		phase_transition_cue.emit(PHASE_TRANSITION_CUES[_transition_cue_index], cue_time)
		_transition_cue_index += 1


func _finish_phase_transition() -> void:
	phase = 2
	damage_policy.damage_multiplier = _boss_config().phase_two_damage_multiplier
	poise_component.configure(_boss_config().phase_two_poise, 1.45)
	_reset_combo_sequence()
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
	return _boss_config().action_timing(action)


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
	direction_locked = false
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
	play_animation(&"death_start",true); enemy_died.emit(); death_sequence_started.emit(); call_deferred("_play_death_sequence")


func _play_death_sequence() -> void:
	await get_tree().create_timer(0.55).timeout
	if not is_inside_tree(): return
	play_animation(&"death_collapse",true)
	await get_tree().create_timer(0.65).timeout
	if not is_inside_tree(): return
	play_animation(&"soul_release",true)
	# The common enemy presenter frees the node when soul_release finishes, so
	# publish the formal defeat once the final presentation has begun.  This is
	# after collapse and before the animation-owned cleanup, exactly once.
	if not _defeat_emitted:
		_defeat_emitted = true
		defeated.emit()


func begin_external_intro() -> void:
	if is_dead():
		return
	_combat_enabled = false
	set_physics_process(false)
	velocity = Vector2.ZERO
	_end_hitboxes()
	hurtbox.set_enabled(false)
	detection_area.set_deferred("monitoring", false)
	transition_state(INTRO)
	play_animation(&"intro", true)
	intro_started.emit()


func begin_combat(player_target: Player) -> void:
	if is_dead():
		return
	target = player_target
	_combat_enabled = true
	set_physics_process(true)
	hurtbox.set_enabled(true)
	detection_area.set_deferred("monitoring", true)
	_reset_combo_sequence()
	transition_state(COMBAT)
	play_animation(_idle_animation(), true)
	combat_started.emit()


func begin_debug_phase_two(player_target: Player) -> void:
	if is_dead():
		return
	_transition_started = true
	phase = 2
	damage_policy.damage_multiplier = _boss_config().phase_two_damage_multiplier
	poise_component.configure(_boss_config().phase_two_poise, 1.45)
	begin_combat(player_target)
	play_animation(&"idle_p2", true)
	phase_changed.emit(phase)


func is_combat_enabled() -> bool:
	return _combat_enabled


func get_attack_phase_name() -> StringName: return attack_phase
func is_attack_window_active() -> bool: return (melee_hitbox != null and melee_hitbox.is_active) or (area_hitbox != null and area_hitbox.is_active)
func get_debug_summary() -> String:
	return "Soul Gaoler Ormund P%d %s HP %d/%d POISE %d/%d %s/%s COMBO %d/%d TURN %.2f LOCK %s" % [
		phase,
		current_state,
		health_component.current_health,
		health_component.max_health,
		poise_component.current_poise,
		poise_component.max_poise,
		active_action,
		attack_phase,
		combo_count,
		combo_budget,
		player_turn_remaining,
		str(direction_locked),
	]
func get_combo_count() -> int: return combo_count
func get_combo_budget() -> int: return combo_budget
func get_player_turn_remaining() -> float: return player_turn_remaining
func is_direction_locked() -> bool: return direction_locked
func get_turn_remaining() -> float: return _turn_remaining
func get_recent_attack_history() -> Array[StringName]: return _recent_attack_history.duplicate()
func _boss_config() -> SoulGaolerOrmundConfig: return config as SoulGaolerOrmundConfig
