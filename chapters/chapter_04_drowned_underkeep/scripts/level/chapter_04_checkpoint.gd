class_name Chapter04Checkpoint
extends Area2D

signal checkpoint_activated(checkpoint_id: StringName, spawn_marker: Marker2D)

@export var checkpoint_id: StringName = &""
@export_node_path("Marker2D") var spawn_marker_path: NodePath = NodePath("SpawnMarker")

var _activated: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _activated or body is not Player or checkpoint_id.is_empty():
		return
	var marker: Marker2D = get_node_or_null(spawn_marker_path) as Marker2D
	if marker == null:
		push_error("Chapter04Checkpoint requires a SpawnMarker")
		return
	_activated = true
	checkpoint_activated.emit(checkpoint_id, marker)
