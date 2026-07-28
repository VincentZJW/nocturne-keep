class_name DuchessBossEntrance
extends Node2D

## Formal threshold before the Ballroom. A composed transition controller owns relocation.

signal entrance_requested(player: Player)

@export_node_path("Area2D") var approach_area_path: NodePath = NodePath("ApproachArea")
@export_node_path("StaticBody2D") var blocker_path: NodePath = NodePath("DoorBlocker")
@export_node_path("Sprite2D") var door_artwork_path: NodePath = NodePath("ExteriorVisuals/DoorArtwork")
@export_node_path("Node2D") var exterior_visuals_path: NodePath = NodePath("ExteriorVisuals")

@onready var approach_area: Area2D = get_node_or_null(approach_area_path) as Area2D
@onready var blocker: StaticBody2D = get_node_or_null(blocker_path) as StaticBody2D
@onready var door_artwork: Sprite2D = get_node_or_null(door_artwork_path) as Sprite2D
@onready var exterior_visuals: Node2D = get_node_or_null(exterior_visuals_path) as Node2D

var door_open_progress: float = 0.0:
	set(value):
		door_open_progress = clampf(value, 0.0, 1.0)
		if door_artwork != null:
			door_artwork.visible = door_open_progress < 1.0
		if exterior_visuals != null:
			exterior_visuals.visible = door_open_progress < 1.0
			exterior_visuals.modulate.a = 1.0 - door_open_progress
		queue_redraw()
var _entry_requested: bool = false


func _ready() -> void:
	if approach_area == null or blocker == null or door_artwork == null or exterior_visuals == null:
		push_error("DuchessBossEntrance scene composition is incomplete")
		return
	approach_area.body_entered.connect(_on_body_entered)
	queue_redraw()


func open_immediately() -> void:
	door_open_progress = 1.0
	_set_blocker_enabled(false)
	set_entry_enabled(false)


func reset_entrance() -> void:
	door_open_progress = 0.0
	_entry_requested = false
	_set_blocker_enabled(true)
	set_entry_enabled(true)


func set_entry_enabled(enabled: bool) -> void:
	approach_area.set_deferred("monitoring", enabled)
	approach_area.set_deferred("monitorable", enabled)


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if _entry_requested or door_open_progress >= 1.0 or player == null:
		return
	_entry_requested = true
	set_entry_enabled(false)
	entrance_requested.emit(player)


func _set_blocker_enabled(enabled: bool) -> void:
	blocker.collision_layer = 1 if enabled else 0
	for child: Node in blocker.get_children():
		var shape: CollisionShape2D = child as CollisionShape2D
		if shape != null:
			shape.set_deferred("disabled", not enabled)


func _draw() -> void:
	# The formal raster assets own the door/statues; only the threshold carpet remains dynamic.
	draw_colored_polygon(PackedVector2Array([Vector2(-390, 0), Vector2(390, 0), Vector2(250, 34), Vector2(-250, 34)]), Color("441321"))
