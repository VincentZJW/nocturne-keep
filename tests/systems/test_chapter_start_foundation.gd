extends SceneTree

## Chapter-start contract: Bootstrap remains configured while debug routing can
## target either loadable chapter profile.

const EXPECTED_F5_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_registry()
	_test_chapter_one_metadata()
	_test_chapter_two_metadata()
	_test_chapter_three_entry_metadata()
	_test_debug_run_config()
	_test_formal_flow_is_unchanged()
	_finish()


func _test_registry() -> void:
	var expected_ids: Array[StringName] = [
		ChapterRegistry.CHAPTER_PROLOGUE,
		ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS,
		ChapterRegistry.CHAPTER_02_SILENT_COURT,
		ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES,
		ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP,
		ChapterRegistry.CHAPTER_05_NIGHT_REPEATED,
		ChapterRegistry.CHAPTER_06_HOLLOW_BELL_ABYSS,
	]
	var registered_ids: Array[StringName] = ChapterRegistry.get_chapter_ids()
	_expect(registered_ids.size() == expected_ids.size(), "Registry does not contain seven entries")
	for chapter_id: StringName in expected_ids:
		_expect(ChapterRegistry.has_chapter(chapter_id), "Missing chapter id: %s" % chapter_id)
		var profile: ChapterStartProfile = ChapterRegistry.get_chapter_or_null(chapter_id)
		_expect(profile != null, "Chapter lookup returned null: %s" % chapter_id)
		if profile != null:
			_expect(profile.is_valid_registry_entry(), "Registry metadata is invalid: %s" % chapter_id)
	_expect(
		ChapterRegistry.get_chapter_or_null(&"CHAPTER_UNKNOWN") == null,
		"Unknown chapter lookup did not return null"
	)


func _test_chapter_one_metadata() -> void:
	var profile: ChapterStartProfile = ChapterRegistry.get_chapter(
		ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS
	)
	_expect(profile.main_scene_path == ChapterRegistry.CHAPTER_01_SCENE_PATH, "Chapter I path mismatch")
	_expect(profile.default_spawn_id == &"dark_forest_tutorial_spawn", "Chapter I default spawn mismatch")
	_expect(profile.available_spawn_ids.has(&"boss_checkpoint"), "Chapter I Boss checkpoint missing")
	_expect(profile.debug_ready and profile.is_valid_debug_target(), "Chapter I profile is not debug-ready")


func _test_chapter_two_metadata() -> void:
	var profile: ChapterStartProfile = ChapterRegistry.get_chapter(
		ChapterRegistry.CHAPTER_02_SILENT_COURT
	)
	_expect(profile.main_scene_path == ChapterRegistry.CHAPTER_02_SCENE_PATH, "Chapter II path mismatch")
	_expect(profile.default_spawn_id == &"CH2_START", "Chapter II default spawn mismatch")
	_expect(profile.default_checkpoint_id == &"Chapter02CP01", "Chapter II checkpoint mismatch")
	_expect(profile.starting_currency == 30, "Chapter II test currency metadata mismatch")
	_expect(profile.equipped_weapon == &"ravenfang_daggers", "Chapter II weapon metadata mismatch")
	_expect(profile.debug_ready, "Chapter II is not marked debug-ready")
	_expect(profile.is_valid_debug_target(), "Chapter II profile is not a valid debug target")
	for planned_id: StringName in [
		ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP,
		ChapterRegistry.CHAPTER_05_NIGHT_REPEATED,
		ChapterRegistry.CHAPTER_06_HOLLOW_BELL_ABYSS,
	]:
		_expect(not ChapterRegistry.get_chapter(planned_id).debug_ready, "%s is unexpectedly ready" % planned_id)


func _test_chapter_three_entry_metadata() -> void:
	var profile: ChapterStartProfile = ChapterRegistry.get_chapter(
		ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	)
	_expect(profile.main_scene_path == ChapterRegistry.CHAPTER_03_SCENE_PATH, "Chapter III path mismatch")
	_expect(profile.default_spawn_id == &"chapter_03_start", "Chapter III entry spawn mismatch")
	_expect(profile.default_checkpoint_id == &"Chapter03CP01", "Chapter III CP01 mismatch")
	_expect(profile.debug_ready and profile.is_valid_debug_target(), "Chapter III entry is not debug-ready")
	_expect(
		profile.required_weapons == [
			&"veilbound_daggers", &"ravenfang_daggers", &"crimson_masque_stilettos",
		],
		"Chapter III weapon ownership profile mismatch",
	)
	_expect(
		profile.equipped_weapon == &"crimson_masque_stilettos",
		"Chapter III does not equip the Chapter II Boss reward",
	)
	_expect(
		profile.chapter_story_flags.get(&"chapter_02_completed", false),
		"Chapter III profile does not complete Chapter II"
	)


func _test_debug_run_config() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	_expect(config != null, "DebugRunConfig Autoload is missing")
	if config == null:
		return
	_expect(not config.debug_chapter_start_enabled, "Debug chapter start is not disabled by default")
	_expect(
		config.debug_start_chapter_id == ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS,
		"Debug target does not default to Chapter I"
	)
	_expect(config.debug_start_spawn_id == &"dark_forest_tutorial_spawn", "Debug spawn default mismatch")
	_expect(config.debug_reset_chapter_state_on_run, "Debug reset default mismatch")
	_expect(config.debug_use_test_currency and config.debug_test_currency == 30, "Debug currency defaults mismatch")
	_expect(config.debug_start_full_health, "Full-health debug default mismatch")
	_expect(not config.debug_skip_chapter_intro, "Chapter intro is unexpectedly skipped")
	_expect(not config.debug_show_chapter_select, "Chapter selector is unexpectedly visible")
	_expect(not config.is_chapter_start_allowed(), "Formal startup default unexpectedly allows Debug routing")
	config.debug_chapter_start_enabled = true
	_expect(config.is_chapter_start_allowed() == OS.is_debug_build(), "Debug/release guard does not reflect the build type")
	var target: ChapterStartProfile = config.get_target_profile()
	_expect(target != null and target.chapter_id == ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS, "Target profile lookup failed")
	config.reset_to_defaults()
	_expect(not config.debug_chapter_start_enabled, "Reset defaults re-enabled Debug chapter start")


func _test_formal_flow_is_unchanged() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "") == EXPECTED_F5_PATH,
		"Formal F5 entry is not MainBootstrap"
	)
	_expect(current_scene == null, "Side-effect-free ChapterStartRouter changed a script-only test scene")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CHAPTER_START_FOUNDATION_TEST: PASS (7 entries, Chapters I/II/III-entry ready, Bootstrap preserved)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CHAPTER_START_FOUNDATION_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
