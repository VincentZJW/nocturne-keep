# The Hollow Duchess, Seraphine — Boss Specification

Status: first playable two-phase implementation complete; human combat-feel acceptance pending

## Identity and encounter

- Chinese: 空心公爵夫人·瑟芙琳
- English: The Hollow Duchess, Seraphine
- Arena: Silent Ballroom, Chapter II room 09
- Runtime scene: `res://chapters/chapter_02_silent_court/scenes/boss/hollow_duchess.tscn`
- Main instance: `SilentCourt/BossArea/HollowDuchess`
- Controller: `SilentCourt/ChapterSystems/HollowDuchessRoomController`
- Debug F5 route: `MainBootstrap -> CHAPTER_02_SILENT_COURT -> CH2_BOSS`

Seraphine is a tall undead court hostess bound to the last royal dance. Her white porcelain mask, damaged black/crimson gown, rapier, blade fan and restrained footwork distinguish her from Chapter I's armored gate knight. She does not summon ordinary enemies, teleport without a tell, or use untelegraphed full-screen damage.

## Composition

```text
HollowDuchess (CharacterBody2D)
├── VisualRoot/AnimatedSprite2D
├── CollisionShape2D
├── HealthComponent
├── Hurtbox
├── FacingRoot
│   ├── RapierThrustHitbox
│   ├── FanSlashHitbox
│   ├── RiposteHitbox
│   ├── SideStepCutHitbox
│   ├── DoubleLungeHitbox1
│   ├── DoubleLungeHitbox2
│   └── FinalWaltzHitbox
└── RouteTelegraph
```

`HollowDuchessConfig` is the sole Boss tuning source. Existing shared `HealthComponent`, `HitboxComponent` and `HurtboxComponent` retain bounded health, faction filtering and one-hit-per-attack-ID settlement. The room controller owns activation, door/camera/input lock, CP05 retry and presentation; the Boss script owns only combat decisions and state.

## Vitals, pressure resistance and facing

| Parameter | Value |
| --- | ---: |
| Maximum Health | 220 |
| Phase 2 threshold | 121 HP / 55% |
| Poise | 60 |
| Normal Attack Poise damage | 10 |
| Dash Attack Poise damage | 24 |
| Stagger | 0.56 s |
| Post-Stagger protection | 2.50 s |
| Turn reaction | 0.14 s |
| Turn animation | 0.44 s |
| Facing commit | 70% of turn animation |

Normal Player hits reduce HP and Poise but cannot interrupt an attack. A Dash Attack gives a brief light reaction only from neutral movement states. Poise exhaustion is the only normal route into `Stagger`; protection prevents consecutive permanent locks. Death and Phase Transition always outrank Stagger.

Attacks lock facing. Side changes first request `Turn`; the new facing commits late in its authored 0.58-second response instead of flipping in one frame. Hitboxes remain children of `FacingRoot`, so flip, weapon direction and damage geometry agree.

## State and cadence contract

Core neutral flow is `Dormant -> Intro -> Idle -> Evaluate -> Approach/Retreat/Turn/Attack`. Every attack has explicit Windup, Active and Recovery states. Phase 1 has a random 0.84–1.02-second Attack Gap; Phase 2 uses 0.72–0.90 seconds. A maximum of two chained decisions is followed by mandatory 1.14/0.99-second recovery. Defensive side/back movement cannot repeat more than twice.

### Phase 1 attacks

| Attack | Windup / Active / Recovery | Damage | Read and counter |
| --- | --- | ---: | --- |
| Rapier Thrust | 0.46 / 0.11 / 0.60 s | 11 | straight pale rapier line; jump, cross or retreat |
| Fan Slash | 0.54 / 0.14 / 0.72 s | 13 | raised blade fan and two narrow angled volumes; jump above or leave close range |
| Backstep Riposte | 0.24 backstep + 0.22 pause + 0.30 / 0.10 / 0.72 s | 12 | retreats before a committed return thrust; punish the recovery, cooldown 3.6 s |
| Side-Step Cut | 0.38 sidestep + 0.12 prepare + 0.32 / 0.11 / 0.66 s | 12 | lateral reposition then direction-locked cut; cooldown 2.9 s |

### Phase transition

At 121 HP or below, the current action is allowed to settle before `PhaseTransition`. Seraphine becomes temporarily invulnerable, retreats a short safe distance, changes the Ballroom tint, preserves current HP and unlocks Phase 2 after 1.22 seconds. The transition never heals.

### Phase 2 attacks

| Attack | Timing | Damage | Read and counter |
| --- | --- | ---: | --- |
| Double Waltz Lunge | 0.48 windup, 0.10 hit 1, 0.27 gap, 0.11 hit 2, 0.80 recovery | 9 + 12 | first thrust baits an early response; second remains direction-locked |
| Phantom Dancer Sweep | 0.75 lane telegraph, 0.72 crossing, 0.82 recovery | 10 | two translucent dancers cross fixed floor/elevated lanes; real Boss remains visible; cooldown 4.5 s |
| Final Waltz Crossing | 0.90 prepare, three 0.68 passes with 0.43 gaps, 1.15 recovery | 8 per pass | available at 25% HP; route line precedes each crossing; cooldown 7.0 s |

Phantom routes are non-solid, use distinct attack IDs and free themselves at route completion. Final Waltz uses one fresh attack ID per pass, so a target cannot be damaged twice during one pass but can be hit by separate passes.

## Pixel art and animations

- Source concept: `assets/boss/hollow_duchess/concept_art/hollow_duchess_concept.svg`
- Generated animation frames: `assets/boss/hollow_duchess/sprites/`
- Runtime SpriteFrames: `assets/boss/hollow_duchess/animations/hollow_duchess_sprite_frames.tres`
- Format: 96×96 transparent PNG, nearest-neighbor, no antialiasing or mipmaps.
- Palette: porcelain white, black/plum/crimson gown, pale steel rapier, muted violet soul mist.

Twenty named sequences provide 101 original frames: `idle`, `intro`, `elegant_walk`, `turn`, `sidestep`, `backstep`, `rapier_thrust_windup`, `rapier_thrust_active`, `rapier_thrust_recovery`, `fan_slash_windup`, `fan_slash_active`, `fan_slash_recovery`, `riposte`, `phase_transition`, `double_lunge`, `phantom_dance`, `final_waltz`, `light_hit`, `stagger` and `death`. Left display uses `flip_h`; source images are not duplicated.

## Room, HUD, reset and ending

Entering `BossArea/BossActivationArea` closes the rear and exit doors, sets CP05, locks the Player for the title card, constrains the existing camera to X 27520–32128 and starts the full 5.1-second intro. The title and line `你果然回来了。` are visible before Player control resumes. A signal-driven HUD shows bilingual name, exact HP, phase and Poise.

Player death uses the existing ghost/respawn sequence. On respawn the room controller resets Boss HP/phase/Poise/cooldowns/phantoms/position, reopens the rear approach, restores the closed exit and uses the one-second retry intro. Boss death disables all attack sources, plays `death`, delivers `你认识我？` / `不……但殿下一直在等你。`, opens both doors and fades the Boss HUD. The exit is a safe Chapter III transition placeholder only; no later chapter is implemented.

## Verification boundary

Automated evidence proves configuration, 70 attack cycles, phase/Poise/reset, five complete 222–226-second live-component simulations and Main composition. Graphical evidence was captured from the legal Bootstrap/CH2_BOSS path, not an isolated preview. Manual acceptance must still judge tell readability, punish-window feel, camera framing at arena extremes and whether phase-two lanes remain readable during real evasive play.
