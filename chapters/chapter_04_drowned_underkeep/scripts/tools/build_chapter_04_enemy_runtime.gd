extends SceneTree

## Builds persistent SpriteFrames, tuning Resources and PackedScenes for the seven
## normal Chapter IV enemies plus the single Executioner elite.

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep"
const ROLES: Array[String] = [
	"drowned_gaoler", "chainbound_convict", "mire_harpooner",
	"sunken_shield_penitent", "mirefin_raider", "bog_toad", "sewer_maw",
	"underkeep_executioner",
]
const DISPLAY_NAMES: Dictionary[String, String] = {
	"drowned_gaoler": "Drowned Gaoler",
	"chainbound_convict": "Chainbound Convict",
	"mire_harpooner": "Mire Harpooner",
	"sunken_shield_penitent": "Sunken Shield Penitent",
	"mirefin_raider": "Mirefin Raider",
	"bog_toad": "Bog Toad",
	"sewer_maw": "Sewer Maw",
	"underkeep_executioner": "Underkeep Executioner",
}
const ACTIONS: Dictionary[String, Array] = {
	"drowned_gaoler": ["jailer_cleave", "hook_drag", "shoulder_check"],
	"chainbound_convict": ["chain_sweep", "shackle_slam", "drag"],
	"mire_harpooner": ["harpoon_shot", "hooked_harpoon", "close_thrust"],
	"sunken_shield_penitent": ["shield_bash", "rusted_thrust", "shield_crush"],
	"mirefin_raider": ["claw_swipe", "mire_lunge", "fin_bite"],
	"bog_toad": ["leap_crush", "mud_burst", "tongue_lash"],
	"sewer_maw": ["sewer_bite", "ambush", "latch"],
	"underkeep_executioner": ["executioner_cleave", "chain_reaper", "gallows_slam"],
}


func _initialize() -> void:
	if not _build_projectile_scene():
		quit(1)
		return
	for role: String in ROLES:
		var frames: SpriteFrames = _build_sprite_frames(role)
		if frames == null:
			quit(1)
			return
		var frames_path: String = "%s/assets/enemies/%s/animations/%s_sprite_frames.tres" % [ROOT, role, role]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(frames_path.get_base_dir()))
		if ResourceSaver.save(frames, frames_path) != OK:
			push_error("Cannot save %s" % frames_path)
			quit(1)
			return
		var config: Chapter04EnemyConfig = _make_config(role)
		var config_path: String = "%s/resources/enemies/%s_data.tres" % [ROOT, role]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(config_path.get_base_dir()))
		if ResourceSaver.save(config, config_path) != OK:
			push_error("Cannot save %s" % config_path)
			quit(1)
			return
		var loot: LootDropProfile = LootDropProfile.new()
		loot.enemy_type = StringName(DISPLAY_NAMES[role].replace(" ", ""))
		loot.coin_min = 3 if role != "underkeep_executioner" else 8
		loot.coin_max = 6 if role != "underkeep_executioner" else 12
		var loot_path: String = "%s/resources/enemies/%s_loot.tres" % [ROOT, role]
		if ResourceSaver.save(loot, loot_path) != OK:
			push_error("Cannot save %s" % loot_path)
			quit(1)
			return
		if not _build_enemy_scene(role, config, frames, loot):
			quit(1)
			return
	print("CH4 ENEMY RUNTIME BUILD | PASS roles=%d" % ROLES.size())
	quit(0)


func _definitions(role: String) -> Dictionary:
	var result: Dictionary = {
		"idle": 4, "walk": 6, "alert": 3, "turn": 3,
		"light_hit": 2, "stagger": 4, "hurt": 3, "death": 6,
	}
	if role == "sewer_maw": result["hidden"] = 4
	if role == "sunken_shield_penitent": result["guard_break"] = 4
	for action: String in ACTIONS[role]:
		result["%s_windup" % action] = 5
		result["%s_active" % action] = 2
		result["%s_recovery" % action] = 5
	return result


