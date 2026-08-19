class_name Chapter04BossRoomController
extends Node

signal intro_completed
signal boss_flow_completed

const PHASE_ONE_TRACK: StringName = &"CH4_BOSS_SOUL_GAOLER_PHASE_01"
const PHASE_TWO_TRACK: StringName = &"CH4_BOSS_SOUL_GAOLER_PHASE_02"
const PHASE_TRANSITION_TRACK: StringName = &"CH4_BOSS_SOUL_GAOLER_TRANSITION"
const FLAG_BOSS_DEFEATED: StringName = &"ch4_boss_defeated"
const FLAG_BOSS_INTRO_SEEN: StringName = &"ch4_boss_intro_seen"
const TITLE_FADE_IN: float = 0.18
const TITLE_HOLD: float = 0.70
const PHASE_TITLE_HOLD: float = 0.58
const TITLE_FADE_OUT: float = 0.24
const CAMERA_REVEAL_DURATION: float = 0.65
const CAMERA_RETURN_DURATION: float = 0.39
const DIALOGUE_DUCK_DB: float = 6.0

@export_node_path("SoulGaolerOrmund") var boss_path: NodePath = NodePath("../Enemies/SoulGaolerOrmund")
@export_node_path("Chapter04RoomExit") var reward_exit_path: NodePath = NodePath("../Transitions/ExitEast")
@export var intro_line_duration: float = 0.72
@export var boss_movement_left_bound: float = 180.0
@export var boss_movement_right_bound: float = 2124.0

var boss: SoulGaolerOrmund
var player: Player
var reward_exit: Chapter04RoomExit
var _intro_running: bool = false
var _boss_defeated: bool = false
var _combat_started: bool = false
var _intro_sequence_token: int = 0
var _ui_layer: CanvasLayer
var _dialogue_panel: PanelContainer
var _dialogue_label: Label
var _boss_panel: PanelContainer
var _boss_name: Label
var _boss_phase: Label
var _boss_health: ProgressBar
var _boss_poise: ProgressBar
var _boss_title: VBoxContainer
var _boss_title_name: Label
var _boss_title_epithet: Label
var _phase_title: VBoxContainer
var _phase_title_name: Label
var _phase_title_chinese: Label
var _default_camera_zoom: Vector2 = Vector2.ONE
var _default_camera_offset: Vector2 = Vector2.ZERO
var _last_music_sync_cue: StringName = &""
var _last_music_sync_seconds: float = 0.0


func _ready() -> void:
	get_parent().set_meta(&"boss_intro_controls_player", true)
	call_deferred("_bind_runtime")


func _process(_delta: float) -> void:
	if _boss_panel == null or not _boss_panel.visible:
		return
	if boss == null or boss.poise_component == null or _boss_poise == null:
		return
	_boss_poise.max_value = boss.poise_component.max_poise
	_boss_poise.value = boss.poise_component.current_poise


func _exit_tree() -> void:
	var music: MusicManagerService = get_node_or_null("/root/MusicManager") as MusicManagerService
	if music == null:
		return
	var active_track: StringName = music.get_current_track_id()
	if active_track in [PHASE_ONE_TRACK, PHASE_TWO_TRACK, PHASE_TRANSITION_TRACK]:
		music.stop_music()
	music.restore_after_dialogue(0.0)
	music.clear_phase_switch_guard(&"ch4_ormund_phase_two")


