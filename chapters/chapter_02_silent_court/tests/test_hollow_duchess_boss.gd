extends SceneTree

const TEST_ROOM: String = "res://chapters/chapter_02_silent_court/scenes/tests/hollow_duchess_test_room.tscn"
const ATTACKS: Array[StringName] = [
	&"rapier_thrust", &"fan_slash", &"backstep_riposte", &"side_step_cut",
	&"flying_fan", &"double_waltz_lunge", &"phantom_dancer_sweep", &"final_waltz_crossing",
]

var _failures: Array[String] = []
var _started_counts: Dictionary[StringName, int] = {}
var _active_counts: Dictionary[StringName, int] = {}
var _finished_counts: Dictionary[StringName, int] = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 12.0
	var packed: PackedScene = ResourceLoader.load(TEST_ROOM, "PackedScene") as PackedScene
	if packed == null:
		_fail("Boss test room does not load")
		_finish()
		return
	var room: Node = packed.instantiate()
	root.add_child(room)
	current_scene = room
	for _frame: int in range(12):
		await physics_frame
	var boss: HollowDuchess = room.get_node_or_null("HollowDuchess") as HollowDuchess
	var player: Player = room.get_node_or_null("Player") as Player
	if boss == null or player == null:
		_fail("Boss or Player is missing from standalone test room")
		_finish()
		return
	# Keep the target alive so the deterministic attack audit tests
	# Seraphine's state machine instead of eventually idling on a dead player.
	player.hurtbox.set_invulnerable(true)
	boss.attack_started.connect(_on_attack_started)
	boss.attack_active.connect(_on_attack_active)
	boss.attack_finished.connect(_on_attack_finished)
	_validate_config(boss)
	await _wait_until_combat_ready(boss)
	_validate_distance_selection(boss, player)
	for attack_name: StringName in ATTACKS:
		for _iteration: int in range(10):
			if not boss.debug_force_attack(attack_name):
				_fail("Could not force %s" % attack_name)
				continue
			if _iteration == 0 and attack_name == &"flying_fan":
				await _validate_flying_fan_runtime(boss)
			elif _iteration == 0 and attack_name == &"phantom_dancer_sweep":
				await _validate_marionette_runtime(boss)
			await _wait_for_attack_completion(boss, attack_name)
		print("HOLLOW_DUCHESS_ATTACK_CYCLES: %s x10" % attack_name)
		if _started_counts.get(attack_name, 0) != 10:
			_fail("%s start count != 10" % attack_name)
		if _active_counts.get(attack_name, 0) < 10:
			_fail("%s active count < 10" % attack_name)
		if _finished_counts.get(attack_name, 0) != 10:
			_fail("%s finish count != 10" % attack_name)
	await _validate_marionette_repetition(boss)
	await _validate_phase_and_poise(boss, player)
	Engine.time_scale = 1.0
	_finish()


