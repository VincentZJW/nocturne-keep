class_name PlayerAnimationPreview
extends Control

## Internal shared Player animation inspector. It is not the formal game Main scene.

const SpriteFramesBuilder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")

const ANIMATION_KEYS: Dictionary[Key, StringName] = {
	KEY_1: &"idle", KEY_2: &"run", KEY_3: &"jump_start", KEY_4: &"jump_loop",
	KEY_5: &"fall", KEY_6: &"land", KEY_7: &"dash_start", KEY_8: &"dash_loop",
	KEY_9: &"dash_end", KEY_0: &"air_dash_start", KEY_MINUS: &"air_dash_loop",
	KEY_EQUAL: &"air_dash_end", KEY_BRACKETLEFT: &"attack", KEY_BRACKETRIGHT: &"dash_attack",
	KEY_SEMICOLON: &"hurt", KEY_APOSTROPHE: &"death",
}

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var animation_controller: PlayerAnimationController = %AnimationController
@onready var animation_name_label: Label = %AnimationNameValue
@onready var frame_label: Label = %FrameValue
@onready var fps_label: Label = %FpsValue
@onready var loop_label: Label = %LoopValue
@onready var direction_label: Label = %DirectionValue
@onready var lock_label: Label = %LockValue
@onready var event_label: Label = %EventValue


func _ready() -> void:
	_connect_animation_buttons()
	%PlayButton.pressed.connect(animation_controller.resume)
	%PauseButton.pressed.connect(animation_controller.pause)
	%RestartButton.pressed.connect(animation_controller.restart_current)
	%FaceLeftButton.pressed.connect(animation_controller.set_facing_left.bind(true))
	%FaceRightButton.pressed.connect(animation_controller.set_facing_left.bind(false))
	animation_controller.one_shot_finished.connect(_on_one_shot_finished)
	animation_controller.animation_changed.connect(_on_animation_changed)
	animation_controller.facing_changed.connect(_on_facing_changed)
	event_label.text = "Ready · choose an animation"


func _process(_delta: float) -> void:
	var animation_name: StringName = animated_sprite.animation
	var sprite_frames: SpriteFrames = animated_sprite.sprite_frames
	if sprite_frames == null or not sprite_frames.has_animation(animation_name):
		return
	var is_placeholder: bool = SpriteFramesBuilder.is_placeholder(animation_name)
	animation_name_label.text = "%s%s" % [
		str(animation_name), " · PLACEHOLDER" if is_placeholder else " · PRODUCTION",
	]
	frame_label.text = "%d / %d%s" % [
		animated_sprite.frame + 1,
		sprite_frames.get_frame_count(animation_name),
		(
			" · HIT WINDOW"
			if animation_controller.is_attack_hit_window() or animation_controller.is_dash_attack_hit_window()
			else ""
		),
	]
	fps_label.text = "%.1f FPS" % sprite_frames.get_animation_speed(animation_name)
	loop_label.text = "LOOP" if sprite_frames.get_animation_loop(animation_name) else "ONE-SHOT"
	direction_label.text = "LEFT · flip_h=true" if animated_sprite.flip_h else "RIGHT · flip_h=false"
	lock_label.text = "animation=%s · facing=%s" % [
		"LOCKED" if animation_controller.is_animation_locked() else "free",
		"LOCKED" if animation_controller.is_facing_locked() else "free",
	]


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if ANIMATION_KEYS.has(event.physical_keycode):
		_play_selected(ANIMATION_KEYS[event.physical_keycode])


func _connect_animation_buttons() -> void:
	var button_animations: Dictionary[Button, StringName] = {
		%IdleButton: &"idle", %RunButton: &"run", %JumpStartButton: &"jump_start",
		%JumpLoopButton: &"jump_loop", %FallButton: &"fall", %LandButton: &"land",
		%DashStartButton: &"dash_start", %DashLoopButton: &"dash_loop",
		%DashEndButton: &"dash_end", %AirDashStartButton: &"air_dash_start",
		%AirDashLoopButton: &"air_dash_loop", %AirDashEndButton: &"air_dash_end",
		%AttackButton: &"attack", %DashAttackButton: &"dash_attack",
		%HurtButton: &"hurt", %DeathButton: &"death",
	}
	var connected_animations: Array[StringName] = []
	for button: Button in button_animations:
		var animation_name: StringName = button_animations[button]
		button.pressed.connect(_play_selected.bind(animation_name))
		connected_animations.append(animation_name)
	var grid: GridContainer = %AnimationButtons
	for animation_name: StringName in SpriteFramesBuilder.ANIMATION_ORDER:
		if animation_name in connected_animations:
			continue
		var button: Button = Button.new()
		button.text = str(animation_name)
		button.custom_minimum_size = Vector2(136.0, 34.0)
		button.pressed.connect(_play_selected.bind(animation_name))
		grid.add_child(button)


func _play_selected(animation_name: StringName) -> void:
	animation_controller.reset_to_idle()
	if animation_name == &"idle":
		return
	if animation_name in PlayerAnimationController.LOOP_ANIMATIONS:
		animation_controller.play_loop(animation_name)
	else:
		animation_controller.play_one_shot(animation_name)


func _on_one_shot_finished(animation_name: StringName) -> void:
	event_label.text = "one_shot_finished(%s)" % animation_name


func _on_animation_changed(animation_name: StringName) -> void:
	event_label.text = "animation_changed(%s)" % animation_name


func _on_facing_changed(facing_left: bool) -> void:
	event_label.text = "facing_changed(%s)" % ("left" if facing_left else "right")
