class_name Chapter02EncounterRuntime
extends Node2D

## Finite Chapter II encounter composition. Saved Chapter02EnemySpawnPoint nodes
## are the source of truth for placement, activation and bounded platform motion.

const GROUND_ORIGIN_OFFSET: Vector2 = Vector2(0.0, -28.0)
const ACTIVATION_RANGE_Y: float = 430.0
const UPDATE_INTERVAL: float = 0.15

@export_node_path("Player") var player_path: NodePath
@export_node_path("Node2D") var enemies_parent_path: NodePath
@export_node_path("Node2D") var spawn_points_path: NodePath

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var enemies_parent: Node2D = get_node_or_null(enemies_parent_path) as Node2D
@onready var spawn_points: Node2D = get_node_or_null(spawn_points_path) as Node2D

var _groups: Array[Node2D] = []
var _update_timer: float = 0.0


func _ready() -> void:
	if player == null or enemies_parent == null or spawn_points == null:
		push_error("Chapter02EncounterRuntime requires Player, Enemies and EnemySpawnPoints")
		set_process(false)
		return
	_build_encounters()


func _process(delta: float) -> void:
	_update_timer = maxf(0.0, _update_timer - delta)
	if _update_timer > 0.0:
		return
	_update_timer = UPDATE_INTERVAL
	for group: Node2D in _groups:
		var center: Vector2 = group.get_meta("activation_center", Vector2.ZERO) as Vector2
		var activation_range_x: float = float(group.get_meta("activation_range_x", 720.0))
		var engaged: bool = (
			absf(player.global_position.x - center.x) <= activation_range_x
			and absf(player.global_position.y - center.y) <= ACTIVATION_RANGE_Y
		)
		_set_group_active(group, engaged)


func get_encounter_count() -> int:
	return _groups.size()


func get_enemy_count() -> int:
	var count: int = 0
	for group: Node2D in _groups:
		for child: Node in group.get_children():
			if child is EnemyCombatant:
				count += 1
	return count


func _build_encounters() -> void:
	var groups_by_id: Dictionary = {}
	for child: Node in spawn_points.get_children():
		var spawn: Chapter02EnemySpawnPoint = child as Chapter02EnemySpawnPoint
		if spawn == null:
			continue
		if not spawn.is_valid_spawn():
			push_error("Invalid Chapter II enemy spawn: %s" % spawn.get_path())
			continue
		var group: Node2D = groups_by_id.get(spawn.encounter_id) as Node2D
		if group == null:
			group = Node2D.new()
			group.name = String(spawn.encounter_id)
			group.set_meta("floor", spawn.floor_number)
			group.set_meta("activation_center", spawn.activation_center)
			group.set_meta("activation_range_x", spawn.activation_range_x)
			enemies_parent.add_child(group)
			_groups.append(group)
			groups_by_id[spawn.encounter_id] = group
		_spawn_enemy(group, spawn, group.get_child_count() + 1)
	for group: Node2D in _groups:
		_set_group_active(group, false)


func _spawn_enemy(group: Node2D, spawn: Chapter02EnemySpawnPoint, index: int) -> void:
	var enemy: Node2D = spawn.enemy_scene.instantiate() as Node2D
	if enemy == null:
		push_error("Unable to instantiate Chapter II enemy for %s" % group.name)
		return
	var role: String = String(spawn.enemy_role)
	enemy.name = "%s_%02d_%s" % [group.name, index, role]
	var foot_position: Vector2 = spawn.global_position
	enemy.position = foot_position if spawn.is_airborne() else foot_position + GROUND_ORIGIN_OFFSET
	if spawn.uses_bounded_movement() and enemy.has_method("configure_movement_bounds"):
		enemy.call(
			"configure_movement_bounds",
			spawn.platform_left_bound,
			spawn.platform_right_bound
		)
	group.add_child(enemy)
	enemy.set_meta("authored_foot_position", foot_position)
	enemy.set_meta("spawn_uses_global_position", true)
	enemy.set_meta("spawn_path", spawn.get_path())
	enemy.set_meta("placement", Chapter02EnemySpawnPoint.Placement.keys()[spawn.placement])


func _set_group_active(group: Node2D, active: bool) -> void:
	for child: Node in group.get_children():
		if child.has_method("set_ai_active"):
			child.call("set_ai_active", active)


func prepare_floor_change() -> void:
	for group: Node2D in _groups:
		_set_group_active(group, false)
		_clear_transient_projectiles(group)


func get_placement_counts() -> Dictionary:
	var counts: Dictionary = {"GROUND": 0, "PLATFORM": 0, "CEILING_AIR": 0}
	for child: Node in spawn_points.get_children():
		var spawn: Chapter02EnemySpawnPoint = child as Chapter02EnemySpawnPoint
		if spawn == null:
			continue
		var key: String = Chapter02EnemySpawnPoint.Placement.keys()[spawn.placement]
		counts[key] = int(counts.get(key, 0)) + 1
	return counts


func _clear_transient_projectiles(node: Node) -> void:
	for child: Node in node.get_children():
		if child is CrossbowBolt or child is BloodCandleProjectile:
			child.queue_free()
		else:
			_clear_transient_projectiles(child)
