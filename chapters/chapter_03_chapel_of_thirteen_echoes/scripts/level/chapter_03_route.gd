class_name Chapter03Route
extends Node2D

const DEFAULT_SPAWN_ID: StringName = &"chapter_03_start"
const FLAG_CHAPTER_03_STARTED: StringName = &"chapter_03_started"

@onready var transition_controller: Chapter03RoomTransitionController = $RoomTransitionController


func _ready() -> void:
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	var selected_spawn_id: StringName = DEFAULT_SPAWN_ID
	if session != null:
		selected_spawn_id = session.consume_pending_spawn(DEFAULT_SPAWN_ID)
		session.current_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
		session.set_story_flag(FLAG_CHAPTER_03_STARTED)
	var start: Dictionary = _resolve_start(selected_spawn_id)
	var start_room_id: StringName = start.room_id as StringName
	transition_controller.initialize(start_room_id, start.spawn_id as StringName)
	if start_room_id == &"CH3_BOSS":
		transition_controller.play_active_boss_intro.call_deferred()


func _resolve_start(spawn_id: StringName) -> Dictionary:
	match spawn_id:
		&"CH3_BELLCHAIN_TEST":
			return {"room_id": &"CH3_NAVE_ENTRY", "spawn_id": &"BellchainTest"}
		&"CH3_SCRIBE_TEST":
			return {"room_id": &"CH3_NAVE_ENTRY", "spawn_id": &"ScribeTest"}
		&"CH3_EXECUTIONER_TEST", &"CH3_CHOIR_TEST":
			return {"room_id": &"CH3_CHOIR_GALLERY", "spawn_id": &"EnemyTest"}
		&"CH3_BOSS_ANTE":
			return {"room_id": &"CH3_BOSS_ANTE", "spawn_id": &"EntryWest"}
		&"CH3_BOSS":
			return {"room_id": &"CH3_BOSS", "spawn_id": &"EntryWest"}
		&"CH3_POST_BOSS":
			return {"room_id": &"CH3_POST_BOSS", "spawn_id": &"EntryWest"}
		&"CH3_UNDERKEEP_DESCENT":
			return {"room_id": &"CH3_UNDERKEEP_DESCENT", "spawn_id": &"EntryWest"}
		&"CH3_NAVE_ENTRY":
			return {"room_id": &"CH3_NAVE_ENTRY", "spawn_id": &"EntryWest"}
		&"CH3_CHOIR_GALLERY":
			return {"room_id": &"CH3_CHOIR_GALLERY", "spawn_id": &"EntryWest"}
		&"CH3_BOSS_CHECKPOINT":
			return {"room_id": &"CH3_BOSS_CHECKPOINT", "spawn_id": &"EntryWest"}
	return {"room_id": &"CH3_CHAPEL_VESTIBULE", "spawn_id": &"EntryWest"}
