class_name PontiffStatusProjectile
extends Area2D

enum EffectKind { BURN, FREEZE }

@export var effect_kind: EffectKind = EffectKind.BURN
@export var speed: float = 240.0
@export var lifetime: float = 4.5
@export var impact_damage: int = 8
@export var status_duration: float = 3.0
@export var burn_tick_damage: int = 5
@export var burn_tick_interval: float = 1.0
@export var freeze_immunity_duration: float = 5.0

@onready var projectile_sprite: AnimatedSprite2D = $ProjectileSprite as AnimatedSprite2D
@onready var impact_sprite: AnimatedSprite2D = $ImpactSprite as AnimatedSprite2D
@onready var hitbox: HitboxComponent = $Hitbox as HitboxComponent

var _direction: float = 1.0
var _remaining: float = 0.0
var _resolved: bool = false
var _source_id: StringName = &""


func _ready() -> void:
	_remaining = lifetime
	body_entered.connect(_on_body_entered)
	hitbox.hit_confirmed.connect(_on_hit_confirmed)
	projectile_sprite.play(&"active")
	impact_sprite.visible = false


func initialize(direction: float, attack_id: int, owner_node: Node2D) -> void:
	_direction = signf(direction) if not is_zero_approx(direction) else 1.0
	_source_id = StringName("edran_magic_%d" % attack_id)
	scale.x = _direction
	hitbox.begin_attack(attack_id, impact_damage, _direction, owner_node)


func _physics_process(delta: float) -> void:
	if _resolved:
		return
	_remaining -= delta
	if _remaining <= 0.0:
		queue_free()
		return
	var motion: Vector2 = Vector2(_direction * speed * delta, 0.0)
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + motion,
		1
	)
	query.exclude = [get_rid()]
	var collision: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if not collision.is_empty():
		global_position = collision.position as Vector2
		_resolve_impact()
		return
	global_position += motion


func _on_hit_confirmed(target_hurtbox: HurtboxComponent, _damage: int, _attack_id: int) -> void:
	if _resolved or target_hurtbox == null:
		return
	var player: Player = target_hurtbox.get_parent() as Player
	if player != null and player.status_effect_controller != null:
		if effect_kind == EffectKind.BURN:
			player.status_effect_controller.apply_burn(
				_source_id, status_duration, burn_tick_damage, burn_tick_interval
			)
		else:
			player.status_effect_controller.apply_freeze(
				_source_id, status_duration, freeze_immunity_duration
			)
	_resolve_impact()


func _on_body_entered(body: Node2D) -> void:
	var collision_body: CollisionObject2D = body as CollisionObject2D
	if collision_body != null and collision_body.collision_layer & 1 != 0:
		_resolve_impact()


func _resolve_impact() -> void:
	if _resolved:
		return
	_resolved = true
	set_physics_process(false)
	set_deferred("monitoring", false)
	hitbox.end_attack()
	projectile_sprite.visible = false
	impact_sprite.visible = true
	impact_sprite.play(&"active")
	await get_tree().create_timer(0.34).timeout
	queue_free()