func _validate_config(boss: HollowDuchess) -> void:
	var config: HollowDuchessConfig = boss.config
	_expect(is_equal_approx(boss.BEHAVIOR_REACTION_DELAY, 0.28), "Duchess behavior reaction delay must be 0.28s")
	_expect(boss.get_behavior_pressures().size() == 6, "Duchess exposes six decaying behavior pressures")
	var base_curtain: float = boss._adaptive_attack_multiplier(boss.ATTACK_SIDE_CUT)
	boss.crossup_pressure = 0.8
	var learned_curtain: float = boss._adaptive_attack_multiplier(boss.ATTACK_SIDE_CUT)
	_expect(learned_curtain > base_curtain, "Silk Curtain responds to delayed cross-up pressure")
	_expect(learned_curtain <= 2.65, "Duchess adaptive weighting remains capped")
	boss._reset_behavior_context()
	_expect(config.max_health == 220, "max HP must be 220")
	_expect(is_equal_approx(config.phase_2_threshold, 0.55), "phase threshold must be 55%")
	_expect(config.max_poise == 60, "max Poise must be 60")
	_expect(config.phase_2_max_poise == 80, "Phase 2 max Poise must be 80")
	_expect(is_equal_approx(config.phase_2_incoming_damage_multiplier, 0.85), "Phase 2 mitigation mismatch")
	_expect(is_equal_approx(boss.get_turn_total_duration(), 0.58), "turn total must be 0.58s")
	_expect(config.rapier_thrust_damage == 11, "Rapier damage mismatch")
	_expect(config.fan_slash_damage == 13, "Fan damage mismatch")
	_expect(config.riposte_damage == 12, "Riposte damage mismatch")
	_expect(config.side_step_cut_damage == 12, "Side Cut damage mismatch")
	_expect(config.phase_2_rapier_thrust_damage == 13, "Phase 2 Rapier damage mismatch")
	_expect(config.phase_2_fan_slash_damage == 16, "Phase 2 Fan damage mismatch")
	_expect(config.phase_2_riposte_damage == 14, "Phase 2 Riposte damage mismatch")
	_expect(config.phase_2_side_step_cut_damage == 14, "Phase 2 Side Cut damage mismatch")
	_expect(config.double_lunge_damage_1 == 10 and config.double_lunge_damage_2 == 14, "Double Lunge damage mismatch")
	_expect(config.flying_fan_damage == 16, "Flying Fan damage mismatch")
	_expect(is_equal_approx(config.flying_fan_windup, 0.72), "Flying Fan windup mismatch")
	_expect(is_equal_approx(config.flying_fan_recovery, 0.72), "Flying Fan recovery mismatch")
	_expect(config.phantom_damage == 42, "Marionette Guillotine damage mismatch")
	_expect(is_equal_approx(config.phantom_telegraph, 1.35), "Marionette telegraph mismatch")
	_expect(is_equal_approx(config.phantom_active, 0.82), "Marionette crossing duration mismatch")
	_expect(is_equal_approx(config.phantom_recovery, 1.25), "Marionette recovery mismatch")
	_expect(is_equal_approx(config.phantom_dance_cooldown, 9.0), "Marionette cooldown mismatch")
	_expect(config.phantom_min_other_attacks == 2, "Marionette attack-spacing rule mismatch")
	_expect(config.phantom_hitbox_size == Vector2(40.0, 34.0), "Marionette compact hitbox mismatch")
	_validate_marionette_art_scale()
	var movement: PlayerMovementConfig = load(
		"res://resources/player/player_movement_config.tres"
	) as PlayerMovementConfig
	var one_jump_height: float = (
		movement.jump_velocity * movement.jump_velocity / (2.0 * movement.gravity)
	)
	# The hit volume rises 34 px above the ballroom baseline. The Player's feet
	# extend roughly 27 px below its origin, so two authored jumps leave a clear
	# vertical safety margin while a single jump remains deliberately tight.
	var double_jump_clearance: float = one_jump_height * 2.0 - 27.0 - config.phantom_hitbox_size.y
	_expect(double_jump_clearance >= 70.0, "Marionette lane lacks double-jump clearance")
	print("MARIONETTE_DOUBLE_JUMP_CLEARANCE: %.2f px" % double_jump_clearance)
	_expect(config.final_waltz_damage == 10, "Final Waltz damage mismatch")
	_expect(config.rapier_thrust_windup >= 0.46 and config.rapier_thrust_recovery >= 0.60, "Rapier timing mismatch")
	_expect(config.fan_slash_windup >= 0.54 and config.fan_slash_recovery >= 0.72, "Fan timing mismatch")
	_expect(config.phase_1_min_attack_gap >= 0.84, "Phase 1 gap too short")
	_expect(is_equal_approx(config.phase_2_min_attack_gap, 0.82), "Phase 2 minimum gap mismatch")
	_expect(is_equal_approx(config.phase_2_max_attack_gap, 1.02), "Phase 2 maximum gap mismatch")


