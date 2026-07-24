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
	for node: Node in enemies:
		_expect(node.get_node_or_null("LootDropComponent") is LootDropComponent, "%s lacks LootDropComponent" % node.name)
	var player: Player = main.get_node("World/Player") as Player
	_expect(player.health_component.max_health == 100, "Player max Health changed")
	_expect(is_equal_approx(player.stamina_component.max_stamina, 100.0), "Player max Stamina changed")
	_expect(main.has_node("HUD/RunInventory"), "Main inventory HUD missing")
	_expect(main.has_node("World/CastleEntranceArea/BossReward"), "Main Boss reward missing")
	_expect(player.has_node("VisualRoot/WeaponVisual"), "Player equipment visual component missing")


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
	var high_stats: Dictionary = loot.collect_statistics(100, 1.0, 4242)
	var mid_stats: Dictionary = loot.collect_statistics(100, 0.5, 4242)
	var low_stats: Dictionary = loot.collect_statistics(100, 0.2, 4242)
	print("LOOT_100_ROLL_HIGH: %s" % high_stats)
	print("LOOT_100_ROLL_MID: %s" % mid_stats)
	print("LOOT_100_ROLL_LOW: %s" % low_stats)
	_expect(_sum_counts(high_stats) == 100 and _sum_counts(mid_stats) == 100 and _sum_counts(low_stats) == 100, "100-roll statistics do not total 100")
	_expect(int(low_stats[&"small_health"]) + int(low_stats[&"large_health"]) >= int(high_stats[&"small_health"]) + int(high_stats[&"large_health"]), "Low-HP protection did not increase healing outcomes")
	loot.force_drop = LootDropComponent.ForceDrop.COIN
	var forced: Dictionary = loot.resolve_roll(1.0, false)
	_expect(forced["kind"] == &"coin", "Debug force coin did not override environment rule")
	loot.force_drop = LootDropComponent.ForceDrop.NORMAL
	loot._rng.seed = 9102
	for _index: int in range(100):
		var environment_result: Dictionary = loot.resolve_roll(0.2, false)
		_expect(environment_result["kind"] != &"small_health" and environment_result["kind"] != &"large_health", "Environment kill produced healing")


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
