extends SceneTree

## Persists the reviewed CH4-S4 fixed encounter population into room-owned manifests.

const AUTHORED_SEED: int = 40446
const CHAPTER_ROOT: String = "res://chapters/chapter_04_drowned_underkeep"
const ROOM_ROOT: String = CHAPTER_ROOT + "/scenes/rooms"
const MANIFEST_ROOT: String = CHAPTER_ROOT + "/resources/encounters"
const SPAWNER_SCRIPT: Script = preload(
	"res://chapters/chapter_04_drowned_underkeep/scripts/encounters/chapter_04_encounter_spawner.gd"
)

const ENEMY_SCENES: Dictionary = {
	&"drowned_gaoler": "res://chapters/chapter_04_drowned_underkeep/scenes/enemies/drowned_gaoler.tscn",
	&"chainbound_convict": "res://chapters/chapter_04_drowned_underkeep/scenes/enemies/chainbound_convict.tscn",
	&"mire_harpooner": "res://chapters/chapter_04_drowned_underkeep/scenes/enemies/mire_harpooner.tscn",
	&"sunken_shield_penitent": "res://chapters/chapter_04_drowned_underkeep/scenes/enemies/sunken_shield_penitent.tscn",
	&"mirefin_raider": "res://chapters/chapter_04_drowned_underkeep/scenes/enemies/mirefin_raider.tscn",
	&"bog_toad": "res://chapters/chapter_04_drowned_underkeep/scenes/enemies/bog_toad.tscn",
	&"sewer_maw": "res://chapters/chapter_04_drowned_underkeep/scenes/enemies/sewer_maw.tscn",
	&"underkeep_executioner": "res://chapters/chapter_04_drowned_underkeep/scenes/enemies/underkeep_executioner.tscn",
}

