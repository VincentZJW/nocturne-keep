class_name HollowDuchessTestRoom
extends Node2D

@onready var player: Player = $Player as Player
@onready var boss: HollowDuchess = $HollowDuchess as HollowDuchess
@onready var status: Label = $HUD/Status as Label


func _ready() -> void:
	var equipment: PlayerEquipmentManager = get_node_or_null("/root/EquipmentManager") as PlayerEquipmentManager
	if equipment != null:
		equipment.acquire_and_equip(&"ravenfang_daggers")
	boss.activate(player, true)


func _process(_delta: float) -> void:
	status.text = boss.get_debug_status()
