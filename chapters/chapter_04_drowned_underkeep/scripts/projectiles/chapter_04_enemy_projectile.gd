class_name Chapter04EnemyProjectile
extends Area2D

@export_node_path("HitboxComponent") var hitbox_path: NodePath = NodePath("Hitbox")
@export var lifetime: float = 2.8

@onready var hitbox: HitboxComponent = get_node_or_null(hitbox_path) as HitboxComponent

var velocity: Vector2 = Vector2.ZERO
var _remaining_lifetime: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_remaining_lifetime = lifetime
	add_to_group("chapter_04_enemy_projectile")


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	_remaining_lifetime -= delta
	if _remaining_lifetime <= 0.0:
		queue_free()


func launch(
	direction: Vector2,
	speed: float,
	damage: int,
	attack_id: int,
	source: Node2D,
	attack_kind: StringName
) -> void:
	velocity = direction.normalized() * speed
	rotation = velocity.angle()
	_remaining_lifetime = lifetime
	if hitbox != null:
		hitbox.attack_kind = StringName("enemy_%s" % attack_kind)
		hitbox.begin_attack(attack_id, damage, signf(direction.x), source)


func _on_body_entered(body: Node2D) -> void:
	if body == null or body is Player:
		return
	queue_free()
