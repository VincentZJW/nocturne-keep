# Weapon Data, Inventory and Equipment Specification

`WeaponData` contains id, bilingual name/description, `dual_daggers` type, tier, normal/Dash damage, icon, Player visual id, optional idle/attack/world-pickup visuals, acquisition audio, shop value, sell flag and story-reward flag.

| Resource | Tier | Normal | Dash | Acquisition |
|---|---:|---:|---:|---|
| `veilbound_daggers.tres` | 1 | 10 | 20 | starting weapon |
| `ravenfang_daggers.tres` | 2 | 12 | 24 | first Boss fixed reward |

`WeaponInventory` owns unique ids. `EquipmentManager` owns the equipped id, resolves resources, exposes `get_normal_attack_damage()` / `get_dash_attack_damage()` and emits typed equipment/damage signals. Both persist across Player death and scenes; new-run reset restores Veilbound only. Player active frames query these getters, so action code and scenes no longer author damage.

`Player/VisualRoot/WeaponVisual` observes `weapon_equipped`. Veilbound uses the existing authored frame blades; Ravenfang adds longer black-steel, pale-edge and restrained dark-red rune pixels to idle, run, jump, Dash, normal Attack and Dash Attack poses. It follows `flip_h` without changing Hitboxes, attack speed, reach or movement.

After the complete Gate Knight death, `BossRewardController` grants 30 coins once and reveals the permanent pickup at `Main/World/CastleEntranceArea/BossReward/WeaponPickup`, world `(6210,592)`. E acquires and auto-equips it, showing `ATTACK 10 → 12`. The gate opens on death but the threshold transition waits for collection and otherwise shows a small return prompt.

Run persistence is intentionally in three focused autoloads, not Main-local variables. Save-file persistence is not implemented; the future save boundary is `current_coins`, owned weapon ids, equipped weapon id and `ChapterSession` reward flags.
