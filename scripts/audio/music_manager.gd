class_name MusicManagerService
extends Node

## Persistent two-deck music service.  Boss/level code owns timing decisions;
## this singleton owns playback, fades, buses, one-shot phase guards and debug state.

signal track_started(track_id: StringName)
signal track_stopped(track_id: StringName)
signal crossfade_started(from_track_id: StringName, to_track_id: StringName, duration: float)
signal crossfade_completed(track_id: StringName)

const REGISTRY: MusicTrackRegistry = preload("res://resources/audio/music_track_registry.tres")
const SILENCE_DB: float = -80.0
const DEBUG_REFRESH_SECONDS: float = 0.20

var _deck_a: AudioStreamPlayer
var _deck_b: AudioStreamPlayer
var _active_deck: AudioStreamPlayer
var _standby_deck: AudioStreamPlayer
var _fade_tween: Tween
var _duck_tween: Tween
var _current_track_id: StringName = &""
var _current_target_db: float = -10.0
var _duck_amount_db: float = 0.0
var _music_bus_index: int = -1
var _music_bus_base_db: float = 0.0
var _phase_switch_guards: Dictionary[StringName, bool] = {}
var _switch_count: int = 0
var _debug_layer: CanvasLayer
var _debug_label: Label
var _debug_refresh_remaining: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_deck_a = _create_deck("MusicDeckA")
	_deck_b = _create_deck("MusicDeckB")
	_active_deck = _deck_a
	_standby_deck = _deck_b
	_create_debug_overlay()
	_music_bus_index = AudioServer.get_bus_index(&"Music")
	if _music_bus_index >= 0:
		_music_bus_base_db = AudioServer.get_bus_volume_db(_music_bus_index)
	var registry_errors: PackedStringArray = REGISTRY.validate()
	for message: String in registry_errors:
		push_error(message)
	set_process(false)


func _process(delta: float) -> void:
	if _debug_layer == null or not _debug_layer.visible:
		return
	_debug_refresh_remaining -= delta
	if _debug_refresh_remaining > 0.0:
		return
	_debug_refresh_remaining = DEBUG_REFRESH_SECONDS
	_update_debug_overlay()


func play_music(track_id: StringName, fade_seconds: float = 0.0, restart: bool = false) -> bool:
	var definition: MusicTrackDefinition = REGISTRY.find_track(track_id)
	if definition == null:
		push_error("Unknown music track id: %s" % track_id)
		return false
	if _current_track_id == track_id and _active_deck.playing and not restart:
		return false
	if _current_track_id.is_empty() or not _active_deck.playing:
		_start_on_active_deck(definition, fade_seconds)
		return true
	crossfade_to(track_id, fade_seconds, restart)
	return true


func crossfade_to(track_id: StringName, duration: float = 1.0, restart: bool = false) -> bool:
	var definition: MusicTrackDefinition = REGISTRY.find_track(track_id)
	if definition == null:
		push_error("Unknown music track id: %s" % track_id)
		return false
	if _current_track_id == track_id and _active_deck.playing and not restart:
		return false
	_cancel_fade()
	var previous_id: StringName = _current_track_id
	_prepare_deck(_standby_deck, definition)
	_standby_deck.volume_db = SILENCE_DB
	_standby_deck.play()
	_current_track_id = track_id
	_current_target_db = definition.default_volume_db
	_switch_count += 1
	crossfade_started.emit(previous_id, track_id, maxf(0.0, duration))
	if duration <= 0.0:
		_active_deck.stop()
		_active_deck.volume_db = SILENCE_DB
		_standby_deck.volume_db = _effective_target_db()
		_swap_decks()
		track_started.emit(track_id)
		crossfade_completed.emit(track_id)
		return true
	var old_deck: AudioStreamPlayer = _active_deck
	var new_deck: AudioStreamPlayer = _standby_deck
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_property(old_deck, "volume_db", SILENCE_DB, duration)
	_fade_tween.tween_property(new_deck, "volume_db", _effective_target_db(), duration)
	_fade_tween.finished.connect(func() -> void:
		old_deck.stop()
		old_deck.volume_db = SILENCE_DB
		_swap_decks()
		track_started.emit(track_id)
		crossfade_completed.emit(track_id)
	, CONNECT_ONE_SHOT)
	return true