func _build_sprite_frames(role: String) -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation: String in _definitions(role):
		var animation_id: StringName = StringName(animation)
		frames.add_animation(animation_id)
		frames.set_animation_speed(animation_id, _animation_speed(animation))
		frames.set_animation_loop(animation_id, animation in ["idle", "walk", "hidden"])
		var count: int = int(_definitions(role)[animation])
		for index: int in range(count):
			var path: String = "%s/assets/enemies/%s/sprites/%s/%s_%02d.png" % [ROOT, role, animation, animation, index + 1]
			var texture: Texture2D = load(path) as Texture2D
			if texture == null:
				push_error("Missing imported texture %s" % path)
				return null
			frames.add_frame(animation_id, texture)
	return frames


func _animation_speed(animation: String) -> float:
	if animation == "idle" or animation == "hidden": return 4.0
	if animation == "walk": return 8.0
	if animation.ends_with("_windup"): return 10.0
	if animation.ends_with("_active"): return 14.0
	if animation.ends_with("_recovery"): return 8.0
	if animation == "death": return 8.0
	return 10.0


func _make_config(role: String) -> Chapter04EnemyConfig:
	var c: Chapter04EnemyConfig = Chapter04EnemyConfig.new()
	c.display_name = StringName(DISPLAY_NAMES[role])
	c.ground_acceleration = 330.0
	c.ground_deceleration = 540.0
	c.patrol_half_width = 138.0
	c.platform_height_tolerance = 130.0
	c.lose_target_range = 360.0
	c.initial_idle_duration = 0.6
	c.patrol_turn_pause = 0.26
	c.normal_attack_poise_damage = 14
	c.dash_attack_poise_damage = 28
	var actions: Array = ACTIONS[role]
	c.primary_action = StringName(actions[0])
	c.secondary_action = StringName(actions[1])
	c.special_action = StringName(actions[2])
	match role:
		"drowned_gaoler":
			c.archetype=Chapter04EnemyConfig.Archetype.DROWNED_GAOLER; c.chapter_max_health=104; c.max_health=100; c.max_poise=44
			c.patrol_speed=30.0; c.chase_speed=56.0; c.detection_range=225.0; c.attack_range=56.0
			c.attack_damage=12; c.attack_windup=0.40; c.attack_active_duration=0.14; c.attack_recovery=0.50
			c.secondary_damage=11; c.secondary_range=78.0; c.secondary_windup=0.48; c.secondary_active_duration=0.12; c.secondary_recovery=0.62; c.pull_strength=62.0
			c.special_damage=10; c.special_range=50.0; c.special_windup=0.44; c.special_active_duration=0.16; c.special_recovery=0.66; c.special_motion_speed=115.0
		"chainbound_convict":
			c.archetype=Chapter04EnemyConfig.Archetype.CHAINBOUND_CONVICT; c.chapter_max_health=152; c.max_health=100; c.max_poise=92
			c.patrol_speed=20.0; c.chase_speed=36.0; c.detection_range=220.0; c.attack_range=72.0
			c.attack_damage=16; c.attack_windup=0.66; c.attack_active_duration=0.18; c.attack_recovery=0.90
			c.secondary_damage=19; c.secondary_range=60.0; c.secondary_windup=0.84; c.secondary_active_duration=0.18; c.secondary_recovery=1.10
			c.special_damage=11; c.special_range=102.0; c.special_windup=0.68; c.special_active_duration=0.14; c.special_recovery=0.94; c.pull_strength=70.0; c.protected_active_frames=true
		"mire_harpooner":
			c.archetype=Chapter04EnemyConfig.Archetype.MIRE_HARPOONER; c.chapter_max_health=96; c.max_health=96; c.max_poise=38
			c.patrol_speed=24.0; c.chase_speed=40.0; c.detection_range=290.0; c.attack_range=235.0
			c.attack_damage=13; c.attack_windup=0.58; c.attack_active_duration=0.10; c.attack_recovery=0.72
			c.secondary_damage=11; c.secondary_range=245.0; c.secondary_windup=0.72; c.secondary_active_duration=0.10; c.secondary_recovery=0.88; c.pull_strength=54.0
			c.special_damage=10; c.special_range=48.0; c.special_windup=0.42; c.special_active_duration=0.13; c.special_recovery=0.62
			c.projectile_speed=250.0; c.projectile_lifetime=3.0
		"sunken_shield_penitent":
			c.archetype=Chapter04EnemyConfig.Archetype.SUNKEN_SHIELD_PENITENT; c.chapter_max_health=132; c.max_health=100; c.max_poise=70; c.shield_max_health=72
			c.patrol_speed=22.0; c.chase_speed=35.0; c.detection_range=215.0; c.attack_range=50.0
			c.attack_damage=14; c.attack_windup=0.48; c.attack_active_duration=0.15; c.attack_recovery=0.70
			c.secondary_damage=14; c.secondary_range=72.0; c.secondary_windup=0.58; c.secondary_active_duration=0.13; c.secondary_recovery=0.78
			c.special_damage=17; c.special_range=54.0; c.special_windup=0.72; c.special_active_duration=0.18; c.special_recovery=0.98; c.special_motion_speed=90.0; c.guard_break_duration=0.72
		"mirefin_raider":
			c.archetype=Chapter04EnemyConfig.Archetype.MIREFIN_RAIDER; c.chapter_max_health=116; c.max_health=100; c.max_poise=50; c.amphibious=true
			c.patrol_speed=42.0; c.chase_speed=76.0; c.detection_range=235.0; c.attack_range=48.0
			c.attack_damage=13; c.attack_windup=0.34; c.attack_active_duration=0.13; c.attack_recovery=0.48
			c.secondary_damage=16; c.secondary_range=115.0; c.secondary_windup=0.48; c.secondary_active_duration=0.18; c.secondary_recovery=0.78; c.secondary_motion_speed=220.0
			c.special_damage=14; c.special_range=64.0; c.special_windup=0.40; c.special_active_duration=0.16; c.special_recovery=0.64; c.special_motion_speed=145.0
		"bog_toad":
			c.archetype=Chapter04EnemyConfig.Archetype.BOG_TOAD; c.chapter_max_health=142; c.max_health=100; c.max_poise=76
			c.patrol_speed=18.0; c.chase_speed=32.0; c.detection_range=245.0; c.attack_range=105.0
			c.attack_damage=17; c.attack_windup=0.70; c.attack_active_duration=0.22; c.attack_recovery=0.96; c.primary_motion_speed=195.0
			c.secondary_damage=11; c.secondary_range=190.0; c.secondary_windup=0.62; c.secondary_active_duration=0.12; c.secondary_recovery=0.82
			c.special_damage=13; c.special_range=180.0; c.special_windup=0.56; c.special_active_duration=0.12; c.special_recovery=0.80; c.pull_strength=48.0; c.projectile_speed=205.0
		"sewer_maw":
			c.archetype=Chapter04EnemyConfig.Archetype.SEWER_MAW; c.chapter_max_health=82; c.max_health=82; c.max_poise=26; c.starts_hidden=true; c.hidden_duration=0.48
			c.patrol_speed=34.0; c.chase_speed=68.0; c.detection_range=175.0; c.attack_range=46.0
			c.attack_damage=10; c.attack_windup=0.34; c.attack_active_duration=0.12; c.attack_recovery=0.50
			c.secondary_damage=14; c.secondary_range=92.0; c.secondary_windup=0.46; c.secondary_active_duration=0.18; c.secondary_recovery=0.82; c.secondary_motion_speed=210.0
			c.special_damage=8; c.special_range=45.0; c.special_windup=0.38; c.special_active_duration=0.20; c.special_recovery=0.72; c.pull_strength=36.0
		"underkeep_executioner":
			c.archetype=Chapter04EnemyConfig.Archetype.UNDERKEEP_EXECUTIONER; c.chapter_max_health=244; c.max_health=100; c.max_poise=126
			c.patrol_speed=18.0; c.chase_speed=34.0; c.detection_range=250.0; c.attack_range=88.0
			c.attack_damage=20; c.attack_windup=0.68; c.attack_active_duration=0.18; c.attack_recovery=1.00
			c.secondary_damage=18; c.secondary_range=118.0; c.secondary_windup=0.76; c.secondary_active_duration=0.17; c.secondary_recovery=1.08; c.pull_strength=76.0
			c.special_damage=23; c.special_range=70.0; c.special_windup=0.82; c.special_active_duration=0.20; c.special_recovery=1.18; c.protected_active_frames=true
			c.stagger_duration=0.82; c.turn_duration=0.38
	return c


