extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const ROLES: Array[String] = [
	"censer_executioner", "silent_chorister", "stained_glass_seraph",
	"confessional_wraith", "thirteenth_scribe",
]
const DISPLAY_NAMES: Dictionary = {
	"censer_executioner": "Censer Executioner",
	"silent_chorister": "Silent Chorister",
	"stained_glass_seraph": "Stained Glass Seraph",
	"confessional_wraith": "Confessional Wraith",
	"thirteenth_scribe": "Thirteenth Scribe",
}


func _initialize() -> void:
	if not _build_projectile_scene() or not _build_field_scene():
		quit(1)
		return
	for role: String in ROLES:
		var config: Chapter03SpecialistConfig = _make_config(role)
		var config_path: String = "%s/resources/enemies/%s_data.tres" % [ROOT, role]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(config_path.get_base_dir()))
		if ResourceSaver.save(config, config_path) != OK:
			push_error("Cannot save %s" % config_path)
			quit(1)
			return
		var loot: LootDropProfile = LootDropProfile.new()
		loot.enemy_type = StringName(DISPLAY_NAMES[role].replace(" ", ""))
		loot.coin_min = 2
		loot.coin_max = 5 if role in ["censer_executioner", "thirteenth_scribe"] else 4
		var loot_path: String = "%s/resources/enemies/%s_loot.tres" % [ROOT, role]
		if ResourceSaver.save(loot, loot_path) != OK:
			push_error("Cannot save %s" % loot_path)
			quit(1)
			return
		var saved_config: Chapter03SpecialistConfig = load(config_path) as Chapter03SpecialistConfig
		var saved_loot: LootDropProfile = load(loot_path) as LootDropProfile
		if saved_config == null or saved_loot == null or not _build_enemy_scene(role, saved_config, saved_loot):
			quit(1)
			return
	print("CH3 PHASE2B-2F SCENES | PASS roles=5")
	quit(0)


