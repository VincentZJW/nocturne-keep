extends SceneTree

## Deterministic original pixel source for Seraphine's genuinely redrawn Unmasked form.

const ROOT: String = "res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/phase_02_unmasked"
const CLEAR: Color = Color(0, 0, 0, 0)
const OUTLINE: Color = Color("0b0710")
const VOID: Color = Color("120812")
const DRESS: Color = Color("28101d")
const CRIMSON: Color = Color("6f1f32")
const BLOOD: Color = Color("9b3046")
const BONE: Color = Color("c7bcc0")
const STEEL: Color = Color("d5dce1")
const EYE: Color = Color("e05a62")
const MIST: Color = Color("6b2949")

const ANIMATIONS: Dictionary = {
	"idle": 4, "intro": 6, "elegant_walk": 6, "turn": 4,
	"sidestep": 4, "backstep": 4,
	"rapier_thrust_windup": 4, "rapier_thrust_active": 2,
	"rapier_thrust_recovery": 4, "fan_slash_windup": 4,
	"fan_slash_active": 2, "fan_slash_recovery": 5, "riposte": 8,
	"phase_transition": 8, "double_lunge": 8, "phantom_dance": 6,
	"final_waltz": 8, "light_hit": 2, "stagger": 4, "death": 7,
}


func _initialize() -> void:
	for animation_name: String in ANIMATIONS:
		var count: int = int(ANIMATIONS[animation_name])
		var directory: String = "%s/%s" % [ROOT, animation_name]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		for frame_index: int in range(count):
			var image: Image = _draw_frame(animation_name, frame_index, count)
			var output: String = "%s/%s_%02d.png" % [directory, animation_name, frame_index + 1]
			var error: Error = image.save_png(ProjectSettings.globalize_path(output))
			if error != OK:
				push_error("Phase 2 asset save failed: %s" % output)
				quit(1)
				return
	_generate_transition_stages()
	print("HOLLOW_DUCHESS_PHASE_2_ASSETS: PASS animations=%d" % ANIMATIONS.size())
	quit(0)


func _generate_transition_stages() -> void:
	var directory: String = "res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/phase_transition"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var sources: Array[String] = [
		"res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/sprites/phase_transition/phase_transition_03.png",
		"res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/sprites/phase_transition/phase_transition_06.png",
		ROOT + "/phase_transition/phase_transition_03.png",
		ROOT + "/phase_transition/phase_transition_06.png",
		ROOT + "/phase_transition/phase_transition_08.png",
	]
	var names: Array[String] = ["mask_crack", "mask_break", "body_distort", "dress_tear", "phase_2_reveal"]
	for index: int in range(names.size()):
		var source: Image = Image.load_from_file(ProjectSettings.globalize_path(sources[index]))
		if source == null or source.is_empty():
			push_error("Missing transition source: %s" % sources[index])
			quit(1)
			return
		source.save_png(ProjectSettings.globalize_path("%s/%s.png" % [directory, names[index]]))


func _draw_frame(animation: String, frame: int, count: int) -> Image:
	if animation == "death":
		return _draw_death(frame)
	var image: Image = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var ratio: float = float(frame) / float(maxi(1, count - 1))
	var x: int = 42
	var y: int = 10
	var lean: int = 0
	var crouch: int = 0
	var sway: int = 0
	match animation:
		"idle":
			y += [0, -1, 0, 1][frame]
			sway = [-2, 0, 2, 0][frame]
		"elegant_walk":
			x += [0, 2, 3, 1, -1, -2][frame]
			y += [0, -1, 1, 0, -1, 1][frame]
			sway = [-4, -2, 1, 4, 2, -1][frame]
		"sidestep":
			lean = [0, 3, 6, 3][frame]
			crouch = 3
		"backstep":
			lean = [0, -3, -7, -4][frame]
			crouch = 3
		"turn":
			lean = [0, -2, 2, 0][frame]
		"stagger":
			lean = [-5, -8, -5, -2][frame]
			crouch = [2, 5, 4, 2][frame]
		"light_hit":
			lean = -4 if frame == 0 else -1
		"phase_transition":
			crouch = 4 - mini(frame, 4)
			sway = (frame % 3) - 1
		_:
			if animation.begins_with("rapier_thrust"):
				lean = -frame if animation.ends_with("windup") else 7 if animation.ends_with("active") else 4 - frame
				crouch = 3 if not animation.ends_with("recovery") else 1
			elif animation.begins_with("fan_slash"):
				lean = -2 + frame if animation.ends_with("windup") else 4
				crouch = 2
			elif animation == "riposte":
				lean = -6 if frame < 3 else mini(8, frame)
				crouch = 3
			elif animation == "double_lunge":
				lean = [0, -3, 6, 9, 1, -2, 7, 10][frame]
				crouch = 3 if frame >= 2 else 1
			elif animation in ["phantom_dance", "final_waltz"]:
				lean = [-3, 0, 4, 7, 2, -2, 5, 8][frame % 8]
				sway = (frame % 4) - 2
	_draw_unmasked(image, x + lean, y + crouch, sway, animation, frame, ratio)
	return image


