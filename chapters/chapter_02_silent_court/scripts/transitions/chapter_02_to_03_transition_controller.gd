class_name Chapter02To03TransitionController
extends Node

## Orchestrates the post-Duchess presentation and gate prerequisites. The Boss
## owns combat/death only; SceneTransitionManager owns scene replacement.

signal reward_spawned
signal reward_collected(weapon_id: StringName)
signal exit_revealed
signal passage_transition_requested

const FLAG_CHAPTER_02_COMPLETED: StringName = &"chapter_02_completed"
const FLAG_DUCHESS_DEFEATED: StringName = &"hollow_duchess_defeated"
const FLAG_EXIT_REVEALED: StringName = &"chapter_02_exit_revealed"
const FLAG_PASSAGE_OPENED: StringName = &"royal_chapel_passage_opened"
const FLAG_REWARD_COLLECTED: StringName = &"chapter_02_boss_weapon_collected"
const REWARD_WEAPON_ID: StringName = &"crimson_masque_stilettos"

@export var transition_data: Chapter02TransitionData
@export var reward_pickup_scene: PackedScene
@export_node_path("Player") var player_path: NodePath
@export_node_path("HollowDuchess") var boss_path: NodePath
@export_node_path("HollowDuchessRoomController") var room_controller_path: NodePath
@export_node_path("HollowDuchessBallroomFx") var ballroom_fx_path: NodePath
@export_node_path("BallroomMirrorGate") var mirror_gate_path: NodePath
@export_node_path("Marker2D") var reward_anchor_path: NodePath
@export_node_path("Node2D") var pickup_parent_path: NodePath
@export_node_path("CrimsonMasqueAcquisitionPanel") var acquisition_panel_path: NodePath

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var boss: HollowDuchess = get_node_or_null(boss_path) as HollowDuchess
@onready var room_controller: HollowDuchessRoomController = get_node_or_null(
	room_controller_path
) as HollowDuchessRoomController
@onready var ballroom_fx: HollowDuchessBallroomFx = get_node_or_null(
	ballroom_fx_path
) as HollowDuchessBallroomFx
@onready var mirror_gate: BallroomMirrorGate = get_node_or_null(
	mirror_gate_path
) as BallroomMirrorGate
@onready var reward_anchor: Marker2D = get_node_or_null(reward_anchor_path) as Marker2D
@onready var pickup_parent: Node2D = get_node_or_null(pickup_parent_path) as Node2D
@onready var acquisition_panel: CrimsonMasqueAcquisitionPanel = get_node_or_null(
	acquisition_panel_path
) as CrimsonMasqueAcquisitionPanel

var _reward_pickup: WeaponPickup
var _sequence_started: bool = false


func _ready() -> void:
	call_deferred("_initialize_transition")


func _initialize_transition() -> void:
	if not _validate_dependencies():
		return
	boss.boss_defeated.connect(_on_boss_defeated)
	mirror_gate.mirror_revealed.connect(_on_mirror_revealed)
	mirror_gate.passage_requested.connect(_on_passage_requested)
	mirror_gate.door_opened.connect(_on_door_opened)
	_apply_persisted_state()


func debug_complete_boss_sequence() -> void:
	_on_boss_defeated()


func get_reward_pickup() -> WeaponPickup:
	return _reward_pickup


func _on_boss_defeated() -> void:
	if _sequence_started:
		return
	_sequence_started = true
	var session: ChapterSessionState = _session()
	if session != null:
		session.set_story_flag(FLAG_DUCHESS_DEFEATED)
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.velocity = Vector2.ZERO
	ballroom_fx.set_defeated()
	boss.visible = false
	_ensure_reward_pickup()
	if not mirror_gate.begin_reveal(transition_data.mirror_reveal_duration):
		_on_mirror_revealed()


func _on_mirror_revealed() -> void:
	var session: ChapterSessionState = _session()
	if session != null:
		session.set_story_flag(FLAG_EXIT_REVEALED)
	mirror_gate.set_interaction_enabled(true)
	if not player.is_dead():
		player.set_input_profile(Player.InputProfile.FULL)
	exit_revealed.emit()


