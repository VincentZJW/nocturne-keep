class_name ShieldBlockComponent
extends EnemyHitPolicyComponent

## Directional shield policy for normal Attack block and Dash Attack guard break.

signal block_successful(hitbox: HitboxComponent)
signal guard_broken(hitbox: HitboxComponent)
signal shield_broken_changed(broken: bool)

@export_node_path("Node2D") var body_path: NodePath = NodePath("..")
@export_node_path("Node2D") var facing_root_path: NodePath = NodePath("../FacingRoot")

@onready var body: Node2D = get_node_or_null(body_path) as Node2D
@onready var facing_root: Node2D = get_node_or_null(facing_root_path) as Node2D

var is_blocking: bool = true
var shield_broken: bool = false


func resolve_damage(hitbox: HitboxComponent) -> int:
	if (
		hitbox == null
		or shield_broken
		or not is_blocking
		or not _is_source_in_front(hitbox.global_position)
	):
		return hitbox.damage if hitbox != null else 0
	if hitbox.attack_kind == &"dash_attack":
		break_shield()
		guard_broken.emit(hitbox)
		return 0
	if hitbox.attack_kind == &"normal_attack":
		block_successful.emit(hitbox)
		return 0
	return hitbox.damage


func set_blocking(enabled: bool) -> void:
	is_blocking = enabled and not shield_broken


func break_shield() -> bool:
	if shield_broken:
		return false
	shield_broken = true
	is_blocking = false
	shield_broken_changed.emit(true)
	return true


func is_shield_broken() -> bool:
	return shield_broken


func _is_source_in_front(source_position: Vector2) -> bool:
	if body == null or facing_root == null:
		return false
	var source_offset: float = source_position.x - body.global_position.x
	if is_zero_approx(source_offset):
		return true
	return signf(source_offset) == signf(facing_root.scale.x)
