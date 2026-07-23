class_name MainEnemyDebugOverlay
extends Label

## Main-scene-only live audit for the first melee enemy instances.

@export_node_path("Node2D") var enemies_root_path: NodePath = NodePath("../../../World/Enemies")
@export_node_path("BaseButton") var toggle_button_path: NodePath = NodePath("../EnemyDebugToggle")

@onready var enemies_root: Node2D = get_node_or_null(enemies_root_path) as Node2D
@onready var toggle_button: BaseButton = get_node_or_null(toggle_button_path) as BaseButton


func _ready() -> void:
	if enemies_root == null or toggle_button == null:
		push_error("MainEnemyDebugOverlay requires Enemies and EnemyDebugToggle")
		set_process(false)
		return
	toggle_button.toggled.connect(_on_debug_toggled)
	_on_debug_toggled(toggle_button.button_pressed)


func _process(_delta: float) -> void:
	if not visible:
		return
	var lines: PackedStringArray = []
	for child: Node in enemies_root.get_children():
		var guard: CastleGuard = child as CastleGuard
		if guard == null or not is_instance_valid(guard):
			continue
		var health: HealthComponent = guard.health_component
		var sprite: AnimatedSprite2D = guard.animated_sprite
		var has_target: bool = guard.target != null and is_instance_valid(guard.target)
		lines.append(
			(
				"%s  STATE %s  HP %d/%d  ANIM %s:%d  TARGET %s  SWORD %s\n"
				+ "POS (%.1f, %.1f)  VX %.1f  FACING %s  VISIBLE %s"
			) % [
				guard.name,
				guard.get_state_name(),
				health.current_health,
				health.max_health,
				sprite.animation,
				sprite.frame + 1,
				"PLAYER" if has_target else "none",
				"ON" if guard.is_attack_window_active() else "off",
				guard.global_position.x,
				guard.global_position.y,
				guard.velocity.x,
				"LEFT" if guard.facing_direction < 0.0 else "RIGHT",
				"yes" if guard.visible else "no",
			]
		)
	text = "\n".join(lines) if not lines.is_empty() else "NO ACTIVE CURSED CASTLE GUARDS"


func _on_debug_toggled(enabled: bool) -> void:
	visible = enabled
	set_process(enabled)
