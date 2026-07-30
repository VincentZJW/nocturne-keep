class_name Chapter03EncounterManifest
extends Resource

## Fixed-seed development output persisted as a formal room manifest.

@export var room_id: StringName = &""
@export var authored_seed: int = 31372026
@export var encounters: Array[Chapter03EncounterData] = []


func enemy_count() -> int:
	var total: int = 0
	for encounter: Chapter03EncounterData in encounters:
		total += encounter.enemy_count()
	return total


func encounter_count() -> int:
	return encounters.size()


func count_enemy_type(enemy_type: StringName) -> int:
	var total: int = 0
	for encounter: Chapter03EncounterData in encounters:
		for spawn: Chapter03EnemySpawnData in encounter.spawns:
			if spawn.enemy_type == enemy_type:
				total += 1
	return total
