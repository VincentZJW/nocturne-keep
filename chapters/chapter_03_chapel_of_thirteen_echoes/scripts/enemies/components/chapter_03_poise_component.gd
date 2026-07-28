class_name Chapter03PoiseComponent
extends Node

## Reusable Chapter III Poise data layer. Enemy controllers decide how Stagger
## is presented; this node only owns bounded Poise and delayed restoration.

signal poise_changed(current: int, maximum: int)
signal poise_broken

@export_range(1, 999, 1) var max_poise: int = 32
@export var recovery_delay: float = 1.20

var current_poise: int = 0
var recovery_timer: float = 0.0


func _ready() -> void:
	reset_to_full()


func configure(maximum: int, delay: float) -> void:
	max_poise = maxi(1, maximum)
	recovery_delay = maxf(0.0, delay)
	reset_to_full()


func apply_impact(amount: int) -> bool:
	if amount <= 0 or current_poise <= 0:
		return false
	current_poise = maxi(0, current_poise - amount)
	recovery_timer = recovery_delay
	poise_changed.emit(current_poise, max_poise)
	if current_poise > 0:
		return false
	poise_broken.emit()
	return true


func advance(delta: float, recovery_blocked: bool = false) -> void:
	if recovery_blocked or current_poise >= max_poise:
		return
	recovery_timer = maxf(0.0, recovery_timer - delta)
	if recovery_timer <= 0.0:
		reset_to_full()


func reset_to_full() -> void:
	max_poise = maxi(1, max_poise)
	current_poise = max_poise
	recovery_timer = 0.0
	poise_changed.emit(current_poise, max_poise)
