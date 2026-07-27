extends SceneTree

const OUTPUT_PATH: String = "res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/audio/broken_waltz_intro.tres"
const MIX_RATE: int = 22050
const DURATION: float = 6.6
const BEAT_DURATION: float = 0.55


func _init() -> void:
	var output_directory: String = OUTPUT_PATH.get_base_dir()
	var error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_directory))
	if error != OK:
		push_error("Could not create Duchess audio directory: %s" % error_string(error))
		quit(1)
		return

	var sample_count: int = roundi(DURATION * float(MIX_RATE))
	var samples := PackedByteArray()
	samples.resize(sample_count * 2)
	var melody: PackedFloat32Array = PackedFloat32Array([293.66, 349.23, 329.63, 261.63, 311.13, 293.66])
	var bass: PackedFloat32Array = PackedFloat32Array([73.42, 65.41, 77.78, 73.42])
	for sample_index: int in range(sample_count):
		var time: float = float(sample_index) / float(MIX_RATE)
		var beat_index: int = floori(time / BEAT_DURATION)
		var beat_time: float = fmod(time, BEAT_DURATION)
		var beat_envelope: float = exp(-beat_time * 4.7)
		var phrase_envelope: float = 0.72 + sin(time * TAU / DURATION) * 0.12
		var melody_frequency: float = melody[beat_index % melody.size()]
		var bass_frequency: float = bass[(beat_index / 3) % bass.size()]
		var melody_sample: float = sin(time * TAU * melody_frequency) * 0.22
		melody_sample += sin(time * TAU * melody_frequency * 2.01) * 0.055
		var bass_sample: float = sin(time * TAU * bass_frequency) * (0.18 if beat_index % 3 == 0 else 0.08)
		var shellac_noise: float = sin(float(sample_index) * 12.9898) * sin(float(sample_index) * 0.017)
		var dropout: float = 0.46 if fmod(time + 0.08, 2.75) < 0.055 else 1.0
		var mixed: float = (melody_sample + bass_sample) * beat_envelope * phrase_envelope * dropout
		mixed += shellac_noise * 0.018
		mixed = clampf(mixed, -0.92, 0.92)
		samples.encode_s16(sample_index * 2, roundi(mixed * 32767.0))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	stream.data = samples
	error = ResourceSaver.save(stream, OUTPUT_PATH)
	if error != OK:
		push_error("Could not save Duchess broken waltz: %s" % error_string(error))
		quit(1)
		return
	print("DUCHESS_BROKEN_WALTZ: PASS samples=%d path=%s" % [sample_count, OUTPUT_PATH])
	quit(0)
