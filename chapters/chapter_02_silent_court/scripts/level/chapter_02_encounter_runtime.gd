class_name Chapter02EncounterRuntime
extends Node2D

## Finite Chapter II encounter composition. Spawn anchors use global foot positions;
## grounded scene origins are converted once by the shared 28 px actor-foot offset.

const GROUND_ORIGIN_OFFSET: Vector2 = Vector2(0.0, -28.0)
const ACTIVATION_RANGE_X: float = 720.0
const ACTIVATION_RANGE_Y: float = 430.0
const UPDATE_INTERVAL: float = 0.15

const RETAINER: PackedScene = preload("res://chapters/chapter_02_silent_court/scenes/enemies/hollow_retainer.tscn")
const HALBERDIER: PackedScene = preload("res://chapters/chapter_02_silent_court/scenes/enemies/court_halberdier.tscn")
const ARMOR: PackedScene = preload("res://chapters/chapter_02_silent_court/scenes/enemies/mourning_armor.tscn")
const ACOLYTE: PackedScene = preload("res://chapters/chapter_02_silent_court/scenes/enemies/blood_candle_acolyte.tscn")
const STALKER: PackedScene = preload("res://chapters/chapter_02_silent_court/scenes/enemies/hanging_stalker.tscn")
const SHIELD_GUARD: PackedScene = preload("res://shared/scenes/enemies/cursed_shield_guard.tscn")
const CROSSBOWMAN: PackedScene = preload("res://shared/scenes/enemies/fallen_crossbowman.tscn")
const GARGOYLE: PackedScene = preload("res://shared/scenes/enemies/gargoyle_sentinel.tscn")

@export_node_path("Player") var player_path: NodePath
@export_node_path("Node2D") var enemies_parent_path: NodePath

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var enemies_parent: Node2D = get_node_or_null(enemies_parent_path) as Node2D

var _groups: Array[Node2D] = []
var _update_timer: float = 0.0


func _ready() -> void:
	if player == null or enemies_parent == null:
		push_error("Chapter02EncounterRuntime requires Player and GameplayWorld/Enemies")
		set_process(false)
		return
	_build_encounters()


func _process(delta: float) -> void:
	_update_timer = maxf(0.0, _update_timer - delta)
	if _update_timer > 0.0:
		return
	_update_timer = UPDATE_INTERVAL
	for group: Node2D in _groups:
		var center: Vector2 = group.get_meta("activation_center", Vector2.ZERO) as Vector2
		var engaged: bool = (
			absf(player.global_position.x - center.x) <= ACTIVATION_RANGE_X
			and absf(player.global_position.y - center.y) <= ACTIVATION_RANGE_Y
		)
		_set_group_active(group, engaged)


func get_encounter_count() -> int:
	return _groups.size()


func get_enemy_count() -> int:
	var count: int = 0
	for group: Node2D in _groups:
		count += group.get_child_count()
	return count


func _build_encounters() -> void:
	for data: Dictionary in _encounter_definitions():
		var group: Node2D = Node2D.new()
		group.name = String(data["id"])
		group.set_meta("floor", int(data["floor"]))
		group.set_meta("activation_center", data["center"] as Vector2)
		enemies_parent.add_child(group)
		_groups.append(group)
		var spawns: Array = data["spawns"] as Array
		for index: int in range(spawns.size()):
			var spawn: Dictionary = spawns[index] as Dictionary
			_spawn_enemy(group, spawn, index + 1)
		_set_group_active(group, false)


func _spawn_enemy(group: Node2D, spawn: Dictionary, index: int) -> void:
	var scene: PackedScene = spawn["scene"] as PackedScene
	var enemy: Node2D = scene.instantiate() as Node2D
	if enemy == null:
		push_error("Unable to instantiate Chapter II enemy for %s" % group.name)
		return
	var role: String = String(spawn["role"])
	enemy.name = "%s_%02d_%s" % [group.name, index, role]
	group.add_child(enemy)
	var foot_position: Vector2 = spawn["position"] as Vector2
	var airborne: bool = bool(spawn.get("airborne", false))
	enemy.global_position = foot_position if airborne else foot_position + GROUND_ORIGIN_OFFSET
	enemy.set_meta("authored_foot_position", foot_position)
	enemy.set_meta("spawn_uses_global_position", true)


func _set_group_active(group: Node2D, active: bool) -> void:
	for child: Node in group.get_children():
		if child.has_method("set_ai_active"):
			child.call("set_ai_active", active)


func _spawn(scene: PackedScene, role: String, position: Vector2, airborne: bool = false) -> Dictionary:
	return {"scene": scene, "role": role, "position": position, "airborne": airborne}


