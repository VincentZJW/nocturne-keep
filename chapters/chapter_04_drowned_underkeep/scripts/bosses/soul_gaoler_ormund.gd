class_name SoulGaolerOrmund
extends GroundEnemyBase

signal phase_changed(phase: int)
signal phase_transition_started(duration: float)
signal phase_transition_cue(cue_name: StringName, elapsed_seconds: float)
signal boss_action_started(action: StringName, phase: int)
signal boss_action_active(action: StringName, active: bool)
signal boss_attack_cue(action: StringName, cue: StringName)
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
const PHASE_TWO_OPENING: StringName = &"PhaseTwoOpening"
const STAGGER: StringName = &"Stagger"
const PHASE_TRANSITION_CUE_TIMES: PackedFloat32Array = [0.40, 0.80, 1.10, 1.70, 1.90]
const PHASE_TRANSITION_CUES: Array[StringName] = [
	&"first_chain_break",
	&"second_chain_break",
	&"soul_cage_collapse",
	&"flood_surge",
	&"final_iron_impact",
]
const ATTACK_EFFECT_SCRIPT: Script = preload("res://chapters/chapter_04_drowned_underkeep/scripts/bosses/soul_gaoler_attack_effect.gd")
const CATEGORY_CLOSE: StringName = &"Close"
const CATEGORY_MID: StringName = &"Mid"
const CATEGORY_FAR: StringName = &"Far"
const CATEGORY_HIGH_PRESSURE: StringName = &"HighPressure"
const PHASE_TWO_ANIMATION_ROOTS: Dictionary[StringName, StringName] = {
	&"halberd_sweep": &"chainstorm_cleave",
	&"chain_anchor_slam": &"chainstorm_cleave",
	&"prison_hook_drag": &"soul_shackle",
	&"floodgate_charge": &"undertow_pull",
	&"soul_cage_pulse": &"drowned_cell_rupture",
}

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
var _javelin_cooldown: float = 0.0
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
var _recent_category_history: Array[StringName] = []
var phase2_opening_used: bool = false
var _opening_recovery_started: bool = false
var _opening_followup_pending: bool = false
var _phase_visual_violation_count: int = 0
var _phase_visual_redirect_count: int = 0
var _active_effects: Array[SoulGaolerAttackEffect] = []
var _shared_hit_targets: Dictionary[int, bool] = {}
var _locked_aim_position: Vector2 = Vector2.ZERO
var _aim_direction_locked: bool = false
var _iron_second_wave_remaining: float = 0.0
var _iron_second_wave_spawned: bool = false
var _iron_first_wave_targets: Dictionary[int, bool] = {}
var _iron_second_wave_targets: Dictionary[int, bool] = {}
var _normal_action_since_high_pressure: bool = true
var _camera_shake_remaining: float = 0.0
var _camera_shake_duration: float = 0.0
var _camera_shake_strength: float = 0.0
var _camera_base_offset: Vector2 = Vector2.ZERO


func complete_debug_phase_transition() -> void:
	if current_state == PHASE_TRANSITION:
		_finish_phase_transition()


func complete_debug_phase_two_opening() -> void:
	if current_state != PHASE_TWO_OPENING:
		return
	_cancel_active_effects()
	hurtbox.set_enabled(true)
	attack_phase = &"None"
	active_action = &""
	direction_locked = false
	_opening_recovery_started = true
	_reset_opening_cue_meta()
	_reset_combo_sequence()
	transition_state(COMBAT)
	play_animation(&"idle_p2", true)


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
	_javelin_cooldown = maxf(0.0, _javelin_cooldown - delta)
	_stagger_protection = maxf(0.0, _stagger_protection - delta)
	_process_camera_shake(delta)
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
	if current_state == PHASE_TWO_OPENING:
		_process_phase_two_opening(delta)
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
	var target_near_edge: bool = _is_target_near_arena_edge()
	var category: StringName = _preferred_category(distance_x)
	var candidates: Array[StringName] = _actions_for_category(category)
	_rotate_candidates(candidates)
	var selected: StringName = _first_usable_action(candidates, target_near_edge)
	if not selected.is_empty():
		return selected
	# A category guard or cooldown must not create a new idle gap. Move outward
	# through the logical distance neighbours while preserving all history rules.
	for fallback_category: StringName in _fallback_categories(category):
		candidates = _actions_for_category(fallback_category)
		_rotate_candidates(candidates)
		selected = _first_usable_action(candidates, target_near_edge)
		if not selected.is_empty():
			return selected
	return &""


