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
@export var summon_cooldown_min: float = 6.2
@export var summon_cooldown_max: float = 7.4
@export var summon_interrupt_cooldown: float = 3.0
@export_range(1, 200, 1) var summon_interrupt_poise: int = 36
@export var summon_interrupt_recovery: float = 0.65
@export var post_summon_major_lock: float = 1.60
@export_range(1, 4, 1) var phase_1_summon_cap: int = 2
@export_range(0, 2, 1) var phase_1_penitent_cap: int = 1
@export_range(0, 2, 1) var phase_1_choir_husk_cap: int = 1
@export var summon_lifetime_min: float = 14.0
@export var summon_lifetime_max: float = 18.0
@export var summon_safe_distance: float = 64.0

@export_category("Phase Transition")
@export_range(4.5, 6.0, 0.1) var phase_transition_duration: float = 5.2
@export var phase_transition_center_tolerance: float = 18.0
@export var phase_02_ready_delay: float = 0.42

@export_category("Phase 2 Vitals")
@export_range(0.1, 1.0, 0.01) var phase_02_incoming_damage_multiplier: float = 0.80
@export_range(1, 999, 1) var phase_02_max_poise: int = 145
@export_range(0.1, 2.0, 0.01) var phase_02_stagger_duration: float = 0.44
@export_range(0.1, 10.0, 0.1) var phase_02_stagger_protection_duration: float = 3.5

@export_category("Phase 2 Cadence")
@export var phase_02_min_attack_gap: float = 0.74
@export var phase_02_max_attack_gap: float = 0.94
@export_range(1, 4, 1) var phase_02_chain_limit: int = 2
@export var phase_02_chain_recovery_min: float = 0.96
@export var phase_02_chain_recovery_max: float = 1.16
@export var phase_02_turn_reaction_delay: float = 0.12
@export var phase_02_turn_animation_duration: float = 0.58

@export_category("Bell-Bound Cleave")
@export var bell_cleave_windup: float = 0.52
@export var bell_cleave_active: float = 0.15
@export var bell_cleave_recovery: float = 0.68
@export_range(1, 99, 1) var bell_cleave_damage: int = 18
@export var bell_cleave_range: float = 118.0

@export_category("Hollow Toll")
@export var hollow_toll_windup: float = 0.76
@export var hollow_toll_recovery: float = 0.82
@export_range(1, 99, 1) var hollow_toll_damage: int = 16
@export var hollow_toll_cooldown: float = 4.2

@export_category("Censer Chain Judgment")
@export var chain_judgment_windup: float = 0.56
@export var chain_judgment_first_active: float = 0.12
@export var chain_judgment_stage_gap: float = 0.28
@export var chain_judgment_second_active: float = 0.14
@export var chain_judgment_recovery: float = 0.88
@export_range(1, 99, 1) var chain_judgment_first_damage: int = 14
@export_range(1, 99, 1) var chain_judgment_second_damage: int = 17
@export var chain_judgment_range: float = 136.0

@export_category("Scripture Burial")
@export var scripture_burial_cast: float = 0.72
@export var scripture_burial_delay: float = 0.85
@export_range(1, 2, 1) var scripture_burial_zone_count: int = 2
@export_range(1, 99, 1) var scripture_burial_damage: int = 14
@export var scripture_burial_cooldown: float = 4.8

@export_category("Procession of the Unburied")
@export var procession_windup: float = 1.0
@export var procession_recovery: float = 0.68
@export var phase_02_summon_cooldown_min: float = 4.8
@export var phase_02_summon_cooldown_max: float = 6.0
@export_range(1, 3, 1) var phase_02_summon_cap: int = 3
@export_range(0, 3, 1) var phase_02_penitent_cap: int = 3
@export_range(0, 1, 1) var phase_02_choir_husk_cap: int = 1

@export_category("Elemental Magic Cadence")
@export var phase_1_magic_global_cooldown_min: float = 3.8
@export var phase_1_magic_global_cooldown_max: float = 4.8
@export var phase_2_magic_global_cooldown_min: float = 3.0
@export var phase_2_magic_global_cooldown_max: float = 4.0

@export_category("Cinder Absolution")
@export var fire_windup: float = 0.58
@export var fire_direction_lock: float = 0.18
@export var fire_recovery: float = 0.72
@export var fire_cooldown: float = 4.5
@export_range(1, 99, 1) var fire_impact_damage: int = 8
@export_range(1, 99, 1) var burn_tick_damage: int = 5
@export var burn_duration: float = 3.0
@export var burn_tick_interval: float = 1.0

@export_category("Litany of Stillness")
@export var ice_windup: float = 0.72
@export var ice_direction_lock: float = 0.20
@export var ice_recovery: float = 0.84
@export var phase_1_ice_cooldown: float = 8.5
@export var phase_2_ice_cooldown: float = 7.0
@export_range(1, 99, 1) var ice_impact_damage: int = 7
@export var freeze_duration: float = 3.0
@export var freeze_immunity_duration: float = 5.0
@export var frozen_major_attack_grace: float = 1.25

@export_category("Mire of the Unburied")
@export var mire_cast_time: float = 2.0
@export var mire_telegraph_delay: float = 0.20
@export var mire_target_lock_time: float = 1.15
@export var mire_recovery: float = 0.70
@export var mire_cooldown: float = 7.0
@export var mire_duration: float = 4.5
@export_range(0.1, 1.0, 0.05) var mire_move_multiplier: float = 0.35
@export_range(0.1, 1.0, 0.05) var mire_dash_multiplier: float = 0.70

@export_category("Threefold Judgment")
@export var lightning_windup: float = 0.85
@export var lightning_position_delay: float = 1.0
@export var lightning_history_duration: float = 2.0
@export var lightning_history_sample_interval: float = 0.10
@export var lightning_telegraph_duration: float = 0.65
@export var lightning_strike_interval: float = 0.70
@export var lightning_active_duration: float = 0.18
@export var lightning_visual_duration: float = 0.32
@export_range(1, 99, 1) var lightning_damage: int = 18
@export var phase_1_lightning_cooldown: float = 10.5
@export var phase_2_lightning_cooldown: float = 8.5
@export var phase_1_lightning_recovery: float = 1.0
@export var phase_2_lightning_recovery: float = 0.85

@export_category("The Weight of Absolution")
@export var gravity_cast_time: float = 1.70
@export var gravity_final_seal_time: float = 1.40
@export var gravity_cooldown: float = 21.0
@export var gravity_interrupt_cooldown: float = 9.0
@export var gravity_first_cast_delay: float = 8.0
@export var gravity_recovery: float = 1.35
@export_range(1, 99, 1) var gravity_direct_damage: int = 20
@export_range(1, 999, 1) var gravity_health_threshold: int = 50
@export_range(1, 999, 1) var gravity_health_floor: int = 20
@export var gravity_post_pressure_lock: float = 1.75

@export_category("Fourteenth Seat")
@export var fourteenth_seat_health_ratio: float = 0.25
@export var fourteenth_seat_warning: float = 1.05
@export var fourteenth_seat_cooldown: float = 7.0
@export_range(1, 99, 1) var fourteenth_seat_damage: int = 20

@export_category("Death")
@export_range(1.5, 6.0, 0.1) var death_sequence_duration: float = 3.4
