extends SceneTree

## Deterministic original pixel-art source generator for The Hollow Duchess.

const ROOT: String = "res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess"
const CLEAR: Color = Color(0, 0, 0, 0)
const OUTLINE: Color = Color("100c15")
const BLACK: Color = Color("18131e")
const DRESS: Color = Color("2a1722")
const OXBLOOD: Color = Color("5d2234")
const RED: Color = Color("8a344b")
const MASK: Color = Color("ddd8d4")
const MASK_SHADOW: Color = Color("aaa3aa")
const STEEL: Color = Color("cbd4db")
const GLOW: Color = Color("a9c7d8")
const SOUL: Color = Color("796b91")

const ANIMATIONS: Dictionary = {
	"idle": 4,
	"intro": 6,
	"elegant_walk": 6,
	"turn": 4,
	"sidestep": 4,
	"backstep": 4,
	"rapier_thrust_windup": 4,
	"rapier_thrust_active": 2,
	"rapier_thrust_recovery": 4,
	"fan_slash_windup": 4,
	"fan_slash_active": 2,
	"fan_slash_recovery": 5,
	"riposte": 8,
	"phase_transition": 8,
	"double_lunge": 8,
	"phantom_dance": 6,
	"final_waltz": 8,
	"light_hit": 2,
	"stagger": 4,
	"death": 7,
}


func _initialize() -> void:
	for animation_name: String in ANIMATIONS:
		var frame_count: int = int(ANIMATIONS[animation_name])
		var directory: String = "%s/sprites/%s" % [ROOT, animation_name]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		for frame_index: int in range(frame_count):
			var image: Image = _draw_frame(animation_name, frame_index, frame_count)
			var output: String = "%s/%s_%02d.png" % [directory, animation_name, frame_index + 1]
			var error: Error = image.save_png(ProjectSettings.globalize_path(output))
			if error != OK:
				push_error("Failed to save %s: %s" % [output, error_string(error)])
				quit(1)
				return
	_generate_effects()
	print("HOLLOW_DUCHESS_ASSET_GENERATOR: PASS animations=%d" % ANIMATIONS.size())
	quit(0)


func _draw_frame(animation: String, frame: int, frame_count: int) -> Image:
	var image: Image = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var phase: float = float(frame) / float(maxi(1, frame_count - 1))
	var x: int = 42
	var y: int = 12
	var bob: int = 0
	var lean: int = 0
	var crouch: int = 0
	var skirt_sway: int = 0
	if animation == "idle":
		bob = -1 if frame == 1 else 0
		skirt_sway = [-1, 0, 1, 0][frame]
	elif animation == "elegant_walk":
		bob = [-1, 0, 1, 0, -1, 0][frame]
		x += [0, 1, 2, 1, 0, -1][frame]
		skirt_sway = [-3, -1, 1, 3, 1, -1][frame]
	elif animation in ["sidestep", "backstep"]:
		lean = int(round(phase * (5.0 if animation == "sidestep" else -5.0)))
		crouch = 2
	elif animation.begins_with("rapier_thrust"):
		if animation.ends_with("windup"):
			lean = -frame
			crouch = frame
		elif animation.ends_with("active"):
			lean = 6 + frame * 2
			crouch = 3
		else:
			lean = 4 - frame
	elif animation.begins_with("fan_slash"):
		lean = -2 + frame if animation.ends_with("windup") else 3
		crouch = 2
	elif animation == "riposte":
		lean = -5 if frame < 3 else mini(7, frame)
		crouch = 3
	elif animation == "double_lunge":
		lean = [0, -2, 5, 7, 1, -1, 6, 8][frame]
		crouch = 3 if frame >= 2 else 1
	elif animation == "phase_transition":
		crouch = 3 if frame < 4 else 1
		skirt_sway = (frame % 3) - 1
	elif animation in ["phantom_dance", "final_waltz"]:
		lean = [-2, 0, 3, 5, 2, -1, 4, 6][frame % 8]
		skirt_sway = (frame % 4) - 2
	elif animation == "light_hit":
		lean = -3 if frame == 0 else -1
	elif animation == "stagger":
		lean = [-5, -7, -4, -2][frame]
		crouch = [2, 4, 5, 3][frame]
	elif animation == "death":
		return _draw_death(frame)
	elif animation == "turn":
		var narrow: int = [0, 3, 5, 2][frame]
		_draw_body(image, x + lean, y + bob + crouch, skirt_sway, animation, frame, narrow)
		return image
	_draw_body(image, x + lean, y + bob + crouch, skirt_sway, animation, frame, 0)
	return image


