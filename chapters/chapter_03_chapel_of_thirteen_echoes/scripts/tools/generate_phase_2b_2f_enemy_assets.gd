extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies"
const CLEAR: Color = Color(0, 0, 0, 0)
const OUTLINE: Color = Color("0b0d14")
const IRON: Color = Color("343b46")
const STEEL: Color = Color("8e9aa6")
const BONE: Color = Color("d5ccb9")
const WINE: Color = Color("713345")
const GOLD: Color = Color("a1844f")
const PALE: Color = Color("b9d9d6")
const GLASS_BLUE: Color = Color("4f8095")
const GLASS_RED: Color = Color("8d3f54")
const INK: Color = Color("28223a")

const ROLES: Array[String] = [
	"censer_executioner", "silent_chorister", "stained_glass_seraph",
	"confessional_wraith", "thirteenth_scribe",
]


func _initialize() -> void:
	var total: int = 0
	for role: String in ROLES:
		var animations: Dictionary = _animations(role)
		for animation: String in animations:
			var count: int = int(animations[animation])
			var directory: String = "%s/%s/sprites/%s" % [ROOT, role, animation]
			var error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
			if error != OK:
				push_error("Cannot create %s" % directory)
				quit(1)
				return
			for frame: int in range(count):
				var image: Image = _draw(role, animation, frame, count)
				var path: String = "%s/%s_%02d.png" % [directory, animation, frame + 1]
				if image.save_png(ProjectSettings.globalize_path(path)) != OK:
					push_error("Cannot save %s" % path)
					quit(1)
					return
				total += 1
	print("CH3 PHASE2B-2F ASSETS | PASS roles=5 frames=%d" % total)
	quit(0)


func _animations(role: String) -> Dictionary:
	var common: Dictionary = {
		"idle": 4, "walk": 6, "alert": 3, "turn": 3,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 6,
	}
	var actions: Array[String] = []
	match role:
		"censer_executioner": actions = ["primary", "overhead_crush", "smoke_release"]
		"silent_chorister": actions = ["silent_wave", "crescent_hymn", "hush_field"]
		"stained_glass_seraph": actions = ["shard_volley", "dive", "shatter_burst"]
		"confessional_wraith":
			actions = ["emerging_slash", "spectral_dash", "confession_scream"]
			common["hidden"] = 4
		"thirteenth_scribe": actions = ["ink_lance", "binding_script", "thirteenth_seal"]
	for action: String in actions:
		common["%s_windup" % action] = 5 if action != "overhead_crush" else 7
		common["%s_active" % action] = 2 if action != "hush_field" else 4
		common["%s_recovery" % action] = 5 if action != "overhead_crush" else 7
	return common


func _draw(role: String, animation: String, frame: int, count: int) -> Image:
	var image: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	var phase: float = float(frame) / float(maxi(1, count - 1))
	var bob: int = 0
	if animation == "idle": bob = [0, -1, -1, 0][frame]
	elif animation == "walk": bob = [0, -1, 0, 0, -1, 0][frame]
	var pose: String = "base"
	if animation.contains("windup"): pose = "windup"
	elif animation.contains("active"): pose = "active"
	elif animation.contains("recovery"): pose = "recovery"
	elif animation in ["hurt", "light_hit", "stagger"]: pose = "hurt"
	elif animation == "death": pose = "death"
	elif animation == "hidden": pose = "hidden"
	match role:
		"censer_executioner": _draw_executioner(image, animation, pose, frame, phase, bob)
		"silent_chorister": _draw_chorister(image, animation, pose, frame, phase, bob)
		"stained_glass_seraph": _draw_seraph(image, animation, pose, frame, phase, bob)
		"confessional_wraith": _draw_wraith(image, animation, pose, frame, phase, bob)
		"thirteenth_scribe": _draw_scribe(image, animation, pose, frame, phase, bob)
	return image


func _draw_executioner(img: Image, animation: String, pose: String, frame: int, phase: float, bob: int) -> void:
	if pose == "death":
		_rect(img, 11 + frame * 2, 48 + mini(frame, 3) * 2, maxi(8, 43 - frame * 5), maxi(2, 10 - frame), OUTLINE)
		_rect(img, 16, 51, maxi(4, 32 - frame * 4), 5, IRON)
		_draw_censer(img, Vector2i(50, 56), maxi(3, 7 - frame / 2))
		_draw_fragments(img, frame, WINE)
		return
	var x: int = 29 + (-3 if pose == "windup" else 3 if pose == "active" else 0)
	var y: int = 5 + bob
	var stride: int = [-3, -1, 1, 3, 1, -1][frame] if animation == "walk" else 0
	_draw_leg(img, Vector2i(x - 7, 42), Vector2i(x - 8 - stride, 58), 5)
	_draw_leg(img, Vector2i(x + 7, 42), Vector2i(x + 8 + stride, 58), 5)
	_rect(img, x - 13, y + 18, 27, 31, OUTLINE)
	_rect(img, x - 11, y + 20, 23, 27, IRON)
	_rect(img, x - 12, y + 30, 25, 16, WINE)
	_rect(img, x - 9, y, 18, 18, OUTLINE)
	_rect(img, x - 7, y + 2, 14, 15, BONE)
	_rect(img, x - 5, y + 8, 11, 4, OUTLINE)
	_rect(img, x - 12, y + 18, 26, 6, STEEL)
	var hand: Vector2i = Vector2i(x + 13, y + 28)
	var censer: Vector2i = Vector2i(x + 24, y + 43)
	if pose == "windup": censer = Vector2i(x - 13 + roundi(phase * 8), y + 11 - roundi(phase * 12))
	elif pose == "active": censer = Vector2i(59, y + (22 if animation.contains("primary") else 50))
	elif pose == "recovery": censer = Vector2i(55 - roundi(phase * 23), y + 32 + roundi(phase * 9))
	_draw_chain(img, hand, censer)
	_draw_censer(img, censer, 7)
	if animation.contains("smoke_release") and pose == "active": _draw_cloud(img, Vector2i(48, 43), frame, PALE)


