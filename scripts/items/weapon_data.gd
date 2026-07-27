class_name WeaponData
extends Resource

## Immutable tuning/presentation contract for an equippable weapon.

@export var weapon_id: StringName
@export var display_name_zh: String
@export var display_name_en: String
@export_multiline var description_zh: String
@export_multiline var description_en: String
@export var weapon_type: StringName = &"dual_daggers"
@export_range(1, 99, 1) var tier: int = 1
@export_range(1, 9999, 1) var normal_attack_damage: int = 10
@export_range(1, 9999, 1) var dash_attack_damage: int = 20
@export var icon: Texture2D
@export var hud_icon: Texture2D
@export var player_visual_id: StringName = &"veilbound"
@export var player_idle_visual: Texture2D
@export var player_attack_visual: Texture2D
@export var world_pickup_visual: PackedScene
@export var acquisition_sound: AudioStream
@export_range(0, 999999, 1) var shop_value: int = 0
@export var can_sell: bool = false
@export var is_story_reward: bool = false
@export var is_unique: bool = true
@export var is_permanent: bool = true
@export var auto_equip_on_pickup: bool = false
@export var allow_duplicates: bool = false


func is_valid_weapon() -> bool:
	return (
		not weapon_id.is_empty()
		and normal_attack_damage > 0
		and dash_attack_damage > 0
		and not player_visual_id.is_empty()
	)
