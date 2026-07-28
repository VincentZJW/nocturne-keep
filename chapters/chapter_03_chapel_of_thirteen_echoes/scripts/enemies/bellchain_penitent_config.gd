class_name BellchainPenitentConfig
extends EnemyGroundConfig

## Phase 2A tuning for the first Chapter III combatant.

@export_category("Bellchain vitals")
@export_range(1, 200, 1) var max_poise: int = 32
@export_range(1, 99, 1) var normal_attack_poise_damage: int = 14
@export_range(1, 99, 1) var dash_attack_poise_damage: int = 28
@export var stagger_duration: float = 0.56
@export var poise_recovery_delay: float = 1.20

@export_category("Bell slam")
@export_range(1, 100, 1) var bell_slam_damage: int = 13
@export var bell_slam_range: float = 38.0
@export var bell_slam_windup: float = 0.62
@export var bell_slam_active_duration: float = 0.14
@export var bell_slam_recovery: float = 0.76

@export_category("Short chain pull")
@export_range(1, 100, 1) var chain_pull_damage: int = 8
@export var chain_pull_min_range: float = 50.0
@export var chain_pull_max_range: float = 82.0
@export var chain_pull_windup: float = 0.48
@export var chain_pull_active_duration: float = 0.10
@export var chain_pull_recovery: float = 0.60
@export var chain_pull_cooldown: float = 3.0
@export var chain_pull_speed: float = 100.0

@export_category("Readability")
@export var alert_duration: float = 0.24
@export var turn_duration: float = 0.24
@export var light_hit_duration: float = 0.16
