class_name Chapter03PostBossRoom
extends Chapter03Room

@onready var reliquary: Chapter03PostBossReliquary = (
	$PostBossReliquary as Chapter03PostBossReliquary
)
@onready var underkeep_exit: Chapter03RoomExit = $UnderkeepExit as Chapter03RoomExit
@onready var acquisition_panel: ThirteenfoldAbsolutionAcquisitionPanel = (
	$RewardUI/ThirteenfoldAbsolutionAcquisitionPanel as ThirteenfoldAbsolutionAcquisitionPanel
)


func _ready() -> void:
	super._ready()
	underkeep_exit.set_deferred("monitoring", false)
	reliquary.descent_unlocked.connect(_on_descent_unlocked)
	reliquary.reward_collected.connect(_on_reward_collected)
	reliquary.reveal_after_boss()
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null and session.has_story_flag(
		Chapter03PostBossReliquary.FLAG_UNDERKEEP_UNLOCKED
	):
		reliquary.notify_reward_collected()


func _on_descent_unlocked() -> void:
	underkeep_exit.set_deferred("monitoring", true)


func _on_reward_collected(weapon_id: StringName) -> void:
	if weapon_id != Chapter03PostBossReliquary.REWARD_WEAPON_ID:
		return
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.mark_chapter_completed(ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES)
	var equipment: PlayerEquipmentManager = get_node_or_null(
		"/root/EquipmentManager"
	) as PlayerEquipmentManager
	if equipment != null:
		acquisition_panel.present(equipment.get_weapon(weapon_id))
