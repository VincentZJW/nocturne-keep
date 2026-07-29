extends SceneTree

const ART_SOURCE = preload("res://chapters/chapter_02_silent_court/scripts/tools/generate_chapter_02_enemy_art_v2.gd")
const ROOT: String = "res://chapters/chapter_02_silent_court/assets/enemies"
const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"

const REQUIRED_RUNTIME: Dictionary = {
	"hollow_retainer": [&"idle", &"walk", &"alert", &"attack_single_stab", &"attack_combo", &"hurt", &"death"],
	"court_halberdier": [&"idle", &"walk", &"alert", &"turn", &"attack_thrust", &"attack_sweep", &"attack_shaft_push", &"hurt", &"death"],
	"mourning_armor": [&"idle", &"walk", &"alert", &"turn", &"attack_overhead", &"attack_shoulder_bash", &"attack_heavy_sweep", &"stagger", &"hurt", &"death"],
	"blood_candle_acolyte": [&"idle", &"walk", &"alert", &"attack_cast", &"buff_channel", &"hurt", &"death"],
	"hanging_stalker": [&"hang", &"telegraph", &"drop", &"ground_recovery", &"claw", &"retreat", &"return_to_anchor", &"hurt", &"death"],
}


func _initialize() -> void:
	var errors: Array[String] = []
	var total_frames: int = 0
	for role: String in ART_SOURCE.ROLES:
		var concept: String = "%s/%s/concept_art/%s_formal_concept.png" % [ROOT,role,role]
		var preview: String = "%s/%s/animations/%s_stage1_preview.png" % [ROOT,role,role]
		var archive: String = "%s/%s/reference/deprecated_stage0/%s_stage0_runtime_art.tar.gz" % [ROOT,role,role]
		_require_file(concept,errors)
		_require_file(preview,errors)
		_require_file(archive,errors)
		var resource_path: String = "%s/%s/animations/%s_sprite_frames.tres" % [ROOT,role,role]
		var frames: SpriteFrames = load(resource_path) as SpriteFrames
		if frames == null:
			errors.append("Cannot load %s" % resource_path)
			continue
		var definitions: Dictionary = ART_SOURCE.ANIMATIONS[role] as Dictionary
		for animation: String in definitions:
			var name: StringName = StringName(animation)
			var expected: int = int(definitions[animation])
			if not frames.has_animation(name):
				errors.append("%s missing animation %s" % [role,animation])
				continue
			if frames.get_frame_count(name) != expected:
				errors.append("%s/%s frame count %d != %d" % [role,animation,frames.get_frame_count(name),expected])
			for index: int in range(frames.get_frame_count(name)):
				var texture: Texture2D = frames.get_frame_texture(name,index)
				if texture == null:
					errors.append("%s/%s/%d missing texture" % [role,animation,index])
					continue
				if texture.get_width()!=64 or texture.get_height()!=64:
					errors.append("%s/%s/%d is not 64x64" % [role,animation,index])
				if texture.get_image().get_used_rect().size == Vector2i.ZERO:
					errors.append("%s/%s/%d is transparent" % [role,animation,index])
				total_frames += 1
		for required: StringName in REQUIRED_RUNTIME[role]:
			if not frames.has_animation(required): errors.append("%s lost runtime animation %s" % [role,required])
		var scene_path: String = "res://chapters/chapter_02_silent_court/scenes/enemies/%s.tscn" % role
		var scene: PackedScene = load(scene_path) as PackedScene
		if scene == null:
			errors.append("Cannot load %s" % scene_path)
			continue
		var instance: Node = scene.instantiate()
		var sprite: AnimatedSprite2D = instance.get_node_or_null("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
		if sprite == null or sprite.sprite_frames != frames:
			errors.append("%s scene does not use authoritative SpriteFrames" % role)
		instance.free()
	var level_text: String = FileAccess.get_file_as_string(LEVEL_PATH)
	for role: String in ART_SOURCE.ROLES:
		if level_text.find("scenes/enemies/%s.tscn" % role)<0:
			errors.append("Main Chapter II level does not reference %s" % role)
	if errors.is_empty():
		print("CH2 ENEMY ART STAGE1 TEST | PASS roles=%d frames=%d main=true" % [ART_SOURCE.ROLES.size(),total_frames])
		quit(0)
	else:
		for error: String in errors: push_error(error)
		quit(1)


func _require_file(path: String, errors: Array[String]) -> void:
	if not FileAccess.file_exists(path): errors.append("Missing required file %s" % path)
