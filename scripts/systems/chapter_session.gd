class_name ChapterSessionState
extends Node

## Runtime-only Chapter I flow flags shared across scene transitions.
## This service owns no combat, movement, AI, or save-game behavior.

signal objective_changed(step: int, title_zh: String, title_en: String)
signal story_flag_changed(flag_id: StringName, enabled: bool)
signal transition_target_changed(chapter_id: StringName, spawn_id: StringName)
signal progress_state_changed

enum ObjectiveStep {
	LEAVE_CATACOMB,
	CROSS_DARK_FOREST,
	REACH_RAVENMOURN_CASTLE,
	DEFEAT_GATE_KNIGHT,
	ENTER_CASTLE,
}

var opening_completed: bool = false
var revival_completed: bool = false
var daggers_recovered: bool = false
var catacomb_exited: bool = false
var boss_reward_spawned: bool = false
var boss_reward_collected: bool = false
var is_debug_run: bool = false
var current_objective: ObjectiveStep = ObjectiveStep.LEAVE_CATACOMB
var current_chapter_id: StringName = &""
var pending_spawn_id: StringName = &""
var completed_chapters: Dictionary[StringName, bool] = {}
var story_flags: Dictionary[StringName, bool] = {}


func begin_formal_new_game() -> void:
	is_debug_run = false
	reset_revival_state()


func begin_debug_run() -> void:
	is_debug_run = true
	reset_revival_state()


func mark_opening_completed() -> void:
	opening_completed = true


func mark_revival_completed() -> void:
	revival_completed = true
	set_objective(ObjectiveStep.LEAVE_CATACOMB)


func mark_daggers_recovered() -> void:
	daggers_recovered = true


func mark_catacomb_exited() -> void:
	catacomb_exited = true
	set_objective(ObjectiveStep.CROSS_DARK_FOREST)


func set_objective(step: ObjectiveStep) -> void:
	current_objective = step
	var labels: PackedStringArray = _get_objective_labels(step)
	objective_changed.emit(step, labels[0], labels[1])


func apply_start_profile(profile: ChapterStartProfile, spawn_override: StringName = &"") -> void:
	if profile == null:
		return
	current_chapter_id = profile.chapter_id
	pending_spawn_id = (
		spawn_override if not spawn_override.is_empty() else profile.default_spawn_id
	)
	for chapter_id: StringName in profile.previous_chapters_completed:
		completed_chapters[chapter_id] = true
	for flag_id: StringName in profile.chapter_story_flags:
		set_story_flag(flag_id, profile.chapter_story_flags[flag_id])
	var inventory: PlayerWeaponInventory = get_node_or_null(
		"/root/WeaponInventory"
	) as PlayerWeaponInventory
	var equipment: PlayerEquipmentManager = get_node_or_null(
		"/root/EquipmentManager"
	) as PlayerEquipmentManager
	if inventory != null:
		for weapon_id: StringName in profile.required_weapons:
			inventory.add_weapon(weapon_id)
	if equipment != null and not profile.equipped_weapon.is_empty():
		equipment.equip_weapon(profile.equipped_weapon)
	transition_target_changed.emit(current_chapter_id, pending_spawn_id)


func set_story_flag(flag_id: StringName, enabled: bool = true) -> void:
	if flag_id.is_empty():
		return
	if story_flags.get(flag_id, false) == enabled:
		return
	story_flags[flag_id] = enabled
	story_flag_changed.emit(flag_id, enabled)
	progress_state_changed.emit()


func has_story_flag(flag_id: StringName) -> bool:
	return story_flags.get(flag_id, false)


func mark_chapter_completed(chapter_id: StringName) -> void:
	if not chapter_id.is_empty():
		completed_chapters[chapter_id] = true
		progress_state_changed.emit()


func is_chapter_completed(chapter_id: StringName) -> bool:
	return completed_chapters.get(chapter_id, false)


func set_transition_target(chapter_id: StringName, spawn_id: StringName) -> void:
	current_chapter_id = chapter_id
	pending_spawn_id = spawn_id
	transition_target_changed.emit(chapter_id, spawn_id)
	progress_state_changed.emit()


func consume_pending_spawn(default_spawn_id: StringName) -> StringName:
	var result: StringName = pending_spawn_id if not pending_spawn_id.is_empty() else default_spawn_id
	pending_spawn_id = &""
	return result


func export_progress_snapshot() -> Dictionary:
	var completed_ids: Array[StringName] = []
	for chapter_id: StringName in completed_chapters:
		if completed_chapters[chapter_id]:
			completed_ids.append(chapter_id)
	completed_ids.sort()
	var enabled_flags: Dictionary[StringName, bool] = {}
	var serialized_completed_ids: Array[String] = []
	for chapter_id: StringName in completed_ids:
		serialized_completed_ids.append(String(chapter_id))
	for flag_id: StringName in story_flags:
		enabled_flags[flag_id] = story_flags[flag_id]
	return {
		"opening_completed": opening_completed,
		"revival_completed": revival_completed,
		"daggers_recovered": daggers_recovered,
		"catacomb_exited": catacomb_exited,
		"boss_reward_spawned": boss_reward_spawned,
		"boss_reward_collected": boss_reward_collected,
		"current_objective": int(current_objective),
		"current_chapter_id": String(current_chapter_id),
		"pending_spawn_id": String(pending_spawn_id),
		"completed_chapters": serialized_completed_ids,
		"story_flags": enabled_flags,
	}


