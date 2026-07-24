class_name PlayerWeaponInventory
extends Node

## Run-persistent owned-weapon ledger; presentation and combat remain elsewhere.

signal weapon_added(weapon_id: StringName)
signal inventory_reset

const STARTING_WEAPON_ID: StringName = &"veilbound_daggers"

var _owned_weapon_ids: Dictionary[StringName, bool] = {}


func _ready() -> void:
	ensure_starting_weapon()


func ensure_starting_weapon() -> void:
	if not owns_weapon(STARTING_WEAPON_ID):
		_owned_weapon_ids[STARTING_WEAPON_ID] = true
		weapon_added.emit(STARTING_WEAPON_ID)


func add_weapon(weapon_id: StringName) -> bool:
	if weapon_id.is_empty() or owns_weapon(weapon_id):
		return false
	_owned_weapon_ids[weapon_id] = true
	weapon_added.emit(weapon_id)
	return true


func owns_weapon(weapon_id: StringName) -> bool:
	return _owned_weapon_ids.has(weapon_id)


func get_owned_weapon_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for key: StringName in _owned_weapon_ids:
		result.append(key)
	result.sort()
	return result


func reset_for_new_run() -> void:
	_owned_weapon_ids.clear()
	ensure_starting_weapon()
	inventory_reset.emit()
