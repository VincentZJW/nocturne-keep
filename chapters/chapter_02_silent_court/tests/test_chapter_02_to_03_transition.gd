extends SceneTree

const CHAPTER_02_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"

var _failures: Array[String] = []
var _death_lines: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var session: ChapterSessionState = root.get_node("ChapterSession") as ChapterSessionState
	var manager: SceneTransitionManagerState = root.get_node(
		"SceneTransitionManager"
	) as SceneTransitionManagerState
	session.begin_debug_run()
	manager.default_fade_out_duration = 0.01
	manager.default_fade_in_duration = 0.01
	var level: SilentCourtLevel = await _load_silent_court()
	if level == null:
		_finish()
		return
	var boss: HollowDuchess = level.get_node(
		"GameplayWorld/BossArea/HollowDuchess"
	) as HollowDuchess
	var controller: Chapter02To03TransitionController = level.get_node(
		"ChapterSystems/Chapter02To03TransitionController"
	) as Chapter02To03TransitionController
	var gate: BallroomMirrorGate = level.get_node(
		"GameplayWorld/BossArea/BallroomMirrorGate"
	) as BallroomMirrorGate
	controller.transition_data = controller.transition_data.duplicate(true) as Chapter02TransitionData
	controller.transition_data.mirror_reveal_duration = 0.01
	controller.transition_data.door_open_duration = 0.01
	boss.config = boss.config.duplicate(true) as HollowDuchessConfig
	boss.config.death_player_line_time = 0.01
	boss.config.death_boss_line_time = 0.02
	boss.config.death_passage_line_time = 0.03
	boss.config.death_echo_line_time = 0.04
	boss.config.death_duration = 0.06
	boss.death_line_requested.connect(_on_death_line)
	boss.debug_set_health(0)
	await _wait_until(func() -> bool: return gate.is_revealed(), 120, "mirror reveal")
	_expect(_death_lines == [
		"夜巡守卫：你认识我？",
		"瑟芙琳：不……但殿下一直在等你。",
		"瑟芙琳：穿过镜后的礼门。",
		"瑟芙琳：十三声忏悔，会替她回答。",
	], "Death dialogue sequence mismatch: %s" % [_death_lines])
	_expect(session.has_story_flag(&"hollow_duchess_defeated"), "Duchess flag missing")
	_expect(session.has_story_flag(&"chapter_02_exit_revealed"), "Exit reveal flag missing")
	_expect(not boss.visible, "Defeated Boss did not disappear")
	_expect(controller.get_reward_placeholder() != null, "Reward placeholder did not spawn")
	# Re-enter the saved scene before collecting: Boss stays gone, mirror stays open,
	# and the missing placeholder is deterministically recreated.
	level.queue_free()
	await process_frame
	var reloaded: SilentCourtLevel = await _load_silent_court()
	if reloaded == null:
		_finish()
		return
	var reload_boss: HollowDuchess = reloaded.get_node(
		"GameplayWorld/BossArea/HollowDuchess"
	) as HollowDuchess
	var reload_controller: Chapter02To03TransitionController = reloaded.get_node(
		"ChapterSystems/Chapter02To03TransitionController"
	) as Chapter02To03TransitionController
	var reload_gate: BallroomMirrorGate = reloaded.get_node(
		"GameplayWorld/BossArea/BallroomMirrorGate"
	) as BallroomMirrorGate
	reload_controller.transition_data = reload_controller.transition_data.duplicate(true) as Chapter02TransitionData
	reload_controller.transition_data.door_open_duration = 0.01
	_expect(not reload_boss.visible, "Boss respawned after persisted defeat")
	_expect(reload_gate.is_revealed(), "Mirror closed after reload")
	var reward: Chapter02BossRewardPlaceholder = reload_controller.get_reward_placeholder()
	_expect(reward != null and reward.is_available(), "Reward placeholder was not recovered")
	# Gate refuses passage until the placeholder condition has been collected.
	reload_gate.passage_requested.emit()
	await process_frame
	_expect(not manager.is_transitioning(), "Gate bypassed the reward prerequisite")
	if reward != null:
		reward.placeholder_collected.emit()
	await process_frame
	_expect(session.has_story_flag(&"chapter_02_boss_weapon_collected"), "Reward flag missing")
	reload_gate.passage_requested.emit()
	await _wait_for_scene("RoyalChapelPassage", 240)
	_expect(session.has_story_flag(&"chapter_02_completed"), "Chapter II completion flag missing")
	_expect(session.has_story_flag(&"royal_chapel_passage_opened"), "Passage flag missing")
	var passage: RoyalChapelPassage = current_scene as RoyalChapelPassage
	_expect(passage != null, "Royal Processional Passage did not load")
	if passage != null:
		await _wait_until(func() -> bool: return not manager.is_transitioning(), 180, "passage fade-in")
		passage.debug_enter_chapter_three()
		await _wait_for_scene("Chapter03EntryPlaceholder", 240)
	_expect(current_scene is Chapter03EntryPlaceholder, "Chapter III entry placeholder did not load")
	_expect(session.has_story_flag(&"chapter_03_started"), "Chapter III started flag missing")
	if current_scene != null:
		for path: String in [
			"SpawnPoints/Chapter03PlayerSpawn", "Checkpoints/Chapter03CP01", "CameraBounds",
			"Doors/ChapelSideDoor", "NarrativeTriggers/ChapterTitleTrigger",
			"GameplayWorld/Geometry/MainRouteExitPlaceholder",
		]:
			_expect(current_scene.get_node_or_null(path) != null, "Missing Chapter III node: %s" % path)
	_finish()


func _load_silent_court() -> SilentCourtLevel:
	var packed: PackedScene = load(CHAPTER_02_PATH) as PackedScene
	var level: SilentCourtLevel = packed.instantiate() as SilentCourtLevel if packed != null else null
	if level == null:
		_failures.append("Silent Court failed to instantiate")
		return null
	root.add_child(level)
	current_scene = level
	for _frame: int in range(5):
		await process_frame
	return level


func _on_death_line(speaker: String, text: String) -> void:
	_death_lines.append("%s：%s" % [speaker, text])


func _wait_until(predicate: Callable, maximum_frames: int, label: String) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if predicate.call():
			return
	_failures.append("Timed out waiting for %s" % label)


func _wait_for_scene(scene_name: String, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.name == scene_name:
			return
	_failures.append("Timed out waiting for scene %s" % scene_name)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CH2_TO_CH3_TRANSITION_TEST: PASS dialogue=4 mirror=1 reward_gate=1 reload=1 passage=1 chapter3=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH2_TO_CH3_TRANSITION_TEST: %s" % failure)
	quit(1)
