class_name ChapterRegistry
extends RefCounted

## Static registry of chapter metadata. It deliberately stores scene paths as
## strings so planned chapters can be registered without loading missing scenes.

const CHAPTER_PROLOGUE: StringName = &"CHAPTER_PROLOGUE"
const CHAPTER_01_RAVENMOURN_OUTSKIRTS: StringName = &"CHAPTER_01_RAVENMOURN_OUTSKIRTS"
const CHAPTER_02_SILENT_COURT: StringName = &"CHAPTER_02_SILENT_COURT"
const CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES: StringName = &"CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES"
const CHAPTER_04_DROWNED_UNDERKEEP: StringName = &"CHAPTER_04_DROWNED_UNDERKEEP"
const CHAPTER_05_NIGHT_REPEATED: StringName = &"CHAPTER_05_NIGHT_REPEATED"
const CHAPTER_06_HOLLOW_BELL_ABYSS: StringName = &"CHAPTER_06_HOLLOW_BELL_ABYSS"

const PROLOGUE_SCENE_PATH: String = "res://scenes/cinematics/opening_cinematic.tscn"
const CHAPTER_01_SCENE_PATH: String = "res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
const CHAPTER_01_PROFILE_PATH: String = (
	"res://chapters/chapter_01_ravenmourn_outskirts/resources/chapter/chapter_01_start_profile.tres"
)
const CHAPTER_02_SCENE_PATH: String = (
	"res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
)
const CHAPTER_02_PROFILE_PATH: String = (
	"res://chapters/chapter_02_silent_court/resources/chapter/chapter_02_start_profile.tres"
)
const CHAPTER_03_PROFILE_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/chapter/"
	+ "chapter_03_start_profile.tres"
)
const CHAPTER_03_SCENE_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/"
	+ "chapter_03_route.tscn"
)
const CHAPTER_04_SCENE_PATH: String = (
	"res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
)
const CHAPTER_04_PROFILE_PATH: String = (
	"res://chapters/chapter_04_drowned_underkeep/resources/chapter/chapter_04_start_profile.tres"
)
const CHAPTER_05_SCENE_PATH: String = (
	"res://chapters/chapter_05_night_repeated/scenes/level/night_repeated.tscn"
)
const CHAPTER_06_SCENE_PATH: String = (
	"res://chapters/chapter_06_hollow_bell_abyss/scenes/level/hollow_bell_abyss.tscn"
)

static var _profiles: Dictionary[StringName, ChapterStartProfile] = {}


static func get_chapter_ids() -> Array[StringName]:
	_ensure_initialized()
	return _profiles.keys()


static func has_chapter(chapter_id: StringName) -> bool:
	_ensure_initialized()
	return _profiles.has(chapter_id)


static func get_chapter(chapter_id: StringName) -> ChapterStartProfile:
	_ensure_initialized()
	assert(_profiles.has(chapter_id), "Unknown chapter id: %s" % chapter_id)
	return _profiles[chapter_id].duplicate(true) as ChapterStartProfile


static func get_chapter_or_null(chapter_id: StringName) -> ChapterStartProfile:
	_ensure_initialized()
	if not _profiles.has(chapter_id):
		return null
	return _profiles[chapter_id].duplicate(true) as ChapterStartProfile


