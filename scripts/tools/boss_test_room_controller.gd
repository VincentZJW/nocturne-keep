extends Node2D

## Minimal manual Boss sandbox; configured Main remains the acceptance scene.

@onready var player: Player = $Player
@onready var boss: FallenGateKnight = $FallenGateKnight


func _ready() -> void:
	boss.activate(player)
