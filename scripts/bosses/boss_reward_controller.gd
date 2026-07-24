class_name BossRewardController
extends Node2D

## Fixed first-Boss reward. It never participates in the normal loot table.

signal reward_spawned
signal reward_collected(weapon_id: StringName)

const REWARD_WEAPON_ID: StringName = &"ravenfang_daggers"
const BOSS_COIN_REWARD: int = 30

@export_node_path("FallenGateKnight") var boss_path: NodePath = NodePath("../FallenGateKnight")
@export_node_path("WeaponPickup") var weapon_pickup_path: NodePath = NodePath("WeaponPickup")
@export_node_path("Node2D") var coin_feedback_path: NodePath = NodePath("CoinFeedback")
@export_node_path("Label") var acquired_label_path: NodePath = NodePath("AcquiredLabel")
@export_node_path("Label") var gate_prompt_path: NodePath = NodePath("GatePrompt")
@export_node_path("AudioStreamPlayer") var reward_audio_path: NodePath = NodePath("RewardAudio")

@onready var boss: FallenGateKnight = get_node_or_null(boss_path) as FallenGateKnight
@onready var weapon_pickup: WeaponPickup = get_node_or_null(weapon_pickup_path) as WeaponPickup
@onready var coin_feedback: Node2D = get_node_or_null(coin_feedback_path) as Node2D
@onready var acquired_label: Label = get_node_or_null(acquired_label_path) as Label
@onready var gate_prompt: Label = get_node_or_null(gate_prompt_path) as Label
@onready var reward_audio: AudioStreamPlayer = get_node_or_null(
	reward_audio_path
) as AudioStreamPlayer


func _ready() -> void:
	if boss == null or weapon_pickup == null or coin_feedback == null or acquired_label == null or gate_prompt == null or reward_audio == null:
		push_error("BossRewardController scene composition is incomplete")
		return
	if DisplayServer.get_name() != "headless":
		reward_audio.stream = _create_reward_chime()
	boss.boss_defeated.connect(_on_boss_defeated)
	weapon_pickup.weapon_collected.connect(_on_weapon_collected)
	coin_feedback.visible = false
	acquired_label.visible = false
	gate_prompt.visible = false
	var session: ChapterSessionState = _session()
	weapon_pickup.set_available(session != null and session.boss_reward_spawned and not is_reward_collected())


func _exit_tree() -> void:
	if reward_audio != null:
		reward_audio.stop()
		reward_audio.stream = null


func is_reward_collected() -> bool:
	var session: ChapterSessionState = _session()
	var inventory: PlayerWeaponInventory = _inventory()
	return (
		(session != null and session.boss_reward_collected)
		or (inventory != null and inventory.owns_weapon(REWARD_WEAPON_ID))
	)


func show_gate_prompt() -> void:
	if is_reward_collected():
		return
	gate_prompt.visible = true
	gate_prompt.modulate.a = 1.0
	var tween: Tween = gate_prompt.create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(gate_prompt, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func() -> void: gate_prompt.visible = false)


func debug_force_reward() -> void:
	_on_boss_defeated()


func _on_boss_defeated() -> void:
	var session: ChapterSessionState = _session()
	var wallet: CurrencyWallet = _wallet()
	if session == null or wallet == null:
		return
	if session.boss_reward_spawned:
		weapon_pickup.set_available(not is_reward_collected())
		return
	session.boss_reward_spawned = true
	wallet.add_coins(BOSS_COIN_REWARD)
	_show_coin_feedback()
	_play_reward_audio(0.92)
	weapon_pickup.set_available(true)
	reward_spawned.emit()


func _on_weapon_collected(weapon_id: StringName) -> void:
	var session: ChapterSessionState = _session()
	if session != null:
		session.boss_reward_collected = true
	_play_reward_audio(1.12)
	acquired_label.text = "获得 鸦牙双匕  ·  ATTACK 10 → 12\nRAVENFANG DAGGERS ACQUIRED"
	acquired_label.visible = true
	acquired_label.modulate.a = 1.0
	var tween: Tween = acquired_label.create_tween()
	tween.tween_interval(1.6)
	tween.tween_property(acquired_label, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func() -> void: acquired_label.visible = false)
	reward_collected.emit(weapon_id)


func _show_coin_feedback() -> void:
	coin_feedback.visible = true
	coin_feedback.modulate.a = 1.0
	coin_feedback.position.y = -38.0
	var tween: Tween = coin_feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(coin_feedback, "position:y", -55.0, 0.8)
	tween.tween_property(coin_feedback, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(func() -> void: coin_feedback.visible = false)


func _session() -> ChapterSessionState:
	return get_node_or_null("/root/ChapterSession") as ChapterSessionState


func _wallet() -> CurrencyWallet:
	return get_node_or_null("/root/CurrencyManager") as CurrencyWallet


func _inventory() -> PlayerWeaponInventory:
	return get_node_or_null("/root/WeaponInventory") as PlayerWeaponInventory


func _play_reward_audio(pitch: float) -> void:
	if reward_audio == null or reward_audio.stream == null:
		return
	reward_audio.pitch_scale = pitch
	reward_audio.play()


func _create_reward_chime() -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	var sample_count: int = int(stream.mix_rate * 0.22)
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)
	for index: int in range(sample_count):
		var time: float = float(index) / float(stream.mix_rate)
		var envelope: float = 1.0 - float(index) / float(sample_count)
		var wave: float = sin(TAU * 523.25 * time) * 0.55 + sin(TAU * 783.99 * time) * 0.25
		data.encode_s16(index * 2, int(clampf(wave * envelope, -1.0, 1.0) * 12000.0))
	stream.data = data
	return stream