func _make_config(role: String) -> Chapter03SpecialistConfig:
	var c: Chapter03SpecialistConfig = Chapter03SpecialistConfig.new()
	c.display_name = StringName(DISPLAY_NAMES[role])
	c.ground_acceleration = 330.0
	c.ground_deceleration = 500.0
	c.patrol_half_width = 132.0
	c.platform_height_tolerance = 120.0
	c.lose_target_range = 330.0
	c.initial_idle_duration = 0.55
	c.patrol_turn_pause = 0.28
	match role:
		"censer_executioner":
			c.archetype = Chapter03SpecialistConfig.Archetype.CENSER_EXECUTIONER
			c.chapter_max_health = 126; c.max_health = 100; c.max_poise = 82
			c.patrol_speed = 25.0; c.chase_speed = 46.0; c.detection_range = 225.0
			c.attack_range = 74.0; c.primary_action = &"primary"; c.attack_damage = 14
			c.attack_windup = 0.66; c.attack_active_duration = 0.18; c.attack_recovery = 0.90
			c.secondary_action = &"overhead_crush"; c.secondary_damage = 17; c.secondary_range = 55.0
			c.secondary_windup = 0.82; c.secondary_active_duration = 0.16; c.secondary_recovery = 1.05
			c.special_action = &"smoke_release"; c.special_damage = 4; c.special_range = 115.0
			c.special_windup = 0.72; c.special_recovery = 0.85; c.special_duration = 2.0
			c.protected_active_frames = true; c.stagger_duration = 0.78; c.turn_duration = 0.34
		"silent_chorister":
			c.archetype = Chapter03SpecialistConfig.Archetype.SILENT_CHORISTER
			c.chapter_max_health = 84; c.max_health = 84; c.max_poise = 36; c.airborne = true; c.gravity = 0.0
			c.patrol_speed = 34.0; c.chase_speed = 52.0; c.detection_range = 275.0; c.attack_range = 205.0
			c.primary_action = &"silent_wave"; c.attack_damage = 10; c.attack_windup = 0.55; c.attack_active_duration = 0.10; c.attack_recovery = 0.64
			c.secondary_action = &"crescent_hymn"; c.secondary_damage = 12; c.secondary_range = 240.0; c.secondary_windup = 0.68
			c.special_action = &"hush_field"; c.special_damage = 0; c.special_range = 190.0; c.special_windup = 0.70; c.special_duration = 2.5; c.support_multiplier = 0.65
			c.projectile_speed = 205.0; c.hover_height = 92.0; c.hover_amplitude = 5.0
		"stained_glass_seraph":
			c.archetype = Chapter03SpecialistConfig.Archetype.STAINED_GLASS_SERAPH
			c.chapter_max_health = 76; c.max_health = 76; c.max_poise = 30; c.airborne = true; c.gravity = 0.0
			c.patrol_speed = 46.0; c.chase_speed = 72.0; c.detection_range = 285.0; c.attack_range = 220.0
			c.primary_action = &"shard_volley"; c.attack_damage = 9; c.attack_windup = 0.58; c.attack_active_duration = 0.12; c.attack_recovery = 0.68
			c.secondary_action = &"dive"; c.secondary_damage = 13; c.secondary_range = 180.0; c.secondary_windup = 0.60; c.secondary_active_duration = 0.22; c.secondary_recovery = 0.70
			c.special_action = &"shatter_burst"; c.special_damage = 8; c.special_range = 62.0; c.special_windup = 0.62; c.special_active_duration = 0.12
			c.projectile_speed = 235.0; c.hover_height = 112.0; c.hover_amplitude = 8.0
		"confessional_wraith":
			c.archetype = Chapter03SpecialistConfig.Archetype.CONFESSIONAL_WRAITH
			c.chapter_max_health = 82; c.max_health = 82; c.max_poise = 38
			c.patrol_speed = 30.0; c.chase_speed = 62.0; c.detection_range = 220.0; c.attack_range = 58.0
			c.primary_action = &"emerging_slash"; c.attack_damage = 12; c.attack_windup = 0.44; c.attack_active_duration = 0.12; c.attack_recovery = 0.58
			c.secondary_action = &"spectral_dash"; c.secondary_damage = 11; c.secondary_range = 130.0; c.secondary_windup = 0.52; c.secondary_active_duration = 0.18; c.secondary_recovery = 0.72
			c.special_action = &"confession_scream"; c.special_damage = 10; c.special_range = 75.0; c.special_windup = 0.68; c.special_active_duration = 0.14
			c.starts_hidden = true; c.hidden_duration = 0.8
		"thirteenth_scribe":
			c.archetype = Chapter03SpecialistConfig.Archetype.THIRTEENTH_SCRIBE
			c.chapter_max_health = 98; c.max_health = 98; c.max_poise = 46
			c.patrol_speed = 28.0; c.chase_speed = 48.0; c.detection_range = 270.0; c.attack_range = 210.0
			c.primary_action = &"ink_lance"; c.attack_damage = 10; c.attack_windup = 0.52; c.attack_active_duration = 0.10; c.attack_recovery = 0.62
			c.secondary_action = &"binding_script"; c.secondary_damage = 8; c.secondary_range = 190.0; c.secondary_windup = 0.58; c.secondary_recovery = 0.72; c.secondary_cooldown = 3.0
			c.special_action = &"thirteenth_seal"; c.special_damage = 13; c.special_range = 220.0; c.special_windup = 0.82; c.special_active_duration = 0.10; c.special_recovery = 0.82; c.special_duration = 1.05
			c.projectile_speed = 220.0; c.movement_slow_multiplier = 0.8; c.movement_slow_duration = 1.0; c.ward_cooldown = 4.0
	return c


