class_name RunInventoryHud
extends Control

## Compact, signal-driven coin and equipped-weapon display shared across scenes.

@export_node_path("Label") var coin_label_path: NodePath = NodePath("CoinLabel")
@export_node_path("Label") var weapon_label_path: NodePath = NodePath("WeaponLabel")

@onready var coin_label: Label = get_node_or_null(coin_label_path) as Label
@onready var weapon_label: Label = get_node_or_null(weapon_label_path) as Label


func _ready() -> void:
	if coin_label == null or weapon_label == null:
		push_error("RunInventoryHud requires CoinLabel and WeaponLabel")
		return
	var wallet: CurrencyWallet = _wallet()
	var equipment: PlayerEquipmentManager = _equipment()
	if wallet == null or equipment == null:
		push_error("RunInventoryHud requires CurrencyManager and EquipmentManager")
		return
	wallet.coins_changed.connect(_on_coins_changed)
	equipment.weapon_equipped.connect(_on_weapon_equipped)
	_on_coins_changed(wallet.current_coins, 0)
	_on_weapon_equipped(equipment.get_equipped_weapon())


func _exit_tree() -> void:
	var wallet: CurrencyWallet = _wallet()
	var equipment: PlayerEquipmentManager = _equipment()
	if wallet != null and wallet.coins_changed.is_connected(_on_coins_changed):
		wallet.coins_changed.disconnect(_on_coins_changed)
	if equipment != null and equipment.weapon_equipped.is_connected(_on_weapon_equipped):
		equipment.weapon_equipped.disconnect(_on_weapon_equipped)


func _on_coins_changed(current: int, _delta: int) -> void:
	coin_label.text = "◉ %d" % current


func _on_weapon_equipped(weapon: WeaponData) -> void:
	weapon_label.text = "WPN T%d  %d / %d" % [
		weapon.tier, weapon.normal_attack_damage, weapon.dash_attack_damage,
	]


func _wallet() -> CurrencyWallet:
	return get_node_or_null("/root/CurrencyManager") as CurrencyWallet


func _equipment() -> PlayerEquipmentManager:
	return get_node_or_null("/root/EquipmentManager") as PlayerEquipmentManager
