extends SceneTree

const BOSS_PATH: String = "res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn"
const PLAYER_PATH: String = "res://scenes/player/player.tscn"
const RUNTIME_PATH: String = "res://scenes/runtime/chapter_gameplay_runtime.tscn"

var _failures: PackedStringArray = []
var _attack_id: int = 6000
var _hurt_signal_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _validate_phase_two_visual_authority()
	await _validate_javelin_bleed()
	await _validate_iron_grave_bleed()
	await _validate_bleed_refresh_and_lifecycle()
	await _validate_existing_status_regression()
	_validate_status_hud_contract()
	for failure: String in _failures:
		push_error("ORMUND PHASE2/BLEED: %s" % failure)
	print(
		"ORMUND PHASE2 VISUAL + BLEED | %s | TRANSITIONS 20 | FLIPS 30 | NORMAL_HITS 20 | DASH_HITS 10 | STAGGERS 5 | BLEED_HITS 40"
		% ("PASS" if _failures.is_empty() else "FAIL %d" % _failures.size())
	)
	quit(0 if _failures.is_empty() else 1)


func _validate_phase_two_visual_authority() -> void:
	for transition_index: int in 20:
		var pair: Dictionary = await _spawn_pair()
		var boss: SoulGaolerOrmund = pair.boss as SoulGaolerOrmund
		boss.health_component.set_current_health(275)
		_expect(boss.current_state == boss.PHASE_TRANSITION, "transition %d enters PhaseTransition" % transition_index)
		boss.complete_debug_phase_transition()
		_expect(boss.phase == 2, "transition %d establishes phase=2 authority" % transition_index)
		_expect(boss.animated_sprite.animation == &"flooded_judgment_windup", "transition %d opening uses P2 art" % transition_index)
		boss.complete_debug_phase_two_opening()

		var p2_actions: Array[StringName] = [
			&"chainstorm_cleave", &"undertow_pull", &"drowned_cell_rupture",
			&"soul_shackle", &"flooded_judgment", &"drowned_javelin",
			&"gaolers_verdict", &"iron_grave",
		]
		for action: StringName in p2_actions:
			for attack_phase: StringName in [&"windup", &"active", &"recovery"]:
				var animation_name: StringName = boss._action_animation(action, attack_phase)
				boss.play_animation(animation_name, true)
				_expect(not boss.is_phase_one_visual_active(), "%s/%s remains P2" % [action, attack_phase])

		# Any stale state request is resolved once at animation entry. This is a
		# future-regression guard, not a per-frame visibility override.
		for stale_animation: StringName in [
			&"idle_p1", &"walk_p1", &"turn_p1", &"light_hit_p1", &"stagger_p1",
			&"prison_hook_drag_windup", &"chain_anchor_slam_active",
			&"soul_cage_pulse_recovery",
		]:
			boss.play_animation(stale_animation, true)
			_expect(not boss.is_phase_one_visual_active(), "stale request %s is phase-safe" % stale_animation)

		if transition_index == 0:
			await _exercise_phase_two_hits_and_facing(boss)
		if transition_index < 5:
			_simulate_sustained_phase_two_visuals(boss, 120.0)
		_expect(boss.get_phase_visual_violation_count() == 0, "transition %d records zero P1 display violations" % transition_index)
		await _free_pair(pair)


func _exercise_phase_two_hits_and_facing(boss: SoulGaolerOrmund) -> void:
	boss.health_component.set_current_health(500)
	var player_hitbox := HitboxComponent.new()
	player_hitbox.faction = &"player"
	root.add_child(player_hitbox)
	await process_frame
	for hit_index: int in 30:
		boss.set_facing_direction(-1.0 if hit_index % 2 == 0 else 1.0)
		if hit_index % 6 == 0:
			boss.poise_component.current_poise = 1
			boss._stagger_protection = 0.0
		_attack_id += 1
		var is_dash: bool = hit_index >= 20
		player_hitbox.attack_kind = &"dash_attack" if is_dash else &"attack"
		player_hitbox.begin_attack(_attack_id, 28 if is_dash else 14, 1.0)
		_expect(player_hitbox.try_hit(boss.hurtbox), "phase2 hit %d resolves" % hit_index)
		player_hitbox.end_attack()
		_expect(not boss.is_phase_one_visual_active(), "phase2 hit %d keeps P2 art" % hit_index)
		if boss.current_state == boss.STAGGER:
			boss._stagger_protection = 0.0
			boss.poise_component.reset_to_full()
			boss.transition_state(boss.COMBAT)
			boss.play_animation(&"idle_p2", true)
	player_hitbox.queue_free()
	await process_frame


