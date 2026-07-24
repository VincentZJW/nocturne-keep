extends SceneTree

## Compact/expanded/hidden and responsive-layout contract for the configured F5 Main HUD.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const TEST_SIZES: Array[Vector2i] = [
	Vector2i(800, 540),
	Vector2i(1280, 664),
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_test_input_map()
	var original_size: Vector2i = get_root().size
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	get_root().add_child(main)
	await process_frame
	await process_frame
	var controller: MainDebugHudController = main.get_node_or_null("Interface") as MainDebugHudController
	var debug_root: Control = main.get_node_or_null("Interface/DebugHudRoot") as Control
	var action_panel: Control = main.get_node_or_null("Interface/DebugHudRoot/Panel") as Control
	var action_debug: PlayerActionDebugOverlay = main.get_node_or_null(
		"Interface/DebugHudRoot/Panel/Content/ActionScroll/ActionDebug"
	) as PlayerActionDebugOverlay
	var enemy_panel: Control = main.get_node_or_null(
		"Interface/DebugHudRoot/EnemyDebugPanel"
	) as Control
	var enemy_debug: MainEnemyDebugOverlay = main.get_node_or_null(
		"Interface/DebugHudRoot/EnemyDebugPanel/Content/EnemyScroll/EnemyDebug"
	) as MainEnemyDebugOverlay
	var damage_button: Button = main.get_node_or_null(
		"Interface/DebugHudRoot/DamageTestButton"
	) as Button
	var health_container: Control = main.get_node_or_null("HUD/HealthContainer") as Control
	var stamina_container: Control = main.get_node_or_null("HUD/StaminaContainer") as Control
	_expect(
		controller != null
		and debug_root != null
		and action_panel != null
		and action_debug != null
		and enemy_panel != null
		and enemy_debug != null
		and damage_button != null
		and health_container != null
		and stamina_container != null,
		"Main compact HUD node contract is incomplete"
	)
	if controller == null or action_debug == null or enemy_debug == null:
		main.queue_free()
		get_root().size = original_size
		_finish()
		return

	_test_default_compact_state(
		controller, debug_root, action_panel, action_debug,
		enemy_panel, enemy_debug, damage_button, health_container, stamina_container
	)
	await _test_expanded_and_hidden_states(
		controller, debug_root, action_debug, enemy_debug, health_container
	)
	await _test_responsive_layout(
		controller, action_panel, enemy_panel, damage_button, health_container, stamina_container
	)
	get_root().size = original_size
	main.queue_free()
	await process_frame
	_finish()


func _test_input_map() -> void:
	var bindings: Dictionary[StringName, Key] = {
		&"debug_toggle_hud": KEY_F1,
		&"debug_toggle_compact": KEY_F2,
		&"debug_toggle_enemy_details": KEY_F3,
	}
	for action: StringName in bindings:
		_expect(InputMap.has_action(action), "%s is missing from Input Map" % action)
		var found_key: bool = false
		for event: InputEvent in InputMap.action_get_events(action):
			var key_event: InputEventKey = event as InputEventKey
			if key_event != null and key_event.keycode == bindings[action]:
				found_key = true
		_expect(found_key, "%s does not use its required function key" % action)


func _test_default_compact_state(
	controller: MainDebugHudController,
	debug_root: Control,
	action_panel: Control,
	action_debug: PlayerActionDebugOverlay,
	enemy_panel: Control,
	enemy_debug: MainEnemyDebugOverlay,
	damage_button: Button,
	health_container: Control,
	stamina_container: Control
) -> void:
	_expect(controller.debug_hud_visible, "Debug HUD is not visible by default")
	_expect(controller.debug_compact_mode, "Compact mode is not enabled by default")
	_expect(not controller.enemy_details_expanded, "Enemy details are expanded by default")
	_expect(debug_root.visible, "Default debug root is hidden")
	for required: String in ["PLAYER", "STATE", "HP", "STA", "VX", "VY", "DASH", "HURT", "INV"]:
		_expect(action_debug.text.contains(required), "Compact Player summary omits %s" % required)
	_expect(not action_debug.text.contains("COMBO WINDOW"), "Compact Player summary exposes expanded fields")
	for required: String in ["ENC", "ALIVE", "ENGAGED", "ATK"]:
		_expect(enemy_debug.text.contains(required), "Compact Enemy summary omits %s" % required)
	_expect(not enemy_debug.text.contains("ACTIVATED"), "Compact Enemy summary exposes expanded fields")
	_expect(action_panel.size.x <= 340.5 and action_panel.size.y <= 64.5, "Player compact panel exceeds 340×64")
	_expect(enemy_panel.size.x <= 380.5 and enemy_panel.size.y <= 68.5, "Enemy compact panel exceeds 380×68")
	_expect(is_equal_approx(health_container.size.x, 196.0), "Health HUD is not 196 pixels wide")
	_expect(is_equal_approx(stamina_container.size.x, 196.0), "Stamina HUD is not 196 pixels wide")
	_expect(damage_button.size.x <= 120.5 and damage_button.size.y <= 28.5, "Damage test button is not compact")


