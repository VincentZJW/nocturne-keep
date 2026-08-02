extends SceneTree

## W3 contract test. Run once with W3_PROGRESS_PHASE=write and once with
## W3_PROGRESS_PHASE=load to prove recovery across separate Godot processes.

const WEAPON_ID: StringName = &"thirteenfold_absolution_blades"
const WEAPON_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/"
	+ "thirteenfold_absolution_blades.tres"
)
const CRIMSON_PATH: String = (
	"res://chapters/chapter_02_silent_court/resources/weapons/"
	+ "crimson_masque_stilettos.tres"
)
const FRAMES_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/"
	+ "thirteenfold_absolution_player_sprite_frames.tres"
)
const TEST_SAVE_PATH: String = "user://thirteenfold_absolution_w3_test.json"
const INVALID_SAVE_PATH: String = "user://thirteenfold_absolution_w3_invalid.json"
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var phase: String = OS.get_environment("W3_PROGRESS_PHASE").strip_edges().to_lower()
	if phase == "write":
		await _run_write_phase()
	elif phase == "load":
		await _run_load_phase()
	else:
		_failures.append("Set W3_PROGRESS_PHASE to write or load")
	_finish(phase)


func _run_write_phase() -> void:
	var service: PlayerProgressSaveServiceState = _save_service()
	var session: ChapterSessionState = _session()
	var equipment: PlayerEquipmentManager = _equipment()
	var inventory: PlayerWeaponInventory = _inventory()
	_expect(service.set_save_path_for_testing(TEST_SAVE_PATH), "Could not select isolated test save")
	_expect(service.clear_progress() == OK, "Could not clear stale W3 test save")
	session.begin_formal_new_game()
	_expect(service.enable_formal_persistence(false) == OK, "Could not enable formal persistence")
	_validate_weapon_resource()
	_expect(equipment.acquire_and_equip(WEAPON_ID), "Could not acquire/equip Thirteenfold Absolution")
	_expect(inventory.owns_weapon(WEAPON_ID), "Inventory does not own Thirteenfold Absolution")
	_expect(not inventory.add_weapon(WEAPON_ID), "Unique weapon accepted a duplicate")
	_expect(equipment.get_normal_attack_damage() == 14, "Normal damage is not 14")
	_expect(equipment.get_dash_attack_damage() == 28, "Dash damage is not 28")
	session.mark_chapter_completed(&"CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES")
	session.set_story_flag(&"chapter_03_boss_reward_collected")
	session.set_story_flag(&"chapter_03_underkeep_unlocked")
	session.set_transition_target(
		&"CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES",
		&"CH3_UNDERKEEP_DESCENT"
	)
	_expect(service.save_progress() == OK, "Explicit W3 save failed")
	_expect(FileAccess.file_exists(TEST_SAVE_PATH), "W3 save file was not created")
	var saved_json: JSON = JSON.new()
	_expect(
		saved_json.parse(FileAccess.get_file_as_string(TEST_SAVE_PATH)) == OK,
		"W3 save is not valid JSON"
	)
	_expect(equipment.equipped_weapon_id == WEAPON_ID, "Write phase equipped ID changed")


