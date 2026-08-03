extends SceneTree

## Formal Main/F5-authority capture for the 95% replication pass.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const OUTPUT: String = "res://docs/qa/chapter_04_character_replication/main"
var _captures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280,720))
	var debug:DebugRunConfigState=root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug==null: _fail("DebugRunConfig missing"); return
	debug.debug_chapter_start_enabled=true
	debug.debug_start_chapter_id=ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id=&"CH4_HUMANOID_COMBAT"
	debug.debug_skip_chapter_intro=true
	if change_scene_to_file(BOOTSTRAP)!=OK: _fail("MainBootstrap launch failed"); return
	var level:Node=await _wait_level()
	if level==null: _fail("Main did not route to Chapter IV"); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var player:Player=level.get_node("ChapterRuntime/Player") as Player
	player.hurtbox.set_invulnerable(true)
	await _capture(level,player,"CharacterTrial/GaolerIntake",Vector2(1900,584),"01_gaoler_harpooner_main.png")
	await _capture(level,player,"CharacterTrial/PenitentFloodway",Vector2(4450,584),"02_penitent_mirefin_main.png")
	await _capture(level,player,"CharacterTrial/ConvictCistern",Vector2(5950,584),"03_convict_toad_maw_main.png")
	await _capture(level,player,"CharacterTrial/ExecutionBlock",Vector2(7100,584),"04_executioner_main.png")
	var boss_group:EncounterGroup=level.get_node("CharacterTrial/OrmundBossEncounter") as EncounterGroup
	var boss:SoulGaolerOrmund=level.get_node("CharacterTrial/OrmundBossEncounter/Enemies/SoulGaolerOrmund") as SoulGaolerOrmund
	player.global_position=Vector2(8440,584); player.velocity=Vector2.ZERO; player.player_camera.reset_smoothing(); boss_group.activate(player); boss.set_target(player)
	await _settle(); _save("05_ormund_phase_01_main.png")
	boss.health_component.set_current_health(308); await create_timer(1.35).timeout; await _settle(); _save("06_ormund_phase_02_main.png")
	debug.reset_to_defaults()
	print("CH4 CHARACTER REPLICATION MAIN QA | PASS captures=%d main=%s" % [_captures,level.scene_file_path])
	unload_current_scene(); for _frame:int in range(4): await process_frame
	quit(0)


func _capture(level:Node,player:Player,path:String,position:Vector2,file_name:String)->void:
	var group:EncounterGroup=level.get_node(path) as EncounterGroup
	player.global_position=position; player.velocity=Vector2.ZERO; player.player_camera.reset_smoothing(); group.activate(player)
	await _settle(); _save(file_name)


func _settle()->void:
	for _i:int in range(16): await process_frame


func _wait_level()->Node:
	for _i:int in range(480):
		await process_frame
		if current_scene!=null and current_scene.scene_file_path==LEVEL: return current_scene
	return null


func _save(file_name:String)->void:
	var image:Image=root.get_texture().get_image()
	if image==null or image.save_png(ProjectSettings.globalize_path("%s/%s" % [OUTPUT,file_name]))!=OK: _fail("Cannot save "+file_name); return
	_captures+=1


func _fail(message:String)->void:
	push_error("CH4 CHARACTER REPLICATION MAIN QA: "+message); quit(1)
