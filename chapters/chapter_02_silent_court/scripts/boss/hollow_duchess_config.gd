class_name HollowDuchessConfig
extends Resource

## Central tuning contract for The Hollow Duchess. Runtime behavior owns no magic combat values.

@export_category("Identity")
@export var display_name_en: String = "THE HOLLOW DUCHESS, SERAPHINE"
@export var display_name_zh: String = "空心公爵夫人·瑟芙琳"

@export_category("Vitals")
@export_range(1, 9999, 1) var max_health: int = 220
@export_range(0.1, 0.9, 0.01) var phase_2_threshold: float = 0.55
@export_range(1, 999, 1) var max_poise: int = 60
@export_range(0.1, 2.0, 0.01) var stagger_duration: float = 0.56
@export_range(0.1, 10.0, 0.1) var stagger_protection_duration: float = 2.5
@export_range(1, 999, 1) var phase_2_max_poise: int = 80
@export_range(0.1, 2.0, 0.01) var phase_2_stagger_duration: float = 0.48
@export_range(0.1, 10.0, 0.1) var phase_2_stagger_protection_duration: float = 3.0
@export_range(0.1, 1.0, 0.01) var phase_2_incoming_damage_multiplier: float = 0.85
@export_range(1, 99, 1) var normal_attack_poise_damage: int = 10
@export_range(1, 99, 1) var dash_attack_poise_damage: int = 24

@export_category("Movement")
@export var gravity: float = 980.0
@export var approach_speed: float = 132.0
@export var retreat_speed: float = 120.0
@export var side_step_speed: float = 300.0
@export var backstep_speed: float = 350.0
@export var lunge_speed: float = 250.0
@export var final_waltz_speed: float = 430.0
@export var acceleration: float = 720.0
@export var deceleration: float = 880.0
@export var preferred_distance: float = 96.0
@export var far_distance: float = 172.0
@export var side_threshold: float = 15.0
@export var close_clearance: float = 48.0
@export var arena_left_offset: float = -1500.0
@export var arena_right_offset: float = 1300.0

@export_category("Decision Timing")
@export var intro_attack_gap: float = 0.45
@export var idle_decision_delay: float = 0.16
@export var approach_evaluation_time: float = 0.30
@export var retreat_duration: float = 0.28
@export var approach_gap_margin: float = 24.0
@export var retreat_gap_margin: float = 28.0
@export var phase_transition_retreat_time: float = 0.44
@export var phase_transition_center_speed: float = 210.0
@export var phase_2_entry_gap: float = 0.88
@export var post_stagger_gap: float = 0.40
@export var light_hit_reaction_duration: float = 0.12

@export_category("Turn")
@export var turn_reaction_delay: float = 0.14
@export var turn_animation_duration: float = 0.44
@export_range(0.5, 0.9, 0.05) var turn_facing_commit_ratio: float = 0.70

@export_category("Cadence")
@export var phase_1_min_attack_gap: float = 0.84
@export var phase_1_max_attack_gap: float = 1.02
@export var phase_2_min_attack_gap: float = 0.82
@export var phase_2_max_attack_gap: float = 1.02
@export_range(1, 4, 1) var chain_limit: int = 2
@export var phase_1_chain_recovery: float = 1.14
@export var phase_2_chain_recovery: float = 0.99
@export var backstep_riposte_cooldown: float = 3.6
@export var side_step_cut_cooldown: float = 2.9
@export var phantom_dance_cooldown: float = 4.5
@export var final_waltz_cooldown: float = 7.0

@export_category("Rapier Thrust")
@export var rapier_thrust_windup: float = 0.46
@export var rapier_thrust_active: float = 0.11
@export var rapier_thrust_recovery: float = 0.60
@export_range(1, 20, 1) var rapier_thrust_damage: int = 11
@export_range(1, 20, 1) var phase_2_rapier_thrust_damage: int = 13
@export var rapier_thrust_range: float = 112.0

@export_category("Fan Slash")
@export var fan_slash_windup: float = 0.54
@export var fan_slash_active: float = 0.14
@export var fan_slash_recovery: float = 0.72
@export_range(1, 20, 1) var fan_slash_damage: int = 13
@export_range(1, 20, 1) var phase_2_fan_slash_damage: int = 16
@export var fan_slash_range: float = 70.0

