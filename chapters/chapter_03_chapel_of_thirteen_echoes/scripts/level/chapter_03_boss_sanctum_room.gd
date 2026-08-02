class_name Chapter03BossSanctumRoom
extends Chapter03Room

const PHASE_01_TRACK_ID: StringName = &"CH3_BOSS_MUSIC_PHASE_01"
const PHASE_02_TRACK_ID: StringName = &"CH3_BOSS_MUSIC_PHASE_02"
const PHASE_SWITCH_GUARD: StringName = &"CH3_EDRAN_PHASE_02_ONCE"
const INTRO_MUSIC_DB: float = -18.0
const COMBAT_MUSIC_DB: float = -10.0
const TRANSITION_MUSIC_DB: float = -24.0
const PHASE_CROSSFADE_SECONDS: float = 1.10
const DIALOGUE_DUCK_DB: float = 6.0
const DEATH_FADE_SECONDS: float = 1.50

@onready var sanctum: Chapter03BossSanctum = $BossSanctum as Chapter03BossSanctum
@onready var post_boss_exit: Chapter03RoomExit = $PostBossExit as Chapter03RoomExit
@onready var boss: ThirteenthPontiffEdran = (
	$BossActors/ThirteenthPontiffEdran as ThirteenthPontiffEdran
)
@onready var reward_sequence: Chapter03RewardSequenceController = (
	$RewardSequence as Chapter03RewardSequenceController
)

var _death_environment_done: bool = false
var _reward_formation_done: bool = false


func _ready() -> void:
	super._ready()
	post_boss_exit.set_deferred("monitoring", false)
	sanctum.death_environment_finished.connect(_on_death_environment_finished)
	sanctum.intro_environment_started.connect(_on_intro_environment_started)
	sanctum.intro_environment_finished.connect(_on_intro_environment_finished)
	sanctum.dialogue_started.connect(_on_dialogue_started)
	sanctum.dialogue_finished.connect(_on_dialogue_finished)
	boss.activated.connect(_on_boss_activated)
	boss.defeated.connect(_on_boss_defeated)
	boss.phase_transition_started.connect(_on_phase_transition_started)
	boss.phase_transition_stage_reached.connect(_on_phase_transition_stage_reached)
	boss.phase_changed.connect(_on_phase_changed)
	boss.death_sequence_started.connect(_on_death_sequence_started)
	reward_sequence.formation_finished.connect(_on_reward_formation_finished)
	call_deferred("_activate_boss_if_intro_skipped")


func _on_intro_environment_finished() -> void:
	_activate_boss()


func _on_intro_environment_started() -> void:
	var music_manager: MusicManagerService = _get_music_manager()
	if music_manager == null:
		return
	music_manager.play_music(PHASE_01_TRACK_ID, 0.60)
	music_manager.set_music_volume(INTRO_MUSIC_DB, 0.60)


func _activate_boss_if_intro_skipped() -> void:
	if sanctum.is_intro_complete():
		_activate_boss()


func _activate_boss() -> void:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	boss.activate(player)


func _on_boss_activated() -> void:
	var music_manager: MusicManagerService = _get_music_manager()
	if music_manager == null:
		return
	if music_manager.get_current_track_id() != PHASE_01_TRACK_ID:
		music_manager.play_music(PHASE_01_TRACK_ID, 0.35)
	music_manager.set_music_volume(COMBAT_MUSIC_DB, 0.50)


func _on_boss_defeated() -> void:
	var music_manager: MusicManagerService = _get_music_manager()
	if music_manager != null and music_manager.get_current_track_id() in [
		PHASE_01_TRACK_ID, PHASE_02_TRACK_ID,
	]:
		music_manager.fade_out(DEATH_FADE_SECONDS)
	sanctum.notify_boss_defeated()
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player == null or not reward_sequence.play_sequence(player):
		push_error("Chapter III reward formation could not start after Edran's defeat")


func _on_phase_transition_started() -> void:
	var music_manager: MusicManagerService = _get_music_manager()
	if music_manager != null and music_manager.get_current_track_id() == PHASE_01_TRACK_ID:
		music_manager.set_music_volume(TRANSITION_MUSIC_DB, 0.75)
	sanctum.play_phase_transition_environment()


func _on_phase_transition_stage_reached(stage_name: StringName) -> void:
	if stage_name != &"black_bell_reveal":
		return
	var music_manager: MusicManagerService = _get_music_manager()
	if music_manager != null:
		music_manager.phase_switch_once(
			PHASE_SWITCH_GUARD, PHASE_02_TRACK_ID, PHASE_CROSSFADE_SECONDS
		)


func _on_phase_changed(phase: int) -> void:
	# The normal route has already switched on the black-bell presentation beat.
	# This fallback only serves the existing immediate Phase 2 debug route.
	if phase != 2:
		return
	var music_manager: MusicManagerService = _get_music_manager()
	if music_manager != null and music_manager.get_current_track_id() != PHASE_02_TRACK_ID:
		music_manager.phase_switch_once(PHASE_SWITCH_GUARD, PHASE_02_TRACK_ID, 0.35)


func _on_death_sequence_started() -> void:
	sanctum.play_death_dialogue()
	var music_manager: MusicManagerService = _get_music_manager()
	if music_manager != null and music_manager.get_current_track_id() in [
		PHASE_01_TRACK_ID, PHASE_02_TRACK_ID,
	]:
		music_manager.fade_out(DEATH_FADE_SECONDS)


func _on_dialogue_started() -> void:
	var music_manager: MusicManagerService = _get_music_manager()
	if music_manager != null:
		music_manager.duck_for_dialogue(DIALOGUE_DUCK_DB, 0.18)


func _on_dialogue_finished() -> void:
	var music_manager: MusicManagerService = _get_music_manager()
	if music_manager != null:
		music_manager.restore_after_dialogue(0.25)


func _on_death_environment_finished() -> void:
	_death_environment_done = true
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.set_story_flag(&"chapter_03_boss_environment_defeated")
	_try_open_post_boss_exit()


func _on_reward_formation_finished() -> void:
	_reward_formation_done = true
	_try_open_post_boss_exit()


func _try_open_post_boss_exit() -> void:
	if _death_environment_done and _reward_formation_done:
		post_boss_exit.set_deferred("monitoring", true)


func _exit_tree() -> void:
	var music_manager: MusicManagerService = _get_music_manager()
	if music_manager != null and music_manager.get_current_track_id() in [
		PHASE_01_TRACK_ID, PHASE_02_TRACK_ID,
	]:
		music_manager.fade_out(0.35)


func _get_music_manager() -> MusicManagerService:
	return get_node_or_null("/root/MusicManager") as MusicManagerService
