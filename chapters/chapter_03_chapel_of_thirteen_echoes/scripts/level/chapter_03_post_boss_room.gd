class_name Chapter03PostBossRoom
extends Chapter03Room

@onready var reliquary: Chapter03PostBossReliquary = (
	$PostBossReliquary as Chapter03PostBossReliquary
)
@onready var underkeep_exit: Chapter03RoomExit = $UnderkeepExit as Chapter03RoomExit


func _ready() -> void:
	super._ready()
	underkeep_exit.set_deferred("monitoring", false)
	reliquary.descent_unlocked.connect(_on_descent_unlocked)
	reliquary.reveal_after_boss()


func _on_descent_unlocked() -> void:
	underkeep_exit.set_deferred("monitoring", true)
