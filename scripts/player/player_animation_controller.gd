class_name PlayerAnimationController
extends Node

## Presentation-only animation arbitration. It owns no movement, health, or damage logic.

signal one_shot_finished(animation_name: StringName)
signal animation_changed(animation_name: StringName)
signal facing_changed(facing_left: bool)

const ATTACK_HIT_FRAMES: Array[int] = [2, 3]
const LOOP_ANIMATIONS: Array[StringName] = [&"idle", &"run", &"jump_loop", &"fall"]
const ONE_SHOT_ANIMATIONS: Array[StringName] = [
	&"jump_start", &"land", &"dash", &"attack", &"hurt", &"death",
]
const FACING_LOCK_ANIMATIONS: Array[StringName] = [&"dash", &"attack"]
const PRIORITIES: Dictionary[StringName, int] = {
	&"idle": 10,
	&"run": 20,
	&"jump_loop": 40,
	&"fall": 40,
	&"jump_start": 50,
	&"land": 60,
	&"dash": 70,
	&"attack": 80,
	&"hurt": 90,
	&"death": 100,
}

@export_node_path("AnimatedSprite2D") var animated_sprite_path: NodePath = NodePath("../VisualRoot/AnimatedSprite2D")

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(animated_sprite_path) as AnimatedSprite2D

var _animation_locked: bool = false
var _facing_locked: bool = false
var _locked_animation: StringName = &""
var _pending_facing_left: bool = false
var _has_pending_facing: bool = false


func _ready() -> void:
	if animated_sprite == null:
		push_error("PlayerAnimationController requires an AnimatedSprite2D at %s" % animated_sprite_path)
		set_process(false)
		return
	animated_sprite.animation_finished.connect(_on_animation_finished)
	if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(&"idle"):
		play_loop(&"idle")


func play_loop(animation_name: StringName, allow_lower_priority: bool = false) -> bool:
	if animation_name not in LOOP_ANIMATIONS or not _can_play(animation_name, allow_lower_priority):
		return false
	return _play_if_changed(animation_name)


func play_one_shot(animation_name: StringName) -> bool:
	if animation_name not in ONE_SHOT_ANIMATIONS or not _can_play(animation_name, false):
		return false
	var changed: bool = _play_if_changed(animation_name)
	if not changed:
		return false
	_animation_locked = true
	_locked_animation = animation_name
	if animation_name in FACING_LOCK_ANIMATIONS:
		_facing_locked = true
	return true


func set_facing_left(facing_left: bool) -> bool:
	if animated_sprite == null:
		return false
	if _facing_locked:
		_pending_facing_left = facing_left
		_has_pending_facing = true
		return false
	if animated_sprite.flip_h == facing_left:
		return true
	animated_sprite.flip_h = facing_left
	facing_changed.emit(facing_left)
	return true


func pause() -> void:
	if animated_sprite != null:
		animated_sprite.pause()


func resume() -> void:
	if animated_sprite != null:
		animated_sprite.play()


func restart_current() -> void:
	if animated_sprite != null and not animated_sprite.animation.is_empty():
		animated_sprite.play(animated_sprite.animation)


func reset_to_idle() -> void:
	_animation_locked = false
	_facing_locked = false
	_locked_animation = &""
	_has_pending_facing = false
	if animated_sprite != null:
		animated_sprite.stop()
		animated_sprite.play(&"idle")
		animation_changed.emit(&"idle")


func is_animation_locked() -> bool:
	return _animation_locked


func is_facing_locked() -> bool:
	return _facing_locked


func is_attack_hit_window() -> bool:
	return animated_sprite != null and animated_sprite.animation == &"attack" and animated_sprite.frame in ATTACK_HIT_FRAMES


func _can_play(animation_name: StringName, allow_lower_priority: bool) -> bool:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return false
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		return false
	if animated_sprite.animation == animation_name and animated_sprite.is_playing():
		return false
	if not _animation_locked:
		if allow_lower_priority or not animated_sprite.is_playing():
			return true
		var current_animation: StringName = animated_sprite.animation
		return PRIORITIES[animation_name] >= PRIORITIES.get(current_animation, 0)
	return PRIORITIES[animation_name] > PRIORITIES[_locked_animation]


func _play_if_changed(animation_name: StringName) -> bool:
	if animated_sprite.animation == animation_name and animated_sprite.is_playing():
		return false
	animated_sprite.play(animation_name)
	animation_changed.emit(animation_name)
	return true


func _on_animation_finished() -> void:
	var finished_animation: StringName = animated_sprite.animation
	if finished_animation not in ONE_SHOT_ANIMATIONS:
		return
	if finished_animation == &"death":
		one_shot_finished.emit(finished_animation)
		return
	_animation_locked = false
	_locked_animation = &""
	if _facing_locked:
		_facing_locked = false
		_apply_pending_facing()
	one_shot_finished.emit(finished_animation)


func _apply_pending_facing() -> void:
	if not _has_pending_facing:
		return
	var requested_facing: bool = _pending_facing_left
	_has_pending_facing = false
	set_facing_left(requested_facing)