func _preferred_category(distance_x: float) -> StringName:
	if phase == 2 and _can_offer_high_pressure() and _next_attack_id % 4 == 0:
		return CATEGORY_HIGH_PRESSURE
	if distance_x < 105.0:
		return CATEGORY_CLOSE
	if distance_x < 190.0:
		return CATEGORY_MID
	return CATEGORY_FAR


func _actions_for_category(category: StringName) -> Array[StringName]:
	match category:
		CATEGORY_CLOSE:
			var close: Array[StringName] = [&"halberd_sweep", &"gaolers_verdict", &"prison_hook_drag"]
			if phase == 2:
				close.append(&"soul_shackle")
			return close
		CATEGORY_MID:
			var mid: Array[StringName] = [&"chain_anchor_slam", &"soul_cage_pulse", &"iron_grave"]
			if phase == 2:
				mid.append(&"chainstorm_cleave")
			return mid
		CATEGORY_FAR:
			var far: Array[StringName] = [&"drowned_javelin", &"floodgate_charge"]
			if phase == 2:
				far.append(&"undertow_pull")
			return far
		CATEGORY_HIGH_PRESSURE:
			if phase == 2:
				return [&"chainstorm_cleave", &"drowned_cell_rupture", &"flooded_judgment"]
	return []


func _fallback_categories(category: StringName) -> Array[StringName]:
	match category:
		CATEGORY_CLOSE: return [CATEGORY_MID, CATEGORY_FAR, CATEGORY_HIGH_PRESSURE]
		CATEGORY_MID: return [CATEGORY_CLOSE, CATEGORY_FAR, CATEGORY_HIGH_PRESSURE]
		CATEGORY_FAR: return [CATEGORY_MID, CATEGORY_CLOSE, CATEGORY_HIGH_PRESSURE]
		CATEGORY_HIGH_PRESSURE: return [CATEGORY_MID, CATEGORY_CLOSE, CATEGORY_FAR]
	return [CATEGORY_CLOSE, CATEGORY_MID, CATEGORY_FAR]


func _rotate_candidates(candidates: Array[StringName]) -> void:
	if candidates.size() < 2:
		return
	var rotations: int = _next_attack_id % candidates.size()
	for _rotation: int in rotations:
		candidates.append(candidates.pop_front())


func _first_usable_action(candidates: Array[StringName], target_near_edge: bool) -> StringName:
	for candidate: StringName in candidates:
		if _can_use_action(candidate, target_near_edge):
			return candidate
	return &""


func _can_offer_high_pressure() -> bool:
	return phase == 2 and _normal_action_since_high_pressure and not _high_pressure_used_in_combo


func _can_use_action(action: StringName, target_near_edge: bool) -> bool:
	if action.is_empty():
		return false
	if not _recent_attack_history.is_empty() and _recent_attack_history.back() == action:
		return false
	if _high_pressure_used_in_combo and _is_high_pressure_action(action):
		return false
	if _is_high_pressure_action(action) and not _normal_action_since_high_pressure:
		return false
	var category: StringName = _action_category(action)
	if (
		_recent_category_history.size() >= 2
		and _recent_category_history[-1] == category
		and _recent_category_history[-2] == category
	):
		return false
	if target_near_edge and action in [&"floodgate_charge", &"prison_hook_drag"]:
		return false
	if action == &"drowned_javelin":
		if _javelin_cooldown > 0.0 or not has_valid_target():
			return false
		if absf(target.global_position.x - global_position.x) < _boss_config().javelin_minimum_distance:
			return false
		if not _recent_attack_history.is_empty() and _recent_attack_history.back() == &"iron_grave" and not target.is_on_floor():
			return false
	if action == &"soul_cage_pulse" and _soul_cage_pulse_cooldown > 0.0:
		return false
	if action == &"drowned_cell_rupture" and _cell_rupture_cooldown > 0.0:
		return false
	if action == &"flooded_judgment" and _judgment_cooldown > 0.0:
		return false
	if _opening_followup_pending and action == &"floodgate_charge":
		return false
	return true


