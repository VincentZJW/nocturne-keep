extends SceneTree

## Deterministic rendered evidence for the migrated Chapter I PackedScene and its
## Chapter II gate transition. It uses the same scenes/resources as configured F5.

const MAIN: PackedScene = preload(
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
)
const OUTPUT_ROOT: String = "res://docs/qa/chapter_01_reorganization"


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var config: DebugRunConfigState = root.get_node("DebugRunConfig") as DebugRunConfigState
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS
	config.debug_start_spawn_id = &"dark_forest_tutorial_spawn"
	var main: RavenmournOutskirtsLevel = MAIN.instantiate() as RavenmournOutskirtsLevel
	root.add_child(main)
	current_scene = main
	await _wait_frames(10)
	var player: Player = main.get_node("World/Player") as Player
	(main.get_node("Interface") as MainDebugHudController).set_debug_hud_visible(false)
	main.get_node("HUD/TutorialPrompt").visible = false
	_disable_enemy_ai(main)
	await _capture_at(player, Vector2(620, 612), OUTPUT_ROOT.path_join("chapter_01_forest.png"))
	await _capture_at(player, Vector2(3580, 612), OUTPUT_ROOT.path_join("chapter_01_outskirts.png"))
	await _capture_at(player, Vector2(5150, 612), OUTPUT_ROOT.path_join("chapter_01_castle_approach.png"))
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	player.global_position = Vector2(5900, 612)
	room._on_entry_body_entered(player)
	room.boss.set_physics_process(false)
	await _wait_frames(12)
	_save_viewport(OUTPUT_ROOT.path_join("chapter_01_boss.png"))
	var reward: BossRewardController = main.get_node("World/CastleEntranceArea/BossReward") as BossRewardController
	reward.debug_force_reward()
	reward.boss.visible = false
	await _wait_frames(8)
	_save_viewport(OUTPUT_ROOT.path_join("chapter_01_ravenfang_drop.png"))
	reward.weapon_pickup.collect()
	room.castle_gate_controller.open_gate()
	await _wait_frames(70)
	var transition: CastleEntranceTransition = main.get_node("CastleEntranceTransition") as CastleEntranceTransition
	transition.fade_duration = 0.2
	transition.begin_transition()
	await _wait_frames(30)
	if current_scene == null or current_scene.scene_file_path != ChapterRegistry.CHAPTER_02_SCENE_PATH:
		push_error("Chapter I gate did not load Chapter II")
		quit(1)
		return
	await _wait_frames(8)
	_save_viewport(OUTPUT_ROOT.path_join("chapter_01_enter_chapter_02.png"))
	print("CHAPTER_01_REORGANIZATION_QA: PASS (6 rendered checkpoints, Chapter II loaded)")
	quit(0)


func _capture_at(player: Player, position: Vector2, path: String) -> void:
	player.global_position = position
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	await _wait_frames(10)
	_save_viewport(path)


func _disable_enemy_ai(main: Node2D) -> void:
	for node: Node in main.get_node("World/Encounters").find_children("*", "", true, false):
		var enemy: EnemyCombatant = node as EnemyCombatant
		if enemy != null:
			enemy.set_ai_active(false)


func _wait_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _save_viewport(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Unable to save Chapter I reorganization QA image: %s" % path)
