extends SceneTree

## Five deterministic live-combat simulations. Hits enter through the real
## HitboxComponent -> HurtboxComponent -> HealthComponent path. The player is
## invulnerable only so this test measures Boss cadence and victory completion.

const TEST_ROOM: String = "res://chapters/chapter_02_silent_court/scenes/tests/hollow_duchess_test_room.tscn"
const FIGHT_COUNT: int = 5

var _failures: Array[String] = []
var _attack_id: int = 700_000
var _attack_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 20.0
	var packed: PackedScene = ResourceLoader.load(TEST_ROOM, "PackedScene") as PackedScene
	if packed == null:
		_failures.append("test room did not load")
		_finish()
		return
	var room: Node = packed.instantiate()
	root.add_child(room)
	current_scene = room
	await _wait_physics_frames(12)
	var boss: HollowDuchess = room.get_node_or_null("HollowDuchess") as HollowDuchess
	var player: Player = room.get_node_or_null("Player") as Player
	if boss == null or player == null:
		_failures.append("boss or player missing")
		_finish()
		return
	player.hurtbox.set_invulnerable(true)
	boss.config.intro_retry_duration = 0.05
	boss.attack_started.connect(func(_name: StringName) -> void: _attack_count += 1)
	var player_hitbox: HitboxComponent = HitboxComponent.new()
	player_hitbox.faction = &"player"
	player_hitbox.attack_kind = &"normal_attack"
	room.add_child(player_hitbox)
	var durations: Array[float] = []
	for fight_index: int in range(FIGHT_COUNT):
		boss.reset_boss()
		boss.activate(player, true)
		await _wait_until_active(boss)
		var simulated_seconds: float = 0.0
		var next_hit_at: float = 12.0 + float(fight_index)
		var hit_index: int = 0
		while not boss.health_component.is_dead() and simulated_seconds < 260.0:
			await physics_frame
			simulated_seconds += (1.0 / 60.0) * Engine.time_scale
			if simulated_seconds < next_hit_at:
				continue
			var is_dash_attack: bool = hit_index % 4 == 3
			player_hitbox.attack_kind = &"dash_attack" if is_dash_attack else &"normal_attack"
			var damage: int = 24 if is_dash_attack else 12
			_attack_id += 1
			player_hitbox.begin_attack(_attack_id, damage, 1.0, player)
			var accepted: bool = player_hitbox.try_hit(boss.hurtbox)
			player_hitbox.end_attack()
			if not accepted:
				# Phase transition invulnerability defers, but never drops, the planned strike.
				next_hit_at += 0.5
				continue
			hit_index += 1
			next_hit_at += 12.0 + float((hit_index + fight_index) % 5)
		if not boss.health_component.is_dead():
			_failures.append("fight %d exceeded 260 simulated seconds" % (fight_index + 1))
			continue
		for _frame: int in range(180):
			await physics_frame
			if not boss.is_physics_processing():
				break
		if boss.is_physics_processing():
			_failures.append("fight %d did not complete death sequence" % (fight_index + 1))
		durations.append(simulated_seconds)
		print("HOLLOW_DUCHESS_FULL_FIGHT_%d: duration=%.1fs hits=%d" % [fight_index + 1, simulated_seconds, hit_index])
	for duration: float in durations:
		if duration < 150.0 or duration > 240.0:
			_failures.append("fight duration %.1f outside 150-240s target" % duration)
	if _attack_count < 35:
		_failures.append("Boss produced too few attacks across five fights: %d" % _attack_count)
	player_hitbox.queue_free()
	_finish()


func _wait_until_active(boss: HollowDuchess) -> void:
	for _frame: int in range(180):
		await physics_frame
		if boss.get_state_name() not in [&"Dormant", &"Intro"]:
			return


func _wait_physics_frames(count: int) -> void:
	for _frame: int in range(count):
		await physics_frame


func _finish() -> void:
	Engine.time_scale = 1.0
	if _failures.is_empty():
		print("HOLLOW_DUCHESS_FULL_FIGHTS: PASS fights=5 attacks=%d" % _attack_count)
		quit(0)
		return
	for failure: String in _failures:
		push_error("HOLLOW_DUCHESS_FULL_FIGHTS: %s" % failure)
	quit(1)
