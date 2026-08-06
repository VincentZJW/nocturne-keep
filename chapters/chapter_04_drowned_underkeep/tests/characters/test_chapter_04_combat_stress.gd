extends SceneTree

## Deterministic Chapter IV stress coverage required by the cross-chapter QA:
## 20 deaths per role, 15 complete uses of every authored action, and five
## formal encounter-room reloads.

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep"
const ROOM_PATH: String = ROOT + "/scenes/rooms/ch4_02_rusted_cellblock.tscn"
const ROLES: Array[String] = [
	"drowned_gaoler",
	"chainbound_convict",
	"mire_harpooner",
	"sunken_shield_penitent",
	"mirefin_raider",
	"bog_toad",
	"sewer_maw",
	"underkeep_executioner",
]

var _failures: PackedStringArray = []
var _kill_count: int = 0
var _attack_count: int = 0
var _room_reload_count: int = 0
var _enemy_contact_count: int = 0
var _player_contact_count: int = 0
var _facing_contact_count: int = 0
var _next_contact_attack_id: int = 50_000


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var host: Node2D = Node2D.new()
	host.name = "Chapter04CombatStress"
	root.add_child(host)
	current_scene = host
	var player_packed: PackedScene = load("res://scenes/player/player.tscn") as PackedScene
	var player: Player = player_packed.instantiate() as Player if player_packed != null else null
	_check(player != null, "Player stress fixture failed to instantiate")
	if player == null:
		_finish()
		return
	host.add_child(player)
	player.global_position = Vector2(1100.0, 584.0)
	player.set_physics_process(false)
	for role: String in ROLES:
		await _verify_real_combat_contacts(host, player, role)
		player.hurt_controller.reset_after_respawn()
		player._on_hurt_finished()
		player.hurtbox.set_invulnerable(true)
		await _stress_attacks(host, player, role)
		await _stress_deaths(host, role)
	host.remove_child(player)
	player.free()
	await physics_frame
	await _stress_room_reload(host)
	current_scene = null
	host.queue_free()
	await process_frame
	await process_frame
	_finish()


func _verify_real_combat_contacts(host: Node2D, player: Player, role: String) -> void:
	for facing: float in [-1.0, 1.0]:
		await _verify_enemy_hits_player(host, player, role, facing)
		await _verify_player_hits_enemy(host, player, role, facing)


func _verify_enemy_hits_player(
	host: Node2D,
	player: Player,
	role: String,
	facing: float
) -> void:
	var enemy: Chapter04Enemy = await _spawn_enemy(host, role)
	if enemy == null:
		return
	enemy.global_position = Vector2(500.0, 584.0)
	enemy.set_physics_process(false)
	enemy.set_facing_direction(facing)
	enemy.target = player
	var data: Chapter04EnemyConfig = enemy.config as Chapter04EnemyConfig
	var actions: Array[Dictionary] = [
		{
			"name": data.primary_action,
			"damage": enemy.config.attack_damage,
			"range": enemy.config.attack_range,
			"windup": enemy.config.attack_windup,
			"active": enemy.config.attack_active_duration,
			"recovery": enemy.config.attack_recovery,
		},
		{
			"name": data.secondary_action,
			"damage": data.secondary_damage,
			"range": data.secondary_range,
			"windup": data.secondary_windup,
			"active": data.secondary_active_duration,
			"recovery": data.secondary_recovery,
		},
		{
			"name": data.special_action,
			"damage": data.special_damage,
			"range": data.special_range,
			"windup": data.special_windup,
			"active": data.special_active_duration,
			"recovery": data.special_recovery,
		},
	]
	for action: Dictionary in actions:
		player.health_component.reset_to_full()
		player.hurt_controller.reset_after_respawn()
		player._on_hurt_finished()
		player.hurtbox.set_invulnerable(false)
		var authored_range: float = action["range"] as float
		player.global_position = enemy.global_position + Vector2(
			facing * maxf(1.0, authored_range - 1.0),
			-28.0
		)
		enemy._start_action(
			action["name"] as StringName,
			action["damage"] as int,
			action["windup"] as float,
			action["active"] as float,
			action["recovery"] as float
		)
		enemy._process_action((action["windup"] as float) + 0.01)
		var selected: HitboxComponent = (
			enemy.primary_hitbox
			if (action["name"] as StringName) == data.primary_action
			else enemy.secondary_hitbox
		)
		if not enemy._is_projectile_action(action["name"] as StringName):
			var hitbox_direction: float = signf(selected.global_position.x - enemy.global_position.x)
			_check(
				hitbox_direction == facing,
				"%s %s facing %.0f placed Hitbox on %.0f side"
				% [role, action["name"], facing, hitbox_direction]
			)
			_facing_contact_count += 1
		var health_before: int = player.health_component.current_health
		if enemy._is_projectile_action(action["name"] as StringName):
			for frame_index: int in range(90):
				await physics_frame
				if player.health_component.current_health < health_before:
					break
		else:
			var active_step: float = 1.0 / 60.0
			var active_steps: int = ceili((action["active"] as float) / active_step) + 2
			for active_frame: int in range(active_steps):
				enemy._process_action(active_step)
				enemy.global_position.x += enemy.velocity.x * active_step
				await physics_frame
				if player.health_component.current_health < health_before:
					break
		var expected_health: int = health_before - (action["damage"] as int)
		_check(
			player.health_component.current_health == expected_health,
			"%s %s facing %.0f real contact expected Player HP %d, got %d"
			% [
				role,
				action["name"],
				facing,
				expected_health,
				player.health_component.current_health,
			]
		)
		var health_after_first_contact: int = player.health_component.current_health
		for duplicate_frame: int in range(3):
			await physics_frame
		_check(
			player.health_component.current_health == health_after_first_contact,
			"%s %s facing %.0f damaged Player more than once in one attack"
			% [role, action["name"], facing]
		)
		_enemy_contact_count += 1
		enemy._on_attack_cancelled()
		for projectile: Node in get_nodes_in_group(&"chapter_04_enemy_projectile"):
			projectile.queue_free()
		await process_frame
	enemy.queue_free()
	await process_frame


