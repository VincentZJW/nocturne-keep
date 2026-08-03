extends SceneTree

const CATALOG_PATH: String = "res://chapters/chapter_04_drowned_underkeep/resources/environment/chapter_04_environment_asset_catalog_s2.json"
const WATER_FRAMES_PATH: String = "res://chapters/chapter_04_drowned_underkeep/resources/environment/chapter_04_water_fx_frames.tres"
const MOTION_FRAMES_PATH: String = "res://chapters/chapter_04_drowned_underkeep/resources/environment/chapter_04_environment_motion_frames.tres"

const REQUIRED_P0_IDS: Array[String] = [
	"WALL-01", "WALL-02", "WALL-03", "WALL-04", "WALL-06", "WALL-07",
	"FLOOR-01", "FLOOR-02", "FLOOR-03", "FLOOR-05", "FLOOR-08",
	"CELL-01", "CELL-04", "CELL-05",
	"PLAT-01", "PLAT-02", "PLAT-03", "PLAT-04",
	"CAT-01", "CAT-02", "CAT-03", "CAT-04", "CAT-07",
	"CIS-01", "CIS-02", "DRAIN-01", "DRAIN-04",
	"GATE-01", "GATE-02", "GATE-04", "GATE-05", "GATE-06",
	"BAR-01", "BAR-02", "BAR-03", "BAR-04", "BAR-05", "BAR-06",
	"CHAIN-01", "CHAIN-03", "CHAIN-04",
	"SOUL-01", "SOUL-02", "SOUL-04", "SOUL-05",
	"DOOR-01", "DOOR-02", "DOOR-03", "DOOR-04", "DOOR-05", "DOOR-06",
	"BOSSENV-01", "BOSSENV-02", "BOSSENV-03", "BOSSENV-04",
	"MEM-01", "MEM-02", "MEM-03", "MEM-04",
	"WFX-01", "WFX-02", "WFX-03", "WFX-04", "WFX-05",
	"RFX-01", "RFX-02", "RFX-03", "RFX-04", "RFX-05",
	"SFX-01", "SCFX-01", "SCFX-02", "SCFX-03", "SCFX-04",
]

const WATER_ANIMATIONS: Dictionary = {
	&"rear_water": 4,
	&"local_highlight": 4,
	&"front_lip": 6,
	&"flow_strip": 4,
	&"drain_foam": 4,
	&"step_ripple": 5,
	&"landing_splash": 5,
	&"dash_splash": 5,
	&"enemy_wake": 4,
	&"idle_ripple": 4,
}

const MOTION_ANIMATIONS: Dictionary = {
	&"waterwheel": 8,
	&"gear_train": 4,
	&"rear_chain_sway": 4,
	&"drip": 4,
	&"soul_flame": 6,
	&"cage_contained": 4,
	&"cage_strain": 4,
	&"cage_crack_leak": 4,
	&"cage_release": 4,
	&"memory_water": 6,
	&"boss_gate_seal": 4,
	&"floodgate_chain_strain": 4,
	&"floodgate_gear_dust": 4,
	&"floodgate_lock_spark": 4,
	&"floodgate_water_surge": 4,
}


func _initialize() -> void:
	var failures: Array[String] = []
	var catalog: Dictionary = _load_catalog(failures)
	if not catalog.is_empty():
		_validate_catalog(catalog, failures)
	_validate_sprite_frames(WATER_FRAMES_PATH, WATER_ANIMATIONS, failures)
	_validate_sprite_frames(MOTION_FRAMES_PATH, MOTION_ANIMATIONS, failures)
	_validate_water_layer_contract(failures)
	if failures.is_empty():
		print("CH4 S2 ENVIRONMENT ASSET TEST | PASS | assets=%d | animations=%d" % [int(catalog.get("asset_count", 0)), WATER_ANIMATIONS.size() + MOTION_ANIMATIONS.size()])
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("CH4 S2 ENVIRONMENT ASSET TEST | FAIL | errors=%d" % failures.size())
	quit(1)


