extends SceneTree

const CHAPTER_02_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"

var _failures: Array[String] = []
var _death_lines: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var session: ChapterSessionState = root.get_node("ChapterSession") as ChapterSessionState
	var inventory: PlayerWeaponInventory = root.get_node("WeaponInventory") as PlayerWeaponInventory
	var equipment: PlayerEquipmentManager = root.get_node("EquipmentManager") as PlayerEquipmentManager
	equipment.reset_for_new_run()
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
	await _wait_until(func() -> bool: return controller.get_reward_pickup() != null, 120, "reliquary reward")
	_expect(_death_lines == [
		"夜巡守卫：你认识我？",
		"瑟芙琳：不……但殿下一直在等你。",
		"瑟芙琳：穿过镜后的礼门。",
		"瑟芙琳：十三声忏悔，会替她回答。",
	], "Death dialogue sequence mismatch: %s" % [_death_lines])
	_expect(session.has_story_flag(&"hollow_duchess_defeated"), "Duchess flag missing")
	_expect(not session.has_story_flag(&"chapter_02_exit_revealed"), "Exit revealed before reliquary collection")
	_expect(not gate.is_revealed(), "Mirror revealed before reliquary collection")
	_expect(not boss.visible, "Defeated Boss did not disappear")
	_expect(controller.get_reward_pickup() != null, "Crimson Masque pickup did not spawn")
	# Re-enter before collecting: Boss stays gone, reliquary remains available and mirror stays sealed.
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
	var reload_reliquary: DuchessReliquary = reloaded.get_node(
		"GameplayWorld/BossArea/DuchessReliquary"
	) as DuchessReliquary
	reload_controller.transition_data = reload_controller.transition_data.duplicate(true) as Chapter02TransitionData
	reload_controller.transition_data.mirror_reveal_duration = 0.01
	reload_controller.transition_data.door_open_duration = 0.01
	_expect(not reload_boss.visible, "Boss respawned after persisted defeat")
	_expect(not reload_gate.is_revealed(), "Mirror revealed on uncollected reload")
	var reward: WeaponPickup = reload_controller.get_reward_pickup()
	_expect(reward != null and not reward.is_collected(), "Crimson Masque pickup was not recovered")
	_expect(reward != null and not reward.player_interaction_enabled, "Hidden pickup retained duplicate interaction")
	# Gate refuses passage until the fixed weapon has been collected.
	reload_gate.passage_requested.emit()
	await process_frame
	_expect(not manager.is_transitioning(), "Gate bypassed the reward prerequisite")
	if reward != null:
		reload_reliquary.pickup_requested.emit()
		await process_frame
		_expect(reward.is_collected(), "Reliquary interaction did not collect Crimson Masque")
	await _wait_until(func() -> bool: return reload_gate.is_revealed(), 120, "post-collection mirror reveal")
	_expect(session.has_story_flag(&"chapter_02_boss_weapon_collected"), "Reward flag missing")
	_expect(session.has_story_flag(&"chapter_02_exit_revealed"), "Exit reveal flag missing after reward")
	_expect(inventory.owns_weapon(&"crimson_masque_stilettos"), "Crimson Masque missing from inventory")
	_expect(equipment.equipped_weapon_id == &"crimson_masque_stilettos", "Crimson Masque did not auto-equip")
	_expect(equipment.get_normal_attack_damage() == 14, "Crimson Masque normal damage is not 14")
	_expect(equipment.get_dash_attack_damage() == 28, "Crimson Masque Dash damage is not 28")
	var player: Player = reloaded.player
	var weapon_visual: PlayerWeaponVisual = player.get_node("VisualRoot/WeaponVisual") as PlayerWeaponVisual
	_expect(weapon_visual.get_visual_id() == &"crimson_masque", "Crimson Masque Player visual did not switch")
	# Collected reload keeps the Boss gone and never duplicates the fixed reward.
	reloaded.queue_free()
	await process_frame
	var collected_reload: SilentCourtLevel = await _load_silent_court()
	var collected_controller: Chapter02To03TransitionController = collected_reload.get_node(
		"ChapterSystems/Chapter02To03TransitionController"
	) as Chapter02To03TransitionController
	_expect(collected_controller.get_reward_pickup() == null, "Collected reward respawned")
	var collected_gate: BallroomMirrorGate = collected_reload.get_node(
		"GameplayWorld/BossArea/BallroomMirrorGate"
	) as BallroomMirrorGate
	collected_gate.passage_requested.emit()
	await _wait_for_scene("RoyalChapelPassage", 240)
	_expect(session.has_story_flag(&"chapter_02_completed"), "Chapter II completion flag missing")
	_expect(session.has_story_flag(&"royal_chapel_passage_opened"), "Passage flag missing")
	var passage: RoyalChapelPassage = current_scene as RoyalChapelPassage
	_expect(passage != null, "Royal Processional Passage did not load")
	if passage != null:
		await _wait_until(func() -> bool: return not manager.is_transitioning(), 180, "passage fade-in")
		passage.debug_enter_chapter_three()
		await _wait_for_scene("Chapter03Route", 240)
	var chapter_three: Chapter03Route = current_scene as Chapter03Route
	_expect(chapter_three != null, "Formal Chapter III route did not load")
	_expect(session.has_story_flag(&"chapter_03_started"), "Chapter III started flag missing")
	await _wait_until(
		func() -> bool: return not manager.is_scene_retirement_in_progress(),
		300,
		"incremental scene retirement"
	)
	if chapter_three != null:
		_expect(
			chapter_three.transition_controller.active_room_id == &"CH3_CHAPEL_VESTIBULE",
			"Chapter II hand-off did not enter the formal Chapel Vestibule"
		)
		for path: String in [
			"RoomHost", "PersistentRuntime/ChapterRuntime/Player",
			"PersistentRuntime/ChapterRuntime/HUD", "RoomTransitionController",
		]:
			_expect(chapter_three.get_node_or_null(path) != null, "Missing formal Chapter III node: %s" % path)
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	for _frame: int in range(8):
		await process_frame
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
		print("CH2_TO_CH3_TRANSITION_TEST: PASS dialogue=4 reliquary=1 mirror_after_reward=1 crimson=14/28 reload=2 passage=1 formal_route=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH2_TO_CH3_TRANSITION_TEST: %s" % failure)
	quit(1)
