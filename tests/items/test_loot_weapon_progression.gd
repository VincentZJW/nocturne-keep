extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const COIN_SCENE: PackedScene = preload("res://scenes/items/pickups/coin_pickup.tscn")
const SMALL_HEALTH_SCENE: PackedScene = preload("res://scenes/items/pickups/small_health_pickup.tscn")
const LARGE_HEALTH_SCENE: PackedScene = preload("res://scenes/items/pickups/large_health_pickup.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_session().reset_revival_state()
	_test_weapon_data_and_managers()
	_test_scaled_configs()
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	await _wait_frames(5)
	_test_main_composition(main)
	await _test_pickups(main)
	await _test_loot_resolution(main)
	await _test_boss_reward(main)
	await _wait_frames(120)
	main.queue_free()
	await process_frame
	_finish()


func _test_weapon_data_and_managers() -> void:
	var veilbound: WeaponData = load("res://resources/items/weapons/veilbound_daggers.tres") as WeaponData
	var ravenfang: WeaponData = load("res://resources/items/weapons/ravenfang_daggers.tres") as WeaponData
	_expect(veilbound != null and veilbound.is_valid_weapon(), "Veilbound WeaponData invalid")
	_expect(ravenfang != null and ravenfang.is_valid_weapon(), "Ravenfang WeaponData invalid")
	_expect(veilbound.normal_attack_damage == 10 and veilbound.dash_attack_damage == 20, "Veilbound damage is not 10/20")
	_expect(ravenfang.normal_attack_damage == 12 and ravenfang.dash_attack_damage == 24, "Ravenfang damage is not 12/24")
	_expect(veilbound.player_visual_id == &"veilbound" and ravenfang.player_visual_id == &"ravenfang", "Weapon visual ids missing")
	_expect(_equipment().get_normal_attack_damage() == 10, "Starting equipment damage mismatch")
	_wallet().add_coins(12)
	_expect(_wallet().current_coins == 12, "Wallet did not add coins")
	_expect(not _wallet().spend_coins(13), "Wallet overspent")
	_expect(_wallet().current_coins == 12, "Failed spend changed wallet")
	_expect(_wallet().spend_coins(5) and _wallet().current_coins == 7, "Wallet spend mismatch")


func _test_scaled_configs() -> void:
	var guard: CastleGuardConfig = load("res://resources/enemies/castle_guard_config.tres") as CastleGuardConfig
	var shield: CursedShieldGuardConfig = load("res://resources/enemies/cursed_shield_guard_config.tres") as CursedShieldGuardConfig
	var spear: DecayedSpearmanConfig = load("res://resources/enemies/decayed_spearman_config.tres") as DecayedSpearmanConfig
	var crossbow: FallenCrossbowmanConfig = load("res://resources/enemies/fallen_crossbowman_config.tres") as FallenCrossbowmanConfig
	var gargoyle: GargoyleSentinelConfig = load("res://resources/enemies/gargoyle_sentinel_config.tres") as GargoyleSentinelConfig
	var boss: FallenGateKnightConfig = load("res://resources/bosses/fallen_gate_knight_config.tres") as FallenGateKnightConfig
	_expect(guard.max_health == 30 and guard.attack_damage == 5, "Guard scale/damage mismatch")
	_expect(shield.max_health == 50 and shield.shield_max_health == 30 and shield.attack_damage == 8, "Shield scale/damage mismatch")
	_expect(spear.max_health == 50 and spear.attack_damage == 10, "Spearman scale/damage mismatch")
	_expect(crossbow.max_health == 40 and crossbow.projectile_damage == 6, "Crossbow scale/damage mismatch")
	_expect(gargoyle.max_health == 30 and gargoyle.dive_damage == 7, "Gargoyle scale/damage mismatch")
	_expect(boss.max_health == 180 and boss.boss_shield_max_health == 100, "Boss scale mismatch")


func _test_main_composition(main: Node2D) -> void:
	var enemies: Array[Node] = main.get_node("World/Encounters").find_children("*", "EnemyCombatant", true, false)
	_expect(enemies.size() == 34, "Main does not contain 34 enemies")
	var shared_dynamic_profile: DynamicLootProfile = load(
		"res://resources/items/loot/default_dynamic_loot_profile.tres"
	) as DynamicLootProfile
	_expect(shared_dynamic_profile != null and shared_dynamic_profile.is_valid_profile(), "Shared dynamic loot profile invalid")
	var expected_coin_ranges: Dictionary[StringName, Vector2i] = {
		&"CursedCastleGuard": Vector2i(1, 2),
		&"CursedShieldGuard": Vector2i(2, 4),
		&"DecayedSpearman": Vector2i(2, 3),
		&"FallenCrossbowman": Vector2i(2, 3),
		&"GargoyleSentinel": Vector2i(2, 4),
	}
	for node: Node in enemies:
		var loot: LootDropComponent = node.get_node_or_null("LootDropComponent") as LootDropComponent
		_expect(loot != null, "%s lacks LootDropComponent" % node.name)
		if loot != null:
			_expect(
				loot.dynamic_profile.resource_path == shared_dynamic_profile.resource_path,
				"%s does not inherit the shared dynamic loot profile" % node.name,
			)
			var expected_range: Vector2i = expected_coin_ranges.get(
				loot.profile.enemy_type, Vector2i.ZERO
			)
			_expect(
				Vector2i(loot.profile.coin_min, loot.profile.coin_max) == expected_range,
				"%s coin quantity range changed" % node.name,
			)
	var player: Player = main.get_node("World/Player") as Player
	_expect(player.health_component.max_health == 100, "Player max Health changed")
	_expect(is_equal_approx(player.stamina_component.max_stamina, 100.0), "Player max Stamina changed")
	_expect(main.has_node("HUD/RunInventory"), "Main inventory HUD missing")
	_expect(main.has_node("World/CastleEntranceArea/BossReward"), "Main Boss reward missing")
	var boss: FallenGateKnight = main.get_node("World/CastleEntranceArea/FallenGateKnight") as FallenGateKnight
	_expect(boss.get_node_or_null("LootDropComponent") == null, "Boss incorrectly uses normal-enemy random loot")
	_expect(player.has_node("VisualRoot/WeaponVisual"), "Player equipment visual component missing")
	var debug_overlay: MainEnemyDebugOverlay = main.get_node(
		"Interface/DebugHudRoot/EnemyDebugPanel/Content/EnemyScroll/EnemyDebug"
	) as MainEnemyDebugOverlay
	_expect(debug_overlay.set_player_health_75_percent(), "Debug 75% Health option unavailable")
	_expect(player.health_component.current_health == 75, "Debug 75% Health option mismatch")
	_expect(debug_overlay.set_player_health_50_percent(), "Debug 50% Health option unavailable")
	_expect(player.health_component.current_health == 50, "Debug 50% Health option mismatch")
	_expect(debug_overlay.set_player_health_20_percent(), "Debug 20% Health option unavailable")
	_expect(player.health_component.current_health == 20, "Debug 20% Health option mismatch")
	_expect(debug_overlay.set_player_health_full(), "Debug Full Health option unavailable")
	_expect(player.health_component.current_health == 100, "Debug Full Health option mismatch")


func _test_pickups(main: Node2D) -> void:
	var player: Player = main.get_node("World/Player") as Player
	_wallet().reset_for_new_run()
	var coin: CoinPickup = COIN_SCENE.instantiate() as CoinPickup
	main.add_child(coin)
	coin.set_pickup_amount(4)
	coin._on_body_entered(player)
	_expect(_wallet().current_coins == 4, "Coin pickup amount mismatch")
	player.health_component.set_current_health(75)
	var small: HealthPickup = SMALL_HEALTH_SCENE.instantiate() as HealthPickup
	main.add_child(small)
	small._on_body_entered(player)
	_expect(player.health_component.current_health == 85, "Small vial did not heal 10")
	small._on_body_entered(player)
	_expect(player.health_component.current_health == 85, "Small vial healed more than once")
	var large: HealthPickup = LARGE_HEALTH_SCENE.instantiate() as HealthPickup
	main.add_child(large)
	large._on_body_entered(player)
	_expect(player.health_component.current_health == 100, "Large vial did not clamp to max")
	var full_health_vial: HealthPickup = SMALL_HEALTH_SCENE.instantiate() as HealthPickup
	main.add_child(full_health_vial)
	full_health_vial._on_body_entered(player)
	_expect(not full_health_vial._consumed, "Full-health Player consumed vial")
	full_health_vial.queue_free()
	var coins_before_death: int = _wallet().current_coins
	player.health_component.set_current_health(0)
	_expect(player.is_dead(), "Player did not enter Death for pickup guard test")
	var death_vial: HealthPickup = SMALL_HEALTH_SCENE.instantiate() as HealthPickup
	main.add_child(death_vial)
	death_vial._on_body_entered(player)
	_expect(not death_vial._consumed and player.health_component.current_health == 0, "Dead Player consumed a vial")
	_expect(_wallet().current_coins == coins_before_death, "Player death cleared wallet")
	death_vial.queue_free()
	_expect(player.respawn_at(player.global_position), "Pickup test Player could not reset after Death")
	await process_frame


func _test_loot_resolution(main: Node2D) -> void:
	var enemy: EnemyCombatant
	for node: Node in main.get_node("World/Encounters").find_children("*", "", true, false):
		if node is EnemyCombatant:
			enemy = node as EnemyCombatant
			break
	if enemy == null:
		_expect(false, "Unable to locate enemy for loot test")
		return
	var loot: LootDropComponent = enemy.get_node("LootDropComponent") as LootDropComponent
	loot.deterministic_debug_seed = 4242
	loot._rng.seed = 4242
	_test_health_tier_boundaries(loot.dynamic_profile)
	_test_forced_roll_boundaries(loot)

	var full_stats: Dictionary = loot.collect_statistics_for_health(1000, 100, 100, 4242)
	var light_stats: Dictionary = loot.collect_statistics_for_health(1000, 75, 100, 4242)
	var heavy_stats: Dictionary = loot.collect_statistics_for_health(1000, 50, 100, 4242)
	var critical_stats: Dictionary = loot.collect_statistics_for_health(1000, 20, 100, 4242)
	print("LOOT_1000_FULL: %s" % full_stats)
	print("LOOT_1000_LIGHT: %s" % light_stats)
	print("LOOT_1000_HEAVY: %s" % heavy_stats)
	print("LOOT_1000_CRITICAL: %s" % critical_stats)
	for stats: Dictionary in [full_stats, light_stats, heavy_stats, critical_stats]:
		_expect(_sum_counts(stats) == 1000, "1,000-roll statistics do not total 1,000")
	_expect_distribution(full_stats, 720, 0, 0, 280, "Full")
	_expect_distribution(light_stats, 500, 280, 70, 150, "Light")
	_expect_distribution(heavy_stats, 350, 350, 150, 150, "Heavy")
	_expect_distribution(critical_stats, 200, 250, 400, 150, "Critical")
	_expect(int(full_stats[&"small_health"]) == 0 and int(full_stats[&"large_health"]) == 0, "Full Health produced a blood vial")
	_expect(int(critical_stats[&"large_health"]) > int(heavy_stats[&"large_health"]), "Critical tier did not prioritize large healing")

	loot.force_drop = LootDropComponent.ForceDrop.COIN
	var forced: Dictionary = loot.resolve_roll(1.0, false)
	_expect(forced["kind"] == &"coin", "Debug force coin did not override environment rule")
	loot.force_drop = LootDropComponent.ForceDrop.NORMAL
	loot._rng.seed = 9102
	var environment_counts: Dictionary[StringName, int] = {
		&"coin": 0, &"small_health": 0, &"large_health": 0, &"none": 0,
	}
	for _index: int in range(1000):
		var environment_result: Dictionary = loot.resolve_roll_for_health(100, 100, false)
		var environment_kind: StringName = environment_result["kind"] as StringName
		environment_counts[environment_kind] += 1
		_expect(environment_result["kind"] != &"small_health" and environment_result["kind"] != &"large_health", "Environment kill produced healing")
	print("LOOT_1000_ENVIRONMENT_FULL: %s" % environment_counts)
	_expect(
		int(environment_counts[&"coin"]) >= 310 and int(environment_counts[&"coin"]) <= 410,
		"Environment coin probability is not approximately half of Full tier",
	)

	var player: Player = main.get_node("World/Player") as Player
	player.health_component.set_current_health(50)
	loot.reset_drop_state()
	loot.force_drop = LootDropComponent.ForceDrop.NONE
	loot.killed_by_player = true
	var resolved_events: Array[StringName] = []
	loot.drop_resolved.connect(
		func(kind: StringName, _amount: int, _roll: float, _source: bool) -> void:
			resolved_events.append(kind)
	)
	loot._on_enemy_died()
	player.health_component.set_current_health(100)
	loot._on_enemy_died()
	_expect(resolved_events.size() == 1, "Enemy death resolved loot more than once")
	_expect(loot.selected_health_tier == &"HEAVY", "Death did not preserve the single 50-Health snapshot")
	_expect(is_equal_approx(loot.player_health_ratio_at_kill, 0.50), "Death Health ratio audit mismatch")
	_expect(loot.selected_drop_result == &"none", "Forced one-result death audit mismatch")
	loot.force_drop = LootDropComponent.ForceDrop.NORMAL
	loot.reset_loot_statistics()
	_expect(_sum_counts(loot.get_loot_statistics()) == 0, "Loot statistics reset failed")
	loot.reset_drop_state()
	_expect(
		loot.selected_health_tier == &"UNRESOLVED"
		and loot.selected_drop_result == &"unrolled"
		and loot.drop_roll < 0.0
		and not loot._resolved,
		"Loot reset did not restore checkpoint-safe initialization",
	)


func _test_health_tier_boundaries(profile: DynamicLootProfile) -> void:
	var cases: Array[Array] = [
		[100, &"FULL"], [99, &"LIGHT"], [51, &"LIGHT"], [50, &"HEAVY"],
		[21, &"HEAVY"], [20, &"CRITICAL"], [1, &"CRITICAL"], [0, &"CRITICAL"],
	]
	for data: Array in cases:
		var current: int = data[0] as int
		var expected: StringName = data[1] as StringName
		var tier: DynamicLootProfile.HealthTier = profile.get_health_tier(current, 100)
		_expect(profile.get_tier_name(tier) == expected, "Health tier boundary failed at %d/100" % current)


func _test_forced_roll_boundaries(loot: LootDropComponent) -> void:
	var cases: Array[Array] = [
		[100, 71.99, &"coin"], [100, 72.00, &"none"],
		[75, 49.99, &"coin"], [75, 50.00, &"small_health"], [75, 78.00, &"large_health"], [75, 85.00, &"none"],
		[50, 34.99, &"coin"], [50, 35.00, &"small_health"], [50, 70.00, &"large_health"], [50, 85.00, &"none"],
		[20, 19.99, &"coin"], [20, 20.00, &"small_health"], [20, 45.00, &"large_health"], [20, 85.00, &"none"],
	]
	for data: Array in cases:
		var health_value: int = data[0] as int
		var forced_roll: float = data[1] as float
		var expected: StringName = data[2] as StringName
		loot.force_next_drop_roll(forced_roll)
		var result: Dictionary = loot.resolve_roll_for_health(health_value, 100, true)
		_expect(result["kind"] == expected, "Forced roll %.2f at %d Health selected %s" % [forced_roll, health_value, result["kind"]])
		_expect(loot.debug_forced_next_roll < 0.0, "Forced next roll was not consumed once")


func _expect_distribution(
	counts: Dictionary,
	expected_coin: int,
	expected_small: int,
	expected_large: int,
	expected_none: int,
	label: String
) -> void:
	var expected: Dictionary[StringName, int] = {
		&"coin": expected_coin,
		&"small_health": expected_small,
		&"large_health": expected_large,
		&"none": expected_none,
	}
	for kind: StringName in expected:
		var tolerance: int = 0 if expected[kind] == 0 else 55
		_expect(
			absi(int(counts[kind]) - expected[kind]) <= tolerance,
			"%s %s distribution exceeded tolerance: %d vs %d" % [
				label, kind, counts[kind], expected[kind],
			],
		)


func _test_boss_reward(main: Node2D) -> void:
	_wallet().debug_set_coins(0)
	var reward: BossRewardController = main.get_node("World/CastleEntranceArea/BossReward") as BossRewardController
	var room: BossRoomController = main.get_node("BossRoomController") as BossRoomController
	reward.debug_force_reward()
	_expect(_wallet().current_coins == 30, "Boss did not award 30 coins")
	_expect(reward.weapon_pickup.visible, "Ravenfang pickup did not appear")
	_expect(not reward.is_reward_collected(), "Reward began collected")
	room.room_is_cleared = true
	room.gate_open_complete = true
	room._on_castle_entrance_body_entered(room.player)
	_expect(not room.entrance_transition.is_transition_in_progress(), "Gate transitioned before weapon collection")
	_expect(reward.weapon_pickup.collect(), "Ravenfang pickup could not be collected")
	_expect(reward.is_reward_collected(), "Ravenfang collection state missing")
	_expect(_equipment().get_normal_attack_damage() == 12 and _equipment().get_dash_attack_damage() == 24, "Ravenfang did not auto-equip")
	var weapon_visual: PlayerWeaponVisual = room.player.get_node("VisualRoot/WeaponVisual") as PlayerWeaponVisual
	_expect(weapon_visual.get_visual_id() == &"ravenfang", "Player weapon visual did not switch")
	var coins_before: int = _wallet().current_coins
	reward.debug_force_reward()
	_expect(_wallet().current_coins == coins_before, "Boss reward duplicated")
	var threshold: Node2D = load("res://scenes/transitions/ravenmourn_threshold.tscn").instantiate() as Node2D
	get_root().add_child(threshold)
	await process_frame
	var threshold_hud: RunInventoryHud = threshold.get_node("HUD/RunInventory") as RunInventoryHud
	_expect(threshold_hud.coin_label.text.contains("30"), "Threshold lost coin state")
	_expect(threshold_hud.weapon_label.text.contains("12 / 24"), "Threshold lost equipped weapon")
	threshold.queue_free()


func _sum_counts(counts: Dictionary) -> int:
	return int(counts[&"coin"]) + int(counts[&"small_health"]) + int(counts[&"large_health"]) + int(counts[&"none"])


func _session() -> ChapterSessionState:
	return get_root().get_node("ChapterSession") as ChapterSessionState


func _wallet() -> CurrencyWallet:
	return get_root().get_node("CurrencyManager") as CurrencyWallet


func _equipment() -> PlayerEquipmentManager:
	return get_root().get_node("EquipmentManager") as PlayerEquipmentManager


func _wait_frames(count: int) -> void:
	for _index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _finish() -> void:
	if _failures.is_empty():
		print("LOOT_WEAPON_PROGRESSION_TEST: PASS")
		quit(0)
	else:
		print("LOOT_WEAPON_PROGRESSION_TEST: FAIL (%d)" % _failures.size())
		quit(1)
