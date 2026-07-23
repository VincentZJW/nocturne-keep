class_name CombatTestRoom
extends Node2D

## Internal-only one-enemy laboratory with optional combat-shape visualization.

@export_node_path("Player") var player_path: NodePath = NodePath("World/Player")
@export_node_path("CastleGuard") var enemy_path: NodePath = NodePath("World/CastleGuard")
@export_node_path("Label") var debug_label_path: NodePath = NodePath("Interface/Panel/DebugLabel")
@export_node_path("CheckButton") var debug_toggle_path: NodePath = NodePath(
	"Interface/Panel/DebugToggle"
)
@export_node_path("Button") var reset_button_path: NodePath = NodePath("Interface/Panel/ResetButton")

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var enemy: CastleGuard = get_node_or_null(enemy_path) as CastleGuard
@onready var debug_label: Label = get_node_or_null(debug_label_path) as Label
@onready var debug_toggle: CheckButton = get_node_or_null(debug_toggle_path) as CheckButton
@onready var reset_button: Button = get_node_or_null(reset_button_path) as Button

var debug_visuals_enabled: bool = true


func _ready() -> void:
	if player == null or enemy == null or debug_label == null or debug_toggle == null or reset_button == null:
		push_error("CombatTestRoom scene composition is incomplete")
		set_process(false)
		return
	debug_toggle.toggled.connect(_on_debug_toggled)
	reset_button.pressed.connect(_on_reset_pressed)
	debug_visuals_enabled = debug_toggle.button_pressed
	if OS.get_cmdline_user_args().has("--combat-demo"):
		player.global_position = enemy.global_position + Vector2(-90.0, 0.0)
	queue_redraw()


func _process(_delta: float) -> void:
	var player_health: HealthComponent = player.health_component
	var enemy_health: HealthComponent = enemy.health_component
	debug_label.text = (
		"PLAYER HP %d/%d  STATE %s  ANIM %s\n"
		+ "GUARD HP %d/%d  STATE %s  ANIM %s\n"
		+ "PLAYER HIT A:%s D:%s  GUARD SWORD:%s  FACING %s"
	) % [
		player_health.current_health,
		player_health.max_health,
		player.get_life_state_name(),
		player.animation_controller.animated_sprite.animation,
		enemy_health.current_health,
		enemy_health.max_health,
		enemy.get_state_name(),
		enemy.animated_sprite.animation,
		"ON" if player.action_controller.attack_hitbox.is_active else "off",
		"ON" if player.action_controller.dash_attack_hitbox.is_active else "off",
		"ON" if enemy.is_attack_window_active() else "off",
		"LEFT" if enemy.facing_direction < 0.0 else "RIGHT",
	]
	if debug_visuals_enabled:
		queue_redraw()


func _draw() -> void:
	if not debug_visuals_enabled or player == null or enemy == null:
		return
	_draw_hurtbox(player.hurtbox, Color(0.30, 0.72, 1.0, 0.72))
	_draw_hurtbox(enemy.hurtbox, Color(0.92, 0.38, 0.42, 0.72))
	_draw_hitbox(player.action_controller.attack_hitbox, Color(0.55, 0.88, 1.0, 0.90))
	_draw_hitbox(player.action_controller.dash_attack_hitbox, Color(0.95, 0.72, 0.28, 0.90))
	_draw_hitbox(enemy.attack_hitbox, Color(1.0, 0.28, 0.22, 0.90))
	draw_circle(enemy.global_position, enemy.config.detection_range, Color(0.32, 0.42, 0.52, 0.28), false, 1.0)
	draw_line(
		Vector2(enemy.global_position.x - enemy.config.patrol_half_width, enemy.global_position.y + 32.0),
		Vector2(enemy.global_position.x + enemy.config.patrol_half_width, enemy.global_position.y + 32.0),
		Color(0.72, 0.51, 0.26, 0.75),
		1.0
	)


func _draw_hurtbox(hurtbox_component: HurtboxComponent, color: Color) -> void:
	if hurtbox_component == null or not hurtbox_component.is_enabled:
		return
	var collision_shape: CollisionShape2D = hurtbox_component.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	if collision_shape == null:
		return
	var rectangle: RectangleShape2D = collision_shape.shape as RectangleShape2D
	if rectangle != null:
		draw_rect(Rect2(collision_shape.global_position - rectangle.size * 0.5, rectangle.size), color, false, 1.0)


func _draw_hitbox(hitbox_component: HitboxComponent, color: Color) -> void:
	if hitbox_component == null or not hitbox_component.is_active:
		return
	var collision_shape: CollisionShape2D = hitbox_component.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	if collision_shape == null:
		return
	var rectangle: RectangleShape2D = collision_shape.shape as RectangleShape2D
	if rectangle != null:
		draw_rect(Rect2(collision_shape.global_position - rectangle.size * 0.5, rectangle.size), color, false, 2.0)


func _on_debug_toggled(enabled: bool) -> void:
	debug_visuals_enabled = enabled
	queue_redraw()


func _on_reset_pressed() -> void:
	get_tree().reload_current_scene()
