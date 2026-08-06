class_name Chapter04EncounterSpawner
extends Node2D

## Builds only the loaded room's saved groups and serializes activation to one group at a time.

signal active_encounter_changed(encounter_id: StringName)

const LAYER_CONTRACT: Script = preload(
	"res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_layer_contract.gd"
)

@export var manifest: Chapter04EncounterManifest

var _groups: Array[EncounterGroup] = []
var _active_group: EncounterGroup
var _activation_suspended: bool = false


func _ready() -> void:
	_activation_suspended = bool(get_parent().get_meta(&"chapter_04_activation_suspended", false))
	if manifest == null:
		push_error("Chapter04EncounterSpawner requires a manifest")
		return
	for encounter_data: Chapter04EncounterData in manifest.encounters:
		_build_encounter(encounter_data)
	call_deferred("_arm_all_dormant_groups")


func get_encounter_groups() -> Array[EncounterGroup]:
	return _groups.duplicate()


func get_total_enemy_count() -> int:
	return manifest.enemy_count() if manifest != null else 0


func get_active_encounter_id() -> StringName:
	return _active_group.encounter_name if is_instance_valid(_active_group) else &""


func set_activation_suspended(suspended: bool) -> void:
	_activation_suspended = suspended
	get_parent().set_meta(&"chapter_04_activation_suspended", suspended)
	for group: EncounterGroup in _groups:
		if group.activation_area == null or group.is_activated:
			continue
		group.activation_area.set_deferred("monitoring", not suspended)


func _build_encounter(data: Chapter04EncounterData) -> void:
	var group: EncounterGroup = EncounterGroup.new()
	group.name = String(data.encounter_id)
	group.encounter_name = data.encounter_id
	group.region_name = data.region_name
	group.simultaneous_attack_limit = data.simultaneous_attack_limit

	var activation_area: Area2D = Area2D.new()
	activation_area.name = "ActivationArea"
	activation_area.collision_layer = 0
	activation_area.collision_mask = 2
	# A freshly inserted room initially shares world space with the persistent
	# Player's previous room position. Keep monitoring off before this Area2D
	# enters the tree so no stale overlap can queue the wrong encounter.
	activation_area.monitoring = false
	activation_area.monitorable = false
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
	for spawn: Chapter04EnemySpawnData in data.spawns:
		var enemy: EnemyCombatant = _instantiate_enemy(spawn)
		if enemy != null:
			enemies_root.add_child(enemy)

	add_child(group)
	_groups.append(group)
	group.encounter_activated.connect(_on_group_activated.bind(group))
	group.encounter_cleared.connect(_on_group_cleared.bind(group))


func _instantiate_enemy(spawn: Chapter04EnemySpawnData) -> EnemyCombatant:
	if spawn.enemy_scene == null:
		push_error("Chapter IV spawn %s has no PackedScene" % spawn.spawn_record_id)
		return null
	var enemy: EnemyCombatant = spawn.enemy_scene.instantiate() as EnemyCombatant
	if enemy == null:
		push_error("Chapter IV spawn %s is not an EnemyCombatant" % spawn.spawn_record_id)
		return null
	enemy.name = String(spawn.spawn_record_id)
	enemy.position = spawn.local_position
	enemy.z_index = int(LAYER_CONTRACT.ENEMIES)
	enemy.z_as_relative = true
	enemy.set_meta("spawn_role", spawn.spawn_role)
	enemy.set_meta("spawn_point_id", spawn.spawn_point_id)
	enemy.set_meta("spawn_record_id", spawn.spawn_record_id)
	enemy.set_meta("access_route", spawn.access_route)
	var grounded: GroundEnemyBase = enemy as GroundEnemyBase
	if grounded != null:
		if spawn.has_valid_bounds():
			grounded.configure_movement_bounds(spawn.movement_bounds.x, spawn.movement_bounds.y)
		grounded.facing_direction = spawn.facing_direction
	return enemy


func _arm_all_dormant_groups() -> void:
	if _activation_suspended:
		return
	for group: EncounterGroup in _groups:
		if group.activation_area != null and not group.is_activated:
			group.activation_area.set_deferred("monitoring", true)


func _on_group_activated(_encounter_id: StringName, group: EncounterGroup) -> void:
	if _activation_suspended:
		_restore_group_to_dormant(group)
		return
	if is_instance_valid(_active_group) and _active_group != group and not _active_group.is_cleared:
		# EncounterGroup has already woken its actors before emitting this signal.
		# A competing queued overlap must be rolled back, not merely ignored.
		_restore_group_to_dormant(group)
		return
	_active_group = group
	for candidate: EncounterGroup in _groups:
		if candidate == group or candidate.is_activated or candidate.activation_area == null:
			continue
		candidate.activation_area.set_deferred("monitoring", false)
	active_encounter_changed.emit(group.encounter_name)


func _restore_group_to_dormant(group: EncounterGroup) -> void:
	if group == null or group.is_cleared:
		return
	group.is_activated = false
	if group.activation_area != null:
		group.activation_area.set_deferred("monitoring", false)
	for enemy: EnemyCombatant in group.get_enemies():
		if not is_instance_valid(enemy) or enemy.is_dead():
			continue
		enemy.set_meta(&"encounter_active", false)
		enemy.set_ai_active(false)
		enemy.process_mode = Node.PROCESS_MODE_DISABLED


func _on_group_cleared(_encounter_id: StringName, group: EncounterGroup) -> void:
	if _active_group == group:
		_active_group = null
	active_encounter_changed.emit(&"")
	for candidate: EncounterGroup in _groups:
		if candidate.is_activated or candidate.activation_area == null:
			continue
		candidate.activation_area.set_deferred("monitoring", not _activation_suspended)
		if not _activation_suspended:
			call_deferred("_activate_if_player_overlaps", candidate)


func _activate_if_player_overlaps(group: EncounterGroup) -> void:
	if group == null or group.is_activated or group.activation_area == null:
		return
	for body: Node2D in group.activation_area.get_overlapping_bodies():
		var player: Player = body as Player
		if player != null:
			group.activate(player)
			return
