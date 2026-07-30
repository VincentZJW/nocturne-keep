class_name Chapter03BossSanctumRoom
extends Chapter03Room

@onready var sanctum: Chapter03BossSanctum = $BossSanctum as Chapter03BossSanctum
@onready var post_boss_exit: Chapter03RoomExit = $PostBossExit as Chapter03RoomExit
@onready var boss: ThirteenthPontiffEdran = (
	$BossActors/ThirteenthPontiffEdran as ThirteenthPontiffEdran
)


func _ready() -> void:
	super._ready()
	post_boss_exit.set_deferred("monitoring", false)
	sanctum.death_environment_finished.connect(_on_death_environment_finished)
	sanctum.intro_environment_finished.connect(_on_intro_environment_finished)
	boss.defeated.connect(_on_boss_defeated)
	boss.phase_transition_started.connect(_on_phase_transition_started)
	boss.death_sequence_started.connect(_on_death_sequence_started)
	call_deferred("_activate_boss_if_intro_skipped")


func _on_intro_environment_finished() -> void:
	_activate_boss()


func _activate_boss_if_intro_skipped() -> void:
	if sanctum.is_intro_complete():
		_activate_boss()


func _activate_boss() -> void:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	boss.activate(player)


func _on_boss_defeated() -> void:
	sanctum.notify_boss_defeated()


func _on_phase_transition_started() -> void:
	sanctum.play_phase_transition_environment()


func _on_death_sequence_started() -> void:
	sanctum.play_death_dialogue()


func _on_death_environment_finished() -> void:
	post_boss_exit.set_deferred("monitoring", true)
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.set_story_flag(&"chapter_03_boss_environment_defeated")
