extends SceneTree

const ROOT := "res://chapters/chapter_04_drowned_underkeep"
const ACTIONS: Array[String] = [
	"halberd_sweep", "chain_anchor_slam", "prison_hook_drag", "floodgate_charge", "soul_cage_pulse",
	"chainstorm_cleave", "undertow_pull", "drowned_cell_rupture", "soul_shackle", "flooded_judgment",
]


func _initialize() -> void:
	var frames: SpriteFrames = _build_frames()
	if frames == null:
		quit(1)
		return
	var frames_path := "%s/assets/bosses/soul_gaoler_ormund/animations/soul_gaoler_ormund_sprite_frames.tres" % ROOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(frames_path.get_base_dir()))
	if ResourceSaver.save(frames, frames_path) != OK:
		quit(1)
		return
	var config: SoulGaolerOrmundConfig = _make_config()
	var config_path := "%s/resources/bosses/soul_gaoler_ormund_data.tres" % ROOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(config_path.get_base_dir()))
	if ResourceSaver.save(config, config_path) != OK or not _build_scene(config, frames):
		quit(1)
		return
	print("SOUL GAOLER ORMUND RUNTIME | PASS animations=%d hp=%d" % [frames.get_animation_names().size(), config.total_health])
	quit(0)


func _definitions() -> Dictionary:
	var defs: Dictionary = {
		"idle":5,"dormant":4,"intro":6,"idle_p1":5,"walk_p1":6,"turn_p1":4,"light_hit_p1":2,"stagger_p1":5,"phase_transition":8,
		"idle_p2":5,"move_p2":6,"turn_p2":4,"light_hit_p2":2,"stagger_p2":5,"death_start":5,"death_collapse":6,"soul_release":8,
	}
	for action: String in ACTIONS:
		defs["%s_windup" % action]=5
		defs["%s_active" % action]=3
		defs["%s_recovery" % action]=5
	return defs


func _build_frames() -> SpriteFrames:
	var result := SpriteFrames.new()
	result.remove_animation(&"default")
	var defs: Dictionary = _definitions()
	for animation: String in defs:
		var id := StringName(animation)
		result.add_animation(id)
		result.set_animation_speed(id, _speed(animation))
		result.set_animation_loop(id, animation in ["dormant","idle_p1","walk_p1","idle_p2","move_p2"])
		for index: int in range(int(defs[animation])):
			var source_animation: String = "idle_p1" if animation == "idle" else animation
			var path := "%s/assets/bosses/soul_gaoler_ormund/sprites/%s/%s_%02d.png" % [ROOT,source_animation,source_animation,index+1]
			var texture := load(path) as Texture2D
			if texture == null:
				push_error("Missing Boss frame %s" % path)
				return null
			result.add_frame(id,texture)
	return result


func _speed(animation: String) -> float:
	if animation in ["dormant","idle_p1","idle_p2"]: return 4.0
	if animation in ["walk_p1","move_p2"]: return 7.0
	if animation.ends_with("_windup"): return 9.0
	if animation.ends_with("_active"): return 14.0
	if animation.ends_with("_recovery"): return 8.0
	if animation == "phase_transition": return 8.0
	if animation.begins_with("death") or animation == "soul_release": return 8.0
	return 10.0


func _make_config() -> SoulGaolerOrmundConfig:
	var c := SoulGaolerOrmundConfig.new()
	c.display_name=&"Soul Gaoler Ormund"
	c.max_health=560
	c.total_health=560
	c.gravity=1650.0
	c.ground_acceleration=300.0
	c.ground_deceleration=560.0
	c.patrol_half_width=420.0
	c.platform_height_tolerance=180.0
	c.detection_range=520.0
	c.lose_target_range=720.0
	c.attack_range=118.0
	c.patrol_speed=0.0
	c.chase_speed=48.0
	c.knockback_speed=55.0
	c.hurt_duration=0.12
	c.initial_idle_duration=0.0
	return c


