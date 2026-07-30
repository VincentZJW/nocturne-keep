extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const ROOM_IDS: Array[StringName] = [
	&"CH3_NAVE_ENTRY",
	&"CH3_MAIN_NAVE_FRONT",
	&"CH3_MAIN_NAVE_REAR",
	&"CH3_CONFESSIONALS",
	&"CH3_CHOIR_GALLERY",
	&"CH3_STAINED_GLASS_HALL",
	&"CH3_ARCHIVE_RELIQUARY",
	&"CH3_BLOOD_CANDLE_CHAPEL",
	&"CH3_PRE_BOSS_COMBAT",
]
const EXPECTED_COUNTS: Dictionary[StringName, int] = {
	&"BellchainPenitent": 22,
	&"CenserExecutioner": 8,
	&"SilentChorister": 12,
	&"StainedGlassSeraph": 10,
	&"ConfessionalWraith": 10,
	&"ThirteenthScribe": 10,
}
const EXPECTED_ROOM_TOTALS: Dictionary[StringName, int] = {
	&"CH3_NAVE_ENTRY": 4,
	&"CH3_MAIN_NAVE_FRONT": 8,
	&"CH3_MAIN_NAVE_REAR": 8,
	&"CH3_CONFESSIONALS": 8,
	&"CH3_CHOIR_GALLERY": 9,
	&"CH3_STAINED_GLASS_HALL": 8,
	&"CH3_ARCHIVE_RELIQUARY": 8,
	&"CH3_BLOOD_CANDLE_CHAPEL": 8,
	&"CH3_PRE_BOSS_COMBAT": 11,
}
const REQUIRED_DEBUG_SPAWNS: Array[StringName] = [
	&"CH3_START", &"CH3_OPENING_ENCOUNTER", &"CH3_MAIN_NAVE", &"CH3_CONFESSIONALS",
	&"CH3_CHOIR_GALLERY", &"CH3_STAINED_GLASS_HALL", &"CH3_ARCHIVE",
	&"CH3_BLOOD_CANDLE_ZONE", &"CH3_PRE_BOSS_COMBAT",
]

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var type_counts: Dictionary[StringName, int] = {}
	var total_enemies: int = 0
	var total_encounters: int = 0
	var platform_ranged: int = 0
	var air_anchors: int = 0
	var ambushers: int = 0
	var heavy_ground: int = 0
	for room_id: StringName in ROOM_IDS:
		var definition: Chapter03RoomDefinition = load(
			"%s/resources/encounters/%s.tres" % [ROOT, String(room_id).to_lower()]
		) as Chapter03RoomDefinition
		_expect(definition != null, "%s definition loads" % room_id)
		if definition == null:
			continue
		_expect(definition.is_valid(), "%s definition is structurally valid" % room_id)
		_expect(definition.manifest.authored_seed == 31372026, "%s persists fixed seed" % room_id)
		_expect(definition.manifest.enemy_count() == EXPECTED_ROOM_TOTALS[room_id], "%s enemy total" % room_id)
		total_enemies += definition.manifest.enemy_count()
		total_encounters += definition.manifest.encounter_count()
		for encounter: Chapter03EncounterData in definition.manifest.encounters:
			_expect(encounter.enemy_count() >= 1 and encounter.enemy_count() <= 4, "%s bounded encounter size" % encounter.encounter_id)
			_expect(encounter.simultaneous_attack_limit <= 3, "%s attack limit" % encounter.encounter_id)
			for spawn: Chapter03EnemySpawnData in encounter.spawns:
				type_counts[spawn.enemy_type] = type_counts.get(spawn.enemy_type, 0) + 1
				_expect(_role_matches(spawn), "%s role matches %s" % [spawn.enemy_type, spawn.spawn_role])
				_expect(_inside_room(spawn.local_position, definition.room_size), "%s is inside %s" % [spawn.enemy_type, room_id])
				match spawn.spawn_role:
					&"platform_ranged":
						platform_ranged += 1
						_expect(_has_supporting_platform(spawn, definition), "%s has reachable formal platform" % spawn.enemy_type)
					&"air_anchor":
						air_anchors += 1
						_expect(spawn.local_position.y >= 280.0 and spawn.local_position.y <= 360.0, "%s air height" % spawn.enemy_type)
					&"confessional_spawn":
						ambushers += 1
					&"ground_heavy":
						heavy_ground += 1
		var scene: PackedScene = load(
			"%s/scenes/rooms/%s.tscn" % [ROOT, String(room_id).to_lower()]
		) as PackedScene
		_expect(scene != null, "%s formal room scene loads" % room_id)
		if scene != null:
			await _audit_runtime_room(scene, room_id)
	_expect(total_enemies == 72, "formal total is exactly 72")
	_expect(total_encounters == 20, "formal route has 20 EncounterGroups")
	for enemy_type: StringName in EXPECTED_COUNTS:
		_expect(type_counts.get(enemy_type, 0) == EXPECTED_COUNTS[enemy_type], "%s exact count" % enemy_type)
	_expect(platform_ranged == 22, "all 22 grounded ranged units use platforms")
	_expect(air_anchors == 10, "all 10 Seraphs use air anchors")
	_expect(ambushers == 10, "all 10 Wraiths use confession ambush anchors")
	_expect(heavy_ground == 8, "all 8 Executioners use ground-heavy slots")
	_audit_opening_encounter()
	_audit_safe_rooms()
	_audit_main_debug_spawns()
	if _failures.is_empty():
		print(
			"CH3_ENEMY_DISTRIBUTION_B0_B5 PASS rooms=9 encounters=20 enemies=72 "
			+ "bellchain=22 executioner=8 chorister=12 seraph=10 wraith=10 scribe=10 "
			+ "platform_ranged=22 air=10 ambush=10 heavy=8 seed=31372026"
		)
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH3_ENEMY_DISTRIBUTION_B0_B5: %s" % failure)
	quit(1)