func _record_action(action: StringName) -> void:
	_recent_attack_history.append(action)
	if _recent_attack_history.size() > 3:
		_recent_attack_history.pop_front()
	var category: StringName = _action_category(action)
	_recent_category_history.append(category)
	if _recent_category_history.size() > 3:
		_recent_category_history.pop_front()
	if _is_high_pressure_action(action):
		_normal_action_since_high_pressure = false
	else:
		_normal_action_since_high_pressure = true
	_opening_followup_pending = false


func _is_high_pressure_action(action: StringName) -> bool:
	return action in [&"chainstorm_cleave", &"drowned_cell_rupture", &"flooded_judgment"]


func _action_category(action: StringName) -> StringName:
	if _is_high_pressure_action(action):
		return CATEGORY_HIGH_PRESSURE
	if action in [&"halberd_sweep", &"gaolers_verdict", &"prison_hook_drag", &"soul_shackle"]:
		return CATEGORY_CLOSE
	if action in [&"chain_anchor_slam", &"soul_cage_pulse", &"iron_grave"]:
		return CATEGORY_MID
	if action in [&"drowned_javelin", &"floodgate_charge", &"undertow_pull"]:
		return CATEGORY_FAR
	return &"Neutral"


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
	direction_locked = action not in [&"drowned_javelin", &"gaolers_verdict"]
	_pending_facing_direction = 0.0
	_turn_remaining = 0.0
	_aim_direction_locked = direction_locked
	_locked_aim_position = target.global_position if has_valid_target() else global_position + Vector2(facing_direction * 100.0, 0.0)
	_iron_second_wave_remaining = 0.0
	_iron_second_wave_spawned = false
	active_action = action
	action_damage = _action_damage(action)
	action_active_duration = timing.y
	action_recovery_duration = timing.z
	attack_phase = &"Windup"
	action_timer = timing.x
	velocity.x = 0.0
	transition_state(StringName("%sWindup" % action))
	play_animation(_action_animation(action, &"windup"), true)
	_record_action(action)
	if action == &"soul_cage_pulse":
		_soul_cage_pulse_cooldown = _boss_config().soul_cage_pulse_cooldown
	elif action == &"drowned_cell_rupture":
		_cell_rupture_cooldown = _boss_config().cell_rupture_cooldown
	elif action == &"flooded_judgment":
		_judgment_cooldown = _boss_config().judgment_cooldown
	elif action == &"drowned_javelin":
		_javelin_cooldown = (
			_boss_config().javelin_phase_one_cooldown
			if phase == 1
			else _boss_config().javelin_phase_two_cooldown
		)
	elif action == &"iron_grave":
		_prepare_iron_grave_wave(false)
	if _is_high_pressure_action(action):
		_high_pressure_used_in_combo = true
	boss_action_started.emit(action, phase)


func _process_action(delta: float) -> void:
	_process_direction_lock(delta)
	if active_action == &"iron_grave" and attack_phase == &"Active" and phase == 2 and not _iron_second_wave_spawned:
		_iron_second_wave_remaining = maxf(0.0, _iron_second_wave_remaining - delta)
		if _iron_second_wave_remaining <= 0.0:
			_iron_second_wave_spawned = true
			_prepare_iron_grave_wave(true)
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
	play_animation(_action_animation(active_action, &"active"), true)
	_shared_hit_targets.clear()
	melee_hitbox.set_shared_target_ledger(_shared_hit_targets)
	area_hitbox.set_shared_target_ledger(_shared_hit_targets)
	if active_action == &"drowned_javelin":
		_spawn_drowned_javelin()
	elif active_action == &"gaolers_verdict":
		_begin_verdict_impact()
	elif active_action != &"iron_grave":
		var hitbox: HitboxComponent = area_hitbox if active_action in [&"soul_cage_pulse", &"drowned_cell_rupture", &"flooded_judgment"] else melee_hitbox
		hitbox.attack_kind = StringName("enemy_%s" % active_action)
		hitbox.begin_attack(current_attack_id, action_damage, facing_direction, self)
	if active_action == &"iron_grave" and phase == 2:
		_iron_second_wave_remaining = _boss_config().iron_grave_second_wave_delay
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
	play_animation(_action_animation(active_action, &"recovery"), true)


