class_name DynamicLootProfile
extends Resource

## Shared normal-enemy drop tables selected from a single Player Health snapshot.

enum HealthTier {
	FULL,
	LIGHT,
	HEAVY,
	CRITICAL,
}

@export var full_health_weights: LootProbabilityWeights
@export var light_damage_weights: LootProbabilityWeights
@export var heavy_damage_weights: LootProbabilityWeights
@export var critical_health_weights: LootProbabilityWeights


func get_health_tier(current_health: int, max_health: int) -> HealthTier:
	if max_health <= 0 or current_health >= max_health:
		return HealthTier.FULL
	return get_health_tier_from_ratio(
		clampf(float(maxi(0, current_health)) / float(max_health), 0.0, 1.0)
	)


func get_health_tier_from_ratio(health_ratio: float) -> HealthTier:
	var bounded_ratio: float = clampf(health_ratio, 0.0, 1.0)
	if bounded_ratio >= 1.0:
		return HealthTier.FULL
	if bounded_ratio > 0.50:
		return HealthTier.LIGHT
	if bounded_ratio > 0.20:
		return HealthTier.HEAVY
	return HealthTier.CRITICAL


func get_weights(tier: HealthTier) -> LootProbabilityWeights:
	match tier:
		HealthTier.FULL:
			return full_health_weights
		HealthTier.LIGHT:
			return light_damage_weights
		HealthTier.HEAVY:
			return heavy_damage_weights
		_:
			return critical_health_weights


func get_tier_name(tier: HealthTier) -> StringName:
	match tier:
		HealthTier.FULL:
			return &"FULL"
		HealthTier.LIGHT:
			return &"LIGHT"
		HealthTier.HEAVY:
			return &"HEAVY"
		_:
			return &"CRITICAL"


func is_valid_profile() -> bool:
	for weights: LootProbabilityWeights in [
		full_health_weights,
		light_damage_weights,
		heavy_damage_weights,
		critical_health_weights,
	]:
		if weights == null or not weights.is_valid_table():
			return false
	return true
