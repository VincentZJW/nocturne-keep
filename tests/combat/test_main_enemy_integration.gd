extends SceneTree

## Saved F5 Main audit: mixed roster, authored activation, live HUD, and latest resources.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const EXPECTED_MAIN_PATH: String = "res://scenes/cinematics/opening_cinematic.tscn"
const GROUP_SIZES: Array[int] = [1, 1, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 3]
const ACTIVATION_POSITIONS: Array[Vector2] = [
	Vector2(930.0, 612.0), Vector2(1220.0, 612.0), Vector2(1480.0, 612.0),
	Vector2(1800.0, 612.0), Vector2(2070.0, 612.0), Vector2(2320.0, 612.0),
	Vector2(2640.0, 612.0), Vector2(2920.0, 612.0), Vector2(3200.0, 612.0),
	Vector2(2780.0, 470.0), Vector2(3500.0, 612.0), Vector2(3820.0, 612.0),
	Vector2(4100.0, 612.0), Vector2(4400.0, 612.0), Vector2(4420.0, 474.0),
	Vector2(4800.0, 612.0), Vector2(5080.0, 612.0), Vector2(5160.0, 478.0),
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "") == EXPECTED_MAIN_PATH,
		"F5 run/main_scene is not the authored opening cinematic"
	)
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	var player: Player = main.get_node_or_null("World/Player") as Player
	var encounters_root: Node2D = main.get_node_or_null("World/Encounters") as Node2D
	_expect(player != null, "Main is missing Player")
	_expect(encounters_root != null, "Main is missing Encounters")
	if player == null or encounters_root == null:
		main.queue_free()
		_finish()
		return
	await _wait_physics_frames(8)
	var groups: Array[EncounterGroup] = _collect_groups(encounters_root)
	var enemies: Array[EnemyCombatant] = _collect_enemies(groups)
	_expect(groups.size() == 18, "Main does not contain eighteen authored encounters")
	_expect(enemies.size() == 34, "Main does not contain thirty-four mixed enemies")
	_test_saved_roster(groups, enemies)
	_test_main_system_wiring(main, player)
	await _test_encounter_activation(player, groups)
	_test_combat_wiring(enemies, player)
	main.queue_free()
	await process_frame
	_finish()


func _test_saved_roster(groups: Array[EncounterGroup], enemies: Array[EnemyCombatant]) -> void:
	var shared_gargoyle_frames: SpriteFrames = load(
		"res://resources/enemies/gargoyle_sentinel_sprite_frames.tres"
	) as SpriteFrames
	for index: int in range(groups.size()):
		_expect(groups[index].get_enemies().size() == GROUP_SIZES[index], "Encounter group size mismatch")
	var counts: Dictionary[StringName, int] = {}
	for enemy: EnemyCombatant in enemies:
		counts[enemy.get_enemy_type_name()] = counts.get(enemy.get_enemy_type_name(), 0) + 1
		_expect(enemy.scene_file_path.begins_with("res://scenes/enemies/"), "%s is not an enemy PackedScene" % enemy.name)
		_expect(enemy.get_health_component() != null, "%s lacks HealthComponent" % enemy.name)
		_expect(enemy.get_node_or_null("Hurtbox") is HurtboxComponent, "%s lacks HurtboxComponent" % enemy.name)
		if enemy is CursedShieldGuard:
			_expect(
				enemy.get_node_or_null("ShieldComponent") is ShieldComponent,
				"%s lacks the independent ShieldComponent" % enemy.name
			)
			_expect(
				enemy.get_node_or_null("FacingRoot/ShieldVisual") is AnimatedSprite2D,
				"%s lacks the independent ShieldVisual" % enemy.name
			)
			_expect(
				enemy.get_node_or_null("FacingRoot/ShieldHitEffect") is AnimatedSprite2D,
				"%s lacks the live ShieldHitEffect" % enemy.name
			)
			_expect(
				enemy.get_node_or_null("FacingRoot/ShieldBreakEffect") is AnimatedSprite2D,
				"%s lacks the live ShieldBreakEffect" % enemy.name
			)
			_expect(
				enemy.get_node_or_null("VisualRoot/GuardBreakMarker") is Sprite2D,
				"%s lacks the live GuardBreakMarker" % enemy.name
			)
		elif enemy is GargoyleSentinel:
			var gargoyle_sprite: AnimatedSprite2D = enemy.get_node_or_null(
				"VisualRoot/AnimatedSprite2D"
			) as AnimatedSprite2D
			_expect(
				gargoyle_sprite != null and gargoyle_sprite.sprite_frames == shared_gargoyle_frames,
				"%s does not use the latest shared Gargoyle SpriteFrames" % enemy.name
			)
		_test_enemy_balance_profile(enemy)
	_expect(counts.get(&"CursedCastleGuard", 0) == 14, "Main Castle Guard count mismatch")
	_expect(counts.get(&"CursedShieldGuard", 0) == 5, "Main Shield Guard count mismatch")
	_expect(counts.get(&"DecayedSpearman", 0) == 6, "Main Spearman count mismatch")
	_expect(counts.get(&"FallenCrossbowman", 0) == 5, "Main Crossbowman count mismatch")
	_expect(counts.get(&"GargoyleSentinel", 0) == 4, "Main Gargoyle count mismatch")
	_expect(
		main_has_platform_crossbow(groups),
		"Main lacks the authored high-platform Crossbowman"
	)


