class_name SilentCourtEnemyConfig
extends EnemyGroundConfig

## Typed tuning shared only by the four grounded Silent Court prototypes.

enum Archetype {
	HOLLOW_RETAINER,
	COURT_HALBERDIER,
	MOURNING_ARMOR,
	BLOOD_CANDLE_ACOLYTE,
}

@export_category("Role")
@export var archetype: Archetype = Archetype.HOLLOW_RETAINER
@export_range(1, 100, 1) var secondary_damage: int = 5
@export_range(1, 100, 1) var tertiary_damage: int = 5
@export var close_range: float = 34.0
@export var secondary_range: float = 72.0
@export var turn_duration: float = 0.28
@export var retreat_distance: float = 108.0

@export_category("Secondary cadence")
@export var secondary_windup: float = 0.34
@export var secondary_active_duration: float = 0.10
@export var secondary_recovery: float = 0.48
@export var combo_gap: float = 0.08

@export_category("Mourning Armor")
@export_range(1, 10, 1) var poise_max: int = 4
@export_range(0.0, 1.0, 0.05) var frontal_normal_multiplier: float = 0.75
@export var stagger_duration: float = 0.42

@export_category("Blood-Candle Acolyte")
@export var projectile_speed: float = 180.0
@export var projectile_lifetime: float = 2.4
@export_range(1, 100, 1) var ember_damage: int = 4
@export var ember_lifetime: float = 0.65
@export var buff_radius: float = 220.0
@export_range(0.5, 1.0, 0.01) var buff_windup_multiplier: float = 0.90
@export var buff_channel_duration: float = 0.50