func _build_scene(config: SoulGaolerOrmundConfig, frames: SpriteFrames) -> bool:
	var root:=SoulGaolerOrmund.new(); root.name="SoulGaolerOrmund"; root.config=config; root.floor_snap_length=8.0; root.collision_layer=4; root.collision_mask=3; root.z_index=12
	var visual:=Node2D.new(); visual.name="VisualRoot"; root.add_child(visual)
	var sprite:=AnimatedSprite2D.new(); sprite.name="AnimatedSprite2D"; sprite.sprite_frames=frames; sprite.animation=&"dormant"; sprite.autoplay="dormant"; sprite.position=Vector2(0,-92); sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST; visual.add_child(sprite)
	var body:=_shape(Vector2(66,142),Vector2(0,-71)); body.name="CollisionShape2D"; root.add_child(body)
	var health:=HealthComponent.new(); health.name="HealthComponent"; health.max_health=560; root.add_child(health)
	var poise:=Chapter04PoiseComponent.new(); poise.name="PoiseComponent"; poise.max_poise=150; root.add_child(poise)
	var policy:=Chapter04BossDamagePolicy.new(); policy.name="DamagePolicy"; root.add_child(policy)
	var hurtbox:=HurtboxComponent.new(); hurtbox.name="Hurtbox"; hurtbox.collision_layer=16; hurtbox.collision_mask=32; hurtbox.faction=&"enemy"; hurtbox.hit_policy_path=NodePath("../DamagePolicy"); root.add_child(hurtbox)
	var hurt_shape:=_shape(Vector2(76,148),Vector2(0,-74)); hurt_shape.name="CollisionShape2D"; hurtbox.add_child(hurt_shape)
	var facing:=Node2D.new(); facing.name="FacingRoot"; root.add_child(facing)
	var melee:=_hitbox("MeleeHitbox",Vector2(148,72),Vector2(90,-65)); facing.add_child(melee)
	var area:=_hitbox("AreaHitbox",Vector2(260,138),Vector2(0,-68)); root.add_child(area)
	var detection:=Area2D.new(); detection.name="DetectionArea"; detection.collision_layer=128; detection.collision_mask=2; detection.monitorable=false; root.add_child(detection)
	var detect_shape:=CollisionShape2D.new(); detect_shape.name="CollisionShape2D"; var circle:=CircleShape2D.new(); circle.radius=520.0; detect_shape.shape=circle; detection.add_child(detect_shape)
	var wall:=RayCast2D.new(); wall.name="WallCheck"; wall.position=Vector2(0,-35); wall.target_position=Vector2(-42,0); wall.collision_mask=1; wall.enabled=true; root.add_child(wall)
	var floor:=RayCast2D.new(); floor.name="FloorCheck"; floor.position=Vector2(-34,-5); floor.target_position=Vector2(0,48); floor.collision_mask=1; floor.enabled=true; root.add_child(floor)
	_set_owner_recursive(root,root)
	var packed:=PackedScene.new()
	if packed.pack(root)!=OK: root.free(); return false
	var path := "%s/scenes/bosses/soul_gaoler_ormund.tscn" % ROOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var ok: bool=ResourceSaver.save(packed,path)==OK
	root.free()
	return ok


func _shape(size:Vector2,position:Vector2)->CollisionShape2D:
	var node:=CollisionShape2D.new(); var shape:=RectangleShape2D.new(); shape.size=size; node.shape=shape; node.position=position; return node


func _hitbox(node_name:String,size:Vector2,position:Vector2)->HitboxComponent:
	var h:=HitboxComponent.new(); h.name=node_name; h.position=position; h.collision_layer=64; h.collision_mask=8; h.faction=&"enemy"; h.monitoring=false; h.monitorable=false
	var shape:=_shape(size,Vector2.ZERO); shape.name="CollisionShape2D"; shape.disabled=true; h.add_child(shape); return h


func _set_owner_recursive(node:Node,scene_owner:Node)->void:
	for child:Node in node.get_children():
		child.owner=scene_owner
		_set_owner_recursive(child,scene_owner)
