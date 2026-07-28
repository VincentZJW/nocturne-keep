extends SceneTree

const ROOT: String = "res://chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden"
const ANIMATION_ROOT: String = ROOT + "/animations"
const EFFECT_ROOT: String = ROOT + "/effects"
const BODY_OUTPUT: String = ROOT + "/candle_warden_sprite_frames.tres"
const FLAME_OUTPUT: String = ROOT + "/candle_warden_soul_flame_sprite_frames.tres"

const DEFINITIONS: Dictionary[StringName, Array] = {
	&"seated": [2, 3.0, true],
	&"rising": [5, 7.0, false],
	&"idle": [4, 4.0, true],
	&"lantern_idle": [6, 6.0, true],
	&"look_at_player": [3, 7.0, false],
	&"talk": [4, 6.0, true],
	&"talk_emphasis": [4, 7.0, false],
	&"gesture_point": [4, 7.0, false],
	&"gesture_warn": [4, 7.0, false],
	&"offer_key": [4, 7.0, false],
	&"open_door": [5, 6.0, false],
	&"slow_walk": [6, 6.0, true],
	&"raise_lantern": [4, 7.0, false],
	&"turn_away": [4, 7.0, false],
	&"return_to_shadow": [6, 6.0, false],
}


func _initialize() -> void:
	var body: SpriteFrames = SpriteFrames.new()
	body.remove_animation(&"default")
	var total_frames: int = 0
	for animation_name: StringName in DEFINITIONS:
		var definition: Array = DEFINITIONS[animation_name]
		body.add_animation(animation_name)
		body.set_animation_speed(animation_name, float(definition[1]))
		body.set_animation_loop(animation_name, bool(definition[2]))
		for frame_index: int in range(int(definition[0])):
			var path: String = "%s/%s/%s_%02d.png" % [
				ANIMATION_ROOT, animation_name, animation_name, frame_index + 1,
			]
			var texture: Texture2D = load(path) as Texture2D
			if texture == null:
				push_error("Missing Candle Warden frame: %s" % path)
				quit(1)
				return
			body.add_frame(animation_name, texture)
			total_frames += 1
	var body_error: Error = ResourceSaver.save(body, BODY_OUTPUT)
	if body_error != OK:
		push_error("Unable to save Candle Warden SpriteFrames: %s" % error_string(body_error))
		quit(1)
		return

	var flame: SpriteFrames = SpriteFrames.new()
	flame.remove_animation(&"default")
	flame.add_animation(&"soul_flame")
	flame.set_animation_speed(&"soul_flame", 8.0)
	flame.set_animation_loop(&"soul_flame", true)
	for frame_index: int in range(6):
		var flame_path: String = "%s/soul_flame/soul_flame_%02d.png" % [EFFECT_ROOT, frame_index + 1]
		var flame_texture: Texture2D = load(flame_path) as Texture2D
		if flame_texture == null:
			push_error("Missing Candle Warden soul flame: %s" % flame_path)
			quit(1)
			return
		flame.add_frame(&"soul_flame", flame_texture)
	var flame_error: Error = ResourceSaver.save(flame, FLAME_OUTPUT)
	if flame_error != OK:
		push_error("Unable to save Candle Warden flame SpriteFrames: %s" % error_string(flame_error))
		quit(1)
		return
	print("CANDLE_WARDEN_STAGE_3_SPRITE_FRAMES: PASS animations=%d frames=%d flame=6" % [DEFINITIONS.size(), total_frames])
	quit(0)
