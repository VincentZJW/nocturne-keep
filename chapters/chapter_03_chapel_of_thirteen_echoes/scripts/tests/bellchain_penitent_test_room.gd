class_name BellchainPenitentTestRoom
extends Node2D

@onready var player: Player = $ChapterRuntime/Player as Player
@onready var respawn_controller: PlayerRespawnController = (
	$ChapterRuntime/PlayerRespawnController as PlayerRespawnController
)
@onready var enemy: BellchainPenitent = $Enemies/BellchainPenitent as BellchainPenitent
@onready var player_spawn: Marker2D = $PlayerSpawn as Marker2D


func _ready() -> void:
	player.global_position = player_spawn.global_position
	player.velocity = Vector2.ZERO
	respawn_controller.set_spawn_point(player_spawn)
	enemy.configure_movement_bounds(520.0, 1060.0)
	enemy.set_target(player)
	if player.player_camera != null:
		player.player_camera.limit_left = 0
		player.player_camera.limit_right = 1280
		player.player_camera.limit_top = 0
		player.player_camera.limit_bottom = 720
		player.player_camera.reset_smoothing()
