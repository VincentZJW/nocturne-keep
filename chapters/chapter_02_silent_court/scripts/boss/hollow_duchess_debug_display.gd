class_name HollowDuchessDebugDisplay
extends Label

@export_node_path("HollowDuchess") var boss_path: NodePath
@export_range(0.05, 1.0, 0.05) var refresh_interval: float = 0.15

@onready var boss: HollowDuchess = get_node_or_null(boss_path) as HollowDuchess

var _remaining: float = 0.0


func _ready() -> void:
	visible = OS.is_debug_build()
	if boss == null:
		text = "DUCHESS DEBUG · unavailable"


func _process(delta: float) -> void:
	if not visible or boss == null:
		return
	_remaining -= delta
	if _remaining > 0.0:
		return
	_remaining = refresh_interval
	text = boss.get_debug_status()
