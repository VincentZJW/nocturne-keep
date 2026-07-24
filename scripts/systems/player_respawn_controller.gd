class_name PlayerRespawnController
extends Node

## Coordinates the current level's single spawn point with Player-owned reset state.

signal player_respawned(global_spawn_position: Vector2)

@export var enabled: bool = true
@export_node_path("Player") var player_path: NodePath = NodePath("../World/Player")
@export_node_path("Marker2D") var spawn_point_path: NodePath = NodePath("../World/SpawnPoint")
@export_node_path("PlayerDeathSequence") var death_sequence_path: NodePath = NodePath(
	"../World/Player/DeathSequence"
)

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var spawn_point: Marker2D = get_node_or_null(spawn_point_path) as Marker2D
@onready var death_sequence: PlayerDeathSequence = get_node_or_null(
	death_sequence_path
) as PlayerDeathSequence

var _respawn_in_progress: bool = false


func set_spawn_point(new_spawn_point: Marker2D) -> bool:
	if new_spawn_point == null or not is_instance_valid(new_spawn_point):
		return false
	spawn_point = new_spawn_point
	return true


func _ready() -> void:
	if player == null:
		push_error("PlayerRespawnController requires a Player target")
		return
	if spawn_point == null:
		push_error("PlayerRespawnController requires a Marker2D spawn point")
		return
	if death_sequence == null:
		push_error("PlayerRespawnController requires a PlayerDeathSequence")
		return
	death_sequence.sequence_completed.connect(_on_death_sequence_completed)


func _exit_tree() -> void:
	if (
		death_sequence != null
		and is_instance_valid(death_sequence)
		and death_sequence.sequence_completed.is_connected(_on_death_sequence_completed)
	):
		death_sequence.sequence_completed.disconnect(_on_death_sequence_completed)


func _on_death_sequence_completed() -> void:
	if not enabled or _respawn_in_progress or player == null or spawn_point == null:
		return
	_respawn_in_progress = true
	var did_respawn: bool = player.respawn_at(spawn_point.global_position)
	if did_respawn:
		player_respawned.emit(spawn_point.global_position)
	_respawn_in_progress = false
