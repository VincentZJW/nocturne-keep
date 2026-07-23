class_name HealthComponent
extends Node

## Owns bounded health mutation without defining death state or presentation behavior.

## Emitted after [member current_health] changes.
signal health_changed(current: int, maximum: int)
## Emitted once when health reaches zero. Restoring positive health rearms the signal.
signal died

@export_range(1, 9999, 1) var max_health: int = 100

var current_health: int:
	get:
		return _current_health
	set(value):
		_set_current_health(value)

var _current_health: int = 0
var _death_emitted: bool = false


func _ready() -> void:
	max_health = maxi(1, max_health)
	_current_health = max_health
	health_changed.emit(_current_health, max_health)


func set_current_health(value: int) -> void:
	current_health = value


func take_damage(amount: int) -> void:
	if amount <= 0 or is_dead():
		return
	set_current_health(_current_health - amount)


func heal(amount: int) -> void:
	if amount <= 0:
		return
	set_current_health(_current_health + amount)


func reset_to_full() -> void:
	set_current_health(max_health)


func is_dead() -> bool:
	return _current_health <= 0


func _set_current_health(value: int) -> void:
	max_health = maxi(1, max_health)
	var clamped_health: int = clampi(value, 0, max_health)
	if clamped_health == _current_health:
		return
	_current_health = clamped_health
	health_changed.emit(_current_health, max_health)
	if _current_health > 0:
		_death_emitted = false
		return
	if not _death_emitted:
		_death_emitted = true
		died.emit()
