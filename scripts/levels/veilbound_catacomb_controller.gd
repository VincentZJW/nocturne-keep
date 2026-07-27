class_name VeilboundCatacombController
extends Node2D

## Owns the one-time Chapter I story revival, local interactions, and exit fade.

signal revival_sequence_completed(skipped: bool)
signal daggers_recovered
signal stone_door_opened
signal catacomb_exit_requested

@export var monologue_zh: CatacombDialogue
@export var monologue_en: CatacombDialogue
@export var dialogue_zh: CatacombDialogue
@export var dialogue_en: CatacombDialogue
@export_file("*.tscn") var dark_forest_scene_path: String = "res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
@export_range(0.2, 1.0, 0.05) var transition_duration: float = 0.55
@export_range(0.3, 1.5, 0.05) var skip_hold_duration: float = 0.75

@onready var player: Player = $World/Player
@onready var player_visual: Node2D = $World/Player/VisualRoot
@onready var revival_art: RevivalPlayerArt = $World/Player/RevivalPlayerArt
@onready var candle_warden: CandleWarden = $World/CandleWarden
@onready var dialogue_ui: CatacombDialogueUI = $NarrativeUI/DialogueUI
@onready var objective_ui: ChapterObjectiveUI = $NarrativeUI/ObjectiveUI
@onready var interaction_prompt: Label = $NarrativeUI/InteractionPrompt
@onready var skip_panel: Control = $NarrativeUI/SkipPanel
@onready var skip_progress: ProgressBar = $NarrativeUI/SkipPanel/SkipProgress
@onready var fade_rect: ColorRect = $NarrativeUI/FadeRect
@onready var gameplay_hud_root: Control = $HUD/GameplayHudRoot
@onready var dagger_pickup: Area2D = $World/Interactions/DaggerPickup
@onready var dagger_visuals: Node2D = $World/Interactions/DaggerPickup/DaggerVisuals
@onready var stone_door_interaction: Area2D = $World/Interactions/StoneDoorInteraction
@onready var exit_trigger: Area2D = $World/Interactions/CatacombExitTrigger
@onready var stone_door: CatacombStoneDoor = $World/StoneDoorBody/StoneDoorVisual
@onready var stone_door_collision: CollisionShape2D = $World/StoneDoorBody/CollisionShape2D
@onready var bell_player: AudioStreamPlayer = $BellPlayer

var _story_complete: bool = false
var _dialogue_active: bool = false
var _current_zh: CatacombDialogue
var _current_en: CatacombDialogue
var _current_line: int = -1
var _line_remaining: float = 0.0
var _skip_hold: float = 0.0
var _daggers_collected: bool = false
var _door_open: bool = false
var _transitioning: bool = false
var _active_tween: Tween


func _ready() -> void:
	if not _validate_dependencies():
		set_process(false)
		return
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.set_physics_process(false)
	player_visual.visible = false
	revival_art.visible = true
	revival_art.set_pose(RevivalPlayerArt.Pose.CORPSE)
	candle_warden.visible = false
	gameplay_hud_root.visible = false
	gameplay_hud_root.modulate.a = 0.0
	interaction_prompt.visible = false
	skip_panel.visible = true
	skip_progress.min_value = 0.0
	skip_progress.max_value = skip_hold_duration
	skip_progress.value = 0.0
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)
	_bell_player_setup()
	call_deferred("_run_revival_sequence")


func _process(delta: float) -> void:
	if not _story_complete:
		_process_skip(delta)
	if _dialogue_active:
		_line_remaining -= delta
		if Input.is_action_just_pressed(&"ui_accept") or _line_remaining <= 0.0:
			_advance_dialogue()
		return
	if not _story_complete or _transitioning:
		return
	_update_interaction_prompt()
	if Input.is_action_just_pressed(&"interact"):
		_handle_interaction()


func skip_revival_for_test() -> void:
	if not _story_complete:
		_complete_story_sequence(true)


func is_story_complete() -> bool:
	return _story_complete


