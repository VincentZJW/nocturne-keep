class_name PlayerStaminaComponent
extends Node

## Owns player stamina values and regeneration. Presentation observes typed signals only.

signal stamina_changed(current: float, maximum: float)
signal stamina_depleted
signal stamina_insufficient

@export_range(1.0, 1000.0, 1.0) var max_stamina: float = 100.0
@export_range(0.0, 1000.0, 1.0) var dash_stamina_cost: float = 25.0
@export_range(0.0, 10.0, 0.01) var stamina_regen_delay: float = 0.60
@export_range(0.0, 1000.0, 1.0) var stamina_regen_rate: float = 35.0

var current_stamina: float = 100.0
var stamina_regen_timer: float = 0.0


func _ready() -> void:
	current_stamina = max_stamina
	stamina_regen_timer = 0.0
	stamina_changed.emit(current_stamina, max_stamina)


func advance(delta: float, regeneration_blocked: bool) -> void:
	stamina_regen_timer = maxf(0.0, stamina_regen_timer - delta)
	if regeneration_blocked or stamina_regen_timer > 0.0 or current_stamina >= max_stamina:
		return
	var previous_stamina: float = current_stamina
	current_stamina = minf(max_stamina, current_stamina + stamina_regen_rate * delta)
	if not is_equal_approx(previous_stamina, current_stamina):
		stamina_changed.emit(current_stamina, max_stamina)


func can_afford_dash() -> bool:
	return current_stamina + 0.0001 >= dash_stamina_cost


func try_consume_dash() -> bool:
	if not can_afford_dash():
		stamina_insufficient.emit()
		return false
	current_stamina = clampf(current_stamina - dash_stamina_cost, 0.0, max_stamina)
	stamina_regen_timer = stamina_regen_delay
	stamina_changed.emit(current_stamina, max_stamina)
	if is_zero_approx(current_stamina):
		stamina_depleted.emit()
	return true


func refund_dash_charge() -> void:
	current_stamina = minf(max_stamina, current_stamina + dash_stamina_cost)
	stamina_changed.emit(current_stamina, max_stamina)


func reset_to_full() -> void:
	current_stamina = max_stamina
	stamina_regen_timer = 0.0
	stamina_changed.emit(current_stamina, max_stamina)