func main_has_platform_crossbow(groups: Array[EncounterGroup]) -> bool:
	for enemy: EnemyCombatant in _collect_enemies(groups):
		if enemy is FallenCrossbowman and enemy.global_position.y < 500.0:
			return true
	return false


func _test_main_system_wiring(main: Node2D, player: Player) -> void:
	_expect(player.player_camera.enabled, "Main Player Camera2D is disabled")
	_expect(
		main.has_node("Interface/DebugHudRoot/EnemyDebugPanel/Content/EnemyScroll/EnemyDebug"),
		"Main mixed-enemy debug overlay is missing"
	)
	var health_hud: PlayerHealthHud = main.get_node_or_null("HUD/HealthContainer") as PlayerHealthHud
	var stamina_hud: PlayerStaminaHud = main.get_node_or_null("HUD") as PlayerStaminaHud
	var respawn: PlayerRespawnController = main.get_node_or_null("PlayerRespawnController") as PlayerRespawnController
	_expect(health_hud != null and health_hud.health_component == player.health_component, "Main Health HUD is not live-bound")
	_expect(stamina_hud != null and stamina_hud.stamina_component == player.stamina_component, "Main Stamina HUD is not live-bound")
	_expect(respawn != null and respawn.player == player, "Main respawn controller is not bound to Player")
	var enemy_debug: MainEnemyDebugOverlay = main.get_node_or_null(
		"Interface/DebugHudRoot/EnemyDebugPanel/Content/EnemyScroll/EnemyDebug"
	) as MainEnemyDebugOverlay
	var debug_controller: MainDebugHudController = main.get_node_or_null(
		"Interface"
	) as MainDebugHudController
	_expect(enemy_debug != null and debug_controller != null, "Main enemy debug controls are incomplete")
	if enemy_debug != null and debug_controller != null:
		debug_controller.set_debug_hud_visible(false)
		_expect(not enemy_debug.visible and not enemy_debug.is_processing(), "Main enemy debug cannot be disabled")
		debug_controller.set_debug_hud_visible(true)
		debug_controller.set_compact_mode(false)
		_expect(_debug_contains_profile(enemy_debug.text, "CursedCastleGuard", "HP 30/30", "DMG 5"), "Main Debug omits current Castle Guard balance")
		_expect(_debug_contains_profile(enemy_debug.text, "CursedShieldGuard", "BODY 50/50", "DMG 8"), "Main Debug omits current Shield Guard body balance")
		_expect(
			_debug_contains_profile(
				enemy_debug.text, "CursedShieldGuard", "SH 30/30", "SHIELD intact"
			),
			"Main Debug omits Shield Guard shield-health fields"
		)
		_expect(_debug_contains_profile(enemy_debug.text, "DecayedSpearman", "HP 50/50", "DMG 10"), "Main Debug omits current Spearman balance")
		_expect(_debug_contains_profile(enemy_debug.text, "FallenCrossbowman", "HP 40/40", "DMG 6"), "Main Debug omits current Crossbowman balance")
		_expect(_debug_contains_profile(enemy_debug.text, "GargoyleSentinel", "HP 30/30", "ANIM"), "Main Debug omits Gargoyle fields")
		debug_controller.set_compact_mode(true)
	player.health_component.take_damage(7)
	player.stamina_component.try_consume_dash()
	_expect(health_hud.health_bar.value == 93.0, "Main Health HUD did not update")
	_expect(stamina_hud.stamina_bar.value == 75.0, "Main Stamina HUD did not update")
	player.health_component.reset_to_full()
	player.stamina_component.reset_to_full()


