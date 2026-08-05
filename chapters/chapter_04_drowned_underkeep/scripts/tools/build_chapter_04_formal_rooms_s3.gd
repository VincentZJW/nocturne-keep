extends SceneTree

const OUTPUT_DIR: String = "res://chapters/chapter_04_drowned_underkeep/scenes/rooms"
const MANIFEST_PATH: String = "res://chapters/chapter_04_drowned_underkeep/resources/rooms/chapter_04_room_manifest_s3.json"
const ROOM_SCRIPT: String = "res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_room.gd"
const EXIT_SCRIPT: String = "res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_room_exit.gd"
const CHECKPOINT_SCRIPT: String = "res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_checkpoint.gd"
const WATER_FRAMES: String = "res://chapters/chapter_04_drowned_underkeep/resources/environment/chapter_04_water_fx_frames.tres"
const MOTION_FRAMES: String = "res://chapters/chapter_04_drowned_underkeep/resources/environment/chapter_04_environment_motion_frames.tres"
const ORMUND_SCENE: String = "res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn"
const ROOT: String = "res://chapters/chapter_04_drowned_underkeep/assets/"
const FLOOR_Y: float = 620.0

const ROOMS: Array[Dictionary] = [
	{"id": &"CH4_AREA_00", "slug": "drowned_threshold", "name": "CHAPTER IV · DROWNED THRESHOLD / 淹没门槛", "function": &"transition", "width": 1792, "wall": "environment/walls/eroded_chapel_limestone_01.png", "floor": "environment/floors/wet_flagstone_strip_01.png", "water": true, "focal": [["environment/walls/chapel_prison_transition_arch.png", 560, 390], ["doors/rusted_gates/isolation_gate_01.png", 1440, 476]], "platforms": [], "slots": 0},
	{"id": &"CH4_AREA_01", "slug": "flooded_intake", "name": "CHAPTER IV · FLOODED INTAKE / 淹水引渠", "function": &"combat", "width": 1920, "wall": "environment/walls/drainage_masonry_01.png", "floor": "environment/floors/shallow_water_channel_bed_01.png", "water": true, "focal": [["environment/walls/thick_pointed_prison_arch_224.png", 420, 360], ["doors/floodgates/vertical_floodgate_01.png", 1540, 436]], "platforms": [[1152, 560, 128]], "slots": 4},
	{"id": &"CH4_AREA_02", "slug": "rusted_cellblock", "name": "CHAPTER IV · RUSTED CELLBLOCK / 锈锁牢区", "function": &"combat", "width": 2048, "wall": "environment/walls/wet_prison_brick_02.png", "floor": "environment/floors/wet_flagstone_strip_02.png", "water": true, "focal": [["environment/flooded_cells/thick_cell_front_intact.png", 400, 492], ["environment/flooded_cells/thick_cell_front_bent.png", 640, 492], ["environment/flooded_cells/thick_cell_front_open.png", 880, 492], ["doors/cell_doors/cell_door_closed.png", 1640, 500]], "platforms": [[1248, 548, 160]], "slots": 5},
	{"id": &"CH4_AREA_03", "slug": "broken_chainway", "name": "CHAPTER IV · BROKEN CHAINWAY / 断链水廊", "function": &"traversal_combat", "width": 2048, "wall": "environment/walls/wet_prison_brick_03.png", "floor": "environment/floors/shallow_water_channel_bed_02.png", "water": true, "focal": [["environment/catwalks/chain_bridge_broken_left.png", 760, 440], ["environment/catwalks/chain_bridge_broken_right.png", 1280, 440], ["props/chains/chain_module_01.png", 720, 280], ["props/chains/chain_module_03.png", 1320, 280]], "platforms": [[640, 568, 96], [800, 528, 128], [1000, 496, 160], [1200, 528, 128], [1360, 568, 96]], "slots": 4},
	{"id": &"CH4_AREA_04", "slug": "harpoon_watch_gallery", "name": "CHAPTER IV · HARPOON WATCH GALLERY / 鱼叉瞭望廊", "function": &"vertical_combat", "width": 2176, "wall": "environment/walls/wet_prison_brick_01.png", "floor": "environment/floors/wet_flagstone_strip_03.png", "water": true, "focal": [["environment/flooded_cells/upper_inspection_cell_bay_01.png", 560, 300], ["environment/flooded_cells/upper_inspection_cell_bay_02.png", 1560, 300], ["props/chains/chain_module_02.png", 1088, 250]], "platforms": [[560, 560, 144], [960, 556, 96], [1320, 496, 160], [1560, 560, 144]], "slots": 5},
	{"id": &"CH4_AREA_05", "slug": "cistern_of_the_changed", "name": "CHAPTER IV · CISTERN OF THE CHANGED / 异鳞蓄水池", "function": &"ecology_arena", "width": 2176, "wall": "environment/walls/drainage_masonry_02.png", "floor": "environment/floors/shallow_water_channel_bed_03.png", "water": true, "focal": [["environment/cistern/reservoir_regulator_corrupted.png", 1088, 344], ["environment/cistern/overflow_drain_round.png", 400, 430], ["environment/cistern/overflow_drain_barred.png", 1776, 430]], "platforms": [[640, 584, 96], [900, 568, 64], [1280, 568, 64], [1536, 584, 96]], "slots": 5},
	{"id": &"CH4_AREA_06", "slug": "dry_gaolers_cell", "name": "CHAPTER IV · DRY GAOLER'S CELL / 干涸狱卒室", "function": &"safe_checkpoint", "width": 1536, "wall": "environment/walls/wet_prison_brick_01.png", "floor": "environment/floors/dry_checkpoint_stone_01.png", "water": false, "focal": [["props/records/record_prop_01.png", 620, 548], ["props/keys/key_prop_01.png", 820, 540], ["props/crates/storage_prop_02.png", 1040, 556], ["doors/cell_doors/cell_door_open.png", 1320, 500]], "platforms": [], "slots": 0, "checkpoint": &"DRY_GAOLER_CELL"},
	{"id": &"CH4_AREA_07", "slug": "leech_sluice", "name": "CHAPTER IV · LEECH SLUICE / 蛭潮排水渠", "function": &"ambush_combat", "width": 1920, "wall": "environment/walls/drainage_masonry_01.png", "floor": "environment/floors/drain_grate_strip_01.png", "water": true, "focal": [["props/drainage/ambush_drain_telegraph.png", 520, 556], ["props/drainage/ambush_drain_closed.png", 960, 556], ["props/drainage/ambush_drain_telegraph.png", 1400, 556], ["environment/cistern/overflow_drain_square.png", 960, 400]], "platforms": [], "slots": 4},
	{"id": &"CH4_AREA_08", "slug": "gaolers_workshop", "name": "CHAPTER IV · GAOLER'S WORKSHOP / 狱卒工坊", "function": &"elite_combat", "width": 2176, "wall": "environment/walls/wet_prison_brick_02.png", "floor": "environment/floors/wet_flagstone_strip_04.png", "water": false, "focal": [["props/torture_tools/workshop_prop_01.png", 420, 540], ["props/torture_tools/workshop_prop_04.png", 760, 540], ["props/torture_tools/workshop_prop_06.png", 1680, 540], ["props/chains/chain_module_04.png", 1088, 270]], "platforms": [[1088, 548, 256], [1580, 540, 160]], "slots": 5},
	{"id": &"CH4_AREA_09", "slug": "soul_cage_registry", "name": "CHAPTER IV · SOUL-CAGE REGISTRY / 囚魂档案室", "function": &"mixed_combat", "width": 2176, "wall": "environment/walls/soul_gaol_carved_stone_01.png", "floor": "environment/floors/wet_flagstone_strip_01.png", "water": true, "focal": [["props/soul_cages/registry_wall_cage_bay_01.png", 480, 360], ["props/soul_cages/registry_wall_cage_bay_02.png", 1088, 340], ["props/soul_cages/registry_wall_cage_bay_03.png", 1696, 360], ["props/records/record_prop_05.png", 1088, 560]], "platforms": [[680, 548, 144], [1450, 548, 144]], "slots": 4},
	{"id": &"CH4_AREA_10", "slug": "floodgate_engine_hall", "name": "CHAPTER IV · FLOODGATE ENGINE HALL / 水闸机轮厅", "function": &"machinery_combat", "width": 2304, "wall": "environment/walls/drainage_masonry_02.png", "floor": "environment/floors/shallow_water_channel_bed_01.png", "water": true, "focal": [["environment/floodgate/floodgate_housing_01.png", 520, 350], ["environment/floodgate/gothic_waterwheel_01.png", 960, 350], ["environment/floodgate/main_gear_train_01.png", 1480, 390], ["environment/floodgate/floodgate_housing_02.png", 1940, 350]], "platforms": [[760, 552, 160], [1320, 540, 224], [1760, 552, 160]], "slots": 5},
	{"id": &"CH4_AREA_11", "slug": "final_lock_approach", "name": "CHAPTER IV · FINAL LOCK APPROACH / 终锁前庭", "function": &"combat_exam", "width": 2304, "wall": "environment/walls/soul_gaol_carved_stone_02.png", "floor": "environment/floors/wet_flagstone_strip_02.png", "water": false, "focal": [["doors/rusted_gates/isolation_gate_01.png", 520, 470], ["doors/rusted_gates/isolation_gate_02.png", 1120, 470], ["doors/rusted_gates/isolation_gate_03.png", 1720, 470], ["doors/boss_gate/soul_lock_outer_frame.png", 2150, 398]], "platforms": [[1540, 508, 160]], "slots": 5},
	{"id": &"CH4_AREA_12", "slug": "last_gaol_checkpoint", "name": "CHAPTER IV · LAST GAOL CHECKPOINT / 末狱检查点", "function": &"safe_checkpoint", "width": 1536, "wall": "environment/walls/soul_gaol_carved_stone_01.png", "floor": "environment/floors/dry_checkpoint_stone_02.png", "water": false, "focal": [["props/keys/key_prop_03.png", 620, 540], ["props/records/record_prop_08.png", 820, 548], ["doors/boss_gate/soul_lock_outer_frame.png", 1280, 398]], "platforms": [], "slots": 0, "checkpoint": &"LAST_GAOL"},
	{"id": &"CH4_AREA_13", "slug": "soul_lock_antechamber", "name": "CHAPTER IV · SOUL LOCK ANTECHAMBER / 魂锁前厅", "function": &"boss_staging", "width": 1792, "wall": "environment/walls/soul_gaol_carved_stone_02.png", "floor": "environment/floors/dry_checkpoint_stone_01.png", "water": false, "focal": [["props/soul_cages/numbered_soul_cage_empty.png", 420, 500], ["doors/boss_gate/soul_lock_outer_frame.png", 896, 360], ["doors/boss_gate/soul_lock_panel_01.png", 896, 376], ["props/soul_cages/numbered_soul_cage_empty.png", 1372, 500]], "platforms": [], "slots": 0},
	{"id": &"CH4_AREA_14", "slug": "core_of_drowned_gaol", "name": "CHAPTER IV · CORE OF DROWNED GAOL / 溺狱核心", "function": &"boss_arena", "width": 2304, "wall": "environment/walls/soul_gaol_carved_stone_02.png", "floor": "environment/boss_area/boss_shallow_water_bed.png", "water": true, "focal": [["environment/boss_area/monumental_floodgate_recess.png", 420, 330], ["environment/boss_area/drowned_gaol_core_backdrop.png", 1152, 330], ["environment/boss_area/monumental_floodgate_recess.png", 1884, 330], ["environment/boss_area/chained_prison_crown.png", 1152, 316]], "platforms": [], "slots": 0, "boss": true},
	{"id": &"CH4_AREA_15", "slug": "broken_soul_reservoir", "name": "CHAPTER IV · BROKEN SOUL RESERVOIR / 破魂蓄池", "function": &"reward_revelation", "width": 1920, "wall": "environment/walls/soul_gaol_carved_stone_01.png", "floor": "environment/floors/wet_flagstone_strip_03.png", "water": true, "memory": true, "focal": [["environment/memory_transition/broken_soul_reservoir.png", 960, 360], ["props/soul_cages/broken_cage_state_04.png", 520, 530], ["props/soul_cages/broken_cage_state_03.png", 1400, 530]], "platforms": [], "slots": 0},
	{"id": &"CH4_AREA_16", "slug": "hall_of_drowned_memories", "name": "CHAPTER IV · HALL OF DROWNED MEMORIES / 溺忆回廊", "function": &"chapter_transition", "width": 2176, "wall": "environment/memory_transition/ruined_drowned_corridor_01.png", "floor": "environment/floors/dry_checkpoint_stone_02.png", "water": true, "memory": true, "focal": [["environment/memory_transition/ruined_drowned_corridor_02.png", 700, 330], ["environment/memory_transition/ruined_drowned_corridor_01.png", 1300, 330], ["doors/boss_gate/soul_lock_outer_frame.png", 1960, 398]], "platforms": [], "slots": 0},
]

