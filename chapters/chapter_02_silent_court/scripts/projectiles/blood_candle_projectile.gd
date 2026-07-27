class_name BloodCandleProjectile
extends Area2D

## Slow, straight, direction-locked projectile. World impact leaves one short ember.

@export_node_path("HitboxComponent") var hitbox_path: NodePath = NodePath("Hitbox")
@export var ember_scene: PackedScene

@onready var hitbox: HitboxComponent = get_node_or_null(hitbox_path) as HitboxComponent

var direction: float = 1.0
var speed: float = 180.0
var lifetime_remaining: float = 2.4
var ember_damage: int = 4
var ember_lifetime: float = 0.65
var resolved: bool = false


func _ready() -> void:
	if hitbox == null:
		push_error("BloodCandleProjectile requires Hitbox")
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	hitbox.hit_confirmed.connect(_on_hit_confirmed)


func initialize(
	travel_direction: float,
	travel_speed: float,
	damage: int,
	lifetime: float,
	ground_ember_damage: int,
	ground_ember_lifetime: float
) -> void:
	direction = -1.0 if travel_direction < 0.0 else 1.0
	speed = travel_speed
	lifetime_remaining = lifetime
	ember_damage = ground_ember_damage
	ember_lifetime = ground_ember_lifetime
	scale.x = direction
	if hitbox != null:
		hitbox.begin_attack(get_instance_id(), damage, direction, self)


func _physics_process(delta: float) -> void:
	if resolved:
		return
	lifetime_remaining = maxf(0.0, lifetime_remaining - delta)
	if lifetime_remaining <= 0.0:
		_resolve(false)
		return
	var start: Vector2 = global_position
	var finish: Vector2 = start + Vector2(direction * speed * delta, 0.0)
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(start, finish, 1)
	query.exclude = [get_rid()]
	var collision: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if not collision.is_empty():
		global_position = collision["position"] as Vector2
		_resolve(true)
		return
	global_position = finish


func _on_body_entered(body: Node2D) -> void:
	if body is StaticBody2D or body is TileMapLayer:
		_resolve(true)


func _on_hit_confirmed(_target: HurtboxComponent, _damage: int, _attack_id: int) -> void:
	_resolve(false)


func _resolve(spawn_ember: bool) -> void:
	if resolved:
		return
	resolved = true
	hitbox.end_attack()
	if spawn_ember and ember_scene != null and get_parent() != null:
		var ember: BloodCandleEmber = ember_scene.instantiate() as BloodCandleEmber
		if ember != null:
			get_parent().add_child(ember)
			ember.global_position = global_position + Vector2(0.0, -5.0)
			ember.initialize(ember_damage, ember_lifetime)
	queue_free()
