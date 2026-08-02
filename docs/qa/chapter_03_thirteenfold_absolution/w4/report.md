# Thirteenfold Absolution W4 QA

Date: 2026-08-02

## Result matrix

| Check | Result | Evidence |
| --- | --- | --- |
| Edran one-shot formation trigger | PASS | MainBootstrap capture route and focused W4 test |
| Formation timing/stage order | PASS | 4.20 s; fragments → seals → blades → ready |
| Player lock/protection restoration | PASS | Focused W4 test preserves prior input/Hurtbox state |
| Exit waits for both death branches | PASS | Updated R4 Boss flow regression |
| Formal reliquary and E prompt | PASS | `05_reliquary_pickup_prompt_main.png` |
| Unique WeaponPickup transaction | PASS | duplicate rejected; owned count increases once |
| Auto-equip and combat authority | PASS | equipped ID and Player visual; normal/Dash `14/28` |
| Acquisition panel | PASS | `06_acquisition_panel_open_gate_main.png` |
| Empty reliquary/reload state | PASS | focused W4 room reload test |
| Underkeep locked/open transaction | PASS | collision blocker and Area2D are synchronized |
| MainBootstrap integration | PASS | six 1280×720 captures from formal bootstrap route |
| Chapter IV PackedScene | NOT IN W4 | no Chapter IV scene or false transition added |

## Main evidence

- `01_boss_fragments_converge_main.png`
- `02_thirteen_seals_extinguish_main.png`
- `03_blades_reforged_main.png`
- `04_formation_complete_main.png`
- `05_reliquary_pickup_prompt_main.png`
- `06_acquisition_panel_open_gate_main.png`

All evidence is captured from `res://scenes/bootstrap/main_bootstrap.tscn`, using the guarded Chapter III `CH3_BOSS` route. The capture proceeds from the actual Boss room to the actual post-Boss room and performs the formal pickup.

## Automated commands

The exact commands and terminal outcomes are preserved in `docs/development_log.md`. The focused test is:

```bash
"$GODOT_BIN" --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_w4_reward.gd
```

## Manual acceptance boundary

Automated QA proves state, uniqueness, equipment, lock restoration, room reload and Main composition. A human playtest should still judge the 4.20-second cadence, fragment readability, acquisition-panel dwell time and whether the restrained sound/visual treatment fits the end of Edran's death scene. W5 remains the full-route and persistence stress pass.