var _room_script: Script
var _exit_script: Script
var _checkpoint_script: Script
var _water_frames: SpriteFrames
var _motion_frames: SpriteFrames
var _manifest_rooms: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_room_script = load(ROOM_SCRIPT) as Script
	_exit_script = load(EXIT_SCRIPT) as Script
	_checkpoint_script = load(CHECKPOINT_SCRIPT) as Script
	_water_frames = load(WATER_FRAMES) as SpriteFrames
	_motion_frames = load(MOTION_FRAMES) as SpriteFrames
	if _room_script == null or _exit_script == null or _checkpoint_script == null:
		_fail("required Chapter IV S3 scripts did not load")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(MANIFEST_PATH.get_base_dir()))
	for index: int in ROOMS.size():
		if not _build_room(index, ROOMS[index]):
			return
	if not _save_manifest():
		return
	print("CH4 S3 ROOM BUILD | PASS rooms=%d manifest=%s" % [ROOMS.size(), MANIFEST_PATH])
	quit(0)


func _build_room(index: int, data: Dictionary) -> bool:
	var root: Node2D = Node2D.new()
	root.name = _pascal_name(str(data["slug"]))
	root.set_script(_room_script)
	root.set("room_id", data["id"])
	root.set("room_index", index)
	root.set("bilingual_name", str(data["name"]))
	root.set("room_size", Vector2i(int(data["width"]), 720))
	root.set("room_function", data["function"])
	root.set("default_spawn_id", &"EntryWest")
	root.set_meta("formal_chapter_room", true)
	root.set_meta("environment_asset_milestone", "CH4-S2")

	var background: Node2D = _node2d(root, "Background", root)
	background.z_index = -100
	var architecture: Node2D = _node2d(root, "Architecture", root)
	architecture.z_index = -70
	var rear_props: Node2D = _node2d(root, "RearProps", root)
	rear_props.z_index = -40
	var rear_water: Node2D = _node2d(root, "RearWater", root)
	rear_water.z_index = -20
	var gameplay: Node2D = _node2d(root, "Gameplay", root)
	gameplay.z_index = 0
	var front_lip: Node2D = _node2d(root, "FrontWaterLip", root)
	front_lip.z_index = 13
	var markers: Node2D = _node2d(root, "FutureEncounterSpawns", root)
	var spawn_points: Node2D = _node2d(root, "SpawnPoints", root)
	var transitions: Node2D = _node2d(root, "Transitions", root)

	_build_wall_tiles(background, str(data["wall"]), int(data["width"]))
	_build_floor(gameplay, str(data["floor"]), int(data["width"]), root)
	_build_focal_assets(architecture, rear_props, data["focal"] as Array)
	_build_platforms(gameplay, architecture, data["platforms"] as Array, root)
	if bool(data.get("water", false)):
		_build_water(rear_water, front_lip, int(data["width"]), bool(data.get("memory", false)))
	_build_spawns(spawn_points, int(data["width"]), root)
	_build_transitions(transitions, index, int(data["width"]), root)
	if index == 3:
		_configure_broken_chainway_exit(transitions, root)
	_build_future_slots(markers, int(data["slots"]), int(data["width"]), data["platforms"] as Array, root)
	if data.has("checkpoint"):
		_build_checkpoint(gameplay, data["checkpoint"] as StringName, int(data["width"]) / 2, root)
	if bool(data.get("boss", false)):
		var boss_slot: Marker2D = Marker2D.new()
		boss_slot.name = "BossSlot"
		boss_slot.position = Vector2(int(data["width"]) * 0.68, FLOOR_Y - 1.0)
		_owned(markers, boss_slot, root)
		var boss_scene: PackedScene = load(ORMUND_SCENE) as PackedScene
		if boss_scene == null:
			_fail("formal Ormund scene did not load")
			root.free()
			return false
		var enemies: Node2D = _node2d(root, "Enemies", root)
		var boss: Node2D = boss_scene.instantiate() as Node2D
		boss.name = "SoulGaolerOrmund"
		boss.position = boss_slot.position
		boss.set_meta("formal_boss_instance", true)
		_owned(enemies, boss, root)
		root.set_meta("boss_arena_clear_width", 1400)

	var packed: PackedScene = PackedScene.new()
	if packed.pack(root) != OK:
		_fail("failed to pack room %s" % data["id"])
		root.free()
		return false
	var scene_path: String = "%s/ch4_%02d_%s.tscn" % [OUTPUT_DIR, index, data["slug"]]
	if ResourceSaver.save(packed, scene_path) != OK:
		_fail("failed to save %s" % scene_path)
		root.free()
		return false
	_manifest_rooms.append({
		"index": index,
		"room_id": String(data["id"]),
		"bilingual_name": str(data["name"]),
		"function": String(data["function"]),
		"scene": scene_path,
		"width": int(data["width"]),
		"future_enemy_slots": int(data["slots"]),
		"checkpoint": String(data.get("checkpoint", &"")),
		"water": bool(data.get("water", false)),
		"memory_water": bool(data.get("memory", false)),
		"platform_count": (data["platforms"] as Array).size(),
	})
	root.free()
	return true