func _validate_distance_selection(boss: HollowDuchess, player: Player) -> void:
	var original_phase: int = boss._phase
	var original_position: Vector2 = player.global_position
	var original_target: Player = boss._target
	boss._phase = 2
	boss._target = player
	boss._rng.seed = 20260818
	boss.far_pressure = 0.60
	player.global_position = boss.global_position + Vector2(260.0, 0.0)
	var flying_fan_count: int = 0
	var far_phantom_count: int = 0
	var ranged_count: int = 0
	for _sample: int in range(30):
		boss._flying_fan_cooldown = 0.0
		boss._phantom_cooldown = 0.0
		boss._attacks_since_phantom = boss.config.phantom_min_other_attacks
		var selected: StringName = boss._select_attack(260.0)
		if selected == boss.ATTACK_FLYING_FAN:
			flying_fan_count += 1
		if selected == boss.ATTACK_PHANTOM:
			far_phantom_count += 1
		if selected in [boss.ATTACK_FLYING_FAN, boss.ATTACK_PHANTOM]:
			ranged_count += 1
		if not selected.is_empty():
			boss._same_attack_count = boss._same_attack_count + 1 if boss._last_attack == selected else 1
			boss._last_attack = selected
	_expect(far_phantom_count >= 6 and far_phantom_count <= 11, "30 far decisions selected Marionette %d times (target 6-11)" % far_phantom_count)
	_expect(ranged_count >= 16 and ranged_count <= 25, "30 far decisions selected ranged attacks %d times (target 16-25)" % ranged_count)
	print("HOLLOW_DUCHESS_FAR_SELECTION: samples=30 flying_fan=%d marionette=%d ranged=%d" % [flying_fan_count, far_phantom_count, ranged_count])
	# Mid distance must sit between close and far Marionette pressure.
	boss._rng.seed = 20260819
	boss.far_pressure = 0.0
	boss.close_pressure = 0.0
	boss._last_attack = &""
	boss._same_attack_count = 0
	player.global_position = boss.global_position + Vector2(160.0, 0.0)
	var mid_phantom_count: int = 0
	for _sample: int in range(30):
		boss._flying_fan_cooldown = 0.0
		boss._phantom_cooldown = 0.0
		boss._attacks_since_phantom = boss.config.phantom_min_other_attacks
		var selected: StringName = boss._select_attack(160.0)
		if selected == boss.ATTACK_PHANTOM:
			mid_phantom_count += 1
		if not selected.is_empty():
			boss._same_attack_count = boss._same_attack_count + 1 if boss._last_attack == selected else 1
			boss._last_attack = selected
	# Close range keeps Flying Fan legal but deliberately uncommon.  This proves
	# the selector is weighted by distance rather than hard-coded to one skill.
	boss._rng.seed = 20260818
	boss.far_pressure = 0.0
	boss.close_pressure = 0.60
	boss._last_attack = &""
	boss._same_attack_count = 0
	player.global_position = boss.global_position + Vector2(50.0, 0.0)
	var close_fan_count: int = 0
	var close_phantom_count: int = 0
	for _sample: int in range(30):
		boss._flying_fan_cooldown = 0.0
		boss._phantom_cooldown = 0.0
		boss._attacks_since_phantom = boss.config.phantom_min_other_attacks
		var selected: StringName = boss._select_attack(50.0)
		if selected == boss.ATTACK_FLYING_FAN:
			close_fan_count += 1
		if selected == boss.ATTACK_PHANTOM:
			close_phantom_count += 1
		if not selected.is_empty():
			boss._same_attack_count = boss._same_attack_count + 1 if boss._last_attack == selected else 1
			boss._last_attack = selected
	_expect(close_fan_count <= 6, "30 close decisions selected Flying Fan %d times (maximum 6)" % close_fan_count)
	_expect(close_fan_count < flying_fan_count, "Close range did not reduce Flying Fan selection")
	_expect(close_phantom_count < mid_phantom_count and mid_phantom_count < far_phantom_count, "Marionette distance weighting is not Close < Mid < Far")
	print("HOLLOW_DUCHESS_DISTANCE_SELECTION: close_marionette=%d mid_marionette=%d far_marionette=%d close_fan=%d" % [close_phantom_count, mid_phantom_count, far_phantom_count, close_fan_count])
	# Ten seconds at Far must build pressure after the 0.28-second observation
	# delay; returning Close for ten seconds must decay that old evidence.
	boss._reset_behavior_context()
	player.global_position = boss.global_position + Vector2(260.0, 0.0)
	for _sample: int in range(50):
		boss._observe_target_behavior(0.20)
	var learned_far_pressure: float = boss.far_pressure
	_expect(learned_far_pressure >= 0.50, "Ten seconds at Far did not build far pressure")
	player.global_position = boss.global_position + Vector2(50.0, 0.0)
	for _sample: int in range(50):
		boss._observe_target_behavior(0.20)
	_expect(boss.far_pressure <= 0.05, "Far pressure did not decay after ten close seconds")
	_expect(boss.close_pressure >= 0.50, "Ten close seconds did not build close pressure")
	print("HOLLOW_DUCHESS_PRESSURE_SWITCH: far_peak=%.2f far_after_close=%.2f close=%.2f" % [learned_far_pressure, boss.far_pressure, boss.close_pressure])
	boss._phase = original_phase
	boss._target = original_target
	boss._last_attack = &""
	boss._same_attack_count = 0
	boss._reset_behavior_context()
	player.global_position = original_position


func _validate_flying_fan_runtime(boss: HollowDuchess) -> void:
	await _wait_for_state(boss, &"FlyingFanActive", 120)
	_expect(boss._active_flying_fans.size() == 1, "Flying Fan projectile was not created")
	if boss._active_flying_fans.is_empty():
		return
	var fan: HitboxComponent = boss._active_flying_fans[0]
	_expect(fan.attack_kind == &"boss_flying_fan", "Flying Fan attack kind mismatch")
	_expect(fan.damage == 16, "Flying Fan projectile damage mismatch")
	var sprite: Sprite2D = fan.get_node_or_null("BladedFanVisual") as Sprite2D
	_expect(sprite != null and sprite.texture != null, "Flying Fan lacks formal pixel visual")
	if sprite != null and sprite.texture != null:
		_expect(sprite.texture.get_size() == Vector2(32.0, 32.0), "Flying Fan pixel texture size mismatch")


