class_name FallenCrossbowmanConfig
extends EnemyGroundConfig

## Ranged cadence and projectile tuning for the first grounded shooter.

@export var aim_duration: float = 0.60
@export var reload_duration: float = 1.50
@export var projectile_speed: float = 260.0
@export_range(1, 100, 1) var projectile_damage: int = 6
@export var minimum_safe_distance: float = 70.0
@export var retreat_distance: float = 105.0
@export var projectile_lifetime: float = 3.0
