class_name CatacombDialogue
extends Resource

## One localized, index-aligned dialogue track for the catacomb revival.

@export var sequence_id: StringName = &"catacomb_revival"
@export var locale_code: StringName = &"zh_CN"
@export var speakers: PackedStringArray = PackedStringArray()
@export var lines: PackedStringArray = PackedStringArray()
@export var cues: Array[StringName] = []
@export var durations: PackedFloat32Array = PackedFloat32Array()


func get_line_count() -> int:
	return mini(speakers.size(), mini(lines.size(), mini(cues.size(), durations.size())))


func is_valid_track() -> bool:
	return get_line_count() > 0 and speakers.size() == lines.size() and lines.size() == cues.size() and cues.size() == durations.size()


func get_speaker(index: int) -> String:
	return speakers[index] if index >= 0 and index < get_line_count() else ""


func get_line(index: int) -> String:
	return lines[index] if index >= 0 and index < get_line_count() else ""


func get_cue(index: int) -> StringName:
	return cues[index] if index >= 0 and index < get_line_count() else &""


func get_duration(index: int) -> float:
	return maxf(0.5, durations[index]) if index >= 0 and index < get_line_count() else 0.5
