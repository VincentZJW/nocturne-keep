class_name MusicTrackRegistry
extends Resource

## Central catalogue; gameplay requests stable IDs rather than file paths.

@export var tracks: Array[MusicTrackDefinition] = []


func find_track(track_id: StringName) -> MusicTrackDefinition:
	for definition: MusicTrackDefinition in tracks:
		if definition != null and definition.track_id == track_id:
			return definition
	return null


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	var seen: Dictionary[StringName, bool] = {}
	for definition: MusicTrackDefinition in tracks:
		if definition == null or not definition.is_valid_definition():
			errors.append("Music registry contains an invalid track definition")
			continue
		if seen.has(definition.track_id):
			errors.append("Duplicate music track id: %s" % definition.track_id)
		seen[definition.track_id] = true
	return errors
