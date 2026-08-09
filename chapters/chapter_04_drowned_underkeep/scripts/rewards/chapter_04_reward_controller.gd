class_name Chapter04RewardController
extends Node2D

## Controls only the Last Soul Lock presentation. Weapon ownership and combat
## values remain authoritative in WeaponPickup/Inventory/EquipmentManager.

signal reward_collected(reward_id: StringName)
signal reward_stage_changed(stage: StringName)

const REWARD_ID: StringName = &"soul_lock_twin_keys"
const FLAG_REWARD_UNLOCKED: StringName = &"ch4_reward_unlocked"
const FLAG_REWARD_COLLECTED: StringName = &"ch4_reward_collected"
const FLAG_PRESENTATION_COMPLETE: StringName = &"ch4_reward_presentation_complete"
const FLAG_MEMORY_PASSAGE_UNLOCKED: StringName = &"ch4_memory_passage_unlocked"

@export_node_path("WeaponPickup") var pickup_path: NodePath = NodePath("WeaponPickup")
@export_node_path("Sprite2D") var reliquary_path: NodePath = NodePath("ReliquaryStage")
@export_node_path("Sprite2D") var chain_path: NodePath = NodePath("ChainPull")
@export_node_path("Sprite2D") var soul_release_path: NodePath = NodePath("SoulRelease")
@export_node_path("Label") var stage_label_path: NodePath = NodePath("StageLabel")
@export_node_path("Label") var obtained_label_path: NodePath = NodePath("ObtainedLabel")
@export_node_path("Chapter04RoomExit") var memory_exit_path: NodePath = NodePath(
	"../Transitions/ExitEast"
)
@export_range(0.1, 2.0, 0.05) var water_settle_duration: float = 1.00
@export_range(0.1, 2.0, 0.05) var soul_release_duration: float = 1.35
@export_range(0.1, 2.0, 0.05) var chain_pull_duration: float = 1.25
@export_range(0.1, 2.0, 0.05) var reliquary_rise_duration: float = 1.45
@export_range(0.1, 2.0, 0.05) var key_formation_duration: float = 1.20
@export_range(0.1, 2.0, 0.05) var inspection_hold_duration: float = 0.85

@onready var pickup: WeaponPickup = get_node(pickup_path) as WeaponPickup
@onready var reliquary: Sprite2D = get_node(reliquary_path) as Sprite2D
@onready var chain_pull: Sprite2D = get_node(chain_path) as Sprite2D
@onready var soul_release: Sprite2D = get_node(soul_release_path) as Sprite2D
@onready var stage_label: Label = get_node(stage_label_path) as Label
@onready var obtained_label: Label = get_node(obtained_label_path) as Label
@onready var memory_exit: Chapter04RoomExit = get_node(memory_exit_path) as Chapter04RoomExit

var _collected: bool = false
var _presentation_running: bool = false
var _presentation_token: int = 0
var _current_stage: StringName = &"locked"
var _player: Player
var _previous_profile: Player.InputProfile = Player.InputProfile.FULL
var _previous_invulnerability: bool = false
var _owns_player_lock: bool = false


func _ready() -> void:
	pickup.weapon_collected.connect(_on_weapon_collected)
	var session: ChapterSessionState = _session()
	var inventory: PlayerWeaponInventory = _inventory()
	_collected = (
		(session != null and session.has_story_flag(FLAG_REWARD_COLLECTED))
		or (inventory != null and inventory.owns_weapon(REWARD_ID))
	)
	var unlocked: bool = (
		session == null
		or session.has_story_flag(FLAG_REWARD_UNLOCKED)
		or _collected
	)
	if _collected:
		_apply_collected_state(false)
		return
	memory_exit.requires_interaction = true
	memory_exit.set_locked(true)
	obtained_label.visible = false
	if not unlocked:
		_set_stage(&"locked", "THE LAST SOUL LOCK ENDURES / 最后的魂锁仍未断裂")
		pickup.set_available(false)
		pickup.set_player_interaction_enabled(false)
		reliquary.visible = false
		chain_pull.visible = false
		soul_release.visible = false
		return
	var presentation_complete: bool = session != null and session.has_story_flag(
		FLAG_PRESENTATION_COMPLETE
	)
	if presentation_complete:
		_show_claimable_state()
	else:
		_prepare_sequence_state()
		call_deferred("_run_reward_sequence")


func _exit_tree() -> void:
	_presentation_token += 1
	_restore_player()


func _prepare_sequence_state() -> void:
	pickup.set_available(false)
	pickup.set_player_interaction_enabled(false)
	reliquary.visible = true
	reliquary.position = Vector2(0, 88)
	reliquary.modulate = Color(0.62, 0.76, 0.79, 0.56)
	chain_pull.visible = false
	soul_release.visible = false
	_set_stage(&"water_settle", "THE WATER FALLS SILENT / 水声正在沉寂")


