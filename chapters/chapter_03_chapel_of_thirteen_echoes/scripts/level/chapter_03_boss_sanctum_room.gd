class_name Chapter03BossSanctumRoom
extends Chapter03Room

@onready var sanctum: Chapter03BossSanctum = $BossSanctum as Chapter03BossSanctum
@onready var post_boss_exit: Chapter03RoomExit = $PostBossExit as Chapter03RoomExit


func _ready() -> void:
	super._ready()
	post_boss_exit.set_deferred("monitoring", false)
	sanctum.death_environment_finished.connect(_on_death_environment_finished)


func _on_death_environment_finished() -> void:
	post_boss_exit.set_deferred("monitoring", true)
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.set_story_flag(&"chapter_03_boss_environment_defeated")