func _on_reward_collected(weapon_id: StringName) -> void:
	if weapon_id != REWARD_WEAPON_ID:
		return
	var session: ChapterSessionState = _session()
	if session != null:
		session.set_story_flag(FLAG_REWARD_COLLECTED)
	var equipment: PlayerEquipmentManager = get_node_or_null(
		"/root/EquipmentManager"
	) as PlayerEquipmentManager
	if acquisition_panel != null and equipment != null:
		acquisition_panel.present(equipment.get_weapon(REWARD_WEAPON_ID))
	reward_collected.emit(weapon_id)


func _on_passage_requested() -> void:
	var session: ChapterSessionState = _session()
	if session == null or not session.has_story_flag(FLAG_DUCHESS_DEFEATED):
		return
	if not session.has_story_flag(FLAG_REWARD_COLLECTED):
		_ensure_reward_pickup()
		mirror_gate.show_message(transition_data.missing_reward_prompt)
		return
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.velocity = Vector2.ZERO
	if not mirror_gate.begin_door_open(transition_data.door_open_duration):
		_on_door_opened()


func _on_door_opened() -> void:
	var session: ChapterSessionState = _session()
	if session == null:
		return
	session.set_story_flag(FLAG_CHAPTER_02_COMPLETED)
	session.set_story_flag(FLAG_PASSAGE_OPENED)
	session.mark_chapter_completed(ChapterRegistry.CHAPTER_02_SILENT_COURT)
	var manager: SceneTransitionManagerState = get_node_or_null(
		"/root/SceneTransitionManager"
	) as SceneTransitionManagerState
	if manager == null:
		push_error("Chapter II exit requires SceneTransitionManager")
		player.set_input_profile(Player.InputProfile.FULL)
		return
	passage_transition_requested.emit()
	if not manager.transition_to_scene(
		transition_data.passage_scene_path,
		transition_data.passage_spawn_id,
		ChapterRegistry.CHAPTER_02_SILENT_COURT,
		transition_data.fade_out_duration,
		transition_data.fade_in_duration
	):
		player.set_input_profile(Player.InputProfile.FULL)


func _apply_persisted_state() -> void:
	var session: ChapterSessionState = _session()
	if session == null or not session.has_story_flag(FLAG_DUCHESS_DEFEATED):
		return
	_sequence_started = true
	room_controller.apply_persisted_clear_state()
	ballroom_fx.set_defeated()
	mirror_gate.reveal_immediately()
	if not session.has_story_flag(FLAG_REWARD_COLLECTED):
		_ensure_reward_pickup()


func _ensure_reward_pickup() -> void:
	var session: ChapterSessionState = _session()
	var inventory: PlayerWeaponInventory = get_node_or_null(
		"/root/WeaponInventory"
	) as PlayerWeaponInventory
	var already_collected: bool = (
		(session != null and session.has_story_flag(FLAG_REWARD_COLLECTED))
		or (inventory != null and inventory.owns_weapon(REWARD_WEAPON_ID))
	)
	if already_collected:
		if session != null:
			session.set_story_flag(FLAG_REWARD_COLLECTED)
		if _reward_pickup != null:
			_reward_pickup.set_available(false)
		return
	if _reward_pickup == null or not is_instance_valid(_reward_pickup):
		_reward_pickup = reward_pickup_scene.instantiate() as WeaponPickup
		if _reward_pickup == null:
			push_error("Chapter II Boss weapon pickup could not be instantiated")
			return
		pickup_parent.add_child(_reward_pickup)
		_reward_pickup.global_position = reward_anchor.global_position
		_reward_pickup.weapon_collected.connect(_on_reward_collected)
	_reward_pickup.set_available(true)
	reward_spawned.emit()


func _session() -> ChapterSessionState:
	return get_node_or_null("/root/ChapterSession") as ChapterSessionState


func _validate_dependencies() -> bool:
	if (
		transition_data == null or not transition_data.is_valid()
		or reward_pickup_scene == null or player == null or boss == null
		or room_controller == null or ballroom_fx == null or mirror_gate == null
		or reward_anchor == null or pickup_parent == null or acquisition_panel == null
	):
		push_error("Chapter02To03TransitionController scene composition is incomplete")
		return false
	return true
