class_name PlayerDeathTestButton
extends Button

## Development-only manual damage trigger for PLAYER-DEATH-001 acceptance.

@export_range(1, 9999, 1) var damage_amount: int = 25
@export_node_path("HealthComponent") var health_component_path: NodePath = NodePath(
	"../../World/Player/HealthComponent"
)


func _ready() -> void:
	pressed.connect(_apply_test_damage)


func _apply_test_damage() -> void:
	var health_component: HealthComponent = get_node_or_null(
		health_component_path
	) as HealthComponent
	if health_component == null:
		push_error("PlayerDeathTestButton requires a HealthComponent")
		return
	health_component.take_damage(damage_amount)