func _draw_unmasked(
	image: Image, x: int, y: int, sway: int, animation: String, frame: int, ratio: float
) -> void:
	# Hollow elongated face, red pin eyes and broken porcelain crown fragments.
	_rect(image, x - 10, y + 3, 22, 20, OUTLINE)
	_rect(image, x - 7, y + 5, 16, 18, VOID)
	_rect(image, x - 4, y + 10, 2, 2, EYE)
	_rect(image, x + 4, y + 10, 2, 2, EYE)
	_rect(image, x - 2, y + 17, 8, 2, CRIMSON)
	_rect(image, x - 12, y, 6, 5, BONE)
	_rect(image, x + 9, y + 2, 7, 4, BONE)
	_rect(image, x - 15, y + 8, 4, 3, BONE)
	# Spine-fan silhouette is new to Phase 2 and remains behind the narrow body.
	for rib: int in range(5):
		var rib_y: int = y + 24 + rib * 5
		var reach: int = 17 + rib * 3
		_draw_line(image, Vector2i(x, rib_y), Vector2i(x - reach, rib_y - 8), CRIMSON, 2)
		_draw_line(image, Vector2i(x + 2, rib_y), Vector2i(x + reach, rib_y - 6), MIST, 2)
	# Torn bodice, exposed pale ribs and elongated arms.
	_rect(image, x - 10, y + 22, 22, 25, OUTLINE)
	_rect(image, x - 7, y + 24, 16, 21, DRESS)
	for rib_y: int in [28, 33, 38]:
		_draw_line(image, Vector2i(x - 4, y + rib_y - 22), Vector2i(x + 6, y + rib_y - 22), BONE, 1)
	_rect(image, x - 14, y + 25, 5, 23, VOID)
	_rect(image, x + 10, y + 24, 5, 24, VOID)
	# Asymmetric torn dress exposes black soul limbs and pale shin bone.
	_rect(image, x - 13 + sway, y + 45, 28, 15, OUTLINE)
	_rect(image, x - 10 + sway, y + 46, 22, 13, CRIMSON)
	_rect(image, x - 18 + sway, y + 58, 38, 8, OUTLINE)
	_rect(image, x - 14 + sway, y + 59, 13, 5, DRESS)
	_rect(image, x + 4 + sway, y + 59, 12, 5, DRESS)
	_rect(image, x - 7, y + 64, 4, 10, VOID)
	_rect(image, x + 6, y + 63, 4, 11, BONE)
	_rect(image, x - 19 + sway, y + 69, 5, 2, MIST)
	_rect(image, x + 16 + sway, y + 67, 5, 2, BLOOD)
	# Bone-stiletto and shattered-mask fan keep separate, readable attack silhouettes.
	var hand: Vector2i = Vector2i(x + 10, y + 30)
	var tip: Vector2i = Vector2i(x + 39, y + 25)
	if animation.begins_with("rapier_thrust") or animation in ["riposte", "double_lunge"]:
		var extension: int = 54 if animation.ends_with("active") or frame >= 3 else 35
		tip = Vector2i(x + extension, y + 24)
	_draw_line(image, hand, tip, BONE, 2)
	_draw_line(image, tip, Vector2i(tip.x + 4, tip.y), STEEL, 1)
	var fan_hand: Vector2i = Vector2i(x - 11, y + 31)
	if animation.begins_with("fan_slash"):
		var sweep: int = 14 + frame * 9
		_draw_line(image, fan_hand, Vector2i(x + sweep, y + 14 + frame * 8), BONE, 3)
		_draw_line(image, fan_hand, Vector2i(x + sweep + 5, y + 22 + frame * 6), STEEL, 2)
	else:
		_draw_line(image, fan_hand, Vector2i(x - 21, y + 20), BONE, 2)
		_draw_line(image, fan_hand, Vector2i(x - 19, y + 33), BLOOD, 2)
	if animation == "phase_transition":
		for shard: int in range(1 + frame):
			_rect(image, 22 + shard * 7, 17 + (shard % 3) * 9, 2, 2, BONE)
	if animation in ["phantom_dance", "final_waltz"]:
		for mist: int in range(4):
			_rect(image, x - 24 + mist * 15, y + 73 - (mist % 2) * 4, 4, 2, Color(0.55, 0.12, 0.24, 0.65 + ratio * 0.2))


func _draw_death(frame: int) -> Image:
	var image: Image = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var fade: float = 1.0 - float(frame) / 7.0
	_rect(image, 19 + frame * 2, 56 + frame * 2, 58 - frame * 3, maxi(4, 20 - frame * 2), Color(0.45, 0.10, 0.20, fade))
	for shard: int in range(3 + frame * 2):
		_rect(image, 18 + (shard * 11) % 66, 72 - (shard % 5) * 8, 2, 2, Color(BONE, fade))
	return image


func _draw_line(image: Image, start: Vector2i, finish: Vector2i, color: Color, thickness: int) -> void:
	var steps: int = maxi(abs(finish.x - start.x), abs(finish.y - start.y))
	for index: int in range(steps + 1):
		var ratio: float = float(index) / float(maxi(1, steps))
		var point := Vector2i(roundi(lerpf(start.x, finish.x, ratio)), roundi(lerpf(start.y, finish.y, ratio)))
		_rect(image, point.x, point.y, thickness, thickness, color)


func _rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	var clipped := Rect2i(x, y, width, height).intersection(Rect2i(0, 0, image.get_width(), image.get_height()))
	if clipped.size.x > 0 and clipped.size.y > 0:
		image.fill_rect(clipped, color)
