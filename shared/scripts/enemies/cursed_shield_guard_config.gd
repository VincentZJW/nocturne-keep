class_name CursedShieldGuardConfig
extends EnemyGroundConfig

## Heavy frontal defender with independently tuned body and shield durability.

@export_range(1, 99, 1) var shield_max_health: int = 3
@export_range(0.0, 16.0, 1.0) var shield_center_tolerance: float = 8.0
@export var guard_break_duration: float = 0.65
@export var block_reaction_duration: float = 0.24
@export var turn_delay: float = 0.22
@export_range(0.04, 0.06, 0.01) var shield_break_flash_duration: float = 0.05
@export_range(0.25, 0.35, 0.05) var shield_break_flash_alpha: float = 0.30