func _build_wall_tiles(parent: Node2D, relative_path: String, width: int) -> void:
	var texture: Texture2D = _texture(relative_path)
	var count: int = ceili(float(width) / 256.0)
	for row: int in 3:
		for column: int in count:
			var sprite: Sprite2D = Sprite2D.new()
			sprite.name = "Wall_%02d_%02d" % [row, column]
			sprite.texture = texture
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.position = Vector2(column * 256 + 128, row * 224 + 128)
			sprite.modulate = Color(0.92 + 0.02 * ((row + column) % 2), 0.94, 1.0)
			_owned(parent, sprite, parent.owner if parent.owner != null else parent)


func _build_floor(parent: Node2D, relative_path: String, width: int, root: Node2D) -> void:
	var texture: Texture2D = _texture(relative_path)
	var tile_width: int = max(1, texture.get_width())
	var count: int = ceili(float(width) / float(tile_width))
	for column: int in count:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.name = "FloorTile_%02d" % column
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position = Vector2(column * tile_width + tile_width / 2, FLOOR_Y + texture.get_height() / 2)
		_owned(parent, sprite, root)
	var body: StaticBody2D = StaticBody2D.new()
	body.name = "FloorCollision"
	body.collision_layer = 1
	body.collision_mask = 0
	_owned(parent, body, root)
	var shape_node: CollisionShape2D = CollisionShape2D.new()
	shape_node.name = "CollisionShape2D"
	shape_node.position = Vector2(width / 2.0, FLOOR_Y + 52.0)
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(width, 104)
	shape_node.shape = shape
	_owned(body, shape_node, root)


