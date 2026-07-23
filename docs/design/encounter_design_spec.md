# Gray-box Encounter Design Specification

Version: 1.0
Last updated: 2026-07-23
Status: first-enemy hand-authored density prototype; manual feel acceptance pending

## Scope and density decision

The current F5 gray box has a 2600-pixel floor (`x=-100..2500`), approximately 2.03 screens at the 1280-pixel reference width. It is materially shorter than the 3–5-screen case for which six to eight enemies were suggested. The current target is therefore five Cursed Castle Guards, not an arbitrary high count.

No new enemy type, elite, Boss, drop, experience, random spawn, respawn wave, or object pool is part of this design. `scenes/tools/combat_test_room.tscn` intentionally remains a one-Guard isolated laboratory.

## Main composition

```text
Main/World/Encounters
├── EncounterGroup01 (1 Guard)
│   ├── ActivationArea
│   └── Enemies/CursedGuard01
├── EncounterGroup02 (1 Guard)
│   ├── ActivationArea
│   └── Enemies/CursedGuard02
├── EncounterGroup03 (1 Guard)
│   ├── ActivationArea
│   └── Enemies/CursedGuard03
└── EncounterGroup04 (2 Guards)
    ├── ActivationArea
    └── Enemies/CursedGuard04A, CursedGuard04B
```

| Group | Activation center | Guard spawn(s) | Design purpose |
| --- | --- | --- | --- |
| 01 | `(430, 470)` | `(500, 610)` | immediate single-enemy teaching and Hurt readability |
| 02 | `(850, 470)` | `(1030, 610)` | isolated repeat after a recovery gap |
| 03 | `(1300, 470)` | `(1500, 610)` | platform-adjacent jump/Air Dash approach |
| 04 | `(1840, 470)` | `(2070, 610)`, `(2310, 610)` | final two-enemy stamina and disengage check |

All spawns use the valid ground baseline, remain separated, and leave the main route open. The gaps between encounter fronts provide time for the 0.60-second stamina regeneration delay and partial recovery before the next group.

## Activation contract

- `EncounterGroup` owns one Player-only `ActivationArea`, one `Enemies` container, a persistent `is_activated` flag, and debug counts.
- Every Guard starts visually present in Idle but with AI physics and its DetectionArea paused.
- First Player entry activates the group once, enables each Guard's AI/detection, and immediately supplies the Player target only if already within that Guard's own 180-pixel detection range.
- Activation stays true for the current scene run. Dead Guards remain dead/removed; no timer recreates them.
- Earlier groups may continue bounded Patrol after losing the Player, but only `Chase`, `Attack`, and `Hurt` count as engaged. Safe spacing plus the 260-pixel lose range prevents whole-map pursuit.

## Multi-enemy fairness

- Authored group size never exceeds two; the debug `simultaneous_attack_limit` is two.
- The only two-enemy group uses 240-pixel spawn spacing. With 46-pixel attack range, both cannot occupy one attack origin without first repositioning around body collisions.
- Guard bodies collide with Player but do not deal contact damage; Guards do not deal friendly fire.
- Per-attack target memory prevents one sword swing from applying twice across `attack_03/04`.
- Player's synchronous 0.50-second invulnerability rejects subsequent distinct Guard sources during the grace window, preventing multi-hit stun lock.
- Guards retain edge/wall checks and cannot chase off the floor. There is no group-tactics, reservation, flanking, or formation AI in this milestone.

## Debug and reset

The closable Main enemy debug panel displays group name, activation, engaged count, alive count, attacking count/limit, and each Guard's state, Health, configured damage, target, sword window, and x-position. This is diagnostic presentation only.

Reloading Main resets group activation and all five authored enemies. There is intentionally no infinite/random generation: deterministic placement makes Hurt, stamina, multi-source invulnerability, and encounter pacing reproducible for automated and manual tests.

## Manual acceptance

1. Confirm only Group01 engages at startup and later groups remain Idle until their ActivationAreas are crossed.
2. Verify a defeated group does not respawn and activation remains latched when walking back.
3. Confirm recovery space exists between Groups 01–03 and that no Guard begins chasing from off-screen beyond its group.
4. In Group04, verify both enemies remain spatially readable, do not overlap, and no more than two sword attacks can be active.
5. Verify retreat, jump, Ground/Air Dash, normal Attack, Dash Attack, and stamina recovery remain usable through the complete route.
