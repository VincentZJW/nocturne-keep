extends SceneTree

## Real-time runtime endurance test.  Default is 600 seconds; the environment
## variable MU1_LONG_PLAY_SECONDS may shorten local smoke runs, never formal QA.

const DEFAULT_TRACK_ID: StringName = &"CH2_BOSS_MUSIC_PHASE_02"

var _duration_seconds: float = 600.0
var _track_id: StringName = DEFAULT_TRACK_ID
var _failures: Array[String] = []
var _maximum_players: int = 0
var _wrap_count: int = 0
var _starting_static_memory_bytes: int = 0
var _maximum_static_memory_bytes: int = 0
var _ending_static_memory_bytes: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var override: String = OS.get_environment("MU_LONG_PLAY_SECONDS")
	if override.is_empty():
		override = OS.get_environment("MU1_LONG_PLAY_SECONDS")
	if override.is_valid_float():
		_duration_seconds = maxf(1.0, override.to_float())
	var track_override: String = OS.get_environment("MU_LONG_PLAY_TRACK_ID")
	if not track_override.is_empty():
		_track_id = StringName(track_override)
	var manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	if manager == null:
		_failures.append("MusicManager is missing")
		_finish()
		return
	manager.stop_music()
	if not manager.play_music(_track_id, 0.0, true):
		_failures.append("Selected endurance track did not start: %s" % _track_id)
		_finish()
		return
	_starting_static_memory_bytes = int(Performance.get_monitor(Performance.MEMORY_STATIC))
	_maximum_static_memory_bytes = _starting_static_memory_bytes
	var started_ms: int = Time.get_ticks_msec()
	var previous_position: float = manager.get_playback_position()
	while float(Time.get_ticks_msec() - started_ms) / 1000.0 < _duration_seconds:
		await create_timer(0.25, true, false, true).timeout
		var player_count: int = manager.get_active_player_count()
		var current_static_memory_bytes: int = int(Performance.get_monitor(Performance.MEMORY_STATIC))
		_maximum_static_memory_bytes = maxi(_maximum_static_memory_bytes, current_static_memory_bytes)
		_maximum_players = maxi(_maximum_players, player_count)
		if player_count != 1:
			_failures.append("Active player count changed to %d" % player_count)
			break
		if manager.get_current_track_id() != _track_id:
			_failures.append("Track id changed during endurance playback")
			break
		var current_position: float = manager.get_playback_position()
		if current_position + 1.0 < previous_position:
			_wrap_count += 1
		previous_position = current_position
	manager.stop_music()
	await create_timer(0.50, true, false, true).timeout
	_ending_static_memory_bytes = int(Performance.get_monitor(Performance.MEMORY_STATIC))
	var ending_growth_bytes: int = _ending_static_memory_bytes - _starting_static_memory_bytes
	if ending_growth_bytes > 16 * 1024 * 1024:
		_failures.append("Static memory grew by more than 16 MiB: %d bytes" % ending_growth_bytes)
	manager.queue_free()
	for _frame: int in range(5):
		await process_frame
	if is_equal_approx(_duration_seconds, 600.0) and _wrap_count < 4:
		_failures.append("Expected at least four seamless loop wraps; observed %d" % _wrap_count)
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("MUSIC_MANAGER_LONG_PLAY: PASS track=%s seconds=%.1f wraps=%d max_players=%d memory_start=%d memory_end=%d memory_peak=%d memory_growth=%d" % [
			_track_id,
			_duration_seconds,
			_wrap_count,
			_maximum_players,
			_starting_static_memory_bytes,
			_ending_static_memory_bytes,
			_maximum_static_memory_bytes,
			_ending_static_memory_bytes - _starting_static_memory_bytes,
		])
		quit(0)
		return
	for failure: String in _failures:
		push_error("MUSIC_MANAGER_LONG_PLAY: %s" % failure)
	quit(1)
