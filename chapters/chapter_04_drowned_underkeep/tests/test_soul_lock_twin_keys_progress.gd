extends SceneTree

## W4 persistence contract. Run in two fresh Godot processes with
## SOUL_LOCK_W4_PHASE=write and SOUL_LOCK_W4_PHASE=load.

const CHAPTER_ID: StringName = &"CHAPTER_04_DROWNED_UNDERKEEP"
const WEAPON_ID: StringName = &"soul_lock_twin_keys"
const ROUTE_PATH: String = (
	"res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
)
const PROFILE_PATH: String = (
	"res://chapters/chapter_04_drowned_underkeep/resources/chapter/"
	+ "chapter_04_start_profile.tres"
)
const TEST_SAVE_PATH: String = "user://soul_lock_twin_keys_w4.json"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var phase: String = OS.get_environment("SOUL_LOCK_W4_PHASE").strip_edges().to_lower()
	if phase == "write":
		await _run_write_phase()
	elif phase == "load":
		await _run_load_phase()
	else:
		_failures.append("Set SOUL_LOCK_W4_PHASE to write or load")
	_finish(phase)


func _run_write_phase() -> void:
	var service: PlayerProgressSaveServiceState = _save_service()
	var session: ChapterSessionState = _session()
	var profile: ChapterStartProfile = load(PROFILE_PATH) as ChapterStartProfile
	_expect(service.set_save_path_for_testing(TEST_SAVE_PATH), "isolated W4 save path rejected")
	_expect(service.clear_progress() == OK, "stale W4 save could not be cleared")
	session.begin_formal_new_game()
	_expect(profile != null, "Chapter IV profile could not load")
	if profile == null:
		return
	session.apply_start_profile(profile, &"CH4_AREA_15")
	session.set_story_flag(&"ch4_boss_defeated", true)
	session.set_story_flag(&"ch4_reward_unlocked", true)
	_expect(service.enable_formal_persistence(false) == OK, "formal persistence did not start")
	var route: DrownedUnderkeepRoute = await _instantiate_route()
	if route == null:
		return
	var controller: Chapter04RoomTransitionController = route.get_node(
		"RoomTransitionController"
	) as Chapter04RoomTransitionController
	var player: Player = route.get_node("ChapterRuntime/Player") as Player
	_expect(controller.active_room_id == &"CH4_AREA_15", "W4 did not begin in Area 15")
	var reward: Chapter04RewardController = controller.active_room.get_node_or_null(
		"RewardController"
	) as Chapter04RewardController
	var exit: Chapter04RoomExit = controller.active_room.get_node_or_null(
		"Transitions/ExitEast"
	) as Chapter04RoomExit
	_expect(reward != null, "formal reward controller is missing")
	_expect(exit != null and exit.is_locked(), "memory passage opened before collection")
	_expect(not _inventory().owns_weapon(WEAPON_ID), "fresh W4 profile pre-owned reward")
	if reward != null:
		_expect(reward.collect_for_qa(), "formal unique pickup failed")
	await process_frame
	_assert_equipped_contract(player)
	_expect(reward != null and not reward.collect_for_qa(), "duplicate pickup was accepted")
	_expect(exit != null and not exit.is_locked(), "collection did not unlock Area 16")
	_expect(session.has_story_flag(&"ch4_reward_collected"), "collected flag missing")
	_expect(session.has_story_flag(&"ch4_memory_passage_unlocked"), "memory flag missing")
	await _assert_death_respawn_retention(player)
	session.set_transition_target(CHAPTER_ID, &"CH4_AREA_16")
	_expect(service.save_progress() == OK, "W4 progress save failed")
	_expect(FileAccess.file_exists(TEST_SAVE_PATH), "W4 progress file was not created")
	route.queue_free()
	await _flush_frames()