func _simulate_sustained_phase_two_visuals(boss: SoulGaolerOrmund, duration: float) -> void:
	var elapsed: float = 0.0
	var sequence: Array[StringName] = [
		&"idle_p2", &"move_p2", &"turn_p2", &"soul_shackle_windup",
		&"soul_shackle_active", &"soul_shackle_recovery", &"light_hit_p2",
		&"stagger_p2", &"drowned_cell_rupture_windup",
		&"drowned_cell_rupture_active", &"drowned_cell_rupture_recovery",
	]
	var index: int = 0
	while elapsed < duration:
		boss.play_animation(sequence[index % sequence.size()], true)
		_expect(not boss.is_phase_one_visual_active(), "sustained P2 visual %.1fs" % elapsed)
		elapsed += 0.5
		index += 1


func _validate_javelin_bleed() -> void:
	for run: int in 20:
		var player: Player = await _spawn_player()
		var effect := SoulGaolerAttackEffect.new()
		root.add_child(effect)
		effect.configure_javelin(Vector2.RIGHT, 520.0, 22, 7000 + run, null, {})
		var health_before: int = player.health_component.current_health
		_expect(effect.hitbox.try_hit(player.hurtbox), "javelin %d direct hit resolves" % run)
		_expect(player.health_component.current_health == health_before - 22, "javelin %d direct damage remains 22" % run)
		_expect(player.status_effect_controller.is_bleeding(), "javelin %d applies Bleed after hit confirmation" % run)
		_expect(is_equal_approx(player.status_effect_controller.get_remaining(PlayerStatusEffectController.BLEED), 5.0), "javelin %d starts five-second Bleed" % run)
		effect.queue_free()
		player.queue_free()
		await process_frame

	var invulnerable_player: Player = await _spawn_player()
	var rejected_effect := SoulGaolerAttackEffect.new()
	root.add_child(rejected_effect)
	rejected_effect.configure_javelin(Vector2.RIGHT, 520.0, 22, 7100, null, {})
	invulnerable_player.hurtbox.set_invulnerable(true)
	_expect(not rejected_effect.hitbox.try_hit(invulnerable_player.hurtbox), "invulnerable direct hit is rejected")
	_expect(not invulnerable_player.status_effect_controller.is_bleeding(), "rejected direct hit cannot apply Bleed")
	rejected_effect.queue_free()
	invulnerable_player.queue_free()
	await process_frame


func _validate_iron_grave_bleed() -> void:
	for run: int in 20:
		var player: Player = await _spawn_player()
		var effect := SoulGaolerAttackEffect.new()
		root.add_child(effect)
		effect.configure_zone(
			SoulGaolerAttackEffect.EffectKind.PRISON_PIKE,
			Vector2(32.0, 82.0), 0.88, 0.22, 0.20, 22, 7200 + run,
			null, {}, &"iron_grave_wave_1", true
		)
		effect._begin_active()
		var health_before: int = player.health_component.current_health
		_expect(effect.hitbox.try_hit(player.hurtbox), "iron grave %d direct hit resolves" % run)
		_expect(player.health_component.current_health == health_before - 22, "iron grave %d direct damage remains 22" % run)
		_expect(player.status_effect_controller.is_bleeding(), "iron grave %d applies Bleed" % run)
		effect.queue_free()
		player.queue_free()
		await process_frame