func _build_enemy_scene(role: String, config: Chapter03SpecialistConfig, loot_profile: LootDropProfile) -> bool:
	var root: Chapter03SpecialistEnemy = Chapter03SpecialistEnemy.new()
	root.name = _pascal(role)
	root.config = config
	root.floor_snap_length = 6.0
	root.collision_layer = 4
	root.collision_mask = 3
	root.projectile_scene = load("%s/scenes/projectiles/chapter_03_enemy_projectile.tscn" % ROOT) as PackedScene
	root.field_scene = load("%s/scenes/projectiles/chapter_03_timed_field.tscn" % ROOT) as PackedScene
	var visual: Node2D = Node2D.new(); visual.name = "VisualRoot"; root.add_child(visual)
	var sprite: AnimatedSprite2D = AnimatedSprite2D.new(); sprite.name = "AnimatedSprite2D"; sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.sprite_frames = load("%s/assets/enemies/%s/animations/%s_sprite_frames.tres" % [ROOT, role, role]) as SpriteFrames
	sprite.animation = &"idle"; sprite.autoplay = "idle"; visual.add_child(sprite)
	var body_shape: CollisionShape2D = _shape_node(Vector2(26, 50), Vector2(0, 5)); body_shape.name = "CollisionShape2D"; root.add_child(body_shape)
	var health: HealthComponent = HealthComponent.new(); health.name = "HealthComponent"; root.add_child(health)
	var poise: Chapter03PoiseComponent = Chapter03PoiseComponent.new(); poise.name = "PoiseComponent"; poise.max_poise = config.max_poise; root.add_child(poise)
	var hurtbox: HurtboxComponent = HurtboxComponent.new(); hurtbox.name = "Hurtbox"; hurtbox.collision_layer = 16; hurtbox.collision_mask = 32; hurtbox.faction = &"enemy"; root.add_child(hurtbox)
	var hurt_shape: CollisionShape2D = _shape_node(Vector2(30, 52), Vector2(0, 5)); hurt_shape.name = "CollisionShape2D"; hurtbox.add_child(hurt_shape)
	if role == "thirteenth_scribe":
		var policy: Chapter03ScribeWardPolicy = Chapter03ScribeWardPolicy.new(); policy.name = "WardPolicy"; root.add_child(policy)
		hurtbox.hit_policy_path = NodePath("../WardPolicy")
		root.ward_policy_path = NodePath("WardPolicy")
	var facing: Node2D = Node2D.new(); facing.name = "FacingRoot"; root.add_child(facing)
	var primary: HitboxComponent = _hitbox("PrimaryHitbox", Vector2(44, 18), Vector2(35, -2)); facing.add_child(primary)
	var secondary: HitboxComponent = _hitbox("SecondaryHitbox", Vector2(58, 20), Vector2(43, -1)); facing.add_child(secondary)
	var detection: Area2D = Area2D.new(); detection.name = "DetectionArea"; detection.collision_layer = 128; detection.collision_mask = 2; detection.monitorable = false; root.add_child(detection)
	var detect_shape: CollisionShape2D = CollisionShape2D.new(); detect_shape.name = "CollisionShape2D"; var circle: CircleShape2D = CircleShape2D.new(); circle.radius = config.detection_range; detect_shape.shape = circle; detection.add_child(detect_shape)
	var wall: RayCast2D = RayCast2D.new(); wall.name = "WallCheck"; wall.position = Vector2(0, 4); wall.target_position = Vector2(-22, 0); wall.collision_mask = 1; wall.enabled = true; root.add_child(wall)
	var floor: RayCast2D = RayCast2D.new(); floor.name = "FloorCheck"; floor.position = Vector2(-19, 20); floor.target_position = Vector2(0, 28); floor.collision_mask = 1; floor.enabled = true; root.add_child(floor)
	var loot_drop: LootDropComponent = LootDropComponent.new(); loot_drop.name = "LootDropComponent"; loot_drop.profile = loot_profile; loot_drop.dynamic_profile = load("res://resources/items/loot/default_dynamic_loot_profile.tres") as DynamicLootProfile; root.add_child(loot_drop)
	_set_owner_recursive(root, root)
	var packed: PackedScene = PackedScene.new()
	if packed.pack(root) != OK:
		root.free()
		return false
	var path: String = "%s/scenes/enemies/%s.tscn" % [ROOT, role]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var saved: bool = ResourceSaver.save(packed, path) == OK
	root.free()
	return saved


