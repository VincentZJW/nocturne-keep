extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIR: String = "res://docs/qa/chapter_02_enemy_boss_art_rework/stage_1"
const ENTRIES: Array[Dictionary] = [
	{"role":"HollowRetainer", "slug":"hollow_retainer", "action":&"stab_active", "offset":Vector2(-90,0)},
	{"role":"CourtHalberdier", "slug":"court_halberdier", "action":&"long_thrust_active", "offset":Vector2(-120,0)},
	{"role":"MourningArmor", "slug":"mourning_armor", "action":&"overhead_active", "offset":Vector2(-110,0)},
	{"role":"BloodCandleAcolyte", "slug":"blood_candle_acolyte", "action":&"projectile_cast_active", "offset":Vector2(-100,0)},
	{"role":"HangingStalker", "slug":"hanging_stalker", "action":&"emerging_claw", "offset":Vector2(-100,130)},
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280,720))
	var config: DebugRunConfigState=root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config==null:
		push_error("CH2_STAGE1_MAIN_QA missing DebugRunConfig"); quit(1); return
	config.debug_chapter_start_enabled=true
	config.debug_start_chapter_id=ChapterRegistry.CHAPTER_02_SILENT_COURT
	config.debug_start_spawn_id=&"CH2_START"
	if change_scene_to_file(BOOTSTRAP)!=OK:
		push_error("CH2_STAGE1_MAIN_QA failed to load Bootstrap"); quit(1); return
	var level: Node=await _wait_for_level()
	if level==null:
		push_error("CH2_STAGE1_MAIN_QA SilentCourt did not load"); quit(1); return
	var player: Player=level.get_node_or_null("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player") as Player
	if player==null:
		push_error("CH2_STAGE1_MAIN_QA missing Player"); quit(1); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var captures: int=0
	for entry: Dictionary in ENTRIES:
		var enemy: Node2D=_find_enemy(level,String(entry["role"]))
		if enemy==null:
			push_error("CH2_STAGE1_MAIN_QA missing role %s" % entry["role"]); quit(1); return
		player.global_position=enemy.global_position+(entry["offset"] as Vector2)
		player.velocity=Vector2.ZERO
		player.player_camera.reset_smoothing()
		if enemy.has_method("set_ai_active"): enemy.call("set_ai_active",false)
		var sprite: AnimatedSprite2D=enemy.get_node_or_null("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
		if sprite==null:
			push_error("CH2_STAGE1_MAIN_QA missing sprite for %s" % entry["role"]); quit(1); return
		sprite.play(&"idle" if sprite.sprite_frames.has_animation(&"idle") else &"hang")
		for _frame: int in range(8): await process_frame
		if not _save("main_%s_identity.png" % entry["slug"]): quit(1); return
		captures+=1
		var action: StringName=entry["action"] as StringName
		sprite.play(action)
		sprite.frame=maxi(0,sprite.sprite_frames.get_frame_count(action)-1)
		await process_frame
		if not _save("main_%s_action.png" % entry["slug"]): quit(1); return
		captures+=1
	print("CH2 ENEMY ART STAGE1 MAIN QA | PASS captures=%d main=%s" % [captures,level.scene_file_path])
	config.reset_to_defaults()
	quit(0)


func _find_enemy(node: Node, role: String) -> Node2D:
	if node is Node2D and node.name.to_lower().contains(role.to_lower()): return node as Node2D
	for child: Node in node.get_children():
		var found: Node2D=_find_enemy(child,role)
		if found!=null: return found
	return null


func _save(filename: String) -> bool:
	var path: String="%s/%s" % [OUTPUT_DIR,filename]
	if root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path))!=OK:
		push_error("CH2_STAGE1_MAIN_QA failed to save %s" % path); return false
	return true


func _wait_for_level() -> Node:
	for _frame: int in range(240):
		await process_frame
		if current_scene!=null and current_scene.scene_file_path=="res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn": return current_scene
	return null
