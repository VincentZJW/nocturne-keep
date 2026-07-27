extends SceneTree

const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = ResourceLoader.load(LEVEL_PATH, "PackedScene") as PackedScene
	if packed == null:
		_failures.append("Silent Court Main does not load")
		_finish()
		return
	var level: Node = packed.instantiate()
	root.add_child(level)
	current_scene = level
	for _frame: int in range(4):
		await process_frame
	var required_paths: Array[String] = [
		"GameplayWorld/BossArea/HollowDuchess", "GameplayWorld/BossArea/BossActivationArea", "GameplayWorld/BossArea/BossDoorRear",
		"GameplayWorld/BossArea/BossExitDoor", "GameplayWorld/BossArea/BallroomFx", "PlayerSpawnPoints/CH2_BOSS",
		"ChapterSystems/HollowDuchessRoomController", "GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/HUD/HollowDuchessBossHud",
		"ChapterSystems/Chapter02To03TransitionController", "GameplayWorld/BossArea/BallroomMirrorGate",
		"GameplayWorld/BossArea/Chapter02BossWeaponPickupAnchor",
	]
	for path: String in required_paths:
		if level.get_node_or_null(path) == null:
			_failures.append("Missing Main node %s" % path)
	var boss: HollowDuchess = level.get_node_or_null("GameplayWorld/BossArea/HollowDuchess") as HollowDuchess
	var player: Player = level.get_node_or_null("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player") as Player
	var spawn: Marker2D = level.get_node_or_null("PlayerSpawnPoints/CH2_BOSS") as Marker2D
	if boss != null:
		_expect(boss.health_component.max_health == 220, "Main Boss HP mismatch")
		_expect(boss.global_position.distance_to(Vector2(6000, -1188)) < 1.0, "Main Boss spawn mismatch")
	if player != null and spawn != null:
		player.global_position = spawn.global_position
		_expect(player.global_position == Vector2(2500, -1216), "CH2_BOSS spawn mismatch")
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("HOLLOW_DUCHESS_MAIN_TEST: PASS boss=1 doors=2 cp05=1 hud=1 mirror=1 reward_anchor=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("HOLLOW_DUCHESS_MAIN_TEST: %s" % failure)
	quit(1)
