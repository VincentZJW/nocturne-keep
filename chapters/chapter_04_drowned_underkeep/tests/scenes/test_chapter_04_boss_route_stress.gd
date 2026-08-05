extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const RUNS: int = 10

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_AREA_12"
	debug.debug_skip_chapter_intro = true
	_check(change_scene_to_file(BOOTSTRAP) == OK, "MainBootstrap must launch")
	var level: Node = await _wait_for_level()
	if level == null:
		_finish()
		return
	var controller: Chapter04RoomTransitionController = level.get_node("RoomTransitionController") as Chapter04RoomTransitionController
	var player: Player = level.get_node("ChapterRuntime/Player") as Player
	var session: ChapterSessionState = root.get_node("ChapterSession") as ChapterSessionState
	for run_index: int in RUNS:
		_reset_boss_flags(session)
		_check(controller._swap_room(&"CH4_AREA_12", &"EntryWest"), "run %d checkpoint reload failed" % run_index)
		_check(controller.active_room.call("get_spawn", &"CP_CH4_BOSS") != null, "run %d CP_CH4_BOSS missing" % run_index)

		# Two gate-contract observations per run give the required 20 checks without
		# bypassing the room transition system or moving the Player out of bounds.
		# Exercise the actual E-action path twice per run (20 interactions total),
		# including prompt, fade-owned room transition and destination spawn.
		for gate_check: int in 2:
			_check(controller._swap_room(&"CH4_AREA_13", &"EntryWest"), "run %d antechamber load %d failed" % [run_index, gate_check])
			await process_frame
			await process_frame
			var boss_gate: Node = controller.active_room.get_node_or_null("BossGatePresentation")
			var exit: Chapter04RoomExit = controller.active_room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
			_check(boss_gate != null and exit != null and exit.requires_interaction, "run %d gate contract %d failed" % [run_index, gate_check])
			if exit != null:
				exit._on_body_entered(player)
				_check(exit.is_prompt_visible(), "run %d gate prompt %d missing" % [run_index, gate_check])
				var event: InputEventAction = InputEventAction.new()
				event.action = &"interact"
				event.pressed = true
				exit._unhandled_input(event)
				var blocker: StaticBody2D = boss_gate.get_node_or_null("GateBlocker") as StaticBody2D if boss_gate != null else null
				_check(blocker != null and blocker.collision_layer == 0, "run %d gate blocker %d remained active" % [run_index, gate_check])
				await _wait_for_room(controller, &"CH4_AREA_14")
				_check(controller.active_room_id == &"CH4_AREA_14", "run %d gate interaction %d did not load Boss room" % [run_index, gate_check])
				var gate_flow: Chapter04BossRoomController = controller.active_room.get_node_or_null("BossRoomController") as Chapter04BossRoomController
				if gate_flow != null:
					gate_flow.skip_intro_for_qa()
		session.set_story_flag(&"ch4_boss_intro_seen", false)
		_check(controller._swap_room(&"CH4_AREA_14", &"EntryWest"), "run %d Boss room load failed" % run_index)
		var flow: Chapter04BossRoomController = controller.active_room.get_node("BossRoomController") as Chapter04BossRoomController
		flow.intro_line_duration = 0.01
		await create_timer(1.35).timeout
		var boss: SoulGaolerOrmund = controller.active_room.get_node_or_null("Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
		_check(boss != null and boss.is_combat_enabled(), "run %d complete intro did not enter combat" % run_index)
		_check(player.get_input_profile() == Player.InputProfile.FULL, "run %d intro did not release Player" % run_index)

		boss.health_component.take_damage(37)
		player.respawned.emit(player.global_position)
		await create_timer(1.10).timeout
		boss = controller.active_room.get_node_or_null("Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
		_check(boss != null and boss.health_component.current_health == boss.health_component.max_health, "run %d retry did not reset Boss HP" % run_index)
		_check(boss != null and boss.is_combat_enabled(), "run %d short retry intro did not resume combat" % run_index)

		boss.health_component.set_current_health(0)
		await create_timer(3.05).timeout
		var reward_exit: Chapter04RoomExit = controller.active_room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
		_check(session.has_story_flag(&"ch4_boss_defeated"), "run %d defeat flag missing" % run_index)
		_check(reward_exit != null and not reward_exit.is_locked(), "run %d reward route stayed locked" % run_index)

		_check(controller._swap_room(&"CH4_AREA_15", &"EntryWest"), "run %d reward room load failed" % run_index)
		var reward: Chapter04RewardController = controller.active_room.get_node("RewardController") as Chapter04RewardController
		var memory_exit: Chapter04RoomExit = controller.active_room.get_node("Transitions/ExitEast") as Chapter04RoomExit
		_check(memory_exit.is_locked(), "run %d unclaimed reward did not lock exit" % run_index)
		if run_index < 5:
			_check(controller._swap_room(&"CH4_AREA_14", &"EntryWest"), "run %d unclaimed persistence backtrack failed" % run_index)
			for _frame: int in 3:
				await process_frame
			_check(controller.active_room.get_node_or_null("Enemies/SoulGaolerOrmund") == null, "run %d defeated Boss respawned" % run_index)
			_check(controller._swap_room(&"CH4_AREA_15", &"EntryWest"), "run %d unclaimed reward reload failed" % run_index)
			reward = controller.active_room.get_node("RewardController") as Chapter04RewardController
			memory_exit = controller.active_room.get_node("Transitions/ExitEast") as Chapter04RoomExit
			_check(not session.has_story_flag(&"ch4_reward_collected") and memory_exit.is_locked(), "run %d unclaimed state did not persist" % run_index)
		for _press: int in 10:
			reward.collect_for_qa()
		_check(session.has_story_flag(&"ch4_reward_collected"), "run %d reward was not collected" % run_index)
		_check(session.has_story_flag(&"ch4_memory_passage_unlocked"), "run %d memory passage flag missing" % run_index)
		_check(not memory_exit.is_locked(), "run %d memory passage stayed locked" % run_index)

		_check(controller._swap_room(&"CH4_AREA_16", &"EntryWest"), "run %d memory hall load failed" % run_index)
		_check(controller.active_room.has_node("Transitions/MemoryExit"), "run %d memory exit missing" % run_index)
		var ch5: ChapterStartProfile = ChapterRegistry.get_chapter(ChapterRegistry.CHAPTER_05_NIGHT_REPEATED)
		_check(ch5.debug_ready and &"CH5_START" in ch5.available_spawn_ids, "run %d CH5_START registry invalid" % run_index)

	debug.reset_to_defaults()
	_finish()


func _reset_boss_flags(session: ChapterSessionState) -> void:
	for flag: StringName in [
		&"ch4_boss_defeated",
		&"ch4_boss_intro_seen",
		&"ch4_reward_unlocked",
		&"ch4_reward_collected",
		&"ch4_memory_passage_unlocked",
	]:
		session.set_story_flag(flag, false)


func _wait_for_level() -> Node:
	for _frame: int in 480:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _wait_for_room(controller: Chapter04RoomTransitionController, room_id: StringName) -> void:
	for _frame: int in 180:
		await process_frame
		if not controller.is_transitioning() and controller.active_room_id == room_id:
			return


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CH4 BOSS ROUTE STRESS | PASS checkpoint=10 gate=20 intro=10 retry=10 death=10 unclaimed_reload=5 reward_collect=10 repeated_E=100 memory=10 CH5=10")
		unload_current_scene()
		for _frame: int in 12:
			await process_frame
		await create_timer(0.5, true, false, true).timeout
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH4 BOSS ROUTE STRESS: %s" % failure)
	quit(1)
