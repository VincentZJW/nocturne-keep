class_name PlayerAnimationPreview
extends Control

## Internal animation viewer. It never changes the formal project Main scene.

const Generator: Script = preload("res://scripts/tools/pixel_player_animation_generator.gd")
const ContactSheet: Script = preload("res://scripts/tools/player_animation_contact_sheet.gd")

const PLAYBACK_SPEEDS: Dictionary[String, float] = {
	"idle": 6.0, "run": 10.0, "dash": 12.0, "attack": 10.0,
}

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite
@onready var status_label: Label = %Status
@onready var idle_button: Button = %IdleButton
@onready var run_button: Button = %RunButton
@onready var dash_button: Button = %DashButton
@onready var attack_button: Button = %AttackButton


func _ready() -> void:
	idle_button.pressed.connect(_play_animation.bind("idle"))
	run_button.pressed.connect(_play_animation.bind("run"))
	dash_button.pressed.connect(_play_animation.bind("dash"))
	attack_button.pressed.connect(_play_animation.bind("attack"))
	animated_sprite.animation_finished.connect(_on_animation_finished)
	var sequences: Dictionary[String, Array] = Generator.generate_all()
	var save_results: Dictionary[String, int] = Generator.save_all(sequences)
	var reference_results: Dictionary[String, int] = Generator.archive_references()
	var contact_sheet_error: Error = ContactSheet.export(sequences)
	_build_sprite_frames(sequences)
	var failures: PackedStringArray = _collect_failures(save_results, reference_results)
	if contact_sheet_error != OK:
		failures.append(ContactSheet.OUTPUT_PATH)
	if failures.is_empty():
		status_label.text = "IDLE · 4 frames · 64×64 · nearest-neighbor"
	else:
		status_label.text = "Export failed: %s" % ", ".join(failures)
	_play_animation("idle")
	if OS.get_cmdline_user_args().has("--generate-only"):
		print("PLAYER_ANIMATION_EXPORT: %d frames + 4 references" % save_results.size())
		get_tree().quit(0 if failures.is_empty() else 1)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	match event.physical_keycode:
		KEY_1:
			_play_animation("idle")
		KEY_2:
			_play_animation("run")
		KEY_3:
			_play_animation("dash")
		KEY_4:
			_play_animation("attack")


func _build_sprite_frames(sequences: Dictionary[String, Array]) -> void:
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	sprite_frames.remove_animation(&"default")
	for animation_name: String in Generator.ANIMATION_ORDER:
		var name_key: StringName = StringName(animation_name)
		sprite_frames.add_animation(name_key)
		sprite_frames.set_animation_speed(name_key, PLAYBACK_SPEEDS[animation_name])
		sprite_frames.set_animation_loop(name_key, animation_name in ["idle", "run"])
		var frames: Array = sequences[animation_name]
		for frame_variant: Variant in frames:
			var frame: Image = frame_variant as Image
			var texture: ImageTexture = ImageTexture.create_from_image(frame)
			sprite_frames.add_frame(name_key, texture)
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _play_animation(animation_name: String) -> void:
	animated_sprite.play(StringName(animation_name))
	status_label.text = "%s · %d frames · %s FPS · keys 1–4" % [
		animation_name.to_upper(), Generator.FRAME_COUNTS[animation_name], PLAYBACK_SPEEDS[animation_name],
	]


func _on_animation_finished() -> void:
	var current: StringName = animated_sprite.animation
	if current in [&"dash", &"attack"]:
		animated_sprite.play(current)


func _collect_failures(
		save_results: Dictionary[String, int],
		reference_results: Dictionary[String, int]
	) -> PackedStringArray:
	var failures: PackedStringArray = []
	for path: String in save_results:
		if save_results[path] != OK:
			failures.append(path)
	for path: String in reference_results:
		if reference_results[path] != OK:
			failures.append(path)
	return failures
