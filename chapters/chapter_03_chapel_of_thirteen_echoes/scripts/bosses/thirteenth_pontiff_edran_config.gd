class_name ThirteenthPontiffEdranConfig
extends Resource

@export_category("Identity")
@export var display_name_en: String = "THE THIRTEENTH PONTIFF, EDRAN"
@export var display_name_zh: String = "第十三响教宗·埃德兰"

@export_category("Phase 1 Vitals")
@export_range(1, 9999, 1) var max_health: int = 360
@export_range(1, 9999, 1) var phase_transition_health: int = 198
@export_range(0.1, 1.0, 0.01) var incoming_damage_multiplier: float = 0.88
@export_range(1, 999, 1) var max_poise: int = 110
@export_range(0.1, 2.0, 0.01) var stagger_duration: float = 0.52
@export_range(0.1, 10.0, 0.1) var stagger_protection_duration: float = 3.0
@export_range(1, 99, 1) var normal_attack_poise_damage: int = 14
@export_range(1, 99, 1) var dash_attack_poise_damage: int = 28

@export_category("Movement")
@export var gravity: float = 980.0
@export var approach_speed: float = 72.0
@export var acceleration: float = 420.0
@export var deceleration: float = 560.0
@export var preferred_distance: float = 112.0
@export var arena_half_width: float = 1250.0

@export_category("Cadence")
@export var phase_1_min_attack_gap: float = 0.88
@export var phase_1_max_attack_gap: float = 1.08
@export_range(1, 4, 1) var chain_limit: int = 2
@export var chain_recovery: float = 1.18
@export var turn_reaction_delay: float = 0.16
@export var turn_animation_duration: float = 0.68
@export_range(0.5, 0.9, 0.05) var turn_facing_commit_ratio: float = 0.70

@export_category("Pontifical Sweep")
@export var sweep_windup: float = 0.58
@export var sweep_active: float = 0.14
@export var sweep_recovery: float = 0.72
@export_range(1, 99, 1) var sweep_damage: int = 15
@export var sweep_range: float = 88.0

@export_category("Crozier Thrust")
@export var thrust_windup: float = 0.48
@export var thrust_active: float = 0.11
@export var thrust_recovery: float = 0.64
@export var thrust_direction_lock: float = 0.16
@export_range(1, 99, 1) var thrust_damage: int = 14
@export var thrust_range: float = 142.0

@export_category("Censer Procession")
@export var censer_windup: float = 0.64
@export var censer_active: float = 0.16
@export var censer_recovery: float = 0.80
@export_range(1, 99, 1) var censer_damage: int = 13
@export var censer_range: float = 104.0
@export var censer_cooldown_min: float = 2.8
@export var censer_cooldown_max: float = 3.5

@export_category("Litany of Ash")
@export var litany_cast_duration: float = 0.76
@export var litany_seal_delay_min: float = 0.80
@export var litany_seal_delay_max: float = 1.00
@export_range(1, 6, 1) var litany_seal_count_min: int = 2
@export_range(1, 6, 1) var litany_seal_count_max: int = 3
@export_range(1, 99, 1) var litany_damage: int = 12
@export var litany_cooldown: float = 4.2

@export_category("Thirteenfold Sentence")
@export var thirteenfold_cast_duration: float = 0.82
@export_range(1, 8, 1) var thirteenfold_wave_count: int = 3
@export_range(1, 99, 1) var thirteenfold_damage: int = 14
@export var thirteenfold_cooldown: float = 6.0
@export var thirteenfold_wave_gap: float = 0.34

@export_category("Raise the Unconfessed")
@export var summon_windup: float = 1.15
@export var summon_recovery: float = 0.72
@export var summon_cooldown_min: float = 8.5
@export var summon_cooldown_max: float = 10.0
@export_range(1, 200, 1) var summon_interrupt_poise: int = 36
@export var summon_interrupt_recovery: float = 0.65
@export var post_summon_major_lock: float = 1.60
@export_range(1, 4, 1) var phase_1_summon_cap: int = 2
@export_range(0, 2, 1) var phase_1_penitent_cap: int = 1
@export_range(0, 2, 1) var phase_1_choir_husk_cap: int = 1
@export var summon_lifetime_min: float = 14.0
@export var summon_lifetime_max: float = 18.0
@export var summon_safe_distance: float = 64.0
