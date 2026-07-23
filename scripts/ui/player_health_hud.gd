class_name PlayerHealthHud
extends Control

## Signal-driven player Health presentation. It never mutates Health gameplay state.

@export_node_path("HealthComponent") var health_component_path: NodePath = NodePath(
	"../../World/Player/HealthComponent"
)

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_value: Label = $HealthValue

var health_component: HealthComponent


func _ready() -> void:
	var initial_component: HealthComponent = get_node_or_null(
		health_component_path
	) as HealthComponent
	if initial_component == null:
		push_error("PlayerHealthHud requires a HealthComponent")
		_show_unbound_state()
		return
	bind_health_component(initial_component)


func _exit_tree() -> void:
	_disconnect_health_component()


func bind_health_component(component: HealthComponent) -> void:
	_disconnect_health_component()
	health_component = component
	if health_component == null:
		_show_unbound_state()
		return
	if not health_component.health_changed.is_connected(_on_health_changed):
		health_component.health_changed.connect(_on_health_changed)
	_on_health_changed(health_component.current_health, health_component.max_health)


func _disconnect_health_component() -> void:
	if health_component == null or not is_instance_valid(health_component):
		health_component = null
		return
	if health_component.health_changed.is_connected(_on_health_changed):
		health_component.health_changed.disconnect(_on_health_changed)
	health_component = null


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.min_value = 0.0
	health_bar.max_value = float(maximum)
	health_bar.value = float(current)
	health_value.text = "%03d / %03d" % [current, maximum]


func _show_unbound_state() -> void:
	health_bar.min_value = 0.0
	health_bar.max_value = 1.0
	health_bar.value = 0.0
	health_value.text = "--- / ---"
