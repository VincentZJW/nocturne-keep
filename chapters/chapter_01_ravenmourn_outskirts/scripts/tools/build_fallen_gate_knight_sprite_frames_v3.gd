extends SceneTree

## Adds the production-reference animation families requested by the Fallen Gate
## Knight art contract to the same SpriteFrames resource used by the live Boss.
## Existing gameplay families, timing and frame counts are deliberately preserved.

const ROOT: String = "res://chapters/chapter_01_ravenmourn_outskirts"
const SPRITES: String = ROOT + "/assets/boss/fallen_gate_knight/sprites"
const RESOURCE_PATH: String = ROOT + "/resources/boss/fallen_gate_knight_sprite_frames.tres"

const SUPPLEMENTAL: Dictionary = {
	&"dormant": {&"frames": 4, &"fps": 3.0, &"loop": true},
	&"intro": {&"frames": 6, &"fps": 6.0, &"loop": false},
	&"approach_shielded": {&"frames": 6, &"fps": 7.0, &"loop": true},
	&"shield_hit": {&"frames": 3, &"fps": 12.0, &"loop": false},
	&"shield_bash_windup": {&"frames": 3, &"fps": 6.0, &"loop": false},
	&"shield_bash_active": {&"frames": 2, &"fps": 20.0, &"loop": false},
	&"shield_bash_recovery": {&"frames": 3, &"fps": 8.0, &"loop": false},
	&"sword_slash_windup": {&"frames": 3, &"fps": 7.0, &"loop": false},
	&"sword_slash_active": {&"frames": 2, &"fps": 20.0, &"loop": false},
	&"sword_slash_recovery": {&"frames": 3, &"fps": 9.0, &"loop": false},
	&"thrust_windup": {&"frames": 3, &"fps": 7.0, &"loop": false},
	&"thrust_active": {&"frames": 2, &"fps": 20.0, &"loop": false},
	&"thrust_recovery": {&"frames": 3, &"fps": 9.0, &"loop": false},
	&"heavy_overhead_windup": {&"frames": 3, &"fps": 5.0, &"loop": false},
	&"heavy_overhead_active": {&"frames": 2, &"fps": 16.0, &"loop": false},
	&"heavy_overhead_recovery": {&"frames": 3, &"fps": 7.0, &"loop": false},
	&"light_hit": {&"frames": 2, &"fps": 14.0, &"loop": false},
	&"hurt": {&"frames": 3, &"fps": 12.0, &"loop": false},
	&"death_start": {&"frames": 3, &"fps": 7.0, &"loop": false},
	&"combo_slash": {&"frames": 6, &"fps": 12.0, &"loop": false},
	&"stagger": {&"frames": 4, &"fps": 10.0, &"loop": false},
	# 0.88 s raise, 0.20 s held telegraph, committed downward cut, exact
	# ground-contact release and short recovery. Durations are in 0.1 s units.
	&"shockwave_strike": {
		&"frames": 10, &"fps": 10.0, &"loop": false,
		&"durations": [1.7, 1.7, 1.7, 1.7, 2.0, 1.1, 1.0, 0.8, 1.1, 1.6],
	},
	&"shockwave_strike_shielded": {
		&"frames": 10, &"fps": 10.0, &"loop": false,
		&"durations": [1.7, 1.7, 1.7, 1.7, 2.0, 1.1, 1.0, 0.8, 1.1, 1.6],
	},
}


func _initialize() -> void:
	var frames: SpriteFrames = load(RESOURCE_PATH) as SpriteFrames
	if frames == null:
		push_error("Cannot load Fallen Gate Knight SpriteFrames: %s" % RESOURCE_PATH)
		quit(1)
		return
	var added_frames: int = 0
	for animation_variant: Variant in SUPPLEMENTAL.keys():
		var animation: StringName = animation_variant as StringName
		var definition: Dictionary = SUPPLEMENTAL[animation] as Dictionary
		if frames.has_animation(animation):
			frames.remove_animation(animation)
		frames.add_animation(animation)
		frames.set_animation_speed(animation, float(definition[&"fps"]))
		frames.set_animation_loop(animation, bool(definition[&"loop"]))
		var frame_count: int = int(definition[&"frames"])
		for frame_index: int in range(frame_count):
			var texture_path: String = "%s/%s/%s_%02d.png" % [
				SPRITES, animation, animation, frame_index + 1,
			]
			var texture: Texture2D = load(texture_path) as Texture2D
			if texture == null:
				push_error("Missing Fallen Gate Knight texture: %s" % texture_path)
				quit(1)
				return
			var duration: float = 1.0
			if definition.has(&"durations"):
				var durations: Array = definition[&"durations"] as Array
				duration = float(durations[frame_index])
			frames.add_frame(animation, texture, duration)
			added_frames += 1
	var save_error: Error = ResourceSaver.save(frames, RESOURCE_PATH)
	if save_error != OK:
		push_error("Cannot save Fallen Gate Knight SpriteFrames (%d)" % save_error)
		quit(1)
		return
	print("FALLEN_GATE_KNIGHT_SPRITE_FRAMES_V3: PASS animations=%d added_frames=%d" % [
		frames.get_animation_names().size(), added_frames,
	])
	quit(0)
