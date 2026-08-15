class_name PlayerStatusEffectController
extends Node

## Single owner for temporary Player status effects. Gameplay systems apply a
## typed status here; presentation observes signals and never owns timers.

signal status_applied(effect_id: StringName, duration: float)
signal status_refreshed(effect_id: StringName, duration: float)
signal status_expired(effect_id: StringName)
signal status_changed(effect_id: StringName, remaining: float, duration: float)
signal all_statuses_cleared

const BURN: StringName = &"burn"
const BLEED: StringName = &"bleed"
const FREEZE: StringName = &"freeze"
const FREEZE_IMMUNITY: StringName = &"freeze_immunity"
const MIRE_SLOW: StringName = &"mire_slow"
const MIRE_MOVEMENT_SOURCE: StringName = &"edran_mire"

@export_node_path("Player") var player_path: NodePath = NodePath("..")
@export_node_path("HealthComponent") var health_component_path: NodePath = NodePath("../HealthComponent")
@export_node_path("AnimatedSprite2D") var burn_fx_path: NodePath = NodePath("../VisualRoot/StatusEffects/BurnFX")
@export_node_path("AnimatedSprite2D") var bleed_fx_path: NodePath = NodePath("../VisualRoot/StatusEffects/BleedFX")
@export_node_path("AnimatedSprite2D") var freeze_fx_path: NodePath = NodePath("../VisualRoot/StatusEffects/FreezeFX")
@export_node_path("AnimatedSprite2D") var mire_fx_path: NodePath = NodePath("../VisualRoot/StatusEffects/MireFX")

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var health_component: HealthComponent = get_node_or_null(health_component_path) as HealthComponent
@onready var burn_fx: AnimatedSprite2D = get_node_or_null(burn_fx_path) as AnimatedSprite2D
@onready var bleed_fx: AnimatedSprite2D = get_node_or_null(bleed_fx_path) as AnimatedSprite2D
@onready var freeze_fx: AnimatedSprite2D = get_node_or_null(freeze_fx_path) as AnimatedSprite2D
@onready var mire_fx: AnimatedSprite2D = get_node_or_null(mire_fx_path) as AnimatedSprite2D

var _burn_source_id: StringName = &""
var _burn_duration: float = 0.0
var _burn_remaining: float = 0.0
var _burn_tick_interval: float = 1.0
var _burn_tick_remaining: float = 0.0
var _burn_tick_damage: int = 0

var _bleed_source_id: StringName = &""
var _bleed_duration: float = 0.0
var _bleed_remaining: float = 0.0
var _bleed_tick_interval: float = 1.0
var _bleed_tick_remaining: float = 0.0
var _bleed_tick_damage: int = 0

var _freeze_source_id: StringName = &""
var _freeze_duration: float = 0.0
var _freeze_remaining: float = 0.0
var _freeze_immunity_remaining: float = 0.0
var _freeze_immunity_duration: float = 5.0

var _mire_source_id: StringName = &""
var _mire_duration: float = 0.0
var _mire_remaining: float = 0.0
var _mire_move_multiplier: float = 1.0
var _mire_dash_multiplier: float = 1.0
var _burn_visual_generation: int = 0
var _bleed_visual_generation: int = 0
var _freeze_visual_generation: int = 0
var _mire_visual_generation: int = 0


func _ready() -> void:
	if player == null or health_component == null:
		push_error("PlayerStatusEffectController requires Player and HealthComponent")
		set_physics_process(false)
		return
	_set_fx_active(burn_fx, false)
	_set_fx_active(bleed_fx, false)
	_set_fx_active(freeze_fx, false)
	_set_fx_active(mire_fx, false)


func _physics_process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	var safe_delta: float = maxf(0.0, delta)
	_tick_burn(safe_delta)
	_tick_bleed(safe_delta)
	_tick_freeze(safe_delta)
	_tick_mire(safe_delta)
	if _freeze_immunity_remaining > 0.0:
		_freeze_immunity_remaining = maxf(0.0, _freeze_immunity_remaining - safe_delta)
		status_changed.emit(FREEZE_IMMUNITY, _freeze_immunity_remaining, _freeze_immunity_duration)
		if is_zero_approx(_freeze_immunity_remaining):
			status_expired.emit(FREEZE_IMMUNITY)


func apply_burn(
	source_id: StringName,
	duration: float = 3.0,
	tick_damage: int = 5,
	tick_interval: float = 1.0
) -> bool:
	if player == null or player.is_dead() or duration <= 0.0 or tick_damage <= 0:
		return false
	var was_active: bool = is_burning()
	_burn_source_id = source_id
	_burn_duration = duration
	_burn_remaining = duration
	_burn_tick_interval = maxf(0.01, tick_interval)
	_burn_tick_remaining = _burn_tick_interval
	_burn_tick_damage = tick_damage
	_burn_visual_generation += 1
	_set_fx_active(burn_fx, true)
	if was_active:
		status_refreshed.emit(BURN, duration)
	else:
		status_applied.emit(BURN, duration)
	status_changed.emit(BURN, _burn_remaining, _burn_duration)
	return true


