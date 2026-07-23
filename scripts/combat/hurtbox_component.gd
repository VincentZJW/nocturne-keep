class_name HurtboxComponent
extends Area2D

## Receives hostile HitboxComponent contacts and forwards accepted damage to Health.

signal hit_received(damage: int, source_position: Vector2, attack_id: int)
signal enabled_changed(enabled: bool)
signal invulnerability_changed(invulnerable: bool)

@export var faction: StringName = &"neutral"
@export_node_path("HealthComponent") var health_component_path: NodePath = NodePath("../HealthComponent")
@export var start_enabled: bool = true

@onready var health_component: HealthComponent = get_node_or_null(
	health_component_path
) as HealthComponent

var is_enabled: bool = true
var is_invulnerable: bool = false


func _ready() -> void:
	monitoring = false
	if health_component == null:
		push_error("HurtboxComponent requires a HealthComponent at %s" % health_component_path)
		set_enabled(false)
		return
	set_enabled(start_enabled)


func receive_hit(hitbox: HitboxComponent) -> bool:
	if (
		not is_enabled
		or is_invulnerable
		or hitbox == null
		or not hitbox.is_active
		or hitbox.faction == faction
		or health_component == null
		or health_component.is_dead()
	):
		return false
	var health_before: int = health_component.current_health
	health_component.take_damage(hitbox.damage)
	if health_component.current_health >= health_before:
		return false
	hit_received.emit(hitbox.damage, hitbox.global_position, hitbox.attack_id)
	return true


func set_enabled(enabled: bool) -> void:
	var changed: bool = is_enabled != enabled or monitorable != enabled
	is_enabled = enabled
	# PhysicsServer forbids a synchronous monitorable change while an Area2D
	# enter/exit signal is being dispatched. The logical flag changes now so
	# late contacts are rejected; only the server-backed property is deferred.
	set_deferred("monitorable", enabled)
	for child: Node in get_children():
		var collision_shape: CollisionShape2D = child as CollisionShape2D
		if collision_shape != null:
			collision_shape.set_deferred("disabled", not enabled)
	if changed:
		enabled_changed.emit(enabled)


func set_invulnerable(invulnerable: bool) -> void:
	if is_invulnerable == invulnerable:
		return
	is_invulnerable = invulnerable
	invulnerability_changed.emit(invulnerable)