static func _ensure_initialized() -> void:
	if not _profiles.is_empty():
		return
	_register(_make_profile(
		CHAPTER_PROLOGUE,
		"序章 · 复苏 / Prologue · Awakening",
		PROLOGUE_SCENE_PATH,
		&"opening_start",
		&"prologue_start",
		[&"opening_start", &"veilbound_catacomb_altar"],
		[],
		[],
		&"",
		0,
		100.0,
		true
	))
	var chapter_one_profile: ChapterStartProfile = ResourceLoader.load(
		CHAPTER_01_PROFILE_PATH, "ChapterStartProfile"
	) as ChapterStartProfile
	assert(chapter_one_profile != null, "Chapter I start profile failed to load")
	_register(chapter_one_profile)
	var chapter_two_profile: ChapterStartProfile = ResourceLoader.load(
		CHAPTER_02_PROFILE_PATH, "ChapterStartProfile"
	) as ChapterStartProfile
	assert(chapter_two_profile != null, "Chapter II start profile failed to load")
	_register(chapter_two_profile)
	var chapter_three_profile: ChapterStartProfile = ResourceLoader.load(
		CHAPTER_03_PROFILE_PATH, "ChapterStartProfile"
	) as ChapterStartProfile
	assert(chapter_three_profile != null, "Chapter III entry profile failed to load")
	_register(chapter_three_profile)
	var chapter_four_profile: ChapterStartProfile = ResourceLoader.load(
		CHAPTER_04_PROFILE_PATH, "ChapterStartProfile"
	) as ChapterStartProfile
	assert(chapter_four_profile != null, "Chapter IV entry profile failed to load")
	_register(chapter_four_profile)
	_register(_make_profile(
		CHAPTER_05_NIGHT_REPEATED,
		"第五章 · 重演之夜 / Chapter V · Night Repeated",
		CHAPTER_05_SCENE_PATH,
		&"CH5_START",
		&"CH5_START",
		[&"CH5_START"],
		[
			CHAPTER_PROLOGUE,
			CHAPTER_01_RAVENMOURN_OUTSKIRTS,
			CHAPTER_02_SILENT_COURT,
			CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES,
			CHAPTER_04_DROWNED_UNDERKEEP,
		],
		[],
		&"",
		0,
		100.0,
		true
	))
	_register(_make_planned_profile(
		CHAPTER_06_HOLLOW_BELL_ABYSS,
		"第六章 · 空钟深渊 / Chapter VI · Hollow Bell Abyss",
		CHAPTER_06_SCENE_PATH,
		&"chapter_06_start",
		[
			CHAPTER_PROLOGUE,
			CHAPTER_01_RAVENMOURN_OUTSKIRTS,
			CHAPTER_02_SILENT_COURT,
			CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES,
			CHAPTER_04_DROWNED_UNDERKEEP,
			CHAPTER_05_NIGHT_REPEATED,
		]
	))


static func _register(profile: ChapterStartProfile) -> void:
	assert(profile.is_valid_registry_entry(), "Invalid chapter registry entry: %s" % profile.chapter_id)
	assert(not _profiles.has(profile.chapter_id), "Duplicate chapter id: %s" % profile.chapter_id)
	_profiles[profile.chapter_id] = profile


static func _make_planned_profile(
	chapter_id: StringName,
	bilingual_name: String,
	main_scene_path: String,
	spawn_id: StringName,
	previous_chapters: Array[StringName]
) -> ChapterStartProfile:
	return _make_profile(
		chapter_id,
		bilingual_name,
		main_scene_path,
		spawn_id,
		spawn_id,
		[spawn_id],
		previous_chapters,
		[],
		&"",
		0,
		100.0,
		false
	)


static func _make_profile(
	chapter_id: StringName,
	bilingual_name: String,
	main_scene_path: String,
	default_spawn_id: StringName,
	default_checkpoint_id: StringName,
	available_spawn_ids: Array[StringName],
	previous_chapters: Array[StringName],
	required_weapons: Array[StringName],
	equipped_weapon: StringName,
	starting_currency: int,
	starting_hp: float,
	debug_ready: bool
) -> ChapterStartProfile:
	var profile: ChapterStartProfile = ChapterStartProfile.new()
	profile.profile_id = StringName("%s_DEFAULT" % chapter_id)
	profile.chapter_id = chapter_id
	profile.bilingual_name = bilingual_name
	profile.main_scene_path = main_scene_path
	profile.default_spawn_id = default_spawn_id
	profile.default_checkpoint_id = default_checkpoint_id
	profile.available_spawn_ids = available_spawn_ids.duplicate()
	profile.previous_chapters_completed = previous_chapters.duplicate()
	profile.required_weapons = required_weapons.duplicate()
	profile.equipped_weapon = equipped_weapon
	profile.starting_currency = starting_currency
	profile.starting_hp = starting_hp
	profile.start_full_health = true
	profile.chapter_boss_defeated = false
	profile.chapter_shortcuts = {}
	profile.chapter_story_flags = {}
	profile.debug_ready = debug_ready
	return profile
