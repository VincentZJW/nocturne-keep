class_name UnderkeepDripPoint
extends Node2D

@export_range(1.5, 8.0, 0.1) var minimum_delay: float = 1.8
@export_range(1.5, 8.0, 0.1) var maximum_delay: float = 4.5
@export var waterline_y: float = 612.0
@export var drop_texture: Texture2D
@export var ripple_frames: Array[Texture2D] = []
@export var audio_stream: AudioStream

var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_release_drop)
	add_child(_timer)
	_schedule()


func _schedule() -> void:
	_timer.start(randf_range(minimum_delay, maximum_delay))


func _release_drop() -> void:
	if drop_texture == null:
		_schedule()
		return
	var drop := Sprite2D.new()
	drop.name = "WaterDrop"
	drop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	drop.texture = drop_texture
	drop.z_index = 16
	drop.global_position = global_position
	get_tree().current_scene.add_child(drop)
	var fall_distance: float = maxf(8.0, waterline_y - global_position.y)
	var duration: float = clampf(fall_distance / 720.0, 0.18, 0.65)
	var tween: Tween = drop.create_tween()
	tween.tween_property(drop, "global_position:y", waterline_y, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_finish_drop.bind(drop, Vector2(global_position.x, waterline_y)))
	_schedule()


func _finish_drop(drop: Sprite2D, impact_position: Vector2) -> void:
	if is_instance_valid(drop):
		drop.queue_free()
	if not ripple_frames.is_empty():
		var ripple := UnderkeepWaterEffect.new()
		ripple.name = "DripRipple"
		ripple.frames = ripple_frames
		ripple.frames_per_second = 16.0
		ripple.z_index = 17
		ripple.global_position = impact_position
		get_tree().current_scene.add_child(ripple)
	if audio_stream != null:
		var player := AudioStreamPlayer2D.new()
		player.stream = audio_stream
		player.volume_db = -15.0
		player.max_distance = 900.0
		player.global_position = impact_position
		player.finished.connect(player.queue_free)
		get_tree().current_scene.add_child(player)
		player.play()