func _process_direction_lock(_delta: float) -> void:
	if attack_phase != &"Windup" or active_action not in [&"drowned_javelin", &"gaolers_verdict"]:
		return
	var lock_window: float = (
		_boss_config().javelin_direction_lock
		if active_action == &"drowned_javelin"
		else _boss_config().verdict_direction_lock
	)
	if not _aim_direction_locked and action_timer <= lock_window:
		_aim_direction_locked = true
		direction_locked = true
		_locked_aim_position = target.global_position if has_valid_target() else global_position + Vector2(facing_direction * 120.0, 0.0)
		boss_attack_cue.emit(active_action, &"direction_locked")
		return
	if _aim_direction_locked or not has_valid_target():
		return
	var desired: float = signf(target.global_position.x - global_position.x)
	if not is_zero_approx(desired):
		set_facing_direction(desired)


func _spawn_drowned_javelin() -> void:
	var projectile := ATTACK_EFFECT_SCRIPT.new() as SoulGaolerAttackEffect
	get_parent().add_child(projectile)
	projectile.global_position = global_position + Vector2(facing_direction * 42.0, -76.0)
	var aim_vector: Vector2 = _locked_aim_position - projectile.global_position
	if aim_vector.length_squared() < 1.0:
		aim_vector = Vector2(facing_direction, 0.0)
	projectile.configure_javelin(
		aim_vector,
		_boss_config().javelin_speed,
		_boss_config().drowned_javelin_damage,
		current_attack_id,
		self,
		_shared_hit_targets
	)
	_track_effect(projectile)
	boss_attack_cue.emit(&"drowned_javelin", &"release")


func _begin_verdict_impact() -> void:
	melee_hitbox.attack_kind = &"enemy_gaolers_verdict"
	melee_hitbox.begin_attack(
		current_attack_id,
		_boss_config().gaolers_verdict_direct_damage,
		facing_direction,
		self
	)
	var shockwave := ATTACK_EFFECT_SCRIPT.new() as SoulGaolerAttackEffect
	get_parent().add_child(shockwave)
	shockwave.global_position = global_position + Vector2(facing_direction * 88.0, -9.0)
	shockwave.configure_zone(
		SoulGaolerAttackEffect.EffectKind.GROUND_RIFT,
		Vector2(156.0, 16.0),
		0.0,
		action_active_duration,
		0.12,
		_boss_config().gaolers_verdict_shockwave_damage,
		current_attack_id,
		self,
		_shared_hit_targets,
		&"gaolers_verdict_shockwave"
	)
	_track_effect(shockwave)
	_start_camera_shake(0.12, 3.0)
	boss_attack_cue.emit(&"gaolers_verdict", &"impact")


func _prepare_iron_grave_wave(second_wave: bool) -> void:
	var pike_count: int = 4 if phase == 1 else (3 if not second_wave else 4)
	var telegraph: float = (
		_boss_config().iron_grave_second_wave_telegraph
		if second_wave
		else _boss_config().iron_grave_telegraph
	)
	var shared_targets: Dictionary[int, bool] = _iron_second_wave_targets if second_wave else _iron_first_wave_targets
	shared_targets.clear()
	var wave_attack_id: int = _next_attack_id
	_next_attack_id += 1
	var center_x: float = target.global_position.x if has_valid_target() else global_position.x
	var bounds: Vector2 = get_movement_bounds() if has_movement_bounds() else Vector2(global_position.x - 520.0, global_position.x + 520.0)
	var spacing: float = 52.0
	var start_x: float = center_x - spacing * float(pike_count - 1) * 0.5
	if second_wave and has_valid_target():
		start_x = target.global_position.x - spacing * float(pike_count - 1) * 0.5
	for index: int in pike_count:
		var x: float = clampf(start_x + float(index) * spacing, bounds.x + 32.0, bounds.y - 32.0)
		# Alternating offsets leave a readable 96+ px escape gap rather than
		# blanketing the whole arena.
		if not second_wave and _next_attack_id % 2 == 0 and index >= 2:
			x += 78.0
		var pike := ATTACK_EFFECT_SCRIPT.new() as SoulGaolerAttackEffect
		get_parent().add_child(pike)
		pike.global_position = Vector2(x, global_position.y - 9.0)
		pike.configure_zone(
			SoulGaolerAttackEffect.EffectKind.PRISON_PIKE,
			Vector2(32.0, 82.0),
			telegraph,
			0.22,
			0.20,
			_boss_config().iron_grave_damage,
			wave_attack_id,
			self,
			shared_targets,
			&"iron_grave_wave_2" if second_wave else &"iron_grave_wave_1",
			true
		)
		_track_effect(pike)
	boss_attack_cue.emit(&"iron_grave", &"wave_2_telegraph" if second_wave else &"wave_1_telegraph")