func _verify_player_hits_enemy(
	host: Node2D,
	player: Player,
	role: String,
	facing: float
) -> void:
	var enemy: Chapter04Enemy = await _spawn_enemy(host, role)
	if enemy == null:
		return
	enemy.global_position = Vector2(500.0, 584.0)
	enemy.set_physics_process(false)
	# Face the enemy in the same direction as Player so this contact enters from
	# behind the shield role and proves the shared body-Hurtbox contract.
	enemy.set_facing_direction(facing)
	enemy.hurtbox.set_enabled(true)
	player.global_position = enemy.global_position + Vector2(-facing * 44.0, -28.0)
	player.animation_controller.reset_to_idle()
	player.animation_controller.set_facing_left(facing < 0.0)
	await physics_frame
	var player_hitboxes: Array[Dictionary] = [
		{
			"name": &"normal_attack",
			"hitbox": player.action_controller.attack_hitbox,
			"damage": 1,
		},
		{
			"name": &"dash_attack",
			"hitbox": player.action_controller.dash_attack_hitbox,
			"damage": 2,
		},
	]
	for contact: Dictionary in player_hitboxes:
		enemy.health_component.reset_to_full()
		enemy.hurtbox.set_enabled(true)
		var hitbox: HitboxComponent = contact["hitbox"] as HitboxComponent
		hitbox.attack_kind = contact["name"] as StringName
		var health_before: int = enemy.health_component.current_health
		var attack_id: int = _next_contact_attack_id
		_next_contact_attack_id += 1
		hitbox.begin_attack(attack_id, contact["damage"] as int, facing, player)
		for frame_index: int in range(5):
			await physics_frame
			if enemy.health_component.current_health < health_before:
				break
		var expected_health: int = health_before - (contact["damage"] as int)
		_check(
			enemy.health_component.current_health == expected_health,
			"Player %s facing %.0f expected %s HP %d, got %d"
			% [
				contact["name"],
				facing,
				role,
				expected_health,
				enemy.health_component.current_health,
			]
		)
		var health_after_first_contact: int = enemy.health_component.current_health
		for duplicate_frame: int in range(3):
			await physics_frame
		_check(
			enemy.health_component.current_health == health_after_first_contact,
			"Player %s facing %.0f damaged %s more than once in attack %d"
			% [contact["name"], facing, role, attack_id]
		)
		_player_contact_count += 1
		hitbox.end_attack()
		await physics_frame
	enemy.queue_free()
	await process_frame


