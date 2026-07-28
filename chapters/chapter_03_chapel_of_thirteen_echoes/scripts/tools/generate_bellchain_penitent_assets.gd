extends SceneTree

## Deterministic native-pixel source generator for Chapter III Phase 2A.

const OUTPUT_ROOT: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies/"
	+ "bellchain_penitent/sprites"
)
const TRANSPARENT: Color = Color(0, 0, 0, 0)
const VOID: Color = Color("090b12")
const OUTLINE: Color = Color("11141d")
const ASH: Color = Color("292b34")
const ASH_LIGHT: Color = Color("3a3d48")
const IRON: Color = Color("4b5561")
const STEEL: Color = Color("82909b")
const BONE: Color = Color("d0c7b6")
const COPPER: Color = Color("8a6540")
const COPPER_LIGHT: Color = Color("b08a58")
const WINE: Color = Color("6d2f3b")

const ANIMATIONS: Dictionary = {
	"idle": 4,
	"walk": 6,
	"alert": 3,
	"turn": 3,
	"chain_lash_windup": 5,
	"chain_lash_active": 2,
	"chain_lash_recovery": 5,
	"bell_slam_windup": 7,
	"bell_slam_active": 2,
	"bell_slam_recovery": 6,
	"chain_pull_windup": 5,
	"chain_pull_active": 2,
	"chain_pull_recovery": 5,
	"light_hit": 2,
	"stagger": 4,
	"hurt": 3,
	"death": 6,
}


func _initialize() -> void:
	var written: int = 0
	for animation_name: String in ANIMATIONS:
		var frame_count: int = int(ANIMATIONS[animation_name])
		var directory: String = "%s/%s" % [OUTPUT_ROOT, animation_name]
		var directory_error: Error = DirAccess.make_dir_recursive_absolute(
			ProjectSettings.globalize_path(directory)
		)
		if directory_error != OK:
			push_error("Unable to create %s: %s" % [directory, error_string(directory_error)])
			quit(1)
			return
		for frame_index: int in range(frame_count):
			var image: Image = _draw_frame(animation_name, frame_index, frame_count)
			var output_path: String = "%s/%s_%02d.png" % [
				directory, animation_name, frame_index + 1,
			]
			var save_error: Error = image.save_png(ProjectSettings.globalize_path(output_path))
			if save_error != OK:
				push_error("Unable to save %s: %s" % [output_path, error_string(save_error)])
				quit(1)
				return
			written += 1
	print("CH3 BELLCHAIN ASSET GENERATOR | PASS frames=%d animations=%d" % [written, ANIMATIONS.size()])
	quit(0)


