class_name OpeningCinematicTimeline
extends Resource

## Typed bilingual timeline data for the Chapter I opening.

@export var shot_durations: PackedFloat32Array = PackedFloat32Array()
@export var subtitles_zh: PackedStringArray = PackedStringArray()
@export var subtitles_en: PackedStringArray = PackedStringArray()


func get_shot_count() -> int:
	return mini(shot_durations.size(), mini(subtitles_zh.size(), subtitles_en.size()))


func get_total_duration() -> float:
	var total: float = 0.0
	for duration: float in shot_durations:
		total += duration
	return total


func get_subtitle(index: int, _locale: String = "") -> String:
	if index < 0 or index >= get_shot_count():
		return ""
	return "%s\n%s" % [subtitles_zh[index], subtitles_en[index]]
