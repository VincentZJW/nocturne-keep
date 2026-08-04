extends SceneTree

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep"
const COMBAT_ROOM_IDS: Array[StringName] = [
	&"CH4_AREA_01", &"CH4_AREA_02", &"CH4_AREA_03", &"CH4_AREA_04", &"CH4_AREA_05",
	&"CH4_AREA_07", &"CH4_AREA_08", &"CH4_AREA_09", &"CH4_AREA_10", &"CH4_AREA_11",
]
const SUPPORT_ROOM_INDICES: Array[int] = [0, 6, 12, 13, 14, 15, 16]
const EXPECTED_TYPES: Dictionary = {
	&"drowned_gaoler": 10,
	&"chainbound_convict": 6,
	&"mire_harpooner": 7,
	&"sunken_shield_penitent": 6,
	&"mirefin_raider": 7,
	&"bog_toad": 4,
	&"sewer_maw": 4,
	&"underkeep_executioner": 2,
}

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var type_totals: Dictionary = {}
	var total_enemies: int = 0
	var total_groups: int = 0
	var total_elevated: int = 0
	var harpooners_on_platforms: int = 0
	for room_id: StringName in COMBAT_ROOM_IDS:
		var path: String = "%s/resources/encounters/%s.tres" % [ROOT, String(room_id).to_lower()]
		var manifest: Chapter04EncounterManifest = load(path) as Chapter04EncounterManifest
		_check(manifest != null, "%s failed to load" % path)
		if manifest == null:
			continue
		_check(manifest.room_id == room_id, "%s room id mismatch" % room_id)
		_check(manifest.authored_seed == 40446, "%s seed mismatch" % room_id)
		_check(manifest.encounter_count() == 2, "%s must contain exactly two groups" % room_id)
		_check(manifest.enemy_count() in [4, 5], "%s must contain four or five enemies" % room_id)
		var expected_group_sizes: Array[int] = [2, manifest.enemy_count() - 2]
		for group_index: int in manifest.encounters.size():
			var encounter: Chapter04EncounterData = manifest.encounters[group_index]
			_check(encounter.spawns.size() == expected_group_sizes[group_index], "%s group split mismatch" % encounter.encounter_id)
			_check(encounter.simultaneous_attack_limit == 2, "%s attack limit metadata mismatch" % encounter.encounter_id)
			for spawn: Chapter04EnemySpawnData in encounter.spawns:
				_check(spawn.enemy_scene != null, "%s PackedScene missing" % spawn.spawn_record_id)
				_check(spawn.has_valid_bounds(), "%s movement bounds invalid" % spawn.spawn_record_id)
				_check(spawn.local_position.x >= 96.0 and spawn.local_position.x <= manifest.room_width - 96.0, "%s x is outside room safety envelope" % spawn.spawn_record_id)
				type_totals[spawn.enemy_type] = int(type_totals.get(spawn.enemy_type, 0)) + 1
				if spawn.spawn_role in [&"platform_ranged", &"platform_heavy"]:
					total_elevated += 1
					_check(not spawn.access_route.is_empty(), "%s elevated spawn needs an authored access route" % spawn.spawn_record_id)
				if spawn.enemy_type == &"mire_harpooner" and spawn.spawn_role == &"platform_ranged":
					harpooners_on_platforms += 1
		total_enemies += manifest.enemy_count()
		total_groups += manifest.encounter_count()
		var room_scene_path: String = _room_scene_path(room_id)
		var room_scene: PackedScene = load(room_scene_path) as PackedScene
		var room: Chapter04Room = room_scene.instantiate() as Chapter04Room if room_scene != null else null
		_check(room != null, "%s room scene failed to instantiate" % room_id)
		if room != null:
			var spawner: Chapter04EncounterSpawner = room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
			_check(spawner != null and spawner.manifest != null, "%s room lacks persisted spawner" % room_id)
			if spawner != null and spawner.manifest != null:
				_check(spawner.manifest.resource_path == path, "%s room references wrong manifest" % room_id)
			room.free()
	for enemy_type: StringName in EXPECTED_TYPES:
		_check(int(type_totals.get(enemy_type, 0)) == int(EXPECTED_TYPES[enemy_type]), "%s roster total mismatch" % enemy_type)
	_check(total_enemies == 46, "formal roster must total 46 enemies")
	_check(total_groups == 20, "formal route must total 20 groups")
	_check(total_elevated == 13, "formal route must total 13 elevated starts")
	_check(harpooners_on_platforms == 7, "all seven Harpooners must start on reviewed platforms")
	for room_index: int in SUPPORT_ROOM_INDICES:
		var room_scene: PackedScene = load(_support_room_scene_path(room_index)) as PackedScene
		var room: Chapter04Room = room_scene.instantiate() as Chapter04Room if room_scene != null else null
		_check(room != null, "support room %02d failed to instantiate" % room_index)
		if room != null:
			_check(not room.has_node("EncounterSpawner"), "support room %02d must remain enemy-free" % room_index)
			room.free()
	_finish()


func _room_scene_path(room_id: StringName) -> String:
	var by_id: Dictionary = {
		&"CH4_AREA_01": "ch4_01_flooded_intake.tscn",
		&"CH4_AREA_02": "ch4_02_rusted_cellblock.tscn",
		&"CH4_AREA_03": "ch4_03_broken_chainway.tscn",
		&"CH4_AREA_04": "ch4_04_harpoon_watch_gallery.tscn",
		&"CH4_AREA_05": "ch4_05_cistern_of_the_changed.tscn",
		&"CH4_AREA_07": "ch4_07_leech_sluice.tscn",
		&"CH4_AREA_08": "ch4_08_gaolers_workshop.tscn",
		&"CH4_AREA_09": "ch4_09_soul_cage_registry.tscn",
		&"CH4_AREA_10": "ch4_10_floodgate_engine_hall.tscn",
		&"CH4_AREA_11": "ch4_11_final_lock_approach.tscn",
	}
	return "%s/scenes/rooms/%s" % [ROOT, String(by_id[room_id])]


func _support_room_scene_path(index: int) -> String:
	var files: Dictionary = {
		0: "ch4_00_drowned_threshold.tscn",
		6: "ch4_06_dry_gaolers_cell.tscn",
		12: "ch4_12_last_gaol_checkpoint.tscn",
		13: "ch4_13_soul_lock_antechamber.tscn",
		14: "ch4_14_core_of_drowned_gaol.tscn",
		15: "ch4_15_broken_soul_reservoir.tscn",
		16: "ch4_16_hall_of_drowned_memories.tscn",
	}
	return "%s/scenes/rooms/%s" % [ROOT, String(files[index])]


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CH4 S4 MANIFESTS | PASS rooms=10 groups=20 enemies=46 elevated=13 harpooners=7 seed=40446")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH4 S4 MANIFESTS: %s" % failure)
	quit(1)
