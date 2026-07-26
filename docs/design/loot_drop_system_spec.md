# Loot System Specification

Version: 1.1 — health-tier dynamic Chapter I drops

`scripts/items/loot_drop_component.gd` is composed once into each of the five normal-enemy PackedScenes. The 34 saved Main instances inherit it; Main stores no per-instance odds. Each enemy type references one `LootDropProfile` containing only its coin range, while all five types explicitly reference `resources/items/loot/default_dynamic_loot_profile.tres` for outcome probabilities.

## Shared four-tier table

| Tier | Death-time Player Health | Coin | Small Health | Large Health | None |
|---|---|---:|---:|---:|---:|
| `FULL` | `current >= maximum` or ratio `>= 1.0` | 72 | 0 | 0 | 28 |
| `LIGHT` | `0.50 < ratio < 1.0` | 50 | 28 | 7 | 15 |
| `HEAVY` | `0.20 < ratio <= 0.50` | 35 | 35 | 15 | 15 |
| `CRITICAL` | `ratio <= 0.20`, including zero | 20 | 25 | 40 | 15 |

`DynamicLootProfile` owns tier selection and four `LootProbabilityWeights` subresources. Every table must total exactly 100 or the component reports a configuration error during `_ready()`. Full Health cannot produce a blood vial; Critical Health favors the large vial but still retains 15% no-drop probability.

## Resolution contract

Each enemy death reads Player `current_health` and `max_health` once, stores `selected_health_tier`, `player_health_ratio_at_kill`, `drop_roll` and `selected_drop_result`, and resolves exactly one of `coin`, `small_health`, `large_health`, or `none`. The floating-point roll is in `[0, 100)` and is consumed once; outcome intervals are cumulative weights, so coin and healing cannot coexist from one death. `_resolved` prevents a duplicate Death signal from rolling or spawning again. `reset_drop_state()` restores the audit fields for an explicitly reused test actor.

The component records the accepted Hitbox before Health mutation. Player-faction fatal hits use the selected table. A death without a Player hit is environmental: the same single roll removes healing and uses half of that tier's coin probability, with all remaining probability becoming `none`. Debug deletion calls `suppress_drop()` or bypasses Death and drops nothing.

| Enemy | Coin range |
|---|---:|
| Cursed Castle Guard | 1–2 |
| Cursed Shield Guard | 2–4 |
| Decayed Spearman | 2–3 |
| Fallen Crossbowman | 2–3 |
| Gargoyle Sentinel | 2–4 |

Boss loot never uses this component. `BossRewardController` grants fixed 30 coins and Ravenfang. Pickups pop 14 pixels, settle at their authored world position, own no body/damage collision, live 20 seconds and blink for the final 3.

## Debug and verification

- `force_drop` forces one result type; `force_next_drop_roll()` consumes one exact floating-point outcome roll.
- `collect_statistics_for_health()` samples a current/maximum pair with an isolated deterministic RNG state. `reset_loot_statistics()` clears live debug counts.
- Main's Expanded Enemy Debug shows the latest result plus tier, death-time ratio, roll, amount/source and active weights. Development helpers expose Player HP presets 100/75/50/20 without making the HUD a Health authority.
- Boundary contract: 100 is Full; 99/51 Light; 50/21 Heavy; 20/1/0 Critical.
- The deterministic milestone sample uses 1,000 rolls for every tier, in addition to exact forced-roll threshold tests and all-34 Main inheritance checks.
