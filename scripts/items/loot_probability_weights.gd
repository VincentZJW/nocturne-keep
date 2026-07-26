class_name LootProbabilityWeights
extends Resource

## One mutually exclusive 100-point drop table.

@export_range(0, 100, 1) var coin_weight: int = 0
@export_range(0, 100, 1) var small_health_weight: int = 0
@export_range(0, 100, 1) var large_health_weight: int = 0
@export_range(0, 100, 1) var none_weight: int = 100


func get_total_weight() -> int:
	return coin_weight + small_health_weight + large_health_weight + none_weight


func is_valid_table() -> bool:
	return get_total_weight() == 100


func get_drop_kind(roll: float) -> StringName:
	var bounded_roll: float = clampf(roll, 0.0, 99.9999)
	var threshold: float = float(coin_weight)
	if bounded_roll < threshold:
		return &"coin"
	threshold += float(small_health_weight)
	if bounded_roll < threshold:
		return &"small_health"
	threshold += float(large_health_weight)
	if bounded_roll < threshold:
		return &"large_health"
	return &"none"


func get_debug_summary() -> String:
	return "coin %d | small %d | large %d | none %d" % [
		coin_weight, small_health_weight, large_health_weight, none_weight,
	]
