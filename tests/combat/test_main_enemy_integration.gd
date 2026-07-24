extends SceneTree

## Saved F5 Main audit: mixed roster, authored activation, live HUD, and latest resources.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const EXPECTED_MAIN_PATH: String = "res://scenes/main/main.tscn"
const GROUP_SIZES: Array[int] = [2, 2, 2, 3]
const ACTIVATION_POSITIONS: Array[Vector2] = [
	Vector2(430.0, 612.0), Vector2(850.0, 612.0),
	Vector2(1300.0, 612.0), Vector2(1840.0, 612.0),
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "") == EXPECTED_MAIN_PATH,
		"F5 run/main_scene is not the authored Main"
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
	_expect(groups.size() == 4, "Main does not contain four authored encounters")
	_expect(enemies.size() == 9, "Main does not contain nine mixed enemies")
	_test_saved_roster(groups, enemies)
	_test_main_system_wiring(main, player)
	await _test_encounter_activation(player, groups)
	_test_combat_wiring(enemies, player)
	main.queue_free()
	await process_frame
	_finish()


func _test_saved_roster(groups: Array[EncounterGroup], enemies: Array[EnemyCombatant]) -> void:
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
				enemy.get_node_or_null("FacingRoot/ShieldBreakEffect") is AnimatedSprite2D,
				"%s lacks the live ShieldBreakEffect" % enemy.name
			)
		_test_enemy_balance_profile(enemy)
	_expect(counts.get(&"CursedCastleGuard", 0) == 3, "Main Castle Guard count mismatch")
	_expect(counts.get(&"CursedShieldGuard", 0) == 2, "Main Shield Guard count mismatch")
	_expect(counts.get(&"DecayedSpearman", 0) == 2, "Main Spearman count mismatch")
	_expect(counts.get(&"FallenCrossbowman", 0) == 2, "Main Crossbowman count mismatch")
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
		_expect(_debug_contains_profile(enemy_debug.text, "CursedCastleGuard", "HP 3/3", "DMG 5"), "Main Debug omits current Castle Guard balance")
		_expect(_debug_contains_profile(enemy_debug.text, "CursedShieldGuard", "HP 7/7", "DMG 8"), "Main Debug omits current Shield Guard balance")
		_expect(
			_debug_contains_profile(
				enemy_debug.text, "CursedShieldGuard", "BLOCK ON", "SHIELD BROKEN false"
			),
			"Main Debug omits Shield Guard block/broken fields"
		)
		_expect(_debug_contains_profile(enemy_debug.text, "DecayedSpearman", "HP 5/5", "DMG 10"), "Main Debug omits current Spearman balance")
		_expect(_debug_contains_profile(enemy_debug.text, "FallenCrossbowman", "HP 4/4", "DMG 6"), "Main Debug omits current Crossbowman balance")
		debug_controller.set_compact_mode(true)
	player.health_component.take_damage(7)
	player.stamina_component.try_consume_dash()
	_expect(health_hud.health_bar.value == 93.0, "Main Health HUD did not update")
	_expect(stamina_hud.stamina_bar.value == 75.0, "Main Stamina HUD did not update")
	player.health_component.reset_to_full()
	player.stamina_component.reset_to_full()


func _test_encounter_activation(player: Player, groups: Array[EncounterGroup]) -> void:
	_expect(groups[0].is_activated, "Spawn encounter did not activate")
	for index: int in range(1, groups.size()):
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
	_expect(max_alive <= 3, "A Main encounter exceeds the three-enemy cap")


func _test_combat_wiring(enemies: Array[EnemyCombatant], player: Player) -> void:
	var type_occurrences: Dictionary[StringName, int] = {}
	for enemy: EnemyCombatant in enemies:
		var hitbox: HitboxComponent = enemy.get_node_or_null("FacingRoot/AttackHitbox") as HitboxComponent
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
		var expected_death: StringName = (
			&"death_unshielded"
			if enemy is CursedShieldGuard and (enemy as CursedShieldGuard).is_shield_broken()
			else &"death"
		)
		_expect(
			sprite != null and sprite.animation == expected_death,
			"%s did not play the correct Main Death animation" % enemy.name
		)
		if sprite != null:
			sprite.animation_finished.emit()
			_expect(not enemy.visible, "%s did not complete Main death dissolve cleanup" % enemy.name)


