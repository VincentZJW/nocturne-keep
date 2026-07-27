class_name HangingStalkerConfig
extends Resource

@export var display_name: StringName = &"Hanging Stalker"
@export_range(1, 999, 1) var max_health: int = 48
@export_range(1, 100, 1) var drop_damage: int = 9
@export_range(1, 100, 1) var claw_damage: int = 6
@export var detection_range: float = 230.0
@export var lose_target_range: float = 320.0
@export var telegraph_duration: float = 0.55
@export var direction_lock_lead: float = 0.18
@export var drop_speed: float = 360.0
@export var ground_recovery_duration: float = 0.52
@export var claw_windup: float = 0.25
@export var claw_active_duration: float = 0.10
@export var retreat_duration: float = 0.32
@export var return_speed: float = 210.0
@export var hurt_duration: float = 0.18
@export var knockback_speed: float = 100.0
