extends SceneTree

## Integration tests for the signal-driven, rebindable PLAYER-HP-002 Health HUD.

const MAIN_SCENE: PackedScene = preload("res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_health_display_and_stamina_regression()
	await _test_health_component_rebinding()
	_finish()


func _test_health_display_and_stamina_regression() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	get_root().add_child(main)
	await process_frame
	var health: HealthComponent = main.get_node(
		"World/Player/HealthComponent"
	) as HealthComponent
	var health_hud: PlayerHealthHud = main.get_node(
		"HUD/HealthContainer"
	) as PlayerHealthHud
	var health_bar: ProgressBar = main.get_node(
		"HUD/HealthContainer/HealthBar"
	) as ProgressBar
	var health_value: Label = main.get_node(
		"HUD/HealthContainer/HealthValue"
	) as Label
	var stamina: PlayerStaminaComponent = main.get_node(
		"World/Player/StaminaComponent"
	) as PlayerStaminaComponent
	var stamina_bar: ProgressBar = main.get_node(
		"HUD/StaminaContainer/StaminaBar"
	) as ProgressBar
	var stamina_value: Label = main.get_node(
		"HUD/StaminaContainer/StaminaValue"
	) as Label
	_expect(
		health != null and health_hud != null and health_bar != null and health_value != null,
		"Main is missing the functional Health HUD binding"
	)
	if health != null and health_hud != null and health_bar != null and health_value != null:
		_expect(health_hud.health_component == health, "Health HUD did not bind the Player component")
		_expect(is_equal_approx(health_bar.min_value, 0.0), "Health bar minimum is not zero")
		_expect(is_equal_approx(health_bar.max_value, 100.0), "Health bar maximum is not 100")
		_expect(is_equal_approx(health_bar.value, 100.0), "Health bar did not initialize full")
		_expect(health_value.text == "100 / 100", "Initial Health numeric display is wrong")
		health.take_damage(10)
		_expect(is_equal_approx(health_bar.value, 90.0), "Damage signal did not lower the Health bar")
		_expect(health_value.text == "090 / 100", "Damage numeric display is out of sync")
		health.heal(10)
		_expect(is_equal_approx(health_bar.value, 100.0), "Healing signal did not raise the Health bar")
		_expect(health_value.text == "100 / 100", "Healing numeric display is out of sync")
		health.take_damage(65)
		health.reset_to_full()
		_expect(is_equal_approx(health_bar.value, 100.0), "Health reset did not restore the bar")
		_expect(health_value.text == "100 / 100", "Health reset numeric display is out of sync")
	_expect(stamina != null and stamina_bar != null and stamina_value != null, "Stamina HUD was removed")
	if stamina != null and stamina_bar != null and stamina_value != null:
		stamina.try_consume_dash()
		_expect(is_equal_approx(stamina_bar.value, 75.0), "Stamina bar stopped following its component")
		_expect(stamina_value.text == "075 / 100", "Stamina numeric display changed")
	_expect(
		main.has_node("Interface/DebugHudRoot/Panel/Content/ActionScroll/ActionDebug"),
		"Debug HUD structure was changed"
	)
	main.queue_free()
	await process_frame


func _test_health_component_rebinding() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	get_root().add_child(main)
	await process_frame
	var original_health: HealthComponent = main.get_node(
		"World/Player/HealthComponent"
	) as HealthComponent
	var health_hud: PlayerHealthHud = main.get_node(
		"HUD/HealthContainer"
	) as PlayerHealthHud
	var health_bar: ProgressBar = main.get_node(
		"HUD/HealthContainer/HealthBar"
	) as ProgressBar
	var health_value: Label = main.get_node(
		"HUD/HealthContainer/HealthValue"
	) as Label
	var replacement_health: HealthComponent = HealthComponent.new()
	replacement_health.max_health = 60
	main.add_child(replacement_health)
	health_hud.bind_health_component(replacement_health)
	_expect(health_hud.health_component == replacement_health, "Health HUD did not retain its new binding")
	_expect(is_equal_approx(health_bar.max_value, 60.0), "Rebinding did not update the Health maximum")
	_expect(health_value.text == "060 / 060", "Rebinding did not initialize the new component value")
	original_health.take_damage(50)
	_expect(health_value.text == "060 / 060", "Old Health component still updates the rebound HUD")
	replacement_health.take_damage(15)
	_expect(is_equal_approx(health_bar.value, 45.0), "New Health component did not update the rebound bar")
	_expect(health_value.text == "045 / 060", "Rebound Health numeric display is out of sync")
	main.queue_free()
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PLAYER_HEALTH_HUD_TEST: PASS (initial, signals, reset, rebind, Stamina regression)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("PLAYER_HEALTH_HUD_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
