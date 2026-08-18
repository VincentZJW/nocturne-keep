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
		"GameplayWorld/BossArea/DuchessBossEntrance/DoorBlocker",
		"GameplayWorld/BossArea/DuchessBossEntrance/ExteriorVisuals/DoorArtwork",
		"ChapterSystems/DuchessBossThresholdTransition",
		"GameplayWorld/BossArea/DuchessEncounterPresentation/AnimationPlayer",
		"GameplayWorld/BossArea/DuchessReliquary/WeaponDisplay/PickupAnchor",
		"GameplayWorld/BossArea/DuchessReliquary/CandleFlames/AnimationTimer",
		"GameplayWorld/BossArea/DuchessReliquary/InteractionArea/CollisionShape2D",
		"GameplayWorld/BossArea/DuchessReliquary/InteractionPrompt",
		"GameplayWorld/BossArea/BallroomFx/VisibilityNotifier",
	]
	for path: String in required_paths:
		if level.get_node_or_null(path) == null:
			_failures.append("Missing Main node %s" % path)
	var boss: HollowDuchess = level.get_node_or_null("GameplayWorld/BossArea/HollowDuchess") as HollowDuchess
	var player: Player = level.get_node_or_null("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player") as Player
	var spawn: Marker2D = level.get_node_or_null("PlayerSpawnPoints/CH2_BOSS") as Marker2D
	var entrance: Node2D = level.get_node_or_null(
		"GameplayWorld/BossArea/DuchessBossEntrance"
	) as Node2D
	var threshold: DuchessBossThresholdTransition = level.get_node_or_null(
		"ChapterSystems/DuchessBossThresholdTransition"
	) as DuchessBossThresholdTransition
	var reliquary: DuchessReliquary = level.get_node_or_null(
		"GameplayWorld/BossArea/DuchessReliquary"
	) as DuchessReliquary
	var interaction_prompt: Label = level.get_node_or_null(
		"GameplayWorld/BossArea/DuchessReliquary/InteractionPrompt"
	) as Label
	var ballroom_fx: HollowDuchessBallroomFx = level.get_node_or_null(
		"GameplayWorld/BossArea/BallroomFx"
	) as HollowDuchessBallroomFx
	if boss != null:
		_expect(boss.health_component.max_health == 220, "Main Boss HP mismatch")
		_expect(boss.global_position.distance_to(Vector2(4700, -1188)) < 1.0, "Main Boss spawn mismatch")
		_expect(boss.phase_2_sprite_frames != null, "Main Boss Phase 2 SpriteFrames missing")
		_expect(boss.config.phase_2_max_poise == 80, "Main Boss Phase 2 Poise mismatch")
	if player != null and spawn != null:
		player.global_position = spawn.global_position
		_expect(player.global_position == Vector2(2500, -1216), "CH2_BOSS spawn mismatch")
		_expect(player.z_index == 12 and not player.z_as_relative, "Player layer contract changed")
	if entrance != null:
		_expect(entrance.z_index == 8 and not entrance.z_as_relative, "Boss entrance must remain behind Player")
	if threshold != null:
		# A legal Debug Chapter Start may already have requested the saved Boss
		# threshold during these first four frames. Both the untouched idle state
		# and an authored transition stage prove the same formal controller owns
		# the Main route; an unknown stage still fails composition QA.
		_expect(
			threshold.get_transition_stage() in [
				&"idle", &"fading_out", &"blackout", &"fading_in", &"complete"
			],
			"Boss threshold entered an unknown transition stage"
		)
	if reliquary != null and player != null and interaction_prompt != null:
		_expect(reliquary.z_index == 8 and not reliquary.z_as_relative, "Reliquary must remain behind Player")
		_expect(interaction_prompt.z_index == 20 and not interaction_prompt.z_as_relative, "Reliquary prompt layer mismatch")
		_expect(is_equal_approx(reliquary.get_interaction_radius(), 112.0), "Reliquary interaction radius mismatch")
		reliquary.set_unlocked(true, true)
		reliquary.interaction_area.body_entered.emit(player)
		_expect(interaction_prompt.visible, "Reliquary proximity prompt did not appear")
		_expect(interaction_prompt.text.contains("按 E 拾取 绯幕礼刺"), "Reliquary prompt copy mismatch")
		reliquary.set_collected(true)
		_expect(not interaction_prompt.visible, "Reliquary prompt remained after collection")
		_expect(not reliquary.weapon_display.visible, "Reliquary weapon remained after collection")
	if ballroom_fx != null:
		_expect(not ballroom_fx.is_animation_processing(), "Off-screen Ballroom FX still processes")
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("HOLLOW_DUCHESS_MAIN_TEST: PASS boss=1 layers=1 entrance=1 presentation=1 cp05=1 hud=1 reliquary=1 candles=1 proximity=112 mirror=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("HOLLOW_DUCHESS_MAIN_TEST: %s" % failure)
	quit(1)