func _build_focal_assets(architecture: Node2D, rear_props: Node2D, definitions: Array) -> void:
	for index: int in definitions.size():
		var item: Array = definitions[index] as Array
		var sprite: Sprite2D = Sprite2D.new()
		sprite.name = "FocalAsset_%02d" % index
		sprite.texture = _texture(str(item[0]))
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position = Vector2(float(item[1]), float(item[2]))
		var target: Node2D = architecture if str(item[0]).begins_with("environment/") or str(item[0]).begins_with("doors/") else rear_props
		_owned(target, sprite, architecture.owner)


func _build_platforms(parent: Node2D, architecture: Node2D, definitions: Array, root: Node2D) -> void:
	for index: int in definitions.size():
		var item: Array = definitions[index] as Array
		var x: float = float(item[0])
		var top: float = float(item[1])
		var width: int = int(item[2])
		var texture_path: String = "environment/platforms/maintenance_stone_ledge_%03d.png" % width
		if width == 144:
			texture_path = "environment/catwalks/riveted_iron_catwalk_160.png"
			width = 160
		elif width == 224:
			texture_path = "environment/platforms/wide_prison_dais_224.png"
		elif width == 256:
			texture_path = "environment/platforms/execution_platform_256.png"
		elif width == 64:
			texture_path = "environment/platforms/cistern_stepping_stone_064.png"
		elif width == 96 and top >= 570:
			texture_path = "environment/platforms/cistern_stepping_stone_096.png"
		var texture: Texture2D = _texture(texture_path)
		var sprite: Sprite2D = Sprite2D.new()
		sprite.name = "PlatformVisual_%02d" % index
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position = Vector2(x, top + texture.get_height() / 2.0)
		_owned(parent, sprite, root)
		var bracket: Sprite2D = Sprite2D.new()
		bracket.name = "PlatformSupport_%02d" % index
		bracket.texture = _texture("environment/catwalks/support_bracket_%02d.png" % (index % 8 + 1))
		bracket.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bracket.position = Vector2(x, top + 42)
		_owned(architecture, bracket, root)
		var body: StaticBody2D = StaticBody2D.new()
		body.name = "PlatformCollision_%02d" % index
		body.collision_layer = 1
		body.collision_mask = 0
		_owned(parent, body, root)
		var shape_node: CollisionShape2D = CollisionShape2D.new()
		shape_node.name = "CollisionShape2D"
		shape_node.position = Vector2(x, top + 6)
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(width, 12)
		shape_node.shape = shape
		_owned(body, shape_node, root)


