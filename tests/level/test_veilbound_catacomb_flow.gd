extends SceneTree

## Deterministic contract for Opening -> Catacomb -> Dark Forest startup flow.

const OPENING: PackedScene = preload("res://scenes/cinematics/opening_cinematic.tscn")
const CATACOMB: PackedScene = preload("res://scenes/levels/veilbound_catacomb.tscn")
const MAIN: PackedScene = preload("res://scenes/main/main.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_f5_route()
	var catacomb: VeilboundCatacombController = CATACOMB.instantiate() as VeilboundCatacombController
	root.add_child(catacomb)
	current_scene = catacomb
	for _frame: int in range(4):
		await process_frame
	_test_catacomb_composition(catacomb)
	_test_dialogue_data(catacomb)
	_test_skip_and_unlock(catacomb)
	_test_daggers_and_door(catacomb)
	for _frame: int in range(110):
		await process_frame
		await physics_frame
	_expect(catacomb.stone_door.open_progress >= 0.99, "Stone door animation did not open fully")
	_expect(catacomb.stone_door_collision.disabled, "Stone door collision remained enabled")
	catacomb.queue_free()
	await process_frame
	var main: Node2D = MAIN.instantiate() as Node2D
	root.add_child(main)
	await process_frame
	_test_main_spawn(main)
	main.queue_free()
	await process_frame
	_finish()


func _test_f5_route() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "")
		== "res://scenes/cinematics/opening_cinematic.tscn",
		"F5 no longer starts at Opening Cinematic"
	)
	var opening: OpeningCinematicController = OPENING.instantiate() as OpeningCinematicController
	_expect(opening.target_scene_path == "res://scenes/levels/veilbound_catacomb.tscn", "Opening target is not Veilbound Catacomb")
	opening.free()


func _test_catacomb_composition(catacomb: VeilboundCatacombController) -> void:
	for path: String in [
		"World/SeveredAltar",
		"World/Player/RevivalPlayerArt",
		"World/CandleWarden",
		"World/Interactions/DaggerPickup",
		"World/StoneDoorBody/StoneDoorVisual",
		"World/Interactions/CatacombExitTrigger",
		"NarrativeUI/DialogueUI",
		"NarrativeUI/ObjectiveUI",
	]:
		_expect(catacomb.has_node(path), "Catacomb is missing %s" % path)
	_expect(catacomb.get_tree().get_nodes_in_group("enemies").is_empty(), "Catacomb contains an enemy")
	_expect(catacomb.dark_forest_scene_path == "res://scenes/main/main.tscn", "Catacomb exit does not target Main")
	_expect(catacomb.player.get_input_profile() == Player.InputProfile.LOCKED, "Player is not locked during revival")


func _test_dialogue_data(catacomb: VeilboundCatacombController) -> void:
	_expect(catacomb.monologue_zh.is_valid_track() and catacomb.monologue_en.is_valid_track(), "Revival monologue tracks are invalid")
	_expect(catacomb.dialogue_zh.is_valid_track() and catacomb.dialogue_en.is_valid_track(), "Candle Warden dialogue tracks are invalid")
	_expect(catacomb.monologue_zh.get_line_count() == 3, "Protagonist monologue is not three lines")
	_expect(catacomb.dialogue_zh.get_line_count() == 27, "Candle Warden conversation is not 27 lines")
	_expect(catacomb.dialogue_en.get_line(0) == "Seven years.", "English dialogue order is wrong")
	_expect(catacomb.dialogue_en.get_line(26).contains("learn how to live again"), "Final Warden line is wrong")


func _test_skip_and_unlock(catacomb: VeilboundCatacombController) -> void:
	catacomb.skip_revival_for_test()
	_expect(catacomb.is_story_complete(), "Skip did not complete revival state")
	_expect(catacomb.player.get_input_profile() == Player.InputProfile.CATACOMB_MOVE_ONLY, "Skip did not grant move-only control")
	_expect(not catacomb.player_visual.visible and catacomb.revival_art.visible, "Skipped unarmed presentation is wrong")
	var session: Node = root.get_node_or_null("ChapterSession")
	_expect(session != null and bool(session.get("revival_completed")), "Skip did not persist revival completion")


func _test_daggers_and_door(catacomb: VeilboundCatacombController) -> void:
	catacomb.collect_daggers_for_test()
	_expect(catacomb.has_daggers(), "Dagger pickup state was not set")
	_expect(catacomb.player_visual.visible and not catacomb.revival_art.visible, "Dagger pickup did not restore Player weapon visual")
	catacomb.open_door_for_test()
	_expect(catacomb.is_door_open(), "Door prerequisite did not open the stone door")


func _test_main_spawn(main: Node2D) -> void:
	var spawn: Marker2D = main.get_node_or_null("World/DarkForestTutorialSpawn") as Marker2D
	var player: Player = main.get_node_or_null("World/Player") as Player
	var respawn: PlayerRespawnController = main.get_node_or_null("PlayerRespawnController") as PlayerRespawnController
	_expect(spawn != null and spawn.position == Vector2(320, 612), "Dark Forest tutorial spawn is missing or moved")
	_expect(player != null and player.position == spawn.position, "Player does not start at Dark Forest tutorial spawn")
	_expect(respawn != null and respawn.spawn_point == spawn, "Respawn authority is not bound to Dark Forest tutorial spawn")
	_expect(main.has_node("TutorialController"), "Main tutorial no longer starts after Catacomb")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("VEILBOUND_CATACOMB_FLOW_TEST: PASS (F5 route, 30 bilingual lines, skip, daggers, door, Main spawn)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("VEILBOUND_CATACOMB_FLOW_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
