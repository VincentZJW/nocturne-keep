extends SceneTree

## Stage 2A contract: registry/profile/config exist without changing F5 routing.

const EXPECTED_F5_PATH: String = "res://scenes/cinematics/opening_cinematic.tscn"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_registry()
	_test_chapter_two_metadata()
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


func _test_chapter_two_metadata() -> void:
	var profile: ChapterStartProfile = ChapterRegistry.get_chapter(
		ChapterRegistry.CHAPTER_02_SILENT_COURT
	)
	_expect(profile.main_scene_path == ChapterRegistry.CHAPTER_02_SCENE_PATH, "Chapter II path mismatch")
	_expect(profile.default_spawn_id == &"chapter_02_cp01", "Chapter II default spawn mismatch")
	_expect(profile.default_checkpoint_id == &"chapter_02_cp01", "Chapter II checkpoint mismatch")
	_expect(profile.starting_currency == 30, "Chapter II test currency metadata mismatch")
	_expect(profile.equipped_weapon == &"ravenfang_daggers", "Chapter II weapon metadata mismatch")
	_expect(not profile.debug_ready, "Chapter II was marked ready before its scene/profile exists")
	_expect(not profile.is_valid_debug_target(), "Missing Chapter II scene was accepted as a debug target")
	for planned_id: StringName in [
		ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES,
		ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP,
		ChapterRegistry.CHAPTER_05_NIGHT_REPEATED,
		ChapterRegistry.CHAPTER_06_HOLLOW_BELL_ABYSS,
	]:
		_expect(not ChapterRegistry.get_chapter(planned_id).debug_ready, "%s is unexpectedly ready" % planned_id)


func _test_debug_run_config() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	_expect(config != null, "DebugRunConfig Autoload is missing")
	if config == null:
		return
	_expect(config.debug_chapter_start_enabled, "Debug chapter start is not enabled by default")
	_expect(
		config.debug_start_chapter_id == ChapterRegistry.CHAPTER_02_SILENT_COURT,
		"Debug target does not default to Chapter II"
	)
	_expect(config.debug_start_spawn_id == &"chapter_02_cp01", "Debug spawn default mismatch")
	_expect(config.debug_reset_chapter_state_on_run, "Debug reset default mismatch")
	_expect(config.debug_use_test_currency and config.debug_test_currency == 30, "Debug currency defaults mismatch")
	_expect(config.debug_start_full_health, "Full-health debug default mismatch")
	_expect(not config.debug_skip_chapter_intro, "Chapter intro is unexpectedly skipped")
	_expect(not config.debug_show_chapter_select, "Chapter selector is unexpectedly visible")
	_expect(
		config.is_chapter_start_allowed() == (OS.is_debug_build() and config.debug_chapter_start_enabled),
		"Debug/release guard does not reflect the build type"
	)
	var target: ChapterStartProfile = config.get_target_profile()
	_expect(target != null and target.chapter_id == ChapterRegistry.CHAPTER_02_SILENT_COURT, "Target profile lookup failed")
	config.debug_chapter_start_enabled = false
	_expect(not config.is_chapter_start_allowed(), "Disabled debug start was still allowed")
	config.reset_to_defaults()


func _test_formal_flow_is_unchanged() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "") == EXPECTED_F5_PATH,
		"Stage 2A changed the formal F5 entry scene"
	)
	_expect(current_scene == null, "DebugRunConfig routed to a scene during Stage 2A")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CHAPTER_START_FOUNDATION_TEST: PASS (7 entries, Chapter II default, no routing)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CHAPTER_START_FOUNDATION_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
