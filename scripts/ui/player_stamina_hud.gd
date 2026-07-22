class_name PlayerStaminaHud
extends CanvasLayer

## Signal-driven stamina presentation. It never mutates stamina gameplay state.

@export_node_path("PlayerStaminaComponent") var stamina_component_path: NodePath = NodePath("../World/Player/StaminaComponent")

@onready var stamina_component: PlayerStaminaComponent = get_node_or_null(
	stamina_component_path
) as PlayerStaminaComponent
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var stamina_value: Label = %StaminaValue
@onready var stamina_container: Control = %StaminaContainer

var _feedback_tween: Tween


func _ready() -> void:
	if stamina_component == null:
		push_error("PlayerStaminaHud requires a PlayerStaminaComponent")
		return
	stamina_component.stamina_changed.connect(_on_stamina_changed)
	stamina_component.stamina_insufficient.connect(_on_stamina_insufficient)
	_on_stamina_changed(stamina_component.current_stamina, stamina_component.max_stamina)


func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.min_value = 0.0
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	stamina_value.text = "%03d / %03d" % [roundi(current), roundi(maximum)]


func _on_stamina_insufficient() -> void:
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()
	stamina_container.position = Vector2.ZERO
	stamina_container.modulate = Color("e18a63")
	_feedback_tween = create_tween()
	_feedback_tween.tween_property(stamina_container, "position:x", 3.0, 0.035)
	_feedback_tween.tween_property(stamina_container, "position:x", -3.0, 0.035)
	_feedback_tween.tween_property(stamina_container, "position:x", 0.0, 0.035)
	_feedback_tween.parallel().tween_property(
		stamina_container, "modulate", Color.WHITE, 0.12
	)
