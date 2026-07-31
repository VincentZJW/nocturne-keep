class_name Chapter03BossSanctum
extends Node2D

## Environment-only presentation authority for Edran's future Boss scene.
## Boss combat connects to these typed hooks without making this scene own AI.

signal intro_environment_finished
signal intro_environment_started
signal phase_transition_environment_finished
signal death_environment_finished
signal dialogue_started
signal dialogue_finished

@export_range(0.02, 0.20, 0.01) var candle_step_duration: float = 0.07
@export_range(0.10, 1.00, 0.05) var camera_reveal_duration: float = 0.65
@export_range(0.20, 2.00, 0.10) var title_hold_duration: float = 0.70
@export var trigger_starts_intro: bool = true

@onready var intro_trigger: Area2D = $IntroTrigger as Area2D
@onready var candles: Node2D = $Presentation/Candles as Node2D
@onready var incense: Sprite2D = $Presentation/Incense as Sprite2D
@onready var resonance: Sprite2D = $Presentation/Resonance as Sprite2D
@onready var glass_crack: Sprite2D = $Presentation/StainedGlassCrack as Sprite2D
@onready var intact_altar: Sprite2D = $Presentation/Altar as Sprite2D
@onready var collapsed_altar: Sprite2D = $Presentation/CollapsedAltar as Sprite2D
@onready var exit_blocker: CollisionShape2D = $BossExitBlocker/CollisionShape2D as CollisionShape2D
@onready var intro_camera: Camera2D = $IntroCamera as Camera2D
@onready var boss_title: Control = $BossIntroOverlay/BossTitle as Control
@onready var dialogue_panel: Control = $BossIntroOverlay/DialoguePanel as Control
@onready var dialogue_label: Label = $BossIntroOverlay/DialoguePanel/Dialogue as Label
@onready var phase_title: Control = $BossIntroOverlay/PhaseTitle as Control

var _intro_running: bool = false
var _intro_complete: bool = false
var _death_response_complete: bool = false


func _ready() -> void:
	intro_trigger.body_entered.connect(_on_intro_trigger_entered)
	reset_environment()


func reset_environment() -> void:
	_intro_running = false
	_intro_complete = false
	_death_response_complete = false
	for child: Node in candles.get_children():
		(child as CanvasItem).visible = false
	incense.visible = true
	incense.modulate.a = 0.38
	resonance.visible = false
	glass_crack.visible = false
	intact_altar.visible = true
	collapsed_altar.visible = false
	exit_blocker.set_deferred("disabled", false)
	boss_title.visible = false
	boss_title.modulate.a = 0.0
	dialogue_panel.visible = false
	phase_title.visible = false


func skip_intro_to_combat_state() -> void:
	_intro_complete = true
	_intro_running = false
	for child: Node in candles.get_children():
		(child as CanvasItem).visible = true
	incense.visible = true
	incense.modulate.a = 0.52
	resonance.visible = false


