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
	text = (
		"STATE %s   ANIM %s   VX %.1f   AIR DASH %s   DASH #%d\n"
		+ "STAMINA %.1f/%.1f   REGEN %.2fs   DASH BUFFER %s (%.2fs)   COMBO WINDOW %s   USED %s\n"
		+ "ATTACK FRAME %d/4   BUFFERED %s   TIMER %.3fs   CHAIN %s   INPUT→HIT %s"
	) % [
		actions.get_action_state_name(),
		player.animation_controller.animated_sprite.animation,
		player.velocity.x,
		"ready" if player.air_dash_available else "spent",
		actions.get_current_dash_number(),
		stamina.current_stamina,
		stamina.max_stamina,
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
	]


func _on_debug_toggled(enabled: bool) -> void:
	debug_visible = enabled
	visible = enabled
	set_process(enabled)