const ROOM_DEFINITIONS: Array[Dictionary] = [
	{
		"id": &"CH4_AREA_01", "file": "ch4_01_flooded_intake.tscn", "width": 1920,
		"groups": [
			[
				[&"drowned_gaoler", &"GroundSlot01", Vector2.ZERO, &"ground", "west intake floor"],
				[&"drowned_gaoler", &"GroundSlot02", Vector2.ZERO, &"ground", "west intake floor"],
			],
			[
				[&"mire_harpooner", &"PlatformSlot01", Vector2.ZERO, &"platform_ranged", "H01: west floor -> maintenance ledge"],
				[&"mirefin_raider", &"GroundSlot04", Vector2.ZERO, &"shallow_water", "east shallow channel"],
			],
		],
	},
	{
		"id": &"CH4_AREA_02", "file": "ch4_02_rusted_cellblock.tscn", "width": 2048,
		"groups": [
			[
				[&"drowned_gaoler", &"GroundSlot01", Vector2.ZERO, &"ground", "west cellblock floor"],
				[&"chainbound_convict", &"GroundSlot02", Vector2.ZERO, &"ground", "west cellblock floor"],
			],
			[
				[&"drowned_gaoler", &"PlatformSlot01", Vector2.ZERO, &"platform_heavy", "short stair and maintenance ledge"],
				[&"sunken_shield_penitent", &"GroundSlot04", Vector2.ZERO, &"ground", "east cellblock floor"],
				[&"sewer_maw", &"GroundSlot05", Vector2.ZERO, &"ambush_drain", "east floor drain"],
			],
		],
	},
	{
		"id": &"CH4_AREA_03", "file": "ch4_03_broken_chainway.tscn", "width": 2048,
		"groups": [
			[
				[&"drowned_gaoler", &"GroundSlot01", Vector2.ZERO, &"ground", "west chainway floor"],
				[&"mire_harpooner", &"PlatformSlot02", Vector2.ZERO, &"platform_ranged", "H02: west floor -> first broken-chain ledge"],
			],
			[
				[&"mirefin_raider", &"GroundSlot03", Vector2.ZERO, &"shallow_water", "east chainway channel"],
				[&"bog_toad", &"GroundSlot04", Vector2.ZERO, &"shallow_water", "east chainway channel"],
			],
		],
	},
	{
		"id": &"CH4_AREA_04", "file": "ch4_04_harpoon_watch_gallery.tscn", "width": 2176,
		"groups": [
			[
				[&"drowned_gaoler", &"GroundSlot01", Vector2.ZERO, &"ground", "west gallery floor"],
				[&"mire_harpooner", &"PlatformSlot01", Vector2.ZERO, &"platform_ranged", "H03: west floor -> low watch ledge"],
			],
			[
				[&"sunken_shield_penitent", &"PlatformSlot03", Vector2.ZERO, &"platform_heavy", "central stair -> reinforced gallery"],
				[&"mire_harpooner", &"PlatformSlot04", Vector2.ZERO, &"platform_ranged", "H04: east floor -> low watch ledge"],
				[&"mirefin_raider", &"GroundSlot05", Vector2.ZERO, &"shallow_water", "east gallery channel"],
			],
		],
	},
	{
		"id": &"CH4_AREA_05", "file": "ch4_05_cistern_of_the_changed.tscn", "width": 2176,
		"groups": [
			[
				[&"chainbound_convict", &"GroundSlot01", Vector2.ZERO, &"ground", "west cistern floor"],
				[&"mirefin_raider", &"GroundSlot02", Vector2.ZERO, &"shallow_water", "west cistern channel"],
			],
			[
				[&"sewer_maw", &"GroundSlot03", Vector2.ZERO, &"ambush_drain", "central cistern drain"],
				[&"mirefin_raider", &"GroundSlot04", Vector2.ZERO, &"shallow_water", "east cistern channel"],
				[&"bog_toad", &"GroundSlot05", Vector2.ZERO, &"shallow_water", "east cistern channel"],
			],
		],
	},
	{
		"id": &"CH4_AREA_07", "file": "ch4_07_leech_sluice.tscn", "width": 1920,
		"groups": [
			[
				[&"drowned_gaoler", &"GroundSlot01", Vector2.ZERO, &"ground", "west sluice floor"],
				[&"sewer_maw", &"GroundSlot02", Vector2.ZERO, &"ambush_drain", "west sluice drain"],
			],
			[
				[&"sewer_maw", &"GroundSlot03", Vector2.ZERO, &"ambush_drain", "east sluice drain"],
				[&"mirefin_raider", &"GroundSlot04", Vector2.ZERO, &"shallow_water", "east sluice channel"],
			],
		],
	},
	{
		"id": &"CH4_AREA_08", "file": "ch4_08_gaolers_workshop.tscn", "width": 2176,
		"groups": [
			[
				[&"drowned_gaoler", &"GroundSlot01", Vector2.ZERO, &"ground", "west workshop floor"],
				[&"sunken_shield_penitent", &"PlatformSlot01", Vector2(-60.0, 0.0), &"platform_heavy", "west stair -> workshop gantry"],
			],
			[
				[&"chainbound_convict", &"GroundSlot03", Vector2.ZERO, &"ground", "central workshop floor"],
				[&"underkeep_executioner", &"PlatformSlot01", Vector2(60.0, 0.0), &"platform_heavy", "central stair -> workshop gantry"],
				[&"mire_harpooner", &"PlatformSlot02", Vector2.ZERO, &"platform_ranged", "H05: east floor -> ranged gantry"],
			],
		],
	},
	{
		"id": &"CH4_AREA_09", "file": "ch4_09_soul_cage_registry.tscn", "width": 2176,
		"groups": [
			[
				[&"chainbound_convict", &"GroundSlot01", Vector2.ZERO, &"ground", "west registry floor"],
				[&"drowned_gaoler", &"PlatformSlot01", Vector2.ZERO, &"platform_heavy", "west archive step -> cage ledge"],
			],
			[
				[&"sunken_shield_penitent", &"GroundSlot03", Vector2.ZERO, &"ground", "east registry floor"],
				[&"mire_harpooner", &"PlatformSlot02", Vector2.ZERO, &"platform_ranged", "H06: east archive step -> cage ledge"],
			],
		],
	},
	{
		"id": &"CH4_AREA_10", "file": "ch4_10_floodgate_engine_hall.tscn", "width": 2304,
		"groups": [
			[
				[&"sunken_shield_penitent", &"GroundSlot01", Vector2.ZERO, &"ground", "west engine floor"],
				[&"mirefin_raider", &"GroundSlot02", Vector2.ZERO, &"shallow_water", "west engine channel"],
			],
			[
				[&"chainbound_convict", &"PlatformSlot02", Vector2.ZERO, &"platform_heavy", "central machinery stair -> heavy gantry"],
				[&"bog_toad", &"GroundSlot04", Vector2.ZERO, &"shallow_water", "east engine channel"],
				[&"bog_toad", &"GroundSlot05", Vector2.ZERO, &"shallow_water", "east engine channel"],
			],
		],
	},
	{
		"id": &"CH4_AREA_11", "file": "ch4_11_final_lock_approach.tscn", "width": 2304,
		"groups": [
			[
				[&"drowned_gaoler", &"GroundSlot01", Vector2.ZERO, &"ground", "west final-lock floor"],
				[&"chainbound_convict", &"GroundSlot02", Vector2.ZERO, &"ground", "west final-lock floor"],
			],
			[
				[&"sunken_shield_penitent", &"GroundSlot03", Vector2.ZERO, &"ground", "east final-lock floor"],
				[&"mire_harpooner", &"PlatformSlot01", Vector2.ZERO, &"platform_ranged", "H07: east floor -> final-lock watch ledge"],
				[&"underkeep_executioner", &"GroundSlot05", Vector2.ZERO, &"ground", "east execution bay"],
			],
		],
	},
]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(MANIFEST_ROOT))
	var saved_rooms: int = 0
	var total_enemies: int = 0
	for room_definition: Dictionary in ROOM_DEFINITIONS:
		var result: Dictionary = _build_room(room_definition)
		if not bool(result.get("ok", false)):
			quit(1)
			return
		saved_rooms += 1
		total_enemies += int(result.get("enemy_count", 0))
	print("CH4-S4 encounter authoring complete: %d rooms, %d enemies, seed %d" % [
		saved_rooms, total_enemies, AUTHORED_SEED,
	])
	quit(0 if saved_rooms == 10 and total_enemies == 46 else 1)


