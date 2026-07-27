class_name EnemyCombatant
extends CharacterBody2D

## Narrow mixed-enemy contract used by encounters, debug UI, and tests.

signal enemy_died
signal presentation_finished
signal target_changed(target: Player)
signal attack_window_changed(active: bool)


func set_target(_new_target: Player) -> void:
	pass


func clear_target() -> void:
	set_target(null)


func set_ai_active(_active: bool) -> void:
	pass


func is_ai_active() -> bool:
	return false


func is_dead() -> bool:
	return false


func get_state_name() -> StringName:
	return &"Invalid"


func get_enemy_type_name() -> StringName:
	return &"Enemy"


func get_detection_range() -> float:
	return 0.0


func get_attack_damage() -> int:
	return 0


func is_attack_window_active() -> bool:
	return false


func get_health_component() -> HealthComponent:
	return null


func get_current_animation_name() -> StringName:
	return &""


func get_attack_phase_name() -> StringName:
	return &"None"


func get_active_projectile_count() -> int:
	return 0


func get_debug_summary() -> String:
	var health: HealthComponent = get_health_component()
	var health_text: String = "--"
	if health != null:
		health_text = "%d/%d" % [health.current_health, health.max_health]
	return "%s  %s  HP %s  ANIM %s" % [
		get_enemy_type_name(), get_state_name(), health_text, get_current_animation_name(),
	]
