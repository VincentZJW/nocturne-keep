class_name HollowDuchessRoomController
extends Node

## Owns Silent Ballroom encounter presentation, lock/camera/reset, not Boss combat decisions.

signal room_locked
signal room_reset
signal room_cleared

const PHASE_01_TRACK_ID: StringName = &"CH2_BOSS_MUSIC_PHASE_01"
const PHASE_02_TRACK_ID: StringName = &"CH2_BOSS_MUSIC_PHASE_02"
const TRANSITION_STINGER_ID: StringName = &"CH2_BOSS_MUSIC_TRANSITION_STINGER"
const PHASE_SWITCH_GUARD: StringName = &"CH2_DUCHESS_PHASE_02_ONCE"
const DIALOGUE_DUCK_DB: float = 6.0
const TRANSITION_MUSIC_DB: float = -20.0
const INTRO_MUSIC_DB: float = -18.0
const PHASE_01_COMBAT_DB: float = -12.0

@export_node_path("Player") var player_path: NodePath
@export_node_path("HollowDuchess") var boss_path: NodePath
@export_node_path("Area2D") var activation_area_path: NodePath
@export_node_path("StaticBody2D") var rear_door_path: NodePath
@export_node_path("StaticBody2D") var exit_door_path: NodePath
@export_node_path("Marker2D") var checkpoint_path: NodePath
@export_node_path("PlayerRespawnController") var respawn_controller_path: NodePath
@export_node_path("HollowDuchessBossHud") var boss_hud_path: NodePath
@export_node_path("Control") var intro_card_path: NodePath
@export_node_path("Control") var phase_title_path: NodePath
@export_node_path("Label") var dialogue_label_path: NodePath
@export_node_path("HollowDuchessBallroomFx") var ballroom_fx_path: NodePath
@export_node_path("DuchessEncounterPresentation") var presentation_path: NodePath
@export var camera_left: int = 27520
@export var camera_right: int = 32128
@export var external_entry_flow_enabled: bool = false

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var boss: HollowDuchess = get_node_or_null(boss_path) as HollowDuchess
@onready var activation_area: Area2D = get_node_or_null(activation_area_path) as Area2D
@onready var rear_door: StaticBody2D = get_node_or_null(rear_door_path) as StaticBody2D
@onready var exit_door: StaticBody2D = get_node_or_null(exit_door_path) as StaticBody2D
@onready var checkpoint: Marker2D = get_node_or_null(checkpoint_path) as Marker2D
@onready var respawn_controller: PlayerRespawnController = get_node_or_null(respawn_controller_path) as PlayerRespawnController
@onready var boss_hud: HollowDuchessBossHud = get_node_or_null(boss_hud_path) as HollowDuchessBossHud
@onready var intro_card: Control = get_node_or_null(intro_card_path) as Control
@onready var phase_title: Control = get_node_or_null(phase_title_path) as Control
@onready var dialogue_label: Label = get_node_or_null(dialogue_label_path) as Label
@onready var dialogue_panel: Control = dialogue_label.get_parent() as Control if dialogue_label != null else null
@onready var ballroom_fx: HollowDuchessBallroomFx = get_node_or_null(ballroom_fx_path) as HollowDuchessBallroomFx
@onready var presentation: DuchessEncounterPresentation = get_node_or_null(
	presentation_path
) as DuchessEncounterPresentation
@onready var music_manager: MusicManagerService = get_node_or_null("/root/MusicManager") as MusicManagerService

var encounter_started: bool = false
var room_is_cleared: bool = false
var intro_seen: bool = false
var _default_camera_left: int = 0
var _default_camera_right: int = 0
var _default_camera_zoom: Vector2 = Vector2.ONE
var _default_camera_offset: Vector2 = Vector2.ZERO
var _dialogue_tween: Tween
var _card_tween: Tween


func _ready() -> void:
	call_deferred("_initialize_room")


func _initialize_room() -> void:
	if not _validate_dependencies():
		return
	if external_entry_flow_enabled:
		activation_area.set_deferred("monitoring", false)
	else:
		activation_area.body_entered.connect(_on_activation_body_entered)
	boss.combat_started.connect(_on_boss_combat_started)
	boss.boss_defeated.connect(_on_boss_defeated)
	boss.intro_line_requested.connect(_on_intro_line_requested)
	boss.death_line_requested.connect(_on_death_line_requested)
	boss.phase_changed.connect(_on_boss_phase_changed)
	boss.phase_transition_started.connect(_on_phase_transition_started)
	boss.phase_transition_completed.connect(_on_phase_transition_completed)
	presentation.dialogue_requested.connect(_on_presentation_dialogue_requested)
	presentation.title_requested.connect(_on_presentation_title_requested)
	presentation.phase_02_revealed.connect(_on_phase_02_revealed)
	respawn_controller.player_respawned.connect(_on_player_respawned)
	boss_hud.bind_boss(boss)
	_default_camera_left = player.player_camera.limit_left
	_default_camera_right = player.player_camera.limit_right
	_default_camera_zoom = player.player_camera.zoom
	_default_camera_offset = player.player_camera.offset
	_set_door_closed(rear_door, false)
	_set_door_closed(exit_door, true)
	intro_card.visible = false
	phase_title.visible = false
	dialogue_panel.visible = false
	respawn_controller.set_spawn_point(checkpoint)