func _test_encounter_activation(player: Player, groups: Array[EncounterGroup]) -> void:
	for index: int in range(groups.size()):
		_expect(not groups[index].is_activated, "%s activated early" % groups[index].name)
		player.global_position = ACTIVATION_POSITIONS[index]
		await _wait_physics_frames(4)
		_expect(groups[index].is_activated, "%s did not activate on Player entry" % groups[index].name)
		for enemy: EnemyCombatant in groups[index].get_enemies():
			_expect(enemy.is_ai_active(), "%s AI remained paused" % enemy.name)
			enemy.set_ai_active(false)
	var max_alive: int = 0
	for group: EncounterGroup in groups:
		max_alive = maxi(max_alive, group.get_alive_enemy_count())
	_expect(max_alive <= 4, "A Main encounter exceeds the four-enemy cap")


func _test_combat_wiring(enemies: Array[EnemyCombatant], player: Player) -> void:
	var type_occurrences: Dictionary[StringName, int] = {}
	for enemy: EnemyCombatant in enemies:
		var hitbox: HitboxComponent = enemy.get_node_or_null(
			"FacingRoot/DiveHitbox" if enemy is GargoyleSentinel else "FacingRoot/AttackHitbox"
		) as HitboxComponent
		if enemy is FallenCrossbowman:
			_expect((enemy as FallenCrossbowman).projectile_scene != null, "Crossbowman lacks bolt PackedScene")
			_expect(enemy.get_attack_damage() == 6, "Crossbow bolt damage is not six")
		else:
			_expect(hitbox != null, "%s lacks a melee AttackHitbox" % enemy.name)
			_expect(hitbox.faction == &"enemy", "%s melee Hitbox faction mismatch" % enemy.name)
		_expect((enemy.get_node("Hurtbox") as HurtboxComponent).faction == &"enemy", "%s Hurtbox faction mismatch" % enemy.name)
		var enemy_type: StringName = enemy.get_enemy_type_name()
		var occurrence: int = type_occurrences.get(enemy_type, 0)
		type_occurrences[enemy_type] = occurrence + 1
		if enemy is CursedShieldGuard and occurrence == 0:
			_test_main_shield_break(enemy as CursedShieldGuard, player)
		elif enemy is CursedShieldGuard and occurrence == 1:
			_test_main_shield_back_hit(enemy as CursedShieldGuard, player)
		if occurrence < 2:
			var use_dash: bool = occurrence == 1
			_kill_main_enemy_with_player_hitbox(enemy, player, use_dash)
		else:
			enemy.get_health_component().take_damage(enemy.get_health_component().current_health)
		_expect(enemy.is_dead(), "%s did not enter Death in Main" % enemy.name)
		_expect(enemy.find_child("*Ghost*", true, false) == null, "%s Main death created a ghost" % enemy.name)
		var sprite: AnimatedSprite2D = enemy.get_node_or_null(
			"VisualRoot/AnimatedSprite2D"
		) as AnimatedSprite2D
		var expected_death: StringName = &"death"
		if enemy is CursedShieldGuard and (enemy as CursedShieldGuard).is_shield_broken():
			expected_death = &"death_unshielded"
		elif enemy is GargoyleSentinel:
			expected_death = &"death_fall"
		_expect(
			sprite != null and sprite.animation == expected_death,
			"%s did not play the correct Main Death animation" % enemy.name
		)
		if sprite != null:
			sprite.animation_finished.emit()
			if enemy is GargoyleSentinel:
				_expect(sprite.animation == &"death_shatter", "Main Gargoyle did not enter shatter")
				sprite.animation_finished.emit()
			_expect(not enemy.visible, "%s did not complete Main death dissolve cleanup" % enemy.name)