func _draw_frame(animation_name: String, frame: int, frame_count: int) -> Image:
	var image: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(TRANSPARENT)
	if animation_name == "death":
		_draw_death(image, frame)
		return image
	var phase: float = float(frame) / float(maxi(1, frame_count - 1))
	var center_x: int = 31
	var bob: int = 0
	var stride: int = 0
	var lean: int = 0
	var free_hand: Vector2i = Vector2i(20, 33)
	var chain_hand: Vector2i = Vector2i(41, 31)
	var prayer_bell: Vector2i = Vector2i(45, 43)
	var alert_eye: bool = false
	var ground_spark: bool = false
	match animation_name:
		"idle":
			bob = [0, -1, -1, 0][frame]
			prayer_bell += Vector2i(frame % 2, -frame % 2)
		"walk":
			stride = [-3, -1, 1, 3, 1, -1][frame]
			bob = [0, -1, 0, 0, -1, 0][frame]
			prayer_bell = Vector2i(44 - stride, 42 + abs(stride) / 2)
		"alert":
			lean = [0, -1, 1][frame]
			chain_hand = Vector2i(42 + frame, 29 - frame)
			prayer_bell = Vector2i(47 + frame * 2, 38 - frame * 2)
			alert_eye = true
		"turn":
			center_x = [31, 32, 31][frame]
			chain_hand = Vector2i([40, 34, 24][frame], 31)
			prayer_bell = Vector2i([45, 35, 19][frame], 42)
		"chain_lash_windup":
			lean = -frame / 2
			chain_hand = Vector2i(37 - frame * 2, 29 - mini(frame, 2))
			prayer_bell = Vector2i(42 - frame * 6, 42 - frame * 3)
		"chain_lash_active":
			lean = 3
			center_x = 30
			free_hand = Vector2i(23, 36)
			chain_hand = Vector2i(42, 28 + frame)
			prayer_bell = Vector2i(60, 28 + frame * 3)
			alert_eye = true
		"chain_lash_recovery":
			lean = 3 - frame
			chain_hand = Vector2i(42 - frame, 30 + frame / 2)
			prayer_bell = Vector2i(56 - frame * 3, 33 + frame * 2)
		"bell_slam_windup":
			lean = -frame / 3
			chain_hand = Vector2i(39 + frame / 2, 28 - frame * 2)
			prayer_bell = Vector2i(43 + frame / 2, 38 - frame * 5)
		"bell_slam_active":
			lean = 3
			center_x = 30
			free_hand = Vector2i(22, 37)
			chain_hand = Vector2i(43, 37)
			prayer_bell = Vector2i(50 + frame * 2, 54)
			ground_spark = true
		"bell_slam_recovery":
			lean = 3 - frame / 2
			chain_hand = Vector2i(43 - frame, 37 - frame)
			prayer_bell = Vector2i(51 - frame * 2, 54 - frame * 2)
		"chain_pull_windup":
			lean = -1
			chain_hand = Vector2i(39 + frame, 30)
			prayer_bell = Vector2i(44 + frame * 3, 40 - frame)
		"chain_pull_active":
			lean = 2
			chain_hand = Vector2i(42, 31)
			prayer_bell = Vector2i(61, 32 + frame)
			alert_eye = true
		"chain_pull_recovery":
			lean = 2 - frame / 2
			chain_hand = Vector2i(42 - frame, 31 + frame / 2)
			prayer_bell = Vector2i(59 - frame * 4, 33 + frame * 2)
		"light_hit":
			lean = -2 - frame
			free_hand = Vector2i(18 - frame, 31)
			chain_hand = Vector2i(40 - frame * 2, 34)
			prayer_bell = Vector2i(48 + frame, 39 - frame * 2)
		"stagger":
			lean = [-4, -6, -5, -3][frame]
			free_hand = Vector2i(17 - frame, 29 + frame)
			chain_hand = Vector2i(38 - frame * 2, 35)
			prayer_bell = Vector2i(48 + frame * 2, 37 - frame)
			alert_eye = frame < 2
		"hurt":
			lean = [-3, -5, -3][frame]
			free_hand = Vector2i(18 - frame, 30)
			chain_hand = Vector2i(39 - frame, 35)
			prayer_bell = Vector2i(49 + frame, 40 - frame * 2)
	_draw_penitent(
		image,
		center_x,
		bob,
		lean,
		stride,
		free_hand,
		chain_hand,
		prayer_bell,
		alert_eye,
		ground_spark,
	)
	return image


