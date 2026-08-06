extends SceneTree

const WRAITH_SCENE: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/confessional_wraith.tscn"
)

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var host: Node2D = Node2D.new()
	root.add_child(host)
	var player_scene: PackedScene = load("res://scenes/player/player.tscn") as PackedScene
	var player: Player = player_scene.instantiate() as Player if player_scene != null else null
	_check(player != null, "Player fixture failed to instantiate")
	if player == null:
		_finish()
		return
	host.add_child(player)
	player.set_physics_process(false)
	var revealed: Chapter03SpecialistEnemy = await _spawn_wraith(host)
	if revealed == null:
		_finish()
		return
	_check(revealed.current_state == Chapter03SpecialistEnemy.HIDDEN, "Wraith does not start hidden")
	_check(revealed.animated_sprite.visible, "Wraith telegraph silhouette is not visible")
	_check(revealed.animated_sprite.modulate.a <= 0.45, "Wraith hidden telegraph is too opaque")
	_check(not revealed.hurtbox.is_enabled, "Wraith telegraph enabled its Hurtbox too early")
	revealed.target = player
	revealed.state_timer = 0.0
	revealed._process_hidden(0.01)
	_check(revealed.animated_sprite.visible, "Wraith reveal did not restore its visual")
	_check(revealed.hurtbox.is_enabled, "Wraith reveal did not enable its Hurtbox")
	revealed.queue_free()
	await process_frame
	await _test_damage_count(host, 14, 6, "normal Attack", 20)
	await _test_damage_count(host, 28, 3, "Dash Attack", 5)
	host.queue_free()
	await process_frame
	_finish()


func _test_damage_count(
	host: Node2D, damage: int, expected_hits: int, label: String, kill_repetitions: int
) -> void:
	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.faction = &"player"
	host.add_child(hitbox)
	await process_frame
	for kill_index: int in range(kill_repetitions):
		var wraith: Chapter03SpecialistEnemy = await _spawn_wraith(host)
		if wraith == null:
			continue
		wraith.set_physics_process(false)
		wraith.animated_sprite.visible = true
		wraith.hurtbox.set_enabled(true)
		for hit_index: int in range(expected_hits):
			hitbox.attack_kind = &"dash_attack" if damage > 14 else &"attack"
			hitbox.begin_attack(31_000 + damage * 1000 + kill_index * 10 + hit_index, damage, 1.0, hitbox)
			_check(hitbox.try_hit(wraith.hurtbox), "%s kill %d hit %d was rejected" % [label, kill_index + 1, hit_index + 1])
			hitbox.end_attack()
		_check(wraith.health_component.current_health <= 0, "%s did not kill Wraith in %d hits on repetition %d" % [label, expected_hits, kill_index + 1])
		wraith.queue_free()
		await process_frame
	hitbox.queue_free()
	await process_frame


func _spawn_wraith(host: Node2D) -> Chapter03SpecialistEnemy:
	var packed: PackedScene = load(WRAITH_SCENE) as PackedScene
	var wraith: Chapter03SpecialistEnemy = packed.instantiate() as Chapter03SpecialistEnemy if packed != null else null
	_check(wraith != null, "Confessional Wraith failed to instantiate")
	if wraith != null:
		host.add_child(wraith)
		await process_frame
	return wraith


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CH3 CONFESSIONAL WRAITH COMBAT FIX | PASS normal_kills=20 dash_kills=5 damage_events=135")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)
