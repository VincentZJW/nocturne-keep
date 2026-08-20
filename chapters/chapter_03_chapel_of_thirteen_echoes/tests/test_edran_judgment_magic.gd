extends SceneTree

const PLAYER_SCENE: String = "res://scenes/player/player.tscn"
const BOSS_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/thirteenth_pontiff_edran.tscn"
const LIGHTNING_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/spells/pontiff_lightning_strike.tscn"
const GRAVITY_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/spells/pontiff_gravity_judgment.tscn"

var _failures: Array[String] = []
var _assertions: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player: Player = (load(PLAYER_SCENE) as PackedScene).instantiate() as Player
	var boss: ThirteenthPontiffEdran = (load(BOSS_SCENE) as PackedScene).instantiate() as ThirteenthPontiffEdran
	root.add_child(player)
	root.add_child(boss)
	await process_frame
	player.set_physics_process(false)
	boss.set_physics_process(false)
	boss.activate(player)
	_test_resource_contract(boss)
	_test_position_history(boss)
	await _test_lightning_damage(player, boss)
	_test_health_matrix(boss, player)
	_test_selector_contract(boss, player)
	await _test_runtime_spells(boss, player)
	player.queue_free()
	boss.queue_free()
	await process_frame
	_finish()


func _test_resource_contract(boss: ThirteenthPontiffEdran) -> void:
	_expect(ResourceLoader.exists(LIGHTNING_SCENE, "PackedScene"), "formal lightning scene exists")
	_expect(ResourceLoader.exists(GRAVITY_SCENE, "PackedScene"), "formal gravity scene exists")
	_expect(boss.lightning_strike_scene != null, "formal Boss references lightning")
	_expect(boss.gravity_judgment_scene != null, "formal Boss references gravity")
	var lightning: PontiffLightningStrike = (load(LIGHTNING_SCENE) as PackedScene).instantiate() as PontiffLightningStrike
	var gravity: PontiffGravityJudgment = (load(GRAVITY_SCENE) as PackedScene).instantiate() as PontiffGravityJudgment
	_expect(lightning != null and lightning.get_node_or_null("Hitbox") is HitboxComponent, "lightning owns formal one-hit Hitbox")
	_expect(lightning != null and lightning.get_node_or_null("StrikeAudio") is AudioStreamPlayer2D, "lightning owns formal strike audio")
	_expect(gravity != null, "gravity judgment visual instantiates")
	_expect(gravity != null and gravity.get_node_or_null("BellInvocation") is AudioStreamPlayer2D, "gravity judgment owns formal bell invocation audio")
	_expect(gravity != null and gravity.get_node_or_null("SealLock") is AudioStreamPlayer2D, "gravity judgment owns formal seal-lock audio")
	_expect(gravity != null and gravity.get_node_or_null("FinalJudgment") is AudioStreamPlayer2D, "gravity judgment owns formal judgment-impact audio")
	_expect(gravity != null and gravity.get_node_or_null("CasterAura") is AnimatedSprite2D, "gravity judgment owns the caster ritual layer")
	_expect(gravity != null and gravity.get_node_or_null("TargetRite/SacredBell") is AnimatedSprite2D, "gravity judgment owns the thirteenth sacred bell layer")
	_expect(gravity != null and gravity.get_node_or_null("TargetRite/JudgmentSeal") is AnimatedSprite2D, "gravity judgment owns the absolution seal layer")
	_expect(gravity != null and gravity.get_node_or_null("TargetRite/Compression") is AnimatedSprite2D, "gravity judgment owns the spatial compression layer")
	_expect(gravity != null and gravity.get_node_or_null("TargetRite/FinalImpact") is AnimatedSprite2D, "gravity judgment owns the final punishment layer")
	if lightning != null:
		lightning.free()
	if gravity != null:
		gravity.free()


