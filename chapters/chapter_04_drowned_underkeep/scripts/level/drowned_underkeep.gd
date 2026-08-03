class_name DrownedUnderkeepRoute
extends Node2D

const DEFAULT_SPAWN_ID: StringName = &"CH4_START"

@onready var transition_controller: Node = $RoomTransitionController


func _ready() -> void:
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	var selected_spawn_id: StringName = DEFAULT_SPAWN_ID
	if session != null:
		selected_spawn_id = session.consume_pending_spawn(DEFAULT_SPAWN_ID)
		session.current_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
		session.set_story_flag(&"chapter_04_started")
	var start: Dictionary = _resolve_start(selected_spawn_id)
	transition_controller.call("initialize", start["room_id"] as StringName, start["spawn_id"] as StringName)


func _resolve_start(spawn_id: StringName) -> Dictionary:
	match spawn_id:
		&"CH4_START", &"CH4_AREA_00":
			return {"room_id": &"CH4_AREA_00", "spawn_id": &"EntryWest"}
		&"CH4_HUMANOID_COMBAT", &"CH4_AREA_01":
			return {"room_id": &"CH4_AREA_01", "spawn_id": &"EntryWest"}
		&"CH4_AREA_02", &"CH4_AREA_03", &"CH4_AREA_04":
			return {"room_id": spawn_id, "spawn_id": &"EntryWest"}
		&"CH4_CREATURE_COMBAT", &"CH4_AREA_05":
			return {"room_id": &"CH4_AREA_05", "spawn_id": &"EntryWest"}
		&"CH4_AREA_06", &"CH4_AREA_07":
			return {"room_id": spawn_id, "spawn_id": &"EntryWest"}
		&"CH4_ELITE_TRIAL", &"CH4_AREA_08":
			return {"room_id": &"CH4_AREA_08", "spawn_id": &"EntryWest"}
		&"CH4_AREA_09", &"CH4_AREA_10", &"CH4_AREA_11", &"CH4_AREA_12", &"CH4_AREA_13":
			return {"room_id": spawn_id, "spawn_id": &"EntryWest"}
		&"CH4_BOSS_PHASE_01", &"CH4_BOSS_PHASE_02", &"CH4_AREA_14":
			return {"room_id": &"CH4_AREA_14", "spawn_id": &"EntryWest"}
		&"CH4_AREA_15", &"CH4_AREA_16":
			return {"room_id": spawn_id, "spawn_id": &"EntryWest"}
	return {"room_id": &"CH4_AREA_00", "spawn_id": &"EntryWest"}