func _test_main_shield_break(shield: CursedShieldGuard, player: Player) -> void:
	shield.set_ai_active(false)
	shield.set_facing_direction(-1.0)
	var normal_hitbox: HitboxComponent = player.action_controller.attack_hitbox
	normal_hitbox.global_position = shield.global_position + Vector2(-30.0, 0.0)
	normal_hitbox.begin_attack(18_000 + shield.get_instance_id(), 1)
	_expect(normal_hitbox.try_hit(shield.hurtbox), "Main frontal normal Attack did not reach Shield Guard")
	normal_hitbox.end_attack()
	_expect(shield.health_component.current_health == 7, "Main frontal normal Attack bypassed Block")
	_expect(shield.get_state_name() == &"Block", "Main frontal normal Attack did not enter Block")
	var dash_hitbox: HitboxComponent = player.action_controller.dash_attack_hitbox
	dash_hitbox.global_position = shield.global_position + Vector2(-32.0, 0.0)
	dash_hitbox.begin_attack(19_000 + shield.get_instance_id(), 2)
	_expect(dash_hitbox.try_hit(shield.hurtbox), "Main frontal Dash Attack did not reach Shield Guard")
	dash_hitbox.end_attack()
	_expect(shield.is_shield_broken(), "Main frontal Dash Attack did not permanently break the shield")
	_expect(shield.get_state_name() == &"GuardBreak", "Main Shield Guard did not enter GuardBreak")
	_expect(shield.shield_break_effect.visible, "Main Shield Guard break effect did not become visible")
	_expect(shield.health_component.current_health == 7, "Main GuardBreak incorrectly dealt Dash damage")
	_expect(
		shield.get_debug_summary().contains("BLOCK OFF")
		and shield.get_debug_summary().contains("SHIELD BROKEN true"),
		"Main Shield Guard Debug did not expose the broken state"
	)
	shield._process_enemy_state(0.69)
	_expect(shield.get_state_name() == &"GuardBreak", "Main GuardBreak ended before 0.70 seconds")
	shield._process_enemy_state(0.02)
	_expect(not shield.is_blocking(), "Main Shield Guard restored Block after GuardBreak")
	_expect(
		shield.animated_sprite.animation == &"walk_unshielded",
		"Main Shield Guard did not recover into the unshielded visual state"
	)
	normal_hitbox.begin_attack(19_100 + shield.get_instance_id(), 1)
	_expect(normal_hitbox.try_hit(shield.hurtbox), "Main post-break frontal normal Attack was rejected")
	normal_hitbox.end_attack()
	_expect(shield.health_component.current_health == 6, "Main post-break frontal normal Attack did not deal damage")
	shield.health_component.reset_to_full()
	shield._recover_from_hurt()


func _test_main_shield_back_hit(shield: CursedShieldGuard, player: Player) -> void:
	shield.set_ai_active(false)
	shield.set_facing_direction(-1.0)
	var normal_hitbox: HitboxComponent = player.action_controller.attack_hitbox
	normal_hitbox.global_position = shield.global_position + Vector2(30.0, 0.0)
	normal_hitbox.begin_attack(19_200 + shield.get_instance_id(), 1)
	_expect(normal_hitbox.try_hit(shield.hurtbox), "Main Shield Guard back Attack was rejected")
	normal_hitbox.end_attack()
	_expect(shield.health_component.current_health == 6, "Main Shield Guard back Attack was blocked")
	_expect(not shield.is_shield_broken(), "Main back Attack incorrectly broke the shield")
	shield.health_component.reset_to_full()
	shield._recover_from_hurt()


func _kill_main_enemy_with_player_hitbox(
	enemy: EnemyCombatant,
	player: Player,
	use_dash: bool
) -> void:
	if enemy is CursedShieldGuard:
		(enemy as CursedShieldGuard).shield_policy.set_blocking(false)
	var hitbox: HitboxComponent = (
		player.action_controller.dash_attack_hitbox
		if use_dash
		else player.action_controller.attack_hitbox
	)
	var expected_hits: int = _get_expected_main_kill_count(enemy.get_enemy_type_name(), use_dash)
	var damage: int = 2 if use_dash else 1
	var hit_count: int = 0
	while enemy.get_health_component().current_health > 0 and hit_count < 32:
		hitbox.begin_attack(20_000 + enemy.get_instance_id() + hit_count, damage)
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
			return 4 if use_dash else 7
		&"DecayedSpearman":
			return 3 if use_dash else 5
		&"FallenCrossbowman":
			return 2 if use_dash else 4
		_:
			return 0


func _test_enemy_balance_profile(enemy: EnemyCombatant) -> void:
	var expected_health: int = 0
	var expected_damage: int = 0
	match enemy.get_enemy_type_name():
		&"CursedCastleGuard":
			expected_health = 3
			expected_damage = 5
		&"CursedShieldGuard":
			expected_health = 7
			expected_damage = 8
		&"DecayedSpearman":
			expected_health = 5
			expected_damage = 10
		&"FallenCrossbowman":
			expected_health = 4
			expected_damage = 6
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
		print("MAIN_ENEMY_INTEGRATION_TEST: PASS (4 groups, 9 mixed enemies, HUD/respawn, projectile layer)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("MAIN_ENEMY_INTEGRATION_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
