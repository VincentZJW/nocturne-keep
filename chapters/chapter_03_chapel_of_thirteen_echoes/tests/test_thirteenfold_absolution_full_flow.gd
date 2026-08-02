extends SceneTree

## W5 final contract. Run this file in two fresh Godot processes with
## W5_FULL_FLOW_PHASE=write and W5_FULL_FLOW_PHASE=load.

const CHAPTER_ID: StringName = &"CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES"
const WEAPON_ID: StringName = &"thirteenfold_absolution_blades"
const ROUTE_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/"
	+ "chapter_03_route.tscn"
)
const PROFILE_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/chapter/"
	+ "chapter_03_start_profile.tres"
)
const TEST_SAVE_PATH: String = "user://thirteenfold_absolution_w5_full_flow.json"
const FLAG_SPAWNED: StringName = &"chapter_03_boss_reward_spawned"
const FLAG_COLLECTED: StringName = &"chapter_03_boss_reward_collected"
const FLAG_UNLOCKED: StringName = &"chapter_03_underkeep_descent_unlocked"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var phase: String = OS.get_environment("W5_FULL_FLOW_PHASE").strip_edges().to_lower()
	if phase == "write":
		await _run_write_phase()
	elif phase == "load":
		await _run_load_phase()
	else:
		_failures.append("Set W5_FULL_FLOW_PHASE to write or load")
	_finish(phase)


func _run_write_phase() -> void:
	var service: PlayerProgressSaveServiceState = _save_service()
	var session: ChapterSessionState = _session()
	var profile: ChapterStartProfile = load(PROFILE_PATH) as ChapterStartProfile
	_expect(service.set_save_path_for_testing(TEST_SAVE_PATH), "isolated W5 save path rejected")
	_expect(service.clear_progress() == OK, "stale W5 save could not be cleared")
	session.begin_formal_new_game()
	_expect(profile != null, "Chapter III profile could not load")
	if profile == null:
		return
	session.apply_start_profile(profile, &"CH3_BOSS")
	_expect(service.enable_formal_persistence(false) == OK, "formal persistence did not start")
	var route: Chapter03Route = await _instantiate_route()
	if route == null:
		return
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var boss_room: Chapter03BossSanctumRoom = controller.active_room as Chapter03BossSanctumRoom
	_expect(boss_room != null, "CH3_BOSS did not load the formal Boss room")
	if boss_room == null:
		return
	boss_room.sanctum.skip_intro_to_combat_state()
	boss_room.boss.activate(controller.player)
	boss_room.boss.config.death_sequence_duration = 0.10
	boss_room.reward_sequence.fragment_duration = 0.10
	boss_room.reward_sequence.seal_duration = 0.10
	boss_room.reward_sequence.forge_duration = 0.10
	boss_room.reward_sequence.hold_duration = 0.10
	boss_room.boss.debug_enter_phase_02_immediate()
	boss_room.boss.health_component.set_current_health(0)
	_expect(
		await _wait_until(Callable(boss_room.reward_sequence, "is_complete"), 4.0),
		"Boss defeat did not finish the formal reward formation"
	)
	_expect(
		await _wait_for_exit_open(boss_room.post_boss_exit, 2.0),
		"Boss exit did not open after death environment and formation"
	)
	_expect(session.has_story_flag(FLAG_SPAWNED), "formation did not persist reward-spawned flag")
	_expect(controller.request_room_change(&"CH3_POST_BOSS", &"EntryWest"), "post-Boss transition rejected")
	_expect(await _wait_for_room(controller, &"CH3_POST_BOSS", 3.0), "post-Boss room transition timed out")
	var post_room: Chapter03PostBossRoom = controller.active_room as Chapter03PostBossRoom
	_expect(post_room != null, "formal post-Boss room is not typed")
	if post_room == null:
		return
	_expect(post_room.reliquary.is_reward_available(), "reward is not collectable before pickup")
	_expect(not post_room.underkeep_exit.monitoring, "underkeep opened before pickup")
	_expect(post_room.reliquary.pickup.collect(), "formal unique pickup failed")
	await process_frame
	await physics_frame
	_assert_equipped_contract(controller.player)
	_expect(not post_room.reliquary.pickup.collect(), "duplicate pickup was accepted")
	_expect(post_room.underkeep_exit.monitoring, "underkeep exit stayed locked after pickup")
	_expect(post_room.reliquary.descent_blocker.disabled, "descent blocker stayed enabled")
	_expect(session.has_story_flag(FLAG_COLLECTED), "reward-collected flag missing")
	_expect(session.has_story_flag(FLAG_UNLOCKED), "underkeep-unlocked flag missing")
	_expect(session.is_chapter_completed(CHAPTER_ID), "Chapter III completion missing")
	_expect(controller.request_room_change(&"CH3_UNDERKEEP_DESCENT", &"EntryWest"), "underkeep transition rejected")
	_expect(await _wait_for_room(controller, &"CH3_UNDERKEEP_DESCENT", 3.0), "underkeep transition timed out")
	await _assert_death_respawn_retention(controller.player)
	session.set_transition_target(CHAPTER_ID, &"CH3_UNDERKEEP_DESCENT")
	_expect(service.save_progress() == OK, "final W5 progress save failed")
	_expect(FileAccess.file_exists(TEST_SAVE_PATH), "W5 progress file was not created")
	var json: JSON = JSON.new()
	_expect(json.parse(FileAccess.get_file_as_string(TEST_SAVE_PATH)) == OK, "W5 progress is not valid JSON")
	route.queue_free()
	await _stop_music_and_flush()


