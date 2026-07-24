extends SceneTree

## Deterministic graphical QA capture using the configured F5 Main scene and live Player Dash Hitbox.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	for _frame: int in range(6):
		await physics_frame
	var player: Player = main.get_node_or_null("World/Player") as Player
	var shield: CursedShieldGuard = main.get_node_or_null(
		"World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01"
	) as CursedShieldGuard
	var debug_controller: MainDebugHudController = main.get_node_or_null(
		"Interface"
	) as MainDebugHudController
	if player == null or shield == null or debug_controller == null:
		push_error("Shield Guard Main QA capture cannot resolve live nodes")
		quit(1)
		return
	shield.set_ai_active(false)
	shield.set_facing_direction(-1.0)
	player.global_position = shield.global_position + Vector2(-54.0, 0.0)
	player.velocity = Vector2.ZERO
	for _frame: int in range(4):
		await physics_frame
	var dash_hitbox: HitboxComponent = player.action_controller.dash_attack_hitbox
	dash_hitbox.global_position = shield.global_position + Vector2(-30.0, 0.0)
	# Preserve the default F5 compact HUD so the break cue is judged in real play space.
	debug_controller.set_compact_mode(true)
	for hit_index: int in range(2):
		dash_hitbox.begin_attack(91_001 + hit_index, 2, 1.0)
		if not dash_hitbox.try_hit(shield.hurtbox):
			push_error("Shield Guard Main QA capture Dash Attack %d was rejected" % (hit_index + 1))
			quit(1)
			return
		dash_hitbox.end_attack()
		# First impact proves the 3 -> 1 critical ShieldVisual. The second proves break.
		for _frame: int in range(10):
			await process_frame
	for _frame: int in range(12):
		await process_frame
	quit(0)