func has_daggers() -> bool:
	return _daggers_collected


func is_door_open() -> bool:
	return _door_open


func open_door_for_test() -> void:
	if _story_complete and _daggers_collected:
		_open_stone_door()


func collect_daggers_for_test() -> void:
	if _story_complete:
		_collect_daggers()


func _run_revival_sequence() -> void:
	bell_player.play()
	await get_tree().create_timer(0.85).timeout
	if _story_complete:
		return
	_active_tween = create_tween()
	_active_tween.tween_property(fade_rect, "modulate:a", 0.0, 1.2)
	await _active_tween.finished
	if _story_complete:
		return
	await get_tree().create_timer(1.0).timeout
	revival_art.soul_visible = true
	revival_art.soul_alpha = 0.0
	revival_art.soul_offset = Vector2(0, -126)
	_active_tween = create_tween().set_parallel(true)
	_active_tween.tween_property(revival_art, "soul_alpha", 0.88, 0.3)
	_active_tween.tween_property(revival_art, "soul_offset", Vector2(0, -12), 1.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await _active_tween.finished
	if _story_complete:
		return
	revival_art.soul_visible = false
	revival_art.soul_mark_strength = 1.0
	_active_tween = create_tween()
	_active_tween.tween_property(revival_art, "soul_mark_strength", 0.18, 0.8)
	revival_art.set_pose(RevivalPlayerArt.Pose.TWITCH)
	await get_tree().create_timer(0.65).timeout
	if _story_complete:
		return
	revival_art.set_pose(RevivalPlayerArt.Pose.BREATH)
	await get_tree().create_timer(1.0).timeout
	if _story_complete:
		return
	revival_art.set_pose(RevivalPlayerArt.Pose.SIT_UP)
	await get_tree().create_timer(1.2).timeout
	if _story_complete:
		return
	_start_dialogue(monologue_zh, monologue_en)
	await _wait_for_dialogue_completion()
	if _story_complete:
		return
	revival_art.set_pose(RevivalPlayerArt.Pose.KNEEL)
	candle_warden.visible = true
	candle_warden.set_presentation_state(CandleWarden.PresentationState.RISING)
	await get_tree().create_timer(0.85).timeout
	if _story_complete:
		return
	candle_warden.set_presentation_state(CandleWarden.PresentationState.WALK)
	_active_tween = create_tween()
	_active_tween.tween_property(candle_warden, "position:x", 760.0, 1.1)
	await _active_tween.finished
	if _story_complete:
		return
	candle_warden.set_presentation_state(CandleWarden.PresentationState.IDLE)
	revival_art.set_pose(RevivalPlayerArt.Pose.STAND)
	_start_dialogue(dialogue_zh, dialogue_en)
	await _wait_for_dialogue_completion()
	if not _story_complete:
		_complete_story_sequence(false)


func _start_dialogue(zh_track: CatacombDialogue, en_track: CatacombDialogue) -> void:
	_current_zh = zh_track
	_current_en = en_track
	_current_line = -1
	_dialogue_active = true
	_advance_dialogue()


func _advance_dialogue() -> void:
	if not _dialogue_active:
		return
	_current_line += 1
	if _current_line >= _current_zh.get_line_count():
		_dialogue_active = false
		dialogue_ui.hide_dialogue()
		return
	var cue: StringName = _current_zh.get_cue(_current_line)
	_apply_dialogue_cue(cue)
	dialogue_ui.show_line(
		"%s / %s" % [_current_zh.get_speaker(_current_line), _current_en.get_speaker(_current_line)],
		_current_zh.get_line(_current_line),
		_current_en.get_line(_current_line)
	)
	_line_remaining = _current_zh.get_duration(_current_line)


func _wait_for_dialogue_completion() -> void:
	while _dialogue_active and not _story_complete:
		await get_tree().process_frame


func _apply_dialogue_cue(cue: StringName) -> void:
	match cue:
		&"player_sit":
			revival_art.set_pose(RevivalPlayerArt.Pose.SIT_UP)
		&"player_look_hands", &"player_memory":
			revival_art.set_pose(RevivalPlayerArt.Pose.LOOK_HANDS)
		&"player_look_around", &"player_talk":
			revival_art.set_pose(RevivalPlayerArt.Pose.SIT_UP if candle_warden.visible == false else RevivalPlayerArt.Pose.STAND)
		&"warden_raise_lantern":
			candle_warden.set_presentation_state(CandleWarden.PresentationState.RAISE_LANTERN)
		&"warden_turn_away":
			candle_warden.facing_left = false
			candle_warden.set_presentation_state(CandleWarden.PresentationState.TURN_AWAY)
		&"warden_talk":
			candle_warden.set_presentation_state(CandleWarden.PresentationState.TALK)


func _process_skip(delta: float) -> void:
	var held: bool = Input.is_action_pressed(&"ui_cancel") or Input.is_action_pressed(&"ui_accept")
	_skip_hold = minf(skip_hold_duration, _skip_hold + delta) if held else maxf(0.0, _skip_hold - delta * 2.0)
	skip_progress.value = _skip_hold
	if _skip_hold >= skip_hold_duration:
		_complete_story_sequence(true)


func _complete_story_sequence(skipped: bool) -> void:
	if _story_complete:
		return
	_story_complete = true
	_dialogue_active = false
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	dialogue_ui.hide_dialogue()
	skip_panel.visible = false
	fade_rect.modulate.a = 0.0
	revival_art.soul_visible = false
	revival_art.soul_mark_strength = 0.0
	revival_art.set_pose(RevivalPlayerArt.Pose.UNARMED)
	# Align the reused CharacterBody foot with the altar top before physics resumes.
	player.global_position.y = 517.0
	candle_warden.visible = true
	candle_warden.position.x = 760.0
	candle_warden.set_presentation_state(CandleWarden.PresentationState.IDLE)
	player.set_physics_process(true)
	player.set_input_profile(Player.InputProfile.CATACOMB_MOVE_ONLY)
	gameplay_hud_root.visible = true
	_active_tween = create_tween()
	_active_tween.tween_property(gameplay_hud_root, "modulate:a", 1.0, 0.35)
	var chapter_session: Node = get_node_or_null("/root/ChapterSession")
	if chapter_session != null and chapter_session.has_method("mark_revival_completed"):
		chapter_session.call("mark_revival_completed")
	objective_ui.show_objective("离开暮帷墓窟", "Leave the Veilbound Catacomb")
	revival_sequence_completed.emit(skipped)


func _update_interaction_prompt() -> void:
	var prompt: String = ""
	if not _daggers_collected and dagger_pickup.has_overlapping_bodies():
		prompt = "E  拾取双匕首  /  RECOVER BLADES"
	elif _daggers_collected and not _door_open and stone_door_interaction.has_overlapping_bodies():
		prompt = "E  开启石门  /  OPEN STONE DOOR"
	else:
		var observation: Area2D = _get_nearby_observation()
		if observation != null:
			prompt = "E  观察  /  EXAMINE"
	interaction_prompt.text = prompt
	interaction_prompt.visible = not prompt.is_empty()


func _handle_interaction() -> void:
	if not _daggers_collected and dagger_pickup.has_overlapping_bodies():
		_collect_daggers()
		return
	if _daggers_collected and not _door_open and stone_door_interaction.has_overlapping_bodies():
		_open_stone_door()
		return
	var observation: Area2D = _get_nearby_observation()
	if observation == null:
		return
	match observation.name:
		&"VeiledCrest":
			dialogue_ui.show_ephemeral("暮帷会……我曾经属于这里。", "The Veiled Order… I belonged here.")
		&"FallenVeilbound":
			dialogue_ui.show_ephemeral("我认识他们吗？", "Did I know them?")
		&"SoulFragment":
			dialogue_ui.show_ephemeral("和我身上的印记一样。", "It bears the same mark as mine.")
		&"BrokenSarcophagus":
			dialogue_ui.show_ephemeral("不是所有沉睡者都被允许醒来。", "Not every sleeper was permitted to wake.")
		&"BrokenDagger":
			dialogue_ui.show_ephemeral("断口上没有锈。", "There is no rust along the break.")


func _collect_daggers() -> void:
	if _daggers_collected:
		return
	_daggers_collected = true
	dagger_visuals.visible = false
	revival_art.visible = false
	player_visual.visible = true
	var chapter_session: Node = get_node_or_null("/root/ChapterSession")
	if chapter_session != null and chapter_session.has_method("mark_daggers_recovered"):
		chapter_session.call("mark_daggers_recovered")
	dialogue_ui.show_ephemeral("旧刃仍记得我的手。", "The old blades still remember my hands.", 1.8)
	daggers_recovered.emit()


func _open_stone_door() -> void:
	if _door_open or not _story_complete or not _daggers_collected:
		return
	_door_open = true
	interaction_prompt.visible = false
	candle_warden.set_presentation_state(CandleWarden.PresentationState.RAISE_LANTERN)
	_active_tween = create_tween()
	_active_tween.tween_property(stone_door, "rune_strength", 1.0, 0.35)
	_active_tween.tween_property(stone_door, "open_progress", 1.0, 1.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_active_tween.parallel().tween_property(stone_door, "rune_strength", 0.25, 1.15)
	_active_tween.finished.connect(_on_door_animation_finished, CONNECT_ONE_SHOT)


func _on_door_animation_finished() -> void:
	stone_door_collision.disabled = true
	stone_door_opened.emit()


func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body != player or not _door_open or _transitioning:
		return
	_transitioning = true
	player.set_input_profile(Player.InputProfile.LOCKED)
	interaction_prompt.visible = false
	var chapter_session: Node = get_node_or_null("/root/ChapterSession")
	if chapter_session != null and chapter_session.has_method("mark_catacomb_exited"):
		chapter_session.call("mark_catacomb_exited")
	catacomb_exit_requested.emit()
	fade_rect.visible = true
	_active_tween = create_tween()
	_active_tween.tween_property(fade_rect, "modulate:a", 1.0, transition_duration)
	_active_tween.finished.connect(_change_to_dark_forest, CONNECT_ONE_SHOT)


func _change_to_dark_forest() -> void:
	var error: Error = get_tree().change_scene_to_file(dark_forest_scene_path)
	if error != OK:
		push_error("VeilboundCatacomb could not load %s" % dark_forest_scene_path)
		_transitioning = false


func _get_nearby_observation() -> Area2D:
	for child: Node in $World/Interactions/Observations.get_children():
		var area: Area2D = child as Area2D
		if area != null and area.has_overlapping_bodies():
			return area
	return null


func _bell_player_setup() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	var sample_count: int = int(1.3 * float(stream.mix_rate))
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)
	for index: int in range(sample_count):
		var time: float = float(index) / float(stream.mix_rate)
		var envelope: float = exp(-2.6 * time)
		var sample: float = (sin(TAU * 73.0 * time) + 0.42 * sin(TAU * 146.0 * time)) * envelope * 0.35
		var value: int = clampi(roundi(sample * 32767.0), -32768, 32767)
		data[index * 2] = value & 0xff
		data[index * 2 + 1] = (value >> 8) & 0xff
	stream.data = data
	bell_player.stream = stream


func _validate_dependencies() -> bool:
	var tracks_valid: bool = (
		monologue_zh != null and monologue_en != null and dialogue_zh != null and dialogue_en != null
		and monologue_zh.is_valid_track() and monologue_en.is_valid_track()
		and dialogue_zh.is_valid_track() and dialogue_en.is_valid_track()
		and monologue_zh.get_line_count() == monologue_en.get_line_count()
		and dialogue_zh.get_line_count() == dialogue_en.get_line_count()
	)
	if not tracks_valid:
		push_error("VeilboundCatacomb requires aligned bilingual dialogue tracks")
		return false
	return true