func _test_expanded_and_hidden_states(
	controller: MainDebugHudController,
	debug_root: Control,
	action_debug: PlayerActionDebugOverlay,
	enemy_debug: MainEnemyDebugOverlay,
	health_container: Control
) -> void:
	await _press_input_action(&"debug_toggle_compact")
	_expect(not controller.debug_compact_mode, "F2 did not switch to Expanded mode")
	for required: String in [
		"COMBO WINDOW", "ATTACK FRAME", "BUFFERED", "LAST SOURCE", "KNOCKBACK",
	]:
		_expect(action_debug.text.contains(required), "Expanded Player details omit %s" % required)
	for required: String in ["ACTIVATED", "ENGAGED", "ALIVE", "ATTACKING", "HP", "ANIM"]:
		_expect(enemy_debug.text.contains(required), "Expanded Enemy details omit %s" % required)
	await _press_input_action(&"debug_toggle_compact")
	await _press_input_action(&"debug_toggle_enemy_details")
	_expect(controller.enemy_details_expanded, "F3 did not expand Enemy details")
	_expect(enemy_debug.text.contains("ACTIVATED"), "F3-style Enemy-only expansion did not reveal details")
	_expect(not action_debug.text.contains("COMBO WINDOW"), "Enemy-only expansion also expanded Player details")
	await _press_input_action(&"debug_toggle_enemy_details")
	await _press_input_action(&"debug_toggle_hud")
	_expect(not debug_root.visible, "F1-style Debug hide did not hide the root")
	_expect(not action_debug.is_processing(), "Hidden Player Debug still processes")
	_expect(not enemy_debug.is_processing(), "Hidden Enemy Debug still processes")
	_expect(health_container.visible, "Debug visibility incorrectly controls formal Health HUD")
	await _press_input_action(&"debug_toggle_hud")
	_expect(debug_root.visible, "Second F1 press did not restore Debug HUD")


func _press_input_action(action: StringName) -> void:
	var pressed_event: InputEventAction = InputEventAction.new()
	pressed_event.action = action
	pressed_event.pressed = true
	Input.parse_input_event(pressed_event)
	await process_frame
	var released_event: InputEventAction = InputEventAction.new()
	released_event.action = action
	released_event.pressed = false
	Input.parse_input_event(released_event)
	await process_frame


func _test_responsive_layout(
	controller: MainDebugHudController,
	action_panel: Control,
	enemy_panel: Control,
	damage_button: Button,
	health_container: Control,
	stamina_container: Control
) -> void:
	var original_content_scale_size: Vector2i = get_root().content_scale_size
	get_root().content_scale_size = Vector2i.ZERO
	for test_size: Vector2i in TEST_SIZES:
		get_root().size = test_size
		await process_frame
		await process_frame
		var ui_size: Vector2i = Vector2i(get_root().get_visible_rect().size)
		controller.set_compact_mode(true)
		controller.set_enemy_details_expanded(false)
		await process_frame
		for control: Control in [action_panel, enemy_panel, damage_button, health_container, stamina_container]:
			_expect(_is_inside_viewport(control, ui_size), "%s leaves %s UI viewport at window %s" % [control.name, ui_size, test_size])
		_expect(not action_panel.get_global_rect().intersects(health_container.get_global_rect()), "Player Debug overlaps Health at %s" % test_size)
		_expect(not enemy_panel.get_global_rect().intersects(damage_button.get_global_rect()), "Enemy Debug overlaps damage button at %s" % test_size)
		controller.set_compact_mode(false)
		await process_frame
		_expect(_is_inside_viewport(action_panel, ui_size), "Expanded Player panel leaves %s UI viewport at window %s" % [ui_size, test_size])
		_expect(_is_inside_viewport(enemy_panel, ui_size), "Expanded Enemy panel leaves %s UI viewport at window %s" % [ui_size, test_size])
		_expect(not action_panel.get_global_rect().intersects(health_container.get_global_rect()), "Expanded Player Debug overlaps Health at %s" % test_size)
		_expect(not action_panel.get_global_rect().intersects(enemy_panel.get_global_rect()), "Expanded debug panels overlap at %s" % test_size)
	controller.set_compact_mode(true)
	get_root().content_scale_size = original_content_scale_size
	await process_frame


func _is_inside_viewport(control: Control, viewport_size: Vector2i) -> bool:
	var rect: Rect2 = control.get_global_rect()
	return (
		rect.position.x >= -0.5
		and rect.position.y >= -0.5
		and rect.end.x <= float(viewport_size.x) + 0.5
		and rect.end.y <= float(viewport_size.y) + 0.5
	)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("MAIN_DEBUG_HUD_TEST: PASS (compact, expanded, hidden, F1/F2/F3, responsive layout)")
		quit(0)
		return
	for failure: String in _failures:
		push_error("MAIN_DEBUG_HUD_TEST: %s" % failure)
	quit(1)