func _build_water(rear_parent: Node2D, front_parent: Node2D, width: int, memory: bool) -> void:
	var count: int = ceili(float(width) / 256.0)
	for index: int in count:
		var water: AnimatedSprite2D = AnimatedSprite2D.new()
		water.name = "RearWater_%02d" % index
		water.sprite_frames = _motion_frames if memory else _water_frames
		water.animation = &"memory_water" if memory else &"rear_water"
		water.autoplay = water.animation
		water.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		water.position = Vector2(index * 256 + 128, FLOOR_Y - (48 if memory else 32))
		_owned(rear_parent, water, rear_parent.owner)
		if memory:
			continue
		var highlight: AnimatedSprite2D = AnimatedSprite2D.new()
		highlight.name = "WaterHighlight_%02d" % index
		highlight.sprite_frames = _water_frames
		highlight.animation = &"local_highlight"
		highlight.autoplay = &"local_highlight"
		highlight.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		highlight.position = Vector2(index * 256 + 128, FLOOR_Y - 8)
		_owned(rear_parent, highlight, rear_parent.owner)
		var lip: AnimatedSprite2D = AnimatedSprite2D.new()
		lip.name = "FrontLip_%02d" % index
		lip.sprite_frames = _water_frames
		lip.animation = &"front_lip"
		lip.autoplay = &"front_lip"
		lip.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		lip.position = Vector2(index * 256 + 128, FLOOR_Y - 2)
		_owned(front_parent, lip, front_parent.owner)


