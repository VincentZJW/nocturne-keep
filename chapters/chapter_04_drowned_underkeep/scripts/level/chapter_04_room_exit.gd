class_name Chapter04RoomExit
extends Area2D

signal transition_requested(destination_room_id: StringName, destination_spawn_id: StringName)
signal interaction_accepted

@export var destination_room_id: StringName = &""
@export var destination_spawn_id: StringName = &"EntryWest"
@export var one_shot: bool = true
@export var requires_interaction: bool = false
@export var interaction_action: StringName = &"interact"
@export_node_path("CanvasItem") var prompt_path: NodePath
@export var locked: bool = false
@export var locked_prompt_text: String = "SEALED · DEFEAT THE ENCOUNTER / 封印中 · 击败敌人"
@export_range(0.0, 3.0, 0.05) var transition_delay: float = 0.0

var _used: bool = false
var _candidate: Player
var _prompt: CanvasItem
var _unlocked_prompt_text: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_prompt = get_node_or_null(prompt_path) as CanvasItem if not prompt_path.is_empty() else null
	var prompt_label: Label = _prompt as Label
	if prompt_label != null:
		_unlocked_prompt_text = prompt_label.text
	_set_prompt_visible(false)
	set_process_unhandled_input(requires_interaction or locked)


func _on_body_entered(body: Node2D) -> void:
	if body is not Player or (_used and one_shot) or destination_room_id.is_empty():
		return
	if requires_interaction or locked:
		_candidate = body as Player
		_update_prompt_text()
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
	if event.is_action_pressed(interaction_action) and not locked:
		get_viewport().set_input_as_handled()
		_request_transition()


func _request_transition() -> void:
	_used = true
	_set_prompt_visible(false)
	interaction_accepted.emit()
	if transition_delay > 0.0:
		await get_tree().create_timer(transition_delay).timeout
		if not is_inside_tree():
			return
	transition_requested.emit(destination_room_id, destination_spawn_id)


func _set_prompt_visible(visible_value: bool) -> void:
	if _prompt != null:
		_prompt.visible = visible_value


func set_locked(value: bool) -> void:
	locked = value
	set_process_unhandled_input(requires_interaction or locked)
	_update_prompt_text()


func is_locked() -> bool:
	return locked


func is_player_in_range() -> bool:
	return _candidate != null and is_instance_valid(_candidate)


func is_prompt_visible() -> bool:
	return _prompt != null and _prompt.visible


func _update_prompt_text() -> void:
	var prompt_label: Label = _prompt as Label
	if prompt_label == null:
		return
	prompt_label.text = locked_prompt_text if locked else _unlocked_prompt_text