func _run_load_phase() -> void:
	var service: PlayerProgressSaveServiceState = _save_service()
	var session: ChapterSessionState = _session()
	var equipment: PlayerEquipmentManager = _equipment()
	var inventory: PlayerWeaponInventory = _inventory()
	_expect(service.set_save_path_for_testing(TEST_SAVE_PATH), "Could not select isolated test save")
	_expect(FileAccess.file_exists(TEST_SAVE_PATH), "Write-phase save is missing")
	session.begin_formal_new_game()
	_expect(not inventory.owns_weapon(WEAPON_ID), "Fresh runtime retained W3 ownership before load")
	_expect(equipment.equipped_weapon_id == &"veilbound_daggers", "Fresh runtime did not reset equipment")
	_expect(service.load_progress() == OK, "Fresh process could not load W3 save")
	_expect(inventory.owns_weapon(WEAPON_ID), "Loaded inventory lacks Thirteenfold Absolution")
	_expect(equipment.equipped_weapon_id == WEAPON_ID, "Loaded equipment ID mismatch")
	_expect(equipment.get_normal_attack_damage() == 14, "Loaded normal damage is not 14")
	_expect(equipment.get_dash_attack_damage() == 28, "Loaded Dash damage is not 28")
	_expect(session.has_story_flag(&"chapter_03_boss_reward_collected"), "Reward flag was not restored")
	_expect(session.has_story_flag(&"chapter_03_underkeep_unlocked"), "Underkeep flag was not restored")
	_expect(
		session.is_chapter_completed(&"CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES"),
		"Chapter completion was not restored"
	)
	_expect(session.current_chapter_id == &"CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES", "Recovery chapter mismatch")
	_expect(session.pending_spawn_id == &"CH3_UNDERKEEP_DESCENT", "Recovery spawn mismatch")
	await _validate_player_death_respawn_retention()
	_validate_invalid_snapshot_rejected()
	await _validate_debug_isolation()
	await _validate_formal_new_game_cleanup()


func _validate_weapon_resource() -> void:
	var weapon: WeaponData = load(WEAPON_PATH) as WeaponData
	var crimson: WeaponData = load(CRIMSON_PATH) as WeaponData
	_expect(weapon != null and weapon.is_valid_weapon(), "Thirteenfold WeaponData is invalid")
	if weapon == null:
		return
	_expect(weapon.resource_path == WEAPON_PATH, "Thirteenfold Resource path mismatch")
	_expect(crimson != null and crimson.resource_path != weapon.resource_path, "WeaponData is not independent")
	_expect(weapon.weapon_id == WEAPON_ID, "Weapon ID mismatch")
	_expect(weapon.display_name_en == "Thirteenfold Absolution", "English name mismatch")
	_expect(weapon.display_name_zh == "十三重赦刃", "Chinese name mismatch")
	_expect(weapon.weapon_type == &"dual_daggers" and weapon.tier == 3, "Type/tier mismatch")
	_expect(weapon.normal_attack_damage == 14 and weapon.dash_attack_damage == 28, "Damage mismatch")
	_expect(weapon.player_visual_id == &"thirteenfold_absolution", "Player visual ID mismatch")
	_expect(weapon.icon != null and weapon.hud_icon != null, "Inventory/HUD icons missing")
	_expect(weapon.is_unique and weapon.is_permanent, "Unique/permanent flags missing")
	_expect(weapon.is_story_reward and not weapon.can_sell, "Story/sell flags mismatch")
	_expect(weapon.auto_equip_on_pickup and not weapon.allow_duplicates, "Acquisition flags mismatch")
	_expect(weapon.world_pickup_visual == null, "W3 must not create the W4 pickup scene")


func _validate_player_death_respawn_retention() -> void:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	await process_frame
	await process_frame
	var visual: PlayerWeaponVisual = player.get_node("VisualRoot/WeaponVisual") as PlayerWeaponVisual
	_expect(visual.get_visual_id() == &"thirteenfold_absolution", "Loaded Player visual ID mismatch")
	_expect(visual.get_active_sprite_frames_path() == FRAMES_PATH, "Loaded Player SpriteFrames mismatch")
	player.health_component.take_damage(player.health_component.max_health)
	await process_frame
	_expect(player.is_dead(), "Lethal damage did not enter death state")
	_expect(_equipment().equipped_weapon_id == WEAPON_ID, "Death cleared equipped weapon")
	_expect(player.respawn_at(Vector2(32.0, 64.0)), "Player respawn failed")
	await process_frame
	_expect(not player.is_dead(), "Player remained dead after respawn")
	_expect(_inventory().owns_weapon(WEAPON_ID), "Respawn cleared weapon ownership")
	_expect(_equipment().equipped_weapon_id == WEAPON_ID, "Respawn cleared equipped weapon")
	_expect(visual.get_visual_id() == &"thirteenfold_absolution", "Respawn changed weapon visual")
	player.queue_free()
	await process_frame


