class_name Chapter03RoomCheckpoint
extends Area2D

signal checkpoint_activated(checkpoint_id: StringName, spawn_marker: Marker2D)

@export var checkpoint_id: StringName = &"CH3_BOSS_CHECKPOINT"
@export_node_path("Marker2D") var spawn_marker_path: NodePath
@export_node_path("Label") var status_label_path: NodePath
@export_node_path("CanvasItem") var visual_path: NodePath

@onready var spawn_marker: Marker2D = get_node_or_null(spawn_marker_path) as Marker2D
@onready var status_label: Label = get_node_or_null(status_label_path) as Label
@onready var visual: CanvasItem = get_node_or_null(visual_path) as CanvasItem

var is_activated: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if status_label != null:
		status_label.visible = false


func _on_body_entered(body: Node2D) -> void:
	if is_activated or body is not Player or spawn_marker == null:
		return
	is_activated = true
	set_deferred("monitoring", false)
	if status_label != null:
		status_label.visible = true
		status_label.modulate.a = 0.0
		var label_tween: Tween = create_tween()
		label_tween.tween_property(status_label, "modulate:a", 1.0, 0.12)
		label_tween.tween_interval(1.15)
		label_tween.tween_property(status_label, "modulate:a", 0.0, 0.24)
		label_tween.tween_callback(func() -> void: status_label.visible = false)
	if visual != null:
		var pulse: Tween = create_tween()
		pulse.tween_property(visual, "modulate", Color(1.25, 1.15, 0.82, 1.0), 0.10)
		pulse.tween_property(visual, "modulate", Color.WHITE, 0.32)
	checkpoint_activated.emit(checkpoint_id, spawn_marker)
