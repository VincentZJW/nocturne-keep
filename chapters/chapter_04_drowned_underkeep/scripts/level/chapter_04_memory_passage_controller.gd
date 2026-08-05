class_name Chapter04MemoryPassageController
extends Node

const FLAG_INTRO_SEEN: StringName = &"ch4_memory_passage_intro_seen"

@export_range(0.25, 2.0, 0.05) var fragment_duration: float = 0.90
@export_range(0.0, 1.0, 0.05) var transition_settle_delay: float = 0.40

var _player: Player
var _layer: CanvasLayer
var _panel: PanelContainer
var _label: Label
var _previous_profile: Player.InputProfile = Player.InputProfile.FULL
var _was_invulnerable: bool = false
var _owns_player_lock: bool = false
var _sequence_timer: Timer
var _is_settling: bool = true
var _fragment_index: int = 0
var _fragments: PackedStringArray = [
	"水面残响：门曾由你开启。\nWATER ECHO: The door was opened by your hand.",
	"暮帷残响：钟响之前，不要回头。\nVEIL ECHO: Before the bell—do not turn back.",
	"王冠残影：让这一夜重演。\nCROWN ECHO: Let the night repeat.",
]


func _ready() -> void:
	_sequence_timer = Timer.new()
	_sequence_timer.name = "MemorySequenceTimer"
	_sequence_timer.one_shot = true
	_sequence_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	_sequence_timer.timeout.connect(_on_sequence_timer_timeout)
	add_child(_sequence_timer)
	if transition_settle_delay > 0.0:
		_sequence_timer.start(transition_settle_delay)
	else:
		call_deferred("_on_sequence_timer_timeout")


func _exit_tree() -> void:
	_restore_player()


func _begin_memory_fragments() -> void:
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null and session.has_story_flag(FLAG_INTRO_SEEN):
		return
	_player = get_tree().get_first_node_in_group("player") as Player
	if _player == null:
		push_error("Chapter04MemoryPassageController requires the persistent Player")
		return
	if session != null:
		session.set_story_flag(FLAG_INTRO_SEEN)
	_build_overlay()
	_previous_profile = _player.get_input_profile()
	_was_invulnerable = _player.hurtbox != null and _player.hurtbox.is_invulnerable
	_owns_player_lock = true
	_player.set_input_profile(Player.InputProfile.LOCKED)
	_player.velocity = Vector2.ZERO
	if _player.hurtbox != null:
		_player.hurtbox.set_invulnerable(true)
	_panel.visible = true
	_fragment_index = 0
	_show_current_fragment()


func _on_sequence_timer_timeout() -> void:
	if _is_settling:
		_is_settling = false
		_begin_memory_fragments()
		return
	_fragment_index += 1
	if _fragment_index >= _fragments.size():
		_panel.visible = false
		_restore_player()
		return
	_show_current_fragment()


func _show_current_fragment() -> void:
	_label.text = _fragments[_fragment_index]
	_sequence_timer.start(fragment_duration)


func _restore_player() -> void:
	if not _owns_player_lock or _player == null or not is_instance_valid(_player):
		return
	if _player.hurtbox != null and not _was_invulnerable:
		_player.hurtbox.set_invulnerable(false)
	_player.set_input_profile(_previous_profile)
	_owns_player_lock = false


func _build_overlay() -> void:
	_layer = CanvasLayer.new()
	_layer.name = "MemoryPassageUI"
	_layer.layer = 22
	get_parent().add_child(_layer)
	_panel = PanelContainer.new()
	_panel.name = "MemoryFragmentPanel"
	_panel.position = Vector2(300, 522)
	_panel.custom_minimum_size = Vector2(680, 94)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_panel.add_child(_label)
	_layer.add_child(_panel)
	_panel.visible = false