func _test_position_history(boss: ThirteenthPontiffEdran) -> void:
	boss._player_position_history.clear()
	for index: int in range(21):
		boss._behavior_clock = float(index) * 0.10
		boss._record_player_position(Vector2(float(index) * 10.0, 500.0))
	boss._behavior_clock = 2.0
	var historical: Vector2 = boss.get_historical_player_position(1.0)
	_expect(historical.is_equal_approx(Vector2(100.0, 500.0)), "one-second historical target is exact")
	_expect(boss.get_historical_sample_error(1.0) <= 0.001, "history timing error is within sample tolerance")
	var bolt_targets: Array[Vector2] = []
	for strike_time: float in [2.0, 2.7, 3.4]:
		boss._behavior_clock = strike_time
		boss._record_player_position(Vector2(strike_time * 100.0, 500.0))
		bolt_targets.append(boss.get_historical_player_position(1.0))
	_expect(bolt_targets[0] != bolt_targets[1] and bolt_targets[1] != bolt_targets[2], "three bolts resample distinct historical positions")
	_expect(is_equal_approx(boss.config.lightning_history_sample_interval, 0.10), "history sample interval is 0.10s")
	_expect(is_equal_approx(boss.config.lightning_history_duration, 2.0), "history retains two seconds")


func _test_health_matrix(boss: ThirteenthPontiffEdran, player: Player) -> void:
	var expected: Dictionary[int, int] = {
		100: 50, 90: 50, 80: 50, 60: 50, 51: 50,
		50: 30, 49: 29, 45: 25, 40: 20, 35: 20, 30: 20, 25: 20,
		21: 20, 20: 20, 15: 15, 10: 10, 1: 1,
	}
	for hp_before: int in expected:
		player.health_component.set_current_health(hp_before)
		var result: Dictionary = boss.resolve_weight_of_absolution_for_player(player)
		_expect(player.health_component.current_health == expected[hp_before], "gravity HP %d becomes %d" % [hp_before, expected[hp_before]])
		_expect(int(result.get(&"amount_changed", -1)) == hp_before - expected[hp_before], "gravity HP %d reports exact delta" % hp_before)
		_expect(int(result.get(&"target_hp", -1)) == expected[hp_before], "gravity HP %d reports exact target" % hp_before)
		if player.is_dead():
			player.respawn_at(Vector2.ZERO)
		else:
			player.health_component.reset_to_full()
	player.hurtbox.set_invulnerable(true)
	player.health_component.set_current_health(80)
	boss.resolve_weight_of_absolution_for_player(player)
	_expect(player.health_component.current_health == 50, "sure-hit gravity ignores ordinary Hurtbox invulnerability")
	player.hurtbox.set_invulnerable(false)
	player.health_component.reset_to_full()


func _test_lightning_damage(player: Player, boss: ThirteenthPontiffEdran) -> void:
	player.health_component.reset_to_full()
	player.hurtbox.set_invulnerable(false)
	var strike: PontiffLightningStrike = (load(LIGHTNING_SCENE) as PackedScene).instantiate() as PontiffLightningStrike
	strike.telegraph_duration = 0.02
	strike.active_duration = 0.10
	strike.visual_duration = 0.14
	strike.initialize(7001, 18, boss)
	root.add_child(strike)
	strike.global_position = player.global_position
	# Advance the focused effect deterministically; other Boss coroutines in this
	# SceneTree test intentionally keep the tree's frame cadence variable.
	strike._process(0.021)
	_expect(strike.hitbox.is_active, "lightning activates its formal Hitbox after telegraph")
	# The focused suite does not run a real gameplay physics loop, so explicitly
	# resolve the already-active overlap when PhysicsServer has not scanned it yet.
	if player.health_component.current_health == 100:
		strike.hitbox.try_hit(player.hurtbox)
	var after_hit: int = player.health_component.current_health
	_expect(after_hit == 82, "lightning resolves one formal 18-damage hit")
	_expect(not strike.hitbox.try_hit(player.hurtbox), "one lightning attack ID rejects a duplicate direct hit")
	strike.cancel()
	await process_frame
	_expect(player.health_component.current_health == after_hit, "one lightning attack ID cannot damage twice")
	player.hurt_controller.reset_after_respawn()
	player.health_component.reset_to_full()