func _test_main_shield_break(shield: CursedShieldGuard, player: Player) -> void:
	shield.set_ai_active(false)
	shield.set_facing_direction(-1.0)
	player.global_position = shield.global_position + Vector2(-34.0, 0.0)
	player.animation_controller.set_facing_left(false)
	var normal_hitbox: HitboxComponent = player.action_controller.attack_hitbox
	for hit_index: int in range(3):
		normal_hitbox.begin_attack(
			18_000 + shield.get_instance_id() + hit_index, 10, 1.0, player
		)
		_expect(normal_hitbox.try_hit(shield.hurtbox), "Main frontal normal Attack did not reach Shield Guard")
		normal_hitbox.end_attack()
		_expect(shield.health_component.current_health == 50, "Main frontal normal Attack damaged body")
		_expect(
			shield.get_shield_current_health() == 20 - hit_index * 10,
			"Main frontal normal Attack did not reduce Shield by ten"
		)
		if hit_index < 2:
			_expect(shield.get_state_name() == &"Block", "Main frontal normal Attack did not enter Block")
			shield._process_enemy_state(0.25)
	_expect(shield.is_shield_broken(), "Three Main normal Attacks did not break Shield")
	_expect(shield.get_state_name() == &"GuardBreak", "Main normal shield break did not enter GuardBreak")
	shield._process_enemy_state(0.66)
	shield.shield_component.reset_shield()
	shield._recover_from_hurt()
	_expect(shield.get_shield_current_health() == 30, "Main Shield reset did not restore 30/30 for Dash route test")
	var dash_hitbox: HitboxComponent = player.action_controller.dash_attack_hitbox
	for hit_index: int in range(2):
		dash_hitbox.begin_attack(
			19_000 + shield.get_instance_id() + hit_index, 20, 1.0, player
		)
		_expect(dash_hitbox.try_hit(shield.hurtbox), "Main frontal Dash Attack did not reach Shield Guard")
		dash_hitbox.end_attack()
		_expect(shield.health_component.current_health == 50, "Main frontal Dash Attack damaged body")
		if hit_index == 0:
			_expect(shield.get_shield_current_health() == 10, "First Main Dash did not reduce Shield 30 to 10")
			shield._process_enemy_state(0.25)
	_expect(shield.is_shield_broken(), "Two Main Dash Attacks did not permanently break the shield")
	_expect(shield.get_state_name() == &"GuardBreak", "Main Shield Guard did not enter GuardBreak")
	_expect(not shield.shield_visual.visible or shield.shield_visual.animation == &"shield_break", "Main ShieldVisual did not begin break presentation")
	_expect(shield.shield_break_effect.visible, "Main Shield Guard break effect did not become visible")
	_expect(shield.guard_break_marker.visible, "Main Shield Guard break marker did not become visible")
	_expect(shield.shield_break_effect.scale == Vector2(2.0, 2.0), "Main break effect is not enlarged")
	_expect(shield.health_component.current_health == 50, "Main GuardBreak incorrectly dealt Dash overflow damage")
	var breaking_attack_id: int = dash_hitbox.attack_id
	_expect(
		shield.shield_component.resolve_damage(dash_hitbox) == 0,
		"Main breaking Dash id was accepted again after shield removal"
	)
	_expect(shield.shield_component.last_duplicate_blocked, "Main duplicate Dash was not reported")
	_expect(shield.health_component.current_health == 50, "Main duplicate breaking Dash damaged body")
	_expect(dash_hitbox.attack_id == breaking_attack_id, "Main breaking Dash id changed unexpectedly")
	_expect(
		shield.get_debug_summary().contains("BLOCK OFF")
		and shield.get_debug_summary().contains("SH 0/30")
		and shield.get_debug_summary().contains("SHIELD broken"),
		"Main Shield Guard Debug did not expose zero/broken Shield"
	)
	shield._process_enemy_state(0.64)
	_expect(shield.get_state_name() == &"GuardBreak", "Main GuardBreak ended before 0.65 seconds")
	_expect(shield.guard_break_marker.visible, "Main break marker vanished before GuardBreak ended")
	shield._process_enemy_state(0.02)
	_expect(not shield.is_blocking(), "Main Shield Guard restored Block after GuardBreak")
	_expect(not shield.guard_break_marker.visible, "Main break marker remained after GuardBreak")
	_expect(
		shield.animated_sprite.animation == &"walk_unshielded",
		"Main Shield Guard did not recover into the unshielded visual state"
	)
	normal_hitbox.begin_attack(19_100 + shield.get_instance_id(), 10, 1.0, player)
	_expect(normal_hitbox.try_hit(shield.hurtbox), "Main post-break frontal normal Attack was rejected")
	normal_hitbox.end_attack()
	_expect(shield.health_component.current_health == 40, "Main post-break frontal normal Attack did not deal damage")
	shield.health_component.reset_to_full()
	shield._recover_from_hurt()


