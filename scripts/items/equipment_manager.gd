class_name PlayerEquipmentManager
extends Node

## Resolves equipped weapon data for combat and signal-driven presentation.

signal weapon_equipped(weapon: WeaponData)
signal damage_values_changed(normal_damage: int, dash_damage: int)

const STARTING_WEAPON: WeaponData = preload(
	"res://resources/items/weapons/veilbound_daggers.tres"
)
const RAVENFANG_WEAPON: WeaponData = preload(
	"res://resources/items/weapons/ravenfang_daggers.tres"
)
const CRIMSON_MASQUE_WEAPON: WeaponData = preload(
	"res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_stilettos.tres"
)
const THIRTEENFOLD_ABSOLUTION_WEAPON: WeaponData = preload(
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/"
	+ "thirteenfold_absolution_blades.tres"
)

var equipped_weapon_id: StringName = &"veilbound_daggers"


func _ready() -> void:
	var inventory: PlayerWeaponInventory = _inventory()
	if inventory != null and not inventory.inventory_reset.is_connected(_on_inventory_reset):
		inventory.inventory_reset.connect(_on_inventory_reset)
	call_deferred("_emit_current_weapon")


func equip_weapon(weapon_id: StringName) -> bool:
	var weapon: WeaponData = get_weapon(weapon_id)
	var inventory: PlayerWeaponInventory = _inventory()
	if weapon == null or inventory == null or not inventory.owns_weapon(weapon_id):
		return false
	if equipped_weapon_id == weapon_id:
		_emit_current_weapon()
		return true
	equipped_weapon_id = weapon_id
	_emit_current_weapon()
	return true


func acquire_and_equip(weapon_id: StringName) -> bool:
	var weapon: WeaponData = get_weapon(weapon_id)
	if weapon == null:
		return false
	var inventory: PlayerWeaponInventory = _inventory()
	if inventory == null:
		return false
	inventory.add_weapon(weapon_id)
	return equip_weapon(weapon_id)


func get_equipped_weapon() -> WeaponData:
	var weapon: WeaponData = get_weapon(equipped_weapon_id)
	return weapon if weapon != null else STARTING_WEAPON


func get_normal_attack_damage() -> int:
	return get_equipped_weapon().normal_attack_damage


func get_dash_attack_damage() -> int:
	return get_equipped_weapon().dash_attack_damage


func get_weapon(weapon_id: StringName) -> WeaponData:
	match weapon_id:
		&"veilbound_daggers":
			return STARTING_WEAPON
		&"ravenfang_daggers":
			return RAVENFANG_WEAPON
		&"crimson_masque_stilettos":
			return CRIMSON_MASQUE_WEAPON
		&"thirteenfold_absolution_blades":
			return THIRTEENFOLD_ABSOLUTION_WEAPON
	return null


func reset_for_new_run() -> void:
	var inventory: PlayerWeaponInventory = _inventory()
	if inventory != null:
		inventory.reset_for_new_run()
	equipped_weapon_id = &"veilbound_daggers"
	_emit_current_weapon()


func _on_inventory_reset() -> void:
	equipped_weapon_id = &"veilbound_daggers"
	_emit_current_weapon()


func _emit_current_weapon() -> void:
	var weapon: WeaponData = get_equipped_weapon()
	weapon_equipped.emit(weapon)
	damage_values_changed.emit(weapon.normal_attack_damage, weapon.dash_attack_damage)


func _inventory() -> PlayerWeaponInventory:
	return get_node_or_null("/root/WeaponInventory") as PlayerWeaponInventory
