class_name BallroomMirrorGate
extends Node2D

## Editable native-2D mirror mechanism and Royal Chapel Passage interaction.

signal mirror_reveal_started
signal mirror_revealed
signal passage_requested
signal door_opened

@export_node_path("StaticBody2D") var blocker_path: NodePath = NodePath("PassageBlocker")
@export_node_path("Area2D") var interaction_area_path: NodePath = NodePath("InteractionArea")
@export_node_path("Label") var prompt_path: NodePath = NodePath("InteractionPrompt")
@export_range(1.0, 4.0, 0.1) var reveal_duration: float = 2.2
@export_range(0.5, 2.0, 0.1) var open_duration: float = 1.1

@onready var blocker: StaticBody2D = get_node_or_null(blocker_path) as StaticBody2D
@onready var interaction_area: Area2D = get_node_or_null(interaction_area_path) as Area2D
@onready var prompt: Label = get_node_or_null(prompt_path) as Label

var reveal_progress: float = 0.0:
	set(value):
		reveal_progress = clampf(value, 0.0, 1.0)
		queue_redraw()
var door_open_progress: float = 0.0:
	set(value):
		door_open_progress = clampf(value, 0.0, 1.0)
		queue_redraw()
var _revealed: bool = false
var _interaction_enabled: bool = false
var _player_in_range: Player
var _opening: bool = false
var _message_tween: Tween
var _reveal_tween: Tween


func _ready() -> void:
	if blocker == null or interaction_area == null or prompt == null:
		push_error("BallroomMirrorGate scene composition is incomplete")
		return
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	prompt.visible = false
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if (
		not _interaction_enabled or _opening or _player_in_range == null
		or _player_in_range.is_dead() or not event.is_action_pressed("interact")
	):
		return
	passage_requested.emit()
	get_viewport().set_input_as_handled()


func begin_reveal(duration: float = -1.0) -> bool:
	if _revealed or reveal_progress > 0.0:
		return false
	var actual_duration: float = reveal_duration if duration < 0.0 else duration
	mirror_reveal_started.emit()
	_reveal_tween = create_tween()
	_reveal_tween.tween_property(self, "reveal_progress", 1.0, actual_duration).set_trans(
		Tween.TRANS_SINE
	).set_ease(Tween.EASE_IN_OUT)
	_reveal_tween.tween_callback(_complete_reveal)
	return true


func reveal_immediately() -> void:
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_reveal_tween = null
	reveal_progress = 1.0
	_revealed = true
	set_interaction_enabled(true)


func set_interaction_enabled(enabled: bool) -> void:
	_interaction_enabled = enabled and _revealed and not _opening
	_update_prompt()


func begin_door_open(duration: float = -1.0) -> bool:
	if not _revealed or _opening or door_open_progress >= 1.0:
		return false
	_opening = true
	_interaction_enabled = false
	_update_prompt()
	var actual_duration: float = open_duration if duration < 0.0 else duration
	var tween: Tween = create_tween()
	tween.tween_property(self, "door_open_progress", 1.0, actual_duration).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_IN)
	tween.tween_callback(_complete_door_open)
	return true


func show_message(text: String, duration: float = 1.6) -> void:
	if _message_tween != null and _message_tween.is_valid():
		_message_tween.kill()
	prompt.text = text
	prompt.visible = true
	prompt.modulate.a = 1.0
	_message_tween = create_tween()
	_message_tween.tween_interval(duration)
	_message_tween.tween_property(prompt, "modulate:a", 0.0, 0.25)
	_message_tween.tween_callback(func() -> void:
		prompt.modulate.a = 1.0
		_update_prompt()
	)


func is_revealed() -> bool:
	return _revealed


func is_open() -> bool:
	return door_open_progress >= 1.0


func _complete_reveal() -> void:
	_reveal_tween = null
	_revealed = true
	set_interaction_enabled(true)
	mirror_revealed.emit()


func _complete_door_open() -> void:
	_set_blocker_enabled(false)
	door_opened.emit()


func _set_blocker_enabled(enabled: bool) -> void:
	blocker.collision_layer = 1 if enabled else 0
	for child: Node in blocker.get_children():
		var shape: CollisionShape2D = child as CollisionShape2D
		if shape != null:
			shape.set_deferred("disabled", not enabled)


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
	if prompt == null:
		return
	prompt.text = "E  ROYAL CHAPEL PASSAGE / 王室礼拜秘门"
	prompt.visible = _interaction_enabled and _player_in_range != null


