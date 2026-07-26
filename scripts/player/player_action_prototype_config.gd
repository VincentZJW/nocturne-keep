class_name PlayerActionPrototypeConfig
extends Resource

## M1.5-only action timing. This resource contains no combat or invulnerability data.

@export var dash_speed: float = 480.0
@export var dash_duration: float = 0.18
@export var dash_input_buffer_time: float = 0.10
@export var dash_min_interval: float = 0.03
@export var dash_attack_input_window: float = 0.18
@export_range(1, 3, 1) var maximum_normal_combo: int = 3
@export var attack_buffer_time: float = 0.08
@export var attack_chain_window_start: float = 0.10
@export var attack_chain_window_end: float = 0.20
@export var minimum_attack_interval: float = 0.32
@export var attack_chain_recovery_duration: float = 0.12
@export var combo_end_recovery: float = 0.34
@export var dash_attack_speed: float = 320.0
@export var dash_attack_move_duration: float = 0.15
@export var dash_attack_recovery_duration: float = 0.10
