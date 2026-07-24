class_name ShieldComponent
extends EnemyHitPolicyComponent

## Owns Shield Guard durability and routes one incoming hit to shield or body.

signal shield_health_changed(current: int, maximum: int)
signal shield_hit(hitbox: HitboxComponent, applied_damage: int, remaining: int)
signal shield_broken(hitbox: HitboxComponent)

const SIDE_FRONT: StringName = &"front"
const SIDE_BACK: StringName = &"back"
const SIDE_BODY: StringName = &"body"

@export_range(1, 99, 1) var shield_max_health: int = 3
@export_range(0.0, 16.0, 1.0) var center_tolerance: float = 8.0
@export_node_path("Node2D") var body_path: NodePath = NodePath("..")
@export_node_path("Node2D") var facing_root_path: NodePath = NodePath("../FacingRoot")

@onready var body: Node2D = get_node_or_null(body_path) as Node2D
@onready var facing_root: Node2D = get_node_or_null(facing_root_path) as Node2D

var shield_current_health: int = 0
var last_attack_kind: StringName = &"none"
var last_attack_id: int = 0
var last_attacker_faction: StringName = &"none"
var last_source_position: Vector2 = Vector2.ZERO
var last_attack_direction: float = 0.0
var last_hit_side: StringName = &"none"
var last_shield_damage: int = 0
var last_body_damage: int = 0
var last_overflow_discarded: int = 0

var _shield_broken: bool = false


func _ready() -> void:
	if body == null or facing_root == null:
		push_error("ShieldComponent requires body and facing root")
	shield_max_health = maxi(1, shield_max_health)
	reset_shield()


func resolve_damage(hitbox: HitboxComponent) -> int:
	_reset_last_resolution(hitbox)
	if hitbox == null:
		return 0
	last_hit_side = classify_source_side(hitbox.global_position)
	if _shield_broken or last_hit_side != SIDE_FRONT or not _is_player_weapon_attack(hitbox):
		last_body_damage = hitbox.damage
		return hitbox.damage
	take_shield_damage(hitbox.damage, hitbox)
	return 0


func take_shield_damage(amount: int, hitbox: HitboxComponent) -> int:
	if amount <= 0 or _shield_broken:
		return 0
	var before: int = shield_current_health
	var applied_damage: int = mini(amount, before)
	last_shield_damage = applied_damage
	last_overflow_discarded = maxi(0, amount - before)
	shield_current_health = clampi(before - amount, 0, shield_max_health)
	shield_health_changed.emit(shield_current_health, shield_max_health)
	shield_hit.emit(hitbox, applied_damage, shield_current_health)
	if shield_current_health == 0:
		_shield_broken = true
		shield_broken.emit(hitbox)
	return applied_damage


func reset_shield() -> void:
	shield_max_health = maxi(1, shield_max_health)
	shield_current_health = shield_max_health
	_shield_broken = false
	_reset_last_resolution(null)
	shield_health_changed.emit(shield_current_health, shield_max_health)


func is_shield_broken() -> bool:
	return _shield_broken


func classify_source_side(source_position: Vector2) -> StringName:
	if body == null or facing_root == null:
		return SIDE_BODY
	var source_offset: float = source_position.x - body.global_position.x
	if absf(source_offset) <= center_tolerance:
		return SIDE_BODY
	return (
		SIDE_FRONT
		if signf(source_offset) == signf(facing_root.scale.x)
		else SIDE_BACK
	)


func get_visual_state() -> StringName:
	if _shield_broken or shield_current_health <= 0:
		return &"broken"
	if shield_current_health == 1:
		return &"critical"
	if shield_current_health < shield_max_health:
		return &"cracked"
	return &"intact"


func _is_player_weapon_attack(hitbox: HitboxComponent) -> bool:
	return hitbox.attack_kind == &"normal_attack" or hitbox.attack_kind == &"dash_attack"


func _reset_last_resolution(hitbox: HitboxComponent) -> void:
	last_attack_kind = hitbox.attack_kind if hitbox != null else &"none"
	last_attack_id = hitbox.attack_id if hitbox != null else 0
	last_attacker_faction = hitbox.faction if hitbox != null else &"none"
	last_source_position = hitbox.global_position if hitbox != null else Vector2.ZERO
	last_attack_direction = hitbox.attack_direction if hitbox != null else 0.0
	last_hit_side = &"none"
	last_shield_damage = 0
	last_body_damage = 0
	last_overflow_discarded = 0