func _validate_bleed_refresh_and_lifecycle() -> void:
	var player: Player = await _spawn_player()
	var status: PlayerStatusEffectController = player.status_effect_controller
	_hurt_signal_count = 0
	player.hurt_controller.hurt_started.connect(_on_player_hurt_started)
	var effect := SoulGaolerAttackEffect.new()
	root.add_child(effect)
	effect.configure_javelin(Vector2.RIGHT, 520.0, 22, 7300, null, {})
	_expect(effect.hitbox.try_hit(player.hurtbox), "lifecycle direct hit resolves")
	var velocity_after_direct_hit: Vector2 = player.velocity
	_expect(_hurt_signal_count == 1, "direct hit produces one Hurt response")
	_expect(player.health_component.current_health == 78, "lifecycle starts after unchanged 22 direct damage")
	status.advance(0.99)
	_expect(player.health_component.current_health == 78, "Bleed has no t=0 or early tick")
	status.advance(0.01)
	_expect(player.health_component.current_health == 77, "Bleed ticks one HP at t=1")
	for _second: int in 4:
		status.advance(1.0)
	_expect(player.health_component.current_health == 73, "Bleed totals five HP at t=1..5")
	_expect(_hurt_signal_count == 1, "Bleed ticks add no Hurt response")
	_expect(player.velocity == velocity_after_direct_hit, "Bleed ticks add no knockback")
	_expect(not status.is_bleeding(), "Bleed expires after five seconds")
	effect.queue_free()
	player.queue_free()
	await process_frame

	var refresh_player: Player = await _spawn_player()
	var refresh_status: PlayerStatusEffectController = refresh_player.status_effect_controller
	_expect(refresh_status.apply_bleed(&"blade", 5.0, 1, 1.0), "initial Bleed applies")
	refresh_status.advance(3.0)
	var health_after_three_ticks: int = refresh_player.health_component.current_health
	_expect(refresh_status.apply_bleed(&"pike", 5.0, 1, 1.0), "second source refreshes Bleed")
	_expect(is_equal_approx(refresh_status.get_remaining(PlayerStatusEffectController.BLEED), 5.0), "refresh restores five seconds")
	_expect(refresh_status.get_active_effect_ids().count(PlayerStatusEffectController.BLEED) == 1, "refresh retains one Bleed instance")
	refresh_status.advance(5.0)
	_expect(refresh_player.health_component.current_health == health_after_three_ticks - 5, "refreshed Bleed has one five-tick stream")
	refresh_player.queue_free()
	await process_frame

	var lethal_player: Player = await _spawn_player()
	lethal_player.health_component.set_current_health(3)
	_expect(lethal_player.status_effect_controller.apply_bleed(&"lethal", 5.0, 1, 1.0), "lethal Bleed applies")
	lethal_player.status_effect_controller.advance(3.0)
	_expect(lethal_player.health_component.is_dead(), "Bleed can kill through HealthComponent")
	lethal_player.queue_free()
	await process_frame


func _validate_existing_status_regression() -> void:
	var player: Player = await _spawn_player()
	var status: PlayerStatusEffectController = player.status_effect_controller
	_expect(status.apply_burn(&"regression", 3.0, 5, 1.0), "Burn still applies")
	status.advance(3.0)
	_expect(player.health_component.current_health == 85, "Burn still produces its existing 15 damage")
	_expect(status.apply_freeze(&"regression", 3.0, 5.0), "Freeze still applies")
	status.advance(3.0)
	_expect(not status.is_frozen() and status.is_freeze_immune(), "Freeze still expires into immunity")
	_expect(status.apply_mire(&"regression", 0.2, 0.35, 0.70), "Mire still applies")
	status.advance(0.2)
	_expect(not status.is_mired(), "Mire still expires")
	player.queue_free()
	await process_frame


func _validate_status_hud_contract() -> void:
	var runtime_scene: PackedScene = load(RUNTIME_PATH) as PackedScene
	var runtime: Node = runtime_scene.instantiate()
	root.add_child(runtime)
	var bleed_slot: Control = runtime.get_node_or_null("HUD/StatusHud/Bleed") as Control
	_expect(bleed_slot != null, "formal runtime HUD owns a Bleed slot")
	runtime.queue_free()


func _spawn_pair() -> Dictionary:
	var boss: SoulGaolerOrmund = (load(BOSS_PATH) as PackedScene).instantiate() as SoulGaolerOrmund
	var player: Player = (load(PLAYER_PATH) as PackedScene).instantiate() as Player
	root.add_child(player)
	root.add_child(boss)
	await process_frame
	player.status_effect_controller.set_physics_process(false)
	boss.begin_combat(player)
	return {"boss": boss, "player": player}


func _free_pair(pair: Dictionary) -> void:
	var boss: SoulGaolerOrmund = pair.boss as SoulGaolerOrmund
	boss._on_attack_cancelled()
	boss.queue_free()
	(pair.player as Player).queue_free()
	await process_frame


func _spawn_player() -> Player:
	var player: Player = (load(PLAYER_PATH) as PackedScene).instantiate() as Player
	root.add_child(player)
	await process_frame
	player.status_effect_controller.set_physics_process(false)
	return player


func _on_player_hurt_started(_knockback: Vector2, _damage: int, _source: Vector2) -> void:
	_hurt_signal_count += 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
