class_name DuchessBossThresholdTransition
extends Node

## Owns the short black-screen threshold relocation before Seraphine's saved intro.

signal transition_started(retry: bool)
signal transition_finished(retry: bool)

@export_node_path("SilentCourtLevel") var level_path: NodePath
@export_node_path("Player") var player_path: NodePath
@export_node_path("DuchessBossEntrance") var entrance_path: NodePath
@export_node_path("Marker2D") var destination_path: NodePath
@export_node_path("ColorRect") var fade_rect_path: NodePath
@export_node_path("HollowDuchessRoomController") var room_controller_path: NodePath
@export_node_path("PlayerRespawnController") var respawn_controller_path: NodePath
@export_range(0.12, 0.40, 0.01) var fade_out_duration: float = 0.24
@export_range(0.04, 0.20, 0.01) var blackout_hold_duration: float = 0.10
@export_range(0.12, 0.40, 0.01) var fade_in_duration: float = 0.24

@onready var level: SilentCourtLevel = get_node_or_null(level_path) as SilentCourtLevel
@onready var player: Player = get_node_or_null(player_path) as Player
@onready var entrance: DuchessBossEntrance = get_node_or_null(entrance_path) as DuchessBossEntrance
@onready var destination: Marker2D = get_node_or_null(destination_path) as Marker2D
@onready var fade_rect: ColorRect = get_node_or_null(fade_rect_path) as ColorRect
@onready var room_controller: HollowDuchessRoomController = get_node_or_null(
	room_controller_path
) as HollowDuchessRoomController
@onready var respawn_controller: PlayerRespawnController = get_node_or_null(
	respawn_controller_path
) as PlayerRespawnController

var _transitioning: bool = false
var _enabled: bool = true
var _previous_invulnerability: bool = false
var _active_retry: bool = false
var _transition_stage: StringName = &"idle"
var _active_tween: Tween


func _ready() -> void:
	if not _validate_dependencies():
		return
	entrance.entrance_requested.connect(_on_entrance_requested)
	respawn_controller.player_respawned.connect(_on_player_respawned)
	if room_controller.room_is_cleared:
		entrance.open_immediately()


func is_transitioning() -> bool:
	return _transitioning


func get_transition_stage() -> StringName:
	return _transition_stage


func set_enabled_for_test(enabled: bool) -> void:
	_enabled = enabled
	if not enabled:
		entrance.open_immediately()


func request_entry() -> bool:
	if (
		not _enabled or _transitioning or player.is_dead()
		or room_controller.room_is_cleared or room_controller.encounter_started
	):
		return false
	_transitioning = true
	_active_retry = room_controller.intro_seen
	_transition_stage = &"fade_out"
	_previous_invulnerability = player.hurtbox.is_invulnerable
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.hurtbox.set_invulnerable(true)
	player.velocity = Vector2.ZERO
	entrance.set_entry_enabled(false)
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	transition_started.emit(_active_retry)
	_active_tween = create_tween()
	_active_tween.tween_property(fade_rect, "modulate:a", 1.0, fade_out_duration)
	_active_tween.tween_callback(_relocate_behind_blackout)
	_active_tween.tween_interval(blackout_hold_duration)
	_active_tween.tween_callback(func() -> void: _transition_stage = &"fade_in")
	_active_tween.tween_property(fade_rect, "modulate:a", 0.0, fade_in_duration)
	_active_tween.tween_callback(_complete_entry)
	return true


func _on_entrance_requested(requesting_player: Player) -> void:
	if requesting_player == player:
		request_entry()


func _relocate_behind_blackout() -> void:
	_transition_stage = &"blackout"
	entrance.open_immediately()
	player.global_position = destination.global_position
	player.velocity = Vector2.ZERO
	level.configure_camera_for_world_y(destination.global_position.y)
	if player.player_camera != null:
		player.player_camera.reset_smoothing()


func _complete_entry() -> void:
	fade_rect.visible = false
	fade_rect.modulate.a = 0.0
	player.hurtbox.set_invulnerable(_previous_invulnerability)
	_transition_stage = &"intro"
	var intro_started: bool = room_controller.begin_encounter_from_entrance()
	if not intro_started and not player.is_dead():
		player.set_input_profile(Player.InputProfile.FULL)
		_transition_stage = &"idle"
	_transitioning = false
	transition_finished.emit(_active_retry)


func _on_player_respawned(_spawn_position: Vector2) -> void:
	if room_controller.room_is_cleared:
		return
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_transitioning = false
	_transition_stage = &"idle"
	fade_rect.visible = false
	fade_rect.modulate.a = 0.0
	call_deferred("_reset_entrance_after_respawn")


func _reset_entrance_after_respawn() -> void:
	if not room_controller.room_is_cleared:
		entrance.reset_entrance()


func _validate_dependencies() -> bool:
	if (
		level == null or player == null or entrance == null or destination == null
		or fade_rect == null or room_controller == null or respawn_controller == null
	):
		push_error("DuchessBossThresholdTransition has an invalid node path")
		return false
	return true
