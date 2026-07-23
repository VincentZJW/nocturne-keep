class_name PlayerHurtConfig
extends Resource

## Central tuning for the Night Warden's non-lethal damage reaction.

@export_category("Knockback")
@export var hurt_knockback_horizontal: float = 180.0
@export var hurt_knockback_vertical: float = -110.0
@export_range(0.0, 1.0, 0.05) var airborne_vertical_multiplier: float = 0.70

@export_category("Timing")
@export var hurt_stun_duration: float = 0.16
@export var hurt_control_recovery_duration: float = 0.08
@export var invulnerability_duration: float = 0.50

@export_category("Presentation")
@export var hit_flash_duration: float = 0.08
@export var camera_shake_strength: float = 2.5
@export var camera_shake_duration: float = 0.10
