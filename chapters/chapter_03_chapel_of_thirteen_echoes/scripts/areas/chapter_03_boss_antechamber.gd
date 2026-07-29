class_name Chapter03BossAntechamber
extends Node2D

signal checkpoint_activated(spawn_marker: Marker2D)

@onready var checkpoint_area: Area2D = $CheckpointArea as Area2D
@onready var checkpoint_marker: Marker2D = $CP_CH3_BOSS as Marker2D

var _activated: bool = false


func _ready() -> void:
	checkpoint_area.body_entered.connect(_on_checkpoint_body_entered)


func _on_checkpoint_body_entered(body: Node2D) -> void:
	if _activated or not body is Player:
		return
	_activated = true
	checkpoint_activated.emit(checkpoint_marker)
