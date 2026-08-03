class_name Chapter04Room
extends Node2D

const LAYER_CONTRACT: Script = preload("res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_layer_contract.gd")
const ROOM_EXIT_SCRIPT: Script = preload("res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_room_exit.gd")
const CHECKPOINT_SCRIPT: Script = preload("res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_checkpoint.gd")

signal transition_requested(destination_room_id: StringName, destination_spawn_id: StringName)
signal checkpoint_requested(checkpoint_id: StringName, spawn_marker: Marker2D)

@export var room_id: StringName = &""
@export var room_index: int = 0
@export var bilingual_name: String = ""
@export var room_size: Vector2i = Vector2i(1920, 720)
@export var room_function: StringName = &"combat"
@export var default_spawn_id: StringName = &"EntryWest"
@export_node_path("Node2D") var spawn_points_path: NodePath = NodePath("SpawnPoints")

@onready var spawn_points: Node2D = get_node_or_null(spawn_points_path) as Node2D


func _ready() -> void:
	for child: Node in find_children("*", "Chapter04RoomExit", true, false):
		if child.get_script() == ROOM_EXIT_SCRIPT:
			child.connect("transition_requested", _on_transition_requested)
	for child: Node in find_children("*", "Chapter04Checkpoint", true, false):
		if child.get_script() == CHECKPOINT_SCRIPT:
			child.connect("checkpoint_activated", _on_checkpoint_activated)
	for child: Node in find_children("*", "EnemyCombatant", true, false):
		var enemy: EnemyCombatant = child as EnemyCombatant
		if enemy != null:
			enemy.z_index = LAYER_CONTRACT.ENEMIES
			enemy.z_as_relative = true


func get_spawn(spawn_id: StringName) -> Marker2D:
	if spawn_points == null:
		return null
	var selected_id: StringName = spawn_id if not spawn_id.is_empty() else default_spawn_id
	var marker: Marker2D = spawn_points.get_node_or_null(NodePath(String(selected_id))) as Marker2D
	if marker == null:
		marker = spawn_points.get_node_or_null(NodePath(String(default_spawn_id))) as Marker2D
	return marker


func _on_transition_requested(destination_room_id: StringName, destination_spawn_id: StringName) -> void:
	transition_requested.emit(destination_room_id, destination_spawn_id)


func _on_checkpoint_activated(checkpoint_id: StringName, spawn_marker: Marker2D) -> void:
	checkpoint_requested.emit(checkpoint_id, spawn_marker)