func phase_switch_once(guard_id: StringName, track_id: StringName, duration: float = 1.0) -> bool:
	if _phase_switch_guards.get(guard_id, false):
		return false
	_phase_switch_guards[guard_id] = true
	return crossfade_to(track_id, duration)


func clear_phase_switch_guard(guard_id: StringName) -> void:
	_phase_switch_guards.erase(guard_id)


func clear_all_phase_switch_guards() -> void:
	_phase_switch_guards.clear()


func fade_out(duration: float = 1.0) -> void:
	if _current_track_id.is_empty():
		return
	_cancel_fade()
	var stopped_id: StringName = _current_track_id
	_current_track_id = &""
	if duration <= 0.0:
		_stop_decks()
		_reset_dialogue_duck()
		track_stopped.emit(stopped_id)
		return
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_property(_deck_a, "volume_db", SILENCE_DB, duration)
	_fade_tween.tween_property(_deck_b, "volume_db", SILENCE_DB, duration)
	_fade_tween.finished.connect(func() -> void:
		_stop_decks()
		_reset_dialogue_duck()
		track_stopped.emit(stopped_id)
	, CONNECT_ONE_SHOT)


func stop_music() -> void:
	_cancel_fade()
	var stopped_id: StringName = _current_track_id
	_current_track_id = &""
	_stop_decks()
	_reset_dialogue_duck()
	if not stopped_id.is_empty():
		track_stopped.emit(stopped_id)


func pause_music() -> void:
	_deck_a.stream_paused = true
	_deck_b.stream_paused = true


func resume_music() -> void:
	_deck_a.stream_paused = false
	_deck_b.stream_paused = false


func set_music_volume(volume_db: float, fade_seconds: float = 0.0) -> void:
	_current_target_db = clampf(volume_db, -60.0, 6.0)
	_tween_active_volume(_effective_target_db(), fade_seconds)


func duck_for_dialogue(attenuation_db: float = 8.0, duration: float = 0.25) -> void:
	_duck_amount_db = maxf(0.0, attenuation_db)
	_tween_dialogue_duck(_duck_amount_db, duration)


func restore_after_dialogue(duration: float = 0.25) -> void:
	_duck_amount_db = 0.0
	_tween_dialogue_duck(0.0, duration)


func preload_track(track_id: StringName) -> bool:
	return REGISTRY.find_track(track_id) != null


func set_debug_overlay_enabled(enabled: bool) -> void:
	_debug_layer.visible = enabled
	set_process(enabled)
	if enabled:
		_debug_refresh_remaining = 0.0
		_update_debug_overlay()


func get_current_track_id() -> StringName:
	return _current_track_id


func get_playback_position() -> float:
	return _active_deck.get_playback_position() if _active_deck != null and _active_deck.playing else 0.0


func get_active_player_count() -> int:
	return int(_deck_a.playing) + int(_deck_b.playing)


func get_current_volume_db() -> float:
	return _active_deck.volume_db if _active_deck != null and _active_deck.playing else SILENCE_DB


func get_switch_count() -> int:
	return _switch_count


func is_debug_overlay_enabled() -> bool:
	return _debug_layer != null and _debug_layer.visible


func is_phase_switch_used(guard_id: StringName) -> bool:
	return _phase_switch_guards.get(guard_id, false)


func get_dialogue_duck_db() -> float:
	return _duck_amount_db


func _start_on_active_deck(definition: MusicTrackDefinition, fade_seconds: float) -> void:
	_cancel_fade()
	_prepare_deck(_active_deck, definition)
	_current_track_id = definition.track_id
	_current_target_db = definition.default_volume_db
	_switch_count += 1
	_active_deck.volume_db = SILENCE_DB if fade_seconds > 0.0 else _effective_target_db()
	_active_deck.play()
	track_started.emit(definition.track_id)
	if fade_seconds > 0.0:
		_tween_active_volume(_effective_target_db(), fade_seconds)


