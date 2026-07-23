extends SceneTree

## Runtime composition, encounter activation, and damage proof for configured F5 Main.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const EXPECTED_MAIN_PATH: String = "res://scenes/main/main.tscn"
const GROUP_NAMES: Array[StringName] = [
	&"EncounterGroup01", &"EncounterGroup02", &"EncounterGroup03", &"EncounterGroup04",
]
const GROUP_SIZES: Array[int] = [1, 1, 1, 2]
const ACTIVATION_POSITIONS: Array[Vector2] = [
	Vector2(430.0, 612.0),
	Vector2(850.0, 612.0),
	Vector2(1300.0, 612.0),
	Vector2(1840.0, 612.0),
]
const GUARD_SPAWNS: Array[Vector2] = [
	Vector2(500.0, 610.0),
	Vector2(1030.0, 610.0),
	Vector2(1500.0, 610.0),
	Vector2(2070.0, 610.0),
	Vector2(2310.0, 610.0),
]

var _failures: Array[String] = []
var _guard_presentation_finished: bool = false
var _guard_tree_exited: bool = false


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "") == EXPECTED_MAIN_PATH,
		"F5 project Main does not resolve to %s" % EXPECTED_MAIN_PATH
	)
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	var player: Player = main.get_node_or_null("World/Player") as Player
	var encounters_root: Node2D = main.get_node_or_null("World/Encounters") as Node2D
	_expect(player != null, "Main is missing Player")
	_expect(encounters_root != null, "Main is missing the Encounters container")
	if player == null or encounters_root == null:
		main.queue_free()
		_finish()
		return
	get_root().add_child(main)
	var groups: Array[EncounterGroup] = _collect_groups(encounters_root)
	var guards: Array[CastleGuard] = _collect_guards(groups)
	_expect(groups.size() == 4, "Main does not contain four EncounterGroups")
	_expect(guards.size() == 5, "Main does not contain five Castle Guards")
	if groups.size() != 4 or guards.size() != 5:
		main.queue_free()
		_finish()
		return
	_test_saved_composition(groups, guards)
	await _wait_physics_frames(8)
	_test_runtime_composition(main, player, groups, guards)
	await _test_main_ai_attack(player, guards[0])
	await _test_encounter_activation(player, groups)
	await _test_guard_damage_and_death(player, guards[4])
	main.queue_free()
	await process_frame
	_finish()


func _test_saved_composition(
	groups: Array[EncounterGroup],
	guards: Array[CastleGuard]
) -> void:
	for index: int in range(groups.size()):
		_expect(groups[index].encounter_name == GROUP_NAMES[index], "EncounterGroup name mismatch")
		_expect(groups[index].get_guards().size() == GROUP_SIZES[index], "EncounterGroup size mismatch")
	for index: int in range(guards.size()):
		_expect(guards[index].position == GUARD_SPAWNS[index], "Castle Guard spawn position mismatch")


func _test_runtime_composition(
	main: Node2D,
	player: Player,
	groups: Array[EncounterGroup],
	guards: Array[CastleGuard]
) -> void:
	_expect(player.player_camera.enabled, "Player Camera2D is not enabled")
	_expect(main.get_viewport().get_camera_2d() == player.player_camera, "Player Camera2D is not active")
	_expect(main.has_node("Interface/EnemyDebugPanel/EnemyDebug"), "Encounter debug display is missing")
	_expect(groups[0].is_activated, "Spawn encounter did not activate after Player entered its area")
	for index: int in range(1, groups.size()):
		_expect(not groups[index].is_activated, "%s activated before Player entered" % groups[index].name)
	for index: int in range(guards.size()):
		var guard: CastleGuard = guards[index]
		_expect(guard.visible and not guard.is_dead(), "%s started hidden or dead" % guard.name)
		_expect(guard.health_component.current_health == 3, "%s did not start at 3 Health" % guard.name)
		_expect(guard.get_attack_damage() == 5, "%s is not configured for five damage" % guard.name)
		_expect(guard.is_ai_active() == (index == 0), "%s activation state is incorrect" % guard.name)
	_expect(guards[0].target == player, "First Guard did not acquire Player at the detection boundary")
	print(
		"MAIN_RUNTIME_AUDIT: groups=%d guards=%d spawns=%s damage=%d first_active=%s later_active=%s" % [
			groups.size(), guards.size(), GUARD_SPAWNS, guards[0].get_attack_damage(),
			groups[0].is_activated, groups[1].is_activated,
		]
	)


