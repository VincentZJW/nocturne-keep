class_name Chapter04MemoryExit
extends Area2D

@export_node_path("Label") var prompt_path: NodePath = NodePath("Prompt")
@export var target_chapter_id: StringName = &"CHAPTER_05_NIGHT_REPEATED"
@export var target_spawn_id: StringName = &"CH5_START"

@onready var prompt: Label = get_node(prompt_path) as Label

var _candidate: Player
var _transitioning: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _candidate == null or _transitioning:
		return
	if event.is_action_pressed(&"interact"):
		get_viewport().set_input_as_handled()
		_transition_to_chapter_five()


func _transition_to_chapter_five() -> void:
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null and not session.has_story_flag(&"ch4_memory_passage_unlocked"):
		prompt.text = "THE MEMORY PATH IS SEALED / 记忆通路尚未开启"
		return
	_transitioning = true
	_candidate.set_input_profile(Player.InputProfile.LOCKED)
	_candidate.velocity = Vector2.ZERO
	if session != null:
		session.mark_chapter_completed(ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP)
		session.set_story_flag(&"ch4_memory_passage_entered")
	var transition: SceneTransitionManagerState = get_node_or_null("/root/SceneTransitionManager") as SceneTransitionManagerState
	if transition == null or not transition.transition_to_chapter(target_chapter_id, target_spawn_id, 0.7, 0.8):
		_transitioning = false
		_candidate.set_input_profile(Player.InputProfile.FULL)


func transition_for_qa() -> void:
	if _candidate != null:
		_transition_to_chapter_five()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_candidate = body as Player
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == _candidate:
		_candidate = null
		prompt.visible = false