func _test_selector_contract(boss: ThirteenthPontiffEdran, player: Player) -> void:
	_expect(is_equal_approx(boss.config.phase_1_lightning_cooldown, 10.5), "Phase 1 lightning cooldown is 10.5s")
	_expect(is_equal_approx(boss.config.phase_2_lightning_cooldown, 8.5), "Phase 2 lightning cooldown is 8.5s")
	_expect(boss.config.lightning_damage == 18, "each lightning strike deals 18")
	_expect(is_equal_approx(boss.config.gravity_cooldown, 21.0), "gravity full cooldown is 21s")
	_expect(is_equal_approx(boss.config.gravity_first_cast_delay, 8.0), "gravity opening grace is 8s")
	_expect(is_equal_approx(boss.config.gravity_final_seal_time, 1.40), "gravity Final Seal occurs at 1.40s")
	_expect(boss.config.gravity_health_threshold == 50 and boss.config.gravity_direct_damage == 20 and boss.config.gravity_health_floor == 20, "gravity uses authoritative 50/20/floor-20 rule")
	boss._phase = 1
	boss._gravity_cooldown = 0.0
	boss._phase_02_elapsed = 99.0
	var phase_one_candidates: Array[ThirteenthPontiffEdran.Attack] = []
	boss._append_magic_candidates(phase_one_candidates)
	_expect(ThirteenthPontiffEdran.Attack.WEIGHT_OF_ABSOLUTION not in phase_one_candidates, "gravity is absent in Phase 1")
	boss._phase = 2
	boss._phase_02_opening_gravity_completed = true
	boss._last_magic = ThirteenthPontiffEdran.Attack.FIRE_SPELL
	var phase_two_candidates: Array[ThirteenthPontiffEdran.Attack] = []
	boss._append_magic_candidates(phase_two_candidates)
	_expect(ThirteenthPontiffEdran.Attack.WEIGHT_OF_ABSOLUTION in phase_two_candidates, "gravity enters Phase 2 signature pool after grace")
	player.status_effect_controller.apply_freeze(&"qa_freeze", 3.0, 5.0)
	phase_two_candidates.clear()
	boss._append_magic_candidates(phase_two_candidates)
	_expect(ThirteenthPontiffEdran.Attack.WEIGHT_OF_ABSOLUTION not in phase_two_candidates, "gravity cannot start on frozen Player")
	player.status_effect_controller.clear_all()