func _draw_penitent(
	image: Image,
	center_x: int,
	vertical_offset: int,
	lean: int,
	stride: int,
	free_hand: Vector2i,
	chain_hand: Vector2i,
	prayer_bell: Vector2i,
	alert_eye: bool,
	ground_spark: bool,
) -> void:
	var x: int = center_x + lean
	var y: int = 9 + vertical_offset
	# Legs and narrow bare feet remain separate beneath the robe.
	_draw_limb(image, Vector2i(x - 4, 47), Vector2i(x - 5 - stride, 57), 3, OUTLINE, IRON)
	_draw_limb(image, Vector2i(x + 4, 47), Vector2i(x + 5 + stride, 57), 3, OUTLINE, IRON)
	_rect(image, x - 10 - stride, 57, 8, 3, OUTLINE)
	_rect(image, x - 9 - stride, 57, 6, 1, BONE)
	_rect(image, x + 2 + stride, 57, 8, 3, OUTLINE)
	_rect(image, x + 3 + stride, 57, 6, 1, BONE)
	# Stepped penitential robe with wine-colored inner strip and torn gaps.
	_rect(image, x - 8, y + 18, 17, 20, OUTLINE)
	_rect(image, x - 6, y + 19, 13, 18, ASH)
	_rect(image, x - 10, y + 35, 21, 14, OUTLINE)
	_rect(image, x - 8, y + 35, 17, 12, ASH)
	_rect(image, x - 5, y + 36, 4, 11, WINE)
	_rect(image, x - 9, y + 44, 4, 7, ASH_LIGHT)
	_rect(image, x + 2, y + 44, 4, 6, ASH_LIGHT)
	_rect(image, x + 8, y + 42, 3, 7, ASH)
	_set_pixel(image, x - 7, y + 46, TRANSPARENT)
	_set_pixel(image, x + 5, y + 45, TRANSPARENT)
	# Shoulders and arms are readable separately from the torso.
	_rect(image, x - 10, y + 19, 21, 5, OUTLINE)
	_rect(image, x - 8, y + 20, 17, 3, ASH_LIGHT)
	_draw_limb(image, Vector2i(x - 8, y + 23), free_hand, 3, OUTLINE, ASH_LIGHT)
	_draw_limb(image, Vector2i(x + 8, y + 23), chain_hand, 3, OUTLINE, ASH_LIGHT)
	_draw_hand(image, free_hand)
	_draw_hand(image, chain_hand)
	# Wrapped head, iron mouth seal and one restrained alert glint.
	_rect(image, x - 6, y, 12, 13, OUTLINE)
	_rect(image, x - 5, y + 1, 10, 11, IRON)
	_rect(image, x - 5, y + 3, 10, 2, ASH_LIGHT)
	_rect(image, x - 4, y + 7, 9, 2, OUTLINE)
	_rect(image, x - 3, y + 8, 7, 2, COPPER)
	_rect(image, x - 1, y + 9, 1, 2, WINE)
	if alert_eye:
		_rect(image, x + 2, y + 5, 2, 1, BONE)
	# Collar, throat bell, waist chain and small ritual fasteners carry concept detail.
	_rect(image, x - 5, y + 13, 11, 3, OUTLINE)
	_rect(image, x - 4, y + 14, 9, 1, COPPER)
	_draw_bell(image, Vector2i(x + 1, y + 18), 6, true)
	_draw_chain(image, Vector2i(x - 7, y + 32), Vector2i(x + 7, y + 35))
	_rect(image, x - 7, y + 38, 2, 2, COPPER_LIGHT)
	_rect(image, x + 6, y + 37, 2, 2, COPPER_LIGHT)
	# The short prayer chain and its separate bell are the attack-readable silhouette.
	_draw_chain(image, chain_hand, prayer_bell - Vector2i(0, 3))
	_draw_bell(image, prayer_bell, 5, false)
	if ground_spark:
		_rect(image, prayer_bell.x - 8, 58, 5, 1, COPPER_LIGHT)
		_rect(image, prayer_bell.x + 4, 57, 4, 1, BONE)
		_rect(image, prayer_bell.x - 2, 55, 2, 2, WINE)


