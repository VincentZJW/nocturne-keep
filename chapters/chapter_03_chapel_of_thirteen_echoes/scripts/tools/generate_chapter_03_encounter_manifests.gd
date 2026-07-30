extends SceneTree

const AUTHORING_SEED: int = 31372026
const OUTPUT_ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/encounters"
const NAVE_BACKDROP_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/structural_r2/nave_backdrop.png"
const CHOIR_BACKDROP_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/structural_r2/choir_gallery_backdrop.png"
const DOOR_PATHS: Array[String] = [
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/doors/structural_r2/nave_iron_door.png",
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/doors/structural_r2/choir_screen_door.png",
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/doors/structural_r2/mirror_back_door.png",
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/doors/structural_r2/boss_vestry_door.png",
]
const ENEMY_SCENE_PATHS: Dictionary[StringName, String] = {
	&"BellchainPenitent": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/bellchain_penitent.tscn",
	&"CenserExecutioner": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/censer_executioner.tscn",
	&"SilentChorister": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/silent_chorister.tscn",
	&"StainedGlassSeraph": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/stained_glass_seraph.tscn",
	&"ConfessionalWraith": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/confessional_wraith.tscn",
	&"ThirteenthScribe": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/thirteenth_scribe.tscn",
}

var _failures: Array[String] = []
var _room_index: int = 0


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	_save_room(
		&"CH3_NAVE_ENTRY", "CHAPTER III · OPENING PROCESSIONAL / 开场送葬列阵",
		&"CH3_MAIN_NAVE_FRONT", "opening", _groups([
			[&"BellchainPenitent", &"BellchainPenitent", &"SilentChorister"],
			[&"ConfessionalWraith"],
		])
	)
	_save_room(
		&"CH3_MAIN_NAVE_FRONT", "CHAPTER III · GREAT NAVE FRONT / 大礼拜堂前段",
		&"CH3_MAIN_NAVE_REAR", "nave", _groups([
			[&"BellchainPenitent", &"BellchainPenitent", &"SilentChorister", &"StainedGlassSeraph"],
			[&"BellchainPenitent", &"BellchainPenitent", &"SilentChorister", &"ThirteenthScribe"],
		])
	)
	_save_room(
		&"CH3_MAIN_NAVE_REAR", "CHAPTER III · GREAT NAVE REAR / 大礼拜堂后段",
		&"CH3_CONFESSIONALS", "nave_rear", _groups([
			[&"BellchainPenitent", &"BellchainPenitent", &"CenserExecutioner", &"SilentChorister"],
			[&"BellchainPenitent", &"StainedGlassSeraph", &"ConfessionalWraith", &"ThirteenthScribe"],
		])
	)
	_save_room(
		&"CH3_CONFESSIONALS", "CHAPTER III · THIRTEEN CONFESSIONALS / 十三忏悔侧廊",
		&"CH3_CHOIR_GALLERY", "confessionals", _groups([
			[&"BellchainPenitent", &"ConfessionalWraith", &"ConfessionalWraith", &"SilentChorister"],
			[&"BellchainPenitent", &"ConfessionalWraith", &"ConfessionalWraith", &"ThirteenthScribe"],
		])
	)
	_save_room(
		&"CH3_CHOIR_GALLERY", "CHAPTER III · BROKEN CHOIR GALLERY / 断声唱诗回廊",
		&"CH3_STAINED_GLASS_HALL", "choir", _groups([
			[&"BellchainPenitent", &"SilentChorister", &"SilentChorister"],
			[&"CenserExecutioner", &"SilentChorister", &"StainedGlassSeraph"],
			[&"BellchainPenitent", &"ThirteenthScribe", &"ThirteenthScribe"],
		])
	)
	_save_room(
		&"CH3_STAINED_GLASS_HALL", "CHAPTER III · SHATTERED SAINTS / 碎彩圣像厅",
		&"CH3_ARCHIVE_RELIQUARY", "stained_glass", _groups([
			[&"BellchainPenitent", &"StainedGlassSeraph", &"StainedGlassSeraph", &"SilentChorister"],
			[&"BellchainPenitent", &"StainedGlassSeraph", &"StainedGlassSeraph", &"ThirteenthScribe"],
		])
	)
	_save_room(
		&"CH3_ARCHIVE_RELIQUARY", "CHAPTER III · PRAYER ARCHIVE / 祷文档案圣器室",
		&"CH3_BLOOD_CANDLE_CHAPEL", "archive", _groups([
			[&"BellchainPenitent", &"CenserExecutioner", &"SilentChorister", &"ThirteenthScribe"],
			[&"BellchainPenitent", &"ConfessionalWraith", &"ThirteenthScribe", &"ThirteenthScribe"],
		])
	)
	_save_room(
		&"CH3_BLOOD_CANDLE_CHAPEL", "CHAPTER III · BLOOD-CANDLE CHAPEL / 血烛祈祷区",
		&"CH3_PRE_BOSS_COMBAT", "blood_candle", _groups([
			[&"BellchainPenitent", &"BellchainPenitent", &"CenserExecutioner", &"SilentChorister"],
			[&"BellchainPenitent", &"CenserExecutioner", &"StainedGlassSeraph", &"ConfessionalWraith"],
		])
	)
	_save_room(
		&"CH3_PRE_BOSS_COMBAT", "CHAPTER III · LAST PROCESSION / 最后送葬高压区",
		&"CH3_BOSS_CHECKPOINT", "pre_boss", _groups([
			[&"BellchainPenitent", &"CenserExecutioner", &"StainedGlassSeraph"],
			[&"BellchainPenitent", &"CenserExecutioner", &"SilentChorister", &"ThirteenthScribe"],
			[&"CenserExecutioner", &"StainedGlassSeraph", &"ConfessionalWraith", &"ConfessionalWraith"],
		])
	)
	if _failures.is_empty():
		print("CH3_ENCOUNTER_GENERATION PASS rooms=9 encounters=20 enemies=72 seed=%d" % AUTHORING_SEED)
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH3_ENCOUNTER_GENERATION: %s" % failure)
	quit(1)