func _audit_runtime_room(scene: PackedScene, room_id: StringName) -> void:
	var room: Chapter03EncounterRoom = scene.instantiate() as Chapter03EncounterRoom
	_expect(room != null, "%s root is Chapter03EncounterRoom" % room_id)
	if room == null:
		return
	root.add_child(room)
	await process_frame
	var groups: Array[EncounterGroup] = room.encounter_spawner.get_encounter_groups()
	_expect(groups.size() == room.get_manifest().encounter_count(), "%s runtime EncounterGroup count" % room_id)
	for group: EncounterGroup in groups:
		_expect(not group.is_activated, "%s starts dormant" % group.encounter_name)
		for enemy: EnemyCombatant in group.get_enemies():
			_expect(enemy.process_mode == Node.PROCESS_MODE_DISABLED, "%s inactive enemy process disabled" % group.encounter_name)
	if not groups.is_empty():
		groups[0].activate()
		for enemy: EnemyCombatant in groups[0].get_enemies():
			_expect(enemy.process_mode == Node.PROCESS_MODE_INHERIT, "%s activates only its group" % groups[0].encounter_name)
		for group_index: int in range(1, groups.size()):
			_expect(not groups[group_index].is_activated, "%s does not pre-activate" % groups[group_index].encounter_name)
	room.queue_free()
	await process_frame


func _audit_opening_encounter() -> void:
	var definition: Chapter03RoomDefinition = load(
		ROOT + "/resources/encounters/ch3_nave_entry.tres"
	) as Chapter03RoomDefinition
	_expect(definition.manifest.encounters.size() == 2, "opening uses staged two-part activation")
	_expect(definition.manifest.encounters[0].enemy_count() == 3, "opening starts with three visible combatants")
	_expect(definition.manifest.encounters[1].enemy_count() == 1, "opening Wraith activates later")
	_expect(definition.manifest.count_enemy_type(&"BellchainPenitent") == 2, "opening has two Bellchain Penitents")
	_expect(definition.manifest.count_enemy_type(&"SilentChorister") == 1, "opening has one platform Chorister")
	_expect(definition.manifest.count_enemy_type(&"ConfessionalWraith") == 1, "opening has one delayed Wraith")


func _audit_safe_rooms() -> void:
	for path: String in [
		ROOT + "/scenes/rooms/ch3_chapel_vestibule.tscn",
		ROOT + "/scenes/rooms/ch3_boss_checkpoint.tscn",
		ROOT + "/scenes/rooms/ch3_boss_ante_room.tscn",
		ROOT + "/scenes/rooms/ch3_post_boss_room.tscn",
		ROOT + "/scenes/rooms/ch3_underkeep_room.tscn",
	]:
		var text: String = FileAccess.get_file_as_string(path)
		_expect("EncounterSpawner" not in text and "scenes/enemies/" not in text, "%s remains enemy-free" % path.get_file())


func _audit_main_debug_spawns() -> void:
	var project_text: String = FileAccess.get_file_as_string("res://project.godot")
	_expect(
		"run/main_scene=\"res://scenes/bootstrap/main_bootstrap.tscn\"" in project_text,
		"F5 authority remains MainBootstrap",
	)
	var profile: ChapterStartProfile = load(ROOT + "/resources/chapter/chapter_03_start_profile.tres") as ChapterStartProfile
	for spawn_id: StringName in REQUIRED_DEBUG_SPAWNS:
		_expect(spawn_id in profile.available_spawn_ids, "%s registered in formal profile" % spawn_id)
	var route_text: String = FileAccess.get_file_as_string(ROOT + "/scripts/level/chapter_03_route.gd")
	for spawn_id: StringName in REQUIRED_DEBUG_SPAWNS:
		_expect(String(spawn_id) in route_text, "%s resolves through Chapter03Route" % spawn_id)


func _role_matches(spawn: Chapter03EnemySpawnData) -> bool:
	match spawn.enemy_type:
		&"BellchainPenitent":
			return spawn.spawn_role == &"ground_light"
		&"CenserExecutioner":
			return spawn.spawn_role == &"ground_heavy"
		&"SilentChorister", &"ThirteenthScribe":
			return spawn.spawn_role == &"platform_ranged"
		&"StainedGlassSeraph":
			return spawn.spawn_role == &"air_anchor"
		&"ConfessionalWraith":
			return spawn.spawn_role == &"confessional_spawn"
	return false


func _inside_room(position: Vector2, room_size: Vector2i) -> bool:
	return position.x >= 80.0 and position.x <= room_size.x - 80.0 and position.y >= 260.0 and position.y <= 600.0


func _has_supporting_platform(spawn: Chapter03EnemySpawnData, definition: Chapter03RoomDefinition) -> bool:
	for platform_position: Vector2 in definition.platform_positions:
		if absf(spawn.local_position.x - platform_position.x) <= 90.0 and absf(spawn.local_position.y - (platform_position.y - 58.0)) <= 1.0:
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
