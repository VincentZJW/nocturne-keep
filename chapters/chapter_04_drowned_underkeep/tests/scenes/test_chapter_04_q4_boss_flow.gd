extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_AREA_11"
	debug.debug_skip_chapter_intro = true
	_check(ProjectSettings.get_setting("application/run/main_scene") == BOOTSTRAP, "F5 main scene must remain MainBootstrap")
	_check(change_scene_to_file(BOOTSTRAP) == OK, "MainBootstrap must launch")
	var level: Node = await _wait_for_level()
	if level == null:
		_finish()
		return
	var controller: Chapter04RoomTransitionController = level.get_node("RoomTransitionController") as Chapter04RoomTransitionController
	var player: Player = level.get_node("ChapterRuntime/Player") as Player
	await process_frame
	await process_frame
	_check(controller.active_room_id == &"CH4_AREA_11", "Main must begin this regression in Final Lock Approach")
	var final_lock_exit: Chapter04RoomExit = controller.active_room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
	_check(final_lock_exit != null, "Final Lock Approach east exit must exist")
	if final_lock_exit != null:
		_check(final_lock_exit.requires_interaction, "Final Lock Approach east exit must require interact")
		_check(final_lock_exit.destination_room_id == &"CH4_AREA_12", "Final Lock Approach must target Last Gaol Checkpoint")
		_check(final_lock_exit.destination_spawn_id == &"EntryWest", "Final Lock Approach must target Area 12 EntryWest")
		await _enter_exit_range(player, final_lock_exit)
		_check(final_lock_exit.is_player_in_range(), "Final Lock Approach exit must detect Player before input")
		_check(final_lock_exit.is_prompt_visible(), "Final Lock Approach must show its E interaction prompt")
		await _press_action_once(&"interact")
		_check(await _wait_for_room(controller, &"CH4_AREA_12"), "Final Lock interaction must enter Last Gaol Checkpoint")
		var area_twelve_spawn: Marker2D = controller.active_room.call("get_spawn", &"EntryWest") as Marker2D
		_check(area_twelve_spawn != null and player.global_position == area_twelve_spawn.global_position, "Area 12 must use its saved EntryWest spawn")

	var checkpoint_exit: Chapter04RoomExit = controller.active_room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
	_check(checkpoint_exit != null and not checkpoint_exit.requires_interaction, "Last Gaol Checkpoint must retain its automatic handoff")
	if checkpoint_exit != null:
		await _enter_exit_range(player, checkpoint_exit)
		_check(await _wait_for_room(controller, &"CH4_AREA_13"), "Last Gaol Checkpoint must continue to Soul Lock Antechamber")

	var soul_lock_exit: Chapter04RoomExit = controller.active_room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
	_check(soul_lock_exit != null and soul_lock_exit.requires_interaction, "Soul Lock Antechamber must retain its explicit Boss-gate interaction")
	if soul_lock_exit != null:
		var boss_gate_blocker: StaticBody2D = controller.active_room.get_node_or_null("BossGatePresentation/GateBlocker") as StaticBody2D
		_check(
			boss_gate_blocker != null and soul_lock_exit.global_position.x < boss_gate_blocker.global_position.x - 40.0,
			"Soul Lock interaction Area must remain reachable in front of the closed physical gate"
		)
		await _enter_exit_range(player, soul_lock_exit)
		_check(soul_lock_exit.is_prompt_visible(), "Soul Lock Antechamber must show its Boss-gate prompt")
		await _press_action_once(&"interact")
		_check(await _wait_for_room(controller, &"CH4_AREA_14"), "Soul Lock interaction must enter formal Ormund arena")

	var boss_room: Node = controller.active_room
	var boss: SoulGaolerOrmund = boss_room.get_node_or_null("Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
	var flow: Chapter04BossRoomController = boss_room.get_node_or_null("BossRoomController") as Chapter04BossRoomController
	var reward_exit: Chapter04RoomExit = boss_room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
	_check(boss != null and flow != null, "formal Main boss room must bind Ormund and its flow controller")
	_check(reward_exit != null and reward_exit.is_locked(), "Boss reward exit must begin locked")
	_check(boss_room.has_node("BossFlowUI/BossHUD"), "Boss HUD must exist in Main runtime")
	if boss != null and flow != null:
		flow.skip_intro_for_qa()
		await process_frame
		_check(boss.is_combat_enabled(), "Boss must enter combat after intro")
		_check(boss.hurtbox.is_enabled, "Boss Hurtbox must open after intro")
		boss.health_component.take_damage(37)
		player.respawned.emit(player.global_position)
		await create_timer(1.1).timeout
		boss_room = controller.active_room
		boss = boss_room.get_node_or_null("Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
		flow = boss_room.get_node_or_null("BossRoomController") as Chapter04BossRoomController
		reward_exit = boss_room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
		_check(boss != null and boss.health_component.current_health == boss.health_component.max_health, "Player respawn must rebuild a full-health Boss encounter")
		_check(boss != null and boss.is_combat_enabled(), "Boss retry must resume without replaying the long intro")
		boss.health_component.set_current_health(roundi(boss.health_component.max_health * 0.5))
		await process_frame
		boss.complete_debug_phase_transition()
		_check(boss.phase == 2, "Boss must enter Phase 2 below threshold")
		boss.health_component.set_current_health(0)
		await create_timer(3.2).timeout
		_check(not reward_exit.is_locked(), "Boss defeat must unlock only the reward-room exit")
	var session: ChapterSessionState = root.get_node_or_null("ChapterSession") as ChapterSessionState
	_check(session.has_story_flag(&"ch4_boss_defeated"), "Boss defeat flag must persist")
	_check(session.has_story_flag(&"ch4_reward_unlocked"), "Reward unlock flag must persist")
	_check(controller._swap_room(&"CH4_AREA_13", &"EntryWest"), "Main must leave the defeated Boss room")
	_check(controller._swap_room(&"CH4_AREA_14", &"EntryWest"), "Main must support returning through the defeated Boss room")
	await process_frame
	await process_frame
	_check(controller.active_room.get_node_or_null("Enemies/SoulGaolerOrmund") == null, "Defeated Boss must not respawn on route backtracking")
	var defeated_exit: Chapter04RoomExit = controller.active_room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
	_check(defeated_exit != null and not defeated_exit.is_locked(), "Defeated Boss room must keep the reward route open")

	_check(controller._swap_room(&"CH4_AREA_15", &"EntryWest"), "Main must load reward room")
	await process_frame
	await process_frame
	var reward: Chapter04RewardController = controller.active_room.get_node_or_null("RewardController") as Chapter04RewardController
	var memory_exit: Chapter04RoomExit = controller.active_room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
	_check(reward != null and memory_exit != null and memory_exit.is_locked(), "Unclaimed reward must lock the memory passage")
	var inventory: PlayerWeaponInventory = root.get_node("WeaponInventory") as PlayerWeaponInventory
	var equipment: PlayerEquipmentManager = root.get_node("EquipmentManager") as PlayerEquipmentManager
	_check(not inventory.owns_weapon(&"soul_lock_twin_keys"), "Boss defeat alone must not grant the reward")
	_check(not session.has_story_flag(&"ch4_memory_passage_unlocked"), "Boss defeat alone must not unlock Chapter V route")
	if reward != null:
		_check(await _wait_for_reward_claimable(reward), "Soul-Lock reward presentation must become claimable")
		player.global_position = reward.pickup.global_position
		player.velocity = Vector2.ZERO
		reward.pickup._on_body_entered(player)
		_check(reward.pickup.prompt.visible, "Soul-Lock pickup must show the real E prompt")
		_check(player.can_process_gameplay_interaction(), "Reward presentation must restore Player interaction input")
		await _press_action_once(&"interact")
	await process_frame
	_check(session.has_story_flag(&"ch4_reward_collected"), "Reward collection flag must persist")
	_check(session.has_story_flag(&"ch4_memory_passage_unlocked"), "Memory passage flag must persist")
	_check(not memory_exit.is_locked(), "Claiming the reward must unlock Area 16")
	_check(inventory.owns_weapon(&"soul_lock_twin_keys"), "Soul-Lock Twin Keys ownership must persist")
	_check(equipment.equipped_weapon_id == &"soul_lock_twin_keys", "Soul-Lock Twin Keys must auto-equip")
	_check(equipment.get_normal_attack_damage() == 16, "Soul-Lock normal damage must be 16")
	_check(equipment.get_dash_attack_damage() == 32, "Soul-Lock Dash damage must be 32")
	_check(reward != null and reward.is_collected(), "Soul-Lock duplicate pickup guard must remain collected")

	_check(controller._swap_room(&"CH4_AREA_16", &"EntryWest"), "Main must load Hall of Drowned Memories")
	await process_frame
	_check(controller.active_room.has_node("Transitions/MemoryExit"), "Hall of Drowned Memories must expose CH5 exit")
	_check(controller.active_room.has_node("MemoryPassageController"), "Hall of Drowned Memories must own its short memory presentation")
	await create_timer(3.35).timeout
	_check(player.get_input_profile() == Player.InputProfile.FULL, "Memory presentation must restore Player control")
	var ch5: ChapterStartProfile = ChapterRegistry.get_chapter(ChapterRegistry.CHAPTER_05_NIGHT_REPEATED)
	_check(ch5.debug_ready, "Chapter V placeholder must be debug-loadable")
	_check(&"CH5_START" in ch5.available_spawn_ids, "Chapter V profile must register CH5_START")
	_check(ResourceLoader.exists(ch5.main_scene_path, "PackedScene"), "Chapter V placeholder scene must exist")

	_check(controller._swap_room(&"CH4_AREA_05", &"EntryWest"), "Main must load the Cistern")
	await process_frame
	await process_frame
	var spawner: Chapter04EncounterSpawner = controller.active_room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
	var gate: Chapter04EncounterGate = controller.active_room.get_node_or_null("Transitions/CisternExitGate") as Chapter04EncounterGate
	_check(spawner != null and gate != null and gate.is_locked(), "Cistern exit must start encounter-locked")
	if spawner != null:
		for group: EncounterGroup in spawner.get_encounter_groups():
			group.activate(level.get_node("ChapterRuntime/Player") as Player)
			for enemy: EnemyCombatant in group.get_enemies():
				_check(enemy.visible and enemy.is_ai_active(), "%s must wake visibly with AI" % enemy.name)
				var health: HealthComponent = enemy.get_health_component()
				_check(health != null, "%s must expose HealthComponent" % enemy.name)
				if health != null:
					health.set_current_health(0)
			await process_frame
			await process_frame
		await process_frame
	_check(gate != null and not gate.is_locked(), "Clearing every Cistern encounter must unlock the formal exit")
	var cistern_exit: Chapter04RoomExit = controller.active_room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
	if cistern_exit != null:
		cistern_exit._on_body_entered(player)
		_check(cistern_exit.is_prompt_visible(), "Cistern east exit must show its interaction prompt")
		var interact_event: InputEventAction = InputEventAction.new()
		interact_event.action = &"interact"
		interact_event.pressed = true
		cistern_exit._unhandled_input(interact_event)
		await create_timer(0.9).timeout
		_check(controller.active_room_id == &"CH4_AREA_06", "Cistern interaction must load Area 06 through the Main transition controller")
		var area_six_spawn: Marker2D = controller.active_room.call("get_spawn", &"EntryWest") as Marker2D
		_check(area_six_spawn != null and player.global_position == area_six_spawn.global_position, "Cistern transition must place Player at Area 06 EntryWest")
	else:
		_check(false, "Cistern east interaction exit is missing")

	_check(controller._swap_room(&"CH4_AREA_16", &"EntryWest"), "Main must return to the memory hall for its formal chapter exit")
	await create_timer(3.35).timeout
	_check(player.get_input_profile() == Player.InputProfile.FULL, "Memory fragments must restore full Player input after the room transition lock")
	var chapter_exit: Chapter04MemoryExit = controller.active_room.get_node_or_null("Transitions/MemoryExit") as Chapter04MemoryExit
	if chapter_exit != null:
		chapter_exit._on_body_entered(player)
		_check(chapter_exit.prompt.visible, "Chapter V memory exit must show its E prompt")
		var chapter_event: InputEventAction = InputEventAction.new()
		chapter_event.action = &"interact"
		chapter_event.pressed = true
		chapter_exit._unhandled_input(chapter_event)
		await create_timer(2.2).timeout
		_check(current_scene != null and current_scene.scene_file_path == ch5.main_scene_path, "Memory exit must load the registered Chapter V scene")
		var ch5_player: Player = current_scene.get_tree().get_first_node_in_group("player") as Player
		var ch5_spawn: Marker2D = current_scene.get_node_or_null("SpawnPoints/CH5_START") as Marker2D if current_scene != null else null
		var entered_at_ch5_start: bool = (
			ch5_player != null
			and ch5_spawn != null
			and absf(ch5_player.global_position.x - ch5_spawn.global_position.x) <= 1.0
			and ch5_player.global_position.y >= ch5_spawn.global_position.y
			and ch5_player.global_position.y <= ch5_spawn.global_position.y + 48.0
		)
		_check(entered_at_ch5_start, "Chapter V must enter at CH5_START and settle only onto its adjacent floor")
	else:
		_check(false, "Chapter V memory exit is missing")

	debug.reset_to_defaults()
	_finish()


func _wait_for_level() -> Node:
	for _frame: int in 480:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _enter_exit_range(player: Player, room_exit: Chapter04RoomExit) -> void:
	player.global_position = room_exit.global_position + Vector2(-140.0, 42.0)
	player.velocity = Vector2.ZERO
	await physics_frame
	player.global_position = room_exit.global_position + Vector2(0.0, 42.0)
	player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame


func _press_action_once(action: StringName) -> void:
	var press: InputEventAction = InputEventAction.new()
	press.action = action
	press.pressed = true
	press.strength = 1.0
	Input.parse_input_event(press)
	await process_frame
	var release: InputEventAction = InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame


func _wait_for_room(controller: Chapter04RoomTransitionController, room_id: StringName) -> bool:
	for _frame: int in 300:
		await process_frame
		if controller.active_room_id == room_id and not controller.is_transitioning():
			return true
	return false


func _wait_for_reward_claimable(reward: Chapter04RewardController) -> bool:
	var deadline_ms: int = Time.get_ticks_msec() + 10000
	while Time.get_ticks_msec() < deadline_ms:
		await process_frame
		if reward.get_current_stage() == &"claimable":
			return true
	return false


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CH4 Q4/BOSS FLOW | PASS Main=bootstrap Boss=P1/P2/death reward=locked/collected memory=CH5_START cistern=cleared")
		unload_current_scene()
		for _frame: int in 8:
			await process_frame
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH4 Q4/BOSS FLOW: %s" % failure)
	quit(1)
