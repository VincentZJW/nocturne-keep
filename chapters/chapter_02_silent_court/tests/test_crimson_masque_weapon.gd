extends SceneTree

const WEAPON_PATH: String = (
	"res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_stilettos.tres"
)
const FRAMES_PATH: String = (
	"res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_player_sprite_frames.tres"
)
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var inventory: PlayerWeaponInventory = root.get_node("WeaponInventory") as PlayerWeaponInventory
	var equipment: PlayerEquipmentManager = root.get_node("EquipmentManager") as PlayerEquipmentManager
	equipment.reset_for_new_run()
	var weapon: WeaponData = load(WEAPON_PATH) as WeaponData
	_expect(weapon != null and weapon.is_valid_weapon(), "Crimson Masque WeaponData invalid")
	if weapon != null:
		_expect(weapon.weapon_id == &"crimson_masque_stilettos", "weapon_id mismatch")
		_expect(weapon.weapon_type == &"dual_daggers" and weapon.tier == 3, "type/tier mismatch")
		_expect(weapon.normal_attack_damage == 14 and weapon.dash_attack_damage == 28, "damage mismatch")
		_expect(weapon.is_unique and weapon.is_permanent, "unique/permanent flags missing")
		_expect(not weapon.can_sell and weapon.is_story_reward, "reward/sell flags mismatch")
		_expect(weapon.auto_equip_on_pickup and not weapon.allow_duplicates, "pickup flags mismatch")
		_expect(
			weapon.icon != null and weapon.hud_icon != null and weapon.world_pickup_visual != null,
			"presentation resources missing",
		)
	_test_images_and_frames()
	_expect(equipment.acquire_and_equip(&"crimson_masque_stilettos"), "acquire/equip failed")
	_expect(inventory.owns_weapon(&"crimson_masque_stilettos"), "inventory ownership missing")
	_expect(not inventory.add_weapon(&"crimson_masque_stilettos"), "duplicate weapon was accepted")
	_expect(equipment.get_normal_attack_damage() == 14, "normal damage getter mismatch")
	_expect(equipment.get_dash_attack_damage() == 28, "Dash damage getter mismatch")
	var player: Player = PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	await process_frame
	await process_frame
	var visual: PlayerWeaponVisual = player.get_node("VisualRoot/WeaponVisual") as PlayerWeaponVisual
	_expect(visual.get_visual_id() == &"crimson_masque", "Player visual id mismatch")
	_expect(visual.get_active_sprite_frames_path() == FRAMES_PATH, "active SpriteFrames path mismatch")
	var combat_root: Node2D = player.get_node("CombatRoot") as Node2D
	var combat_position: Vector2 = combat_root.position
	player.animation_controller.set_facing_left(true)
	_expect(player.animation_controller.animated_sprite.flip_h, "Crimson Masque did not flip left")
	_expect(combat_root.position == combat_position, "visual flip changed combat anchor")
	var inventory_after_crimson: PlayerWeaponInventory = root.get_node("WeaponInventory") as PlayerWeaponInventory
	inventory_after_crimson.add_weapon(&"ravenfang_daggers")
	_expect(equipment.equip_weapon(&"veilbound_daggers"), "Veilbound re-equip failed")
	_expect(visual.get_visual_id() == &"veilbound", "Veilbound visual switch failed")
	_expect(equipment.equip_weapon(&"ravenfang_daggers"), "Ravenfang re-equip failed")
	_expect(visual.get_visual_id() == &"ravenfang", "Ravenfang visual switch failed")
	_expect(equipment.equip_weapon(&"crimson_masque_stilettos"), "Crimson re-equip failed")
	_expect(visual.get_visual_id() == &"crimson_masque", "three-weapon switch did not return to Crimson")
	await _test_attack_id_dedup(player)
	player.queue_free()
	await process_frame
	_test_chapter_three_profile()
	_finish()