func _action_animation(action: StringName, phase_name: StringName) -> StringName:
	var animation_root: StringName = action
	match action:
		&"drowned_javelin": animation_root = &"soul_shackle" if phase == 2 else &"prison_hook_drag"
		&"gaolers_verdict": animation_root = &"chainstorm_cleave" if phase == 2 else &"chain_anchor_slam"
		&"iron_grave": animation_root = &"drowned_cell_rupture" if phase == 2 else &"soul_cage_pulse"
	return StringName("%s_%s" % [animation_root, phase_name])


func play_animation(animation_name: StringName, restart: bool = false) -> void:
	var resolved_animation: StringName = _resolve_phase_visual_animation(animation_name)
	if resolved_animation != animation_name:
		_phase_visual_redirect_count += 1
	super.play_animation(resolved_animation, restart)
	if phase == 2 and _is_phase_one_visual_animation(animated_sprite.animation):
		_phase_visual_violation_count += 1
		push_error(
			"ORMUND_PHASE_VISUAL_VIOLATION requested=%s resolved=%s active=%s"
			% [animation_name, resolved_animation, animated_sprite.animation]
		)


func _resolve_phase_visual_animation(animation_name: StringName) -> StringName:
	if phase != 2:
		return animation_name
	match animation_name:
		&"idle_p1": return &"idle_p2"
		&"walk_p1": return &"move_p2"
		&"turn_p1": return &"turn_p2"
		&"light_hit_p1": return &"light_hit_p2"
		&"stagger_p1": return &"stagger_p2"
	var animation_text: String = String(animation_name)
	for phase_one_root: StringName in PHASE_TWO_ANIMATION_ROOTS:
		var prefix: String = "%s_" % phase_one_root
		if animation_text.begins_with(prefix):
			return StringName(
				"%s_%s" % [
					PHASE_TWO_ANIMATION_ROOTS[phase_one_root],
					animation_text.trim_prefix(prefix),
				]
			)
	return animation_name


func _is_phase_one_visual_animation(animation_name: StringName) -> bool:
	if animation_name in [&"idle_p1", &"walk_p1", &"turn_p1", &"light_hit_p1", &"stagger_p1"]:
		return true
	var animation_text: String = String(animation_name)
	for phase_one_root: StringName in PHASE_TWO_ANIMATION_ROOTS:
		if animation_text.begins_with("%s_" % phase_one_root):
			return true
	return false


func _track_effect(effect: SoulGaolerAttackEffect) -> void:
	_active_effects.append(effect)
	effect.finished.connect(_on_effect_finished)


func _on_effect_finished(effect: SoulGaolerAttackEffect) -> void:
	_active_effects.erase(effect)


func _cancel_active_effects() -> void:
	for effect: SoulGaolerAttackEffect in _active_effects.duplicate():
		if effect != null and is_instance_valid(effect):
			effect.cancel()
	_active_effects.clear()


