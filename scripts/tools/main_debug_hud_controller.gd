class_name MainDebugHudController
extends CanvasLayer

## Main-only presentation controller for development diagnostics.
## It never owns or mutates gameplay state.

signal debug_visibility_changed(is_visible: bool)
signal compact_mode_changed(is_compact: bool)
signal enemy_details_changed(is_expanded: bool)

@export var debug_hud_visible: bool = true
@export var debug_compact_mode: bool = true
@export var enemy_details_expanded: bool = false

@export_node_path("Control") var debug_root_path: NodePath = NodePath("DebugHudRoot")
@export_node_path("Control") var action_panel_path: NodePath = NodePath("DebugHudRoot/Panel")
@export_node_path("PlayerActionDebugOverlay") var action_overlay_path: NodePath = NodePath(
	"DebugHudRoot/Panel/Content/ActionScroll/ActionDebug"
)
@export_node_path("BaseButton") var action_fold_button_path: NodePath = NodePath(
	"DebugHudRoot/Panel/DebugToggle"
)
@export_node_path("Control") var enemy_panel_path: NodePath = NodePath(
	"DebugHudRoot/EnemyDebugPanel"
)
@export_node_path("MainEnemyDebugOverlay") var enemy_overlay_path: NodePath = NodePath(
	"DebugHudRoot/EnemyDebugPanel/Content/EnemyScroll/EnemyDebug"
)
@export_node_path("BaseButton") var enemy_fold_button_path: NodePath = NodePath(
	"DebugHudRoot/EnemyDebugPanel/EnemyDebugToggle"
)

@onready var debug_root: Control = get_node_or_null(debug_root_path) as Control
@onready var action_panel: Control = get_node_or_null(action_panel_path) as Control
@onready var action_overlay: PlayerActionDebugOverlay = get_node_or_null(
	action_overlay_path
) as PlayerActionDebugOverlay
@onready var action_fold_button: BaseButton = get_node_or_null(
	action_fold_button_path
) as BaseButton
@onready var enemy_panel: Control = get_node_or_null(enemy_panel_path) as Control
@onready var enemy_overlay: MainEnemyDebugOverlay = get_node_or_null(
	enemy_overlay_path
) as MainEnemyDebugOverlay
@onready var enemy_fold_button: BaseButton = get_node_or_null(
	enemy_fold_button_path
) as BaseButton


func _ready() -> void:
	if (
		debug_root == null
		or action_panel == null
		or action_overlay == null
		or enemy_panel == null
		or enemy_overlay == null
	):
		push_error("MainDebugHudController requires both Main debug panels and overlays")
		set_process_unhandled_input(false)
		return
	if action_fold_button != null:
		action_fold_button.pressed.connect(toggle_compact_mode)
	if enemy_fold_button != null:
		enemy_fold_button.pressed.connect(toggle_enemy_details)
	get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_command_line_qa_state()
	_apply_all_states()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_toggle_hud"):
		toggle_debug_hud()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"debug_toggle_compact"):
		toggle_compact_mode()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"debug_toggle_enemy_details"):
		toggle_enemy_details()
		get_viewport().set_input_as_handled()


func toggle_debug_hud() -> void:
	set_debug_hud_visible(not debug_hud_visible)


func set_debug_hud_visible(enabled: bool) -> void:
	debug_hud_visible = enabled
	if debug_root != null:
		debug_root.visible = enabled
	if action_overlay != null:
		action_overlay.set_debug_visible(enabled)
	if enemy_overlay != null:
		enemy_overlay.set_debug_visible(enabled)
	debug_visibility_changed.emit(enabled)


func toggle_compact_mode() -> void:
	set_compact_mode(not debug_compact_mode)


func set_compact_mode(enabled: bool) -> void:
	debug_compact_mode = enabled
	if action_overlay != null:
		action_overlay.set_compact_mode(enabled)
	if enemy_overlay != null:
		enemy_overlay.set_compact_mode(enabled)
	_update_fold_buttons()
	_apply_responsive_layout()
	compact_mode_changed.emit(enabled)


func toggle_enemy_details() -> void:
	set_enemy_details_expanded(not enemy_details_expanded)


func set_enemy_details_expanded(enabled: bool) -> void:
	enemy_details_expanded = enabled
	if enemy_overlay != null:
		enemy_overlay.set_details_expanded(enabled)
	_update_fold_buttons()
	_apply_responsive_layout()
	enemy_details_changed.emit(enabled)


func _apply_all_states() -> void:
	set_debug_hud_visible(debug_hud_visible)
	set_compact_mode(debug_compact_mode)
	set_enemy_details_expanded(enemy_details_expanded)


func _apply_responsive_layout() -> void:
	if action_panel == null or enemy_panel == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var action_size: Vector2 = Vector2(340.0, 64.0)
	if not debug_compact_mode:
		action_size = Vector2(minf(780.0, viewport_size.x - 232.0), 126.0)
	action_size.x = minf(action_size.x, viewport_size.x - 24.0)
	action_panel.offset_left = 12.0
	action_panel.offset_top = 12.0
	action_panel.offset_right = 12.0 + action_size.x
	action_panel.offset_bottom = 12.0 + action_size.y

	var enemy_is_expanded: bool = not debug_compact_mode or enemy_details_expanded
	var enemy_size: Vector2 = Vector2(380.0, 68.0)
	if enemy_is_expanded:
		var available_height: float = maxf(120.0, viewport_size.y - action_size.y - 86.0)
		enemy_size = Vector2(
			minf(760.0, viewport_size.x - 24.0),
			minf(360.0, available_height)
		)
	enemy_size.x = minf(enemy_size.x, viewport_size.x - 24.0)
	enemy_panel.offset_left = 12.0
	enemy_panel.offset_top = -50.0 - enemy_size.y
	enemy_panel.offset_right = 12.0 + enemy_size.x
	enemy_panel.offset_bottom = -50.0


func _update_fold_buttons() -> void:
	if action_fold_button != null:
		action_fold_button.text = "+" if debug_compact_mode else "−"
		action_fold_button.tooltip_text = "F2 · Expand Player and Enemy diagnostics" if debug_compact_mode else "F2 · Compact diagnostics"
	if enemy_fold_button != null:
		var enemy_is_expanded: bool = not debug_compact_mode or enemy_details_expanded
		enemy_fold_button.text = "−" if enemy_is_expanded else "+"
		enemy_fold_button.tooltip_text = "F3 · Collapse Enemy details" if enemy_is_expanded else "F3 · Expand Enemy details"


func _apply_command_line_qa_state() -> void:
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	if arguments.has("--debug-expanded"):
		debug_compact_mode = false
		enemy_details_expanded = true
	elif arguments.has("--debug-hidden"):
		debug_hud_visible = false
