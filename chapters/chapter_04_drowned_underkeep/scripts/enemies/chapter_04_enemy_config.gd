class_name Chapter04EnemyConfig
extends EnemyGroundConfig

enum Archetype {
	DROWNED_GAOLER,
	CHAINBOUND_CONVICT,
	MIRE_HARPOONER,
	SUNKEN_SHIELD_PENITENT,
	MIREFIN_RAIDER,
	BOG_TOAD,
	SEWER_MAW,
	UNDERKEEP_EXECUTIONER,
}

@export var archetype: Archetype = Archetype.DROWNED_GAOLER

@export_category("Chapter IV vitals")
@export_range(1, 600, 1) var chapter_max_health: int = 100
@export_range(1, 300, 1) var max_poise: int = 40
@export_range(1, 99, 1) var normal_attack_poise_damage: int = 14
@export_range(1, 99, 1) var dash_attack_poise_damage: int = 28
@export var poise_recovery_delay: float = 1.15
@export var stagger_duration: float = 0.62
@export var alert_duration: float = 0.26
@export var turn_duration: float = 0.24

@export_category("Primary action")
@export var primary_action: StringName = &"primary"

@export_category("Secondary action")
@export var secondary_action: StringName = &"secondary"
@export_range(1, 100, 1) var secondary_damage: int = 10
@export var secondary_range: float = 90.0
@export var secondary_windup: float = 0.60
@export var secondary_active_duration: float = 0.14
@export var secondary_recovery: float = 0.72
@export var secondary_cooldown: float = 2.25

@export_category("Special action")
@export var special_action: StringName = &"special"
@export_range(0, 100, 1) var special_damage: int = 8
@export var special_range: float = 150.0
@export var special_windup: float = 0.78
@export var special_active_duration: float = 0.15
@export var special_recovery: float = 0.88
@export var special_cooldown: float = 4.0

@export_category("Motion and delivery")
@export var airborne: bool = false
@export var amphibious: bool = false
@export var starts_hidden: bool = false
@export var hidden_duration: float = 0.72
@export var hover_amplitude: float = 5.0
@export var projectile_speed: float = 235.0
@export var projectile_lifetime: float = 2.8
@export var primary_motion_speed: float = 0.0
@export var secondary_motion_speed: float = 0.0
@export var special_motion_speed: float = 0.0
@export var pull_strength: float = 0.0
@export var protected_active_frames: bool = false

@export_category("Shield")
@export_range(0, 200, 1) var shield_max_health: int = 0
@export var guard_break_duration: float = 0.74
