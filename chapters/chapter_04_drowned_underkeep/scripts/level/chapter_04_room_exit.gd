class_name Chapter04RoomExit
extends Area2D

signal transition_requested(destination_room_id: StringName, destination_spawn_id: StringName)

@export var destination_room_id: StringName = &""
@export var destination_spawn_id: StringName = &"EntryWest"
@export var one_shot: bool = true

var _used: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is not Player or (_used and one_shot) or destination_room_id.is_empty():
		return
	_used = true
	transition_requested.emit(destination_room_id, destination_spawn_id)