func _bind_runtime() -> void:
	boss = get_node_or_null(boss_path) as SoulGaolerOrmund
	reward_exit = get_node_or_null(reward_exit_path) as Chapter04RoomExit
	player = get_tree().get_first_node_in_group("player") as Player
	if boss == null or player == null or reward_exit == null:
		push_error("Chapter04BossRoomController cannot resolve boss, player, or reward exit")
		return
	boss.configure_movement_bounds(boss_movement_left_bound, boss_movement_right_bound)
	reward_exit.requires_interaction = true
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null and session.has_story_flag(FLAG_BOSS_DEFEATED):
		_boss_defeated = true
		reward_exit.set_locked(false)
		get_parent().set_meta(&"boss_intro_controls_player", false)
		_lock_player(false)
		boss.queue_free()
		return
	_build_ui()
	_default_camera_zoom = player.player_camera.zoom
	_default_camera_offset = player.player_camera.offset
	reward_exit.set_locked(true)
	boss.external_intro_control = true
	boss.begin_external_intro()
	boss.health_component.health_changed.connect(_on_boss_health_changed)
	boss.phase_changed.connect(_on_phase_changed)
	boss.phase_transition_started.connect(_on_phase_transition_started)
	boss.phase_transition_cue.connect(_on_phase_transition_cue)
	boss.boss_attack_cue.connect(_on_boss_attack_cue)
	boss.death_sequence_started.connect(_on_death_started)
	boss.defeated.connect(_on_boss_defeated)
	player.respawned.connect(_on_player_respawned)
	if _is_direct_phase_two_debug_start():
		_start_direct_phase_two_debug()
	elif session != null and session.has_story_flag(FLAG_BOSS_INTRO_SEEN):
		_resume_battle_after_retry()
	else:
		_run_intro()


func _build_ui() -> void:
	_ui_layer = CanvasLayer.new()
	_ui_layer.name = "BossFlowUI"
	_ui_layer.layer = 70
	get_parent().add_child(_ui_layer)

	_boss_panel = PanelContainer.new()
	_boss_panel.name = "BossHUD"
	_boss_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_boss_panel.offset_left = 340.0
	_boss_panel.offset_top = 18.0
	_boss_panel.offset_right = -340.0
	_boss_panel.offset_bottom = 92.0
	var boss_margin: MarginContainer = MarginContainer.new()
	boss_margin.name = "Margin"
	boss_margin.add_theme_constant_override("margin_left", 10)
	boss_margin.add_theme_constant_override("margin_top", 6)
	boss_margin.add_theme_constant_override("margin_right", 10)
	boss_margin.add_theme_constant_override("margin_bottom", 6)
	var boss_box: VBoxContainer = VBoxContainer.new()
	boss_box.name = "VBox"
	boss_box.add_theme_constant_override("separation", 2)
	_boss_name = Label.new()
	_boss_name.name = "Name"
	_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_name.add_theme_font_size_override("font_size", 12)
	_boss_name.text = "SOUL GAOLER ORMUND / 魂狱看守·奥蒙德"
	_boss_phase = Label.new()
	_boss_phase.name = "State"
	_boss_phase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_phase.add_theme_font_size_override("font_size", 9)
	_boss_phase.text = "PHASE I  |  DORMANT"
	_boss_health = ProgressBar.new()
	_boss_health.name = "Health"
	_boss_health.show_percentage = false
	_boss_health.custom_minimum_size = Vector2(0, 10)
	_boss_poise = ProgressBar.new()
	_boss_poise.name = "Poise"
	_boss_poise.show_percentage = false
	_boss_poise.custom_minimum_size = Vector2(0, 6)
	boss_box.add_child(_boss_name)
	boss_box.add_child(_boss_health)
	boss_box.add_child(_boss_poise)
	boss_box.add_child(_boss_phase)
	boss_margin.add_child(boss_box)
	_boss_panel.add_child(boss_margin)
	_ui_layer.add_child(_boss_panel)
	_boss_panel.visible = false

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.name = "DialoguePanel"
	_dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue_panel.offset_left = 180.0
	_dialogue_panel.offset_top = -132.0
	_dialogue_panel.offset_right = -180.0
	_dialogue_panel.offset_bottom = -42.0
	_dialogue_label = Label.new()
	_dialogue_label.name = "Dialogue"
	_dialogue_label.custom_minimum_size = Vector2(0, 84)
	_dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.add_theme_color_override("font_color", Color(0.88, 0.84, 0.74, 1.0))
	_dialogue_label.add_theme_font_size_override("font_size", 16)
	_dialogue_panel.add_child(_dialogue_label)
	_ui_layer.add_child(_dialogue_panel)
	_dialogue_panel.visible = false

	_boss_title = VBoxContainer.new()
	_boss_title.name = "BossTitle"
	_boss_title.position = Vector2(318.0, 244.0)
	_boss_title.size = Vector2(644.0, 100.0)
	_boss_title.add_theme_constant_override("separation", 4)
	_boss_title_name = _make_title_label(28, Color(0.88, 0.8, 0.62, 1.0), 6)
	_boss_title_name.name = "Name"
	_boss_title_name.text = "SOUL GAOLER ORMUND / 魂狱看守·奥蒙德"
	_boss_title_epithet = _make_title_label(13, Color(0.65, 0.7, 0.76, 1.0), 5)
	_boss_title_epithet.name = "Epithet"
	_boss_title_epithet.text = "THE LAST GAOLER / 最后的看守"
	_boss_title.add_child(_boss_title_name)
	_boss_title.add_child(_boss_title_epithet)
	_ui_layer.add_child(_boss_title)
	_boss_title.visible = false

	_phase_title = VBoxContainer.new()
	_phase_title.name = "PhaseTitle"
	_phase_title.position = Vector2(280.0, 214.0)
	_phase_title.size = Vector2(720.0, 110.0)
	_phase_title_name = _make_title_label(25, Color(0.63, 0.84, 0.9, 1.0), 6)
	_phase_title_name.name = "Name"
	_phase_title_name.text = "THE BROKEN CAGE"
	_phase_title_chinese = _make_title_label(17, Color(0.78, 0.72, 0.62, 1.0), 0)
	_phase_title_chinese.name = "Chinese"
	_phase_title_chinese.text = "破笼之魂"
	_phase_title.add_child(_phase_title_name)
	_phase_title.add_child(_phase_title_chinese)
	_ui_layer.add_child(_phase_title)
	_phase_title.visible = false


