class_name Chapter04EncounterManifest
extends Resource

## Fixed-seed development output persisted for one formal Chapter IV combat room.

@export var room_id: StringName = &""
@export var authored_seed: int = 40446
@export var room_width: int = 1920
@export var spawn_points: Array[Chapter04SpawnPointData] = []
@export var encounters: Array[Chapter04EncounterData] = []


func enemy_count() -> int:
	var total: int = 0
	for encounter: Chapter04EncounterData in encounters:
		total += encounter.enemy_count()
	return total


func encounter_count() -> int:
	return encounters.size()


func count_enemy_type(enemy_type: StringName) -> int:
	var total: int = 0
	for encounter: Chapter04EncounterData in encounters:
		for spawn: Chapter04EnemySpawnData in encounter.spawns:
			if spawn.enemy_type == enemy_type:
				total += 1
	return total


func elevated_spawn_count() -> int:
	var total: int = 0
	for encounter: Chapter04EncounterData in encounters:
		for spawn: Chapter04EnemySpawnData in encounter.spawns:
			if spawn.spawn_role in [&"platform_ranged", &"platform_heavy"]:
				total += 1
	return total