func _groups(raw_groups: Array) -> Array[PackedStringArray]:
	var result: Array[PackedStringArray] = []
	for raw_group: Array in raw_groups:
		var packed: PackedStringArray = PackedStringArray()
		for enemy_type: StringName in raw_group:
			packed.append(String(enemy_type))
		result.append(packed)
	return result


func _save_room(
	room_id: StringName,
	bilingual_name: String,
	next_room_id: StringName,
	theme: StringName,
	groups: Array[PackedStringArray]
) -> void:
	var is_wide: bool = groups.size() == 3 or theme in [&"choir", &"pre_boss"]
	var definition: Chapter03RoomDefinition = Chapter03RoomDefinition.new()
	definition.room_id = room_id
	definition.bilingual_name = bilingual_name
	definition.room_size = Vector2i(2432, 720) if is_wide else Vector2i(2304, 720)
	definition.next_room_id = next_room_id
	definition.door_prompt = _door_prompt(next_room_id)
	definition.backdrop_texture = load(CHOIR_BACKDROP_PATH if is_wide else NAVE_BACKDROP_PATH) as Texture2D
	definition.door_texture = load(DOOR_PATHS[_room_index % DOOR_PATHS.size()]) as Texture2D
	definition.manifest = _build_manifest(room_id, groups, definition)
	_add_theme_props(theme, definition)
	var output_path: String = "%s/%s.tres" % [OUTPUT_ROOT, String(room_id).to_lower()]
	var save_error: Error = ResourceSaver.save(definition, output_path)
	if save_error != OK:
		_failures.append("unable to save %s (%s)" % [output_path, error_string(save_error)])
	_room_index += 1


func _build_manifest(
	room_id: StringName,
	groups: Array[PackedStringArray],
	definition: Chapter03RoomDefinition
) -> Chapter03EncounterManifest:
	var manifest: Chapter03EncounterManifest = Chapter03EncounterManifest.new()
	manifest.room_id = room_id
	manifest.authored_seed = AUTHORING_SEED
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = AUTHORING_SEED + _room_index * 101
	for group_index: int in range(groups.size()):
		var encounter: Chapter03EncounterData = Chapter03EncounterData.new()
		encounter.encounter_id = StringName("%s_ENCOUNTER_%02d" % [room_id, group_index + 1])
		encounter.region_name = room_id
		encounter.simultaneous_attack_limit = mini(3, groups[group_index].size())
		encounter.activation_rect = _activation_rect(group_index, groups.size(), definition.room_size.x)
		var base_x: float = _group_base_x(group_index, groups.size())
		var ground_index: int = 0
		var platform_index: int = 0
		for enemy_text: String in groups[group_index]:
			var enemy_type: StringName = StringName(enemy_text)
			var spawn: Chapter03EnemySpawnData = _make_spawn(
				enemy_type, base_x, ground_index, platform_index, random, definition
			)
			encounter.spawns.append(spawn)
			if spawn.spawn_role in [&"platform_ranged", &"platform_wide"]:
				platform_index += 1
			elif spawn.spawn_role != &"air_anchor":
				ground_index += 1
		manifest.encounters.append(encounter)
	return manifest


