class_name Chapter03UnderkeepDescent
extends Node2D

## Formal Chapter III terminal: drowned chapel drainage becomes the Chapter IV threshold.
## Water reactions are presentation-only; player velocity and movement tuning remain untouched.

signal chapter_four_transition_requested(player: Player)

const CHAPTER_FOUR_SCENE: String = (
	"res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
)
const WATERLINE_Y: float = 612.0
const STEP_INTERVAL: float = 0.24
const MAX_TRANSIENT_EFFECTS: int = 10
const RIPPLE_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/"
	+ "water_transition/water/ripples/ripple_%02d.png"
)
const STEP_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/"
	+ "water_transition/water/splashes/step_%02d.png"
)
const DASH_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/"
	+ "water_transition/water/splashes/dash_%02d.png"
)
const LANDING_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/"
	+ "water_transition/water/splashes/landing_%02d.png"
)

@onready var exit_area: Area2D = $ChapterFourExitArea as Area2D
@onready var water_interaction_area: Area2D = $WaterInteractionArea as Area2D
@onready var prompt: Label = $TransitionPrompt as Label
@onready var effects_root: Node2D = $TransientWaterEffects as Node2D

var _player_in_exit_range: Player = null
var _player_in_water: Player = null
var _step_elapsed: float = 0.0
var _step_frames: Array[Texture2D] = []
var _dash_frames: Array[Texture2D] = []
var _landing_frames: Array[Texture2D] = []
var _ripple_frames: Array[Texture2D] = []


func _ready() -> void:
	_step_frames = _load_frames(STEP_PATH, 5)
	_dash_frames = _load_frames(DASH_PATH, 5)
	_landing_frames = _load_frames(LANDING_PATH, 5)
	_ripple_frames = _load_frames(RIPPLE_PATH, 5)
	exit_area.body_entered.connect(_on_exit_body_entered)
	exit_area.body_exited.connect(_on_exit_body_exited)
	water_interaction_area.body_entered.connect(_on_water_body_entered)
	water_interaction_area.body_exited.connect(_on_water_body_exited)
	prompt.visible = false
	set_process(true)


func _process(delta: float) -> void:
	if _player_in_water == null or not is_instance_valid(_player_in_water):
		return
	if not _player_in_water.is_on_floor() or absf(_player_in_water.velocity.x) < 35.0:
		_step_elapsed = STEP_INTERVAL
		return
	_step_elapsed += delta
	if _step_elapsed < STEP_INTERVAL:
		return
	_step_elapsed = 0.0
	_spawn_effect(_step_frames, _player_in_water.global_position.x, 18.0)


func _unhandled_input(event: InputEvent) -> void:
	if (
		not event.is_action_pressed(&"interact")
		or _player_in_exit_range == null
		or not _player_in_exit_range.can_process_gameplay_interaction()
	):
		return
	if not ResourceLoader.exists(CHAPTER_FOUR_SCENE, "PackedScene"):
		prompt.text = "CHAPTER IV THRESHOLD IS UNAVAILABLE / 第四章入口不可用"
		get_viewport().set_input_as_handled()
		return
	chapter_four_transition_requested.emit(_player_in_exit_range)
	get_viewport().set_input_as_handled()


func _on_exit_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null:
		return
	_player_in_exit_range = player
	prompt.text = "E · DESCEND TO THE DROWNED UNDERKEEP / 下行至沉没下堡"
	prompt.visible = true


func _on_exit_body_exited(body: Node2D) -> void:
	if body == _player_in_exit_range:
		_player_in_exit_range = null
		prompt.visible = false


func _on_water_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null:
		return
	_player_in_water = player
	_step_elapsed = STEP_INTERVAL
	_connect_player_presentation_signals(player)
	_spawn_effect(_ripple_frames, player.global_position.x, 15.0)


func _on_water_body_exited(body: Node2D) -> void:
	if body == _player_in_water:
		_player_in_water = null


func _connect_player_presentation_signals(player: Player) -> void:
	if not player.jump_performed.is_connected(_on_player_jump_performed):
		player.jump_performed.connect(_on_player_jump_performed)
	if not player.double_jump_performed.is_connected(_on_player_double_jump_performed):
		player.double_jump_performed.connect(_on_player_double_jump_performed)
	if not player.landed.is_connected(_on_player_landed):
		player.landed.connect(_on_player_landed)
	if (
		player.animation_controller != null
		and not player.animation_controller.animation_changed.is_connected(_on_player_animation_changed)
	):
		player.animation_controller.animation_changed.connect(_on_player_animation_changed)


func _on_player_jump_performed(_from_coyote_time: bool) -> void:
	if _player_in_water != null:
		_spawn_effect(_landing_frames, _player_in_water.global_position.x, 21.0)


func _on_player_double_jump_performed(_remaining: int) -> void:
	if _player_in_water != null:
		_spawn_effect(_step_frames, _player_in_water.global_position.x, 19.0)


func _on_player_landed() -> void:
	if _player_in_water != null:
		_spawn_effect(_landing_frames, _player_in_water.global_position.x, 22.0)


func _on_player_animation_changed(animation_name: StringName) -> void:
	if _player_in_water == null:
		return
	if animation_name in [&"dash_start", &"dash_loop", &"air_dash_start", &"dash_attack"]:
		_spawn_effect(_dash_frames, _player_in_water.global_position.x, 23.0)


func _spawn_effect(frames: Array[Texture2D], world_x: float, effect_z: float) -> void:
	if frames.is_empty() or effects_root.get_child_count() >= MAX_TRANSIENT_EFFECTS:
		return
	var effect := UnderkeepWaterEffect.new()
	effect.name = "WaterReaction"
	effect.frames = frames
	effect.frames_per_second = 20.0
	effect.z_index = int(effect_z)
	effects_root.add_child(effect)
	effect.global_position = Vector2(roundf(world_x), WATERLINE_Y - 3.0)


func _load_frames(pattern: String, count: int) -> Array[Texture2D]:
	var result: Array[Texture2D] = []
	for index: int in range(1, count + 1):
		var texture: Texture2D = load(pattern % index) as Texture2D
		if texture != null:
			result.append(texture)
	return result
