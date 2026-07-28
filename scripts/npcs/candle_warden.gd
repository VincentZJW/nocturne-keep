class_name CandleWarden
extends Node2D

## Story-only Candle Warden presentation. It owns no combat or following AI.

signal presentation_finished(state: PresentationState)

enum PresentationState {
	SEATED,
	RISING,
	IDLE,
	LANTERN_IDLE,
	LOOK_AT_PLAYER,
	WALK,
	RAISE_LANTERN,
	TALK,
	TALK_EMPHASIS,
	GESTURE_POINT,
	GESTURE_WARN,
	OFFER_KEY,
	OPEN_DOOR,
	TURN_AWAY,
	RETURN_TO_SHADOW,
}

@export_range(0.1, 2.0, 0.05) var base_light_energy: float = 0.58
@export_range(0.0, 0.2, 0.01) var light_flicker_amount: float = 0.05
@export_range(0.5, 2.0, 0.05) var presentation_speed: float = 1.0

@onready var visual_root: Node2D = $VisualRoot
@onready var body: AnimatedSprite2D = $VisualRoot/Body
@onready var soul_flame: AnimatedSprite2D = $VisualRoot/Lantern/SoulFlame
@onready var soul_light: PointLight2D = $VisualRoot/Lantern/SoulLight
@onready var soul_motes: GPUParticles2D = $VisualRoot/Lantern/SoulMotes

var presentation_state: PresentationState = PresentationState.SEATED
var facing_left: bool = true:
	set(value):
		facing_left = value
		_update_facing()

var _elapsed: float = 0.0
var _pulse_strength: float = 1.0
var _pulse_tween: Tween


func _ready() -> void:
	body.animation_finished.connect(_on_body_animation_finished)
	body.frame_changed.connect(_sync_lantern_anchor)
	soul_flame.play(&"soul_flame")
	set_presentation_state(presentation_state)
	_update_facing()


func _process(delta: float) -> void:
	_elapsed += delta
	var flicker: float = 1.0 + sin(_elapsed * 7.0) * light_flicker_amount
	soul_light.energy = base_light_energy * _pulse_strength * flicker
	soul_flame.modulate.a = clampf(0.86 + sin(_elapsed * 8.0) * 0.08, 0.72, 0.96)


func set_presentation_state(next_state: PresentationState) -> void:
	presentation_state = next_state
	var animation_name: StringName = _animation_for_state(next_state)
	if body.animation != animation_name or not body.is_playing():
		body.speed_scale = presentation_speed
		body.play(animation_name)
	_sync_lantern_anchor()


func get_current_animation() -> StringName:
	return body.animation


func pulse_soul_flame(strength: float = 1.35, duration: float = 0.35) -> void:
	_start_flame_pulse(maxf(1.0, strength), duration)


func contract_soul_flame(duration: float = 0.42) -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_strength = 0.48
	soul_flame.scale = Vector2(0.72, 0.72)
	_pulse_tween = create_tween().set_parallel(true)
	_pulse_tween.tween_property(self, "_pulse_strength", 1.0, duration).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(soul_flame, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_SINE)


func return_to_shadow() -> void:
	set_presentation_state(PresentationState.RETURN_TO_SHADOW)
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(visual_root, "modulate:a", 0.0, 0.95).set_trans(Tween.TRANS_SINE)


func restore_from_shadow() -> void:
	visual_root.modulate.a = 1.0
	set_presentation_state(PresentationState.IDLE)


func _start_flame_pulse(strength: float, duration: float) -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_strength = strength
	soul_flame.scale = Vector2.ONE * minf(1.28, 0.9 + strength * 0.16)
	_pulse_tween = create_tween().set_parallel(true)
	_pulse_tween.tween_property(self, "_pulse_strength", 1.0, duration).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(soul_flame, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_SINE)


func _animation_for_state(state: PresentationState) -> StringName:
	match state:
		PresentationState.SEATED:
			return &"seated"
		PresentationState.RISING:
			return &"rising"
		PresentationState.LANTERN_IDLE:
			return &"lantern_idle"
		PresentationState.LOOK_AT_PLAYER:
			return &"look_at_player"
		PresentationState.WALK:
			return &"slow_walk"
		PresentationState.RAISE_LANTERN:
			return &"raise_lantern"
		PresentationState.TALK:
			return &"talk"
		PresentationState.TALK_EMPHASIS:
			return &"talk_emphasis"
		PresentationState.GESTURE_POINT:
			return &"gesture_point"
		PresentationState.GESTURE_WARN:
			return &"gesture_warn"
		PresentationState.OFFER_KEY:
			return &"offer_key"
		PresentationState.OPEN_DOOR:
			return &"open_door"
		PresentationState.TURN_AWAY:
			return &"turn_away"
		PresentationState.RETURN_TO_SHADOW:
			return &"return_to_shadow"
		_:
			return &"idle"


func _sync_lantern_anchor() -> void:
	if not is_node_ready():
		return
	var anchor: Vector2 = Vector2(-28.0, -18.0)
	match presentation_state:
		PresentationState.SEATED:
			anchor.y = -1.0
		PresentationState.RISING:
			var rise_offsets: Array[float] = [15.0, 12.0, 8.0, 4.0, 0.0]
			anchor.y += rise_offsets[mini(body.frame, rise_offsets.size() - 1)]
		PresentationState.LANTERN_IDLE:
			var idle_swings: Array[float] = [-1.0, -1.0, 0.0, 1.0, 1.0, 0.0]
			anchor.x += idle_swings[mini(body.frame, idle_swings.size() - 1)]
		PresentationState.WALK:
			var walk_swings: Array[float] = [-2.0, -1.0, 0.0, 2.0, 1.0, 0.0]
			anchor.x += walk_swings[mini(body.frame, walk_swings.size() - 1)]
		PresentationState.TALK_EMPHASIS:
			anchor.y = -24.0
		PresentationState.GESTURE_WARN:
			anchor.y = -26.0
		PresentationState.RAISE_LANTERN:
			anchor.y = -31.0
		PresentationState.OPEN_DOOR:
			anchor.y = -22.0
		PresentationState.RETURN_TO_SHADOW:
			anchor.y = -20.0
	var facing_sign: float = 1.0 if facing_left else -1.0
	anchor.x *= facing_sign
	$VisualRoot/Lantern.position = anchor


func _update_facing() -> void:
	if not is_node_ready():
		return
	body.flip_h = not facing_left
	_sync_lantern_anchor()


func _on_body_animation_finished() -> void:
	presentation_finished.emit(presentation_state)
	if presentation_state in [
		PresentationState.RISING,
		PresentationState.LOOK_AT_PLAYER,
		PresentationState.RAISE_LANTERN,
		PresentationState.TALK_EMPHASIS,
		PresentationState.GESTURE_POINT,
		PresentationState.GESTURE_WARN,
		PresentationState.OFFER_KEY,
		PresentationState.OPEN_DOOR,
		PresentationState.TURN_AWAY,
	]:
		set_presentation_state(PresentationState.LANTERN_IDLE)
