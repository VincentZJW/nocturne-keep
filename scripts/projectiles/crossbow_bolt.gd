class_name CrossbowBolt
extends Area2D

## Collision-safe horizontal bolt. World raycast prevents thin-wall tunneling.

signal projectile_expired

@export_node_path("HitboxComponent") var hitbox_path: NodePath = NodePath("Hitbox")

@onready var hitbox: HitboxComponent = get_node_or_null(hitbox_path) as HitboxComponent

var direction: float = 1.0
var speed: float = 260.0
var lifetime_remaining: float = 3.0
var has_resolved: bool = false


func _ready() -> void:
	if hitbox == null:
		push_error("CrossbowBolt requires Hitbox")
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	hitbox.hit_confirmed.connect(_on_hit_confirmed)


func initialize(
	travel_direction: float,
	travel_speed: float,
	damage: int,
	lifetime: float
) -> void:
	direction = -1.0 if travel_direction < 0.0 else 1.0
	speed = travel_speed
	lifetime_remaining = lifetime
	scale.x = direction
	if hitbox != null:
		hitbox.damage = damage
		hitbox.begin_attack(get_instance_id(), damage)


func _physics_process(delta: float) -> void:
	if has_resolved:
		return
	lifetime_remaining = maxf(0.0, lifetime_remaining - delta)
	if lifetime_remaining <= 0.0:
		_resolve()
		return
	var start_position: Vector2 = global_position
	var end_position: Vector2 = start_position + Vector2(direction * speed * delta, 0.0)
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		start_position, end_position, 1
	)
	query.exclude = [get_rid()]
	var world_hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if not world_hit.is_empty():
		global_position = world_hit["position"] as Vector2
		_resolve()
		return
	global_position = end_position


func _on_body_entered(body: Node2D) -> void:
	if body is StaticBody2D or body is TileMapLayer:
		_resolve()


func _on_hit_confirmed(
	_target: HurtboxComponent,
	_damage: int,
	_attack_id: int
) -> void:
	_resolve()


func _resolve() -> void:
	if has_resolved:
		return
	has_resolved = true
	if hitbox != null:
		hitbox.end_attack()
	projectile_expired.emit()
	queue_free()
