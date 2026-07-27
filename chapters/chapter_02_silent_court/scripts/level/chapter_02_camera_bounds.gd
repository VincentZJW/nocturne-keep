class_name Chapter02CameraBounds
extends Area2D

signal player_entered(room_id: StringName, vertical_limits: Vector2i)

@export var room_id: StringName = &""
@export var vertical_limits: Vector2i = Vector2i(0, 720)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var room_offset_y: int = int(round(get_parent().global_position.y))
		player_entered.emit(
			room_id,
			Vector2i(vertical_limits.x + room_offset_y, vertical_limits.y + room_offset_y)
		)