func _load_catalog(failures: Array[String]) -> Dictionary:
	if not FileAccess.file_exists(CATALOG_PATH):
		failures.append("Missing catalog: %s" % CATALOG_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if not parsed is Dictionary:
		failures.append("Catalog is not a Dictionary")
		return {}
	return parsed as Dictionary


func _validate_catalog(catalog: Dictionary, failures: Array[String]) -> void:
	var assets: Array = catalog.get("assets", []) as Array
	if int(catalog.get("asset_count", -1)) != assets.size():
		failures.append("Catalog asset_count does not match assets array")
	if assets.size() < 290:
		failures.append("Expected at least 290 S2 assets, found %d" % assets.size())
	var present_ids: Dictionary = {}
	for asset_variant: Variant in assets:
		if not asset_variant is Dictionary:
			failures.append("Catalog contains a non-Dictionary asset entry")
			continue
		var asset: Dictionary = asset_variant as Dictionary
		var asset_id: String = str(asset.get("id", ""))
		var path: String = str(asset.get("path", ""))
		present_ids[asset_id] = true
		if not FileAccess.file_exists(path):
			failures.append("Missing PNG: %s" % path)
			continue
		var texture: Texture2D = load(path) as Texture2D
		var image: Image = texture.get_image() if texture != null else null
		if image == null or image.is_empty():
			failures.append("Unreadable PNG: %s" % path)
			continue
		if image.get_width() != int(asset.get("width", -1)) or image.get_height() != int(asset.get("height", -1)):
			failures.append("Dimension mismatch: %s" % path)
		if image.get_format() != Image.FORMAT_RGBA8:
			failures.append("Expected RGBA8 PNG: %s" % path)
		var import_path: String = path + ".import"
		if not FileAccess.file_exists(import_path):
			failures.append("Missing Godot import metadata: %s" % import_path)
			continue
		var import_text: String = FileAccess.get_file_as_string(import_path)
		if import_text.find("compress/mode=0") < 0:
			failures.append("PNG is not lossless-imported: %s" % path)
		if import_text.find("mipmaps/generate=false") < 0:
			failures.append("PNG unexpectedly generates mipmaps: %s" % path)
	for required_id: String in REQUIRED_P0_IDS:
		if not present_ids.has(required_id):
			failures.append("Missing P0 asset family: %s" % required_id)


func _validate_sprite_frames(path: String, expected: Dictionary, failures: Array[String]) -> void:
	var frames: SpriteFrames = load(path) as SpriteFrames
	if frames == null:
		failures.append("Missing SpriteFrames resource: %s" % path)
		return
	for animation_variant: Variant in expected.keys():
		var animation_name: StringName = animation_variant as StringName
		if not frames.has_animation(animation_name):
			failures.append("Missing animation %s in %s" % [animation_name, path])
			continue
		var expected_count: int = int(expected[animation_name])
		if frames.get_frame_count(animation_name) != expected_count:
			failures.append("Animation %s expected %d frames, found %d" % [animation_name, expected_count, frames.get_frame_count(animation_name)])


func _validate_water_layer_contract(failures: Array[String]) -> void:
	var front_lip_texture: Texture2D = load("res://chapters/chapter_04_drowned_underkeep/assets/fx/water/front_lip_01.png") as Texture2D
	var rear_water_texture: Texture2D = load("res://chapters/chapter_04_drowned_underkeep/assets/fx/water/rear_water_body_01.png") as Texture2D
	var highlight_texture: Texture2D = load("res://chapters/chapter_04_drowned_underkeep/assets/fx/water/local_highlight_01.png") as Texture2D
	var front_lip: Image = front_lip_texture.get_image() if front_lip_texture != null else null
	var rear_water: Image = rear_water_texture.get_image() if rear_water_texture != null else null
	var highlight: Image = highlight_texture.get_image() if highlight_texture != null else null
	if front_lip == null or front_lip.get_height() > 4:
		failures.append("Front water lip must remain a maximum 4px occlusion layer")
	if rear_water == null or rear_water.get_height() < 12:
		failures.append("Rear water body is missing or too shallow")
	if highlight == null or highlight.get_height() > 16:
		failures.append("Local highlight must remain a thin separate layer")
