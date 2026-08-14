extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const OUTPUT: String = "res://docs/qa/chapter_04_soul_gaoler_balance"

var _failures: PackedStringArray = []
var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var debug: DebugRunConfigState = root.get_node("DebugRunConfig") as DebugRunConfigState
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_BOSS_PHASE_01"
	debug.debug_skip_chapter_intro = true
	var equipment: PlayerEquipmentManager = root.get_node("EquipmentManager") as PlayerEquipmentManager
	_check(equipment.acquire_and_equip(&"thirteenfold_absolution_blades"), "14/28 QA weapon equips")
	_check(equipment.get_normal_attack_damage() == 14, "normal QA damage is 14")
	_check(equipment.get_dash_attack_damage() == 28, "Dash QA damage is 28")
	_check(ProjectSettings.get_setting("application/run/main_scene") == BOOTSTRAP, "F5 remains MainBootstrap")
	if change_scene_to_file(BOOTSTRAP) != OK:
		return _finish()
	var level: Node = await _wait_for_level()
	if level == null:
		_check(false, "MainBootstrap did not load Chapter IV")
		return _finish()
	var controller: Chapter04RoomTransitionController = level.get_node("RoomTransitionController") as Chapter04RoomTransitionController
	var player: Player = level.get_node("ChapterRuntime/Player") as Player
	var room: Node = controller.active_room
	var boss: SoulGaolerOrmund = room.get_node_or_null("Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
	var flow: Chapter04BossRoomController = room.get_node_or_null("BossRoomController") as Chapter04BossRoomController
	_check(controller.active_room_id == &"CH4_AREA_14", "CH4_BOSS starts in the formal arena")
	_check(boss != null and flow != null, "formal Main Boss and controller resolve")
	if boss == null or flow == null:
		return _finish()
	flow.skip_intro_for_qa()
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(1240.0, 592.0)
	boss.global_position = Vector2(1450.0, 590.0)
	boss.set_target(player)
	boss.set_facing_direction(-1.0)
	await _settle(10)
	_save("01_main_phase_01_scale_and_spacing.png")

	boss._start_action(&"chain_anchor_slam")
	await _settle(4)
	_save("02_main_anchor_slam_direction_lock.png")
	boss._begin_active()
	await _settle(3)
	_save("03_main_anchor_slam_active.png")
	boss._begin_recovery()
	await _settle(3)
	_save("04_main_anchor_slam_punish_window.png")

	boss._on_attack_cancelled()
	boss._reset_combo_sequence()
	boss.combo_count = boss.combo_budget
	boss._start_player_turn()
	player.global_position = boss.global_position + Vector2(86.0, 2.0)
	await _settle(4)
	_save("05_main_player_turn_back_position.png")

	boss.health_component.set_current_health(roundi(boss.health_component.max_health * 0.50))
	boss.complete_debug_phase_transition()
	await _settle(8)
	_save("06_main_phase_02_scale.png")
	boss._start_action(&"flooded_judgment")
	boss._begin_active()
	await _settle(3)
	_save("07_main_flooded_judgment_active.png")
	boss._begin_recovery()
	await _settle(3)
	_save("08_main_flooded_judgment_punish_window.png")

	debug.reset_to_defaults()
	_finish()


func _wait_for_level() -> Node:
	for _frame: int in 600:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _settle(frames: int) -> void:
	for _frame: int in frames:
		await process_frame
	await create_timer(0.05).timeout
	await RenderingServer.frame_post_draw


func _save(file_name: String) -> void:
	var image: Image = root.get_viewport().get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path("%s/%s" % [OUTPUT, file_name]))
	_check(error == OK, "save %s" % file_name)
	if error == OK:
		_captures += 1


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("SOUL GAOLER BALANCE MAIN QA | PASS captures=%d weapon=14/28" % _captures)
		quit(0)
		return
	for failure: String in _failures:
		push_error("SOUL GAOLER BALANCE MAIN QA: %s" % failure)
	quit(1)