func _test_main_shield_back_hit(shield: CursedShieldGuard, player: Player) -> void:
	shield.set_ai_active(false)
	shield.set_facing_direction(-1.0)
	player.global_position = shield.global_position + Vector2(34.0, 0.0)
	player.animation_controller.set_facing_left(true)
	var normal_hitbox: HitboxComponent = player.action_controller.attack_hitbox
	normal_hitbox.begin_attack(19_200 + shield.get_instance_id(), 10, -1.0, player)
	_expect(normal_hitbox.try_hit(shield.hurtbox), "Main Shield Guard back Attack was rejected")
	normal_hitbox.end_attack()
	_expect(shield.health_component.current_health == 40, "Main Shield Guard back Attack was blocked")
	_expect(shield.get_shield_current_health() == 30, "Main back Attack incorrectly damaged Shield")
	_expect(not shield.is_shield_broken(), "Main back Attack incorrectly broke the shield")
	shield.health_component.reset_to_full()
	shield._recover_from_hurt()


func _kill_main_enemy_with_player_hitbox(
	enemy: EnemyCombatant,
	player: Player,
	use_dash: bool
) -> void:
	var hitbox: HitboxComponent = (
		player.action_controller.dash_attack_hitbox
		if use_dash
		else player.action_controller.attack_hitbox
	)
	var expected_hits: int = _get_expected_main_kill_count(enemy.get_enemy_type_name(), use_dash)
	var damage: int = 20 if use_dash else 10
	if enemy is CursedShieldGuard:
		var shield_enemy: CursedShieldGuard = enemy as CursedShieldGuard
		shield_enemy.set_facing_direction(-1.0)
		player.global_position = shield_enemy.global_position + Vector2(34.0, 0.0)
		player.animation_controller.set_facing_left(true)
	var hit_count: int = 0
	while enemy.get_health_component().current_health > 0 and hit_count < 32:
		hitbox.begin_attack(
			20_000 + enemy.get_instance_id() + hit_count,
			damage,
			-1.0 if enemy is CursedShieldGuard else 0.0,
			player
		)
		_expect(
			hitbox.try_hit(enemy.get_node("Hurtbox") as HurtboxComponent),
			"%s Main Player hit %d was rejected" % [enemy.name, hit_count + 1]
		)
		hitbox.end_attack()
		hit_count += 1
	_expect(
		hit_count == expected_hits,
		"%s Main required %d %s hits instead of %d" % [
			enemy.name, hit_count, "Dash" if use_dash else "normal", expected_hits,
		]
	)


func _get_expected_main_kill_count(enemy_type: StringName, use_dash: bool) -> int:
	match enemy_type:
		&"CursedCastleGuard":
			return 2 if use_dash else 3
		&"CursedShieldGuard":
			return 3 if use_dash else 5
		&"DecayedSpearman":
			return 3 if use_dash else 5
		&"FallenCrossbowman":
			return 2 if use_dash else 4
		&"GargoyleSentinel":
			return 2 if use_dash else 3
		_:
			return 0


func _test_enemy_balance_profile(enemy: EnemyCombatant) -> void:
	var expected_health: int = 0
	var expected_damage: int = 0
	match enemy.get_enemy_type_name():
		&"CursedCastleGuard":
			expected_health = 30
			expected_damage = 5
		&"CursedShieldGuard":
			expected_health = 50
			expected_damage = 8
		&"DecayedSpearman":
			expected_health = 50
			expected_damage = 10
		&"FallenCrossbowman":
			expected_health = 40
			expected_damage = 6
		&"GargoyleSentinel":
			expected_health = 30
			expected_damage = 7
		_:
			_expect(false, "Unknown Main enemy type %s" % enemy.get_enemy_type_name())
			return
	_expect(enemy.get_health_component().max_health == expected_health, "%s Main HP mismatch" % enemy.name)
	_expect(enemy.get_attack_damage() == expected_damage, "%s Main damage mismatch" % enemy.name)


func _debug_contains_profile(
	debug_text: String,
	enemy_type: String,
	health_text: String,
	damage_text: String
) -> bool:
	for line: String in debug_text.split("\n"):
		if line.contains(enemy_type):
			return line.contains(health_text) and line.contains(damage_text)
	return false


func _collect_groups(root: Node2D) -> Array[EncounterGroup]:
	var groups: Array[EncounterGroup] = []
	for child: Node in root.get_children():
		var group: EncounterGroup = child as EncounterGroup
		if group != null:
			groups.append(group)
	return groups


func _collect_enemies(groups: Array[EncounterGroup]) -> Array[EnemyCombatant]:
	var enemies: Array[EnemyCombatant] = []
	for group: EncounterGroup in groups:
		enemies.append_array(group.get_enemies())
	return enemies


func _wait_physics_frames(count: int) -> void:
	for _index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("MAIN_ENEMY_INTEGRATION_TEST: PASS (18 groups, 34 mixed enemies, Boss room, HUD/respawn)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("MAIN_ENEMY_INTEGRATION_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