func _test_runtime_spells(boss: ThirteenthPontiffEdran, player: Player) -> void:
	boss.config = boss.config.duplicate() as ThirteenthPontiffEdranConfig
	boss.config.lightning_windup = 0.05
	boss.config.lightning_telegraph_duration = 0.05
	boss.config.lightning_strike_interval = 0.10
	boss.config.lightning_active_duration = 0.03
	boss.config.lightning_visual_duration = 0.05
	boss.config.phase_1_lightning_recovery = 0.05
	boss._phase = 1
	boss.current_state = ThirteenthPontiffEdran.State.IDLE
	boss._action_locked = false
	boss._player_position_history.clear()
	for index: int in range(21):
		boss._behavior_clock = float(index) * 0.10
		boss._record_player_position(Vector2(float(index) * 8.0, 0.0))
	_expect(boss.debug_force_attack(&"threefold_judgment"), "debug starts formal Threefold Judgment")
	var elapsed: float = 0.0
	while boss._action_locked and elapsed < 1.2:
		await create_timer(0.05).timeout
		elapsed += 0.05
		boss._behavior_clock += 0.05
		player.global_position.x += 6.0
		boss._record_player_position(player.global_position)
	_expect(not boss._action_locked, "Threefold Judgment completes")
	_expect(boss._lightning_targets.size() == 3, "Threefold Judgment produces three targets")
	if boss._lightning_targets.size() == 3:
		_expect(boss._lightning_targets[0] != boss._lightning_targets[1], "Bolt 2 resamples history")
		_expect(boss._lightning_targets[1] != boss._lightning_targets[2], "Bolt 3 resamples history")
	boss.debug_enter_phase_02_immediate()
	boss.config.gravity_cast_time = 0.10
	boss.config.gravity_final_seal_time = 0.05
	boss.config.gravity_recovery = 0.05
	boss.config.phase_02_stagger_duration = 0.05
	boss.current_state = ThirteenthPontiffEdran.State.IDLE
	boss._action_locked = false
	player.health_component.set_current_health(80)
	_expect(boss.debug_force_attack(&"weight_of_absolution"), "debug starts formal Weight of Absolution")
	await create_timer(0.25).timeout
	_expect(player.health_component.current_health == 50, "runtime gravity resolves through HealthComponent")
	_expect(not boss._action_locked, "Weight of Absolution completes recovery")
	var poise_hit: HitboxComponent = HitboxComponent.new()
	poise_hit.attack_kind = &"dash_attack"
	boss.current_state = ThirteenthPontiffEdran.State.GRAVITY_FINAL_SEAL
	boss._gravity_final_seal = true
	boss.current_poise = 1
	boss._on_hit_resolving(poise_hit)
	_expect(boss.current_state == ThirteenthPontiffEdran.State.GRAVITY_FINAL_SEAL, "Final Seal cast armour rejects stagger")
	boss.current_state = ThirteenthPontiffEdran.State.GRAVITY_SPELL_WINDUP
	boss._gravity_final_seal = false
	boss.current_poise = 1
	boss._on_hit_resolving(poise_hit)
	_expect(boss.current_state == ThirteenthPontiffEdran.State.STAGGER, "pre-seal Poise break interrupts gravity")
	_expect(is_equal_approx(boss._gravity_cooldown, boss.config.gravity_interrupt_cooldown), "interrupted gravity uses partial cooldown")
	poise_hit.free()
	await create_timer(0.10).timeout
	# Exercise the production Phase-2 selector, not debug_force_attack. All other
	# formal candidates are put on cooldown so the test proves the saved selector
	# can choose and complete the signature spell through its normal state chain.
	boss.current_state = ThirteenthPontiffEdran.State.IDLE
	boss._action_locked = false
	boss._phase = 2
	boss._phase_02_elapsed = boss.config.gravity_first_cast_delay
	boss._attack_gap_timer = 0.0
	boss._last_magic = ThirteenthPontiffEdran.Attack.FIRE_SPELL
	boss._last_phase_02_attack = ThirteenthPontiffEdran.Attack.FIRE_SPELL
	boss._gravity_cooldown = 0.0
	boss._magic_global_cooldown = 0.0
	boss._post_gravity_pressure_lock = 0.0
	boss._ice_suppression_timer = 0.0
	boss._fire_cooldown = 99.0
	boss._ice_cooldown = 99.0
	boss._mire_cooldown = 99.0
	boss._lightning_cooldown = 99.0
	boss._hollow_toll_cooldown = 99.0
	boss._scripture_burial_cooldown = 99.0
	boss._procession_cooldown = 99.0
	boss._fourteenth_seat_cooldown = 99.0
	player.status_effect_controller.clear_all()
	player.health_component.set_current_health(90)
	boss._start_selected_phase_02_attack(999.0)
	await create_timer(0.25).timeout
	_expect(boss._last_phase_02_attack == ThirteenthPontiffEdran.Attack.WEIGHT_OF_ABSOLUTION, "formal Phase-2 selector chooses Weight of Absolution")
	_expect(player.health_component.current_health == 50, "formal selector cast settles HP through HealthComponent")
	_expect(not boss._action_locked, "formal selector cast completes recovery")


func _expect(condition: bool, message: String) -> void:
	_assertions += 1
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("EDRAN_JUDGMENT_MAGIC | PASS assertions=%d history_delay=1.0 bolts=3 hp_cases=17" % _assertions)
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("EDRAN_JUDGMENT_MAGIC | FAIL count=%d assertions=%d" % [_failures.size(), _assertions])
	quit(1)
