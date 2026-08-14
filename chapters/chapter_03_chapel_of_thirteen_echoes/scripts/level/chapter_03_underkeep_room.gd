class_name Chapter03UnderkeepRoom
extends Chapter03Room


func _ready() -> void:
	super._ready()
	var descent: Chapter03UnderkeepDescent = get_node_or_null("UnderkeepDescent") as Chapter03UnderkeepDescent
	if descent != null:
		descent.chapter_four_transition_requested.connect(_on_chapter_four_transition_requested)


func _on_chapter_four_transition_requested(_player: Player) -> void:
	var transition_manager: SceneTransitionManagerState = get_node_or_null(
		"/root/SceneTransitionManager"
	) as SceneTransitionManagerState
	if transition_manager == null:
		push_error("Chapter III underkeep requires SceneTransitionManager")
		return
	transition_manager.transition_to_chapter(
		ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP,
		&"CH4_START",
		0.45,
		0.45
	)
