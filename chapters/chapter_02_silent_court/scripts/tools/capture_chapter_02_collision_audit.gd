extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT: String = "res://docs/qa/chapter_02_three_floor/13_visible_collision_layer_audit.png"


func _initialize() -> void:
	debug_collisions_hint = true
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		push_error("CH2_COLLISION_AUDIT: missing DebugRunConfig")
		quit(1)
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id = &"CH2_FLOOR_1_BANQUET"
	if change_scene_to_file(BOOTSTRAP) != OK:
		quit(1)
		return
	var level: SilentCourtLevel
	for _frame: int in range(240):
		await process_frame
		level = current_scene as SilentCourtLevel
		if level != null:
			break
	if level == null:
		push_error("CH2_COLLISION_AUDIT: Main SilentCourt missing")
		quit(1)
		return
	var player: Player = level.player
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(5200, 584)
	player.velocity = Vector2.ZERO
	level._configure_camera(0, 720)
	for _frame: int in range(24):
		await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.get_base_dir()))
	var error: Error = root.get_viewport().get_texture().get_image().save_png(OUTPUT)
	if error != OK:
		push_error("CH2_COLLISION_AUDIT: save failed %s" % error_string(error))
		quit(1)
		return
	var enemy: Node2D = level.get_node_or_null(
		"GameplayWorld/Enemies/EncounterE05/EncounterE05_01_HollowRetainer"
	) as Node2D
	print("CH2_COLLISION_AUDIT: PASS ground=%s enemy=%s authored_foot=%s live_origin=%s" % [
		"GameplayWorld/Geometry/Rooms/LastBanquetHall/Geometry/MainFloor/CollisionShape2D",
		enemy.get_path() if enemy != null else NodePath(),
		enemy.get_meta("authored_foot_position", Vector2.ZERO) if enemy != null else Vector2.ZERO,
		enemy.global_position if enemy != null else Vector2.ZERO,
	])
	quit(0)
