class_name SoulGaolerOrmundConfig
extends EnemyGroundConfig

@export_category("Shared encounter")
@export_range(1, 1000, 1) var total_health: int = 560
@export_range(0.1, 0.9, 0.01) var phase_two_threshold_ratio: float = 0.55
@export var phase_transition_duration: float = 9.230769

@export_category("Phase I")
@export_range(0.1, 1.0, 0.01) var phase_one_damage_multiplier: float = 0.82
@export_range(1, 400, 1) var phase_one_poise: int = 150
@export var phase_one_stagger_duration: float = 0.48
@export var phase_one_stagger_protection: float = 3.4

@export_category("Phase II")
@export_range(0.1, 1.0, 0.01) var phase_two_damage_multiplier: float = 0.72
@export_range(1, 400, 1) var phase_two_poise: int = 190
@export var phase_two_stagger_duration: float = 0.38
@export var phase_two_stagger_protection: float = 4.0

@export_category("P1 actions")
@export var halberd_sweep_damage: int = 18
@export var anchor_slam_damage: int = 22
@export var hook_drag_damage: int = 15
@export var floodgate_charge_damage: int = 19
@export var soul_cage_pulse_damage: int = 14

@export_category("P2 actions")
@export var chainstorm_cleave_damage: int = 21
@export var undertow_pull_damage: int = 17
@export var cell_rupture_damage: int = 23
@export var soul_shackle_damage: int = 16
@export var flooded_judgment_damage: int = 25
@export var judgment_cooldown: float = 6.5
