class_name Chapter04BossGateController
extends Node2D

@export_node_path("Chapter04RoomExit") var exit_path: NodePath = NodePath("../Transitions/ExitEast")
@export_node_path("StaticBody2D") var blocker_path: NodePath = NodePath("GateBlocker")
@export_node_path("Sprite2D") var left_panel_path: NodePath = NodePath("LeftPanel")
@export_node_path("Sprite2D") var right_panel_path: NodePath = NodePath("RightPanel")

@onready var room_exit: Chapter04RoomExit = get_node(exit_path) as Chapter04RoomExit
@onready var blocker: StaticBody2D = get_node(blocker_path) as StaticBody2D
@onready var left_panel: Sprite2D = get_node(left_panel_path) as Sprite2D
@onready var right_panel: Sprite2D = get_node(right_panel_path) as Sprite2D

var _opening: bool = false


func _ready() -> void:
	room_exit.interaction_accepted.connect(_open_gate)


func _open_gate() -> void:
	if _opening:
		return
	_opening = true
	blocker.collision_layer = 0
	blocker.collision_mask = 0
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(left_panel, "position:x", left_panel.position.x - 70.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(right_panel, "position:x", right_panel.position.x + 70.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(left_panel, "modulate:a", 0.25, 0.55)
	tween.tween_property(right_panel, "modulate:a", 0.25, 0.55)
