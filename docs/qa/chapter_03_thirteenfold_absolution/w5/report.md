# Thirteenfold Absolution W5 final QA

Date: 2026-08-02

Engine: Godot Engine 4.7.1 Standard (`a13da4feb`)

F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`

## Result

PASS for the complete Chapter III reward boundary. Edran defeat, one-shot formation, unique pickup, auto-equip, 14/28 damage, open descent, death/respawn retention, two-process disk recovery, return-to-empty-reliquary and debug-save isolation are implemented and verified. Chapter IV PackedScene entry remains PARTIAL by design because that scene does not exist.

## Main debug-state matrix

| Spawn | Room | Initial reward state | Result |
|---|---|---|---|
| `CH3_BOSS` | Boss Sanctum | unformed/unowned | PASS — complete Boss-to-reward route |
| `CH3_POST_BOSS` | Last Confession Reliquary | formed/uncollected/locked | PASS |
| `CH3_REWARD_TEST` | Last Confession Reliquary | formed/uncollected/locked | PASS — real pickup, not visual spoof |
| `CH3_UNDERKEEP_DESCENT` | Drowned Saints Descent | owned/equipped/collected/unlocked | PASS |

All four are disposable debug states. The W5 two-process test compares the formal save SHA-256 before and after running them and confirms it is unchanged.

## Automatic evidence

| Contract | Result |
|---|---|
| Boss defeat starts exactly one formation | PASS |
| Formation and death environment gate Boss exit | PASS |
| Pickup is unique and auto-equips | PASS |
| Damage and HUD authority resolve 14/28 | PASS |
| Gate is locked before / open after collection | PASS |
| Death and respawn retain equipment | PASS |
| Separate-process reload restores ownership/equipment/flags/recovery spawn | PASS |
| Return visit is empty and cannot duplicate | PASS |
| Debug states do not modify formal save | PASS |
| Chapter IV boundary refuses nonexistent PackedScene | PASS / expected PARTIAL content boundary |

Focused command:

```sh
W5_FULL_FLOW_PHASE=write /Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_full_flow.gd
W5_FULL_FLOW_PHASE=load /Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_full_flow.gd
```

Both fresh processes returned `PASS` with no red runtime error.

## Rendered MainBootstrap evidence

All images are real 1280×720 rendered MainBootstrap frames:

1. `01_reward_test_uncollected_main.png` — real uncollected reward state.
2. `02_pickup_prompt_main.png` — formal interaction prompt.
3. `03_acquired_equipped_main.png` — acquisition panel and HUD tier 3 / 14 / 28.
4. `04_equipped_attack_main.png` — equipped normal attack.
5. `05_equipped_dash_attack_main.png` — equipped Dash Attack.
6. `06_left_facing_main.png` — left-facing flip.
7. `07_underkeep_inherited_main.png` — equipment inherited into Underkeep.
8. `08_death_retains_equipment_main.png` — death/ghost with tier 3 / 14 / 28 still shown.
9. `09_respawn_retains_equipment_main.png` — respawned Player retains equipment.
10. `10_return_empty_reliquary_main.png` — return visit has no duplicate pickup and gate remains open.

Hashes are recorded in `sha256_manifest.txt`; asset ownership/counts are recorded in `artifact_manifest.md`.

## Scope and remaining boundary

W5 changes no Player timing, Hitbox, movement, stamina, Boss values, enemies or Chapter IV content. There is no title/Continue UI. The explicit save load API and recovery target are verified, but exposing Continue belongs to a separate approved milestone. Human review should still judge animation readability and narrative timing; automation only proves deterministic state and composition.
