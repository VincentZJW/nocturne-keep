# Loot System Specification

Version: 1.0 — Chapter I regular-enemy drops

`scripts/items/loot_drop_component.gd` is composed once into each of the five normal-enemy PackedScenes. The 34 saved Main instances inherit it; Main stores no per-instance odds. Each enemy type references one `LootDropProfile` containing only its coin range.

Each death resolves at most one result: `coin`, `small_health`, `large_health`, or `none`. Player HP above 60% uses 58/12/3/27; 31–60% uses 52/16/5/27; 30% or below uses 45/22/8/25. Every row totals 100%. Low-HP protection increases healing probability but guarantees nothing.

The component records the accepted Hitbox before Health mutation. Player-faction fatal hits use the normal table. A death without a Player hit is environmental: healing is removed and an otherwise successful coin result is retained only 50% of the time. Debug deletion calls `suppress_drop()` or bypasses Death and drops nothing. One `_resolved` guard prevents duplicates.

| Enemy | Coin range |
|---|---:|
| Cursed Castle Guard | 1–2 |
| Cursed Shield Guard | 2–4 |
| Decayed Spearman | 2–3 |
| Fallen Crossbowman | 2–3 |
| Gargoyle Sentinel | 2–4 |

Boss loot never uses this component. `BossRewardController` grants fixed 30 coins and Ravenfang. Pickups pop 14 pixels, settle at their authored world position, own no body/damage collision, live 20 seconds and blink for the final 3. `ForceDrop`, deterministic seed and `collect_statistics()` provide repeatable QA.
