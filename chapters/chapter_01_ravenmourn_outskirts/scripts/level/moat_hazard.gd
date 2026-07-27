class_name MoatHazard
extends Area2D

## Sends the Player through the existing death/ghost/respawn sequence once per life.

signal player_fell_into_moat

@export_node_path("Player") var player_path: NodePath = NodePath("../../../Player")

@onready var player: Player = get_node_or_null(player_path) as Player

var _armed: bool = true
var _enemy_ids_triggered: Dictionary[int, bool] = {}


func _ready() -> void:
	if player == null:
		push_error("MoatHazard requires the Main Player")
		return
	body_entered.connect(_on_body_entered)
	player.respawned.connect(_on_player_respawned)


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		_trigger_player_death()
		return
	var enemy: EnemyCombatant = body as EnemyCombatant
	if enemy == null or enemy is FallenGateKnight or enemy.is_dead():
		return
	var enemy_id: int = enemy.get_instance_id()
	if _enemy_ids_triggered.has(enemy_id):
		return
	_enemy_ids_triggered[enemy_id] = true
	var enemy_health: HealthComponent = enemy.get_health_component()
	if enemy_health != null:
		enemy_health.take_damage(enemy_health.current_health)


func _on_player_respawned(_spawn_position: Vector2) -> void:
	_armed = true


func is_armed() -> bool:
	return _armed


func _trigger_player_death() -> void:
	if not _armed or player.is_dead():
		return
	_armed = false
	player_fell_into_moat.emit()
	player.health_component.take_damage(player.health_component.current_health)
