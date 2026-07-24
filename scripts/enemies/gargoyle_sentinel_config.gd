class_name GargoyleSentinelConfig
extends Resource

## Centralized tuning for the first airborne normal enemy.

@export var display_name: StringName = &"GargoyleSentinel"
@export_range(1, 100, 1) var max_health: int = 3
@export_range(1, 100, 1) var dive_damage: int = 7
@export var detection_range: float = 220.0
@export var lose_target_range: float = 310.0
@export var hover_speed: float = 45.0
@export var dive_windup: float = 0.45
@export var dive_direction_lock_duration: float = 0.15
@export var dive_speed: float = 300.0
@export var ground_stun_duration: float = 0.65
@export var return_height: float = 70.0
@export var return_speed: float = 125.0
@export var attack_cooldown: float = 1.10
@export var hurt_duration: float = 0.18
@export var knockback_speed: float = 95.0
