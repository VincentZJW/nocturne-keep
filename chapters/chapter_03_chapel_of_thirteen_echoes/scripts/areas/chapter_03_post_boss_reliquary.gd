class_name Chapter03PostBossReliquary
extends Node2D

## Owns the physical post-Boss reward and descent seal presentation. Inventory
## mutation is delegated to the composed WeaponPickup and EquipmentManager.

signal reliquary_opened
signal reward_collection_requested(player: Player)
signal reward_collected(weapon_id: StringName)
signal descent_unlocked

const REWARD_WEAPON_ID: StringName = &"thirteenfold_absolution_blades"
const FLAG_RELIQUARY_OPENED: StringName = &"chapter_03_reliquary_opened"
const FLAG_REWARD_SPAWNED: StringName = &"chapter_03_boss_reward_spawned"
const FLAG_REWARD_COLLECTED: StringName = &"chapter_03_boss_reward_collected"
const FLAG_UNDERKEEP_UNLOCKED: StringName = &"chapter_03_underkeep_descent_unlocked"

@onready var pickup: WeaponPickup = $ThirteenfoldAbsolutionPickup as WeaponPickup
@onready var empty_reliquary: Sprite2D = $ReliquaryEmpty as Sprite2D
@onready var sealed_gate: Sprite2D = $DescentSeal/Sealed as Sprite2D
@onready var open_gate: Sprite2D = $DescentSeal/Open as Sprite2D
@onready var descent_blocker: CollisionShape2D = (
	$DescentBlocker/CollisionShape2D as CollisionShape2D
)

var _is_revealed: bool = false
var _reward_collected: bool = false


func _ready() -> void:
	pickup.weapon_collected.connect(_on_weapon_collected)
	empty_reliquary.visible = true
	open_gate.visible = false
	descent_blocker.set_deferred("disabled", false)
	visible = false
	pickup.set_available(false)


func reveal_after_boss() -> void:
	if _is_revealed:
		return
	_is_revealed = true
	visible = true
	var session: ChapterSessionState = _session()
	if session != null:
		session.boss_reward_spawned = true
		session.set_story_flag(FLAG_REWARD_SPAWNED)
	var inventory: PlayerWeaponInventory = _inventory()
	var already_collected: bool = (
		(session != null and session.has_story_flag(FLAG_REWARD_COLLECTED))
		or (inventory != null and inventory.owns_weapon(REWARD_WEAPON_ID))
	)
	if already_collected:
		notify_reward_collected()
	else:
		pickup.set_available(true)
	reliquary_opened.emit()


func notify_reward_collected() -> void:
	if _reward_collected:
		return
	_reward_collected = true
	pickup.set_available(false)
	var session: ChapterSessionState = _session()
	if session != null:
		session.boss_reward_collected = true
		session.set_story_flag(FLAG_RELIQUARY_OPENED)
		session.set_story_flag(FLAG_REWARD_COLLECTED)
		session.set_story_flag(FLAG_UNDERKEEP_UNLOCKED)
	sealed_gate.visible = false
	open_gate.visible = true
	descent_blocker.set_deferred("disabled", true)
	descent_unlocked.emit()


func is_reward_collected() -> bool:
	return _reward_collected


func is_reward_available() -> bool:
	return _is_revealed and not _reward_collected and not pickup.is_collected()


func _on_weapon_collected(weapon_id: StringName) -> void:
	if weapon_id != REWARD_WEAPON_ID or _reward_collected:
		return
	notify_reward_collected()
	reward_collected.emit(weapon_id)


# Compatibility helpers retained for older QA capture scripts.
func _on_body_entered(body: Node2D) -> void:
	pickup._on_body_entered(body)


func _on_body_exited(body: Node2D) -> void:
	pickup._on_body_exited(body)


func _session() -> ChapterSessionState:
	return get_node_or_null("/root/ChapterSession") as ChapterSessionState


func _inventory() -> PlayerWeaponInventory:
	return get_node_or_null("/root/WeaponInventory") as PlayerWeaponInventory
