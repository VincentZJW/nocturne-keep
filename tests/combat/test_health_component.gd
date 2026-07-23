extends SceneTree

## Isolated contract tests for the PLAYER-HP-001 health data component.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []
var _health_events: Array[Vector2i] = []
var _death_events: int = 0
var _event_order: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_test_default_value_and_signal()
	_test_custom_maximum_and_clamping()
	_test_invalid_maximum_is_sanitized()
	_test_reset_and_duplicate_signal_guard()
	_test_damage_healing_and_limits()
	_test_death_signal_guard_and_rearm()
	await _test_player_scene_composition()
	_finish()


func _test_default_value_and_signal() -> void:
	_health_events.clear()
	var health: HealthComponent = HealthComponent.new()
	health.health_changed.connect(_on_health_changed)
	get_root().add_child(health)
	_expect(health.max_health == 100, "Default maximum health is not 100")
	_expect(health.current_health == 100, "Health did not initialize full")
	_expect(
		_health_events == [Vector2i(100, 100)],
		"Ready did not emit the initial 100/100 health value exactly once"
	)
	health.queue_free()


func _test_custom_maximum_and_clamping() -> void:
	_health_events.clear()
	var health: HealthComponent = HealthComponent.new()
	health.max_health = 150
	health.health_changed.connect(_on_health_changed)
	get_root().add_child(health)
	_expect(health.current_health == 150, "Custom maximum did not initialize current health")
	health.set_current_health(90)
	_expect(health.current_health == 90, "Valid health assignment was not retained")
	health.set_current_health(-25)
	_expect(health.current_health == 0, "Health was not clamped to zero")
	health.current_health = 900
	_expect(health.current_health == 150, "Health was not clamped to the custom maximum")
	_expect(
		_health_events == [Vector2i(150, 150), Vector2i(90, 150), Vector2i(0, 150), Vector2i(150, 150)],
		"Health change signal values do not match clamped state transitions"
	)
	health.queue_free()


func _test_invalid_maximum_is_sanitized() -> void:
	var health: HealthComponent = HealthComponent.new()
	health.max_health = 0
	get_root().add_child(health)
	_expect(health.max_health == 1, "Maximum health was not sanitized to its minimum of one")
	_expect(health.current_health == 1, "Sanitized maximum did not initialize current health")
	health.queue_free()


func _test_reset_and_duplicate_signal_guard() -> void:
	_health_events.clear()
	var health: HealthComponent = HealthComponent.new()
	health.health_changed.connect(_on_health_changed)
	get_root().add_child(health)
	health.set_current_health(40)
	var event_count_before_duplicate: int = _health_events.size()
	health.set_current_health(40)
	_expect(
		_health_events.size() == event_count_before_duplicate,
		"Assigning an unchanged health value emitted a duplicate signal"
	)
	health.reset_to_full()
	_expect(health.current_health == 100, "Reset did not restore full health")
	_expect(_health_events.back() == Vector2i(100, 100), "Reset signal did not report full health")
	health.queue_free()


func _test_damage_healing_and_limits() -> void:
	_health_events.clear()
	_death_events = 0
	_event_order.clear()
	var health: HealthComponent = HealthComponent.new()
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	get_root().add_child(health)
	_health_events.clear()
	_event_order.clear()
	health.take_damage(25)
	_expect(health.current_health == 75, "Damage did not subtract from current health")
	health.heal(10)
	_expect(health.current_health == 85, "Healing did not add to current health")
	health.heal(999)
	_expect(health.current_health == 100, "Healing was not clamped to maximum health")
	health.take_damage(999)
	_expect(health.current_health == 0, "Lethal damage was not clamped to zero")
	_expect(health.is_dead(), "Zero health was not reported as dead")
	_expect(_death_events == 1, "Lethal damage did not emit died exactly once")
	_expect(
		_event_order.slice(-2) == ["health:0/100", "died"],
		"Lethal event order was not health_changed followed by died"
	)
	var event_count_at_death: int = _health_events.size()
	health.take_damage(10)
	health.take_damage(0)
	health.take_damage(-10)
	health.heal(0)
	health.heal(-10)
	_expect(_health_events.size() == event_count_at_death, "Invalid or post-death input changed health")
	_expect(_death_events == 1, "Post-death damage repeated the died signal")
	health.queue_free()


func _test_death_signal_guard_and_rearm() -> void:
	_death_events = 0
	var health: HealthComponent = HealthComponent.new()
	health.died.connect(_on_died)
	get_root().add_child(health)
	health.current_health = 0
	health.current_health = 0
	_expect(_death_events == 1, "Direct zero assignment repeated the died signal")
	health.heal(20)
	_expect(health.current_health == 20, "Positive healing did not restore health from zero")
	_expect(not health.is_dead(), "Positive healing did not clear dead data state")
	health.take_damage(20)
	_expect(_death_events == 2, "Restored positive health did not rearm the died signal")
	health.reset_to_full()
	_expect(health.current_health == 100, "Reset did not restore health after death")
	health.take_damage(100)
	_expect(_death_events == 3, "Reset did not rearm the died signal")
	health.queue_free()


func _test_player_scene_composition() -> void:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	get_root().add_child(player)
	await process_frame
	var health: HealthComponent = player.get_node_or_null("HealthComponent") as HealthComponent
	_expect(health != null, "Player scene does not contain HealthComponent")
	if health != null:
		_expect(health.unique_name_in_owner, "Player HealthComponent is not uniquely addressable")
		_expect(health.max_health == 100, "Player HealthComponent maximum is not 100")
		_expect(health.current_health == 100, "Player HealthComponent did not initialize full")
	player.queue_free()
	await process_frame


func _on_health_changed(current: int, maximum: int) -> void:
	_health_events.append(Vector2i(current, maximum))
	_event_order.append("health:%d/%d" % [current, maximum])


func _on_died() -> void:
	_death_events += 1
	_event_order.append("died")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("HEALTH_COMPONENT_TEST: PASS (health, damage, healing, death guard, Player composition)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("HEALTH_COMPONENT_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
