extends SceneTree

var failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var profile:=ChapterRegistry.get_chapter(ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP)
	_check(profile.debug_ready,"Chapter IV is F5 debug-ready")
	_check(profile.main_scene_path=="res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn","registry uses formal Main level")
	for spawn:StringName in [&"CH4_HUMANOID_COMBAT",&"CH4_CREATURE_COMBAT",&"CH4_ELITE_TRIAL",&"CH4_BOSS_PHASE_01",&"CH4_BOSS_PHASE_02"]:
		_check(spawn in profile.available_spawn_ids,"profile exposes %s" % spawn)
	_check(FileAccess.file_exists(profile.main_scene_path),"formal Chapter IV scene exists")
	var main_source:String=FileAccess.get_file_as_string(profile.main_scene_path)
	var level_script_source:String=FileAccess.get_file_as_string("res://chapters/chapter_04_drowned_underkeep/scripts/level/drowned_underkeep.gd")
	var trial_source:String=FileAccess.get_file_as_string("res://chapters/chapter_04_drowned_underkeep/scenes/trials/chapter_04_character_trial.tscn")
	_check(not main_source.contains("chapter_04_character_trial.tscn"),"formal S3 route excludes CharacterTrial")
	_check(main_source.contains("RoomTransitionController"),"formal Main owns the S3 room controller")
	_check(level_script_source.contains("CH4_BOSS_PHASE_01"),"Boss arena F5 spawn exists")
	_check(level_script_source.contains("CH4_BOSS_PHASE_02"),"Boss Phase II compatibility spawn exists")
	_check(level_script_source.contains("CH4_AREA_16"),"formal route resolves its final room")
	_check(trial_source.contains("soul_gaoler_ormund.tscn"),"separate regression trial owns latest Soul Gaoler scene")
	for role:String in ["drowned_gaoler","chainbound_convict","mire_harpooner","sunken_shield_penitent","mirefin_raider","bog_toad","sewer_maw","underkeep_executioner"]:
		_check(trial_source.contains("%s.tscn" % role),"Main trial references %s" % role)
	call_deferred("_finish")


func _finish() -> void:
	print("CH4 MAIN INTEGRATION TEST | %s" % ("PASS" if failures==0 else "FAIL %d" % failures))
	quit(0 if failures==0 else 1)


func _check(condition:bool,message:String)->void:
	if condition:return
	failures+=1
	push_error(message)
