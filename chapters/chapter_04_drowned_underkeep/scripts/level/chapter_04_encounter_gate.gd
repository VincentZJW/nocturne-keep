class_name Chapter04EncounterGate
extends Node2D

## Unlocks a formal room exit only after every encounter in that room clears.

signal gate_unlocked

@export_node_path("Chapter04EncounterSpawner") var encounter_spawner_path: NodePath
@export_node_path("Chapter04RoomExit") var exit_path: NodePath
@export_node_path("CollisionShape2D") var blocker_shape_path: NodePath
@export_node_path("CanvasItem") var closed_visual_path: NodePath
@export_node_path("CanvasItem") var open_visual_path: NodePath

@onready var encounter_spawner: Chapter04EncounterSpawner = (
	get_node(encounter_spawner_path) as Chapter04EncounterSpawner
)
@onready var room_exit: Chapter04RoomExit = get_node(exit_path) as Chapter04RoomExit
@onready var blocker_shape: CollisionShape2D = get_node(blocker_shape_path) as CollisionShape2D
@onready var closed_visual: CanvasItem = get_node(closed_visual_path) as CanvasItem
@onready var open_visual: CanvasItem = get_node(open_visual_path) as CanvasItem

var locked: bool = true


func _ready() -> void:
	room_exit.set_locked(true)
	_set_visual_state(true)
	call_deferred("_bind_encounters")


func _bind_encounters() -> void:
	var groups: Array[EncounterGroup] = encounter_spawner.get_encounter_groups()
	if groups.is_empty():
		unlock()
		return
	for group: EncounterGroup in groups:
		if not group.encounter_cleared.is_connected(_on_encounter_cleared):
			group.encounter_cleared.connect(_on_encounter_cleared)
	_check_all_cleared()


func unlock() -> void:
	if not locked:
		return
	locked = false
	room_exit.set_locked(false)
	blocker_shape.set_deferred("disabled", true)
	_set_visual_state(false)
	gate_unlocked.emit()


func is_locked() -> bool:
	return locked


func _on_encounter_cleared(_encounter_id: StringName) -> void:
	_check_all_cleared()


func _check_all_cleared() -> void:
	for group: EncounterGroup in encounter_spawner.get_encounter_groups():
		if not group.is_cleared:
			return
	unlock()


func _set_visual_state(is_closed: bool) -> void:
	closed_visual.visible = is_closed
	open_visual.visible = not is_closed
