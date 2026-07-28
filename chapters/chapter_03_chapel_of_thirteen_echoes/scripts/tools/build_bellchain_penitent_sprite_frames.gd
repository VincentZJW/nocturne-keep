extends SceneTree

const SPRITE_ROOT: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies/"
	+ "bellchain_penitent/sprites"
)
const OUTPUT_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies/"
	+ "bellchain_penitent/animations/bellchain_penitent_sprite_frames.tres"
)

const ANIMATIONS: Dictionary = {
	"idle": [4, 4.0, true],
	"walk": [6, 8.0, true],
	"alert": [3, 10.0, false],
	"turn": [3, 10.0, false],
	"chain_lash_windup": [5, 12.0, false],
	"chain_lash_active": [2, 16.67, false],
	"chain_lash_recovery": [5, 9.62, false],
	"bell_slam_windup": [7, 11.29, false],
	"bell_slam_active": [2, 14.29, false],
	"bell_slam_recovery": [6, 7.89, false],
	"chain_pull_windup": [5, 10.42, false],
	"chain_pull_active": [2, 20.0, false],
	"chain_pull_recovery": [5, 8.33, false],
	"light_hit": [2, 12.0, false],
	"stagger": [4, 8.0, false],
	"hurt": [3, 12.0, false],
	"death": [6, 8.0, false],
}


func _initialize() -> void:
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	sprite_frames.remove_animation(&"default")
	for animation_name: String in ANIMATIONS:
		var definition: Array = ANIMATIONS[animation_name] as Array
		var frame_count: int = int(definition[0])
		var animation_id: StringName = StringName(animation_name)
		sprite_frames.add_animation(animation_id)
		sprite_frames.set_animation_speed(animation_id, float(definition[1]))
		sprite_frames.set_animation_loop(animation_id, bool(definition[2]))
		for frame_index: int in range(frame_count):
			var frame_path: String = "%s/%s/%s_%02d.png" % [
				SPRITE_ROOT, animation_name, animation_name, frame_index + 1,
			]
			var texture: Texture2D = load(frame_path) as Texture2D
			if texture == null:
				push_error("Missing imported Bellchain frame: %s" % frame_path)
				quit(1)
				return
			sprite_frames.add_frame(animation_id, texture)
	var output_directory: String = OUTPUT_PATH.get_base_dir()
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(output_directory)
	)
	if directory_error != OK:
		push_error("Unable to create %s: %s" % [output_directory, error_string(directory_error)])
		quit(1)
		return
	var save_error: Error = ResourceSaver.save(sprite_frames, OUTPUT_PATH)
	if save_error != OK:
		push_error("Unable to save SpriteFrames: %s" % error_string(save_error))
		quit(1)
		return
	print("CH3 BELLCHAIN SPRITEFRAMES | PASS animations=%d frames=%d" % [ANIMATIONS.size(), _total_frames()])
	quit(0)


func _total_frames() -> int:
	var total: int = 0
	for definition_variant: Variant in ANIMATIONS.values():
		var definition: Array = definition_variant as Array
		total += int(definition[0])
	return total
