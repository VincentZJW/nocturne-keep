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
	_check(boss.health_component.current_health==460,"shared Boss health is 460")
	_check(is_equal_approx(config.phase_one_damage_multiplier,0.90),"Phase I mitigation is 0.90")
	_check(is_equal_approx(config.phase_two_damage_multiplier,0.84),"Phase II mitigation is 0.84")
	_check(config.phase_one_poise==130 and config.phase_two_poise==158,"phase Poise is rebalanced")
	_check(is_equal_approx(config.phase_one_stagger_duration,0.82),"Phase I Stagger reward is 0.82 seconds")
	_check(is_equal_approx(config.phase_two_stagger_duration,0.65),"Phase II Stagger reward is 0.65 seconds")
	_check(boss.get_combo_budget()==2,"Phase I starts with two-action Combo Budget")
	_check(is_equal_approx(boss.scale.x,1.0),"Boss body transform remains unscaled")
	_check(is_equal_approx(boss.get_node("VisualRoot").scale.x,0.60),"Boss presentation resolves to the target heavy-humanoid height ratio")
	_check(boss.phase==1,"starts in Phase I")
	_check(boss.animated_sprite.sprite_frames.get_animation_names().size()==47,"complete 47-animation runtime set")
	for required:StringName in [&"halberd_sweep_active",&"phase_transition",&"chainstorm_cleave_active",&"flooded_judgment_active",&"soul_release"]:
		_check(boss.animated_sprite.sprite_frames.has_animation(required),"animation %s exists" % required)
	var p1_image: Image = boss.animated_sprite.sprite_frames.get_frame_texture(&"idle_p1", 0).get_image()
	var p2_image: Image = boss.animated_sprite.sprite_frames.get_frame_texture(&"idle_p2", 0).get_image()
	_check(p1_image.get_size() == Vector2i(192, 192), "Boss frame is 192x192")
	_check(is_zero_approx(p1_image.get_pixel(0, 0).a), "Boss frame keeps transparent background")
	_check(hash(p1_image.get_data()) != hash(p2_image.get_data()), "Phase II is a redrawn frame, not the Phase I frame")
	boss.health_component.set_current_health(253)
	await process_frame
	_check(boss.current_state==boss.PHASE_TRANSITION,"55 percent health starts transition")
	boss.complete_debug_phase_transition()
	_check(boss.phase==2,"transition enters Phase II")
	_check(is_equal_approx(boss.damage_policy.damage_multiplier,0.84),"Phase II mitigation active")
	_check(boss.get_combo_budget() in [2,3],"Phase II uses bounded two-to-three action combos")
	boss._start_action(&"chainstorm_cleave")
	_check(boss.attack_phase==&"Windup","attack begins with telegraphed windup")
	_check(boss.is_direction_locked(),"attack locks facing before Active")
	boss._begin_active()
	_check(boss.is_attack_window_active(),"active phase enables Hitbox")
	boss._begin_recovery()
	_check(not boss.is_attack_window_active(),"recovery disables Hitbox")
	_check(is_equal_approx(config.action_timing(&"flooded_judgment").z,1.62),"ultimate owns the largest recovery window")
	boss.queue_free()
	await process_frame
	print("SOUL GAOLER ORMUND TEST | %s" % ("PASS" if failures==0 else "FAIL %d" % failures))
	quit(0 if failures==0 else 1)


func _check(condition:bool,message:String)->void:
	if condition:return
	failures+=1
	push_error(message)