func _test_images_and_frames() -> void:
	var root_path: String = (
		"res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos"
	)
	for path: String in [
		root_path + "/icons/inventory_icon.png",
		root_path + "/icons/hud_icon.png",
		root_path + "/sprites/world_pickup.png",
	]:
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		_expect(image != null and not image.is_empty(), "missing image: %s" % path)
		if image != null and not image.is_empty():
			_expect(image.get_format() == Image.FORMAT_RGBA8, "image is not RGBA8: %s" % path)
	var frames: SpriteFrames = load(FRAMES_PATH) as SpriteFrames
	_expect(frames != null, "Crimson Masque SpriteFrames missing")
	if frames == null:
		return
	for animation_name: StringName in PlayerSpriteFramesBuilder.ANIMATION_ORDER:
		_expect(frames.has_animation(animation_name), "missing animation %s" % animation_name)
		_expect(
			frames.get_frame_count(animation_name) == PlayerSpriteFramesBuilder.FRAME_COUNTS[animation_name],
			"frame count mismatch for %s" % animation_name,
		)
		for frame_index: int in range(frames.get_frame_count(animation_name)):
			var texture: Texture2D = frames.get_frame_texture(animation_name, frame_index)
			_expect(texture != null and texture.get_size() == Vector2(64, 64), "invalid frame %s:%d" % [animation_name, frame_index])
	var crimson_attack: PackedByteArray = FileAccess.get_file_as_bytes(
		root_path + "/sprites/player/attack/attack_02.png"
	)
	var ravenfang_attack: PackedByteArray = FileAccess.get_file_as_bytes(
		"res://assets/sprites/player/ravenfang/attack/attack_02.png"
	)
	var veilbound_attack: PackedByteArray = FileAccess.get_file_as_bytes(
		"res://assets/sprites/player/assassin/attack/attack_02.png"
	)
	_expect(crimson_attack != ravenfang_attack, "Crimson Attack art duplicates Ravenfang")
	_expect(crimson_attack != veilbound_attack, "Crimson Attack art duplicates Veilbound")


func _test_attack_id_dedup(player: Player) -> void:
	var health: HealthComponent = HealthComponent.new()
	health.max_health = 100
	var hurtbox: HurtboxComponent = HurtboxComponent.new()
	hurtbox.faction = &"enemy"
	hurtbox.health_component_path = NodePath("../HealthComponent")
	var target: Node2D = Node2D.new()
	target.add_child(health)
	health.name = "HealthComponent"
	target.add_child(hurtbox)
	root.add_child(target)
	await process_frame
	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.faction = &"player"
	root.add_child(hitbox)
	await process_frame
	hitbox.begin_attack(301, 14, 1.0, player)
	_expect(hitbox.try_hit(hurtbox), "normal hit was not accepted")
	_expect(health.current_health == 86, "normal hit did not apply exactly 14")
	_expect(not hitbox.try_hit(hurtbox) and health.current_health == 86, "same attack_id hit twice")
	hitbox.end_attack()
	hitbox.begin_attack(302, 28, 1.0, player)
	_expect(hitbox.try_hit(hurtbox), "Dash hit was not accepted")
	_expect(health.current_health == 58, "Dash hit did not apply exactly 28")
	hitbox.queue_free()
	target.queue_free()
	await process_frame


func _test_chapter_three_profile() -> void:
	var session: ChapterSessionState = root.get_node("ChapterSession") as ChapterSessionState
	var inventory: PlayerWeaponInventory = root.get_node("WeaponInventory") as PlayerWeaponInventory
	var equipment: PlayerEquipmentManager = root.get_node("EquipmentManager") as PlayerEquipmentManager
	equipment.reset_for_new_run()
	var profile: ChapterStartProfile = ChapterRegistry.get_chapter(
		ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	)
	session.apply_start_profile(profile)
	_expect(inventory.owns_weapon(&"veilbound_daggers"), "Chapter III lacks Veilbound")
	_expect(inventory.owns_weapon(&"ravenfang_daggers"), "Chapter III lacks Ravenfang")
	_expect(inventory.owns_weapon(&"crimson_masque_stilettos"), "Chapter III lacks Crimson Masque")
	_expect(equipment.equipped_weapon_id == &"crimson_masque_stilettos", "Chapter III does not equip Crimson Masque")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CRIMSON_MASQUE_WEAPON_TEST: PASS data=1 frames=49 damage=14/28 dedup=1 profile=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CRIMSON_MASQUE_WEAPON_TEST: %s" % failure)
	quit(1)