func _on_activation_body_entered(body: Node2D) -> void:
	if body != player or encounter_started or room_is_cleared:
		return
	_begin_encounter()


func begin_encounter_from_entrance() -> bool:
	if encounter_started or room_is_cleared or player.is_dead():
		return false
	_begin_encounter()
	return true


func _begin_encounter() -> void:
	encounter_started = true
	if music_manager != null:
		music_manager.clear_phase_switch_guard(PHASE_SWITCH_GUARD)
		music_manager.play_music(PHASE_01_TRACK_ID, 0.35)
		music_manager.set_music_volume(INTRO_MUSIC_DB, 0.0)
	respawn_controller.set_spawn_point(checkpoint)
	_set_door_closed(rear_door, true)
	_set_door_closed(exit_door, true)
	_lock_camera()
	_begin_intro_camera_reveal()
	player.set_input_profile(Player.InputProfile.LOCKED)
	boss.hurtbox.set_invulnerable(true)
	intro_card.visible = false
	activation_area.set_deferred("monitoring", false)
	boss.activate(player, intro_seen)
	presentation.play_intro(intro_seen)
	intro_seen = true
	room_locked.emit()


func _on_boss_combat_started() -> void:
	intro_card.visible = false
	phase_title.visible = false
	var camera_tween: Tween = create_tween()
	camera_tween.set_parallel(true)
	camera_tween.tween_property(player.player_camera, "zoom", _default_camera_zoom, 0.39)
	camera_tween.tween_property(player.player_camera, "offset", _default_camera_offset, 0.39)
	await camera_tween.finished
	boss_hud.show_for_combat()
	boss.hurtbox.set_invulnerable(false)
	player.set_input_profile(Player.InputProfile.FULL)
	if music_manager != null:
		music_manager.set_music_volume(PHASE_01_COMBAT_DB, 0.55)


func _on_intro_line_requested(text: String) -> void:
	_show_dialogue("SERAPHINE\n%s" % text, 0.72)


func _on_presentation_dialogue_requested(speaker: String, text: String, duration: float) -> void:
	_show_dialogue("%s\n%s" % [_format_speaker(speaker), text], duration)


func _on_presentation_title_requested(title: String, subtitle: String) -> void:
	var target: Control = phase_title if title.contains("UNMASKED") else intro_card
	var title_label: Label = target.get_node_or_null("Name") as Label
	var subtitle_label: Label = target.get_node_or_null(
		"Chinese" if target == phase_title else "Epithet"
	) as Label
	if target == phase_title:
		title_label.text = title
		subtitle_label.text = subtitle
	else:
		title_label.text = "%s / %s" % [title, subtitle]
	target.modulate.a = 0.0
	target.visible = true
	if _card_tween != null and _card_tween.is_valid():
		_card_tween.kill()
	_card_tween = create_tween()
	_card_tween.tween_property(target, "modulate:a", 1.0, 0.18)
	_card_tween.tween_interval(0.58 if target == phase_title else 0.70)
	_card_tween.tween_property(target, "modulate:a", 0.0, 0.24)
	_card_tween.tween_callback(func() -> void:
		target.visible = false
		target.modulate.a = 1.0
	)


func _on_death_line_requested(speaker: String, text: String) -> void:
	_show_dialogue("%s\n%s" % [_format_speaker(speaker), text], 0.72)


func _format_speaker(speaker: String) -> String:
	match speaker.strip_edges():
		"瑟芙琳":
			return "SERAPHINE"
		"夜巡守卫":
			return "NIGHT WARDEN"
		_:
			return speaker.to_upper()


func _on_boss_phase_changed(phase: int) -> void:
	if ballroom_fx != null:
		ballroom_fx.set_phase(phase)


func _on_phase_transition_started() -> void:
	if player.is_dead():
		return
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.velocity = Vector2.ZERO
	var camera_tween: Tween = create_tween()
	camera_tween.tween_property(player.player_camera, "zoom", _default_camera_zoom * 1.08, 0.45)
	presentation.play_phase_transition()
	if music_manager != null:
		music_manager.set_music_volume(TRANSITION_MUSIC_DB, 0.90)
		music_manager.play_transition_stinger(TRANSITION_STINGER_ID, true)


func _on_phase_02_revealed() -> void:
	if music_manager == null or room_is_cleared:
		return
	music_manager.restore_after_dialogue(0.0)
	music_manager.phase_switch_once(PHASE_SWITCH_GUARD, PHASE_02_TRACK_ID, 1.00)


