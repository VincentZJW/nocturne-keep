class_name Chapter04RewardController
extends Node2D

signal reward_collected(reward_id: StringName)

const REWARD_ID: StringName = &"CH4_UNNAMED_CHAIN_RELIC_PLACEHOLDER"

@export_node_path("Area2D") var interaction_area_path: NodePath = NodePath("InteractionArea")
@export_node_path("Label") var prompt_path: NodePath = NodePath("InteractionArea/Prompt")
@export_node_path("CanvasItem") var reward_visual_path: NodePath = NodePath("RewardVisual")
@export_node_path("Chapter04RoomExit") var memory_exit_path: NodePath = NodePath("../Transitions/ExitEast")

@onready var interaction_area: Area2D = get_node(interaction_area_path) as Area2D
@onready var prompt: Label = get_node(prompt_path) as Label
@onready var reward_visual: CanvasItem = get_node(reward_visual_path) as CanvasItem
@onready var memory_exit: Chapter04RoomExit = get_node(memory_exit_path) as Chapter04RoomExit

var _candidate: Player
var _collected: bool = false


func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	set_process_unhandled_input(true)
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	_collected = session != null and session.has_story_flag(&"ch4_reward_collected")
	var unlocked: bool = session == null or session.has_story_flag(&"ch4_reward_unlocked") or _collected
	reward_visual.visible = unlocked and not _collected
	interaction_area.monitoring = unlocked and not _collected
	memory_exit.requires_interaction = true
	memory_exit.set_locked(not _collected)
	prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _candidate == null or _collected:
		return
	if event.is_action_pressed(&"interact"):
		get_viewport().set_input_as_handled()
		_collect_reward()


func _collect_reward() -> void:
	if _collected:
		return
	_collected = true
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.set_story_flag(&"ch4_reward_unlocked")
		session.set_story_flag(&"ch4_reward_collected")
		session.set_story_flag(&"ch4_memory_passage_unlocked")
	reward_visual.visible = false
	interaction_area.set_deferred("monitoring", false)
	prompt.visible = false
	memory_exit.set_locked(false)
	reward_collected.emit(REWARD_ID)


func collect_for_qa() -> void:
	_collect_reward()


func is_collected() -> bool:
	return _collected


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not _collected:
		_candidate = body as Player
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == _candidate:
		_candidate = null
		prompt.visible = false
