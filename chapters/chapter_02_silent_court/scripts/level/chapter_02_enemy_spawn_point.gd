class_name Chapter02EnemySpawnPoint
extends Marker2D

## Authored Chapter II encounter spawn. Platform bounds are global X limits and
## constrain ordinary AI movement without preventing combat knockback falls.

enum Placement {
	GROUND,
	PLATFORM,
	CEILING_AIR,
}

@export var encounter_id: StringName
@export_range(1, 3, 1) var floor_number: int = 1
@export var activation_center: Vector2
@export_range(120.0, 900.0, 10.0) var activation_range_x: float = 720.0
@export var enemy_scene: PackedScene
@export var enemy_role: StringName
@export var placement: Placement = Placement.GROUND
@export var platform_left_bound: float = 0.0
@export var platform_right_bound: float = 0.0
@export var drop_down_allowed: bool = false
@export var chase_off_platform_allowed: bool = false


func is_valid_spawn() -> bool:
	return (
		not encounter_id.is_empty()
		and enemy_scene != null
		and not enemy_role.is_empty()
		and (
			placement == Placement.CEILING_AIR
			or platform_right_bound > platform_left_bound
		)
	)


func is_airborne() -> bool:
	return placement == Placement.CEILING_AIR


func uses_bounded_movement() -> bool:
	return (
		placement != Placement.CEILING_AIR
		and not chase_off_platform_allowed
		and platform_right_bound > platform_left_bound
	)
