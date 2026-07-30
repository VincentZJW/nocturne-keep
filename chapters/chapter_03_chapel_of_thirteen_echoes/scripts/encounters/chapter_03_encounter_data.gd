class_name Chapter03EncounterData
extends Resource

## Saved activation group. Formal runtime never randomizes this data.

@export var encounter_id: StringName = &""
@export var region_name: StringName = &""
@export var activation_rect: Rect2 = Rect2(0.0, 0.0, 640.0, 720.0)
@export_range(1, 4, 1) var simultaneous_attack_limit: int = 2
@export var spawns: Array[Chapter03EnemySpawnData] = []


func enemy_count() -> int:
	return spawns.size()
