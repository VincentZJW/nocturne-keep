class_name MusicTrackDefinition
extends Resource

## Authored metadata and runtime defaults for one project-owned music cue.

@export var track_id: StringName = &""
@export var display_name: String = ""
@export var stream: AudioStream
@export_range(1.0, 300.0, 0.01) var bpm: float = 120.0
@export_range(1, 16, 1) var beats_per_bar: int = 4
@export_range(1, 16, 1) var beat_unit: int = 4
@export_range(-60.0, 6.0, 0.1) var default_volume_db: float = -10.0
@export var loops: bool = true
@export_range(0.0, 3600.0, 0.001) var loop_start_seconds: float = 0.0
@export_range(0.0, 3600.0, 0.001) var loop_end_seconds: float = 0.0


func is_valid_definition() -> bool:
	return not track_id.is_empty() and stream != null
