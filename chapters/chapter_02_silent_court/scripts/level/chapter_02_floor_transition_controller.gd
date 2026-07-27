class_name Chapter02FloorTransitionController
extends Node

## Coordinates the short black-screen floor change without creating a new Player,
## Camera or HUD. Relocation occurs only while the screen is fully black.

signal transition_started(transition_id: StringName, destination_spawn_id: StringName)
signal transition_finished(transition_id: StringName, destination_spawn_id: StringName)

@export_node_path("SilentCourtLevel") var level_path: NodePath
@export_node_path("Player") var player_path: NodePath
@export_node_path("Node2D") var spawn_points_path: NodePath
@export_node_path("Control") var fade_rect_path: NodePath
@export_node_path("Node2D") var transition_areas_path: NodePath
@export_range(0.1, 0.4, 0.01) var fade_out_duration: float = 0.22
@export_range(0.0, 0.2, 0.01) var blackout_hold_duration: float = 0.08
@export_range(0.1, 0.4, 0.01) var fade_in_duration: float = 0.22

@onready var level: SilentCourtLevel = get_node_or_null(level_path) as SilentCourtLevel
@onready var player: Player = get_node_or_null(player_path) as Player
@onready var spawn_points: Node2D = get_node_or_null(spawn_points_path) as Node2D
@onready var fade_rect: ColorRect = get_node_or_null(fade_rect_path) as ColorRect
@onready var transition_areas: Node2D = get_node_or_null(transition_areas_path) as Node2D

var _transitioning: bool = false
var _active_tween: Tween
var _previous_input_profile: Player.InputProfile = Player.InputProfile.FULL
var _previous_invulnerability: bool = false
var _active_transition: Chapter02FloorTransition


func _ready() -> void:
	if level == null or player == null or spawn_points == null or fade_rect == null or transition_areas == null:
		push_error("Chapter02FloorTransitionController has an invalid node path")
		return
	fade_rect.visible = false
	fade_rect.modulate.a = 0.0
	for child: Node in transition_areas.get_children():
		var transition: Chapter02FloorTransition = child as Chapter02FloorTransition
		if transition != null:
			transition.transition_requested.connect(_on_transition_requested)


func is_transitioning() -> bool:
	return _transitioning


func get_active_transition_id() -> StringName:
	return _active_transition.transition_id if _active_transition != null else &""


func request_transition(transition: Chapter02FloorTransition) -> bool:
	if _transitioning or transition == null or player.is_dead():
		return false
	var destination: Marker2D = spawn_points.get_node_or_null(
		NodePath(String(transition.destination_spawn_id))
	) as Marker2D
	if destination == null:
		push_error("Unknown Chapter II floor destination: %s" % transition.destination_spawn_id)
		return false
	_transitioning = true
	_active_transition = transition
	_previous_input_profile = player.get_input_profile()
	_previous_invulnerability = player.hurtbox.is_invulnerable
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.hurtbox.set_invulnerable(true)
	player.velocity = Vector2.ZERO
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	transition_started.emit(transition.transition_id, transition.destination_spawn_id)
	_active_tween = create_tween()
	_active_tween.tween_property(fade_rect, "modulate:a", 1.0, fade_out_duration)
	_active_tween.tween_callback(_relocate_player.bind(destination))
	_active_tween.tween_interval(blackout_hold_duration)
	_active_tween.tween_property(fade_rect, "modulate:a", 0.0, fade_in_duration)
	_active_tween.tween_callback(_complete_transition)
	return true


func _on_transition_requested(transition: Chapter02FloorTransition) -> void:
	request_transition(transition)


func _relocate_player(destination: Marker2D) -> void:
	player.global_position = destination.global_position
	player.velocity = Vector2.ZERO
	level.configure_camera_for_world_y(destination.global_position.y)
	if player.player_camera != null:
		player.player_camera.reset_smoothing()


func _complete_transition() -> void:
	var completed_transition: Chapter02FloorTransition = _active_transition
	fade_rect.visible = false
	fade_rect.modulate.a = 0.0
	player.hurtbox.set_invulnerable(_previous_invulnerability)
	if not player.is_dead():
		player.set_input_profile(_previous_input_profile)
	_transitioning = false
	_active_transition = null
	if completed_transition != null:
		transition_finished.emit(
			completed_transition.transition_id,
			completed_transition.destination_spawn_id
		)
