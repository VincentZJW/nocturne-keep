class_name CastleGuardConfig
extends Resource

## Central tuning data for the first slow, telegraphed melee enemy.

@export_category("Vitals")
@export_range(1, 100, 1) var max_health: int = 3
@export_range(1, 100, 1) var attack_damage: int = 5

@export_category("Locomotion")
@export var patrol_speed: float = 45.0
@export var chase_speed: float = 75.0
@export var ground_acceleration: float = 420.0
@export var ground_deceleration: float = 520.0
@export var gravity: float = 980.0
@export var patrol_half_width: float = 150.0
@export var platform_height_tolerance: float = 72.0

@export_category("Awareness")
@export var detection_range: float = 180.0
@export var lose_target_range: float = 260.0
@export var attack_range: float = 46.0

@export_category("Attack")
@export var attack_windup: float = 0.35
@export var attack_active_duration: float = 0.10
@export var attack_recovery: float = 0.45

@export_category("Reaction")
@export var hurt_duration: float = 0.18
@export var knockback_speed: float = 120.0
@export var death_hide_delay: float = 0.0

@export_category("State cadence")
@export var initial_idle_duration: float = 0.55
@export var patrol_turn_pause: float = 0.25
