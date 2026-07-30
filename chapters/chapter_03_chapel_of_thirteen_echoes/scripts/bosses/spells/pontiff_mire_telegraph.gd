class_name PontiffMireTelegraph
extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D as AnimatedSprite2D

var locked: bool = false


func _ready() -> void:
	animated_sprite.play(&"active")


func follow_target(target_position: Vector2) -> void:
	if not locked:
		global_position = target_position


func lock_target() -> void:
	locked = true


func finish() -> void:
	queue_free()
