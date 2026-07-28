class_name RevivalPlayerArt
extends Node2D

## Story-only revival presentation using the same authored 64×64 body model as
## the formal gameplay Player. The controller keeps ownership of pose timing.

enum Pose {
	CORPSE,
	TWITCH,
	BREATH,
	SIT_UP,
	LOOK_HANDS,
	KNEEL,
	STAND,
	UNARMED,
}

const CORPSE_TEXTURE: Texture2D = preload(
	"res://shared/assets/player/revival/revival_corpse.png"
)
const TWITCH_TEXTURE: Texture2D = preload(
	"res://shared/assets/player/revival/revival_twitch.png"
)
const BREATH_TEXTURE: Texture2D = preload(
	"res://shared/assets/player/revival/revival_breath.png"
)
const SIT_UP_TEXTURE: Texture2D = preload(
	"res://shared/assets/player/revival/revival_sit_up.png"
)
const LOOK_HANDS_TEXTURE: Texture2D = preload(
	"res://shared/assets/player/revival/revival_look_hands.png"
)
const KNEEL_TEXTURE: Texture2D = preload(
	"res://shared/assets/player/revival/revival_kneel.png"
)
const STAND_TEXTURE: Texture2D = preload(
	"res://shared/assets/player/revival/revival_stand.png"
)
const UNARMED_TEXTURE: Texture2D = preload(
	"res://shared/assets/player/revival/revival_unarmed.png"
)
const GHOST_TEXTURE: Texture2D = preload(
	"res://shared/assets/player/effects/night_warden_ghost_hooded_face.png"
)

const STEEL: Color = Color("d5dee3")

var pose: Pose = Pose.CORPSE
var soul_visible: bool = false
var soul_offset: Vector2 = Vector2(0, -112)
var soul_alpha: float = 0.0
var soul_mark_strength: float = 0.0


func set_pose(next_pose: Pose) -> void:
	pose = next_pose
	if pose == Pose.UNARMED:
		position.y = 28.0
	elif pose in [Pose.KNEEL, Pose.STAND]:
		position.y = 14.0
	else:
		position.y = 0.0
	queue_redraw()


func _process(_delta: float) -> void:
	if pose == Pose.UNARMED:
		var player: Player = get_parent() as Player
		position.y = (
			27.0
			if player != null and absf(player.velocity.x) > 5.0 and Time.get_ticks_msec() % 240 < 120
			else 28.0
		)
	queue_redraw()


func _draw() -> void:
	var texture: Texture2D = _get_pose_texture()
	var draw_origin: Vector2 = Vector2(-32.0, -60.0)
	if pose == Pose.BREATH:
		draw_origin.y -= 1.0
	draw_texture(texture, draw_origin)
	if soul_mark_strength > 0.0:
		draw_circle(Vector2(0, -10), 5, STEEL * Color(1, 1, 1, soul_mark_strength))
		draw_arc(
			Vector2(0, -10), 9, 0.2, 5.5, 12,
			Color(0.52, 0.78, 0.92, soul_mark_strength), 2.0
		)
	if soul_visible:
		_draw_soul()


func _get_pose_texture() -> Texture2D:
	match pose:
		Pose.CORPSE:
			return CORPSE_TEXTURE
		Pose.TWITCH:
			return TWITCH_TEXTURE
		Pose.BREATH:
			return BREATH_TEXTURE
		Pose.SIT_UP:
			return SIT_UP_TEXTURE
		Pose.LOOK_HANDS:
			return LOOK_HANDS_TEXTURE
		Pose.KNEEL:
			return KNEEL_TEXTURE
		Pose.STAND:
			return STAND_TEXTURE
		_:
			return UNARMED_TEXTURE


func _draw_soul() -> void:
	var ghost_modulate: Color = Color(0.82, 0.94, 1.0, soul_alpha)
	draw_texture(GHOST_TEXTURE, soul_offset - Vector2(32.0, 32.0), ghost_modulate)