func _build_room(definition: Dictionary) -> Dictionary:
	var room_path: String = "%s/%s" % [ROOM_ROOT, String(definition["file"])]
	var packed_room: PackedScene = load(room_path) as PackedScene
	if packed_room == null:
		push_error("Unable to load Chapter IV room: %s" % room_path)
		return {"ok": false}
	var room: Chapter04Room = packed_room.instantiate() as Chapter04Room
	if room == null:
		push_error("Chapter IV room has wrong root type: %s" % room_path)
		return {"ok": false}
	var marker_root: Node2D = room.get_node_or_null("FutureEncounterSpawns") as Node2D
	if marker_root == null:
		push_error("Chapter IV room lacks FutureEncounterSpawns: %s" % room_path)
		room.queue_free()
		return {"ok": false}

	var manifest := Chapter04EncounterManifest.new()
	manifest.room_id = definition["id"] as StringName
	manifest.authored_seed = AUTHORED_SEED
	manifest.room_width = int(definition["width"])
	var marker_lookup: Dictionary = {}
	for child: Node in marker_root.get_children():
		var marker: Marker2D = child as Marker2D
		if marker == null:
			continue
		marker_lookup[marker.name] = marker
		manifest.spawn_points.append(_snapshot_marker(manifest, marker))

	var type_counts: Dictionary = {}
	var group_definitions: Array = definition["groups"] as Array
	for group_index: int in range(group_definitions.size()):
		var encounter := Chapter04EncounterData.new()
		encounter.encounter_id = StringName("%s_ENCOUNTER_%02d" % [manifest.room_id, group_index + 1])
		encounter.room_id = manifest.room_id
		encounter.region_name = StringName("%s_REGION_%02d" % [manifest.room_id, group_index + 1])
		encounter.sequence_index = group_index
		encounter.activation_rect = _activation_rect(manifest.room_width, group_index)
		encounter.simultaneous_attack_limit = 2
		var spawn_definitions: Array = group_definitions[group_index] as Array
		for spawn_definition: Array in spawn_definitions:
			var enemy_type: StringName = spawn_definition[0] as StringName
			var marker_id: StringName = spawn_definition[1] as StringName
			var marker: Marker2D = marker_lookup.get(marker_id) as Marker2D
			if marker == null:
				push_error("%s lacks marker %s" % [manifest.room_id, marker_id])
				room.queue_free()
				return {"ok": false}
			var next_type_index: int = int(type_counts.get(enemy_type, 0)) + 1
			type_counts[enemy_type] = next_type_index
			encounter.spawns.append(_make_spawn(
				manifest,
				enemy_type,
				marker,
				spawn_definition[2] as Vector2,
				spawn_definition[3] as StringName,
				String(spawn_definition[4]),
				next_type_index
			))
		manifest.encounters.append(encounter)

	var manifest_path: String = "%s/%s.tres" % [MANIFEST_ROOT, String(manifest.room_id).to_lower()]
	if ResourceSaver.save(manifest, manifest_path) != OK:
		push_error("Failed to save Chapter IV manifest: %s" % manifest_path)
		room.queue_free()
		return {"ok": false}
	var existing_spawner: Node = room.get_node_or_null("EncounterSpawner")
	if existing_spawner != null:
		room.remove_child(existing_spawner)
		existing_spawner.free()
	var spawner := Chapter04EncounterSpawner.new()
	spawner.name = "EncounterSpawner"
	spawner.set_script(SPAWNER_SCRIPT)
	spawner.manifest = load(manifest_path) as Chapter04EncounterManifest
	room.add_child(spawner)
	spawner.owner = room
	room.set_meta("formal_encounters_populated", true)
	room.set_meta("encounter_authored_seed", AUTHORED_SEED)
	var output := PackedScene.new()
	if output.pack(room) != OK or ResourceSaver.save(output, room_path) != OK:
		push_error("Failed to persist Chapter IV encounter room: %s" % room_path)
		room.queue_free()
		return {"ok": false}
	var count: int = manifest.enemy_count()
	room.queue_free()
	return {"ok": true, "enemy_count": count}