func _build_enemy_scene(role: String, config: Chapter04EnemyConfig, frames: SpriteFrames, loot: LootDropProfile) -> bool:
	var root: Chapter04Enemy=Chapter04Enemy.new(); root.name=_pascal(role); root.config=config; root.floor_snap_length=6.0; root.collision_layer=4; root.collision_mask=3; root.z_index=10
	root.projectile_scene=load("%s/scenes/projectiles/chapter_04_enemy_projectile.tscn" % ROOT) as PackedScene
	var visual: Node2D=Node2D.new(); visual.name="VisualRoot"; root.add_child(visual)
	var sprite: AnimatedSprite2D=AnimatedSprite2D.new(); sprite.name="AnimatedSprite2D"; sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST; sprite.position=Vector2(0,-38); sprite.sprite_frames=frames; sprite.animation=&"idle"; sprite.autoplay="idle"; visual.add_child(sprite)
	var body_size: Vector2=Vector2(34,60) if role not in ["chainbound_convict","bog_toad","underkeep_executioner"] else Vector2(50,64)
	var body: CollisionShape2D=_shape_node(body_size,Vector2(0,-body_size.y*0.5)); body.name="CollisionShape2D"; root.add_child(body)
	var health: HealthComponent=HealthComponent.new(); health.name="HealthComponent"; root.add_child(health)
	var poise: Chapter04PoiseComponent=Chapter04PoiseComponent.new(); poise.name="PoiseComponent"; poise.max_poise=config.max_poise; root.add_child(poise)
	var hurtbox: HurtboxComponent=HurtboxComponent.new(); hurtbox.name="Hurtbox"; hurtbox.collision_layer=16; hurtbox.collision_mask=32; hurtbox.faction=&"enemy"; root.add_child(hurtbox)
	var hurt_shape: CollisionShape2D=_shape_node(body_size+Vector2(6,4),Vector2(0,-body_size.y*0.5)); hurt_shape.name="CollisionShape2D"; hurtbox.add_child(hurt_shape)
	var shield: ShieldComponent
	if role=="sunken_shield_penitent":
		shield=ShieldComponent.new(); shield.name="ShieldComponent"; shield.shield_max_health=config.shield_max_health; root.add_child(shield); hurtbox.hit_policy_path=NodePath("../ShieldComponent"); root.shield_component_path=NodePath("ShieldComponent")
		var shield_sprite: AnimatedSprite2D=AnimatedSprite2D.new(); shield_sprite.name="ShieldVisual"; shield_sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST; shield_sprite.position=Vector2(-15,-37); shield_sprite.scale=Vector2(0.78,0.78); shield_sprite.sprite_frames=_build_shield_frames(); shield_sprite.animation=&"intact"; shield_sprite.autoplay="intact"; visual.add_child(shield_sprite); root.shield_visual_path=NodePath("VisualRoot/ShieldVisual")
	var facing: Node2D=Node2D.new(); facing.name="FacingRoot"; root.add_child(facing)
	var primary: HitboxComponent=_hitbox("PrimaryHitbox",Vector2(62,28),Vector2(42,-29)); facing.add_child(primary)
	var secondary: HitboxComponent=_hitbox("SecondaryHitbox",Vector2(88,32),Vector2(55,-28)); facing.add_child(secondary)
	var detection: Area2D=Area2D.new(); detection.name="DetectionArea"; detection.collision_layer=128; detection.collision_mask=2; detection.monitorable=false; root.add_child(detection)
	var detection_shape: CollisionShape2D=CollisionShape2D.new(); detection_shape.name="CollisionShape2D"; var circle: CircleShape2D=CircleShape2D.new(); circle.radius=config.detection_range; detection_shape.shape=circle; detection.add_child(detection_shape)
	var wall: RayCast2D=RayCast2D.new(); wall.name="WallCheck"; wall.position=Vector2(0,-22); wall.target_position=Vector2(-28,0); wall.collision_mask=1; wall.enabled=true; root.add_child(wall)
	var floor: RayCast2D=RayCast2D.new(); floor.name="FloorCheck"; floor.position=Vector2(-24,-4); floor.target_position=Vector2(0,34); floor.collision_mask=1; floor.enabled=true; root.add_child(floor)
	var loot_drop: LootDropComponent=LootDropComponent.new(); loot_drop.name="LootDropComponent"; loot_drop.profile=loot; loot_drop.dynamic_profile=load("res://resources/items/loot/default_dynamic_loot_profile.tres") as DynamicLootProfile; root.add_child(loot_drop)
	_set_owner_recursive(root,root)
	var packed: PackedScene=PackedScene.new(); if packed.pack(root)!=OK: root.free(); return false
	var path: String="%s/scenes/enemies/%s.tscn" % [ROOT,role]; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var ok: bool=ResourceSaver.save(packed,path)==OK; root.free(); return ok