func import_progress_snapshot(snapshot: Dictionary) -> bool:
	if not can_import_progress_snapshot(snapshot):
		return false
	var objective_value: int = int(snapshot.get("current_objective", ObjectiveStep.LEAVE_CATACOMB))
	var completed_value: Variant = snapshot.get("completed_chapters", [])
	var flags_value: Variant = snapshot.get("story_flags", {})
	var restored_chapters: Dictionary[StringName, bool] = {}
	for raw_chapter_id: Variant in completed_value:
		var chapter_id: StringName = StringName(String(raw_chapter_id))
		restored_chapters[chapter_id] = true
	var restored_flags: Dictionary[StringName, bool] = {}
	for raw_flag_id: Variant in flags_value:
		var flag_id: StringName = StringName(String(raw_flag_id))
		restored_flags[flag_id] = bool(flags_value[raw_flag_id])
	opening_completed = bool(snapshot.get("opening_completed", false))
	revival_completed = bool(snapshot.get("revival_completed", false))
	daggers_recovered = bool(snapshot.get("daggers_recovered", false))
	catacomb_exited = bool(snapshot.get("catacomb_exited", false))
	boss_reward_spawned = bool(snapshot.get("boss_reward_spawned", false))
	boss_reward_collected = bool(snapshot.get("boss_reward_collected", false))
	current_objective = objective_value
	current_chapter_id = StringName(String(snapshot.get("current_chapter_id", "")))
	pending_spawn_id = StringName(String(snapshot.get("pending_spawn_id", "")))
	completed_chapters = restored_chapters
	story_flags = restored_flags
	for flag_id: StringName in story_flags:
		story_flag_changed.emit(flag_id, story_flags[flag_id])
	transition_target_changed.emit(current_chapter_id, pending_spawn_id)
	progress_state_changed.emit()
	return true


func can_import_progress_snapshot(snapshot: Dictionary) -> bool:
	var objective_value: int = int(snapshot.get("current_objective", ObjectiveStep.LEAVE_CATACOMB))
	if objective_value < ObjectiveStep.LEAVE_CATACOMB or objective_value > ObjectiveStep.ENTER_CASTLE:
		return false
	var completed_value: Variant = snapshot.get("completed_chapters", [])
	var flags_value: Variant = snapshot.get("story_flags", {})
	if not completed_value is Array or not flags_value is Dictionary:
		return false
	for raw_chapter_id: Variant in completed_value:
		if StringName(String(raw_chapter_id)).is_empty():
			return false
	for raw_flag_id: Variant in flags_value:
		if StringName(String(raw_flag_id)).is_empty():
			return false
	return true


func reset_revival_state() -> void:
	opening_completed = false
	revival_completed = false
	daggers_recovered = false
	catacomb_exited = false
	boss_reward_spawned = false
	boss_reward_collected = false
	current_chapter_id = &""
	pending_spawn_id = &""
	completed_chapters.clear()
	story_flags.clear()
	current_objective = ObjectiveStep.LEAVE_CATACOMB
	var wallet: CurrencyWallet = get_node_or_null("/root/CurrencyManager") as CurrencyWallet
	var equipment: PlayerEquipmentManager = get_node_or_null(
		"/root/EquipmentManager"
	) as PlayerEquipmentManager
	if wallet != null:
		wallet.reset_for_new_run()
	if equipment != null:
		equipment.reset_for_new_run()


func replay_revival_scene() -> Error:
	revival_completed = false
	daggers_recovered = false
	catacomb_exited = false
	current_objective = ObjectiveStep.LEAVE_CATACOMB
	return get_tree().change_scene_to_file("res://scenes/levels/veilbound_catacomb.tscn")


func _get_objective_labels(step: ObjectiveStep) -> PackedStringArray:
	match step:
		ObjectiveStep.LEAVE_CATACOMB:
			return PackedStringArray(["离开暮帷墓窟", "Leave the Veilbound Catacomb"])
		ObjectiveStep.CROSS_DARK_FOREST:
			return PackedStringArray(["穿过暗黑森林", "Cross the Dark Forest"])
		ObjectiveStep.REACH_RAVENMOURN_CASTLE:
			return PackedStringArray(["抵达鸦泣城堡", "Reach Ravenmourn Castle"])
		ObjectiveStep.DEFEAT_GATE_KNIGHT:
			return PackedStringArray(["击败堕落守门骑士", "Defeat the Fallen Gate Knight"])
		ObjectiveStep.ENTER_CASTLE:
			return PackedStringArray(["进入城堡", "Enter the Castle"])
	return PackedStringArray(["", ""])
