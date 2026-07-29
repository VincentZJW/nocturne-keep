extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons"
const DEFINITIONS: Dictionary[StringName, Dictionary] = {
	&"ossuary_penitent": {
		&"summon_telegraph": [4, 10.0, false], &"rise": [6, 10.0, false], &"idle": [4, 5.0, true], &"walk": [6, 8.0, true],
		&"claw_windup": [4, 10.0, false], &"claw_active": [2, 14.0, false], &"claw_recovery": [4, 9.0, false],
		&"lunge_windup": [4, 10.0, false], &"lunge_active": [2, 14.0, false], &"lunge_recovery": [4, 9.0, false],
		&"hurt": [3, 12.0, false], &"stagger": [4, 10.0, false], &"death": [6, 9.0, false], &"forced_dissolve": [5, 12.0, false],
	},
	&"choir_husk": {
		&"summon_telegraph": [4, 10.0, false], &"rise": [6, 10.0, false], &"idle": [4, 5.0, true], &"drift": [6, 7.0, true],
		&"aim": [5, 8.0, false], &"shoot": [3, 12.0, false], &"recovery": [4, 8.0, false],
		&"hurt": [3, 12.0, false], &"stagger": [4, 10.0, false], &"death": [6, 9.0, false], &"forced_dissolve": [5, 12.0, false],
	},
}


func _initialize() -> void:
	var total_frames: int = 0
	for actor: StringName in DEFINITIONS:
		var frames: SpriteFrames = SpriteFrames.new()
		frames.remove_animation(&"default")
		var animations: Dictionary = DEFINITIONS[actor]
		for animation: StringName in animations:
			var values: Array = animations[animation]
			var count: int = values[0]
			frames.add_animation(animation)
			frames.set_animation_speed(animation, values[1])
			frames.set_animation_loop(animation, values[2])
			for index: int in range(count):
				var path: String = "%s/%s/sprites/%s/%s_%02d.png" % [ROOT, actor, animation, animation, index + 1]
				var texture: Texture2D = load(path) as Texture2D
				if texture == null:
					push_error("Missing imported summon frame: %s" % path)
					quit(1)
					return
				frames.add_frame(animation, texture)
				total_frames += 1
		var output_dir: String = "%s/%s/animations" % [ROOT, actor]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
		var output: String = "%s/%s_sprite_frames.tres" % [output_dir, actor]
		if ResourceSaver.save(frames, output) != OK:
			push_error("Unable to save %s" % output)
			quit(1)
			return
	print("EDRAN_SUMMON_SPRITE_FRAMES | PASS actors=2 frames=%d" % total_frames)
	quit(0)
