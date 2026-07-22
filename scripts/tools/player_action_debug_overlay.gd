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
	text = "STATE %s   COMBO WINDOW %s (%.2fs)   USED %s   AIR DASH %s   VX %.1f" % [
		actions.get_action_state_name(),
		"OPEN" if actions.is_dash_attack_input_window_open() else "closed",
		actions.get_dash_attack_window_remaining(),
		"true" if actions.is_dash_attack_used() else "false",
		"ready" if player.air_dash_available else "spent",
		player.velocity.x,
	]


func _on_debug_toggled(enabled: bool) -> void:
	debug_visible = enabled
	visible = enabled
	set_process(enabled)