func _run_load_phase() -> void:
	var service: PlayerProgressSaveServiceState = _save_service()
	var session: ChapterSessionState = _session()
	_expect(service.set_save_path_for_testing(TEST_SAVE_PATH), "isolated W4 save path rejected")
	_expect(FileAccess.file_exists(TEST_SAVE_PATH), "write-phase W4 save is missing")
	session.begin_formal_new_game()
	_expect(service.load_progress() == OK, "fresh process could not load W4 progress")
	_expect(_inventory().owns_weapon(WEAPON_ID), "loaded inventory lacks Soul-Lock Twin Keys")
	_expect(_equipment().equipped_weapon_id == WEAPON_ID, "loaded equipment ID mismatch")
	_expect(session.has_story_flag(&"ch4_reward_collected"), "loaded collected flag missing")
	_expect(session.has_story_flag(&"ch4_memory_passage_unlocked"), "loaded memory flag missing")
	var route: DrownedUnderkeepRoute = await _instantiate_route()
	if route == null:
		return
	var controller: Chapter04RoomTransitionController = route.get_node(
		"RoomTransitionController"
	) as Chapter04RoomTransitionController
	var player: Player = route.get_node("ChapterRuntime/Player") as Player
	_expect(controller.active_room_id == &"CH4_AREA_16", "recovery did not resume in Area 16")
	_assert_equipped_contract(player)
	_expect(controller._swap_room(&"CH4_AREA_15", &"EntryWest"), "return to Area 15 failed")
	await process_frame
	await physics_frame
	var restored_reward: Chapter04RewardController = controller.active_room.get_node_or_null(
		"RewardController"
	) as Chapter04RewardController
	var restored_exit: Chapter04RoomExit = controller.active_room.get_node_or_null(
		"Transitions/ExitEast"
	) as Chapter04RoomExit
	_expect(restored_reward != null and restored_reward.is_collected(), "reward respawned")
	_expect(restored_reward != null and not restored_reward.collect_for_qa(), "restored duplicate accepted")
	_expect(restored_exit != null and not restored_exit.is_locked(), "restored exit closed")
	route.queue_free()
	await _flush_frames()
	_expect(service.clear_progress() == OK, "W4 test save cleanup failed")


func _instantiate_route() -> DrownedUnderkeepRoute:
	var packed: PackedScene = load(ROUTE_PATH) as PackedScene
	var route: DrownedUnderkeepRoute = packed.instantiate() as DrownedUnderkeepRoute if packed != null else null
	_expect(route != null, "formal Chapter IV route could not instantiate")
	if route == null:
		return null
	root.add_child(route)
	await process_frame
	await physics_frame
	return route


func _assert_equipped_contract(player: Player) -> void:
	var visual: PlayerWeaponVisual = player.get_node_or_null(
		"VisualRoot/WeaponVisual"
	) as PlayerWeaponVisual
	_expect(_inventory().owns_weapon(WEAPON_ID), "unique inventory ownership missing")
	_expect(_inventory().get_owned_weapon_ids().count(WEAPON_ID) == 1, "duplicate inventory entry found")
	_expect(_equipment().equipped_weapon_id == WEAPON_ID, "weapon did not remain equipped")
	_expect(_equipment().get_normal_attack_damage() == 16, "normal damage is not 16")
	_expect(_equipment().get_dash_attack_damage() == 32, "Dash damage is not 32")
	_expect(visual != null, "Player WeaponVisual is missing")
	if visual != null:
		_expect(visual.get_visual_id() == &"soul_lock_twin_keys", "Player visual ID mismatch")


func _assert_death_respawn_retention(player: Player) -> void:
	player.health_component.take_damage(player.health_component.max_health)
	await process_frame
	_expect(player.is_dead(), "lethal damage did not enter death state")
	_expect(_equipment().equipped_weapon_id == WEAPON_ID, "death cleared equipped weapon")
	_expect(player.respawn_at(player.global_position), "direct W4 respawn failed")
	await process_frame
	_expect(not player.is_dead(), "Player remained dead after respawn")
	_assert_equipped_contract(player)


func _save_service() -> PlayerProgressSaveServiceState:
	return root.get_node("PlayerProgressSaveService") as PlayerProgressSaveServiceState


func _session() -> ChapterSessionState:
	return root.get_node("ChapterSession") as ChapterSessionState


func _inventory() -> PlayerWeaponInventory:
	return root.get_node("WeaponInventory") as PlayerWeaponInventory


func _equipment() -> PlayerEquipmentManager:
	return root.get_node("EquipmentManager") as PlayerEquipmentManager


func _flush_frames() -> void:
	for _frame: int in 8:
		await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish(phase: String) -> void:
	if _failures.is_empty():
		print("SOUL LOCK W4 %s | PASS unique/equip=16/32 death=retained save=retained" % phase.to_upper())
		quit(0)
		return
	for failure: String in _failures:
		push_error("SOUL LOCK W4 %s: %s" % [phase.to_upper(), failure])
	quit(1)
