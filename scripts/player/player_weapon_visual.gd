class_name PlayerWeaponVisual
extends Node2D

## Equipment-driven SpriteFrames authority. Equipped Ravenfang frames replace
## the baked Veilbound frames atomically, so old and new blade silhouettes never mix.

const RAVENFANG_FRAMES_PATH: String = "res://resources/player/ravenfang_player_sprite_frames.tres"

@export_node_path("AnimatedSprite2D") var animated_sprite_path: NodePath = NodePath("../AnimatedSprite2D")
@export_node_path("PlayerAnimationController") var animation_controller_path: NodePath = NodePath(
	"../../AnimationController"
)

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(
	animated_sprite_path
) as AnimatedSprite2D
@onready var animation_controller: PlayerAnimationController = get_node_or_null(
	animation_controller_path
) as PlayerAnimationController

var _visual_id: StringName = &"veilbound"
var _veilbound_frames: SpriteFrames
var _ravenfang_frames: SpriteFrames


func _ready() -> void:
	if animated_sprite == null or animation_controller == null:
		push_error("PlayerWeaponVisual requires Player animation composition")
		return
	_veilbound_frames = animated_sprite.sprite_frames
	_ravenfang_frames = load(RAVENFANG_FRAMES_PATH) as SpriteFrames
	if _ravenfang_frames == null:
		push_error("PlayerWeaponVisual missing Ravenfang SpriteFrames: %s" % RAVENFANG_FRAMES_PATH)
	var equipment: PlayerEquipmentManager = _equipment()
	if equipment != null:
		equipment.weapon_equipped.connect(_on_weapon_equipped)
		_on_weapon_equipped(equipment.get_equipped_weapon())


func _exit_tree() -> void:
	var equipment: PlayerEquipmentManager = _equipment()
	if equipment != null and equipment.weapon_equipped.is_connected(_on_weapon_equipped):
		equipment.weapon_equipped.disconnect(_on_weapon_equipped)


func _on_weapon_equipped(weapon: WeaponData) -> void:
	_visual_id = weapon.player_visual_id if weapon != null else &"veilbound"
	var selected_frames: SpriteFrames = _ravenfang_frames if _visual_id == &"ravenfang" else _veilbound_frames
	if selected_frames == null or selected_frames == animated_sprite.sprite_frames:
		return
	_swap_sprite_frames(selected_frames)


func _swap_sprite_frames(selected_frames: SpriteFrames) -> void:
	var previous_animation: StringName = animated_sprite.animation
	var previous_frame: int = animated_sprite.frame
	var previous_progress: float = animated_sprite.frame_progress
	var was_playing: bool = animated_sprite.is_playing()
	animated_sprite.sprite_frames = selected_frames
	if not selected_frames.has_animation(previous_animation):
		previous_animation = &"idle"
		previous_frame = 0
		previous_progress = 0.0
	if was_playing:
		animated_sprite.play(previous_animation)
	else:
		animated_sprite.animation = previous_animation
	animated_sprite.set_frame_and_progress(
		mini(previous_frame, selected_frames.get_frame_count(previous_animation) - 1),
		clampf(previous_progress, 0.0, 1.0)
	)


func get_visual_id() -> StringName:
	return _visual_id


func get_active_sprite_frames_path() -> String:
	return RAVENFANG_FRAMES_PATH if _visual_id == &"ravenfang" else PlayerSpriteFramesBuilder.RESOURCE_PATH


func _equipment() -> PlayerEquipmentManager:
	return get_node_or_null("/root/EquipmentManager") as PlayerEquipmentManager
