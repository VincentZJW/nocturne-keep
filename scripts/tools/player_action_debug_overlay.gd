class_name PlayerActionDebugOverlay
extends Label

## Optional diagnostics for the internal Main action laboratory. It owns no gameplay state.

@export var debug_visible: bool = true
@export_node_path("Player") var player_path: NodePath = NodePath("../../../World/Player")
@export_node_path("BaseButton") var toggle_button_path: NodePath = NodePath("../DebugToggle")

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var toggle_button: BaseButton = get_node_or_null(toggle_button_path) as BaseButton


func _ready() -> void:
	if player == null:
		push_error("PlayerActionDebugOverlay requires a Player target")
		set_process(false)
		return
	if toggle_button != null:
		toggle_button.button_pressed = debug_visible
		toggle_button.toggled.connect(_on_debug_toggled)
	visible = debug_visible
	set_process(debug_visible)


func _process(_delta: float) -> void:
	var actions: PlayerActionController = player.action_controller
	var stamina: PlayerStaminaComponent = player.stamina_component
	var response_time: float = actions.get_attack_input_to_hit_time()
	var response_text: String = "--" if response_time < 0.0 else "%.3fs" % response_time
	var regeneration_blocked: bool = actions.is_stamina_regeneration_blocked()
	var hurt: PlayerHurtController = player.hurt_controller
	var health: HealthComponent = player.health_component
	var regeneration_rate: float = stamina.get_regeneration_rate(player.is_on_floor())
	var regeneration_state: String = "BLOCKED" if regeneration_blocked else (
		"GROUND %.1f/s" % regeneration_rate
		if player.is_on_floor()
		else "AIR %.1f/s" % regeneration_rate
	)
	text = (
		"FLOOR %s   STATE %s/%s   AIR DASH / GROUND DASH TYPE %s   DASH #%d   DIR %+.0f   VX %.1f   VY %.1f\n"
		+ "ANIM %s   STAMINA %.1f/%.1f   REGEN %s %.2fs   DASH BUFFER %s (%.2fs)\n"
		+ "COMBO WINDOW %s   USED %s   ATTACK FRAME %d/4   BUFFERED %s   TIMER %.3fs   CHAIN %s   INPUT→HIT %s\n"
		+ "HEALTH %d/%d   LIFE %s   INVULN %.3fs   HURT STUN %.3fs   LAST DAMAGE %d\n"
		+ "LAST SOURCE (%.1f, %.1f)   KNOCKBACK (%.1f, %.1f)"
	) % [
		"true" if player.is_on_floor() else "false",
		actions.get_action_state_name(),
		player.get_movement_state_name(),
		actions.get_dash_type_name(),
		actions.get_current_dash_number(),
		actions.get_dash_direction(),
		player.velocity.x,
		player.velocity.y,
		player.animation_controller.animated_sprite.animation,
		stamina.current_stamina,
		stamina.max_stamina,
		regeneration_state,
		stamina.stamina_regen_timer,
		"true" if actions.is_dash_buffered() else "false",
		actions.get_dash_buffer_remaining(),
		"OPEN" if actions.is_dash_attack_input_window_open() else "closed",
		"true" if actions.is_dash_attack_used() else "false",
		actions.get_current_attack_frame(),
		"true" if actions.is_attack_buffered() else "false",
		actions.get_attack_buffer_remaining(),
		"OPEN" if actions.can_chain_attack() else "closed",
		response_text,
		health.current_health,
		health.max_health,
		player.get_life_state_name(),
		hurt.get_invulnerability_remaining(),
		hurt.get_hurt_stun_remaining(),
		hurt.get_last_damage(),
		hurt.get_last_source_position().x,
		hurt.get_last_source_position().y,
		hurt.get_last_knockback_velocity().x,
		hurt.get_last_knockback_velocity().y,
	]


func _on_debug_toggled(enabled: bool) -> void:
	debug_visible = enabled
	visible = enabled
	set_process(enabled)
