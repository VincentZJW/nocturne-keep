class_name BloodCandleEmber
extends Area2D

## Short-lived ground hazard. Hitbox dedup makes one ember one hit per Player.

@export_node_path("HitboxComponent") var hitbox_path: NodePath = NodePath("Hitbox")
@onready var hitbox: HitboxComponent = get_node_or_null(hitbox_path) as HitboxComponent

var lifetime_remaining: float = 0.65


func _ready() -> void:
	if hitbox == null:
		push_error("BloodCandleEmber requires Hitbox")
		queue_free()


func initialize(damage: int, lifetime: float) -> void:
	lifetime_remaining = lifetime
	if hitbox != null:
		hitbox.begin_attack(get_instance_id(), damage, 0.0, self)


func _physics_process(delta: float) -> void:
	lifetime_remaining = maxf(0.0, lifetime_remaining - delta)
	if lifetime_remaining > 0.0:
		return
	if hitbox != null:
		hitbox.end_attack()
	queue_free()
