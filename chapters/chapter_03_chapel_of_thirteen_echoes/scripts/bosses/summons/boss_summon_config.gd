class_name BossSummonConfig
extends Resource

@export_category("Identity")
@export var display_name_en: String
@export var display_name_zh: String
@export var actor_kind: StringName

@export_category("Vitals")
@export_range(1, 999, 1) var max_health: int = 30
@export_range(1, 999, 1) var max_poise: int = 16
@export var stagger_duration: float = 0.32

@export_category("Movement")
@export var move_speed: float = 44.0
@export var gravity: float = 980.0
@export var attack_range: float = 52.0
@export var preferred_range: float = 50.0

@export_category("Attack")
@export_range(1, 99, 1) var primary_damage: int = 8
@export_range(1, 99, 1) var secondary_damage: int = 9
@export var windup: float = 0.42
@export var active: float = 0.10
@export var recovery: float = 0.58
@export var attack_cooldown: float = 1.2
@export var projectile_speed: float = 150.0
@export var summon_telegraph_duration: float = 0.92
@export var rise_duration: float = 0.60
