class_name PontiffGravityJudgment
extends Node2D

## Presentation-only authority for The Weight of Absolution.
## HP settlement remains owned by ThirteenthPontiffEdran.

@export var cast_duration: float = 1.70
@export var target_glow_time: float = 0.55
@export var bell_reveal_time: float = 0.70
@export var seal_lock_time: float = 0.90
@export var pressure_time: float = 1.05

@onready var caster_aura: AnimatedSprite2D = $CasterAura as AnimatedSprite2D
@onready var compression: AnimatedSprite2D = $TargetRite/Compression as AnimatedSprite2D
@onready var sacred_bell: AnimatedSprite2D = $TargetRite/SacredBell as AnimatedSprite2D
@onready var judgment_seal: AnimatedSprite2D = $TargetRite/JudgmentSeal as AnimatedSprite2D
@onready var final_impact: AnimatedSprite2D = $TargetRite/FinalImpact as AnimatedSprite2D
@onready var screen_vignette: TextureRect = $ScreenAtmosphere/JudgmentVignette as TextureRect
@onready var bell_audio: AudioStreamPlayer2D = $BellInvocation as AudioStreamPlayer2D
@onready var lock_audio: AudioStreamPlayer2D = $SealLock as AudioStreamPlayer2D
@onready var impact_audio: AudioStreamPlayer2D = $FinalJudgment as AudioStreamPlayer2D

var target: Player
var caster: Node2D
var elapsed: float = 0.0
var final_seal: bool = false
var resolved: bool = false
var compressed_branch: bool = false

var _reaction_tween: Tween
var _target_visual_root: Node2D
var _target_visual_base_scale: Vector2 = Vector2.ONE
var _target_visual_base_modulate: Color = Color.WHITE
var _target_camera: Camera2D
var _target_camera_base_offset: Vector2 = Vector2.ZERO
var _sanctum_candles: Node2D
var _candles_base_scale: Vector2 = Vector2.ONE
var _candles_base_modulate: Color = Color.WHITE
var _aura_started: bool = false
var _target_glow_started: bool = false
var _bell_reveal_started: bool = false
var _seal_lock_started: bool = false
var _pressure_started: bool = false
var _bell_audio_started: bool = false
var _lock_audio_started: bool = false


func initialize(player: Player, duration: float, source_caster: Node2D = null) -> void:
	target = player
	cast_duration = duration
	caster = source_caster


func _ready() -> void:
	for animated_sprite: AnimatedSprite2D in [
		caster_aura, compression, sacred_bell, judgment_seal,
	]:
		animated_sprite.play()
	caster_aura.modulate.a = 0.0
	compression.visible = false
	sacred_bell.visible = false
	judgment_seal.visible = false
	final_impact.visible = false
	screen_vignette.modulate.a = 0.0
	if target != null and is_instance_valid(target):
		_target_camera = target.player_camera
		if _target_camera != null:
			_target_camera_base_offset = _target_camera.offset
	_sanctum_candles = get_tree().get_first_node_in_group(
		"chapter_03_judgment_candles"
	) as Node2D
	if _sanctum_candles != null:
		_candles_base_scale = _sanctum_candles.scale
		_candles_base_modulate = _sanctum_candles.modulate


func _process(delta: float) -> void:
	elapsed = minf(cast_duration, elapsed + delta)
	_follow_ritual_anchors()
	if not _aura_started:
		_start_caster_aura()
	if not _bell_audio_started and elapsed >= 0.35:
		_bell_audio_started = true
		bell_audio.play()
	if not _target_glow_started and elapsed >= target_glow_time:
		_start_target_glow()
	if not _bell_reveal_started and elapsed >= bell_reveal_time:
		_reveal_sacred_bell()
	if not _seal_lock_started and elapsed >= seal_lock_time:
		_lock_judgment_seal()
	if not _pressure_started and elapsed >= pressure_time:
		_start_compression()


func set_final_seal() -> void:
	if final_seal:
		return
	final_seal = true
	if not _bell_audio_started:
		_bell_audio_started = true
		bell_audio.play()
	if not _seal_lock_started:
		_lock_judgment_seal()
	var seal_tween: Tween = create_tween()
	seal_tween.set_parallel(true)
	seal_tween.tween_property(sacred_bell, "position:y", -91.0, 0.20).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_IN)
	seal_tween.tween_property(sacred_bell, "scale", Vector2(1.08, 0.92), 0.20)
	seal_tween.tween_property(judgment_seal, "scale", Vector2(0.90, 0.78), 0.20)
	seal_tween.tween_property(
		judgment_seal, "modulate", Color(1.12, 1.12, 1.08, 1.0), 0.20
	)
	seal_tween.tween_property(compression, "scale:y", 0.76, 0.20)
	if _target_camera != null:
		seal_tween.tween_property(
			_target_camera, "offset", _target_camera_base_offset + Vector2(0.0, 4.0), 0.20
		)


func show_resolution(was_compressed: bool) -> void:
	if resolved:
		return
	resolved = true
	compressed_branch = was_compressed
	impact_audio.play()
	final_impact.visible = true
	final_impact.modulate.a = 1.0
	final_impact.play(&"final_impact")
	_play_gravity_judgment_reaction()
	var impact_tween: Tween = create_tween()
	impact_tween.set_parallel(true)
	impact_tween.tween_property(sacred_bell, "position:y", -78.0, 0.07)
	impact_tween.tween_property(sacred_bell, "modulate:a", 0.18, 0.32)
	impact_tween.tween_property(judgment_seal, "scale", Vector2(0.64, 0.55), 0.10)
	impact_tween.tween_property(
		judgment_seal, "modulate", Color(1.2, 1.2, 1.15, 0.22), 0.34
	)
	impact_tween.tween_property(compression, "modulate:a", 0.0, 0.28)
	impact_tween.tween_property(caster_aura, "modulate:a", 0.12, 0.45)
	impact_tween.tween_property(screen_vignette, "modulate:a", 0.68, 0.06)
	impact_tween.chain().tween_property(screen_vignette, "modulate:a", 0.0, 0.34)
	_restore_environment_pressure(0.30)


