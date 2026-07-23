class_name EnemyVarietyTestRoom
extends Node2D

## Internal mixed-roster lab. F5 Main remains the production verification path.

@export_node_path("Player") var player_path: NodePath = NodePath("World/Player")
@export_node_path("Node2D") var enemies_root_path: NodePath = NodePath("World/Enemies")
@export_node_path("Label") var debug_label_path: NodePath = NodePath("Interface/Panel/DebugLabel")
@export_node_path("CheckButton") var debug_toggle_path: NodePath = NodePath("Interface/Panel/DebugToggle")
@export_node_path("Button") var reset_button_path: NodePath = NodePath("Interface/Panel/ResetButton")

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var enemies_root: Node2D = get_node_or_null(enemies_root_path) as Node2D
@onready var debug_label: Label = get_node_or_null(debug_label_path) as Label
@onready var debug_toggle: CheckButton = get_node_or_null(debug_toggle_path) as CheckButton
@onready var reset_button: Button = get_node_or_null(reset_button_path) as Button

var debug_visuals_enabled: bool = true


func _ready() -> void:
	if player == null or enemies_root == null or debug_label == null or debug_toggle == null or reset_button == null:
		push_error("EnemyVarietyTestRoom scene composition is incomplete")
		set_process(false)
		return
	debug_toggle.toggled.connect(_on_debug_toggled)
	reset_button.pressed.connect(_on_reset_pressed)
	debug_visuals_enabled = debug_toggle.button_pressed
	if OS.get_cmdline_user_args().has("--variety-overview"):
		player.global_position = Vector2(1050.0, 592.0)
		player.set_physics_process(false)
		player.player_camera.enabled = false
		var overview_camera: Camera2D = Camera2D.new()
		overview_camera.position = Vector2(1050.0, 360.0)
		add_child(overview_camera)
		overview_camera.make_current()
		for enemy: EnemyCombatant in get_enemies():
			enemy.set_ai_active(false)
	queue_redraw()


func _process(_delta: float) -> void:
	var lines: PackedStringArray = [
		"PLAYER HP %d/%d  STATE %s  ANIM %s" % [
			player.health_component.current_health,
			player.health_component.max_health,
			player.get_life_state_name(),
			player.animation_controller.animated_sprite.animation,
		],
	]
	for enemy: EnemyCombatant in get_enemies():
		if is_instance_valid(enemy):
			lines.append("%s · %s" % [enemy.name, enemy.get_debug_summary()])
	debug_label.text = "\n".join(lines)
	if debug_visuals_enabled:
		queue_redraw()


func get_enemies() -> Array[EnemyCombatant]:
	var enemies: Array[EnemyCombatant] = []
	if enemies_root == null:
		return enemies
	for child: Node in enemies_root.get_children():
		var enemy: EnemyCombatant = child as EnemyCombatant
		if enemy != null:
			enemies.append(enemy)
	return enemies


func _draw() -> void:
	if not debug_visuals_enabled or player == null:
		return
	_draw_hurtbox(player.hurtbox, Color(0.30, 0.72, 1.0, 0.72))
	_draw_hitbox(player.action_controller.attack_hitbox, Color(0.55, 0.88, 1.0, 0.90))
	_draw_hitbox(player.action_controller.dash_attack_hitbox, Color(0.95, 0.72, 0.28, 0.90))
	for enemy: EnemyCombatant in get_enemies():
		var hurtbox: HurtboxComponent = enemy.get_node_or_null("Hurtbox") as HurtboxComponent
		var hitbox: HitboxComponent = enemy.get_node_or_null("FacingRoot/AttackHitbox") as HitboxComponent
		_draw_hurtbox(hurtbox, Color(0.92, 0.38, 0.42, 0.72))
		_draw_hitbox(hitbox, Color(1.0, 0.28, 0.22, 0.90))


func _draw_hurtbox(hurtbox: HurtboxComponent, color: Color) -> void:
	if hurtbox == null or not hurtbox.is_enabled:
		return
	_draw_collision_rectangle(hurtbox.get_node_or_null("CollisionShape2D") as CollisionShape2D, color, 1.0)


func _draw_hitbox(hitbox: HitboxComponent, color: Color) -> void:
	if hitbox == null or not hitbox.is_active:
		return
	_draw_collision_rectangle(hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D, color, 2.0)


func _draw_collision_rectangle(collision_shape: CollisionShape2D, color: Color, width: float) -> void:
	if collision_shape == null:
		return
	var rectangle: RectangleShape2D = collision_shape.shape as RectangleShape2D
	if rectangle != null:
		draw_rect(Rect2(collision_shape.global_position - rectangle.size * 0.5, rectangle.size), color, false, width)


func _on_debug_toggled(enabled: bool) -> void:
	debug_visuals_enabled = enabled
	queue_redraw()


func _on_reset_pressed() -> void:
	get_tree().reload_current_scene()