func _build_spawns(parent: Node2D, width: int, root: Node2D) -> void:
	for definition: Array in [["EntryWest", 120.0], ["EntryEast", width - 120.0], ["Inspection", width / 2.0]]:
		var marker: Marker2D = Marker2D.new()
		marker.name = String(definition[0])
		marker.position = Vector2(float(definition[1]), FLOOR_Y - 28.0)
		_owned(parent, marker, root)


func _build_transitions(parent: Node2D, index: int, width: int, root: Node2D) -> void:
	if index > 0:
		_add_exit(parent, "ExitWest", Vector2(24, FLOOR_Y - 70), StringName("CH4_AREA_%02d" % (index - 1)), &"EntryEast", root)
	if index < ROOMS.size() - 1:
		_add_exit(parent, "ExitEast", Vector2(width - 24, FLOOR_Y - 70), StringName("CH4_AREA_%02d" % (index + 1)), &"EntryWest", root)


func _add_exit(parent: Node2D, name_value: String, position: Vector2, destination: StringName, spawn: StringName, root: Node2D) -> void:
	var area: Area2D = Area2D.new()
	area.name = name_value
	area.position = position
	area.collision_layer = 0
	area.collision_mask = 2
	area.monitorable = false
	area.set_script(_exit_script)
	area.set("destination_room_id", destination)
	area.set("destination_spawn_id", spawn)
	_owned(parent, area, root)
	var shape_node: CollisionShape2D = CollisionShape2D.new()
	shape_node.name = "CollisionShape2D"
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(72, 160)
	shape_node.shape = shape
	_owned(area, shape_node, root)