func _make_title_label(font_size: int, color: Color, outline_size: int) -> Label:
	var label: Label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if outline_size > 0:
		label.add_theme_color_override("font_outline_color", Color(0.015, 0.015, 0.03, 1.0))
		label.add_theme_constant_override("outline_size", outline_size)
	return label


func _run_intro() -> void:
	if _intro_running or _boss_defeated:
		return
	_intro_running = true
	_intro_sequence_token += 1
	var sequence_token: int = _intro_sequence_token
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.set_story_flag(FLAG_BOSS_INTRO_SEEN)
	_lock_player(true)
	_play_phase_one_music(true)
	await _play_intro_camera_reveal()
	if not is_inside_tree() or sequence_token != _intro_sequence_token:
		return
	var lines: PackedStringArray = [
		"ORMUND\n礼拜堂终于把你吐了下来。\nThe chapel has finally spat you out.",
		"NIGHT WARDEN\n埃德兰说，未被赦免的人都在这里。\nEdran said the unforgiven were kept here.",
		"ORMUND\n赦免？那只是他们给处刑写下的名字。\nAbsolution? Merely the name they gave execution.",
		"NIGHT WARDEN\n这些灵魂为什么还被锁着？\nWhy are these souls still chained?",
		"ORMUND\n因为死去的人会记得。而王冠最害怕的，就是有人记得那一夜。\nThe dead remember. The Crown fears anyone who remembers that night.",
		"NIGHT WARDEN\n七年前，我来过这里。\nI was here seven years ago.",
		"ORMUND\n你不只来过。你亲手打开了最深处的牢门。\nYou did more than come. You opened the deepest cell with your own hands.",
	]
	_dialogue_panel.visible = true
	for index: int in range(lines.size()):
		var line: String = lines[index]
		_dialogue_label.text = line
		await get_tree().create_timer(1.0 if index == lines.size() - 1 else intro_line_duration).timeout
		if not is_inside_tree() or sequence_token != _intro_sequence_token:
			return
	_dialogue_panel.visible = false
	var music: MusicManagerService = get_node_or_null("/root/MusicManager") as MusicManagerService
	if music != null:
		music.restore_after_dialogue(0.25)
	await _play_boss_title()
	if not is_inside_tree() or sequence_token != _intro_sequence_token:
		return
	_boss_panel.visible = true
	_on_boss_health_changed(boss.health_component.current_health, boss.health_component.max_health)
	await _return_gameplay_camera()
	if not is_inside_tree() or sequence_token != _intro_sequence_token:
		return
	_lock_player(false)
	boss.begin_combat(player)
	_combat_started = true
	_intro_running = false
	intro_completed.emit()


