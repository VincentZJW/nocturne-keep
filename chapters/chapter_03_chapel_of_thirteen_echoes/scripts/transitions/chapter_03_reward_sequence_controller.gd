class_name Chapter03RewardSequenceController
extends Node2D

## Presents Edran's one-shot reforging aftermath. Boss death and reward ownership
## remain separate authorities; this node only owns presentation and its lock.

signal formation_started
signal formation_stage_changed(stage_name: StringName)
signal formation_finished

const FLAG_REWARD_SPAWNED: StringName = &"chapter_03_boss_reward_spawned"

@export_range(0.10, 2.00, 0.05) var fragment_duration: float = 1.20
@export_range(0.10, 2.00, 0.05) var seal_duration: float = 0.95
@export_range(0.10, 2.00, 0.05) var forge_duration: float = 1.25
@export_range(0.10, 1.50, 0.05) var hold_duration: float = 0.80

@onready var fragment_root: Node2D = $Fragments as Node2D
@onready var seal_root: Node2D = $SealNodes as Node2D
@onready var resonance: Sprite2D = $Resonance as Sprite2D
@onready var weapon: Sprite2D = $Weapon as Sprite2D
@onready var resonance_audio: AudioStreamPlayer2D = $ResonanceAudio as AudioStreamPlayer2D

var _running: bool = false
var _completed: bool = false


func _ready() -> void:
	_reset_presentation()


func play_sequence(player: Player) -> bool:
	if _running or _completed or player == null:
		return false
	_running = true
	_run_sequence(player)
	return true


func is_running() -> bool:
	return _running


func is_complete() -> bool:
	return _completed


func get_total_duration() -> float:
	return fragment_duration + seal_duration + forge_duration + hold_duration


func _run_sequence(player: Player) -> void:
	var previous_profile: Player.InputProfile = player.get_input_profile()
	var was_invulnerable: bool = player.hurtbox != null and player.hurtbox.is_invulnerable
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.velocity = Vector2.ZERO
	if player.hurtbox != null:
		player.hurtbox.set_invulnerable(true)
	visible = true
	formation_started.emit()
	formation_stage_changed.emit(&"fragments_converge")
	var fragments: Array[Node] = fragment_root.get_children()
	var fragment_tween: Tween = create_tween().set_parallel(true)
	for index: int in range(fragments.size()):
		var fragment: Sprite2D = fragments[index] as Sprite2D
		if fragment == null:
			continue
		fragment.visible = true
		fragment.modulate.a = 0.0
		fragment_tween.tween_property(fragment, "modulate:a", 1.0, fragment_duration * 0.25)
		fragment_tween.tween_property(
			fragment, "position", Vector2((index - 2) * 5.0, (index % 2) * 4.0), fragment_duration
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		fragment_tween.tween_property(
			fragment, "rotation", fragment.rotation + (0.7 if index % 2 == 0 else -0.7), fragment_duration
		)
	await fragment_tween.finished
	for fragment_node: Node in fragments:
		(fragment_node as CanvasItem).visible = false

	formation_stage_changed.emit(&"thirteen_seals_extinguish")
	resonance.visible = true
	resonance.modulate.a = 0.0
	resonance_audio.play()
	var seal_nodes: Array[Node] = seal_root.get_children()
	for index: int in range(seal_nodes.size()):
		var seal: Sprite2D = seal_nodes[index] as Sprite2D
		if seal == null:
			continue
		seal.visible = true
		seal.modulate.a = 0.0
		var seal_tween: Tween = create_tween()
		seal_tween.tween_interval(float(index) * seal_duration / 18.0)
		seal_tween.tween_property(seal, "modulate:a", 0.90, seal_duration * 0.18)
		seal_tween.tween_property(seal, "modulate", Color(0.30, 0.34, 0.40, 0.24), seal_duration * 0.20)
	var resonance_tween: Tween = create_tween()
	resonance_tween.tween_property(resonance, "modulate:a", 0.82, seal_duration * 0.25)
	resonance_tween.tween_property(resonance, "modulate:a", 0.10, seal_duration * 0.75)
	await get_tree().create_timer(seal_duration).timeout

	# The Boss arena owns only the reforging resonance. The sole collectible and
	# authoritative weapon presentation lives in the post-Boss reliquary.
	formation_stage_changed.emit(&"reliquary_unsealed")
	weapon.visible = false
	var forge_tween: Tween = create_tween()
	forge_tween.tween_property(resonance, "modulate:a", 0.52, forge_duration * 0.30)
	forge_tween.tween_property(resonance, "modulate:a", 0.0, forge_duration * 0.70)
	await forge_tween.finished
	formation_stage_changed.emit(&"reliquary_ready")
	await get_tree().create_timer(hold_duration).timeout

	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.boss_reward_spawned = true
		session.set_story_flag(FLAG_REWARD_SPAWNED)
	_completed = true
	_running = false
	visible = false
	weapon.visible = false
	if is_instance_valid(player) and not player.is_dead():
		if player.hurtbox != null and not was_invulnerable:
			player.hurtbox.set_invulnerable(false)
		player.set_input_profile(previous_profile)
	formation_finished.emit()


func _reset_presentation() -> void:
	visible = false
	resonance.visible = false
	weapon.visible = false
	for fragment: Node in fragment_root.get_children():
		(fragment as CanvasItem).visible = false
	for seal: Node in seal_root.get_children():
		(seal as CanvasItem).visible = false
