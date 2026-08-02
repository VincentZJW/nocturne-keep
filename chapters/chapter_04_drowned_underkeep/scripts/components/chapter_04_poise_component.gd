class_name Chapter04PoiseComponent
extends Node

signal poise_changed(current: int, maximum: int)
signal poise_broken

@export_range(1, 300, 1) var max_poise: int = 40
@export var recovery_delay: float = 1.15

var current_poise: int = 40
var _recovery_timer: float = 0.0


func configure(maximum: int, delay: float) -> void:
	max_poise = maxi(1, maximum)
	recovery_delay = maxf(0.0, delay)
	reset_to_full()


func apply_impact(amount: int) -> bool:
	if amount <= 0:
		return false
	current_poise = maxi(0, current_poise - amount)
	_recovery_timer = recovery_delay
	poise_changed.emit(current_poise, max_poise)
	if current_poise > 0:
		return false
	poise_broken.emit()
	return true


func advance(delta: float, locked: bool) -> void:
	if locked or current_poise >= max_poise:
		return
	_recovery_timer = maxf(0.0, _recovery_timer - delta)
	if _recovery_timer <= 0.0:
		reset_to_full()


func reset_to_full() -> void:
	current_poise = max_poise
	_recovery_timer = 0.0
	poise_changed.emit(current_poise, max_poise)
