class_name MainEnemyDebugOverlay
extends Label

## Main-scene-only live audit for mixed authored encounters.

@export var debug_visible: bool = true
@export var compact_mode: bool = true
@export var details_expanded: bool = false
@export_range(0.10, 0.20, 0.01) var refresh_interval: float = 0.15
@export_node_path("Node2D") var encounters_root_path: NodePath = NodePath("../../../World/Encounters")
@export_node_path("FallenGateKnight") var boss_path: NodePath

@onready var encounters_root: Node2D = get_node_or_null(encounters_root_path) as Node2D
@onready var boss: FallenGateKnight = get_node_or_null(boss_path) as FallenGateKnight if not boss_path.is_empty() else null

var _refresh_accumulator: float = 0.0


func _ready() -> void:
	if encounters_root == null:
		push_error("MainEnemyDebugOverlay requires an Encounters root")
		set_process(false)
		return
	set_debug_visible(debug_visible)


func _process(delta: float) -> void:
	_refresh_accumulator += delta
	if _refresh_accumulator < refresh_interval:
		return
	_refresh_accumulator = 0.0
	_refresh_text()


func set_debug_visible(enabled: bool) -> void:
	debug_visible = enabled
	visible = enabled
	set_process(enabled)
	if enabled:
		_refresh_accumulator = 0.0
		_refresh_text()


func set_compact_mode(enabled: bool) -> void:
	compact_mode = enabled
	_refresh_text()


func set_details_expanded(enabled: bool) -> void:
	details_expanded = enabled
	_refresh_text()


func _refresh_text() -> void:
	if encounters_root == null:
		return
	if compact_mode and not details_expanded:
		text = _build_compact_text()
	else:
		text = _build_expanded_text()


func _build_compact_text() -> String:
	var encounter: EncounterGroup = _get_current_encounter()
	if encounter == null:
		return "ENC -- | ALIVE 0 | ENGAGED 0 | ATK 0/0\nNO AUTHORED ENEMIES"
	var short_name: String = String(encounter.encounter_name).replace("EncounterGroup", "")
	var type_counts: Dictionary[String, int] = {}
	var shield_summaries: PackedStringArray = []
	for enemy: EnemyCombatant in encounter.get_enemies():
		if not is_instance_valid(enemy) or enemy.is_dead():
			continue
		var type_name: String = _get_short_enemy_name(enemy.get_enemy_type_name())
		type_counts[type_name] = type_counts.get(type_name, 0) + 1
		var shield_guard: CursedShieldGuard = enemy as CursedShieldGuard
		if shield_guard != null:
			shield_summaries.append(shield_guard.get_compact_debug_summary())
	var type_parts: PackedStringArray = []
	for type_name: String in type_counts:
		type_parts.append("%s ×%d" % [type_name, type_counts[type_name]])
	var roster_text: String = "NO LIVING ENEMIES" if type_parts.is_empty() else " | ".join(type_parts)
	var summary: String = (
		"ENC %s | ALIVE %d | ENGAGED %d | ATK %d/%d\n%s"
	) % [
		short_name,
		encounter.get_alive_enemy_count(),
		encounter.get_engaged_enemy_count(),
		encounter.get_attacking_enemy_count(),
		encounter.simultaneous_attack_limit,
		roster_text,
	]
	if not shield_summaries.is_empty():
		summary += "\n" + "\n".join(shield_summaries)
	return summary


func _build_expanded_text() -> String:
	var lines: PackedStringArray = []
	if boss != null and is_instance_valid(boss):
		lines.append("BOSS  %s  ROOM %s  DEAD %s" % [
			boss.get_debug_summary(), "locked" if boss.room_engaged else "open",
			"yes" if boss.is_dead() else "no",
		])
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
	return "\n".join(lines) if not lines.is_empty() else "NO AUTHORED ENEMIES"


func _get_current_encounter() -> EncounterGroup:
	var first_encounter: EncounterGroup = null
	var latest_activated: EncounterGroup = null
	for child: Node in encounters_root.get_children():
		var encounter: EncounterGroup = child as EncounterGroup
		if encounter == null:
			continue
		if first_encounter == null:
			first_encounter = encounter
		if encounter.is_activated:
			latest_activated = encounter
	return latest_activated if latest_activated != null else first_encounter


func _get_short_enemy_name(enemy_type: StringName) -> String:
	match enemy_type:
		&"CursedCastleGuard":
			return "Guard"
		&"CursedShieldGuard":
			return "Shield Guard"
		&"DecayedSpearman":
			return "Spearman"
		&"FallenCrossbowman":
			return "Crossbowman"
		&"GargoyleSentinel":
			return "Gargoyle"
		_:
			return String(enemy_type)
