class_name ChapterSessionState
extends Node

## Runtime-only Chapter I flow flags shared across scene transitions.
## This service owns no combat, movement, AI, or save-game behavior.

signal objective_changed(step: int, title_zh: String, title_en: String)

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
var current_objective: ObjectiveStep = ObjectiveStep.LEAVE_CATACOMB


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


func reset_revival_state() -> void:
	opening_completed = false
	revival_completed = false
	daggers_recovered = false
	catacomb_exited = false
	boss_reward_spawned = false
	boss_reward_collected = false
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
