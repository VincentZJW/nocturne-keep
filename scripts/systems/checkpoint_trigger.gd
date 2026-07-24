class_name CheckpointTrigger
extends Area2D

## One-shot, scene-local checkpoint that updates the existing respawn service.

signal checkpoint_activated(checkpoint_id: StringName, world_position: Vector2)

@export var checkpoint_id: StringName = &"checkpoint"
@export_node_path("Marker2D") var spawn_marker_path: NodePath = NodePath("SpawnMarker")
@export_node_path("PlayerRespawnController") var respawn_controller_path: NodePath

@onready var spawn_marker: Marker2D = get_node_or_null(spawn_marker_path) as Marker2D
@onready var respawn_controller: PlayerRespawnController = get_node_or_null(
	respawn_controller_path
) as PlayerRespawnController

var is_activated: bool = false


func _ready() -> void:
	if spawn_marker == null or respawn_controller == null:
		push_error("CheckpointTrigger requires SpawnMarker and PlayerRespawnController")
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_activated or not body is Player:
		return
	is_activated = respawn_controller.set_spawn_point(spawn_marker)
	if is_activated:
		set_deferred("monitoring", false)
		checkpoint_activated.emit(checkpoint_id, spawn_marker.global_position)
