class_name PlayerStatusHud
extends Control

## Signal-driven compact status presentation beside the formal Player vitals.

@export_node_path("PlayerStatusEffectController") var status_controller_path: NodePath = NodePath(
	"../../Player/StatusEffectController"
)

@onready var status_controller: PlayerStatusEffectController = get_node_or_null(
	status_controller_path
) as PlayerStatusEffectController
@onready var burn_slot: Control = $Burn
@onready var burn_time: Label = $Burn/Time
@onready var freeze_slot: Control = $Freeze
@onready var freeze_time: Label = $Freeze/Time
@onready var mire_slot: Control = $Mire
@onready var mire_time: Label = $Mire/Time


func _ready() -> void:
	if status_controller == null:
		push_error("PlayerStatusHud requires a PlayerStatusEffectController")
		visible = false
		return
	status_controller.status_changed.connect(_on_status_changed)
	status_controller.status_expired.connect(_on_status_expired)
	status_controller.all_statuses_cleared.connect(_on_all_statuses_cleared)
	_on_all_statuses_cleared()


func _on_status_changed(effect_id: StringName, remaining: float, _duration: float) -> void:
	match effect_id:
		PlayerStatusEffectController.BURN:
			_set_slot(burn_slot, burn_time, remaining)
		PlayerStatusEffectController.FREEZE:
			_set_slot(freeze_slot, freeze_time, remaining)
		PlayerStatusEffectController.MIRE_SLOW:
			_set_slot(mire_slot, mire_time, remaining)
	_update_visibility()


func _on_status_expired(effect_id: StringName) -> void:
	match effect_id:
		PlayerStatusEffectController.BURN: burn_slot.visible = false
		PlayerStatusEffectController.FREEZE: freeze_slot.visible = false
		PlayerStatusEffectController.MIRE_SLOW: mire_slot.visible = false
	_update_visibility()


func _on_all_statuses_cleared() -> void:
	burn_slot.visible = false
	freeze_slot.visible = false
	mire_slot.visible = false
	visible = false


func _set_slot(slot: Control, label: Label, remaining: float) -> void:
	slot.visible = remaining > 0.0
	label.text = "%.1f" % remaining


func _update_visibility() -> void:
	visible = burn_slot.visible or freeze_slot.visible or mire_slot.visible