func _validate_debug_isolation() -> void:
	var service: PlayerProgressSaveServiceState = _save_service()
	_expect(service.save_progress() == OK, "Could not refresh test save before Debug isolation")
	var hash_before: String = FileAccess.get_sha256(ProjectSettings.globalize_path(TEST_SAVE_PATH))
	service.begin_debug_session()
	_session().begin_debug_run()
	_session().set_story_flag(&"debug_only_flag")
	_equipment().reset_for_new_run()
	await process_frame
	await process_frame
	var hash_after: String = FileAccess.get_sha256(ProjectSettings.globalize_path(TEST_SAVE_PATH))
	_expect(hash_before == hash_after, "Debug session modified the formal progress save")
	_expect(not service.is_persistence_enabled(), "Debug session left persistence enabled")


func _validate_invalid_snapshot_rejected() -> void:
	var service: PlayerProgressSaveServiceState = _save_service()
	_expect(service.set_save_path_for_testing(INVALID_SAVE_PATH), "Could not select invalid test save")
	var invalid_snapshot: Dictionary = {
		"version": PlayerProgressSaveServiceState.SAVE_VERSION,
		"inventory": {"owned_weapon_ids": ["veilbound_daggers", "unknown_weapon"]},
		"equipment": {"equipped_weapon_id": "unknown_weapon"},
		"chapter_session": _session().export_progress_snapshot(),
	}
	var file: FileAccess = FileAccess.open(INVALID_SAVE_PATH, FileAccess.WRITE)
	_expect(file != null, "Could not create invalid transaction test file")
	if file != null:
		file.store_string(JSON.stringify(invalid_snapshot))
		file.close()
	_expect(service.load_progress() == ERR_INVALID_DATA, "Unknown weapon save was not rejected")
	_expect(_equipment().equipped_weapon_id == WEAPON_ID, "Rejected save partially changed equipment")
	_expect(_inventory().owns_weapon(WEAPON_ID), "Rejected save partially changed inventory")
	_expect(service.clear_progress() == OK, "Could not remove invalid transaction test file")
	_expect(service.set_save_path_for_testing(TEST_SAVE_PATH), "Could not restore W3 test save path")
	_expect(service.enable_formal_persistence(false) == OK, "Could not resume W3 test persistence")


func _validate_formal_new_game_cleanup() -> void:
	var service: PlayerProgressSaveServiceState = _save_service()
	_expect(service.begin_new_game() == OK, "Formal New Game could not clear save")
	_expect(not FileAccess.file_exists(TEST_SAVE_PATH), "Formal New Game retained the previous save")
	_session().begin_formal_new_game()
	_expect(_inventory().get_owned_weapon_ids() == [&"veilbound_daggers"], "New Game inventory is not clean")
	_expect(_equipment().equipped_weapon_id == &"veilbound_daggers", "New Game equipment is not Veilbound")
	_expect(service.enable_formal_persistence() == OK, "New Game could not start formal persistence")
	_expect(FileAccess.file_exists(TEST_SAVE_PATH), "New Game did not create a clean baseline save")
	_expect(service.clear_progress() == OK, "Could not clean W3 test save after validation")


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
		print("THIRTEENFOLD_ABSOLUTION_W3 | PASS phase=%s damage=14/28 disk=true" % phase)
		quit(0)
		return
	for failure: String in _failures:
		push_error("THIRTEENFOLD_ABSOLUTION_W3: %s" % failure)
	print("THIRTEENFOLD_ABSOLUTION_W3 | FAIL phase=%s count=%d" % [phase, _failures.size()])
	quit(1)