func _on_phase_transition_completed() -> void:
	if not player.is_dead():
		player.set_input_profile(Player.InputProfile.FULL)
	var camera_tween: Tween = create_tween()
	camera_tween.tween_property(player.player_camera, "zoom", _default_camera_zoom, 0.35)


func _on_boss_defeated() -> void:
	if room_is_cleared:
		return
	room_is_cleared = true
	encounter_started = false
	_set_door_closed(rear_door, false)
	_set_door_closed(exit_door, false)
	_release_camera()
	if music_manager != null:
		music_manager.fade_out(1.50)
	room_cleared.emit()


func apply_persisted_clear_state() -> void:
	room_is_cleared = true
	encounter_started = false
	activation_area.set_deferred("monitoring", false)
	_set_door_closed(rear_door, false)
	_set_door_closed(exit_door, false)
	intro_card.visible = false
	phase_title.visible = false
	dialogue_panel.visible = false
	presentation.reset_presentation()
	boss_hud.hide_immediately()
	presentation.reset_presentation()
	boss.apply_persisted_defeat()
	if music_manager != null:
		music_manager.stop_music()
	_release_camera()


func _on_player_respawned(_spawn_position: Vector2) -> void:
	if room_is_cleared or not encounter_started:
		return
	boss.reset_boss()
	if music_manager != null:
		music_manager.stop_music()
		music_manager.clear_phase_switch_guard(PHASE_SWITCH_GUARD)
	encounter_started = false
	_set_door_closed(rear_door, false)
	_set_door_closed(exit_door, true)
	activation_area.set_deferred("monitoring", not external_entry_flow_enabled)
	intro_card.visible = false
	phase_title.visible = false
	dialogue_panel.visible = false
	boss_hud.hide_immediately()
	_release_camera()
	room_reset.emit()


func _exit_tree() -> void:
	if music_manager == null:
		return
	var current_track: StringName = music_manager.get_current_track_id()
	if current_track == PHASE_01_TRACK_ID or current_track == PHASE_02_TRACK_ID:
		music_manager.fade_out(0.20)


func _show_dialogue(text: String, duration: float) -> void:
	if _dialogue_tween != null and _dialogue_tween.is_valid():
		_dialogue_tween.kill()
	if music_manager != null:
		music_manager.duck_for_dialogue(DIALOGUE_DUCK_DB, 0.18)
	dialogue_label.text = text
	dialogue_label.modulate.a = 1.0
	dialogue_panel.visible = true
	_dialogue_tween = create_tween()
	_dialogue_tween.tween_interval(duration)
	_dialogue_tween.tween_property(dialogue_label, "modulate:a", 0.0, 0.25)
	_dialogue_tween.tween_callback(_finish_dialogue)


func _finish_dialogue() -> void:
	dialogue_panel.visible = false
	if music_manager != null:
		music_manager.restore_after_dialogue(0.25)


func _set_door_closed(door: StaticBody2D, closed: bool) -> void:
	door.visible = closed
	door.collision_layer = 1 if closed else 0
	for child: Node in door.get_children():
		var collision: CollisionShape2D = child as CollisionShape2D
		if collision != null:
			collision.set_deferred("disabled", not closed)


func _lock_camera() -> void:
	player.player_camera.limit_left = camera_left
	player.player_camera.limit_right = camera_right
	player.player_camera.zoom = _default_camera_zoom
	player.player_camera.offset = _default_camera_offset
	player.player_camera.reset_smoothing()


func _begin_intro_camera_reveal() -> void:
	var horizontal_offset: float = clampf(
		(boss.global_position.x - player.global_position.x) * 0.32, 0.0, 360.0
	)
	player.player_camera.offset = _default_camera_offset
	var camera_tween: Tween = create_tween()
	camera_tween.set_parallel(true)
	camera_tween.tween_property(
		player.player_camera, "zoom", _default_camera_zoom * 0.82, 0.65
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(
		player.player_camera,
		"offset",
		_default_camera_offset + Vector2(horizontal_offset, 0.0),
		0.65
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _release_camera() -> void:
	player.player_camera.limit_left = _default_camera_left
	player.player_camera.limit_right = _default_camera_right
	player.player_camera.zoom = _default_camera_zoom
	player.player_camera.offset = _default_camera_offset
	player.player_camera.reset_smoothing()


func _validate_dependencies() -> bool:
	if (
		player == null or boss == null or activation_area == null or rear_door == null
		or exit_door == null or checkpoint == null or respawn_controller == null
		or boss_hud == null or intro_card == null or phase_title == null
		or dialogue_label == null or dialogue_panel == null
		or presentation == null
	):
		push_error("HollowDuchessRoomController scene composition is incomplete")
		return false
	return true
