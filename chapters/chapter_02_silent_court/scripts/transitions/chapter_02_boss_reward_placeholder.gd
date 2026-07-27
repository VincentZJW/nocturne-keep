class_name Chapter02BossRewardPlaceholder
extends Area2D

## Temporary reward-condition validator. This is explicitly not final weapon art.

signal placeholder_collected

@export_node_path("Label") var prompt_path: NodePath = NodePath("Prompt")
@onready var prompt: Label = get_node_or_null(prompt_path) as Label

var _available: bool = false
var _player_in_range: Player


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	set_available(false)


func _unhandled_input(event: InputEvent) -> void:
	if (
		not _available or _player_in_range == null or _player_in_range.is_dead()
		or not event.is_action_pressed("interact")
	):
		return
	set_available(false)
	placeholder_collected.emit()
	get_viewport().set_input_as_handled()


func set_available(available: bool) -> void:
	_available = available
	visible = available
	set_deferred("monitoring", available)
	_update_prompt()


func is_available() -> bool:
	return _available


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null:
		return
	_player_in_range = player
	_update_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body != _player_in_range:
		return
	_player_in_range = null
	_update_prompt()


func _update_prompt() -> void:
	if prompt != null:
		prompt.visible = _available and _player_in_range != null


func _process(_delta: float) -> void:
	if _available:
		queue_redraw()


func _draw() -> void:
	if not _available:
		return
	var pulse: float = 0.72 + 0.12 * sin(Time.get_ticks_msec() * 0.004)
	draw_circle(Vector2(0, -22), 28.0, Color(0.68, 0.72, 0.80, 0.10 * pulse))
	# Broken porcelain mask and two neutral blades mark the future fixed Boss reward.
	draw_arc(Vector2(0, -22), 15.0, 0.1, PI - 0.1, 16, Color(0.86, 0.83, 0.78, pulse), 3.0)
	draw_line(Vector2(-19, -8), Vector2(-56, -38), Color(0.66, 0.70, 0.74, pulse), 4.0)
	draw_line(Vector2(19, -8), Vector2(54, -42), Color(0.66, 0.70, 0.74, pulse), 4.0)
