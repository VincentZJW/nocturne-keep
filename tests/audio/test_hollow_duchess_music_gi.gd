extends SceneTree

const P1_DEF: String = "res://resources/audio/music_tracks/ch2_hollow_duchess_phase_01.tres"
const P2_DEF: String = "res://resources/audio/music_tracks/ch2_hollow_duchess_phase_02.tres"
const STINGER_DEF: String = "res://resources/audio/music_tracks/ch2_hollow_duchess_transition_stinger.tres"
const AUDIO_ROOT: String = "res://chapters/chapter_02_silent_court/assets/audio/music/boss/hollow_duchess"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var phase_01: MusicTrackDefinition = load(P1_DEF) as MusicTrackDefinition
	var phase_02: MusicTrackDefinition = load(P2_DEF) as MusicTrackDefinition
	var stinger: MusicTrackDefinition = load(STINGER_DEF) as MusicTrackDefinition
	_check(phase_01 != null and phase_02 != null and stinger != null, "Track definitions failed to load")
	if phase_01 != null:
		_check(is_equal_approx(phase_01.bpm, 96.0), "Phase 1 BPM is not 96")
		_check(phase_01.beats_per_bar == 3 and phase_01.beat_unit == 4, "Phase 1 is not 3/4")
		_check(phase_01.loops and absf(phase_01.stream.get_length() - 150.0) < 0.05, "Phase 1 duration/loop mismatch")
	if phase_02 != null:
		_check(is_equal_approx(phase_02.bpm, 120.0), "Phase 2 BPM is not 120")
		_check(phase_02.beats_per_bar == 3 and phase_02.beat_unit == 4, "Phase 2 is not 3/4")
		_check(phase_02.loops and absf(phase_02.stream.get_length() - 132.0) < 0.05, "Phase 2 duration/loop mismatch")
	if stinger != null:
		_check(not stinger.loops and absf(stinger.stream.get_length() - 4.5) < 0.05, "Stinger duration/loop mismatch")

	for relative_path: String in [
		"source/generate_hollow_duchess_music.py",
		"source/hollow_duchess_phase_01_score.json",
		"source/hollow_duchess_phase_02_score.json",
		"source/hollow_duchess_transition_stinger_score.json",
		"midi/hollow_duchess_phase_01_waltz.mid",
		"midi/hollow_duchess_phase_02_unmasked_waltz.mid",
		"midi/hollow_duchess_transition_stinger.mid",
		"stems/phase_01_melody.ogg",
		"stems/phase_02_melody.ogg",
	]:
		_check(FileAccess.file_exists("%s/%s" % [AUDIO_ROOT, relative_path]), "Missing editable deliverable: %s" % relative_path)
	_check_score("%s/source/hollow_duchess_phase_01_score.json" % AUDIO_ROOT, 80, 1000, 6)
	_check_score("%s/source/hollow_duchess_phase_02_score.json" % AUDIO_ROOT, 88, 1400, 5)
	_finish()


func _check_score(path: String, expected_bars: int, minimum_events: int, minimum_sections: int) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	_check(file != null, "Could not open score %s" % path)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	_check(parsed is Dictionary, "Score JSON is invalid: %s" % path)
	if not parsed is Dictionary:
		return
	var score: Dictionary = parsed as Dictionary
	_check(int(score.get("bars", 0)) == expected_bars, "Score bar count mismatch: %s" % path)
	_check((score.get("events", []) as Array).size() >= minimum_events, "Score lacks arranged events: %s" % path)
	_check((score.get("sections", {}) as Dictionary).size() >= minimum_sections, "Score lacks section development: %s" % path)
	_check((score.get("main_motif", []) as Array).size() == 6, "Score lacks shared main motif: %s" % path)
	_check(String(score.get("provenance", "")).contains("fully synthesized"), "Score provenance is not original/synthesized")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("HOLLOW_DUCHESS_MUSIC_GI_TEST: PASS p1=150s@96 p2=132s@120 stinger=4.5s source=MIDI+JSON+stems")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)