func finish() -> void:
	_restore_target_presentation()
	_restore_environment_pressure(0.0)
	queue_free()


func _follow_ritual_anchors() -> void:
	if target != null and is_instance_valid(target):
		global_position = target.global_position
	if caster != null and is_instance_valid(caster):
		caster_aura.global_position = caster.global_position + Vector2(0.0, -45.0)


func _start_caster_aura() -> void:
	_aura_started = true
	caster_aura.visible = caster != null and is_instance_valid(caster)
	if not caster_aura.visible:
		return
	caster_aura.play(&"cast_aura")
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(caster_aura, "modulate:a", 0.82, 0.24)
	tween.tween_property(caster_aura, "scale", Vector2.ONE, 0.34).from(
		Vector2(0.72, 0.72)
	)


func _start_target_glow() -> void:
	_target_glow_started = true
	judgment_seal.visible = true
	judgment_seal.modulate.a = 0.0
	judgment_seal.scale = Vector2(0.40, 0.40)
	judgment_seal.play(&"judgment_seal")
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(judgment_seal, "modulate:a", 0.78, 0.24)
	tween.tween_property(judgment_seal, "scale", Vector2.ONE, 0.30).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(screen_vignette, "modulate:a", 0.34, 0.34)


func _reveal_sacred_bell() -> void:
	_bell_reveal_started = true
	sacred_bell.visible = true
	sacred_bell.modulate.a = 0.0
	sacred_bell.position.y = -126.0
	sacred_bell.scale = Vector2(0.78, 0.78)
	sacred_bell.play(&"sacred_bell")
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sacred_bell, "modulate:a", 0.88, 0.28)
	tween.tween_property(sacred_bell, "position:y", -106.0, 0.34).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(sacred_bell, "scale", Vector2.ONE, 0.34)


func _lock_judgment_seal() -> void:
	_seal_lock_started = true
	if not _lock_audio_started:
		_lock_audio_started = true
		lock_audio.play()
	judgment_seal.speed_scale = 1.45
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(judgment_seal, "rotation", -0.11, 0.18)
	tween.tween_property(judgment_seal, "modulate:a", 1.0, 0.18)


func _start_compression() -> void:
	_pressure_started = true
	compression.visible = true
	compression.modulate.a = 0.0
	compression.scale = Vector2(1.12, 1.12)
	compression.play(&"compression")
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(compression, "modulate:a", 0.72, 0.26)
	tween.tween_property(compression, "scale", Vector2.ONE, 0.30)
	if _sanctum_candles != null:
		var candle_tween: Tween = create_tween()
		candle_tween.set_parallel(true)
		candle_tween.tween_property(
			_sanctum_candles,
			"scale",
			Vector2(_candles_base_scale.x, _candles_base_scale.y * 0.54),
			0.26
		)
		candle_tween.tween_property(
			_sanctum_candles,
			"modulate",
			Color(0.52, 0.66, 0.82, _candles_base_modulate.a * 0.66),
			0.26
		)


func _play_gravity_judgment_reaction() -> void:
	if target == null or not is_instance_valid(target):
		return
	_target_visual_root = target.get_node_or_null("VisualRoot") as Node2D
	if _target_visual_root == null:
		return
	if _reaction_tween != null and _reaction_tween.is_valid():
		_reaction_tween.kill()
	_target_visual_base_scale = _target_visual_root.scale
	_target_visual_base_modulate = _target_visual_root.modulate
	_reaction_tween = create_tween()
	_reaction_tween.set_parallel(true)
	_reaction_tween.tween_property(
		_target_visual_root,
		"scale",
		Vector2(_target_visual_base_scale.x * 1.04, _target_visual_base_scale.y * 0.80),
		0.08
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_reaction_tween.tween_property(
		_target_visual_root,
		"modulate",
		Color(0.68, 0.75, 0.90, _target_visual_base_modulate.a),
		0.08
	)
	_reaction_tween.chain().set_parallel(true)
	_reaction_tween.tween_property(
		_target_visual_root, "scale", _target_visual_base_scale, 0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_reaction_tween.tween_property(
		_target_visual_root, "modulate", _target_visual_base_modulate, 0.22
	)


func _restore_target_presentation() -> void:
	if _reaction_tween != null and _reaction_tween.is_valid():
		_reaction_tween.kill()
	if _target_visual_root != null and is_instance_valid(_target_visual_root):
		_target_visual_root.scale = _target_visual_base_scale
		_target_visual_root.modulate = _target_visual_base_modulate
	_target_visual_root = null


func _restore_environment_pressure(duration: float) -> void:
	if _target_camera != null and is_instance_valid(_target_camera):
		if duration <= 0.0:
			_target_camera.offset = _target_camera_base_offset
		else:
			create_tween().tween_property(
				_target_camera, "offset", _target_camera_base_offset, duration
			)
	if _sanctum_candles != null and is_instance_valid(_sanctum_candles):
		if duration <= 0.0:
			_sanctum_candles.scale = _candles_base_scale
			_sanctum_candles.modulate = _candles_base_modulate
		else:
			var candle_tween: Tween = create_tween()
			candle_tween.set_parallel(true)
			candle_tween.tween_property(
				_sanctum_candles, "scale", _candles_base_scale, duration
			)
			candle_tween.tween_property(
				_sanctum_candles, "modulate", _candles_base_modulate, duration
			)