@export_category("Backstep Riposte")
@export var backstep_duration: float = 0.24
@export var pause_after_backstep: float = 0.22
@export var riposte_windup: float = 0.30
@export var riposte_active: float = 0.10
@export var riposte_recovery: float = 0.72
@export_range(1, 20, 1) var riposte_damage: int = 12
@export_range(1, 20, 1) var phase_2_riposte_damage: int = 14

@export_category("Side-Step Cut")
@export var side_step_duration: float = 0.38
@export var side_step_cut_windup: float = 0.32
@export var side_step_cut_active: float = 0.11
@export var side_step_cut_recovery: float = 0.66
@export_range(1, 20, 1) var side_step_cut_damage: int = 12
@export_range(1, 20, 1) var phase_2_side_step_cut_damage: int = 14
@export var side_step_cut_prepare: float = 0.12

@export_category("Phase Transition")
@export var phase_transition_duration: float = 4.40
@export var phase_2_sprite_reveal_time: float = 2.75

@export_category("Double Waltz Lunge")
@export var double_lunge_windup: float = 0.48
@export var double_lunge_hit_1_active: float = 0.10
@export var double_lunge_gap: float = 0.27
@export var double_lunge_hit_2_active: float = 0.11
@export var double_lunge_recovery: float = 0.80
@export_range(1, 20, 1) var double_lunge_damage_1: int = 10
@export_range(1, 20, 1) var double_lunge_damage_2: int = 14

@export_category("Phantom Dancer Sweep")
@export var phantom_telegraph: float = 0.75
@export var phantom_active: float = 0.72
@export var phantom_recovery: float = 0.82
@export_range(1, 20, 1) var phantom_damage: int = 12
@export var phantom_route_half_length: float = 520.0
@export var phantom_route_edge_margin: float = 560.0
@export var phantom_elevated_lane_offset: float = 64.0

@export_category("Final Waltz Crossing")
@export_range(0.05, 0.5, 0.01) var final_waltz_health_threshold: float = 0.25
@export var final_waltz_prepare: float = 0.90
@export_range(1, 5, 1) var final_waltz_passes: int = 3
@export var final_waltz_pass_duration: float = 0.68
@export var final_waltz_pass_gap: float = 0.43
@export var final_waltz_recovery: float = 1.15
@export_range(1, 20, 1) var final_waltz_damage: int = 10
@export var final_waltz_telegraph_length: float = 310.0

@export_category("Presentation")
@export var intro_full_duration: float = 6.4
@export var intro_retry_duration: float = 1.25
@export var death_duration: float = 3.70
@export var death_player_line_time: float = 0.65
@export var death_boss_line_time: float = 1.25
@export var death_passage_line_time: float = 2.05
@export var death_echo_line_time: float = 2.85
@export var light_hit_flash_duration: float = 0.08

@export_category("Attack Selection")
@export var rapier_selection_padding: float = 28.0
@export var riposte_selection_range: float = 58.0
@export var side_cut_selection_range: float = 124.0
@export var double_lunge_selection_range: float = 148.0
@export_range(0.0, 1.0, 0.01) var repeated_attack_weight: float = 0.55
@export_range(0.0, 1.0, 0.01) var overused_attack_weight: float = 0.18

@export_category("Attack Geometry")
@export var rapier_hitbox_size: Vector2 = Vector2(62.0, 12.0)
@export var rapier_hitbox_offset: Vector2 = Vector2(47.0, -5.0)
@export var fan_hitbox_size: Vector2 = Vector2(44.0, 12.0)
@export var fan_hitbox_offset: Vector2 = Vector2(29.0, -2.0)
@export var riposte_hitbox_size: Vector2 = Vector2(58.0, 12.0)
@export var riposte_hitbox_offset: Vector2 = Vector2(45.0, -5.0)
@export var side_cut_hitbox_size: Vector2 = Vector2(46.0, 18.0)
@export var side_cut_hitbox_offset: Vector2 = Vector2(31.0, -1.0)
@export var double_lunge_1_size: Vector2 = Vector2(58.0, 12.0)
@export var double_lunge_2_size: Vector2 = Vector2(72.0, 12.0)
@export var double_lunge_offset: Vector2 = Vector2(48.0, -5.0)
@export var final_waltz_hitbox_size: Vector2 = Vector2(42.0, 52.0)
