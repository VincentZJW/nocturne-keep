class_name CastleGateController
extends AnimationPlayer

## Owns the visible gate lift and releases World collision only after passage is clear.

signal gate_open_started
signal gate_opened
signal gate_closed

const OPEN_ANIMATION: StringName = &"open"

@export_range(0.8, 1.5, 0.05) var gate_open_duration: float = 1.2
@export_range(160.0, 320.0, 8.0) var gate_raise_distance: float = 240.0
@export_node_path("StaticBody2D") var gate_body_path: NodePath = NodePath("..")
@export_node_path("Node2D") var gate_visual_path: NodePath = NodePath("../GateVisual")
@export_node_path("CollisionShape2D") var gate_collision_path: NodePath = NodePath("../GateCollision")
@export_node_path("AudioStreamPlayer2D") var gate_audio_path: NodePath = NodePath("../GateAudio")

@onready var gate_body: StaticBody2D = get_node_or_null(gate_body_path) as StaticBody2D
@onready var gate_visual: Node2D = get_node_or_null(gate_visual_path) as Node2D
@onready var gate_collision: CollisionShape2D = get_node_or_null(
	gate_collision_path
) as CollisionShape2D
@onready var gate_audio: AudioStreamPlayer2D = get_node_or_null(
	gate_audio_path
) as AudioStreamPlayer2D

var _closed_visual_position: Vector2 = Vector2.ZERO
var _is_open: bool = false


func _ready() -> void:
	if gate_body == null or gate_visual == null or gate_collision == null or gate_audio == null:
		push_error("CastleGateController scene composition is incomplete")
		return
	root_node = NodePath("..")
	_closed_visual_position = gate_visual.position
	_build_animation()
	_build_placeholder_gate_sound()
	animation_finished.connect(_on_animation_finished)
	close_gate()


func open_gate() -> bool:
	if _is_open or is_playing():
		return false
	_set_collision_enabled(true)
	gate_audio.play()
	play(OPEN_ANIMATION)
	gate_open_started.emit()
	return true


func close_gate() -> void:
	stop()
	gate_audio.stop()
	_is_open = false
	if gate_visual != null:
		gate_visual.position = _closed_visual_position
	_set_collision_enabled(true)
	gate_closed.emit()


func is_gate_open() -> bool:
	return _is_open


func _build_animation() -> void:
	var animation: Animation = Animation.new()
	animation.length = gate_open_duration
	animation.loop_mode = Animation.LOOP_NONE
	var position_track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(position_track, NodePath("GateVisual:position"))
	animation.track_insert_key(position_track, 0.0, _closed_visual_position)
	animation.track_insert_key(
		position_track,
		gate_open_duration,
		_closed_visual_position + Vector2.UP * gate_raise_distance
	)
	animation.track_set_interpolation_type(position_track, Animation.INTERPOLATION_CUBIC)
	animation.value_track_set_update_mode(position_track, Animation.UPDATE_CONTINUOUS)
	var library: AnimationLibrary = AnimationLibrary.new()
	library.add_animation(OPEN_ANIMATION, animation)
	add_animation_library(&"", library)


func _build_placeholder_gate_sound() -> void:
	if gate_audio.stream != null:
		return
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	var duration: float = 0.36
	var sample_count: int = int(stream.mix_rate * duration)
	var sample_data: PackedByteArray = PackedByteArray()
	sample_data.resize(sample_count * 2)
	for sample_index: int in range(sample_count):
		var time: float = float(sample_index) / float(stream.mix_rate)
		var envelope: float = pow(1.0 - time / duration, 2.0)
		var chain_tone: float = sin(TAU * 92.0 * time) + 0.45 * sin(TAU * 151.0 * time)
		var scrape_tone: float = sin(TAU * (330.0 - 180.0 * time) * time)
		var sample: float = clampf((chain_tone * 0.16 + scrape_tone * 0.07) * envelope, -0.28, 0.28)
		sample_data.encode_s16(sample_index * 2, int(sample * 32767.0))
	stream.data = sample_data
	gate_audio.stream = stream


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == OPEN_ANIMATION:
		_complete_opening()


func _complete_opening() -> void:
	_is_open = true
	_set_collision_enabled(false)
	gate_opened.emit()


func _set_collision_enabled(enabled: bool) -> void:
	if gate_body == null or gate_collision == null:
		return
	gate_body.collision_layer = 1 if enabled else 0
	gate_collision.set_deferred("disabled", not enabled)
