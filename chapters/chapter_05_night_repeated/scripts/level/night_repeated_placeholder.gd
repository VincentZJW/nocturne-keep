class_name NightRepeatedPlaceholder
extends Node2D

@export_node_path("Player") var player_path: NodePath = NodePath("ChapterRuntime/Player")
@export_node_path("Marker2D") var spawn_path: NodePath = NodePath("SpawnPoints/CH5_START")

@onready var player: Player = get_node(player_path) as Player
@onready var spawn: Marker2D = get_node(spawn_path) as Marker2D


func _ready() -> void:
	player.global_position = spawn.global_position
	player.velocity = Vector2.ZERO
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.current_chapter_id = ChapterRegistry.CHAPTER_05_NIGHT_REPEATED
		session.set_story_flag(&"ch5_placeholder_entered")