func _run_reward_sequence() -> void:
	if _presentation_running or _collected:
		return
	_presentation_running = true
	_presentation_token += 1
	var token: int = _presentation_token
	_lock_player()
	await get_tree().create_timer(water_settle_duration).timeout
	if not _sequence_is_valid(token):
		return
	soul_release.visible = true
	_set_stage(&"soul_release", "THE PRISONED NAMES RISE / 被囚的姓名正在升起")
	await get_tree().create_timer(soul_release_duration).timeout
	if not _sequence_is_valid(token):
		return
	chain_pull.visible = true
	_set_stage(&"chain_pull", "THE LAST CHAIN DRAWS TAUT / 最后一条锁链绷紧")
	await get_tree().create_timer(chain_pull_duration).timeout
	if not _sequence_is_valid(token):
		return
	_set_stage(&"reliquary_rise", "THE SOUL-LOCK RELIQUARY ASCENDS / 魂锁遗匣升起")
	var rise_tween: Tween = create_tween()
	rise_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rise_tween.parallel().tween_property(reliquary, "position", Vector2.ZERO, reliquary_rise_duration)
	rise_tween.parallel().tween_property(reliquary, "modulate", Color.WHITE, reliquary_rise_duration)
	await rise_tween.finished
	if not _sequence_is_valid(token):
		return
	chain_pull.visible = false
	soul_release.visible = false
	_set_stage(&"lockbreaker_forms", "LOCKBREAKER · 断狱 / THE PRISON KEY REMEMBERS")
	await get_tree().create_timer(key_formation_duration).timeout
	if not _sequence_is_valid(token):
		return
	_set_stage(&"soulseal_forms", "SOULSEAL · 魂契 / THE COVENANT KEEPS THEIR NAMES")
	await get_tree().create_timer(key_formation_duration).timeout
	if not _sequence_is_valid(token):
		return
	await get_tree().create_timer(inspection_hold_duration).timeout
	if not _sequence_is_valid(token):
		return
	var session: ChapterSessionState = _session()
	if session != null:
		session.set_story_flag(FLAG_PRESENTATION_COMPLETE)
	_presentation_running = false
	_show_claimable_state()
	_restore_player()


func _show_claimable_state() -> void:
	reliquary.visible = true
	reliquary.position = Vector2.ZERO
	reliquary.modulate = Color.WHITE
	chain_pull.visible = false
	soul_release.visible = false
	pickup.set_available(true)
	pickup.set_player_interaction_enabled(true)
	_set_stage(&"claimable", "SOUL-LOCK TWIN KEYS / 魂锁双钥")


func collect_for_qa() -> bool:
	if _collected:
		return false
	if _presentation_running:
		_presentation_token += 1
		_presentation_running = false
		_restore_player()
	_show_claimable_state()
	return pickup.collect()


func is_collected() -> bool:
	return _collected


func is_presentation_running() -> bool:
	return _presentation_running


func get_current_stage() -> StringName:
	return _current_stage


func _on_weapon_collected(weapon_id: StringName) -> void:
	if weapon_id != REWARD_ID or _collected:
		return
	_collected = true
	var session: ChapterSessionState = _session()
	if session != null:
		session.set_story_flag(FLAG_REWARD_UNLOCKED)
		session.set_story_flag(FLAG_PRESENTATION_COMPLETE)
		session.set_story_flag(FLAG_REWARD_COLLECTED)
		session.set_story_flag(FLAG_MEMORY_PASSAGE_UNLOCKED)
	_apply_collected_state(true)
	reward_collected.emit(REWARD_ID)


func _apply_collected_state(show_obtained: bool) -> void:
	_presentation_running = false
	pickup.set_player_interaction_enabled(false)
	pickup.set_available(false)
	reliquary.visible = true
	reliquary.position = Vector2.ZERO
	reliquary.modulate = Color(0.55, 0.62, 0.64, 0.78)
	chain_pull.visible = false
	soul_release.visible = false
	memory_exit.requires_interaction = true
	memory_exit.set_locked(false)
	_set_stage(&"collected", "THE LAST SOUL LOCK IS OPEN / 最后的魂锁已经开启")
	obtained_label.visible = show_obtained
	if show_obtained:
		obtained_label.text = (
			"OBTAINED · SOUL-LOCK TWIN KEYS\n"
			+ "获得 · 魂锁双钥  |  NORMAL 16  ·  DASH 32"
		)
		_hide_obtained_after_delay()
	_restore_player()


func _hide_obtained_after_delay() -> void:
	await get_tree().create_timer(2.8).timeout
	if is_inside_tree() and obtained_label != null:
		obtained_label.visible = false


func _set_stage(stage: StringName, text: String) -> void:
	_current_stage = stage
	stage_label.text = text
	stage_label.visible = true
	set_meta(&"reward_stage", stage)
	reward_stage_changed.emit(stage)


func _lock_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	if _player == null:
		return
	_previous_profile = _player.get_input_profile()
	_previous_invulnerability = _player.hurtbox != null and _player.hurtbox.is_invulnerable
	_owns_player_lock = true
	_player.set_input_profile(Player.InputProfile.LOCKED)
	_player.velocity = Vector2.ZERO
	if _player.hurtbox != null:
		_player.hurtbox.set_invulnerable(true)


func _restore_player() -> void:
	if not _owns_player_lock or _player == null or not is_instance_valid(_player):
		return
	_player.set_input_profile(_previous_profile)
	if _player.hurtbox != null and not _previous_invulnerability:
		_player.hurtbox.set_invulnerable(false)
	_owns_player_lock = false


func _sequence_is_valid(token: int) -> bool:
	return is_inside_tree() and token == _presentation_token and not _collected


func _session() -> ChapterSessionState:
	return get_node_or_null("/root/ChapterSession") as ChapterSessionState


func _inventory() -> PlayerWeaponInventory:
	return get_node_or_null("/root/WeaponInventory") as PlayerWeaponInventory