func _configure_broken_chainway_exit(transitions: Node2D, root: Node2D) -> void:
	var exit_east: Area2D = transitions.get_node_or_null("ExitEast") as Area2D
	if exit_east == null:
		return
	exit_east.set("requires_interaction", true)
	exit_east.set("prompt_path", NodePath("Prompt"))
	var arch: Sprite2D = Sprite2D.new()
	arch.name = "ExitArch"
	arch.z_index = 2
	arch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	arch.position = Vector2(-34.0, -34.0)
	arch.texture = _texture("environment/walls/thick_pointed_prison_arch_128.png")
	_owned(exit_east, arch, root)
	var prompt: Label = Label.new()
	prompt.name = "Prompt"
	prompt.visible = false
	prompt.z_index = 20
	prompt.position = Vector2(-256.0, -128.0)
	prompt.size = Vector2(216.0, 28.0)
	prompt.text = "E · DESCEND / 进入下层溺狱"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	prompt.add_theme_font_size_override("font_size", 13)
	prompt.add_theme_color_override("font_color", Color(0.84, 0.76, 0.56))
	prompt.add_theme_color_override("font_shadow_color", Color(0.02, 0.03, 0.05))
	prompt.add_theme_constant_override("shadow_offset_x", 1)
	prompt.add_theme_constant_override("shadow_offset_y", 1)
	_owned(exit_east, prompt, root)


func _build_future_slots(parent: Node2D, count: int, width: int, platforms: Array, root: Node2D) -> void:
	for index: int in count:
		var marker: Marker2D = Marker2D.new()
		marker.name = "GroundSlot%02d" % (index + 1)
		marker.position = Vector2(360 + index * ((width - 720.0) / max(1, count - 1)), FLOOR_Y)
		marker.set_meta("semantic_tag", "ground")
		_owned(parent, marker, root)
	for index: int in platforms.size():
		var platform: Array = platforms[index] as Array
		if int(platform[2]) < 128:
			continue
		var marker: Marker2D = Marker2D.new()
		marker.name = "PlatformSlot%02d" % (index + 1)
		marker.position = Vector2(float(platform[0]), float(platform[1]))
		marker.set_meta("semantic_tag", "platform_ranged" if int(platform[2]) <= 160 else "platform_heavy")
		marker.set_meta("platform_width", int(platform[2]))
		_owned(parent, marker, root)


func _build_checkpoint(parent: Node2D, checkpoint_id: StringName, x: float, root: Node2D) -> void:
	var area: Area2D = Area2D.new()
	area.name = "Checkpoint"
	area.position = Vector2(x, FLOOR_Y - 70)
	area.collision_layer = 0
	area.collision_mask = 2
	area.monitorable = false
	area.set_script(_checkpoint_script)
	area.set("checkpoint_id", checkpoint_id)
	_owned(parent, area, root)
	var shape_node: CollisionShape2D = CollisionShape2D.new()
	shape_node.name = "CollisionShape2D"
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(160, 160)
	shape_node.shape = shape
	_owned(area, shape_node, root)
	var marker: Marker2D = Marker2D.new()
	marker.name = "SpawnMarker"
	marker.position = Vector2(0, 42)
	_owned(area, marker, root)


func _node2d(parent: Node, name_value: String, root: Node) -> Node2D:
	var node: Node2D = Node2D.new()
	node.name = name_value
	_owned(parent, node, root)
	return node


func _owned(parent: Node, child: Node, root: Node) -> void:
	parent.add_child(child)
	child.owner = root


func _texture(relative_path: String) -> Texture2D:
	var texture: Texture2D = load(ROOT + relative_path) as Texture2D
	if texture == null:
		_fail("missing formal S2 texture: %s" % relative_path)
	return texture


func _pascal_name(slug: String) -> String:
	var result: String = "Ch4"
	for part: String in slug.split("_"):
		result += part.capitalize().replace(" ", "")
	return result


func _save_manifest() -> bool:
	var manifest: Dictionary = {
		"chapter": "CHAPTER_04_DROWNED_UNDERKEEP",
		"milestone": "CH4-S3",
		"room_count": _manifest_rooms.size(),
		"route_order": _manifest_rooms.map(func(room: Dictionary) -> String: return str(room["room_id"])),
		"rooms": _manifest_rooms,
		"formal_encounters_populated": false,
		"chapter_v_destination_status": "sealed_placeholder",
	}
	var file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.WRITE)
	if file == null:
		_fail("unable to open room manifest for writing")
		return false
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
	file.close()
	return true


func _fail(message: String) -> void:
	push_error("CH4 S3 ROOM BUILD: %s" % message)
	quit(1)