func _run_load_phase() -> void:
	var service: PlayerProgressSaveServiceState = _save_service()
	var session: ChapterSessionState = _session()
	_expect(service.set_save_path_for_testing(TEST_SAVE_PATH), "isolated W5 save path rejected")
	_expect(FileAccess.file_exists(TEST_SAVE_PATH), "write-phase W5 save is missing")
	session.begin_formal_new_game()
	_expect(service.load_progress() == OK, "fresh process could not load W5 progress")
	_assert_progress_contract()
	var route: Chapter03Route = await _instantiate_route()
	if route == null:
		return
	var controller: Chapter03RoomTransitionController = route.transition_controller
	_expect(controller.active_room_id == &"CH3_UNDERKEEP_DESCENT", "recovery did not resume in Underkeep")
	_assert_equipped_contract(controller.player)
	await _assert_death_respawn_retention(controller.player)
	_expect(controller._swap_room(&"CH3_POST_BOSS", &"EntryWest"), "return to post-Boss room failed")
	await process_frame
	await physics_frame
	var restored_room: Chapter03PostBossRoom = controller.active_room as Chapter03PostBossRoom
	_expect(restored_room != null, "restored post-Boss room is not typed")
	if restored_room != null:
		_expect(restored_room.reliquary.is_reward_collected(), "restored reliquary is not empty")
		_expect(not restored_room.reliquary.is_reward_available(), "restored reliquary respawned reward")
		_expect(restored_room.underkeep_exit.monitoring, "restored underkeep gate is closed")
		_expect(not restored_room.reliquary.pickup.collect(), "restored pickup duplicated weapon")
	route.queue_free()
	await _stop_music_and_flush()
	var hash_before: String = FileAccess.get_sha256(ProjectSettings.globalize_path(TEST_SAVE_PATH))
	service.begin_debug_session()
	await _validate_debug_starts()
	var hash_after: String = FileAccess.get_sha256(ProjectSettings.globalize_path(TEST_SAVE_PATH))
	_expect(hash_before == hash_after, "debug state modified formal W5 save")
	_expect(not service.is_persistence_enabled(), "debug state left formal persistence enabled")
	_expect(service.clear_progress() == OK, "W5 test save cleanup failed")


func _validate_debug_starts() -> void:
	var profile: ChapterStartProfile = load(PROFILE_PATH) as ChapterStartProfile
	_expect(profile != null, "debug start profile could not load")
	if profile == null:
		return
	for spawn_id: StringName in [
		&"CH3_BOSS", &"CH3_POST_BOSS", &"CH3_REWARD_TEST", &"CH3_UNDERKEEP_DESCENT",
	]:
		var session: ChapterSessionState = _session()
		session.begin_debug_run()
		session.apply_start_profile(profile, spawn_id)
		var debug_route: Chapter03Route = await _instantiate_route()
		if debug_route == null:
			continue
		var controller: Chapter03RoomTransitionController = debug_route.transition_controller
		match spawn_id:
			&"CH3_BOSS":
				_expect(controller.active_room_id == &"CH3_BOSS", "CH3_BOSS debug mapping failed")
				_expect(not _inventory().owns_weapon(WEAPON_ID), "Boss start pre-owned final reward")
			&"CH3_POST_BOSS", &"CH3_REWARD_TEST":
				_expect(controller.active_room_id == &"CH3_POST_BOSS", "%s room mapping failed" % spawn_id)
				var post_room: Chapter03PostBossRoom = controller.active_room as Chapter03PostBossRoom
				_expect(post_room != null, "%s did not load typed post-Boss room" % spawn_id)
				if post_room != null:
					_expect(post_room.reliquary.is_reward_available(), "%s reward is unavailable" % spawn_id)
					_expect(not post_room.underkeep_exit.monitoring, "%s gate started open" % spawn_id)
				_expect(not _inventory().owns_weapon(WEAPON_ID), "%s pre-owned final reward" % spawn_id)
			&"CH3_UNDERKEEP_DESCENT":
				_expect(
					controller.active_room_id == &"CH3_UNDERKEEP_DESCENT",
					"CH3_UNDERKEEP_DESCENT debug mapping failed"
				)
				_assert_equipped_contract(controller.player)
				_expect(session.has_story_flag(FLAG_COLLECTED), "underkeep debug collected flag missing")
				_expect(session.has_story_flag(FLAG_UNLOCKED), "underkeep debug unlock flag missing")
				_expect(session.is_chapter_completed(CHAPTER_ID), "underkeep debug completion missing")
		debug_route.queue_free()
		await _stop_music_and_flush()


