class_name UnderkeepAnimatedSprite
extends Sprite2D

## Lightweight nearest-neighbour animation for low-resolution environment layers.

@export var frames: Array[Texture2D] = []
@export_range(1.0, 30.0, 0.5) var frames_per_second: float = 6.0
@export var randomize_start: bool = false

var _elapsed: float = 0.0
var _frame_index: int = 0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if frames.is_empty():
		set_process(false)
		return
	if randomize_start:
		_frame_index = randi_range(0, frames.size() - 1)
	texture = frames[_frame_index]


func _process(delta: float) -> void:
	_elapsed += delta
	var frame_duration: float = 1.0 / frames_per_second
	while _elapsed >= frame_duration:
		_elapsed -= frame_duration
		_frame_index = (_frame_index + 1) % frames.size()
		texture = frames[_frame_index]
