extends SceneTree

const ASSET_ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies"
const ENEMY_SLUGS: Array[String] = [
	"bellchain_penitent",
	"censer_executioner",
	"silent_chorister",
	"stained_glass_seraph",
	"confessional_wraith",
	"thirteenth_scribe",
]


func _initialize() -> void:
	var failures: Array[String] = []
	var silhouette_hashes: Dictionary = {}
	var checked_count: int = 0
	for enemy_slug: String in ENEMY_SLUGS:
		var concept_path: String = "%s/%s/concept_art/%s_concept.png" % [ASSET_ROOT, enemy_slug, enemy_slug]
		var silhouette_path: String = "%s/%s/concept_art/%s_silhouette.png" % [ASSET_ROOT, enemy_slug, enemy_slug]
		_check_asset(concept_path, Vector2i(256, 256), failures)
		_check_asset(silhouette_path, Vector2i(192, 192), failures)
		silhouette_hashes[FileAccess.get_sha256(silhouette_path)] = true
		checked_count += 2
	if silhouette_hashes.size() != ENEMY_SLUGS.size():
		failures.append("Silhouette hashes are not unique across all six enemies")
	if failures.is_empty():
		print("CHAPTER 03 ENEMY CONCEPT ASSETS | PASS files=%d concepts=6 silhouettes=6 unique_silhouettes=%d" % [checked_count, silhouette_hashes.size()])
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("CHAPTER 03 ENEMY CONCEPT ASSETS | FAIL count=%d" % failures.size())
	quit(1)


func _check_asset(path: String, expected_size: Vector2i, failures: Array[String]) -> void:
	if not FileAccess.file_exists(path):
		failures.append("Missing asset: %s" % path)
		return
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		failures.append("Unreadable imported texture: %s" % path)
		return
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		failures.append("Imported texture has no image data: %s" % path)
		return
	if image.get_size() != expected_size:
		failures.append("Unexpected dimensions %s for %s; expected %s" % [image.get_size(), path, expected_size])
	if image.detect_alpha() == Image.ALPHA_NONE:
		failures.append("Missing alpha channel: %s" % path)
	var visible_pixels: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.0:
				visible_pixels += 1
	if visible_pixels <= 0:
		failures.append("Pure-transparent asset: %s" % path)
	if image.get_used_rect().size == Vector2i.ZERO:
		failures.append("Missing visible bounds: %s" % path)