func _resume_battle_after_retry() -> void:
	_intro_running = true
	_intro_sequence_token += 1
	var sequence_token: int = _intro_sequence_token
	_lock_player(true)
	_play_phase_one_music(false)
	_boss_panel.visible = true
	_on_boss_health_changed(boss.health_component.current_health, boss.health_component.max_health)
	await get_tree().create_timer(CAMERA_RETURN_DURATION).timeout
	if not is_inside_tree() or _boss_defeated or sequence_token != _intro_sequence_token:
		return
	_lock_player(false)
	boss.begin_combat(player)
	_combat_started = true
	_intro_running = false
	intro_completed.emit()


func skip_intro_for_qa() -> void:
	if boss == null or player == null or _boss_defeated:
		return
	_play_phase_one_music(false)
	_intro_sequence_token += 1
	_intro_running = false
	if _dialogue_panel != null:
		_dialogue_panel.visible = false
	if _boss_panel != null:
		_boss_panel.visible = true
	_lock_player(false)
	boss.begin_combat(player)
	_combat_started = true
	intro_completed.emit()


func _on_boss_health_changed(current: int, maximum: int) -> void:
	if _boss_health == null:
		return
	_boss_health.max_value = maximum
	_boss_health.value = current
	_boss_health.tooltip_text = "%d / %d" % [current, maximum]
	if _boss_poise != null and boss != null and boss.poise_component != null:
		_boss_poise.max_value = boss.poise_component.max_poise
		_boss_poise.value = boss.poise_component.current_poise


func _on_phase_changed(new_phase: int) -> void:
	if _boss_phase != null:
		_boss_phase.text = "PHASE %s  |  %s" % [
			"II" if new_phase == 2 else "I", "THE BROKEN CAGE" if new_phase == 2 else "DORMANT"
		]
	if new_phase == 2:
		_play_phase_title()
		var music: MusicManagerService = get_node_or_null("/root/MusicManager") as MusicManagerService
		if music != null:
			music.phase_switch_once(&"ch4_ormund_phase_two", PHASE_TWO_TRACK, 0.18)


func _on_phase_transition_started(_duration: float) -> void:
	var music: MusicManagerService = get_node_or_null("/root/MusicManager") as MusicManagerService
	if music == null:
		return
	music.set_music_volume(-24.0, 0.65)
	music.play_transition_stinger(PHASE_TRANSITION_TRACK, true)


func _on_phase_transition_cue(cue_name: StringName, elapsed_seconds: float) -> void:
	_last_music_sync_cue = cue_name
	_last_music_sync_seconds = elapsed_seconds
	get_parent().set_meta(&"ormund_music_sync_cue", cue_name)
	get_parent().set_meta(&"ormund_music_sync_seconds", elapsed_seconds)


func _on_boss_attack_cue(action: StringName, cue_name: StringName) -> void:
	# Preserve a typed presentation hook for distinct metal, chain, water and
	# prison-pike SFX without coupling combat timing to an audio implementation.
	get_parent().set_meta(&"ormund_attack_cue_action", action)
	get_parent().set_meta(&"ormund_attack_cue_name", cue_name)


func _on_death_started() -> void:
	_combat_started = false
	_lock_player(true)
	if _boss_panel != null:
		_boss_panel.visible = false
	var music: MusicManagerService = get_node_or_null("/root/MusicManager") as MusicManagerService
	if music != null:
		music.fade_out(2.0)


func _on_boss_defeated() -> void:
	if _boss_defeated:
		return
	_boss_defeated = true
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.set_story_flag(FLAG_BOSS_DEFEATED)
		session.set_story_flag(&"ch4_reward_unlocked")
	if _dialogue_panel != null:
		_dialogue_panel.visible = true
		_dialogue_label.text = "ORMUND\n锁链断了……记忆就会回来。去看水面，看清你曾经做过什么。\nThe chains are broken. Memory will return. Look into the water—and see what you once did."
	await get_tree().create_timer(1.45).timeout
	if not is_inside_tree():
		return
	_dialogue_panel.visible = false
	reward_exit.set_locked(false)
	_lock_player(false)
	boss_flow_completed.emit()