func _draw_chorister(img: Image, animation: String, pose: String, frame: int, phase: float, bob: int) -> void:
	if pose == "death":
		_draw_fragments(img, frame + 2, PALE)
		_rect(img, 23, 42 + frame * 2, maxi(4, 19 - frame * 2), maxi(2, 14 - frame * 2), INK)
		return
	var x: int = 31 + (2 if pose == "active" else 0)
	var y: int = 8 + bob + roundi(sin(float(frame)) * 2.0)
	_rect(img, x - 8, y + 4, 17, 13, OUTLINE)
	_rect(img, x - 6, y + 6, 13, 9, BONE)
	_rect(img, x - 5, y + 9, 11, 3, WINE)
	_rect(img, x - 11, y, 23, 3, GOLD)
	_rect(img, x - 8, y - 2, 7, 2, GOLD)
	_rect(img, x + 3, y - 2, 6, 2, GOLD)
	_rect(img, x - 10, y + 17, 21, 30, OUTLINE)
	_rect(img, x - 8, y + 18, 17, 27, INK)
	_rect(img, x - 12, y + 41, 25, 9, INK)
	var book_x: int = x + (15 if pose == "active" else 8)
	_rect(img, book_x - 5, y + 23, 11, 9, OUTLINE)
	_rect(img, book_x - 4, y + 24, 4, 7, BONE)
	_rect(img, book_x + 1, y + 24, 4, 7, BONE)
	if pose == "active":
		var color: Color = PALE if animation.contains("silent_wave") else WINE
		_draw_arc_marks(img, Vector2i(x + 18, y + 27), frame, color)


func _draw_seraph(img: Image, animation: String, pose: String, frame: int, phase: float, bob: int) -> void:
	if pose == "death":
		_draw_fragments(img, frame + 3, GLASS_BLUE)
		_draw_fragments(img, frame + 1, GLASS_RED)
		return
	var x: int = 31 + (roundi(phase * 7.0) if animation.contains("dive") and pose == "active" else 0)
	var y: int = 12 + bob
	var wing: int = 13 + (frame % 3) * 2
	_draw_line(img, Vector2i(x - 3, y + 20), Vector2i(x - wing, y + 8), 5, OUTLINE)
	_draw_line(img, Vector2i(x - 5, y + 22), Vector2i(x - wing - 2, y + 34), 5, GLASS_BLUE)
	_draw_line(img, Vector2i(x + 3, y + 20), Vector2i(x + wing, y + 8), 5, OUTLINE)
	_draw_line(img, Vector2i(x + 5, y + 22), Vector2i(x + wing + 2, y + 34), 5, GLASS_RED)
	_rect(img, x - 5, y + 12, 11, 28, OUTLINE)
	_rect(img, x - 3, y + 14, 7, 24, STEEL)
	_rect(img, x - 5, y + 3, 11, 10, OUTLINE)
	_rect(img, x - 3, y + 5, 7, 6, GLASS_BLUE)
	_rect(img, x - 8, y, 17, 2, GOLD)
	if pose == "active" and animation.contains("shard"):
		for i: int in range(3): _draw_line(img, Vector2i(x + 11, y + 18 + i * 4), Vector2i(x + 24, y + 15 + i * 6), 2, PALE)


func _draw_wraith(img: Image, animation: String, pose: String, frame: int, phase: float, bob: int) -> void:
	var booth_x: int = 25
	_rect(img, booth_x - 8, 11, 17, 45, OUTLINE)
	_rect(img, booth_x - 6, 13, 13, 41, INK)
	_rect(img, booth_x - 5, 19, 11, 12, WINE)
	for bar: int in range(3): _rect(img, booth_x - 3 + bar * 3, 20, 1, 10, STEEL)
	if pose == "hidden": return
	if pose == "death":
		_draw_fragments(img, frame + 2, PALE)
		return
	var x: int = 38 + (8 if pose == "active" else roundi(phase * 3.0))
	var y: int = 13 + bob
	_rect(img, x - 6, y, 12, 12, OUTLINE)
	_rect(img, x - 4, y + 2, 8, 8, PALE)
	_rect(img, x - 3, y + 4, 6, 3, OUTLINE)
	_rect(img, x - 8, y + 12, 17, 27, Color(PALE, 0.75))
	_rect(img, x - 11, y + 35, 22, 8, Color(PALE, 0.45))
	var arm_end: Vector2i = Vector2i(61 if pose == "active" else x + 13, y + 22)
	_draw_line(img, Vector2i(x + 6, y + 16), arm_end, 3, PALE)
	if animation.contains("scream") and pose == "active": _draw_arc_marks(img, Vector2i(x + 12, y + 8), frame, PALE)