func apply_bleed(
	source_id: StringName,
	duration: float = 5.0,
	tick_damage: int = 1,
	tick_interval: float = 1.0
) -> bool:
	if player == null or player.is_dead() or duration <= 0.0 or tick_damage <= 0:
		return false
	var was_active: bool = is_bleeding()
	_bleed_source_id = source_id
	_bleed_duration = duration
	_bleed_remaining = duration
	_bleed_tick_interval = maxf(0.01, tick_interval)
	_bleed_tick_remaining = _bleed_tick_interval
	_bleed_tick_damage = tick_damage
	_bleed_visual_generation += 1
	_set_fx_active(bleed_fx, true)
	if was_active:
		status_refreshed.emit(BLEED, duration)
	else:
		status_applied.emit(BLEED, duration)
	status_changed.emit(BLEED, _bleed_remaining, _bleed_duration)
	return true


func apply_freeze(
	source_id: StringName,
	duration: float = 3.0,
	immunity_duration: float = 5.0
) -> bool:
	if player == null or player.is_dead() or duration <= 0.0 or is_freeze_immune():
		return false
	var was_active: bool = is_frozen()
	_freeze_source_id = source_id
	_freeze_duration = duration
	_freeze_remaining = duration
	_freeze_immunity_duration = maxf(0.0, immunity_duration)
	_freeze_visual_generation += 1
	player.cancel_actions_for_status_lock()
	_set_fx_active(freeze_fx, true)
	if was_active:
		status_refreshed.emit(FREEZE, duration)
	else:
		status_applied.emit(FREEZE, duration)
	status_changed.emit(FREEZE, _freeze_remaining, _freeze_duration)
	return true


func apply_mire(
	source_id: StringName,
	duration: float = 0.20,
	movement_multiplier: float = 0.35,
	dash_multiplier: float = 0.70
) -> bool:
	if player == null or player.is_dead():
		return false
	var was_active: bool = is_mired()
	_mire_source_id = source_id
	_mire_duration = maxf(0.05, duration)
	_mire_remaining = _mire_duration
	_mire_move_multiplier = clampf(movement_multiplier, 0.1, 1.0)
	_mire_dash_multiplier = clampf(dash_multiplier, 0.1, 1.0)
	_mire_visual_generation += 1
	player.set_movement_speed_modifier(MIRE_MOVEMENT_SOURCE, _mire_move_multiplier)
	_set_fx_active(mire_fx, true)
	if was_active:
		status_refreshed.emit(MIRE_SLOW, _mire_duration)
	else:
		status_applied.emit(MIRE_SLOW, _mire_duration)
	status_changed.emit(MIRE_SLOW, _mire_remaining, _mire_duration)
	return true


func clear_effect(effect_id: StringName, source_id: StringName = &"") -> void:
	match effect_id:
		BURN:
			if source_id.is_empty() or source_id == _burn_source_id:
				_expire_burn(true)
		BLEED:
			if source_id.is_empty() or source_id == _bleed_source_id:
				_expire_bleed(true)
		FREEZE:
			if source_id.is_empty() or source_id == _freeze_source_id:
				_expire_freeze(false, true)
		MIRE_SLOW:
			if source_id.is_empty() or source_id == _mire_source_id:
				_expire_mire(true)


func clear_all() -> void:
	_expire_burn(false)
	_expire_bleed(false)
	_expire_freeze(false, false)
	_expire_mire(false)
	_freeze_immunity_remaining = 0.0
	all_statuses_cleared.emit()


func is_burning() -> bool:
	return _burn_remaining > 0.0


func is_bleeding() -> bool:
	return _bleed_remaining > 0.0


func is_frozen() -> bool:
	return _freeze_remaining > 0.0


func is_freeze_immune() -> bool:
	return _freeze_immunity_remaining > 0.0


func is_mired() -> bool:
	return _mire_remaining > 0.0


func is_input_locked() -> bool:
	return is_frozen()


func get_dash_multiplier() -> float:
	return _mire_dash_multiplier if is_mired() else 1.0


func get_remaining(effect_id: StringName) -> float:
	match effect_id:
		BURN: return _burn_remaining
		BLEED: return _bleed_remaining
		FREEZE: return _freeze_remaining
		FREEZE_IMMUNITY: return _freeze_immunity_remaining
		MIRE_SLOW: return _mire_remaining
	return 0.0


func get_active_effect_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	if is_burning(): result.append(BURN)
	if is_bleeding(): result.append(BLEED)
	if is_frozen(): result.append(FREEZE)
	if is_mired(): result.append(MIRE_SLOW)
	return result


func _tick_burn(delta: float) -> void:
	if not is_burning():
		return
	_burn_remaining = maxf(0.0, _burn_remaining - delta)
	_burn_tick_remaining -= delta
	while _burn_tick_remaining <= 0.0001 and (is_burning() or is_zero_approx(_burn_remaining)):
		if health_component == null or health_component.is_dead():
			_expire_burn(true)
			return
		health_component.take_damage(_burn_tick_damage)
		_burn_tick_remaining += _burn_tick_interval
		if health_component.is_dead():
			_expire_burn(true)
			return
	status_changed.emit(BURN, _burn_remaining, _burn_duration)
	if is_zero_approx(_burn_remaining):
		_expire_burn(true)