func _prepare_deck(deck: AudioStreamPlayer, definition: MusicTrackDefinition) -> void:
	deck.stop()
	deck.stream = definition.stream
	deck.bus = &"Music"
	var ogg_stream: AudioStreamOggVorbis = definition.stream as AudioStreamOggVorbis
	if ogg_stream != null:
		ogg_stream.loop = definition.loops
		ogg_stream.loop_offset = definition.loop_start_seconds


func _create_deck(deck_name: String) -> AudioStreamPlayer:
	var deck := AudioStreamPlayer.new()
	deck.name = deck_name
	deck.bus = &"Music"
	deck.volume_db = SILENCE_DB
	add_child(deck)
	return deck


func _swap_decks() -> void:
	var previous_active: AudioStreamPlayer = _active_deck
	_active_deck = _standby_deck
	_standby_deck = previous_active


func _effective_target_db() -> float:
	return clampf(_current_target_db, SILENCE_DB, 6.0)


func _tween_active_volume(target_db: float, duration: float) -> void:
	if _active_deck == null or not _active_deck.playing:
		return
	_cancel_fade()
	if duration <= 0.0:
		_active_deck.volume_db = target_db
		return
	_fade_tween = create_tween()
	_fade_tween.tween_property(_active_deck, "volume_db", target_db, duration)


func _cancel_fade() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null


func _tween_dialogue_duck(attenuation_db: float, duration: float) -> void:
	if _music_bus_index < 0:
		return
	_cancel_duck_tween()
	var target_db: float = _music_bus_base_db - maxf(0.0, attenuation_db)
	if duration <= 0.0:
		_set_music_bus_volume_db(target_db)
		return
	var start_db: float = AudioServer.get_bus_volume_db(_music_bus_index)
	_duck_tween = create_tween()
	_duck_tween.tween_method(_set_music_bus_volume_db, start_db, target_db, duration)


func _set_music_bus_volume_db(volume_db: float) -> void:
	if _music_bus_index >= 0:
		AudioServer.set_bus_volume_db(_music_bus_index, volume_db)


func _cancel_duck_tween() -> void:
	if _duck_tween != null and _duck_tween.is_valid():
		_duck_tween.kill()
	_duck_tween = null


func _reset_dialogue_duck() -> void:
	_cancel_duck_tween()
	_duck_amount_db = 0.0
	_set_music_bus_volume_db(_music_bus_base_db)


func _stop_decks() -> void:
	for deck: AudioStreamPlayer in [_deck_a, _deck_b]:
		deck.stop()
		deck.volume_db = SILENCE_DB
		deck.stream_paused = false


func _exit_tree() -> void:
	_reset_dialogue_duck()


func _create_debug_overlay() -> void:
	_debug_layer = CanvasLayer.new()
	_debug_layer.name = "MusicDebugOverlay"
	_debug_layer.layer = 120
	_debug_layer.visible = false
	add_child(_debug_layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(440.0, 86.0)
	panel.custom_minimum_size = Vector2(400.0, 42.0)
	_debug_layer.add_child(panel)
	_debug_label = Label.new()
	_debug_label.add_theme_font_size_override("font_size", 11)
	_debug_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(_debug_label)


func _update_debug_overlay() -> void:
	if _debug_label == null:
		return
	var bus_index: int = AudioServer.get_bus_index(&"Music")
	var bus_db: float = AudioServer.get_bus_volume_db(bus_index) if bus_index >= 0 else -80.0
	_debug_label.text = "MUSIC %s | POS %.2fs | BUS %.1fdB | DUCK %.1fdB | PLAYERS %d | SWITCH %d" % [
		_current_track_id, get_playback_position(), bus_db, _duck_amount_db,
		get_active_player_count(), _switch_count,
	]
