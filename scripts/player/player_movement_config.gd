class_name PlayerMovementConfig
extends Resource

## M1-only movement tuning. Combat and dash values intentionally live elsewhere later.

@export var move_speed: float = 220.0
@export var ground_acceleration: float = 1400.0
@export var ground_deceleration: float = 1700.0
@export var air_acceleration: float = 850.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1100.0
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.12
@export_range(0.0, 1.0, 0.01) var input_deadzone: float = 0.10
