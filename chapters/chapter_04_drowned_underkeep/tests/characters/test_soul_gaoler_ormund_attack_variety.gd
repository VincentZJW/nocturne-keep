extends SceneTree

const BOSS_PATH: String = "res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn"
const PLAYER_PATH: String = "res://scenes/player/player.tscn"

var failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _validate_phase_two_opening_30()
	await _validate_javelin_20()
	await _validate_verdict_20()
	await _validate_iron_grave_20()
	await _validate_category_selection()
	for failure: String in failures:
		push_error("ORMUND ATTACK VARIETY: %s" % failure)
	print(
		"CH4 ORMUND ATTACK VARIETY | %s | TRANSITIONS 30 | JAVELIN 20 | VERDICT 20 | IRON_GRAVE 20"
		% ("PASS" if failures.is_empty() else "FAIL %d" % failures.size())
	)
	quit(0 if failures.is_empty() else 1)


func _spawn_pair() -> Dictionary:
	var boss_scene: PackedScene = load(BOSS_PATH) as PackedScene
	var player_scene: PackedScene = load(PLAYER_PATH) as PackedScene
	var boss: SoulGaolerOrmund = boss_scene.instantiate() as SoulGaolerOrmund
	var player: Player = player_scene.instantiate() as Player
	root.add_child(player)
	root.add_child(boss)
	await process_frame
	player.global_position = Vector2(840.0, 0.0)
	boss.global_position = Vector2(1040.0, 0.0)
	boss.configure_movement_bounds(180.0, 2124.0)
	boss.begin_combat(player)
	return {"boss": boss, "player": player}


func _free_pair(pair: Dictionary) -> void:
	var boss: SoulGaolerOrmund = pair.boss as SoulGaolerOrmund
	boss._on_attack_cancelled()
	boss.queue_free()
	(pair.player as Player).queue_free()
	await process_frame


func _validate_phase_two_opening_30() -> void:
	for run: int in 30:
		var pair: Dictionary = await _spawn_pair()
		var boss: SoulGaolerOrmund = pair.boss as SoulGaolerOrmund
		var config: SoulGaolerOrmundConfig = boss.config as SoulGaolerOrmundConfig
		boss.health_component.set_current_health(275)
		_expect(boss.current_state == boss.PHASE_TRANSITION, "transition %d enters PhaseTransition" % run)
		_expect(not boss.hurtbox.is_enabled, "transition %d closes Boss Hurtbox" % run)
		_expect(is_equal_approx(boss.state_timer, 2.0), "transition %d is 2.0 seconds" % run)
		boss.complete_debug_phase_transition()
		_expect(boss.phase == 2 and boss.is_phase_two_opening_active(), "transition %d connects directly to opening" % run)
		_expect(boss.phase2_opening_used, "transition %d marks one-shot opening" % run)
		_expect(not boss.hurtbox.is_enabled, "opening %d keeps Boss protected during telegraph" % run)
		_expect(is_equal_approx(boss.action_timer, 1.40), "opening %d telegraph is 1.40 seconds" % run)
		_expect(boss.get_phase_two_opening_safe_gaps().size() == 2, "opening %d publishes two safe ground gaps" % run)
		_expect(boss.get_active_effect_count() == 3, "opening %d covers arena with three separated rift segments" % run)
		for effect_node: SoulGaolerAttackEffect in boss._active_effects:
			_expect(effect_node.damage == 40, "opening %d damage is 40" % run)
			_expect(effect_node.visual_size.y == 16.0, "opening %d remains a low jumpable wave" % run)
		var player: Player = pair.player as Player
		var opening_health_before: int = player.health_component.current_health
		var first_rift: SoulGaolerAttackEffect = boss._active_effects[0]
		var second_rift: SoulGaolerAttackEffect = boss._active_effects[1]
		first_rift._begin_active()
		second_rift._begin_active()
		_expect(first_rift.hitbox.try_hit(player.hurtbox), "opening %d resolves one real hit" % run)
		_expect(not second_rift.hitbox.try_hit(player.hurtbox), "opening %d shares one arena-wide damage gate" % run)
		_expect(player.health_component.current_health == opening_health_before - 40, "opening %d applies exactly 40 damage" % run)
		boss._process_phase_two_opening(1.40)
		_expect(boss.attack_phase == &"Active", "opening %d reaches Active after telegraph" % run)
		boss._process_phase_two_opening(0.24)
		_expect(boss.attack_phase == &"Recovery" and boss.hurtbox.is_enabled, "opening %d restores Hurtbox for punish" % run)
		_expect(is_equal_approx(boss.action_timer, 0.85), "opening %d recovery is 0.85 seconds" % run)
		boss._process_phase_two_opening(0.85)
		_expect(boss.current_state == boss.COMBAT, "opening %d returns to Combat" % run)
		boss._start_phase_two_opening()
		_expect(not boss.is_phase_two_opening_active(), "opening %d cannot repeat" % run)
		await _free_pair(pair)


