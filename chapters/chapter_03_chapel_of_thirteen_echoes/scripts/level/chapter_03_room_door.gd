class_name Chapter03RoomDoor
extends Area2D

signal transition_requested(destination_room_id: StringName, destination_spawn_id: StringName)

@export var destination_room_id: StringName = &""
@export var destination_spawn_id: StringName = &"EntryWest"
@export var transition_on_open: bool = true
@export var opening_offset: Vector2 = Vector2(0.0, -300.0)
@export_range(0.05, 1.0, 0.05) var opening_duration: float = 0.25
@export_node_path("Sprite2D") var door_visual_path: NodePath = NodePath("DoorVisual")
@export_node_path("CollisionShape2D") var blocker_shape_path: NodePath = NodePath("Blocker/CollisionShape2D")
@export_node_path("Label") var prompt_path: NodePath = NodePath("Prompt")

@onready var door_visual: Sprite2D = get_node_or_null(door_visual_path) as Sprite2D
@onready var blocker_shape: CollisionShape2D = get_node_or_null(blocker_shape_path) as CollisionShape2D
@onready var prompt: Label = get_node_or_null(prompt_path) as Label

var _player_in_range: bool = false
var _opened: bool = false
var _opening: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt != null:
		prompt.visible = false


func _process(_delta: float) -> void:
	if _player_in_range and not _opened and not _opening and Input.is_action_just_pressed("interact"):
		_open()


func _open() -> void:
	_opening = true
	if prompt != null:
		prompt.visible = false
	if blocker_shape != null:
		blocker_shape.set_deferred("disabled", true)
	if door_visual != null:
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(door_visual, "position", door_visual.position + opening_offset, opening_duration)
		await tween.finished
	_opened = true
	_opening = false
	if transition_on_open and not destination_room_id.is_empty():
		transition_requested.emit(destination_room_id, destination_spawn_id)


func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	_player_in_range = true
	if prompt != null and not _opened:
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
	_player_in_range = false
	if prompt != null:
		prompt.visible = false
