extends SceneTree

const OUTPUT: String = "res://docs/qa/core_character_replication/core_character_replication_roster.png"
const SAMPLES: Array[Dictionary] = [
	{
		"role": "night_warden_veilbound",
		"paths": [
			"res://shared/assets/player/animations/veilbound/idle/idle_01.png",
			"res://shared/assets/player/animations/veilbound/attack_3/attack_3_03.png",
		],
	},
	{
		"role": "night_warden_ravenfang",
		"paths": [
			"res://shared/assets/player/animations/ravenfang/idle/idle_01.png",
			"res://shared/assets/player/animations/ravenfang/dash_attack/dash_attack_03.png",
		],
	},
	{
		"role": "night_warden_crimson_masque",
		"paths": [
			"res://shared/assets/player/animations/crimson_masque/idle/idle_01.png",
			"res://shared/assets/player/animations/crimson_masque/attack_3/attack_3_03.png",
		],
	},
	{
		"role": "candle_warden",
		"paths": [
			"res://chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden/animations/idle/idle_01.png",
			"res://chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden/animations/offer_key/offer_key_03.png",
		],
	},
]
const BG: Color = Color("080b12")
const PANEL: Color = Color("131821")
const BORDER: Color = Color("657584")


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.get_base_dir()))
	var board: Image = Image.create(1536, 768, false, Image.FORMAT_RGBA8)
	board.fill(BG)
	var failures: int = 0
	for index: int in range(SAMPLES.size()):
		var entry: Dictionary = SAMPLES[index]
		var rect: Rect2i = Rect2i(18 + (index % 2) * 759, 18 + (index / 2) * 375, 741, 357)
		board.fill_rect(rect, BORDER)
		board.fill_rect(Rect2i(rect.position + Vector2i(3, 3), rect.size - Vector2i(6, 6)), PANEL)
		var paths: Array = entry["paths"] as Array
		for pose: int in range(paths.size()):
			var source: Image = Image.load_from_file(ProjectSettings.globalize_path(paths[pose] as String))
			if source == null or source.is_empty():
				failures += 1
				continue
			_blit_fit(board, source, Rect2i(rect.position + Vector2i(12 + pose * 358, 12), Vector2i(345, 333)))
	var error: Error = board.save_png(ProjectSettings.globalize_path(OUTPUT))
	if error != OK:
		failures += 1
	print("CORE CHARACTER REPLICATION EVIDENCE | %s" % ("PASS" if failures == 0 else "FAIL %d" % failures))
	quit(0 if failures == 0 else 1)


func _blit_fit(target: Image, source: Image, rect: Rect2i) -> void:
	var copy: Image = source.duplicate()
	var scale_factor: float = minf(float(rect.size.x) / float(copy.get_width()), float(rect.size.y) / float(copy.get_height()))
	var size: Vector2i = Vector2i(maxi(1, roundi(copy.get_width() * scale_factor)), maxi(1, roundi(copy.get_height() * scale_factor)))
	copy.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
	target.blend_rect(copy, Rect2i(Vector2i.ZERO, size), rect.position + (rect.size - size) / 2)