func _validate_marionette_art_scale() -> void:
	var puppet_texture: Texture2D = load("res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/effects/phantom_dancer.png") as Texture2D
	var duchess_texture: Texture2D = load("res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/phase_02_unmasked/phase_02_idle/phase_02_idle_01.png") as Texture2D
	var player_texture: Texture2D = load("res://shared/assets/player/animations/ravenfang/idle/idle_01.png") as Texture2D
	var puppet: Image = puppet_texture.get_image()
	var duchess: Image = duchess_texture.get_image()
	var player: Image = player_texture.get_image()
	var puppet_bounds: Rect2i = _alpha_bounds(puppet, Rect2i(0, 0, 192, 192))
	var duchess_bounds: Rect2i = _alpha_bounds(duchess, Rect2i(0, 0, duchess.get_width(), duchess.get_height()))
	var player_bounds: Rect2i = _alpha_bounds(player, Rect2i(0, 0, player.get_width(), player.get_height()))
	var boss_ratio: float = float(puppet_bounds.size.y) / float(duchess_bounds.size.y)
	var player_ratio: float = float(puppet_bounds.size.y) / float(player_bounds.size.y)
	_expect(boss_ratio >= 0.648 and boss_ratio <= 0.78, "Marionette height is not approximately 65-78%% of Duchess")
	_expect(player_ratio >= 0.90 and player_ratio <= 1.10, "Marionette height is not 90-110%% of Player")
	print("MARIONETTE_ART_SCALE: puppet=%s duchess=%s player=%s boss_ratio=%.3f player_ratio=%.3f" % [puppet_bounds, duchess_bounds, player_bounds, boss_ratio, player_ratio])


func _alpha_bounds(image: Image, region: Rect2i) -> Rect2i:
	var minimum: Vector2i = Vector2i(region.end.x, region.end.y)
	var maximum: Vector2i = Vector2i(region.position.x - 1, region.position.y - 1)
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			if image.get_pixel(x, y).a > 0.05:
				minimum.x = mini(minimum.x, x)
				minimum.y = mini(minimum.y, y)
				maximum.x = maxi(maximum.x, x)
				maximum.y = maxi(maximum.y, y)
	if maximum.x < minimum.x:
		return Rect2i()
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)


func _validate_marionette_runtime(boss: HollowDuchess) -> void:
	await _wait_for_state(boss, &"PhantomDancePrepare", 120)
	_expect(boss._active_phantoms.size() == 2, "Marionette Guillotine did not create two puppets")
	if boss._active_phantoms.size() != 2:
		return
	var first: DuchessPhantomRoute = boss._active_phantoms[0]
	var second: DuchessPhantomRoute = boss._active_phantoms[1]
	_expect(first._attack_id == second._attack_id and first._attack_id > 0, "Marionettes do not share one attack ID")
	_expect(first.hitbox.attack_kind == &"boss_marionette_guillotine", "Marionette attack kind mismatch")
	_expect(first._damage == 42 and second._damage == 42, "Marionette damage mismatch")
	_expect(first.phantom.region_rect.position.x != second.phantom.region_rect.position.x, "Marionette variants are not visually distinct")
	var first_shape: RectangleShape2D = first.collision_shape.shape as RectangleShape2D
	_expect(first_shape != null and first_shape.size == boss.config.phantom_hitbox_size, "Marionette hit zone mismatch")
	var target_root: Node2D = Node2D.new()
	var target_health: HealthComponent = HealthComponent.new()
	var target_hurtbox: HurtboxComponent = HurtboxComponent.new()
	target_health.name = "HealthComponent"
	target_health.max_health = 100
	target_hurtbox.name = "Hurtbox"
	target_hurtbox.faction = &"player"
	target_hurtbox.health_component_path = NodePath("../HealthComponent")
	target_root.add_child(target_health)
	target_root.add_child(target_hurtbox)
	boss.get_parent().add_child(target_root)
	await physics_frame
	first.hitbox.begin_attack(first._attack_id, first._damage, 1.0, boss)
	second.hitbox.begin_attack(second._attack_id, second._damage, -1.0, boss)
	_expect(first.hitbox.try_hit(target_hurtbox), "First Marionette could not settle its shared hit")
	_expect(target_health.current_health == 58, "Marionette did not settle exactly 42 damage")
	_expect(not second.hitbox.try_hit(target_hurtbox), "Second Marionette bypassed shared target ledger")
	_expect(target_health.current_health == 58, "Marionette pair applied damage more than once")
	first.hitbox.end_attack()
	second.hitbox.end_attack()
	target_root.queue_free()