func _make_spawn(
	enemy_type: StringName,
	base_x: float,
	ground_index: int,
	platform_index: int,
	random: RandomNumberGenerator,
	definition: Chapter03RoomDefinition
) -> Chapter03EnemySpawnData:
	var spawn: Chapter03EnemySpawnData = Chapter03EnemySpawnData.new()
	spawn.enemy_type = enemy_type
	spawn.enemy_scene = load(ENEMY_SCENE_PATHS[enemy_type]) as PackedScene
	spawn.spawn_role = _spawn_role(enemy_type)
	spawn.facing_direction = 1.0 if random.randi_range(0, 1) == 1 else -1.0
	var jitter: float = float(random.randi_range(-3, 3) * 4)
	match spawn.spawn_role:
		&"ground_light", &"ground_heavy", &"confessional_spawn":
			spawn.local_position = Vector2(base_x - 150.0 + ground_index * 96.0 + jitter, 584.0)
			spawn.movement_bounds = Vector2(base_x - 270.0, base_x + 270.0)
		&"platform_ranged", &"platform_wide":
			var upper: bool = platform_index % 2 == 1
			var platform_position: Vector2 = Vector2(
				base_x + 80.0 + platform_index * 190.0,
				408.0 if upper else 484.0
			)
			definition.platform_positions.append(platform_position)
			definition.platform_widths.append(192)
			if upper:
				definition.platform_positions.append(Vector2(platform_position.x - 126.0, 484.0))
				definition.platform_widths.append(96)
			spawn.local_position = platform_position + Vector2(jitter, -58.0)
			spawn.movement_bounds = Vector2(platform_position.x - 78.0, platform_position.x + 78.0)
		&"air_anchor":
			spawn.local_position = Vector2(base_x + 96.0 + jitter, 318.0)
			spawn.movement_bounds = Vector2(base_x - 220.0, base_x + 260.0)
	return spawn


func _spawn_role(enemy_type: StringName) -> StringName:
	match enemy_type:
		&"BellchainPenitent":
			return &"ground_light"
		&"CenserExecutioner":
			return &"ground_heavy"
		&"SilentChorister", &"ThirteenthScribe":
			return &"platform_ranged"
		&"StainedGlassSeraph":
			return &"air_anchor"
		&"ConfessionalWraith":
			return &"confessional_spawn"
	return &"no_spawn"


func _activation_rect(group_index: int, group_count: int, room_width: int) -> Rect2:
	if group_count == 2:
		return Rect2(120.0 + group_index * 1080.0, 0.0, 900.0, 720.0)
	var width: float = 690.0 if group_index < 2 else float(room_width) - 1640.0
	return Rect2(100.0 + group_index * 770.0, 0.0, width, 720.0)


func _group_base_x(group_index: int, group_count: int) -> float:
	if group_count == 2:
		return 560.0 + group_index * 1080.0
	return 430.0 + group_index * 770.0


func _add_theme_props(theme: StringName, definition: Chapter03RoomDefinition) -> void:
	match theme:
		&"opening", &"nave":
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/structural_r2/mourner_bench.png", Vector2(340.0, 560.0), -30)
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/structural_r2/votive_lectern.png", Vector2(1240.0, 540.0), -30)
		&"nave_rear":
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/structural_r2/thirteen_bell_emblem.png", Vector2(1152.0, 188.0), -60)
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/structural_r2/mourner_bench.png", Vector2(420.0, 560.0), -30)
		&"confessionals":
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/boss/thirteen_confession_tablets.png", Vector2(1152.0, 474.0), -40)
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/boss/confessor_lectern.png", Vector2(420.0, 500.0), -30)
		&"choir":
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/structural_r2/organ_pipes_far.png", Vector2(1940.0, 322.0), -100)
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/structural_r2/organ_case_behind.png", Vector2(1940.0, 380.0), -60)
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/structural_r2/choir_seat.png", Vector2(640.0, 560.0), -30)
		&"stained_glass":
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/boss_sanctum/boss_stained_glass.png", Vector2(1152.0, 298.0), -70)
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/boss/bell_saint_left.png", Vector2(420.0, 380.0), -45)
		&"archive":
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/boss/ritual_registry.png", Vector2(1160.0, 384.0), -45)
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/structural_r2/votive_lectern.png", Vector2(460.0, 540.0), -30)
		&"blood_candle":
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/boss/thirteen_blood_candle_array_02.png", Vector2(1152.0, 474.0), -40)
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/boss/boss_censers.png", Vector2(430.0, 310.0), -45)
		&"pre_boss":
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/boss/bell_reliquary.png", Vector2(1216.0, 380.0), -60)
			_add_prop(definition, "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/props/boss/thirteen_confession_tablets.png", Vector2(520.0, 474.0), -40)


func _add_prop(definition: Chapter03RoomDefinition, texture_path: String, position: Vector2, z_index: int) -> void:
	definition.prop_textures.append(load(texture_path) as Texture2D)
	definition.prop_positions.append(position)
	definition.prop_z_indices.append(z_index)


func _door_prompt(next_room_id: StringName) -> String:
	if next_room_id == &"CH3_BOSS_CHECKPOINT":
		return "E  ENTER LAST VIGIL / 进入末祷"
	return "E  CONTINUE PROCESSION / 继续送葬"