func _snapshot_marker(manifest: Chapter04EncounterManifest, marker: Marker2D) -> Chapter04SpawnPointData:
	var data := Chapter04SpawnPointData.new()
	data.spawn_point_id = marker.name
	data.room_id = manifest.room_id
	data.semantic_tag = StringName(String(marker.get_meta("semantic_tag", "ground")))
	data.local_position = marker.position
	data.platform_width = float(marker.get_meta("platform_width", 0.0))
	data.movement_bounds = _movement_bounds(manifest.room_width, marker, Vector2.ZERO)
	return data


func _make_spawn(
		manifest: Chapter04EncounterManifest,
		enemy_type: StringName,
		marker: Marker2D,
		offset: Vector2,
		spawn_role: StringName,
		access_route: String,
		type_index: int
) -> Chapter04EnemySpawnData:
	var data := Chapter04EnemySpawnData.new()
	data.spawn_record_id = StringName("%s_%s_%02d" % [
		manifest.room_id, String(enemy_type).to_upper(), type_index,
	])
	data.enemy_type = enemy_type
	data.spawn_point_id = marker.name
	data.spawn_role = spawn_role
	data.enemy_scene = load(String(ENEMY_SCENES[enemy_type])) as PackedScene
	data.local_position = marker.position + offset
	data.movement_bounds = _movement_bounds(manifest.room_width, marker, offset)
	data.facing_direction = -1.0 if data.local_position.x > manifest.room_width * 0.5 else 1.0
	data.access_route = access_route
	return data


func _movement_bounds(room_width: int, marker: Marker2D, offset: Vector2) -> Vector2:
	var platform_width: float = float(marker.get_meta("platform_width", 0.0))
	if platform_width > 0.0:
		var margin: float = minf(24.0, platform_width * 0.2)
		return Vector2(
			marker.position.x - platform_width * 0.5 + margin,
			marker.position.x + platform_width * 0.5 - margin
		)
	var center_x: float = marker.position.x + offset.x
	return Vector2(maxf(96.0, center_x - 130.0), minf(float(room_width) - 96.0, center_x + 130.0))


func _activation_rect(room_width: int, group_index: int) -> Rect2:
	var half_width: float = float(room_width) * 0.5
	if group_index == 0:
		return Rect2(320.0, 0.0, half_width - 352.0, 720.0)
	return Rect2(half_width + 32.0, 0.0, half_width - 352.0, 720.0)