func _draw_body(image: Image, x: int, y: int, sway: int, animation: String, frame: int, narrow: int) -> void:
	# Hair/court veil and porcelain mask.
	_rect(image, x - 7 + narrow, y, 16 - narrow * 2, 6, OUTLINE)
	_rect(image, x - 9 + narrow, y + 5, 19 - narrow * 2, 16, BLACK)
	_rect(image, x - 5 + narrow / 2, y + 7, 12 - narrow, 11, MASK)
	_rect(image, x + 2, y + 11, 2, 2, MASK_SHADOW)
	if animation == "phase_transition" and frame >= 3:
		_rect(image, x, y + 8, 1, 8, RED)
		_rect(image, x + 2, y + 13, 4, 1, RED)
	# Narrow torso, high shoulders, damaged red bodice.
	_rect(image, x - 10 + narrow, y + 20, 22 - narrow * 2, 24, OUTLINE)
	_rect(image, x - 7 + narrow, y + 22, 16 - narrow * 2, 20, OXBLOOD)
	_rect(image, x - 4, y + 25, 9, 15, DRESS)
	_rect(image, x - 12, y + 22, 5, 18, BLACK)
	_rect(image, x + 9, y + 22, 5, 18, BLACK)
	# Layered court skirt with readable feet and restrained soul mist.
	_rect(image, x - 12 + sway, y + 42, 26, 17, OUTLINE)
	_rect(image, x - 9 + sway, y + 43, 20, 15, DRESS)
	_rect(image, x - 17 + sway, y + 55, 36, 11, OUTLINE)
	_rect(image, x - 13 + sway, y + 56, 28, 8, Color("351724"))
	_rect(image, x - 6, y + 64, 4, 8, BLACK)
	_rect(image, x + 5, y + 64, 4, 8, BLACK)
	_rect(image, x - 15 + sway, y + 67, 5, 2, SOUL)
	_rect(image, x + 13 + sway, y + 69, 4, 2, SOUL)
	# Rapier and fan are deliberately separated in silhouette.
	var rapier_start: Vector2i = Vector2i(x + 9, y + 28)
	var rapier_end: Vector2i = Vector2i(x + 34, y + 29)
	var fan_center: Vector2i = Vector2i(x - 11, y + 29)
	if animation.begins_with("rapier_thrust") or animation in ["riposte", "double_lunge"]:
		var extension: int = 30
		if animation.ends_with("active") or (animation == "riposte" and frame >= 4) or (animation == "double_lunge" and frame in [2, 3, 6, 7]):
			extension = 46
		rapier_end = Vector2i(x + extension, y + 25)
	if animation in ["sidestep", "backstep"]:
		rapier_end = Vector2i(x + 26, y + 22)
	_draw_line(image, rapier_start, rapier_end, STEEL, 2)
	_rect(image, rapier_end.x, rapier_end.y - 1, 4, 3, GLOW)
	if animation.begins_with("fan_slash"):
		var fan_extension: int = 13 + frame * 7
		_draw_line(image, fan_center, Vector2i(x + fan_extension, y + 16 + frame * 7), MASK_SHADOW, 3)
		_draw_line(image, fan_center, Vector2i(x + fan_extension + 3, y + 22 + frame * 5), STEEL, 2)
	else:
		_rect(image, fan_center.x - 4, fan_center.y - 5, 9, 11, RED)
		_draw_line(image, fan_center, Vector2i(fan_center.x - 8, fan_center.y - 8), STEEL, 2)


func _draw_death(frame: int) -> Image:
	var image: Image = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var body_y: int = 22 + frame * 6
	var body_h: int = maxi(5, 46 - frame * 6)
	_rect(image, 25 - frame * 2, body_y, 40 + frame * 3, body_h, OUTLINE)
	if frame < 5:
		_rect(image, 29 - frame * 2, body_y + 3, 32 + frame * 3, maxi(2, body_h - 6), OXBLOOD)
		_rect(image, 36 + frame, body_y + 5, 12, 10, MASK if frame < 3 else MASK_SHADOW)
	for particle: int in range(frame * 2):
		_rect(image, 24 + particle * 5, 70 - (particle % 4) * 6, 2, 2, SOUL)
	return image


func _generate_effects() -> void:
	var directory: String = "%s/effects" % ROOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var phantom: Image = Image.create(48, 72, false, Image.FORMAT_RGBA8)
	phantom.fill(CLEAR)
	_rect(phantom, 15, 4, 18, 14, Color(0.78, 0.84, 0.92, 0.62))
	_rect(phantom, 10, 18, 28, 34, Color(0.44, 0.38, 0.58, 0.50))
	_rect(phantom, 5, 50, 38, 10, Color(0.44, 0.38, 0.58, 0.30))
	phantom.save_png(ProjectSettings.globalize_path("%s/phantom_dancer.png" % directory))
	var spark: Image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	spark.fill(CLEAR)
	_rect(spark, 7, 1, 2, 14, GLOW)
	_rect(spark, 1, 7, 14, 2, GLOW)
	_rect(spark, 5, 5, 6, 6, MASK)
	spark.save_png(ProjectSettings.globalize_path("%s/rapier_glint.png" % directory))


func _draw_line(image: Image, start: Vector2i, finish: Vector2i, color: Color, thickness: int) -> void:
	var steps: int = maxi(abs(finish.x - start.x), abs(finish.y - start.y))
	for index: int in range(steps + 1):
		var ratio: float = float(index) / float(maxi(1, steps))
		var point: Vector2i = Vector2i(roundi(lerpf(start.x, finish.x, ratio)), roundi(lerpf(start.y, finish.y, ratio)))
		_rect(image, point.x, point.y, thickness, thickness, color)


func _rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	var clipped: Rect2i = Rect2i(x, y, width, height).intersection(Rect2i(0, 0, image.get_width(), image.get_height()))
	if clipped.size.x > 0 and clipped.size.y > 0:
		image.fill_rect(clipped, color)
