# Weapon Art Specification

## Ravenfang Daggers / 鸦牙双匕

Ravenfang is an original paired raven-claw silhouette built as hard-edged 16-bit-inspired pixel art. Each blade has a thick dark-steel root, a cold blue-gray edge and an inward-hooked tip. A compact folded-wing guard, segmented black grip and small beak/ring pommel express the raven theme without a literal bird head, feathers, saturated magic glow or modern tactical materials.

Authoritative resources:

- WeaponData: `res://resources/items/weapons/ravenfang_daggers.tres`
- 16×16 icon: `res://assets/ui/items/ravenfang_daggers.png`
- world pickup: `res://scenes/items/pickups/ravenfang_weapon_pickup.tscn`
- equipped frame root: `res://assets/sprites/player/ravenfang/`
- equipped SpriteFrames: `res://resources/player/ravenfang_player_sprite_frames.tres`

The alternate set contains 49 transparent 64×64 frames across all 16 Player animations: Idle, Run, Jump Start/Loop, Fall, Land, ground/Air Dash start-loop-end, normal Attack, Dash Attack, Hurt and Death. Main/offhand claws use one generator and remain paired but vertically separated. All textures use nearest sampling through the existing AnimatedSprite2D and retain the common 58 px foot baseline. Horizontal facing remains `flip_h`.

`PlayerWeaponVisual` switches the AnimatedSprite2D's complete SpriteFrames resource atomically when EquipmentManager equips Ravenfang. It never draws a second weapon overlay, so Veilbound and Ravenfang silhouettes cannot coexist or flash between locomotion, combat, Hurt and Death. The pickup renderer and icon use the same dark steel / cold edge / black grip / blue-gray wing language.

Reproduction uses `generate_item_icons.gd`, `generate_ravenfang_player_assets.gd`, an editor import, then `build_ravenfang_sprite_frames.gd`. Ravenfang combat values remain 12 normal / 24 Dash; art does not change timing, reach, movement or damage.
