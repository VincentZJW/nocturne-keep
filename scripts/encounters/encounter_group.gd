class_name EncounterGroup
extends Node2D

## Hand-authored, one-shot activation boundary for a small mixed-enemy encounter.

signal encounter_activated(encounter_name: StringName)

@export var encounter_name: StringName = &"EncounterGroup"
@export_range(1, 3, 1) var simultaneous_attack_limit: int = 2
@export var start_activated: bool = false
@export_node_path("Area2D") var activation_area_path: NodePath = NodePath("ActivationArea")
@export_node_path("Node2D") var enemies_root_path: NodePath = NodePath("Enemies")

@onready var activation_area: Area2D = get_node_or_null(activation_area_path) as Area2D
@onready var enemies_root: Node2D = get_node_or_null(enemies_root_path) as Node2D

var is_activated: bool = false


func _ready() -> void:
	if activation_area == null or enemies_root == null:
		push_error("EncounterGroup requires ActivationArea and Enemies")
		return
	activation_area.body_entered.connect(_on_activation_body_entered)
	for enemy: EnemyCombatant in get_enemies():
		enemy.set_ai_active(false)
	if start_activated:
		activate()


func activate(player: Player = null) -> bool:
	if is_activated:
		return false
	is_activated = true
	activation_area.set_deferred("monitoring", false)
	for enemy: EnemyCombatant in get_enemies():
		enemy.set_ai_active(true)
		if (
			player != null
			and not player.is_dead()
			and enemy.global_position.distance_to(player.global_position) <= enemy.get_detection_range()
		):
			enemy.set_target(player)
	encounter_activated.emit(encounter_name)
	return true


func get_guards() -> Array[CastleGuard]:
	var guards: Array[CastleGuard] = []
	if enemies_root == null:
		return guards
	for child: Node in enemies_root.get_children():
		var guard: CastleGuard = child as CastleGuard
		if guard != null:
			guards.append(guard)
	return guards


func get_enemies() -> Array[EnemyCombatant]:
	var enemies: Array[EnemyCombatant] = []
	if enemies_root == null:
		return enemies
	for child: Node in enemies_root.get_children():
		var enemy: EnemyCombatant = child as EnemyCombatant
		if enemy != null:
			enemies.append(enemy)
	return enemies


func get_alive_enemy_count() -> int:
	var count: int = 0
	for enemy: EnemyCombatant in get_enemies():
		if is_instance_valid(enemy) and not enemy.is_dead():
			count += 1
	return count


func get_engaged_enemy_count() -> int:
	var count: int = 0
	for enemy: EnemyCombatant in get_enemies():
		if not is_instance_valid(enemy) or enemy.is_dead():
			continue
		if enemy.get_state_name() in [
			&"Chase", &"Attack", &"Aim", &"Shoot", &"Reload", &"Retreat",
			&"Block", &"GuardBreak", &"Hurt",
		]:
			count += 1
	return count


func get_attacking_enemy_count() -> int:
	var count: int = 0
	for enemy: EnemyCombatant in get_enemies():
		if is_instance_valid(enemy) and enemy.get_state_name() in [&"Attack", &"Shoot"]:
			count += 1
	return count


func _on_activation_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player != null:
		activate(player)