func _start_camera_shake(duration: float, strength: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return
	_camera_base_offset = camera.offset
	_camera_shake_duration = duration
	_camera_shake_remaining = duration
	_camera_shake_strength = strength


func _process_camera_shake(delta: float) -> void:
	if _camera_shake_remaining <= 0.0:
		return
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		_camera_shake_remaining = 0.0
		return
	_camera_shake_remaining = maxf(0.0, _camera_shake_remaining - delta)
	if _camera_shake_remaining <= 0.0:
		camera.offset = _camera_base_offset
		return
	var ratio: float = _camera_shake_remaining / maxf(_camera_shake_duration, 0.01)
	var phase_value: float = _camera_shake_remaining * 210.0
	camera.offset = _camera_base_offset + Vector2(roundf(sin(phase_value) * _camera_shake_strength * ratio), roundf(cos(phase_value * 1.3) * _camera_shake_strength * ratio * 0.55))


func _on_health_changed(current: int, _maximum: int) -> void:
	if phase == 1 and not _transition_started and current <= roundi(_boss_config().total_health * _boss_config().phase_two_threshold_ratio):
		_transition_started = true
		_on_attack_cancelled()
		transition_state(PHASE_TRANSITION)
		state_timer = _boss_config().phase_transition_duration
		_transition_elapsed = 0.0
		_transition_cue_index = 0
		velocity = Vector2.ZERO
		hurtbox.set_enabled(false)
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
	phase_changed.emit(phase)
	_start_phase_two_opening()


func _start_phase_two_opening() -> void:
	if phase2_opening_used:
		transition_state(COMBAT)
		play_animation(&"idle_p2", true)
		return
	phase2_opening_used = true
	_opening_recovery_started = false
	_opening_followup_pending = true
	_on_attack_cancelled()
	hurtbox.set_enabled(false)
	active_action = &"judgment_of_the_broken_gaol"
	attack_phase = &"Telegraph"
	action_timer = _boss_config().phase_two_opening_telegraph
	direction_locked = true
	transition_state(PHASE_TWO_OPENING)
	velocity = Vector2.ZERO
	play_animation(&"flooded_judgment_windup", true)
	current_attack_id = _next_attack_id
	_next_attack_id += 1
	_shared_hit_targets.clear()
	_spawn_opening_ground_rifts()
	boss_action_started.emit(active_action, phase)
	boss_attack_cue.emit(active_action, &"weapon_planted")


func _spawn_opening_ground_rifts() -> void:
	var bounds: Vector2 = get_movement_bounds() if has_movement_bounds() else Vector2(global_position.x - 640.0, global_position.x + 640.0)
	var total_width: float = bounds.y - bounds.x
	var safe_half_width: float = 54.0
	var safe_a: float = lerpf(bounds.x, bounds.y, 0.27)
	var safe_b: float = lerpf(bounds.x, bounds.y, 0.73)
	var ranges: Array[Vector2] = [
		Vector2(bounds.x, safe_a - safe_half_width),
		Vector2(safe_a + safe_half_width, safe_b - safe_half_width),
		Vector2(safe_b + safe_half_width, bounds.y),
	]
	for range_x: Vector2 in ranges:
		var width: float = range_x.y - range_x.x
		if width <= 8.0:
			continue
		var rift := ATTACK_EFFECT_SCRIPT.new() as SoulGaolerAttackEffect
		get_parent().add_child(rift)
		rift.global_position = Vector2((range_x.x + range_x.y) * 0.5, global_position.y - 8.0)
		rift.configure_zone(
			SoulGaolerAttackEffect.EffectKind.GROUND_RIFT,
			Vector2(width, 16.0),
			_boss_config().phase_two_opening_telegraph,
			_boss_config().phase_two_opening_active,
			0.16,
			_boss_config().phase_two_opening_damage,
			current_attack_id,
			self,
			_shared_hit_targets,
			&"judgment_of_the_broken_gaol"
		)
		_track_effect(rift)
	# Two cyan circles mark the safe ground gaps; jumping over the low 16 px
	# shockwave remains the universal second solution.
	set_meta(&"phase_two_opening_safe_gaps", PackedFloat32Array([safe_a, safe_b]))
	set_meta(&"phase_two_opening_arena_width", total_width)


func _process_phase_two_opening(delta: float) -> void:
	velocity = Vector2.ZERO
	action_timer = maxf(0.0, action_timer - delta)
	if attack_phase == &"Telegraph":
		var remaining: float = action_timer
		if remaining <= 1.10 and not has_meta(&"opening_cue_ring"):
			set_meta(&"opening_cue_ring", true)
			boss_attack_cue.emit(active_action, &"ring_cracks")
		if remaining <= 0.80 and not has_meta(&"opening_cue_spread"):
			set_meta(&"opening_cue_spread", true)
			boss_attack_cue.emit(active_action, &"arena_spread")
		if remaining <= 0.45 and not has_meta(&"opening_cue_water"):
			set_meta(&"opening_cue_water", true)
			boss_attack_cue.emit(active_action, &"water_rise")
		if remaining <= 0.20 and not has_meta(&"opening_cue_peak"):
			set_meta(&"opening_cue_peak", true)
			boss_attack_cue.emit(active_action, &"soul_peak")
		if action_timer > 0.0:
			return
		attack_phase = &"Active"
		action_timer = _boss_config().phase_two_opening_active
		play_animation(&"flooded_judgment_active", true)
		boss_action_active.emit(active_action, true)
		_start_camera_shake(0.16, 3.5)
		return
	if attack_phase == &"Active":
		if action_timer > 0.0:
			return
		attack_phase = &"Recovery"
		action_timer = _boss_config().phase_two_opening_recovery
		_opening_recovery_started = true
		hurtbox.set_enabled(true)
		play_animation(&"flooded_judgment_recovery", true)
		boss_action_active.emit(active_action, false)
		return
	if attack_phase == &"Recovery" and action_timer <= 0.0:
		attack_phase = &"None"
		active_action = &""
		direction_locked = false
		_reset_opening_cue_meta()
		_reset_combo_sequence()
		transition_state(COMBAT)
		play_animation(&"idle_p2", true)


func _reset_opening_cue_meta() -> void:
	for key: StringName in [&"opening_cue_ring", &"opening_cue_spread", &"opening_cue_water", &"opening_cue_peak"]:
		remove_meta(key)


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
	return _boss_config().action_timing_for_phase(action, phase)


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
		&"drowned_javelin": return _boss_config().drowned_javelin_damage
		&"gaolers_verdict": return _boss_config().gaolers_verdict_direct_damage
		&"iron_grave": return _boss_config().iron_grave_damage
	return 1


func _end_hitboxes() -> void:
	if melee_hitbox != null: melee_hitbox.end_attack()
	if area_hitbox != null: area_hitbox.end_attack()
	attack_window_changed.emit(false)


func _on_attack_cancelled() -> void:
	_end_hitboxes()
	_cancel_active_effects()
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
	if phase == 1:
		phase2_opening_used = false
		_transition_started = false
		_opening_followup_pending = false
		_recent_attack_history.clear()
		_recent_category_history.clear()
		_normal_action_since_high_pressure = true
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
	phase2_opening_used = false
	damage_policy.damage_multiplier = _boss_config().phase_two_damage_multiplier
	poise_component.configure(_boss_config().phase_two_poise, 1.45)
	target = player_target
	_combat_enabled = true
	set_physics_process(true)
	detection_area.set_deferred("monitoring", true)
	_reset_combo_sequence()
	phase_changed.emit(phase)
	_start_phase_two_opening()


func is_combat_enabled() -> bool:
	return _combat_enabled


func get_attack_phase_name() -> StringName: return attack_phase
func is_attack_window_active() -> bool: return (melee_hitbox != null and melee_hitbox.is_active) or (area_hitbox != null and area_hitbox.is_active)
func get_debug_summary() -> String:
	return "Soul Gaoler Ormund P%d %s HP %d/%d POISE %d/%d %s/%s COMBO %d/%d TURN %.2f LOCK %s OPEN %s FX %d" % [
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
		str(phase2_opening_used),
		_active_effects.size(),
	]
func get_combo_count() -> int: return combo_count
func get_combo_budget() -> int: return combo_budget
func get_player_turn_remaining() -> float: return player_turn_remaining
func is_direction_locked() -> bool: return direction_locked
func get_turn_remaining() -> float: return _turn_remaining
func get_recent_attack_history() -> Array[StringName]: return _recent_attack_history.duplicate()
func get_recent_category_history() -> Array[StringName]: return _recent_category_history.duplicate()
func get_active_effect_count() -> int: return _active_effects.size()
func get_javelin_cooldown() -> float: return _javelin_cooldown
func get_phase_visual_violation_count() -> int: return _phase_visual_violation_count
func get_phase_visual_redirect_count() -> int: return _phase_visual_redirect_count
func is_phase_one_visual_active() -> bool:
	return animated_sprite != null and _is_phase_one_visual_animation(animated_sprite.animation)
func is_phase_two_opening_active() -> bool: return current_state == PHASE_TWO_OPENING
func get_phase_two_opening_safe_gaps() -> PackedFloat32Array:
	return get_meta(&"phase_two_opening_safe_gaps", PackedFloat32Array()) as PackedFloat32Array
func _boss_config() -> SoulGaolerOrmundConfig: return config as SoulGaolerOrmundConfig