func _encounter_definitions() -> Array[Dictionary]:
	return [
		{"id": "EncounterE01", "floor": 1, "center": Vector2(1760, 612), "spawns": [_spawn(RETAINER, "HollowRetainer", Vector2(1760, 612))]},
		{"id": "EncounterE02", "floor": 1, "center": Vector2(2520, 612), "spawns": [_spawn(RETAINER, "HollowRetainer", Vector2(2380, 612)), _spawn(RETAINER, "HollowRetainer", Vector2(2690, 612))]},
		{"id": "EncounterE03", "floor": 1, "center": Vector2(3300, 612), "spawns": [_spawn(RETAINER, "HollowRetainer", Vector2(3180, 612)), _spawn(HALBERDIER, "CourtHalberdier", Vector2(3460, 612))]},
		{"id": "EncounterE04", "floor": 1, "center": Vector2(4740, 612), "spawns": [_spawn(ARMOR, "MourningArmor", Vector2(4580, 612)), _spawn(SHIELD_GUARD, "CursedShieldGuard", Vector2(4920, 612))]},
		{"id": "EncounterE05", "floor": 1, "center": Vector2(4980, 612), "spawns": [_spawn(RETAINER, "HollowRetainer", Vector2(4740, 612)), _spawn(HALBERDIER, "CourtHalberdier", Vector2(5000, 612)), _spawn(ARMOR, "MourningArmor", Vector2(5220, 612))]},
		{"id": "EncounterE06", "floor": 1, "center": Vector2(6100, 160), "spawns": [_spawn(RETAINER, "HollowRetainer", Vector2(6540, 26)), _spawn(HALBERDIER, "CourtHalberdier", Vector2(5000, -288)), _spawn(SHIELD_GUARD, "CursedShieldGuard", Vector2(5580, 506))]},
		{"id": "EncounterE07", "floor": 2, "center": Vector2(6060, -288), "spawns": [_spawn(STALKER, "HangingStalker", Vector2(6020, -720), true), _spawn(CROSSBOWMAN, "FallenCrossbowman", Vector2(6260, -288))]},
		{"id": "EncounterE08", "floor": 2, "center": Vector2(5200, -288), "spawns": [_spawn(STALKER, "HangingStalker", Vector2(5100, -720), true), _spawn(RETAINER, "HollowRetainer", Vector2(5320, -288)), _spawn(CROSSBOWMAN, "FallenCrossbowman", Vector2(5560, -288))]},
		{"id": "EncounterE09", "floor": 2, "center": Vector2(4000, -288), "spawns": [_spawn(ACOLYTE, "BloodCandleAcolyte", Vector2(3860, -288)), _spawn(HALBERDIER, "CourtHalberdier", Vector2(4140, -288)), _spawn(RETAINER, "HollowRetainer", Vector2(4380, -288))]},
		{"id": "EncounterE10", "floor": 2, "center": Vector2(2920, -288), "spawns": [_spawn(STALKER, "HangingStalker", Vector2(2760, -720), true), _spawn(ACOLYTE, "BloodCandleAcolyte", Vector2(3020, -288))]},
		{"id": "EncounterE11", "floor": 2, "center": Vector2(1840, -288), "spawns": [_spawn(ACOLYTE, "BloodCandleAcolyte", Vector2(1680, -288)), _spawn(HALBERDIER, "CourtHalberdier", Vector2(1940, -288)), _spawn(STALKER, "HangingStalker", Vector2(2020, -720), true)]},
		{"id": "EncounterE12", "floor": 2, "center": Vector2(720, -288), "spawns": [_spawn(RETAINER, "HollowRetainer", Vector2(560, -288)), _spawn(HALBERDIER, "CourtHalberdier", Vector2(820, -288))]},
		{"id": "EncounterE13", "floor": 3, "center": Vector2(1600, -1188), "spawns": [_spawn(RETAINER, "HollowRetainer", Vector2(1320, -1188)), _spawn(HALBERDIER, "CourtHalberdier", Vector2(1580, -1188)), _spawn(GARGOYLE, "GargoyleSentinel", Vector2(1840, -1460), true), _spawn(CROSSBOWMAN, "FallenCrossbowman", Vector2(2040, -1188))]},
		{"id": "EncounterE14", "floor": 3, "center": Vector2(2300, -1188), "spawns": [_spawn(ARMOR, "MourningArmor", Vector2(2160, -1188)), _spawn(ACOLYTE, "BloodCandleAcolyte", Vector2(2420, -1188)), _spawn(STALKER, "HangingStalker", Vector2(2520, -1620), true)]},
		{"id": "EncounterE15", "floor": 3, "center": Vector2(2860, -1188), "spawns": [_spawn(SHIELD_GUARD, "CursedShieldGuard", Vector2(2700, -1188)), _spawn(HALBERDIER, "CourtHalberdier", Vector2(2940, -1188)), _spawn(RETAINER, "HollowRetainer", Vector2(3180, -1188))]},
	]
