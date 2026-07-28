class_name RoyalChapelPassage
extends Node2D

const DEFAULT_SPAWN_ID: StringName = &"royal_processional_passage_start"
const FLAG_CHAPTER_03_STARTED: StringName = &"chapter_03_started"

@export var transition_data: Chapter02TransitionData
@export_node_path("Player") var player_path: NodePath
@export_node_path("PlayerRespawnController") var respawn_controller_path: NodePath
@export_node_path("Marker2D") var spawn_path: NodePath
@export_node_path("Area2D") var exit_area_path: NodePath
@export_node_path("Label") var prompt_path: NodePath

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var respawn_controller: PlayerRespawnController = get_node_or_null(
	respawn_controller_path
) as PlayerRespawnController
@onready var spawn_marker: Marker2D = get_node_or_null(spawn_path) as Marker2D
@onready var exit_area: Area2D = get_node_or_null(exit_area_path) as Area2D
@onready var prompt: Label = get_node_or_null(prompt_path) as Label

var _player_in_exit: bool = false
var _transition_started: bool = false


func _ready() -> void:
	if not _validate_dependencies():
		return
	var room_name: Label = get_node_or_null(
		"GameplayWorld/ChapterRuntime/HUD/RoomName"
	) as Label
	if room_name != null:
		room_name.text = "CHAPTER II · ROYAL PROCESSIONAL PASSAGE / 王室礼拜回廊"
	exit_area.body_entered.connect(_on_exit_body_entered)
	exit_area.body_exited.connect(_on_exit_body_exited)
	prompt.visible = false
	player.global_position = spawn_marker.global_position
	player.velocity = Vector2.ZERO
	respawn_controller.set_spawn_point(spawn_marker)
	if player.player_camera != null:
		player.player_camera.limit_left = 0
		player.player_camera.limit_right = 3600
		player.player_camera.limit_top = 0
		player.player_camera.limit_bottom = 720
		player.player_camera.reset_smoothing()
	var session: ChapterSessionState = _session()
	if session != null:
		session.consume_pending_spawn(DEFAULT_SPAWN_ID)
	var manager: SceneTransitionManagerState = get_node_or_null(
		"/root/SceneTransitionManager"
	) as SceneTransitionManagerState
	var target_profile: ChapterStartProfile = ChapterRegistry.get_chapter_or_null(
		transition_data.target_chapter_id
	)
	if manager != null and target_profile != null:
		manager.prepare_scene(target_profile.main_scene_path)


func _unhandled_input(event: InputEvent) -> void:
	if (
		_transition_started or not _player_in_exit or player.is_dead()
		or not event.is_action_pressed("interact")
	):
		return
	_transition_started = true
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.velocity = Vector2.ZERO
	var session: ChapterSessionState = _session()
	if session != null:
		session.set_story_flag(FLAG_CHAPTER_03_STARTED)
	var manager: SceneTransitionManagerState = get_node_or_null(
		"/root/SceneTransitionManager"
	) as SceneTransitionManagerState
	if manager == null or not manager.transition_to_chapter(
		transition_data.target_chapter_id,
		transition_data.target_spawn_id,
		transition_data.fade_out_duration,
		transition_data.fade_in_duration
	):
		_transition_started = false
		player.set_input_profile(Player.InputProfile.FULL)
	get_viewport().set_input_as_handled()


func debug_enter_chapter_three() -> void:
	_player_in_exit = true
	var event: InputEventAction = InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	_unhandled_input(event)


func _on_exit_body_entered(body: Node2D) -> void:
	if body != player:
		return
	_player_in_exit = true
	prompt.visible = true


func _on_exit_body_exited(body: Node2D) -> void:
	if body != player:
		return
	_player_in_exit = false
	prompt.visible = false


func _session() -> ChapterSessionState:
	return get_node_or_null("/root/ChapterSession") as ChapterSessionState


func _validate_dependencies() -> bool:
	if (
		transition_data == null or not transition_data.is_valid() or player == null
		or respawn_controller == null or spawn_marker == null or exit_area == null
		or prompt == null
	):
		push_error("RoyalChapelPassage scene composition is incomplete")
		return false
	return true