func _instantiate_route() -> Chapter03Route:
	var packed: PackedScene = load(ROUTE_PATH) as PackedScene
	var route: Chapter03Route = packed.instantiate() as Chapter03Route if packed != null else null
	_expect(route != null, "formal Chapter III route could not instantiate")
	if route == null:
		return null
	root.add_child(route)
	await process_frame
	await physics_frame
	return route


func _assert_progress_contract() -> void:
	var session: ChapterSessionState = _session()
	var inventory: PlayerWeaponInventory = _inventory()
	var equipment: PlayerEquipmentManager = _equipment()
	_expect(inventory.owns_weapon(WEAPON_ID), "loaded inventory lacks Thirteenfold Absolution")
	_expect(equipment.equipped_weapon_id == WEAPON_ID, "loaded equipment ID mismatch")
	_expect(equipment.get_normal_attack_damage() == 14, "loaded normal damage is not 14")
	_expect(equipment.get_dash_attack_damage() == 28, "loaded Dash damage is not 28")
	_expect(session.has_story_flag(FLAG_SPAWNED), "loaded spawned flag missing")
	_expect(session.has_story_flag(FLAG_COLLECTED), "loaded collected flag missing")
	_expect(session.has_story_flag(FLAG_UNLOCKED), "loaded underkeep flag missing")
	_expect(session.is_chapter_completed(CHAPTER_ID), "loaded Chapter III completion missing")
	_expect(session.current_chapter_id == CHAPTER_ID, "loaded recovery chapter mismatch")
	_expect(session.pending_spawn_id == &"CH3_UNDERKEEP_DESCENT", "loaded recovery spawn mismatch")


func _assert_equipped_contract(player: Player) -> void:
	var inventory: PlayerWeaponInventory = _inventory()
	var equipment: PlayerEquipmentManager = _equipment()
	var visual: PlayerWeaponVisual = player.get_node_or_null(
		"VisualRoot/WeaponVisual"
	) as PlayerWeaponVisual
	_expect(inventory.owns_weapon(WEAPON_ID), "unique inventory ownership missing")
	_expect(equipment.equipped_weapon_id == WEAPON_ID, "weapon did not remain equipped")
	_expect(equipment.get_normal_attack_damage() == 14, "normal damage contract changed")
	_expect(equipment.get_dash_attack_damage() == 28, "Dash damage contract changed")
	_expect(visual != null, "Player WeaponVisual is missing")
	if visual != null:
		_expect(visual.get_visual_id() == &"thirteenfold_absolution", "Player visual ID mismatch")


func _assert_death_respawn_retention(player: Player) -> void:
	player.health_component.take_damage(player.health_component.max_health)
	await process_frame
	_expect(player.is_dead(), "lethal damage did not enter death state")
	_expect(_equipment().equipped_weapon_id == WEAPON_ID, "death cleared equipped weapon")
	_expect(player.respawn_at(player.global_position), "direct W5 respawn failed")
	await process_frame
	_expect(not player.is_dead(), "Player remained dead after respawn")
	_assert_equipped_contract(player)


func _wait_for_room(
	controller: Chapter03RoomTransitionController, room_id: StringName, timeout_seconds: float
) -> bool:
	var deadline: int = Time.get_ticks_msec() + roundi(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if controller.active_room_id == room_id and not controller._transitioning:
			return true
	return false


func _wait_until(predicate: Callable, timeout_seconds: float) -> bool:
	var deadline: int = Time.get_ticks_msec() + roundi(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if predicate.call():
			return true
	return false


func _wait_for_exit_open(exit: Area2D, timeout_seconds: float) -> bool:
	var deadline: int = Time.get_ticks_msec() + roundi(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if exit.monitoring:
			return true
	return false


func _stop_music_and_flush() -> void:
	var music_manager: MusicManagerService = root.get_node_or_null(
		"MusicManager"
	) as MusicManagerService
	if music_manager != null:
		music_manager.stop_music()
	for _frame: int in range(4):
		await process_frame


func _session() -> ChapterSessionState:
	return root.get_node("ChapterSession") as ChapterSessionState


func _inventory() -> PlayerWeaponInventory:
	return root.get_node("WeaponInventory") as PlayerWeaponInventory


func _equipment() -> PlayerEquipmentManager:
	return root.get_node("EquipmentManager") as PlayerEquipmentManager


func _save_service() -> PlayerProgressSaveServiceState:
	return root.get_node("PlayerProgressSaveService") as PlayerProgressSaveServiceState


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish(phase: String) -> void:
	if _failures.is_empty():
		print((
			"THIRTEENFOLD_ABSOLUTION_W5 | PASS phase=%s boss=true pickup=unique "
			+ "damage=14/28 disk=true reload=true respawn=true debug_isolated=true"
		) % phase)
		quit(0)
		return
	for failure: String in _failures:
		push_error("THIRTEENFOLD_ABSOLUTION_W5: %s" % failure)
	print("THIRTEENFOLD_ABSOLUTION_W5 | FAIL phase=%s count=%d" % [phase, _failures.size()])
	quit(1)
