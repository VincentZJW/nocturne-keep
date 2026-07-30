class_name WeaponPickup
extends Area2D

signal weapon_collected(weapon_id: StringName)

@export var weapon_id: StringName = &"ravenfang_daggers"
@export var auto_equip: bool = true
@export var player_interaction_enabled: bool = true

@onready var prompt: Label = get_node_or_null("Prompt") as Label

var _player_in_range: Player
var _collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	set_process_unhandled_input(player_interaction_enabled)
	if prompt != null:
		prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if (
		_collected
		or not player_interaction_enabled
		or _player_in_range == null
		or not _player_in_range.can_process_gameplay_interaction()
		or not event.is_action_pressed("interact")
	):
		return
	collect()
	get_viewport().set_input_as_handled()


func collect() -> bool:
	if _collected:
		return false
	var equipment: PlayerEquipmentManager = get_node_or_null(
		"/root/EquipmentManager"
	) as PlayerEquipmentManager
	var inventory: PlayerWeaponInventory = get_node_or_null(
		"/root/WeaponInventory"
	) as PlayerWeaponInventory
	if equipment == null or inventory == null:
		return false
	var acquired: bool = (
		equipment.acquire_and_equip(weapon_id)
		if auto_equip else inventory.add_weapon(weapon_id)
	)
	if not acquired and not inventory.owns_weapon(weapon_id):
		return false
	_collected = true
	monitoring = false
	visible = false
	weapon_collected.emit(weapon_id)
	return true


func set_available(available: bool) -> void:
	_collected = not available
	visible = available
	set_deferred("monitoring", available and player_interaction_enabled)
	if prompt != null:
		prompt.visible = available and player_interaction_enabled and _player_in_range != null


func set_player_interaction_enabled(enabled: bool) -> void:
	player_interaction_enabled = enabled
	set_process_unhandled_input(enabled)
	if not enabled:
		_player_in_range = null
	set_deferred("monitoring", enabled and not _collected)
	if prompt != null:
		prompt.visible = enabled and not _collected and _player_in_range != null


func is_collected() -> bool:
	return _collected


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null or _collected or not player_interaction_enabled:
		return
	_player_in_range = player
	if prompt != null:
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body != _player_in_range:
		return
	_player_in_range = null
	if prompt != null:
		prompt.visible = false