func play_intro_environment(player: Player, boss: ThirteenthPontiffEdran = null) -> void:
	if _intro_complete or _intro_running or player == null:
		return
	_intro_running = true
	intro_environment_started.emit()
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.velocity = Vector2.ZERO
	var player_camera: Camera2D = player.player_camera
	if player_camera != null:
		player_camera.enabled = false
	intro_camera.position = Vector2(520.0, 360.0)
	intro_camera.enabled = true
	if boss != null:
		boss.play_cinematic_animation(&"scripture_writing")
	for child: Node in candles.get_children():
		(child as CanvasItem).visible = true
		(child as CanvasItem).modulate.a = 0.0
		var candle_tween: Tween = create_tween()
		candle_tween.tween_property(child, "modulate:a", 1.0, candle_step_duration)
		await candle_tween.finished
	incense.modulate.a = 0.32
	resonance.visible = true
	resonance.modulate.a = 0.0
	var reveal_tween: Tween = create_tween()
	reveal_tween.tween_property(
		intro_camera, "position", Vector2(1600.0, 360.0), camera_reveal_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	reveal_tween.parallel().tween_property(incense, "position:x", 1600.0, camera_reveal_duration)
	reveal_tween.parallel().tween_property(incense, "modulate:a", 0.70, camera_reveal_duration)
	var resonance_tween: Tween = create_tween()
	resonance_tween.tween_property(resonance, "modulate:a", 0.75, 0.18)
	resonance_tween.tween_property(resonance, "modulate:a", 0.0, 0.42)
	await reveal_tween.finished
	resonance.visible = false
	var dialogue: Array[String] = [
		"EDRAN\n终于……第十四位回到了礼拜堂。",
		"NIGHT WARDEN\n十三次钟声，都是你主持的？",
		"EDRAN\n我只替王冠赦免它无法承担的罪。",
		"NIGHT WARDEN\n那些被献祭的人，也叫赦免？",
		"EDRAN\n肉身会腐烂，侍奉却不必结束。",
		"NIGHT WARDEN\n你把他们变成了什么？",
		"EDRAN\n被钟声记住的人。",
		"NIGHT WARDEN\n那第十四次呢？",
		"EDRAN\n第十四次不需要死者。\n它需要一个已经死过，却仍能回来的人。",
	]
	dialogue_started.emit()
	dialogue_panel.visible = true
	for index: int in range(dialogue.size()):
		dialogue_label.text = dialogue[index]
		if boss != null and index == 1:
			boss.play_cinematic_animation(&"intro_turn")
		await get_tree().create_timer(0.72 if index < dialogue.size()-1 else 1.0).timeout
	dialogue_panel.visible = false
	dialogue_finished.emit()
	boss_title.visible = true
	boss_title.modulate.a = 0.0
	var title_tween: Tween = create_tween()
	title_tween.tween_property(boss_title, "modulate:a", 1.0, 0.18)
	title_tween.tween_interval(title_hold_duration)
	title_tween.tween_property(boss_title, "modulate:a", 0.0, 0.24)
	await title_tween.finished
	boss_title.visible = false
	var player_local_position: Vector2 = to_local(player.global_position)
	var return_tween: Tween = create_tween()
	return_tween.tween_property(
		intro_camera,
		"position",
		Vector2(player_local_position.x, 360.0),
		camera_reveal_duration * 0.6
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await return_tween.finished
	intro_camera.enabled = false
	if player_camera != null:
		player_camera.enabled = true
		player_camera.reset_smoothing()
	player.set_input_profile(Player.InputProfile.FULL)
	_intro_running = false
	_intro_complete = true
	intro_environment_finished.emit()


func play_phase_transition_environment() -> void:
	for index: int in range(candles.get_child_count()):
		var candle: CanvasItem = candles.get_child(index) as CanvasItem
		var tween: Tween = create_tween()
		tween.tween_property(candle,"rotation",deg_to_rad(-16.0 if index%2==0 else 16.0),0.24)
		if index % 3 == 0:
			tween.parallel().tween_property(candle,"modulate",Color(0.58,0.76,0.9,0.72),0.24)
	resonance.visible = true
	resonance.modulate.a = 0.0
	var resonance_tween: Tween = create_tween()
	resonance_tween.tween_property(resonance,"modulate:a",0.82,0.22)
	resonance_tween.tween_property(resonance,"modulate:a",0.18,1.1)
	await resonance_tween.finished
	var transition_dialogue: Array[String] = [
		"EDRAN\n听见了吗？",
		"EDRAN\n他们仍在为你唱诗。",
		"EDRAN\n钟从不在高处鸣响。",
		"EDRAN\n它在每一具未被埋葬的身体里鸣响。",
	]
	dialogue_started.emit()
	dialogue_panel.visible = true
	for line: String in transition_dialogue:
		dialogue_label.text = line
		await get_tree().create_timer(0.66).timeout
	dialogue_panel.visible = false
	dialogue_finished.emit()
	phase_title.visible = true
	phase_title.modulate.a = 0.0
	var title_tween: Tween = create_tween()
	title_tween.tween_property(phase_title,"modulate:a",1.0,0.18)
	title_tween.tween_interval(0.58)
	title_tween.tween_property(phase_title,"modulate:a",0.0,0.24)
	await title_tween.finished
	phase_title.visible = false
	resonance.visible = false
	phase_transition_environment_finished.emit()


func play_death_dialogue() -> void:
	dialogue_started.emit()
	dialogue_panel.visible = true
	dialogue_label.text = "EDRAN\n向下去吧……"
	await get_tree().create_timer(0.78).timeout
	dialogue_label.text = "EDRAN\n王冠把未能被赦免的人……锁在水下。"
	await get_tree().create_timer(1.05).timeout
	dialogue_panel.visible = false
	dialogue_finished.emit()


func notify_boss_defeated() -> void:
	if _death_response_complete:
		return
	_death_response_complete = true
	var candle_nodes: Array[Node] = candles.get_children()
	for index: int in range(candle_nodes.size() - 1, -1, -1):
		var candle: CanvasItem = candle_nodes[index] as CanvasItem
		var extinguish: Tween = create_tween()
		extinguish.tween_property(candle, "modulate:a", 0.0, 0.035)
		await extinguish.finished
	glass_crack.visible = true
	glass_crack.modulate.a = 0.0
	var crack_tween: Tween = create_tween()
	crack_tween.tween_property(glass_crack, "modulate:a", 0.88, 0.28)
	await crack_tween.finished
	intact_altar.visible = false
	collapsed_altar.visible = true
	exit_blocker.set_deferred("disabled", true)
	death_environment_finished.emit()


func is_intro_complete() -> bool:
	return _intro_complete


func is_death_response_complete() -> bool:
	return _death_response_complete


func _on_intro_trigger_entered(body: Node2D) -> void:
	if not trigger_starts_intro:
		return
	var player: Player = body as Player
	if player != null:
		play_intro_environment(player)