func _draw_scribe(img: Image, animation: String, pose: String, frame: int, phase: float, bob: int) -> void:
	if pose == "death":
		_draw_fragments(img, frame + 4, BONE)
		_rect(img, 20, 51, maxi(4, 27 - frame * 3), maxi(2, 7 - frame), INK)
		return
	var x: int = 30 + (2 if pose == "active" else 0)
	var y: int = 7 + bob
	_draw_leg(img, Vector2i(x - 4, 43), Vector2i(x - 5, 58), 3)
	_draw_leg(img, Vector2i(x + 4, 43), Vector2i(x + 5, 58), 3)
	_rect(img, x - 8, y + 16, 17, 34, OUTLINE)
	_rect(img, x - 6, y + 18, 13, 30, INK)
	_rect(img, x - 5, y, 11, 16, OUTLINE)
	_rect(img, x - 4, y + 2, 9, 12, BONE)
	_rect(img, x - 3, y + 5, 7, 2, OUTLINE)
	_rect(img, x + 9, y + 22, 13, 13, OUTLINE)
	_rect(img, x + 11, y + 24, 9, 9, BONE)
	for line: int in range(3): _rect(img, x + 12, y + 25 + line * 3, 6, 1, WINE)
	var quill_end: Vector2i = Vector2i(59 if pose == "active" else x + 22, y + 13)
	_draw_line(img, Vector2i(x + 8, y + 25), quill_end, 2, PALE)
	if pose == "active" and animation.contains("seal"):
		_draw_arc_marks(img, Vector2i(x + 19, y + 42), frame, WINE)


func _draw_leg(img: Image, start: Vector2i, finish: Vector2i, width: int) -> void:
	_draw_line(img, start, finish, width + 2, OUTLINE)
	_draw_line(img, start, finish, width, IRON)
	_rect(img, finish.x - 3, finish.y - 1, 7, 3, OUTLINE)


func _draw_chain(img: Image, start: Vector2i, finish: Vector2i) -> void:
	var steps: int = maxi(abs(finish.x - start.x), abs(finish.y - start.y))
	for i: int in range(steps + 1):
		if i % 3 == 2: continue
		var p: Vector2i = Vector2i(roundi(lerpf(start.x, finish.x, float(i) / maxi(1, steps))), roundi(lerpf(start.y, finish.y, float(i) / maxi(1, steps))))
		_rect(img, p.x, p.y, 2, 2, STEEL)


func _draw_censer(img: Image, center: Vector2i, size: int) -> void:
	_rect(img, center.x - size / 2, center.y - size, size, size, OUTLINE)
	_rect(img, center.x - size / 2 + 1, center.y - size + 1, maxi(1, size - 2), maxi(1, size - 2), GOLD)
	_rect(img, center.x - size / 2 - 1, center.y - 2, size + 2, 2, OUTLINE)


func _draw_cloud(img: Image, center: Vector2i, frame: int, color: Color) -> void:
	for i: int in range(5):
		var p: Vector2i = center + Vector2i((i - 2) * 5 + frame, -abs(i - 2) * 2)
		_rect(img, p.x - 3, p.y - 3, 7, 5, Color(color, 0.55))


func _draw_arc_marks(img: Image, center: Vector2i, frame: int, color: Color) -> void:
	for i: int in range(3):
		_rect(img, center.x + i * 5 + frame, center.y - i * 3, 2, 7 + i * 2, color)


func _draw_fragments(img: Image, count: int, color: Color) -> void:
	for i: int in range(count * 3):
		_rect(img, 12 + (i * 11 + count * 5) % 42, 14 + (i * 7 + count * 3) % 39, 1 + i % 2, 1 + (i + count) % 2, Color(color, maxf(0.2, 1.0 - count * 0.1)))


func _draw_line(img: Image, a: Vector2i, b: Vector2i, width: int, color: Color) -> void:
	var steps: int = maxi(abs(b.x - a.x), abs(b.y - a.y))
	for i: int in range(steps + 1):
		var ratio: float = float(i) / float(maxi(1, steps))
		var p: Vector2i = Vector2i(roundi(lerpf(a.x, b.x, ratio)), roundi(lerpf(a.y, b.y, ratio)))
		_rect(img, p.x - width / 2, p.y - width / 2, width, width, color)


func _rect(img: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	var clipped: Rect2i = Rect2i(x, y, width, height).intersection(Rect2i(0, 0, 64, 64))
	if clipped.size.x > 0 and clipped.size.y > 0: img.fill_rect(clipped, color)
