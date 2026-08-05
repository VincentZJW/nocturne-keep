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
	player.hurtbox.set_invulnerable(true)
	for role: String in ROLES:
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
			"CH4 COMBAT STRESS | PASS roles=%d kills=%d attacks=%d encounter_reloads=%d"
			% [ROLES.size(), _kill_count, _attack_count, _room_reload_count]
		)
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)
