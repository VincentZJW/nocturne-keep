class_name PlayerDeathHud
extends Control

## Temporary death-state presentation. It observes Player life-cycle signals only.

@export_node_path("Player") var player_path: NodePath = NodePath("../../World/Player")

@onready var player: Player = get_node_or_null(player_path) as Player


func _ready() -> void:
	visible = false
	if player == null:
		push_error("PlayerDeathHud requires a Player target")
		return
	player.death_state_entered.connect(_on_death_state_entered)
	player.respawned.connect(_on_player_respawned)
	if player.is_dead():
		_on_death_state_entered()


func _exit_tree() -> void:
	if (
		player != null
		and is_instance_valid(player)
		and player.death_state_entered.is_connected(_on_death_state_entered)
	):
		player.death_state_entered.disconnect(_on_death_state_entered)
	if (
		player != null
		and is_instance_valid(player)
		and player.respawned.is_connected(_on_player_respawned)
	):
		player.respawned.disconnect(_on_player_respawned)


func _on_death_state_entered() -> void:
	visible = true


func _on_player_respawned(_global_spawn_position: Vector2) -> void:
	visible = false