func _draw_death(image: Image, frame: int) -> void:
	if frame == 0:
		_draw_penitent(
			image, 31, 0, -4, 0, Vector2i(17, 31), Vector2i(38, 35),
			Vector2i(50, 38), true, false,
		)
		return
	var body_y: int = 46 + mini(frame, 3) * 3
	var body_width: int = maxi(8, 30 - frame * 3)
	_rect(image, 18, body_y, body_width, maxi(3, 12 - frame * 2), OUTLINE)
	if frame < 4:
		_rect(image, 20, body_y + 2, maxi(4, body_width - 4), maxi(1, 8 - frame * 2), ASH)
		_rect(image, 23, body_y, 6, 5, IRON)
	_draw_chain(image, Vector2i(36, body_y + 2), Vector2i(51, 57))
	_draw_bell(image, Vector2i(53, 57), 5, false)
	_draw_bell(image, Vector2i(31, body_y - 1), 5, true)
	for particle: int in range(frame * 2):
		var px: int = 18 + ((particle * 7 + frame * 3) % 32)
		var py: int = 47 - ((particle * 5 + frame * 2) % 20)
		_rect(image, px, py, 1 + particle % 2, 1 + (particle + frame) % 2, ASH_LIGHT if particle % 3 else COPPER)


func _draw_limb(
	image: Image,
	start: Vector2i,
	finish: Vector2i,
	thickness: int,
	outline_color: Color,
	inner_color: Color,
) -> void:
	_draw_line(image, start, finish, thickness + 2, outline_color)
	_draw_line(image, start, finish, thickness, inner_color)


func _draw_hand(image: Image, position: Vector2i) -> void:
	_rect(image, position.x - 2, position.y - 1, 5, 4, OUTLINE)
	_rect(image, position.x - 1, position.y, 3, 2, BONE)


func _draw_chain(image: Image, start: Vector2i, finish: Vector2i) -> void:
	var distance: int = maxi(abs(finish.x - start.x), abs(finish.y - start.y))
	if distance <= 0:
		return
	for index: int in range(distance + 1):
		if index % 3 == 2:
			continue
		var ratio: float = float(index) / float(distance)
		var point: Vector2i = Vector2i(
			roundi(lerpf(float(start.x), float(finish.x), ratio)),
			roundi(lerpf(float(start.y), float(finish.y), ratio)),
		)
		_rect(image, point.x, point.y, 2, 2, OUTLINE)
		_set_pixel(image, point.x, point.y, COPPER_LIGHT if index % 4 == 0 else IRON)


func _draw_bell(image: Image, base: Vector2i, size: int, throat_bell: bool) -> void:
	var width: int = size + (1 if throat_bell else 0)
	var left: int = base.x - width / 2
	var top: int = base.y - size
	_rect(image, left + 1, top, maxi(1, width - 2), 2, OUTLINE)
	_rect(image, left, top + 2, width, maxi(2, size - 3), OUTLINE)
	_rect(image, left + 1, top + 2, maxi(1, width - 2), maxi(1, size - 4), COPPER)
	_rect(image, left - 1, base.y - 2, width + 2, 2, OUTLINE)
	_rect(image, left, base.y - 2, width, 1, COPPER_LIGHT)
	_rect(image, base.x, base.y, 2, 2, OUTLINE)
	_set_pixel(image, base.x, base.y, COPPER_LIGHT)


func _draw_line(
	image: Image, start: Vector2i, finish: Vector2i, thickness: int, color: Color
) -> void:
	var distance: int = maxi(abs(finish.x - start.x), abs(finish.y - start.y))
	if distance <= 0:
		_rect(image, start.x, start.y, thickness, thickness, color)
		return
	for index: int in range(distance + 1):
		var ratio: float = float(index) / float(distance)
		var point: Vector2i = Vector2i(
			roundi(lerpf(float(start.x), float(finish.x), ratio)),
			roundi(lerpf(float(start.y), float(finish.y), ratio)),
		)
		_rect(image, point.x - thickness / 2, point.y - thickness / 2, thickness, thickness, color)


func _rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	var bounds: Rect2i = Rect2i(0, 0, image.get_width(), image.get_height())
	var clipped: Rect2i = Rect2i(x, y, width, height).intersection(bounds)
	if clipped.size.x > 0 and clipped.size.y > 0:
		image.fill_rect(clipped, color)


func _set_pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
		image.set_pixel(x, y, color)