func _stress_attacks(host: Node2D, player: Player, role: String) -> void:
	var enemy: Chapter04Enemy = await _spawn_enemy(host, role)
	if enemy == null:
		return
	enemy.global_position = Vector2(120.0, 584.0)
	enemy.set_physics_process(false)
	enemy.target = player
	var data: Chapter04EnemyConfig = enemy.config as Chapter04EnemyConfig
	var actions: Array[Dictionary] = [
		{
			"name": data.primary_action,
			"damage": enemy.config.attack_damage,
			"windup": enemy.config.attack_windup,
			"active": enemy.config.attack_active_duration,
			"recovery": enemy.config.attack_recovery,
		},
		{
			"name": data.secondary_action,
			"damage": data.secondary_damage,
			"windup": data.secondary_windup,
			"active": data.secondary_active_duration,
			"recovery": data.secondary_recovery,
		},
		{
			"name": data.special_action,
			"damage": data.special_damage,
			"windup": data.special_windup,
			"active": data.special_active_duration,
			"recovery": data.special_recovery,
		},
	]
	for action: Dictionary in actions:
		for cycle: int in range(15):
			enemy._start_action(
				action["name"] as StringName,
				action["damage"] as int,
				action["windup"] as float,
				action["active"] as float,
				action["recovery"] as float
			)
			enemy._process_action((action["windup"] as float) + 0.01)
			_check(enemy.attack_phase == &"Active", "%s %s cycle %d did not enter Active" % [role, action["name"], cycle + 1])
			enemy._process_action((action["active"] as float) + 0.01)
			_check(enemy.attack_phase == &"Recovery", "%s %s cycle %d did not enter Recovery" % [role, action["name"], cycle + 1])
			enemy._process_action((action["recovery"] as float) + 0.01)
			_check(enemy.attack_phase == &"None", "%s %s cycle %d did not finish" % [role, action["name"], cycle + 1])
			_attack_count += 1
	for projectile: Node in get_nodes_in_group(&"chapter_04_enemy_projectile"):
		projectile.queue_free()
	enemy.queue_free()
	await process_frame


func _stress_deaths(host: Node2D, role: String) -> void:
	for repetition: int in range(20):
		var enemy: Chapter04Enemy = await _spawn_enemy(host, role)
		if enemy == null:
			continue
		enemy.set_physics_process(false)
		var maximum: int = enemy.health_component.max_health
		enemy.health_component.take_damage(maximum)
		_check(enemy.is_dead(), "%s death repetition %d did not enter Death" % [role, repetition + 1])
		_check(not enemy.hurtbox.is_enabled, "%s death repetition %d left Hurtbox active" % [role, repetition + 1])
		_kill_count += 1
		if is_instance_valid(enemy):
			enemy.queue_free()
		await process_frame


func _stress_room_reload(host: Node2D) -> void:
	var room_packed: PackedScene = load(ROOM_PATH) as PackedScene
	_check(room_packed != null, "Formal Chapter IV encounter room failed to load")
	if room_packed == null:
		return
	for repetition: int in range(5):
		var room: Node = room_packed.instantiate()
		host.add_child(room)
		await process_frame
		await process_frame
		var spawner: Chapter04EncounterSpawner = room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
		_check(spawner != null, "Encounter reload %d has no spawner" % (repetition + 1))
		if spawner != null:
			var groups: Array[EncounterGroup] = spawner.get_encounter_groups()
			_check(not groups.is_empty(), "Encounter reload %d built no groups" % (repetition + 1))
			for group: EncounterGroup in groups:
				_check(
					not group.is_activated and not group.is_cleared,
					"Encounter reload %d group %s state activated=%s cleared=%s"
					% [repetition + 1, group.name, group.is_activated, group.is_cleared]
				)
		room.queue_free()
		await process_frame
		_room_reload_count += 1


func _spawn_enemy(host: Node2D, role: String) -> Chapter04Enemy:
	var packed: PackedScene = load("%s/scenes/enemies/%s.tscn" % [ROOT, role]) as PackedScene
	var enemy: Chapter04Enemy = packed.instantiate() as Chapter04Enemy if packed != null else null
	_check(enemy != null, "%s failed to instantiate" % role)
	if enemy != null:
		host.add_child(enemy)
		await process_frame
	return enemy


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print(
			"CH4 COMBAT STRESS | PASS roles=%d kills=%d attacks=%d enemy_contacts=%d player_contacts=%d facing_checks=%d encounter_reloads=%d"
			% [
				ROLES.size(),
				_kill_count,
				_attack_count,
				_enemy_contact_count,
				_player_contact_count,
				_facing_contact_count,
				_room_reload_count,
			]
		)
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)