func _on_player_respawned(_global_spawn_position: Vector2) -> void:
	if _boss_defeated or not _combat_started:
		return
	_combat_started = false
	var transition_controller: Chapter04RoomTransitionController = get_node_or_null(
		"../../../RoomTransitionController"
	) as Chapter04RoomTransitionController
	if transition_controller == null:
		push_error("Chapter04BossRoomController cannot restart the boss room after player death")
		return
	transition_controller.call_deferred("request_room_restart", &"EntryWest")


func complete_boss_for_qa() -> void:
	_on_boss_defeated()


func _lock_player(value: bool) -> void:
	if player == null:
		return
	player.set_input_profile(Player.InputProfile.LOCKED if value else Player.InputProfile.FULL)
	player.velocity = Vector2.ZERO
	if player.hurtbox != null:
		player.hurtbox.set_invulnerable(value)


func _play_intro_camera_reveal() -> void:
	if player == null or player.player_camera == null or boss == null:
		return
	var horizontal_offset: float = clampf(
		(boss.global_position.x - player.global_position.x) * 0.32, 0.0, 360.0
	)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		player.player_camera, "zoom", _default_camera_zoom * 0.82, CAMERA_REVEAL_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		player.player_camera,
		"offset",
		_default_camera_offset + Vector2(horizontal_offset, 0.0),
		CAMERA_REVEAL_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished


func _return_gameplay_camera() -> void:
	if player == null or player.player_camera == null:
		return
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		player.player_camera, "zoom", _default_camera_zoom, CAMERA_RETURN_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		player.player_camera, "offset", _default_camera_offset, CAMERA_RETURN_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished


func _play_boss_title() -> void:
	if _boss_title == null:
		return
	_boss_title.visible = true
	_boss_title.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(_boss_title, "modulate:a", 1.0, TITLE_FADE_IN)
	tween.tween_interval(TITLE_HOLD)
	tween.tween_property(_boss_title, "modulate:a", 0.0, TITLE_FADE_OUT)
	await tween.finished
	_boss_title.visible = false


func _play_phase_title() -> void:
	if _phase_title == null or _phase_title.visible:
		return
	_phase_title.visible = true
	_phase_title.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(_phase_title, "modulate:a", 1.0, TITLE_FADE_IN)
	tween.tween_interval(PHASE_TITLE_HOLD)
	tween.tween_property(_phase_title, "modulate:a", 0.0, TITLE_FADE_OUT)
	await tween.finished
	_phase_title.visible = false


func _play_phase_one_music(dialogue_duck: bool) -> void:
	var music: MusicManagerService = get_node_or_null("/root/MusicManager") as MusicManagerService
	if music != null:
		music.play_music(PHASE_ONE_TRACK, 0.8, true)
		if dialogue_duck:
			music.duck_for_dialogue(DIALOGUE_DUCK_DB, 0.18)
		else:
			music.restore_after_dialogue(0.0)


func _is_direct_phase_two_debug_start() -> bool:
	var debug: DebugRunConfigState = get_node_or_null("/root/DebugRunConfig") as DebugRunConfigState
	return debug != null and debug.is_chapter_start_allowed() and debug.debug_start_spawn_id == &"CH4_BOSS_PHASE_02"


func _start_direct_phase_two_debug() -> void:
	_intro_running = false
	_boss_panel.visible = true
	_lock_player(false)
	var music: MusicManagerService = get_node_or_null("/root/MusicManager") as MusicManagerService
	if music != null:
		music.clear_phase_switch_guard(&"ch4_ormund_phase_two")
		music.play_music(PHASE_TWO_TRACK, 0.45, true)
	boss.begin_debug_phase_two(player)
	_on_boss_health_changed(boss.health_component.current_health, boss.health_component.max_health)
	_combat_started = true
	intro_completed.emit()


func get_last_music_sync_cue() -> StringName:
	return _last_music_sync_cue


func get_last_music_sync_seconds() -> float:
	return _last_music_sync_seconds
