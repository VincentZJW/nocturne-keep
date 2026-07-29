class_name Chapter03Room
extends Node2D

signal transition_requested(destination_room_id: StringName, destination_spawn_id: StringName)
signal checkpoint_requested(checkpoint_id: StringName, spawn_marker: Marker2D)

@export var room_id: StringName = &""
@export var bilingual_name: String = ""
@export var room_size: Vector2i = Vector2i(1280, 720)
@export var default_spawn_id: StringName = &"EntryWest"
@export_node_path("Node2D") var spawn_points_path: NodePath = NodePath("SpawnPoints")

@onready var spawn_points: Node2D = get_node_or_null(spawn_points_path) as Node2D


func _ready() -> void:
	_apply_actor_layer_contract(self)
	for child: Node in find_children("*", "Chapter03RoomDoor", true, false):
		var door := child as Chapter03RoomDoor
		if door != null:
			door.transition_requested.connect(_on_transition_requested)
	for child: Node in find_children("*", "Chapter03RoomExit", true, false):
		var room_exit := child as Chapter03RoomExit
		if room_exit != null:
			room_exit.transition_requested.connect(_on_transition_requested)
	for child: Node in find_children("*", "Chapter03RoomCheckpoint", true, false):
		var checkpoint := child as Chapter03RoomCheckpoint
		if checkpoint != null:
			checkpoint.checkpoint_activated.connect(_on_checkpoint_activated)
	for child: Node in find_children("*", "Chapter03BossGate", true, false):
		var boss_gate := child as Chapter03BossGate
		if boss_gate != null:
			boss_gate.crossing_requested.connect(_on_boss_gate_crossing_requested)


func _apply_actor_layer_contract(root: Node) -> void:
	for child: Node in root.get_children():
		if child is EnemyCombatant:
			var enemy_canvas := child as CanvasItem
			enemy_canvas.z_index = Chapter03LayerContract.ENEMIES
			enemy_canvas.z_as_relative = true
		_apply_actor_layer_contract(child)


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


func _on_boss_gate_crossing_requested(_player: Player) -> void:
	transition_requested.emit(&"CH3_BOSS", &"EntryWest")
