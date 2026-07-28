class_name Chapter03SpecialistConfig
extends EnemyGroundConfig

enum Archetype { CENSER_EXECUTIONER, SILENT_CHORISTER, STAINED_GLASS_SERAPH, CONFESSIONAL_WRAITH, THIRTEENTH_SCRIBE }

@export var archetype: Archetype = Archetype.CENSER_EXECUTIONER
@export_category("Chapter III vitals")
@export_range(1, 200, 1) var chapter_max_health: int = 100
@export_range(1, 200, 1) var max_poise: int = 40
@export_range(1, 99, 1) var normal_attack_poise_damage: int = 14
@export_range(1, 99, 1) var dash_attack_poise_damage: int = 28
@export var poise_recovery_delay: float = 1.2
@export var stagger_duration: float = 0.6
@export var alert_duration: float = 0.25
@export var turn_duration: float = 0.24

@export_category("Primary action")
@export var primary_action: StringName = &"primary"

@export_category("Secondary action")
@export var secondary_action: StringName = &"secondary"
@export_range(1, 100, 1) var secondary_damage: int = 10
@export var secondary_range: float = 92.0
@export var secondary_windup: float = 0.62
@export var secondary_active_duration: float = 0.12
@export var secondary_recovery: float = 0.72
@export var secondary_cooldown: float = 2.4

@export_category("Special action")
@export var special_action: StringName = &"special"
@export_range(0, 100, 1) var special_damage: int = 4
@export var special_range: float = 150.0
@export var special_windup: float = 0.7
@export var special_active_duration: float = 0.15
@export var special_recovery: float = 0.8
@export var special_cooldown: float = 4.0
@export var special_duration: float = 2.0

@export_category("Air and projectile")
@export var airborne: bool = false
@export var hover_height: float = 94.0
@export var hover_amplitude: float = 5.0
@export var projectile_speed: float = 210.0
@export var projectile_lifetime: float = 2.4

@export_category("Role rules")
@export var protected_active_frames: bool = false
@export var starts_hidden: bool = false
@export var hidden_duration: float = 0.8
@export var ward_cooldown: float = 4.0
@export var support_multiplier: float = 0.65
@export var movement_slow_multiplier: float = 0.8
@export var movement_slow_duration: float = 1.0
