extends SceneTree

## Configured-Main visual evidence for loot, Boss reward and cross-scene state.

const MAIN: PackedScene = preload("res://scenes/main/main.tscn")
const SMALL: PackedScene = preload("res://scenes/items/pickups/small_health_pickup.tscn")
const LARGE: PackedScene = preload("res://scenes/items/pickups/large_health_pickup.tscn")
const GUARD: PackedScene = preload("res://scenes/enemies/castle_guard.tscn")
const THRESHOLD: PackedScene = preload("res://scenes/transitions/ravenmourn_threshold.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var session: ChapterSessionState = root.get_node("ChapterSession") as ChapterSessionState
	session.reset_revival_state()
	var main: Node2D = MAIN.instantiate() as Node2D
	root.add_child(main)
	current_scene = main
	await _wait_frames(8)
	var player: Player = main.get_node("World/Player") as Player
	(main.get_node("Interface") as MainDebugHudController).set_debug_hud_visible(false)
	var tutorial: Node = main.get_node("TutorialController")
	tutorial.set_process(false)
	main.get_node("HUD/TutorialPrompt").visible = false
	_hide_and_pause_enemies(main)
	player.global_position = Vector2(1820, 612)
	player.player_camera.reset_smoothing()
	await _show_guard_coin_drop(main, player)
	await _show_pickup(main, player, SMALL, Vector2(1880, 596), "res://docs/qa/loot_small_blood_vial_main.png")
	await _show_pickup(main, player, LARGE, Vector2(1880, 596), "res://docs/qa/loot_large_blood_vial_main.png")
	player.global_position = Vector2(6150, 612)
	player.player_camera.reset_smoothing()
	var reward: BossRewardController = main.get_node("World/CastleEntranceArea/BossReward") as BossRewardController
	reward.debug_force_reward()
	reward.boss.visible = false
	await _wait_frames(10)
	main.get_node("HUD/TutorialPrompt").visible = false
	_save_viewport("res://docs/qa/boss_ravenfang_reward_main.png")
	reward.weapon_pickup.collect()
	await _wait_frames(3)
	main.get_node("HUD/TutorialPrompt").visible = false
	_save_viewport("res://docs/qa/ravenfang_equipped_main.png")
	main.queue_free()
	await process_frame
	var threshold: Node2D = THRESHOLD.instantiate() as Node2D
	root.add_child(threshold)
	current_scene = threshold
	await _wait_frames(5)
	_save_viewport("res://docs/qa/threshold_inventory_persistence.png")
	print("LOOT_WEAPON_QA: PASS (coin, vials, Boss reward, equipment, threshold persistence)")
	quit(0)


func _show_pickup(
	main: Node2D,
	player: Player,
	scene: PackedScene,
	position: Vector2,
	path: String
) -> void:
	var pickup: Node2D = scene.instantiate() as Node2D
	main.get_node("World").add_child(pickup)
	pickup.global_position = position
	await _wait_frames(8)
	main.get_node("HUD/TutorialPrompt").visible = false
	_save_viewport(path)
	pickup.queue_free()
	await process_frame
	player.player_camera.reset_smoothing()


func _show_guard_coin_drop(main: Node2D, player: Player) -> void:
	var guard: EnemyCombatant = GUARD.instantiate() as EnemyCombatant
	main.get_node("World").add_child(guard)
	guard.global_position = Vector2(1880, 612)
	guard.set_ai_active(false)
	var loot: LootDropComponent = guard.get_node("LootDropComponent") as LootDropComponent
	loot.force_drop = LootDropComponent.ForceDrop.COIN
	loot.killed_by_player = true
	guard.get_health_component().take_damage(guard.get_health_component().max_health)
	await _wait_frames(4)
	main.get_node("HUD/TutorialPrompt").visible = false
	_save_viewport("res://docs/qa/loot_normal_enemy_coin_main.png")
	guard.queue_free()
	await process_frame
	for child: Node in main.get_node("World").get_children():
		if child is CoinPickup:
			child.queue_free()
	await process_frame
	player.player_camera.reset_smoothing()


func _hide_and_pause_enemies(main: Node2D) -> void:
	var encounters: Node2D = main.get_node("World/Encounters") as Node2D
	for node: Node in encounters.find_children("*", "", true, false):
		var enemy: EnemyCombatant = node as EnemyCombatant
		if enemy != null:
			enemy.set_ai_active(false)
			enemy.visible = false


func _wait_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


func _save_viewport(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Unable to save loot QA image %s" % path)
