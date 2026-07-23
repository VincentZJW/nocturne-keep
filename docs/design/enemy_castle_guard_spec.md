# Enemy Specification — Cursed Castle Guard / 诅咒剑卫

Version: 1.3 — five-point damage and grouped Main deployment
Last updated: 2026-07-23

## Role and visual identity

Cursed Castle Guard（诅咒剑卫 / 诅咒古堡守卫）is the first normal melee enemy and exists to test the complete Player attack/evasion/Health/death loop. It is an original 16-bit-inspired corrupted castle soldier: a broad dark-armored body, broken rust-colored closed helmet, hidden face, restrained dark-red eye slit, heavy shoulder plates, and one rusted steel sword. Its stance is wider and movement slower than The Night Warden, so the silhouette communicates weight rather than agility. `CastleGuard` remains the internal class/resource identifier to preserve the already-tested scene and combat API; it does not represent a second enemy type.

Twenty-four original 64×64 RGBA frames are generated deterministically with Godot `Image` operations. Source PNGs are transparent, imported Lossless without mipmaps, and displayed with Nearest filtering. The QA contact sheet is `docs/qa/castle_guard_animation_sheet.png`; the stable six-pose visual reference is `assets/sprites/enemies/castle_guard/reference/cursed_castle_guard_reference.png`.

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
- **Attack:** stops pursuit, locks its facing, raises the sword for a 0.35-second telegraph, commits to a diagonal downward heavy cut for a 0.10-second active window, then recovers for 0.45 seconds. It cannot restart each frame.
- **Hurt:** cancels Attack/Hitbox, applies small away-from-source knockback, locks movement/attack for 0.18 seconds, then resumes Chase or Patrol.
- **Death:** terminal. AI velocity, sword Hitbox, Hurtbox, detection, and actor-to-actor collision close immediately. Six frames show lethal imbalance, diagonal fall, grounded collapse, darkened fragmentation, and sparse final debris; animation completion emits `presentation_finished` and frees the actor node. There is no ghost, corpse physics, or drop.

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
| sword damage | 5 | centralized prototype pressure; 100-Health Player survives 19 and dies on hit 20 |

These values are centralized and marked for manual feel testing. No tuning was made to Player movement, jump, Dash, stamina, attack animation, or death timing.

## Animation list

| Animation | Frames | FPS / duration behavior | Loop |
| --- | ---: | --- | --- |
| `idle` | 4 | 4 FPS restrained armor breathing | yes |
| `walk` | 6 | 8 FPS heavy alternating steps | yes |
| `attack` | 5 | 10 FPS base with custom ratios totaling 0.90 s | no |
| `hurt` | 3 | 16.667 FPS, about 0.18 s | no |
| `death` | 6 | 8 FPS fall, grounded pose, then dissolve | no |

All animations face right in source and use `flip_h`; `FacingRoot` mirrors only sword combat geometry so left/right weapon reach remains in front.

### Authored frame intent

- **Idle 01–04:** restrained one-pixel breathing and armor/sword settling; feet remain on the shared baseline.
- **Walk 01–06:** left/right contacts and transition poses alternate at 8 FPS. The torso remains upright, the sword hand stays controlled, and limited helmet/shoulder bob sells plate weight rather than Player-like agility.
- **Attack 01–02:** vertical raised sword and rear-loaded anticipation communicate danger before damage is possible.
- **Attack 03–04:** the arm and blade move downward-forward on a strong diagonal. These are the only active frames and intentionally contrast with the Player's narrow dual-dagger thrust.
- **Attack 05:** the blade finishes low and forward during the punishable recovery.
- **Hurt 01–03:** short recoil silhouettes match the configured 0.18-second hard reaction; the higher 16.667 FPS is intentional so presentation and state timing end together.
- **Death 01–04:** imbalance, diagonal fall, near-ground transition, then a fully grounded body with the sword alongside it.
- **Death 05–06:** the body loses opaque pixels and color, then only sparse semitransparent armor/rust fragments remain before cleanup. No Player ghost asset or node is referenced.

## Combat fairness

- The sword cannot damage during entry or the first 0.35 seconds.
- One swing can damage one target once even if two active frames overlap it.
- Body contact never damages.
- Hurt interrupts windup, active frames, and recovery; there is no armor/poise exception.
- Jump, retreat, Ground Dash, and Air Dash can leave the narrow horizontal hitbox before it activates.
- The Guard does not jump or walk off an edge to follow a Player on another platform.

## Test room and manual acceptance

### F5 Main deployment

`res://scenes/main/main.tscn` owns four mixed groups under `World/Encounters` and three saved instances of this scene:

| Encounter | Saved Guard position(s) | Initial intent |
| --- | --- | --- |
| `EncounterGroup01` | `(500, 610)` | baseline sword threat paired with Shield Guard |
| `EncounterGroup02` | `(1170, 610)` | close pressure paired with Spearman |
| `EncounterGroup03` | `(1500, 610)` | ground pressure beneath a platform Crossbowman |

All stand on the Main floor top at y=640 and use independent bounded patrol homes. `EncounterGroup` now activates any `EnemyCombatant`, while the Castle Guard retains its original AI/state implementation. Main's debug toggle reports its state, Health, target, sword window, position, and five-point damage alongside the three newer enemy types.

### Independent test room

Run `scenes/tools/combat_test_room.tscn` directly. The room contains one Player, one Guard, flat bounded floor, Player Health/Stamina HUD, a three-line Player/Guard state display, toggleable Hurtbox/Hitbox/detection guides, and a Reset button.

For deterministic graphical capture, the internal-only `--guard-death-demo` user argument applies lethal damage after 0.25 seconds. It does not run in normal play or alter enemy Health/Death behavior.

Manual checks still required:

1. Approach from both sides and judge whether the 0.35-second raised-sword pose is readable at gameplay scale.
2. Evade five attacks using retreat, jump, Ground Dash, and Air Dash.
3. Confirm J takes one Guard Health and Shift→J takes two without rear hits.
4. Interrupt windup and active attack with Player damage; confirm the sword never lands afterward.
5. Defeat the Guard and confirm `death_04` reads as fully grounded, `death_05/06` visibly dissipate without a ghost, and no invisible collision blocks the Player.

## Explicit exclusions

No navigation, jumping AI, ranged attack, shield block, poise, drop, enemy respawn, random spawning, second enemy, elite, or Boss is included. The encounter controller only gates the existing AI and owns no combat behavior.