func _tick_bleed(delta: float) -> void:
	if not is_bleeding():
		return
	var active_delta: float = minf(delta, _bleed_remaining)
	_bleed_remaining = maxf(0.0, _bleed_remaining - active_delta)
	_bleed_tick_remaining -= active_delta
	while _bleed_tick_remaining <= 0.0001 and (is_bleeding() or is_zero_approx(_bleed_remaining)):
		if health_component == null or health_component.is_dead():
			_expire_bleed(true)
			return
		health_component.take_damage(_bleed_tick_damage)
		_bleed_tick_remaining += _bleed_tick_interval
		if health_component.is_dead():
			_expire_bleed(true)
			return
	status_changed.emit(BLEED, _bleed_remaining, _bleed_duration)
	if is_zero_approx(_bleed_remaining):
		_expire_bleed(true)


func _tick_freeze(delta: float) -> void:
	if not is_frozen():
		return
	_freeze_remaining = maxf(0.0, _freeze_remaining - delta)
	status_changed.emit(FREEZE, _freeze_remaining, _freeze_duration)
	if is_zero_approx(_freeze_remaining):
		_expire_freeze(true, true)


func _tick_mire(delta: float) -> void:
	if not is_mired():
		return
	_mire_remaining = maxf(0.0, _mire_remaining - delta)
	status_changed.emit(MIRE_SLOW, _mire_remaining, _mire_duration)
	if is_zero_approx(_mire_remaining):
		_expire_mire(true)


func _expire_burn(animate_exit: bool) -> void:
	if _burn_remaining <= 0.0 and _burn_source_id.is_empty():
		return
	_burn_remaining = 0.0
	_burn_source_id = &""
	_burn_visual_generation += 1
	_finish_or_hide_fx(burn_fx, &"extinguish", 0.32, BURN, _burn_visual_generation, animate_exit)
	status_expired.emit(BURN)


func _expire_bleed(animate_exit: bool) -> void:
	if _bleed_remaining <= 0.0 and _bleed_source_id.is_empty():
		return
	_bleed_remaining = 0.0
	_bleed_source_id = &""
	_bleed_visual_generation += 1
	_finish_or_hide_fx(bleed_fx, &"extinguish", 0.24, BLEED, _bleed_visual_generation, animate_exit)
	status_expired.emit(BLEED)


func _expire_freeze(grant_immunity: bool, animate_exit: bool) -> void:
	if _freeze_remaining <= 0.0 and _freeze_source_id.is_empty():
		return
	_freeze_remaining = 0.0
	_freeze_source_id = &""
	_freeze_visual_generation += 1
	_finish_or_hide_fx(freeze_fx, &"shatter", 0.34, FREEZE, _freeze_visual_generation, animate_exit)
	status_expired.emit(FREEZE)
	if grant_immunity and _freeze_immunity_duration > 0.0:
		_freeze_immunity_remaining = _freeze_immunity_duration
		status_applied.emit(FREEZE_IMMUNITY, _freeze_immunity_duration)


func _expire_mire(animate_exit: bool) -> void:
	if player != null:
		player.clear_movement_speed_modifier(MIRE_MOVEMENT_SOURCE)
	if _mire_remaining <= 0.0 and _mire_source_id.is_empty():
		return
	_mire_remaining = 0.0
	_mire_source_id = &""
	_mire_dash_multiplier = 1.0
	_mire_visual_generation += 1
	_finish_or_hide_fx(mire_fx, &"fade", 0.58, MIRE_SLOW, _mire_visual_generation, animate_exit)
	status_expired.emit(MIRE_SLOW)


func _set_fx_active(effect: AnimatedSprite2D, active: bool) -> void:
	if effect == null:
		return
	effect.visible = active
	if active:
		effect.play(&"active")
	else:
		effect.stop()


func _finish_or_hide_fx(
	effect: AnimatedSprite2D,
	exit_animation: StringName,
	duration: float,
	effect_id: StringName,
	generation: int,
	animate_exit: bool
) -> void:
	if effect == null:
		return
	if not animate_exit or effect.sprite_frames == null or not effect.sprite_frames.has_animation(exit_animation):
		_set_fx_active(effect, false)
		return
	if not is_inside_tree() or get_tree() == null:
		_set_fx_active(effect, false)
		return
	effect.visible = true
	effect.play(exit_animation)
	get_tree().create_timer(duration).timeout.connect(
		_hide_fx_if_current.bind(effect, effect_id, generation), CONNECT_ONE_SHOT
	)


func _hide_fx_if_current(effect: AnimatedSprite2D, effect_id: StringName, generation: int) -> void:
	var current_generation: int = 0
	match effect_id:
		BURN: current_generation = _burn_visual_generation
		BLEED: current_generation = _bleed_visual_generation
		FREEZE: current_generation = _freeze_visual_generation
		MIRE_SLOW: current_generation = _mire_visual_generation
	if generation == current_generation:
		_set_fx_active(effect, false)