func _draw() -> void:
	# Prayer statues and oxidized royal frame remain in front of the recessed door.
	_draw_prayer_statue(Vector2(-210.0, 0.0), false)
	_draw_prayer_statue(Vector2(210.0, 0.0), true)
	var arch: PackedVector2Array = PackedVector2Array([
		Vector2(-160, 0), Vector2(-160, -210), Vector2(-92, -292), Vector2(0, -338),
		Vector2(92, -292), Vector2(160, -210), Vector2(160, 0),
	])
	draw_polyline(arch, Color("6f5b3c"), 14.0, true)
	draw_polyline(arch, Color("302a2c"), 5.0, true)
	# Black bell-shaped stone door behind the separating mirror panels.
	if reveal_progress >= 0.30:
		var door_alpha: float = clampf((reveal_progress - 0.30) / 0.25, 0.0, 1.0)
		var rise: float = door_open_progress * 230.0
		var door_points: PackedVector2Array = PackedVector2Array([
			Vector2(-112, -rise), Vector2(-112, -205 - rise), Vector2(-58, -270 - rise),
			Vector2(0, -305 - rise), Vector2(58, -270 - rise),
			Vector2(112, -205 - rise), Vector2(112, -rise),
		])
		draw_colored_polygon(door_points, Color(0.055, 0.06, 0.075, door_alpha))
		for groove_index: int in range(13):
			var x: float = -78.0 + float(groove_index) * 13.0
			var glow: float = (
				1.0 if door_open_progress * 13.0 >= float(groove_index) else 0.18
			)
			draw_line(
				Vector2(x, -46 - rise), Vector2(x * 0.55, -190 - rise),
				Color(0.58, 0.70, 0.76, door_alpha * glow), 2.0
			)
		draw_circle(Vector2(0, -246 - rise), 22.0, Color(0.45, 0.34, 0.20, door_alpha))
		draw_arc(Vector2(0, -239 - rise), 10.0, PI, TAU, 18, Color("17141b"), 4.0)
	# Broken mirror restores, receives thirteen cracks, then separates at center.
	var separation: float = clampf((reveal_progress - 0.58) / 0.42, 0.0, 1.0) * 118.0
	var mirror_alpha: float = 1.0 - clampf((reveal_progress - 0.86) / 0.14, 0.0, 1.0)
	var restored: float = clampf(reveal_progress / 0.24, 0.0, 1.0)
	for side: int in [-1, 1]:
		var center_x: float = float(side) * (72.0 + separation)
		draw_rect(Rect2(center_x - 70.0, -262.0, 140.0, 244.0), Color(0.18, 0.22, 0.28, mirror_alpha), true)
		draw_rect(Rect2(center_x - 66.0, -258.0, 132.0, 236.0), Color(0.32, 0.38, 0.44, mirror_alpha * (0.46 + 0.32 * restored)), false, 4.0)
		# The restored reflection deliberately contains no Player silhouette.
		for table_index: int in range(3):
			var table_y: float = -78.0 - float(table_index) * 40.0
			draw_line(Vector2(center_x - 45, table_y), Vector2(center_x + 45, table_y), Color(0.48, 0.37, 0.41, mirror_alpha * restored), 3.0)
	if reveal_progress < 0.24:
		draw_line(Vector2(-110, -245), Vector2(-18, -84), Color("111019"), 7.0)
		draw_line(Vector2(92, -236), Vector2(25, -118), Color("111019"), 6.0)
	if reveal_progress >= 0.24 and reveal_progress < 0.86:
		var crack_progress: float = clampf((reveal_progress - 0.24) / 0.34, 0.0, 1.0)
		for crack_index: int in range(13):
			var angle: float = TAU * float(crack_index) / 13.0
			var end: Vector2 = Vector2(105.0, 76.0).rotated(angle) * crack_progress + Vector2(0, -142)
			draw_line(Vector2(0, -142), end, Color(0.72, 0.78, 0.82, 0.75 * mirror_alpha), 2.0)
	# Low soul mist remains restrained at the threshold.
	for mist_index: int in range(7):
		var x: float = -110.0 + float(mist_index) * 36.0
		draw_circle(Vector2(x, -6.0), 18.0, Color(0.55, 0.64, 0.70, 0.07 + reveal_progress * 0.06))


func _draw_prayer_statue(base: Vector2, mirrored: bool) -> void:
	var direction: float = -1.0 if mirrored else 1.0
	draw_rect(Rect2(base.x - 32, -112, 64, 112), Color("26252d"), true)
	draw_circle(Vector2(base.x, -145), 30.0, Color("35333c"))
	draw_line(Vector2(base.x, -92), Vector2(base.x + direction * 22, -55), Color("706a70"), 8.0)
	draw_line(Vector2(base.x + direction * 22, -55), Vector2(base.x, -37), Color("706a70"), 8.0)
