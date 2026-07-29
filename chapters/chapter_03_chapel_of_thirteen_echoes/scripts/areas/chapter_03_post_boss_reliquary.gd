class_name Chapter03PostBossReliquary
extends Node2D

## Owns the environmental reward gate only. A future authoritative Boss reward
## system calls notify_reward_collected after it updates inventory.

signal reliquary_opened
signal reward_collection_requested(player: Player)
signal descent_unlocked

const FLAG_RELIQUARY_OPENED: StringName = &"chapter_03_reliquary_opened"
const FLAG_REWARD_COLLECTED: StringName = &"chapter_03_boss_reward_collected"

@onready var interact_area: Area2D = $RewardInteractArea as Area2D
@onready var prompt: Label = $InteractionPrompt as Label
@onready var sealed_gate: Sprite2D = $DescentSeal/Sealed as Sprite2D
@onready var open_gate: Sprite2D = $DescentSeal/Open as Sprite2D
@onready var descent_blocker: CollisionShape2D = $DescentBlocker/CollisionShape2D as CollisionShape2D

var _player_in_range: Player = null
var _is_revealed: bool = false
var _reward_collected: bool = false


func _ready() -> void:
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	prompt.visible = false
	open_gate.visible = false
	descent_blocker.set_deferred("disabled", false)


func _unhandled_input(event: InputEvent) -> void:
	if (
		event.is_action_pressed(&"interact")
		and _player_in_range != null
		and _is_revealed
		and not _reward_collected
	):
		reward_collection_requested.emit(_player_in_range)
		var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
		if session != null:
			session.set_story_flag(FLAG_RELIQUARY_OPENED)
		prompt.text = "REWARD INTEGRATION HOOK READY / 奖励系统接口已触发"
		get_viewport().set_input_as_handled()


func reveal_after_boss() -> void:
	if _is_revealed:
		return
	_is_revealed = true
	visible = true
	reliquary_opened.emit()


func notify_reward_collected() -> void:
	if _reward_collected:
		return
	_reward_collected = true
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.set_story_flag(FLAG_REWARD_COLLECTED)
	sealed_gate.visible = false
	open_gate.visible = true
	descent_blocker.set_deferred("disabled", true)
	prompt.visible = false
	descent_unlocked.emit()


func is_reward_collected() -> bool:
	return _reward_collected


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null:
		return
	_player_in_range = player
	if _is_revealed and not _reward_collected:
		prompt.text = "E · INSPECT THE LAST CONFESSION / 检视末次忏悔遗物龛"
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		prompt.visible = false
