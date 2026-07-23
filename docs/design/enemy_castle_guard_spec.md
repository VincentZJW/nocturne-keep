# Enemy Specification — Castle Guard / 古堡守卫

Version: 1.0 — first melee prototype
Last updated: 2026-07-23

## Role and visual identity

Castle Guard is the first normal melee enemy and exists to test the complete Player attack/evasion/Health/death loop. It is an original 16-bit-inspired corrupted castle soldier: a broad dark-armored body, broken rust-colored helmet edge, hidden face, restrained dark-red eye slit, and one rusted steel sword. Its stance is wider and movement slower than The Night Warden, so the silhouette communicates weight rather than agility.

Twenty-four original 64×64 RGBA frames are generated deterministically with Godot `Image` operations. Source PNGs are transparent, imported Lossless without mipmaps, and displayed with Nearest filtering. The QA contact sheet is `docs/qa/castle_guard_animation_sheet.png`.

## Scene composition

```text
CastleGuard (CharacterBody2D)
├── VisualRoot/AnimatedSprite2D
├── CollisionShape2D
├── HealthComponent
├── Hurtbox/CollisionShape2D
├── FacingRoot/AttackHitbox/CollisionShape2D
├── DetectionArea/CollisionShape2D
├── WallCheck
├── FloorCheck
└── StateMachine
```

The actor scene is independently instantiable. `CastleGuardStateMachine` owns the current typed state; `CastleGuard` owns decisions, collision-safe movement, and animation/hitbox coordination. All tuning comes from `resources/enemies/castle_guard_config.tres`.

## State flow

```text
Idle → Patrol ⇄ Chase → Attack → Chase
          ↑          ↘ Hurt ─────┘
          └──────────── Death (terminal)
```

- **Idle:** brief initial/turn pause, zero target velocity, idle animation.
- **Patrol:** bounded horizontal walk. Wall, missing forward floor, or patrol limit causes a turn and short pause.
- **Chase:** horizontal pursuit only. The Guard stops at walls/edges and abandons a target outside the lose range or outside the same-platform height tolerance.
- **Attack:** stops pursuit, locks its facing, shows 0.35 seconds of windup, activates the sword for 0.10 seconds, then recovers for 0.45 seconds. It cannot restart each frame.
- **Hurt:** cancels Attack/Hitbox, applies small away-from-source knockback, locks movement/attack for 0.18 seconds, then resumes Chase or Patrol.
- **Death:** terminal. AI velocity, sword Hitbox, Hurtbox, detection, and actor-to-actor collision close immediately. A six-frame fall/collapse plays, then the actor hides. No drop is spawned.

## Prototype tuning

| Parameter | Value | Rationale / test target |
| --- | ---: | --- |
| max Health | 3 | three normal thrusts or normal + Dash Attack |
| patrol speed | 45 px/s | visibly heavy and slower than Player |
| chase speed | 75 px/s | creates pressure without matching Player mobility |
| detection / lose range | 180 / 260 px | hysteresis prevents rapid acquire/loss flicker |
| attack range | 46 px | sword reach, still escapable by walking or Dash |
| windup / active / recovery | 0.35 / 0.10 / 0.45 s | readable commitment and punish window |
| hurt duration | 0.18 s | clear feedback without permanent stun lock assumption |
| knockback speed | 120 px/s | small readable displacement |
| sword damage | 1 | first integer damage contract; Player Health remains 100 |

These values are centralized and marked for manual feel testing. No tuning was made to Player movement, jump, Dash, stamina, attack animation, or death timing.

## Animation list

| Animation | Frames | FPS / duration behavior | Loop |
| --- | ---: | --- | --- |
| `idle` | 4 | 4 FPS restrained armor breathing | yes |
| `walk` | 6 | 8 FPS heavy alternating steps | yes |
| `attack` | 5 | custom durations totaling 0.90 s | no |
| `hurt` | 3 | 16.667 FPS, about 0.18 s | no |
| `death` | 6 | 8 FPS armor collapse | no |

All animations face right in source and use `flip_h`; `FacingRoot` mirrors only sword combat geometry so left/right weapon reach remains in front.

## Combat fairness

- The sword cannot damage during entry or the first 0.35 seconds.
- One swing can damage one target once even if two active frames overlap it.
- Body contact never damages.
- Hurt interrupts windup, active frames, and recovery; there is no armor/poise exception.
- Jump, retreat, Ground Dash, and Air Dash can leave the narrow horizontal hitbox before it activates.
- The Guard does not jump or walk off an edge to follow a Player on another platform.

## Test room and manual acceptance

Run `scenes/tools/combat_test_room.tscn` directly. The room contains one Player, one Guard, flat bounded floor, Player Health/Stamina HUD, a three-line Player/Guard state display, toggleable Hurtbox/Hitbox/detection guides, and a Reset button.

Manual checks still required:

1. Approach from both sides and judge whether the 0.35-second raised-sword pose is readable at gameplay scale.
2. Evade five attacks using retreat, jump, Ground Dash, and Air Dash.
3. Confirm J takes one Guard Health and Shift→J takes two without rear hits.
4. Interrupt windup and active attack with Player damage; confirm the sword never lands afterward.
5. Defeat the Guard and confirm its final collapse reads clearly and no invisible collision blocks the Player.

## Explicit exclusions

No navigation, jumping AI, ranged attack, shield block, poise, drop, respawn, encounter controller, second enemy, elite, or Boss is included.