func _test_main_ai_attack(player: Player, guard: CastleGuard) -> void:
	var health_before: int = player.health_component.current_health
	for _frame_index: int in range(180):
		if player.health_component.current_health < health_before:
			break
		await physics_frame
	_expect(
		player.health_component.current_health == health_before - 5,
		"First Guard AI did not deliver exactly one five-damage sword hit"
	)
	_expect(player.get_life_state_name() == &"Hurt", "AI sword hit did not enter Player Hurt")
	_expect(player.hurt_controller.get_last_damage() == 5, "Player debug context did not record five damage")
	var invulnerable_health: int = player.health_component.current_health
	var extra_hitbox: HitboxComponent = guard.attack_hitbox
	extra_hitbox.begin_attack(9901, guard.get_attack_damage())
	_expect(not extra_hitbox.try_hit(player.hurtbox), "Invulnerability accepted a second immediate Guard hit")
	_expect(player.health_component.current_health == invulnerable_health, "Immediate second Guard hit changed Health")
	extra_hitbox.end_attack()
	await _wait_physics_frames(34)
	guard.set_ai_active(false)


func _test_encounter_activation(
	player: Player,
	groups: Array[EncounterGroup]
) -> void:
	for group_index: int in range(1, groups.size()):
		player.global_position = ACTIVATION_POSITIONS[group_index]
		await _wait_physics_frames(4)
		_expect(groups[group_index].is_activated, "%s did not activate on Player entry" % groups[group_index].name)
		for guard: CastleGuard in groups[group_index].get_guards():
			_expect(guard.is_ai_active(), "%s Guard AI remained paused after activation" % groups[group_index].name)
			guard.set_ai_active(false)
		_expect(groups[group_index].is_activated, "%s did not retain one-shot activation state" % groups[group_index].name)
	var maximum_group_size: int = 0
	for group: EncounterGroup in groups:
		maximum_group_size = maxi(maximum_group_size, group.get_alive_enemy_count())
	_expect(maximum_group_size <= 2, "A Main encounter exceeds the two-enemy authored cap")


func _test_guard_damage_and_death(player: Player, guard: CastleGuard) -> void:
	guard.presentation_finished.connect(_on_guard_presentation_finished)
	guard.tree_exited.connect(_on_guard_tree_exited)
	guard.set_physics_process(false)
	player.set_physics_process(false)
	player.health_component.reset_to_full()
	player.hurt_controller.reset_after_respawn()
	guard.attack_hitbox.global_position = player.hurtbox.global_position
	guard.attack_hitbox.begin_attack(8801, guard.get_attack_damage())
	_expect(guard.attack_hitbox.try_hit(player.hurtbox), "Main Guard sword did not hit Player Hurtbox")
	_expect(player.health_component.current_health == 95, "Main Guard sword did not deal exactly five damage")
	guard.attack_hitbox.end_attack()
	guard.health_component.take_damage(guard.health_component.current_health)
	_expect(guard.get_state_name() == &"Death", "Lethal damage did not enter Guard Death")
	_expect(not guard.hurtbox.is_enabled and not guard.attack_hitbox.is_active, "Dead Guard retained a combat area")
	guard.set_physics_process(true)
	player.set_physics_process(true)
	await _wait_physics_frames(50)
	_expect(_guard_presentation_finished, "Main Guard Death/dissolve did not complete")
	_expect(_guard_tree_exited, "Completed Main Guard did not leave the SceneTree")
	_expect(not is_instance_valid(guard), "Completed Main Guard node was not freed")


func _collect_groups(root: Node2D) -> Array[EncounterGroup]:
	var groups: Array[EncounterGroup] = []
	for child: Node in root.get_children():
		var group: EncounterGroup = child as EncounterGroup
		if group != null:
			groups.append(group)
	return groups


func _collect_guards(groups: Array[EncounterGroup]) -> Array[CastleGuard]:
	var guards: Array[CastleGuard] = []
	for group: EncounterGroup in groups:
		guards.append_array(group.get_guards())
	return guards


func _wait_physics_frames(count: int) -> void:
	for _frame_index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _on_guard_presentation_finished() -> void:
	_guard_presentation_finished = true


func _on_guard_tree_exited() -> void:
	_guard_tree_exited = true


func _finish() -> void:
	if _failures.is_empty():
		print("MAIN_ENEMY_INTEGRATION_TEST: PASS (5 Guards, 4 activations, Hurt, 5 damage, Death)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("MAIN_ENEMY_INTEGRATION_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
