class_name LootDropProfile
extends Resource

## Per-enemy quantity tuning. Shared health-aware weights live in LootDropComponent.

@export var enemy_type: StringName
@export_range(1, 99, 1) var coin_min: int = 1
@export_range(1, 99, 1) var coin_max: int = 2


func get_coin_amount(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(coin_min, maxi(coin_min, coin_max))
