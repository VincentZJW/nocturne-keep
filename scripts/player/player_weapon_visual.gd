class_name PlayerWeaponVisual
extends Node2D

## Equipment-driven overlay for the currently equipped twin blades.
## The original Veilbound blades remain in the authored frames. Ravenfang adds a
## crisp black-steel silhouette that follows locomotion and attack poses.

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


func _ready() -> void:
	if animated_sprite == null or animation_controller == null:
		push_error("PlayerWeaponVisual requires Player animation composition")
		return
	animated_sprite.frame_changed.connect(queue_redraw)
	animated_sprite.animation_changed.connect(queue_redraw)
	animation_controller.facing_changed.connect(_on_facing_changed)
	var equipment: PlayerEquipmentManager = _equipment()
	if equipment != null:
		equipment.weapon_equipped.connect(_on_weapon_equipped)
		_on_weapon_equipped(equipment.get_equipped_weapon())


func _exit_tree() -> void:
	var equipment: PlayerEquipmentManager = _equipment()
	if equipment != null and equipment.weapon_equipped.is_connected(_on_weapon_equipped):
		equipment.weapon_equipped.disconnect(_on_weapon_equipped)


func _draw() -> void:
	if animated_sprite == null or _visual_id != &"ravenfang":
		return
	var animation: StringName = animated_sprite.animation
	if animation == &"death" or animation == &"hurt":
		return
	var direction: float = -1.0 if animated_sprite.flip_h else 1.0
	var pose: Dictionary = _get_pose(animation, animated_sprite.frame)
	_draw_blade(pose.get("main", Vector2(11.0, -2.0)), int(pose.get("main_len", 12)), direction, false)
	_draw_blade(pose.get("off", Vector2(-8.0, 2.0)), int(pose.get("off_len", 9)), direction, true)


func _draw_blade(origin: Vector2, length: int, direction: float, upper: bool) -> void:
	var start: Vector2 = Vector2(origin.x * direction, origin.y)
	var step_y: float = -0.18 if upper else 0.18
	var steel: Color = Color("6f8194")
	var edge: Color = Color("eef5f6")
	var rune: Color = Color("8c3f46")
	for index: int in range(length):
		var point: Vector2 = start + Vector2(float(index) * direction, roundf(float(index) * step_y))
		draw_rect(Rect2(point.floor(), Vector2(1.0, 2.0)), steel)
	var tip: Vector2 = start + Vector2(float(length) * direction, roundf(float(length) * step_y))
	draw_rect(Rect2(tip.floor(), Vector2(1.0, 1.0)), edge)
	draw_rect(Rect2((start + Vector2(3.0 * direction, 0.0)).floor(), Vector2(1.0, 1.0)), rune)
	draw_rect(Rect2((start - Vector2(2.0 * direction, 0.0)).floor(), Vector2(3.0, 2.0)), Color("172b3d"))


func _get_pose(animation: StringName, frame: int) -> Dictionary:
	if animation == &"attack" or animation == &"dash_attack":
		if frame >= 1 and frame <= 3:
			return {"main": Vector2(7, -8), "off": Vector2(6, -4), "main_len": 18, "off_len": 15}
		return {"main": Vector2(8, -5), "off": Vector2(3, 1), "main_len": 13, "off_len": 10}
	if animation.begins_with("dash") or animation.begins_with("air_dash"):
		return {"main": Vector2(8, -5), "off": Vector2(-8, 2), "main_len": 13, "off_len": 10}
	if animation == &"jump_start" or animation == &"jump_loop" or animation == &"fall":
		return {"main": Vector2(10, -2), "off": Vector2(-7, 1), "main_len": 12, "off_len": 9}
	if animation == &"run":
		var run_offset: float = -2.0 if frame % 2 == 0 else 1.0
		return {"main": Vector2(10, -3 + run_offset), "off": Vector2(-8, 2 - run_offset), "main_len": 12, "off_len": 9}
	return {"main": Vector2(10, -3), "off": Vector2(-8, 2), "main_len": 12, "off_len": 9}


func _on_weapon_equipped(weapon: WeaponData) -> void:
	_visual_id = weapon.player_visual_id if weapon != null else &"veilbound"
	queue_redraw()


func _on_facing_changed(_facing_left: bool) -> void:
	queue_redraw()


func get_visual_id() -> StringName:
	return _visual_id


func _equipment() -> PlayerEquipmentManager:
	return get_node_or_null("/root/EquipmentManager") as PlayerEquipmentManager
