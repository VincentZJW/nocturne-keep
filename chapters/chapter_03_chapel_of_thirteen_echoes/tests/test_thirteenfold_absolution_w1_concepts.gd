extends SceneTree

const CONCEPT_ROOT: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/"
	+ "assets/weapons/thirteenfold_absolution/concept_art"
)
const REQUIRED_IMAGES: Dictionary[String, Vector2i] = {
	"absolution_main_blade_front.png": Vector2i(1024, 1536),
	"absolution_main_blade_side.png": Vector2i(1024, 1536),
	"penance_offhand_blade_front.png": Vector2i(1024, 1536),
	"penance_offhand_blade_side.png": Vector2i(1024, 1536),
	"thirteen_seal_nodes.png": Vector2i(1254, 1254),
	"thirteenfold_absolution_pair_concept.png": Vector2i(1536, 1024),
	"thirteenfold_absolution_silhouette.png": Vector2i(1536, 1024),
	"thirteenfold_combat_pose.png": Vector2i(1536, 1024),
	"thirteenfold_guard_breakdown.png": Vector2i(1536, 1024),
	"thirteenfold_player_scale.png": Vector2i(1536, 1024),
	"thirteenfold_reforging_sequence.png": Vector2i(1536, 1024),
	"thirteenfold_reliquary_concept.png": Vector2i(1536, 1024),
}


func _initialize() -> void:
	var failures: Array[String] = []
	var hashes: Dictionary[String, bool] = {}
	for file_name: String in REQUIRED_IMAGES:
		var path: String = "%s/%s" % [CONCEPT_ROOT, file_name]
		_check_concept(path, REQUIRED_IMAGES[file_name], hashes, failures)
	if hashes.size() != REQUIRED_IMAGES.size():
		failures.append(
			"Concept images must have unique SHA-256 hashes: expected=%d actual=%d"
			% [REQUIRED_IMAGES.size(), hashes.size()]
		)
	if failures.is_empty():
		print(
			"THIRTEENFOLD_ABSOLUTION_W1 | PASS concepts=%d unique_hashes=%d"
			% [REQUIRED_IMAGES.size(), hashes.size()]
		)
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("THIRTEENFOLD_ABSOLUTION_W1 | FAIL count=%d" % failures.size())
	quit(1)


func _check_concept(
	path: String,
	expected_size: Vector2i,
	hashes: Dictionary[String, bool],
	failures: Array[String]
) -> void:
	if not FileAccess.file_exists(path):
		failures.append("Missing concept image: %s" % path)
		return
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		failures.append("Concept image did not import as Texture2D: %s" % path)
		return
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		failures.append("Concept image has no image data: %s" % path)
		return
	if image.get_size() != expected_size:
		failures.append(
			"Unexpected dimensions for %s: expected=%s actual=%s"
			% [path, expected_size, image.get_size()]
		)
	if image.get_used_rect().size == Vector2i.ZERO:
		failures.append("Concept image has no visible bounds: %s" % path)
	var hash_value: String = FileAccess.get_sha256(path)
	if hash_value.is_empty():
		failures.append("Could not hash concept image: %s" % path)
		return
	hashes[hash_value] = true
