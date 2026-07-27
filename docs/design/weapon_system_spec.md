# Weapon Data, Inventory and Equipment Specification

`WeaponData` contains id, bilingual name/description, `dual_daggers` type, tier, normal/Dash damage, icon, Player visual id, optional idle/attack/world-pickup visuals, acquisition audio, shop value, sell/story-reward flags and explicit unique/permanent/auto-equip/duplicate-policy metadata.

| Resource | Tier | Normal | Dash | Acquisition |
|---|---:|---:|---:|---|
| `veilbound_daggers.tres` | 1 | 10 | 20 | starting weapon |
| `ravenfang_daggers.tres` | 2 | 12 | 24 | first Boss fixed reward |
| `crimson_masque_stilettos.tres` | 3 | 14 | 28 | Hollow Duchess fixed reward |

`WeaponInventory` owns unique ids. `EquipmentManager` owns the equipped id, resolves resources, exposes `get_normal_attack_damage()` / `get_dash_attack_damage()` and emits typed equipment/damage signals. Both persist across Player death and scenes; new-run reset restores Veilbound only. Player active frames query these getters, so action code and scenes no longer author damage.

`Player/VisualRoot/WeaponVisual` observes `weapon_equipped`. Veilbound retains its original SpriteFrames. Ravenfang and Crimson Masque each atomically replace the complete AnimatedSprite2D resource with a dedicated 49-frame set covering all 16 locomotion, aerial, Dash, Attack, Hurt and Death animations. No overlay is drawn, so silhouettes never mix during a switch. Crimson Masque uses two straight dark-silver ceremonial blades, a cracked porcelain half-mask guard, folded-fan offhand guard, narrow crimson grooves and tear-ruby pommels; `flip_h` changes presentation only and never changes Hitbox size, attack speed, reach or movement.

After the complete Gate Knight death, `BossRewardController` grants 30 coins once and reveals the permanent pickup at `Main/World/CastleEntranceArea/BossReward/WeaponPickup`, world `(6210,592)`. E acquires and auto-equips it, showing `ATTACK 10 → 12`. The gate opens on death but the threshold transition waits for collection and otherwise shows a small return prompt.

After the Hollow Duchess death dialogue and dissolve, `Chapter02To03TransitionController` unlocks the saved `DuchessReliquary` and reconstructs the permanent Crimson Masque pickup at `DuchessReliquary/WeaponDisplay/PickupAnchor`, never at the Boss corpse. The pickup's old floor visual is hidden so the crossed blades remain visibly mounted in the medieval cabinet. E uses the same `WeaponPickup` API to add the unique id, auto-equip it, update the icon/Tier/14/28 HUD and set `chapter_02_boss_weapon_collected`. Reload before collection restores an occupied, interactable reliquary and sealed mirror; reload after collection restores an empty cabinet and revealed mirror. The Royal Chapel Passage gate checks the story flag and inventory remains the equipment source of truth.

Run persistence is intentionally in three focused autoloads, not Main-local variables. Save-file persistence is not implemented; the future save boundary is `current_coins`, owned weapon ids, equipped weapon id and `ChapterSession` reward flags.
