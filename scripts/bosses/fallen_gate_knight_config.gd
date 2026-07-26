class_name FallenGateKnightConfig
extends Resource

## Centralized phase, attack, movement, and Shield tuning for the first Boss.

@export_category("Identity")
@export var display_name: StringName = &"FallenGateKnight"
@export var display_name_en: String = "FALLEN GATE KNIGHT"
@export var display_name_zh: String = "堕落门卫骑士"

@export_category("Vitals")
@export_range(1, 999, 1) var max_health: int = 18
@export_range(1, 99, 1) var boss_shield_max_health: int = 10

@export_category("Damage")
@export_range(1, 100, 1) var shield_bash_damage: int = 8
@export_range(1, 100, 1) var sword_slash_damage: int = 10
@export_range(1, 100, 1) var heavy_overhead_damage: int = 15
@export_range(1, 100, 1) var charge_thrust_damage: int = 12
@export_range(1, 100, 1) var shockwave_damage: int = 8

@export_category("Locomotion")
@export var shielded_move_speed: float = 52.0
@export var unshielded_move_speed: float = 68.0
@export var acceleration: float = 340.0
@export var deceleration: float = 480.0
@export var gravity: float = 980.0
@export var detection_range: float = 520.0
@export var attack_range: float = 88.0

@export_category("Cadence")
@export var shield_break_stun: float = 0.90
@export var phase_transition_duration: float = 1.10
@export var boss_turn_reaction_delay: float = 0.18
@export var boss_turn_animation_duration: float = 0.30
@export var boss_turn_cooldown: float = 0.12
@export_range(0.0, 32.0, 1.0) var turn_side_threshold: float = 12.0
@export var attack_recovery: float = 0.42
@export var boss_light_hit_reaction_cooldown: float = 0.32
@export var boss_heavy_hit_reaction_cooldown: float = 0.50
@export var boss_heavy_hit_reaction_duration: float = 0.12
@export var shield_break_flash_duration: float = 0.07
@export_range(0.0, 1.0, 0.05) var shield_break_flash_alpha: float = 0.35
