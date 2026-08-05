extends SceneTree

const SAMPLE_RATE: int = 22050
const DURATION_SECONDS: float = 12.0
const OUTPUT_DIR: String = "res://chapters/chapter_04_drowned_underkeep/assets/audio/music/boss/soul_gaoler_ormund"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	_generate_track("soul_gaoler_phase_01_submerged_chains", 50.0, false)
	_generate_track("soul_gaoler_phase_02_broken_cage", 68.0, true)
	quit()


func _generate_track(file_name: String, bpm: float, phase_two: bool) -> void:
	var sample_count: int = roundi(SAMPLE_RATE * DURATION_SECONDS)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)
	var beat_seconds: float = 60.0 / bpm
	for index: int in sample_count:
		var time: float = float(index) / float(SAMPLE_RATE)
		var beat_phase: float = fmod(time, beat_seconds) / beat_seconds
		var pulse: float = exp(-beat_phase * (13.0 if phase_two else 9.0))
		var drone: float = sin(TAU * 41.2 * time) * 0.30 + sin(TAU * 61.8 * time) * 0.15
		var chain: float = sin(TAU * (246.0 if phase_two else 164.0) * time) * pulse * 0.18
		var toll_phase: float = fmod(time, beat_seconds * 4.0) / (beat_seconds * 4.0)
		var toll: float = sin(TAU * 82.4 * time) * exp(-toll_phase * 11.0) * 0.22
		var current: float = (drone + chain + toll) * (0.80 if phase_two else 0.68)
		var sample: int = clampi(roundi(current * 32767.0), -32768, 32767)
		bytes.encode_s16(index * 2, sample)
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	stream.data = bytes
	var result: Error = stream.save_to_wav("%s/%s" % [OUTPUT_DIR, file_name])
	if result != OK:
		push_error("Unable to save Soul Gaoler music: %s" % error_string(result))
