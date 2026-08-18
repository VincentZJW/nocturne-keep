class_name FallenGateKnightConfig
extends Resource

## Centralized phase, attack, movement, and Shield tuning for the first Boss.

@export_category("Identity")
@export var display_name: StringName = &"FallenGateKnight"
@export var display_name_en: String = "FALLEN GATE KNIGHT"
@export var display_name_zh: String = "堕落守门骑士"

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

@export_category("Attack geometry and selection")
@export var shield_bash_hitbox_size: Vector2 = Vector2(14.0, 30.0)
@export var shield_bash_hitbox_offset: Vector2 = Vector2(19.0, 4.0)
@export var slash_hitbox_size: Vector2 = Vector2(26.0, 22.0)
@export var slash_hitbox_offset: Vector2 = Vector2(16.0, 0.0)
@export var thrust_hitbox_size: Vector2 = Vector2(32.0, 10.0)
@export var thrust_hitbox_offset: Vector2 = Vector2(20.0, -7.0)
@export var shield_visual_forward_tip: float = 32.0
@export var slash_visual_forward_tip: float = 31.0
@export var thrust_visual_forward_tip: float = 41.0
@export var shield_bash_trigger_range: float = 37.0
@export var sword_slash_trigger_range: float = 40.0
@export var heavy_overhead_trigger_range: float = 40.0
@export_range(0.0, 1.0, 0.01) var shield_bash_selection_weight: float = 0.22
@export_range(0.0, 1.0, 0.01) var sword_slash_selection_weight: float = 0.43
@export_range(0.0, 1.0, 0.01) var heavy_overhead_selection_weight: float = 0.35
@export var shield_bash_repeat_cooldown: float = 2.70
@export var attack_selection_seed: int = 1977

@export_category("Cadence")
@export var shield_break_stun: float = 0.90
@export var phase_transition_duration: float = 1.10
@export var boss_turn_reaction_delay: float = 0.33
@export var boss_turn_animation_duration: float = 0.80
@export var boss_turn_cooldown: float = 0.14
@export_range(0.70, 1.0, 0.05) var boss_turn_facing_commit_ratio: float = 0.80
@export_range(0.0, 32.0, 1.0) var turn_side_threshold: float = 12.0
@export var attack_recovery: float = 0.42
@export_category("Post-attack gaps (active end to next windup)")
@export var shield_bash_attack_gap: float = 1.18
@export var sword_slash_attack_gap: float = 1.05
@export var heavy_overhead_attack_gap: float = 1.20
@export var combo_slash_attack_gap: float = 1.05
@export var charge_thrust_attack_gap: float = 1.12
@export var jump_smash_attack_gap: float = 1.16
@export var shockwave_strike_attack_gap: float = 1.10
@export_category("Gate Severance presentation")
@export var shockwave_visual_size: Vector2 = Vector2(80.0, 88.0)
@export var shockwave_collision_size: Vector2 = Vector2(34.0, 34.0)
@export var shockwave_base_collision_size: Vector2 = Vector2(78.0, 14.0)
@export var shockwave_core_collision_offset: Vector2 = Vector2(7.0, -25.0)
@export var shockwave_base_collision_offset: Vector2 = Vector2(2.0, -7.0)
@export var shockwave_spawn_offset: Vector2 = Vector2(52.0, 44.0)
@export var shockwave_travel_distance: float = 330.0
@export var shockwave_spawn_duration: float = 0.10
@export var shockwave_travel_duration: float = 0.78
@export var shockwave_dissipate_duration: float = 0.16
@export var shockwave_visual_fps: float = 12.0
@export_range(0.4, 0.65, 0.05) var post_attack_move_multiplier: float = 0.50
@export_category("Shield Bash authored timing")
@export var shield_bash_windup: float = 0.46
@export var shield_bash_active: float = 0.10
@export var shield_bash_recovery: float = 0.68
@export_category("Hit feedback")
@export var boss_light_hit_reaction_cooldown: float = 0.32
@export var boss_heavy_hit_reaction_cooldown: float = 0.50
@export var boss_heavy_hit_reaction_duration: float = 0.12
@export var shield_break_flash_duration: float = 0.07
@export_range(0.0, 1.0, 0.05) var shield_break_flash_alpha: float = 0.35
