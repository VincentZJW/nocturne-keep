class_name Chapter03PostBossRoom
extends Chapter03Room

@onready var reliquary: Chapter03PostBossReliquary = (
	$PostBossReliquary as Chapter03PostBossReliquary
)
@onready var underkeep_exit: Chapter03RoomExit = $UnderkeepExit as Chapter03RoomExit


func _ready() -> void:
	super._ready()
	underkeep_exit.set_deferred("monitoring", false)
	reliquary.descent_unlocked.connect(_on_descent_unlocked)
	reliquary.reward_collection_requested.connect(_on_reward_collection_requested)
	reliquary.reveal_after_boss()
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.boss_reward_spawned = true
		if session.has_story_flag(Chapter03PostBossReliquary.FLAG_REWARD_COLLECTED):
			reliquary.notify_reward_collected()


func _on_descent_unlocked() -> void:
	underkeep_exit.set_deferred("monitoring", true)


func _on_reward_collection_requested(_player: Player) -> void:
	# B6 deliberately records a unique story reliquary token only. Chapter III has
	# no approved WeaponData reward, so no combat values or inventory weapon are invented.
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		if session.has_story_flag(Chapter03PostBossReliquary.FLAG_REWARD_COLLECTED):
			return
		session.boss_reward_collected = true
		session.mark_chapter_completed(ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES)
	reliquary.notify_reward_collected()
