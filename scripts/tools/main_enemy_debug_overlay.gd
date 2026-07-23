class_name MainEnemyDebugOverlay
extends Label

## Main-scene-only live audit for mixed authored encounters.

@export_node_path("Node2D") var encounters_root_path: NodePath = NodePath("../../../World/Encounters")
@export_node_path("BaseButton") var toggle_button_path: NodePath = NodePath("../EnemyDebugToggle")

@onready var encounters_root: Node2D = get_node_or_null(encounters_root_path) as Node2D
@onready var toggle_button: BaseButton = get_node_or_null(toggle_button_path) as BaseButton


func _ready() -> void:
	if encounters_root == null or toggle_button == null:
		push_error("MainEnemyDebugOverlay requires Encounters and EnemyDebugToggle")
		set_process(false)
		return
	toggle_button.toggled.connect(_on_debug_toggled)
	_on_debug_toggled(toggle_button.button_pressed)


func _process(_delta: float) -> void:
	if not visible:
		return
	var lines: PackedStringArray = []
	for child: Node in encounters_root.get_children():
		var encounter: EncounterGroup = child as EncounterGroup
		if encounter == null:
			continue
		lines.append(
			"%s  ACTIVATED %s  ENGAGED %d  ALIVE %d  ATTACKING %d/%d" % [
				encounter.encounter_name,
				"yes" if encounter.is_activated else "no",
				encounter.get_engaged_enemy_count(),
				encounter.get_alive_enemy_count(),
				encounter.get_attacking_enemy_count(),
				encounter.simultaneous_attack_limit,
			]
		)
		for enemy: EnemyCombatant in encounter.get_enemies():
			if not is_instance_valid(enemy):
				continue
			lines.append("  %s  %s  X %.0f" % [
				enemy.name, enemy.get_debug_summary(), enemy.global_position.x,
			])
	text = "\n".join(lines) if not lines.is_empty() else "NO AUTHORED ENEMIES"


func _on_debug_toggled(enabled: bool) -> void:
	visible = enabled
	set_process(enabled)
