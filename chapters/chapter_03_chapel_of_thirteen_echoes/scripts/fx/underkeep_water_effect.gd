class_name UnderkeepWaterEffect
extends Sprite2D

## One-shot pixel splash/ripple. It is presentation-only and never changes physics.

@export var frames: Array[Texture2D] = []
@export_range(4.0, 30.0, 1.0) var frames_per_second: float = 18.0
@export var vertical_drift: float = 0.0

var _elapsed: float = 0.0
var _frame_index: int = 0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if frames.is_empty():
		queue_free()
		return
	texture = frames[0]


func _process(delta: float) -> void:
	position.y += vertical_drift * delta
	_elapsed += delta
	var frame_duration: float = 1.0 / frames_per_second
	if _elapsed < frame_duration:
		return
	_elapsed -= frame_duration
	_frame_index += 1
	if _frame_index >= frames.size():
		queue_free()
		return
	texture = frames[_frame_index]