func _build_projectile_scene() -> bool:
	var root: Chapter03EnemyProjectile = Chapter03EnemyProjectile.new(); root.name = "Chapter03EnemyProjectile"; root.collision_layer = 0; root.collision_mask = 1
	var visual: Polygon2D = Polygon2D.new(); visual.name = "Visual"; visual.polygon = PackedVector2Array([Vector2(-7,-2), Vector2(8,0), Vector2(-7,2)]); visual.color = Color("b9d9d6"); root.add_child(visual)
	var world_shape: CollisionShape2D = _shape_node(Vector2(15, 6), Vector2.ZERO); world_shape.name = "WorldCollisionShape2D"; root.add_child(world_shape)
	var hitbox: HitboxComponent = HitboxComponent.new(); hitbox.name = "Hitbox"; hitbox.collision_layer = 64; hitbox.collision_mask = 8; hitbox.faction = &"enemy"; root.add_child(hitbox)
	var shape: CollisionShape2D = _shape_node(Vector2(15, 6), Vector2.ZERO); shape.name = "CollisionShape2D"; hitbox.add_child(shape)
	_set_owner_recursive(root, root)
	var packed: PackedScene = PackedScene.new()
	if packed.pack(root) != OK:
		root.free()
		return false
	var path: String = "%s/scenes/projectiles/chapter_03_enemy_projectile.tscn" % ROOT; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var saved: bool = ResourceSaver.save(packed, path) == OK
	root.free()
	return saved


func _build_field_scene() -> bool:
	var root: Chapter03TimedField = Chapter03TimedField.new(); root.name = "Chapter03TimedField"; root.collision_layer = 0; root.collision_mask = 8
	var visual: Polygon2D = Polygon2D.new(); visual.name = "Visual"; visual.polygon = PackedVector2Array([Vector2(-44,18),Vector2(-40,-8),Vector2(-20,-20),Vector2(0,-24),Vector2(20,-20),Vector2(40,-8),Vector2(44,18)]); visual.color = Color(0.42,0.25,0.36,0.28); root.add_child(visual)
	var detect: CollisionShape2D = _shape_node(Vector2(88, 48), Vector2(0, -3)); detect.name = "CollisionShape2D"; root.add_child(detect)
	var hitbox: HitboxComponent = HitboxComponent.new(); hitbox.name = "Hitbox"; hitbox.collision_layer = 64; hitbox.collision_mask = 8; hitbox.faction = &"enemy"; root.add_child(hitbox)
	var hit_shape: CollisionShape2D = _shape_node(Vector2(88, 48), Vector2(0, -3)); hit_shape.name = "CollisionShape2D"; hitbox.add_child(hit_shape)
	_set_owner_recursive(root, root)
	var packed: PackedScene = PackedScene.new()
	if packed.pack(root) != OK:
		root.free()
		return false
	var path: String = "%s/scenes/projectiles/chapter_03_timed_field.tscn" % ROOT; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var saved: bool = ResourceSaver.save(packed, path) == OK
	root.free()
	return saved


func _shape_node(size: Vector2, position: Vector2) -> CollisionShape2D:
	var node: CollisionShape2D = CollisionShape2D.new(); var shape: RectangleShape2D = RectangleShape2D.new(); shape.size = size; node.shape = shape; node.position = position; return node


func _hitbox(node_name: String, size: Vector2, position: Vector2) -> HitboxComponent:
	var hitbox: HitboxComponent = HitboxComponent.new(); hitbox.name = node_name; hitbox.position = position; hitbox.collision_layer = 64; hitbox.collision_mask = 8; hitbox.faction = &"enemy"; hitbox.monitoring = false; hitbox.monitorable = false
	var shape: CollisionShape2D = _shape_node(size, Vector2.ZERO); shape.name = "CollisionShape2D"; shape.disabled = true; hitbox.add_child(shape); return hitbox


func _set_owner_recursive(node: Node, owner: Node) -> void:
	for child: Node in node.get_children():
		child.owner = owner
		_set_owner_recursive(child, owner)


func _pascal(value: String) -> String:
	var result: String = ""
	for word: String in value.split("_"): result += word.capitalize().replace(" ", "")
	return result