func _build_shield_frames() -> SpriteFrames:
	var result: SpriteFrames=SpriteFrames.new(); result.remove_animation(&"default")
	for state: String in ["intact","cracked","critical"]:
		var id: StringName=StringName(state); result.add_animation(id); result.set_animation_speed(id,1.0); result.set_animation_loop(id,true)
		result.add_frame(id,load("%s/assets/enemies/sunken_shield_penitent/shield/%s.png" % [ROOT,state]) as Texture2D)
	return result


func _build_projectile_scene() -> bool:
	var root: Chapter04EnemyProjectile=Chapter04EnemyProjectile.new(); root.name="Chapter04EnemyProjectile"; root.collision_layer=0; root.collision_mask=1; root.z_index=16
	var visual: Polygon2D=Polygon2D.new(); visual.name="Visual"; visual.polygon=PackedVector2Array([Vector2(-9,-3),Vector2(10,0),Vector2(-9,3)]); visual.color=Color("a8b8b8"); root.add_child(visual)
	var world_shape: CollisionShape2D=_shape_node(Vector2(19,7),Vector2.ZERO); world_shape.name="WorldCollisionShape2D"; root.add_child(world_shape)
	var hitbox: HitboxComponent=HitboxComponent.new(); hitbox.name="Hitbox"; hitbox.collision_layer=64; hitbox.collision_mask=8; hitbox.faction=&"enemy"; root.add_child(hitbox)
	var hit_shape: CollisionShape2D=_shape_node(Vector2(19,7),Vector2.ZERO); hit_shape.name="CollisionShape2D"; hitbox.add_child(hit_shape)
	_set_owner_recursive(root,root); var packed: PackedScene=PackedScene.new(); if packed.pack(root)!=OK: root.free(); return false
	var path: String="%s/scenes/projectiles/chapter_04_enemy_projectile.tscn" % ROOT; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir())); var ok: bool=ResourceSaver.save(packed,path)==OK; root.free(); return ok


func _shape_node(size: Vector2, position: Vector2) -> CollisionShape2D:
	var node: CollisionShape2D=CollisionShape2D.new(); var shape: RectangleShape2D=RectangleShape2D.new(); shape.size=size; node.shape=shape; node.position=position; return node


func _hitbox(node_name: String, size: Vector2, position: Vector2) -> HitboxComponent:
	var hitbox: HitboxComponent=HitboxComponent.new(); hitbox.name=node_name; hitbox.position=position; hitbox.collision_layer=64; hitbox.collision_mask=8; hitbox.faction=&"enemy"; hitbox.monitoring=false; hitbox.monitorable=false
	var shape: CollisionShape2D=_shape_node(size,Vector2.ZERO); shape.name="CollisionShape2D"; shape.disabled=true; hitbox.add_child(shape); return hitbox


func _set_owner_recursive(node: Node, scene_owner: Node) -> void:
	for child: Node in node.get_children(): child.owner=scene_owner; _set_owner_recursive(child,scene_owner)


func _pascal(value: String) -> String:
	var result: String = ""
	for word: String in value.split("_"):
		result += word.capitalize().replace(" ", "")
	return result
