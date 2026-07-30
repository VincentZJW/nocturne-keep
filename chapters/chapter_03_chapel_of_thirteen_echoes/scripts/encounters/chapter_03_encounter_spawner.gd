class_name Chapter03EncounterSpawner
extends Node2D

## Instantiates only the current room's persisted manifest and leaves each group dormant until entered.

@export var manifest: Chapter03EncounterManifest


func _ready() -> void:
	if manifest == null:
		push_error("Chapter03EncounterSpawner requires a manifest")
		return
	for encounter_data: Chapter03EncounterData in manifest.encounters:
		_build_encounter(encounter_data)


func get_encounter_groups() -> Array[EncounterGroup]:
	var groups: Array[EncounterGroup] = []
	for child: Node in get_children():
		var group: EncounterGroup = child as EncounterGroup
		if group != null:
			groups.append(group)
	return groups


func get_total_enemy_count() -> int:
	return manifest.enemy_count() if manifest != null else 0


func _build_encounter(data: Chapter03EncounterData) -> void:
	var group: EncounterGroup = EncounterGroup.new()
	group.name = String(data.encounter_id)
	group.encounter_name = data.encounter_id
	group.region_name = data.region_name
	group.simultaneous_attack_limit = data.simultaneous_attack_limit

	var activation_area: Area2D = Area2D.new()
	activation_area.name = "ActivationArea"
	activation_area.collision_layer = 0
	activation_area.collision_mask = 2
	var activation_shape: CollisionShape2D = CollisionShape2D.new()
	activation_shape.name = "CollisionShape2D"
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = data.activation_rect.size
	activation_shape.shape = rectangle
	activation_shape.position = data.activation_rect.position + data.activation_rect.size * 0.5
	activation_area.add_child(activation_shape)
	group.add_child(activation_area)

	var enemies_root: Node2D = Node2D.new()
	enemies_root.name = "Enemies"
	group.add_child(enemies_root)
	for spawn: Chapter03EnemySpawnData in data.spawns:
		var enemy: EnemyCombatant = _instantiate_enemy(spawn)
		if enemy != null:
			enemies_root.add_child(enemy)

	add_child(group)
	for enemy: EnemyCombatant in group.get_enemies():
		var grounded: GroundEnemyBase = enemy as GroundEnemyBase
		if grounded == null:
			continue
		var spawn: Chapter03EnemySpawnData = _find_spawn(data, StringName(enemy.get_meta("spawn_record_id", "")))
		if spawn == null:
			continue
		if spawn.has_valid_bounds():
			grounded.configure_movement_bounds(spawn.movement_bounds.x, spawn.movement_bounds.y)
		grounded.set_facing_direction(spawn.facing_direction)


func _instantiate_enemy(spawn: Chapter03EnemySpawnData) -> EnemyCombatant:
	if spawn.enemy_scene == null:
		push_error("Chapter III spawn %s has no PackedScene" % spawn.enemy_type)
		return null
	var enemy: EnemyCombatant = spawn.enemy_scene.instantiate() as EnemyCombatant
	if enemy == null:
		push_error("Chapter III spawn %s is not an EnemyCombatant" % spawn.enemy_type)
		return null
	enemy.name = String(spawn.enemy_type)
	enemy.position = spawn.local_position
	enemy.z_index = Chapter03LayerContract.ENEMIES
	enemy.z_as_relative = true
	enemy.set_meta("spawn_role", spawn.spawn_role)
	enemy.set_meta("spawn_record_id", StringName("%s@%d,%d" % [
		spawn.enemy_type, roundi(spawn.local_position.x), roundi(spawn.local_position.y)
	]))
	return enemy


func _find_spawn(data: Chapter03EncounterData, record_id: StringName) -> Chapter03EnemySpawnData:
	for spawn: Chapter03EnemySpawnData in data.spawns:
		var candidate: StringName = StringName("%s@%d,%d" % [
			spawn.enemy_type, roundi(spawn.local_position.x), roundi(spawn.local_position.y)
		])
		if candidate == record_id:
			return spawn
	return null
