extends SceneTree

const BOSS_PATH := "res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn"
var failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed:=load(BOSS_PATH) as PackedScene
	_check(packed!=null,"Boss scene loads")
	if packed==null: quit(1); return
	var boss:=packed.instantiate() as SoulGaolerOrmund
	_check(boss!=null,"Boss has SoulGaolerOrmund controller")
	root.add_child(boss)
	await process_frame
	var config:=boss.config as SoulGaolerOrmundConfig
	_check(config!=null,"Boss config type")
	_check(boss.health_component.current_health==560,"shared Boss health is 560")
	_check(boss.phase==1,"starts in Phase I")
	_check(boss.animated_sprite.sprite_frames.get_animation_names().size()==47,"complete 47-animation runtime set")
	for required:StringName in [&"halberd_sweep_active",&"phase_transition",&"chainstorm_cleave_active",&"flooded_judgment_active",&"soul_release"]:
		_check(boss.animated_sprite.sprite_frames.has_animation(required),"animation %s exists" % required)
	var p1_image: Image = boss.animated_sprite.sprite_frames.get_frame_texture(&"idle_p1", 0).get_image()
	var p2_image: Image = boss.animated_sprite.sprite_frames.get_frame_texture(&"idle_p2", 0).get_image()
	_check(p1_image.get_size() == Vector2i(192, 192), "Boss frame is 192x192")
	_check(is_zero_approx(p1_image.get_pixel(0, 0).a), "Boss frame keeps transparent background")
	_check(hash(p1_image.get_data()) != hash(p2_image.get_data()), "Phase II is a redrawn frame, not the Phase I frame")
	boss.health_component.set_current_health(308)
	await process_frame
	_check(boss.current_state==boss.PHASE_TRANSITION,"55 percent health starts transition")
	boss.complete_debug_phase_transition()
	_check(boss.phase==2,"transition enters Phase II")
	_check(is_equal_approx(boss.damage_policy.damage_multiplier,0.72),"Phase II mitigation active")
	boss._start_action(&"chainstorm_cleave")
	_check(boss.attack_phase==&"Windup","attack begins with telegraphed windup")
	boss._begin_active()
	_check(boss.is_attack_window_active(),"active phase enables Hitbox")
	boss._begin_recovery()
	_check(not boss.is_attack_window_active(),"recovery disables Hitbox")
	boss.queue_free()
	await process_frame
	print("SOUL GAOLER ORMUND TEST | %s" % ("PASS" if failures==0 else "FAIL %d" % failures))
	quit(0 if failures==0 else 1)


func _check(condition:bool,message:String)->void:
	if condition:return
	failures+=1
	push_error(message)
