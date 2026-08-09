# Soul-Lock Twin Keys / 魂锁双钥

## Purpose

Fourth-chapter permanent Boss reward from Soul Gaoler Ormund. The reward keeps the player's established dual-thrust moveset and increases only base damage, preserving reach, speed, stamina costs, recovery, and control feel.

## Weapon pair

- **Lockbreaker / 断狱 (main hand):** broad asymmetric prison-key blade, three readable teeth, broken-shackle guard, short broken chain at the pommel.
- **Soulseal / 魂契 (off hand):** shorter narrow seal-key blade, intact lock-ring guard, cyan soul channel, compact key-head pommel.
- Palette: black iron, corroded silver, rusted copper, restrained drowned cyan.

## Data contract

| Field | Value |
|---|---|
| weapon_id | `soul_lock_twin_keys` |
| type | dual daggers |
| tier | 4 |
| normal damage | 16 |
| dash attack damage | 32 |
| sellable | no |
| unique/permanent | yes / yes |
| auto-equip | yes |
| duplicates | rejected |

No passive effect, bonus reach, attack-speed change, additional hit, stamina change, or new combo is introduced.

## Reward sequence

The existing **Broken Soul Reservoir / 破魂蓄池** remains the sole Chapter IV reward facility. Ormund's death unlocks the route; the reservoir presents the Last Soul Lock sequence: water settles, chains pull taut, the reliquary rises, Lockbreaker and Soulseal form separately, then the pickup becomes interactive. Collection owns and equips the weapon, unlocks the Hall of Drowned Memories, and unlocks Chapter V progression. Boss death alone does not grant ownership or Chapter V access.

## Player animation contract

The weapon uses the shared 30-animation, 97-frame player contract. All locomotion, attack, dash, hurt, and death frames are regenerated with both keys visible where the pose supports them. The frame count, FPS, anchors, collision shapes, and attack timing remain unchanged.

## Persistence and progression contract

- The unique inventory ID is serialized by the existing `PlayerProgressSaveService` inventory/equipment payload; no parallel save system is introduced.
- Collection auto-equips the pair and persists 16 Normal / 32 Dash damage through death, respawn, room reload, application restart, and formal save reload.
- Ormund defeat sets only `ch4_boss_defeated` and `ch4_reward_unlocked`. It does not silently grant the weapon or unlock Chapter V.
- The successful pickup sets `ch4_reward_collected`, `ch4_reward_presentation_complete`, and `ch4_memory_passage_unlocked`. The existing Hall of Drowned Memories route consumes the latter flag.
- Revisiting the reservoir renders the emptied reliquary and rejects duplicate collection.

## Formal paths

- Concept board: `res://chapters/chapter_04_drowned_underkeep/assets/weapons/soul_lock_twin_keys/concept_art/soul_lock_twin_keys_concept_board.png`
- Runtime art: `res://chapters/chapter_04_drowned_underkeep/assets/weapons/soul_lock_twin_keys/`
- Weapon data: `res://chapters/chapter_04_drowned_underkeep/resources/weapons/soul_lock_twin_keys.tres`
- Player SpriteFrames: `res://chapters/chapter_04_drowned_underkeep/resources/weapons/soul_lock_twin_keys_player_sprite_frames.tres`
- Pickup scene: `res://chapters/chapter_04_drowned_underkeep/scenes/weapons/soul_lock_twin_keys_pickup.tscn`
- Formal reward room: `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_15_broken_soul_reservoir.tscn`
- Main QA evidence: `res://docs/qa/chapter_04_soul_lock_twin_keys/`
