extends SceneTree

const BOOTSTRAP := "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL := "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const OUTPUT := "res://docs/qa/chapter_04_characters/c7"
var captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280,720))
	var debug:=root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug==null: _fail("DebugRunConfig missing"); return
	debug.debug_chapter_start_enabled=true
	debug.debug_start_chapter_id=ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id=&"CH4_HUMANOID_COMBAT"
	debug.debug_skip_chapter_intro=true
	if change_scene_to_file(BOOTSTRAP)!=OK: _fail("MainBootstrap launch failed"); return
	var level:Node=await _wait_level()
	if level==null: _fail("Main did not route to Chapter IV"); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var player:=level.get_node("ChapterRuntime/Player") as Player
	player.hurtbox.set_invulnerable(true)
	await _capture_encounter(level,player,"CharacterTrial/GaolerIntake",Vector2(1900,584),"01_humanoid_gaoler_main.png")
	await _capture_encounter(level,player,"CharacterTrial/PenitentFloodway",Vector2(4450,584),"02_shield_and_mirefin_main.png")
	await _capture_encounter(level,player,"CharacterTrial/ConvictCistern",Vector2(5950,584),"03_convict_and_bog_toad_main.png")
	await _capture_encounter(level,player,"CharacterTrial/ExecutionBlock",Vector2(7100,584),"04_executioner_elite_main.png")
	var boss_group:=level.get_node("CharacterTrial/OrmundBossEncounter") as EncounterGroup
	var boss:=level.get_node("CharacterTrial/OrmundBossEncounter/Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
	player.global_position=Vector2(8440,584); player.velocity=Vector2.ZERO; player.player_camera.reset_smoothing(); boss_group.activate(player); boss.set_target(player)
	await _settle(); _save("05_ormund_phase_01_main.png")
	boss.health_component.set_current_health(308)
	await create_timer(1.35).timeout
	await _settle(); _save("06_ormund_phase_02_main.png")
	debug.reset_to_defaults()
	print("CH4 CHARACTER MAIN QA | PASS captures=%d main=%s" % [captures,level.scene_file_path])
	call_deferred("_teardown_successfully")


func _teardown_successfully() -> void:
	# Release the complete Main/F5 tree before terminating the QA runner so
	# renderer shutdown warnings cannot mask real gameplay errors.
	unload_current_scene()
	for _frame: int in range(4):
		await process_frame
	quit(0)


func _capture_encounter(level:Node,player:Player,path:String,position:Vector2,file_name:String)->void:
	var group:=level.get_node(path) as EncounterGroup
	player.global_position=position; player.velocity=Vector2.ZERO; player.player_camera.reset_smoothing(); group.activate(player)
	await _settle(); _save(file_name)


func _settle()->void:
	for _i:int in range(12): await process_frame


func _wait_level()->Node:
	for _i:int in range(480):
		await process_frame
		if current_scene!=null and current_scene.scene_file_path==LEVEL: return current_scene
	return null


func _save(file_name:String)->void:
	var path:="%s/%s" % [OUTPUT,file_name]
	var viewport_texture:ViewportTexture=root.get_texture()
	if viewport_texture==null:
		_fail("Viewport texture unavailable for %s" % path)
		return
	var image:Image=viewport_texture.get_image()
	if image==null or image.save_png(ProjectSettings.globalize_path(path))!=OK:
		_fail("Cannot save %s" % path)
		return
	captures+=1


func _fail(message:String)->void:
	push_error("CH4 CHARACTER MAIN QA: %s" % message)
	quit(1)
