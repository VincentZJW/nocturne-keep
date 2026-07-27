class_name Chapter02FloorTransition
extends Area2D

## One-way Chapter II floor-change trigger. The controller owns fading and relocation.

signal transition_requested(transition: Chapter02FloorTransition)

@export var transition_id: StringName
@export var destination_spawn_id: StringName


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		transition_requested.emit(self)
