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
	_test_combat_wiring(enemies)
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
	_expect(main.has_node("Interface/EnemyDebugPanel/EnemyDebug"), "Main mixed-enemy debug overlay is missing")
	var health_hud: PlayerHealthHud = main.get_node_or_null("HUD/HealthContainer") as PlayerHealthHud
	var stamina_hud: PlayerStaminaHud = main.get_node_or_null("HUD") as PlayerStaminaHud
	var respawn: PlayerRespawnController = main.get_node_or_null("PlayerRespawnController") as PlayerRespawnController
	_expect(health_hud != null and health_hud.health_component == player.health_component, "Main Health HUD is not live-bound")
	_expect(stamina_hud != null and stamina_hud.stamina_component == player.stamina_component, "Main Stamina HUD is not live-bound")
	_expect(respawn != null and respawn.player == player, "Main respawn controller is not bound to Player")
	var enemy_debug: MainEnemyDebugOverlay = main.get_node_or_null(
		"Interface/EnemyDebugPanel/EnemyDebug"
	) as MainEnemyDebugOverlay
	var enemy_toggle: CheckButton = main.get_node_or_null(
		"Interface/EnemyDebugPanel/EnemyDebugToggle"
	) as CheckButton
	_expect(enemy_debug != null and enemy_toggle != null, "Main enemy debug controls are incomplete")
	if enemy_debug != null and enemy_toggle != null:
		enemy_toggle.toggled.emit(false)
		_expect(not enemy_debug.visible and not enemy_debug.is_processing(), "Main enemy debug cannot be disabled")
		enemy_toggle.toggled.emit(true)
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


func _test_combat_wiring(enemies: Array[EnemyCombatant]) -> void:
	for enemy: EnemyCombatant in enemies:
		var hitbox: HitboxComponent = enemy.get_node_or_null("FacingRoot/AttackHitbox") as HitboxComponent
		if enemy is FallenCrossbowman:
			_expect((enemy as FallenCrossbowman).projectile_scene != null, "Crossbowman lacks bolt PackedScene")
			_expect(enemy.get_attack_damage() == 4, "Crossbow bolt damage is not four")
		else:
			_expect(hitbox != null, "%s lacks a melee AttackHitbox" % enemy.name)
			_expect(hitbox.faction == &"enemy", "%s melee Hitbox faction mismatch" % enemy.name)
		_expect((enemy.get_node("Hurtbox") as HurtboxComponent).faction == &"enemy", "%s Hurtbox faction mismatch" % enemy.name)


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
