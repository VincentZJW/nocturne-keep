extends SceneTree

## Deterministic Chapter I contract: opening, tutorial composition, authored roster,
## checkpoints, environmental clues, Boss last words, and text-free threshold.

const OPENING: PackedScene = preload("res://scenes/cinematics/opening_cinematic.tscn")
const MAIN: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_opening_contract()
	var main: Node2D = MAIN.instantiate() as Node2D
	root.add_child(main)
	for _frame: int in range(6):
		await physics_frame
	_test_main_composition(main)
	_test_roster(main)
	_test_checkpoints(main)
	_test_boss_epilogue(main)
	main.queue_free()
	await process_frame
	_finish()


func _test_opening_contract() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "")
		== "res://scenes/bootstrap/main_bootstrap.tscn",
		"F5 does not begin with MainBootstrap"
	)
	var opening: OpeningCinematicController = OPENING.instantiate() as OpeningCinematicController
	root.add_child(opening)
	_expect(opening.timeline != null, "Opening lacks timeline resource")
	_expect(opening.timeline.get_shot_count() == 8, "Opening does not contain eight shots")
	_expect(opening.get_authored_duration() >= 60.0 and opening.get_authored_duration() <= 90.0, "Opening duration is outside 60–90 seconds")
	_expect(opening.skip_unlock_delay >= 1.5, "Opening skip unlocks too early")
	_expect(opening.target_scene_path == "res://scenes/levels/veilbound_catacomb.tscn", "Opening does not transition to Veilbound Catacomb")
	_expect(opening.get_node_or_null("UI/SubtitlePanel") != null, "Opening bilingual subtitle panel missing")
	_expect(opening.get_node_or_null("UI/SkipPanel") != null, "Opening hold-to-skip UI missing")
	opening.scene_change_enabled = false
	opening.finish_cinematic(true)
	opening.finish_cinematic(true)
	_expect(opening._finishing and opening.shot_timer.is_stopped(), "Opening skip did not stop its timeline exactly once")
	opening.queue_free()


func _test_main_composition(main: Node2D) -> void:
	_expect(main.has_node("World/DarkForestTutorialSpawn"), "Main lacks DarkForestTutorialSpawn")
	_expect(main.get_node_or_null("TutorialController") is TutorialController, "Main lacks TutorialController")
	_expect(main.get_node_or_null("HUD/TutorialPrompt") is TutorialPromptUI, "Main lacks tutorial prompt UI")
	_expect(main.has_node("World/ChapterOneStorytellingArt"), "Main lacks visual storytelling layer")
	_expect(main.has_node("World/TutorialFallenLog"), "Main lacks jump teaching obstacle")
	_expect(main.has_node("World/TutorialAirDashPlatform"), "Main lacks air-dash teaching platform")
	var tutorial: TutorialController = main.get_node("TutorialController") as TutorialController
	_expect(tutorial.completed_steps.size() == TutorialController.Step.COMPLETE, "Tutorial does not own eleven persistent steps")


func _test_roster(main: Node2D) -> void:
	var encounters: Node2D = main.get_node("World/Encounters") as Node2D
	var total: int = 0
	var optional_total: int = 0
	var region_counts: Dictionary[StringName, int] = {}
	var type_counts: Dictionary[StringName, int] = {}
	for node: Node in encounters.get_children():
		var group: EncounterGroup = node as EncounterGroup
		if group == null:
			continue
		var group_size: int = group.get_enemies().size()
		total += group_size
		region_counts[group.region_name] = region_counts.get(group.region_name, 0) + group_size
		if group.is_optional:
			optional_total += group_size
		for enemy: EnemyCombatant in group.get_enemies():
			type_counts[enemy.get_enemy_type_name()] = type_counts.get(enemy.get_enemy_type_name(), 0) + 1
	_expect(encounters.get_child_count() == 18, "EncounterGroup total is not 18")
	_expect(total == 34 and optional_total == 7, "Roster is not 34 total / 7 optional")
	_expect(region_counts.get(&"Tutorial", 0) == 8, "Tutorial roster is not 8")
	_expect(region_counts.get(&"DarkForest", 0) == 10, "Dark Forest roster is not 10")
	_expect(region_counts.get(&"CastleOutskirts", 0) == 9, "Outskirts roster is not 9")
	_expect(region_counts.get(&"CastleApproach", 0) == 7, "Approach roster is not 7")
	_expect(type_counts.get(&"CursedCastleGuard", 0) == 14, "Guard total is not 14")
	_expect(type_counts.get(&"CursedShieldGuard", 0) == 5, "Shield total is not 5")
	_expect(type_counts.get(&"DecayedSpearman", 0) == 6, "Spear total is not 6")
	_expect(type_counts.get(&"FallenCrossbowman", 0) == 5, "Crossbow total is not 5")
	_expect(type_counts.get(&"GargoyleSentinel", 0) == 4, "Gargoyle total is not 4")


func _test_checkpoints(main: Node2D) -> void:
	for path: String in [
		"World/Checkpoints/AfterTutorial", "World/Checkpoints/AfterForest",
		"World/Checkpoints/AfterOutskirts",
	]:
		_expect(main.get_node_or_null(path) is CheckpointTrigger, "Missing checkpoint %s" % path)
	_expect(main.has_node("World/CastleEntranceArea/BossCheckpoint"), "Boss checkpoint missing")
	var player: Player = main.get_node("World/Player") as Player
	var respawn: PlayerRespawnController = main.get_node("PlayerRespawnController") as PlayerRespawnController
	var after_tutorial: CheckpointTrigger = main.get_node(
		"World/Checkpoints/AfterTutorial"
	) as CheckpointTrigger
	after_tutorial._on_body_entered(player)
	_expect(
		respawn.spawn_point == after_tutorial.spawn_marker,
		"After-tutorial checkpoint did not update the respawn authority"
	)


func _test_boss_epilogue(main: Node2D) -> void:
	var line: BossLastWordsPresenter = main.get_node_or_null("HUD/BossLastWords") as BossLastWordsPresenter
	_expect(line != null, "Boss last words presenter missing")
	if line != null:
		line._on_boss_died()
		line._on_boss_died()
		_expect(line.visible and line.text.contains("The bell… remembers you."), "Boss last words did not display once")
	_expect(main.has_node("World/CastleEntranceArea/CastleGate"), "Weighted gate missing")
	_expect(main.has_node("World/CastleEntranceArea/CastleEntranceTrigger"), "Castle entrance trigger missing")
	_expect(main.has_node("CastleEntranceTransition"), "Text-free entrance transition missing")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CHAPTER_ONE_FLOW_TEST: PASS (8-shot opening, 11-step tutorial, 18 groups, 34 enemies, checkpoints, Boss epilogue)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CHAPTER_ONE_FLOW_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
