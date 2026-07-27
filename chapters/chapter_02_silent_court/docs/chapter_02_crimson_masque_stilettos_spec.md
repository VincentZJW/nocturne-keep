# Crimson Masque Stilettos / 绯幕礼刺

Status: implemented Chapter II fixed Boss reward

## Identity

- ID: `crimson_masque_stilettos`
- Type: dual daggers
- Tier: 3
- Normal Attack: 14
- Dash Attack: 28
- Unique, permanent, unsellable, no duplicates, auto-equip on pickup
- Description: 曾在无声舞会中用于最后决斗的一对礼刺。白瓷已裂，绯幕未落。

The pair carries the Silent Court's masquerade language without copying Veilbound or Ravenfang. `Crimson Needle / 绯红礼针` is the longer straight needle with a cracked porcelain half-mask guard. `Masque Fan Blade / 假面扇刺` is slightly shorter and wider with a compact three-facet folded-fan guard. Both use dark silver, pale porcelain, restrained black and narrow crimson accents; their straight thrust profile is intentionally unlike Ravenfang's inward-hooked claws.

## Runtime resources

- WeaponData: `res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_stilettos.tres`
- Pickup: `res://chapters/chapter_02_silent_court/scenes/weapons/crimson_masque_stilettos_pickup.tscn`
- Inventory/HUD icons: `res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos/icons/`
- World pickup: `res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos/sprites/world_pickup.png`
- Player frame root: `res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos/sprites/player/`
- SpriteFrames: `res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_player_sprite_frames.tres`

The Player resource contains 49 transparent 64×64 frames across the existing 16 animation names. Every frame is generated from the established pose sources with a weapon-specific pixel renderer. This preserves feet/anchors, timing, attack windows and left/right `flip_h` behavior while changing both blade silhouettes across Idle, Run, aerial movement, Dash, Attack, Hurt and Death.

All source PNGs are losslessly imported with Mipmaps disabled. The project-wide CanvasItem filter is nearest, and scene Sprite2D/TextureRect nodes explicitly use nearest filtering.

## Acquisition and persistence

Seraphine's death controller completes its existing four lines and mirror reveal, then the transition controller instantiates the pickup at `SilentCourt/GameplayWorld/BossArea/Chapter02BossWeaponPickupAnchor`. E collection uses the shared WeaponPickup contract, adds one unique inventory id, equips it and shows the compact acquisition panel. The secret door remains gated by `chapter_02_boss_weapon_collected`.

- Defeated + uncollected reload: Boss absent, mirror revealed, weapon reconstructed at the fixed anchor.
- Collected reload: no duplicate world pickup; ownership, equipment and gate eligibility persist for the process lifetime.
- Chapter III Debug Start: owns Veilbound, Ravenfang and Crimson Masque, equips Crimson Masque and carries all Chapter II completion flags without re-awarding the pickup.

## Scope boundary

This weapon adds no new input, passive, status, element, critical system, combo tree, attack range, animation timing or Dash behavior. It does not alter Chapter I weapon data, enemies, Hollow Duchess combat tuning, loot tables or formal Chapter III content.