func _validate_javelin_20() -> void:
	for run: int in 20:
		var pair: Dictionary = await _spawn_pair()
		var boss: SoulGaolerOrmund = pair.boss as SoulGaolerOrmund
		var player: Player = pair.player as Player
		player.global_position = Vector2(1360.0, -10.0)
		boss._start_action(&"drowned_javelin")
		_expect(not boss.is_direction_locked(), "javelin %d tracks before lock window" % run)
		boss.action_timer = 0.24
		boss._process_direction_lock(0.01)
		var locked_target: Vector2 = boss._locked_aim_position
		player.global_position += Vector2(0.0, -120.0)
		boss._process_direction_lock(0.10)
		_expect(boss.is_direction_locked() and boss._locked_aim_position == locked_target, "javelin %d freezes aim for dodge" % run)
		boss._begin_active()
		_expect(boss.get_active_effect_count() == 1, "javelin %d spawns one projectile" % run)
		var projectile: SoulGaolerAttackEffect = boss._active_effects[0]
		_expect(projectile.kind == SoulGaolerAttackEffect.EffectKind.JAVELIN, "javelin %d uses projectile effect" % run)
		_expect(projectile.damage == 22 and projectile.velocity.length() > 500.0, "javelin %d is 22 damage and high speed" % run)
		projectile._embed()
		_expect(projectile.velocity == Vector2.ZERO and is_equal_approx(projectile._linger_remaining, 1.5), "javelin %d miss embeds without a damage field" % run)
		_expect(boss.get_javelin_cooldown() >= 5.9, "javelin %d starts P1 cooldown" % run)
		await _free_pair(pair)


func _validate_verdict_20() -> void:
	for run: int in 20:
		var pair: Dictionary = await _spawn_pair()
		var boss: SoulGaolerOrmund = pair.boss as SoulGaolerOrmund
		var player: Player = pair.player as Player
		boss._start_action(&"gaolers_verdict")
		boss.action_timer = 0.27
		boss._process_direction_lock(0.01)
		_expect(boss.is_direction_locked(), "verdict %d locks in final 0.28 seconds" % run)
		boss._begin_active()
		_expect(boss.melee_hitbox.damage == 28, "verdict %d direct hit is 28" % run)
		_expect(boss.get_active_effect_count() == 1, "verdict %d creates one ground shockwave" % run)
		var shockwave: SoulGaolerAttackEffect = boss._active_effects[0]
		_expect(shockwave.damage == 18 and shockwave.visual_size.y == 16.0, "verdict %d shockwave is jumpable 18 damage" % run)
		var health_before: int = player.health_component.current_health
		_expect(boss.melee_hitbox.try_hit(player.hurtbox), "verdict %d direct hit resolves" % run)
		_expect(not shockwave.hitbox.try_hit(player.hurtbox), "verdict %d shared id blocks 28+18 double damage" % run)
		_expect(player.health_component.current_health == health_before - 28, "verdict %d applies only 28 damage" % run)
		await _free_pair(pair)


func _validate_iron_grave_20() -> void:
	for run: int in 20:
		var pair: Dictionary = await _spawn_pair()
		var boss: SoulGaolerOrmund = pair.boss as SoulGaolerOrmund
		boss.phase = 2 if run % 2 == 1 else 1
		boss._start_action(&"iron_grave")
		var expected_first_count: int = 3 if boss.phase == 2 else 4
		_expect(boss.get_active_effect_count() == expected_first_count, "iron grave %d authors first-wave pikes" % run)
		var first_id: int = boss._active_effects[0].attack_id
		for pike: SoulGaolerAttackEffect in boss._active_effects:
			_expect(pike.damage == 22 and is_equal_approx(pike.telegraph_duration, 0.88), "iron grave %d pike is telegraphed 22 damage" % run)
			_expect(pike.attack_id == first_id, "iron grave %d shares first-wave attack id" % run)
		var player: Player = pair.player as Player
		var pike_health_before: int = player.health_component.current_health
		boss._active_effects[0]._begin_active()
		boss._active_effects[1]._begin_active()
		boss._active_effects[0]._physics_process(0.08)
		boss._active_effects[1]._physics_process(0.08)
		_expect(boss._active_effects[0].is_damage_active(), "iron grave %d arms after visible emergence" % run)
		_expect(boss._active_effects[0].hitbox.try_hit(player.hurtbox), "iron grave %d first pike resolves" % run)
		_expect(not boss._active_effects[1].hitbox.try_hit(player.hurtbox), "iron grave %d same-wave overlap cannot double-hit" % run)
		_expect(player.health_component.current_health == pike_health_before - 22, "iron grave %d applies one 22-damage result" % run)
		boss._begin_active()
		if boss.phase == 2:
			boss._process_action(0.53)
			_expect(boss._iron_second_wave_spawned, "iron grave %d P2 schedules second wave" % run)
			_expect(boss.get_active_effect_count() == 7, "iron grave %d P2 uses 3+4 pikes" % run)
			var second_id: int = boss._active_effects[-1].attack_id
			_expect(second_id != first_id, "iron grave %d second wave owns a new damage gate" % run)
		await _free_pair(pair)


func _validate_category_selection() -> void:
	var pair: Dictionary = await _spawn_pair()
	var boss: SoulGaolerOrmund = pair.boss as SoulGaolerOrmund
	var player: Player = pair.player as Player
	boss.global_position = Vector2(900.0, 0.0)
	player.global_position = Vector2(970.0, 0.0)
	_expect(boss._preferred_category(70.0) == boss.CATEGORY_CLOSE, "close range selects Close category")
	_expect(boss._preferred_category(150.0) == boss.CATEGORY_MID, "middle range selects Mid category")
	_expect(boss._preferred_category(260.0) == boss.CATEGORY_FAR, "far range selects Far category")
	boss._recent_category_history = [boss.CATEGORY_FAR, boss.CATEGORY_FAR]
	_expect(not boss._can_use_action(&"drowned_javelin", false), "one category cannot appear three times in succession")
	boss._recent_category_history.clear()
	boss._normal_action_since_high_pressure = false
	_expect(not boss._can_use_action(&"flooded_judgment", false), "high pressure requires a normal action separator")
	await _free_pair(pair)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
