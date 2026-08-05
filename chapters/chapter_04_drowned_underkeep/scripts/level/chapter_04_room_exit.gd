class_name Chapter04RoomExit
extends Area2D

signal transition_requested(destination_room_id: StringName, destination_spawn_id: StringName)

@export var destination_room_id: StringName = &""
@export var destination_spawn_id: StringName = &"EntryWest"
@export var one_shot: bool = true
@export var requires_interaction: bool = false
@export var interaction_action: StringName = &"interact"
@export_node_path("CanvasItem") var prompt_path: NodePath

var _used: bool = false
var _candidate: Player
var _prompt: CanvasItem


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_prompt = get_node_or_null(prompt_path) as CanvasItem if not prompt_path.is_empty() else null
	_set_prompt_visible(false)
	set_process_unhandled_input(requires_interaction)


func _on_body_entered(body: Node2D) -> void:
	if body is not Player or (_used and one_shot) or destination_room_id.is_empty():
		return
	if requires_interaction:
		_candidate = body as Player
		_set_prompt_visible(true)
		return
	_request_transition()


func _on_body_exited(body: Node2D) -> void:
	if body != _candidate:
		return
	_candidate = null
	_set_prompt_visible(false)


func _unhandled_input(event: InputEvent) -> void:
	if (
		not requires_interaction
		or _candidate == null
		or not is_instance_valid(_candidate)
		or (_used and one_shot)
	):
		return
	if event.is_action_pressed(interaction_action):
		get_viewport().set_input_as_handled()
		_request_transition()


func _request_transition() -> void:
	_used = true
	_set_prompt_visible(false)
	transition_requested.emit(destination_room_id, destination_spawn_id)


func _set_prompt_visible(visible_value: bool) -> void:
	if _prompt != null:
		_prompt.visible = visible_value