func _validate_marionette_repetition(boss: HollowDuchess) -> void:
	for iteration: int in range(20):
		if not boss.debug_force_attack(&"phantom_dancer_sweep"):
			_fail("Marionette repetition %d could not start" % (iteration + 1))
			continue
		await _wait_for_state(boss, &"PhantomDancePrepare", 120)
		_expect(
			boss._active_phantoms.size() == 2,
			"Marionette repetition %d did not create two puppets" % (iteration + 1)
		)
		await _wait_for_attack_completion(boss, &"phantom_dancer_sweep")
	print("MARIONETTE_GUILLOTINE_CYCLES: PASS triggers=20 paired_routes=true")


func _wait_for_state(boss: HollowDuchess, state_name: StringName, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await physics_frame
		if boss.get_state_name() == state_name:
			return
	_fail("Boss did not reach %s" % state_name)


func _wait_until_combat_ready(boss: HollowDuchess) -> void:
	for _frame: int in range(240):
		await physics_frame
		if boss.get_state_name() not in [&"Dormant", &"Intro"]:
			return
	_fail("Boss did not leave Intro")


func _wait_for_attack_completion(boss: HollowDuchess, attack_name: StringName) -> void:
	var observed_start: bool = false
	for _frame: int in range(720):
		await physics_frame
		if boss.get_current_attack() == attack_name:
			observed_start = true
		if observed_start and boss.get_current_attack().is_empty():
			return
	_fail("%s did not complete" % attack_name)


func _validate_phase_and_poise(boss: HollowDuchess, player: Player) -> void:
	boss.reset_boss()
	boss.config.intro_retry_duration = 0.05
	boss.activate(player, true)
	await _wait_until_combat_ready(boss)
	boss.debug_set_health(121)
	for _frame: int in range(180):
		await physics_frame
		if boss.get_phase() == 2:
			break
	_expect(boss.get_phase() == 2, "Phase 2 did not activate at 121 HP")
	_expect(boss.health_component.current_health == 121, "Phase transition restored HP")
	_expect(boss.get_current_poise() == 80, "Phase 2 Poise did not increase to 80")
	_expect(boss.is_phase_transition_completed(), "Phase transition completion flag missing")
	_expect(boss.get_current_attack() == &"phantom_dancer_sweep", "Phase 2 did not open with the formal Marionette Guillotine attack")
	var mitigation_probe: HitboxComponent = HitboxComponent.new()
	mitigation_probe.damage = 20
	_expect(boss.hurtbox.hit_policy.resolve_damage(mitigation_probe) == 17, "Phase 2 damage reduction is not 15%")
	mitigation_probe.queue_free()
	boss.reset_boss()
	boss.config.intro_retry_duration = 0.05
	boss.activate(player, true)
	await _wait_until_combat_ready(boss)
	var normal_hit: HitboxComponent = HitboxComponent.new()
	normal_hit.attack_kind = &"normal_attack"
	for index: int in range(6):
		boss._on_hit_resolving(normal_hit)
		boss._on_hit_received(12, player.global_position, 100 + index)
	_expect(boss.get_current_poise() == 0, "Six normal attacks should exhaust 60 Poise")
	_expect(boss.get_state_name() == &"Stagger", "Poise exhaustion did not enter Stagger")
	for _frame: int in range(10):
		await physics_frame
	_expect(boss.get_current_poise() == 60, "Poise did not restore after Stagger")
	normal_hit.queue_free()


func _on_attack_started(attack_name: StringName) -> void:
	_started_counts[attack_name] = _started_counts.get(attack_name, 0) + 1


func _on_attack_active(attack_name: StringName, _attack_id: int) -> void:
	_active_counts[attack_name] = _active_counts.get(attack_name, 0) + 1


func _on_attack_finished(attack_name: StringName) -> void:
	_finished_counts[attack_name] = _finished_counts.get(attack_name, 0) + 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("HOLLOW_DUCHESS_BOSS_TEST: PASS attacks=8 iterations=80 phase=2 poise=60")
		quit(0)
		return
	for failure: String in _failures:
		push_error("HOLLOW_DUCHESS_BOSS_TEST: %s" % failure)
	quit(1)
