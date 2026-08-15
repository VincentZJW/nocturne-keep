# Fallen Gate Knight Boss Specification

Version: 1.6
Last updated: 2026-07-29

## Identity

`Fallen Gate Knight / 堕落守门骑士` uses a 128×96 production cell while preserving the former body/feet world anchor and roughly 1.6× Player-scale body. The added horizontal room exists for the complete `Gatewarden Greatsword / 守门誓剑`, not to enlarge collision or attack reach. The v3 production art is original and independently redraws shielded and unshielded silhouettes; it does not scale the Cursed Shield Guard. Death drops the sword, collapses, and dissolves; no ghost is spawned.

## Shared combat authority

- Body: `HealthComponent`, 180 Health.
- Shield: shared corrected `ShieldComponent`, 100 Health, front-only Player weapon routing, no breaking-hit overflow, stable attacker/id ledger, permanent break.
- Damage: Bash 8, Slash 10, Heavy/Jump Smash 15, Charge 12, Shockwave 8.
- Turn: 0.33 s reaction + 0.80 s authored animation, 12 px side threshold, 0.14 s post-turn cooldown. The earlier 0.80–1.00-second target is superseded by 1.00–1.30 seconds; fixed-step total is 1.1333 s. Facing commits at 80% of the animation stage, never before 70%. ShieldBreak: 0.90 s. PhaseTransition: 1.10 s.
- Post-attack cadence is per skill and measured from active Hitbox close to the next windup, not appended after the full animation. Attack damage, Body/Shield, skills, phases, base movement and bridge bounds are unchanged.

## Phase 1 — shielded

`BossIntro → IdleShielded ↔ ApproachShielded ↔ TurnShielded → ShieldBash / SwordSlash / HeavyOverhead → GuardRecovery`.

Phase-1 selection is weighted rather than the old fixed equal cycle: Shield Bash `22%`, Sword Slash `43%`, Heavy Overhead `35%`. Shield Bash is eligible only inside 37 px, cannot directly repeat, and starts a 2.70-second repeat cooldown. Slash/Heavy eligibility stops at 40 px; outside it, the Boss approaches instead of attacking through oversized geometry. Phase 2 still uses its unchanged four-family cycle, including the actual `ChargeThrust`; Shield Bash cannot occur after shield loss.

Frontal normal/Dash attacks damage only Shield; rear/center or post-break attacks damage Body. Shield hits play `shield_block`. Shield zero enters `ShieldBreak`, then a one-way `PhaseTransition`.

Shield presentation uses ratio bands without duplicating combat authority: above 80% intact, 51–80% damaged, 1–50% critical, and 0 broken. `ShieldDamageOverlay` listens to the same Shield signal as the HUD; it adds pixel cracks only, while the existing shield-break animation removes the shield. With Veilbound Daggers, five frontal Dash Attacks or ten frontal Normal Attacks break a full Shield. The breaking hit never overflows into Body.

## Phase 2 — unshielded

`IdleUnshielded ↔ ApproachUnshielded ↔ TurnUnshielded → ComboSlash / JumpSmash / ChargeThrust / ShockwaveStrike → Recovery`.

Phase 2 is faster, never restores Shield, and has no third phase or summons. Each attack owns one stable attack id and frame-bound Hitbox. ComboSlash has two authored steps but remains one Boss attack family, not a Player combo system.

## Animation and art contract

`idle_shielded`, `walk_shielded`, `turn_shielded`, `shield_block`, `shield_bash`, `sword_slash`, `heavy_overhead`, `hurt_shielded`, `shield_break`, `phase_transition`, `idle_unshielded`, `walk_unshielded`, `turn_unshielded`, `combo_slash_1`, `combo_slash_2`, `jump_smash`, `charge_thrust`, `shockwave_strike`, `hurt_unshielded`, `death`.

These 20 stable Gameplay families retain their existing counts, FPS, active-frame indices and AI bindings. The same formal SpriteFrames resource also carries the art-contract families `dormant`, `intro`, `approach_shielded`, `shield_hit`, the shield-bash/sword-slash/thrust/heavy-overhead `windup`, `active` and `recovery` splits, `light_hit`, `hurt`, `death_start`, `combo_slash`, and `stagger`. Total: 41 animations / 165 production frames. They provide explicit authored poses without altering the current combat state machine.

Phase 1 uses a shaped peaked tower shield with rim thickness, rivets and the crowned-raven gate crest. Damage overlays permanently progress intact → damaged → critical → broken. Phase 2 is independently redrawn with no shield, an exposed cursed left arm, two-handed grip, cracked crown helm, brighter soul-fire seams and a more severely torn cape. Full concept/equipment sheets and the runtime path are indexed in `../chapter_01_boss_art_bible.md`.

The Gatewarden Greatsword targets an 84–88% full-weapon-to-Boss-height relationship in neutral presentation. It uses a long but restrained guard-longsword blade rather than an oversized fantasy slab: decisive point, old-silver main plane, pale honed edge, dark shadow plane, central ridge, Ravenmourn gate-arch/raven-wing crossguard, wrapped long grip and faceted oath-seal pommel. Phase 2 retains the exact weapon identity and adds only sparse cold-blue curse fissures. Every sword-bearing frame uses the same construction; the visual revision does not alter any saved Hitbox, reach, damage or timing value.

At 60 physics ticks/s, the configured 0.33 + 0.80 sequence completes in 1.1333 s. The reaction cancels if the Player returns to the current front or center tolerance. The existing three-frame authored turn is runtime-scaled to exactly the 0.80-second animation stage; it narrows/twists the torso and draws shield/sword inward before visual and `FacingRoot` commit together at the 80% mark. `ShieldComponent` stores source/Boss position, facing and timestamp at resolution, so contact before that commit keeps the old rear route and subsequent contact uses the new front.

Turn requests are accepted from shielded/unshielded Idle and Approach plus GuardRecovery/Recovery. Attack windup/active direction is locked until Recovery; ShieldBreak, PhaseTransition and Death reject turning. The 12 px threshold plus 0.14 s cooldown prevents center-line jitter. Light or heavy feedback cannot restart, pause, shorten or cancel an active Turn. All attack Hitboxes remain closed throughout Turn. The Attack Gap continues to count during turning, but another windup waits for Turn completion and reevaluates distance. The 1.1333-second response makes one rear Normal stable, a timing-sensitive second possible and a third unavailable in the deterministic 20-trial timing matrix.

Normal Player hits use a 0.32-second lightweight feedback cooldown and never cancel AI, a chosen attack, Turn, Attack Gap, windup or active frames. Dash hits use a 0.50-second heavy-feedback cooldown; only neutral Idle, Approach and normal Recovery can become the 0.12-second Hurt reaction. Turn, the seven Boss attacks, ShieldBreak, PhaseTransition and Death are light/heavy uninterruptible. Recovery Hurt returns to the still-running Attack Gap instead of skipping it. Shield-side hits preserve the same routing/overflow rules and use feedback without body Hurt. `reset_boss()` clears both reaction cooldowns, Turn and Attack-Gap measurement state.

## Post-active counter window

The timer begins on the transition out of the final active frame. Animation follow-through and Turn consume the same timer concurrently, so these values are the complete action-right window rather than extra idle appended to an animation.

| Attack family | Configured gap | Measured at 60 Hz | Phase |
| --- | ---: | ---: | ---: |
| Shield Bash | 1.18 s | 1.183 s | 1 |
| Sword Slash | 1.05 s | 1.050 s | 1 |
| Heavy Overhead | 1.20 s | 1.200 s | 1 |
| Combo Slash, after step 2 only | 1.05 s | 1.050 s | 2 |
| Charge Thrust | 1.12 s | 1.133 s | 2 |
| Jump Smash | 1.16 s | 1.167 s | 2 |
| Shockwave Strike | 1.10 s | 1.100 s | 2 |

Recovery permits 50% movement only when distance adjustment is needed. It cannot begin a new attack early, and a Turn takes priority if the Player crosses behind. The Player timing baseline remains Normal unlock 0.320 s, Normal+reverse-Dash travel 0.500 s, Normal+48 px ground escape 0.620 s and Dash Attack+reverse-Dash travel 0.447 s. All seven gaps passed five deterministic attempts for Dash Attack→reverse Dash and Normal→reverse Dash; Shield Bash, Sword Slash and Heavy Overhead also passed five Normal→48 px movement attempts. A complete three-hit Player chain plus escape exceeds every gap.

## Attack geometry and visual contract

The previous `FacingRoot/MeleeHitbox` was one `100×42` rectangle at `(65,4)`, with a local forward edge of 115 px and an effective actor-root reach of about 126 px after the Player Hurtbox half-width. It served Shield Bash, Slash, Heavy, Combo, Jump and Charge despite their different silhouettes. It did not cross the true actor center, but it greatly exceeded every visible shield/sword tip.

| Family / saved node | Old shape / offset | New shape / offset | Damage-volume forward edge | Effective root distance | Active visual tip |
| --- | --- | --- | ---: | ---: | ---: |
| Shield Bash · `FacingRoot/ShieldBashHitbox` | shared `100×42 @ (65,4)` | `14×30 @ (19,4)` | 26 px | 37 px | 32 px |
| Slash/Heavy/Combo/Jump · `FacingRoot/SlashHitbox` | shared `100×42 @ (65,4)` | `26×22 @ (16,0)` | 29 px | 40 px | 31 px |
| Charge Thrust · `FacingRoot/ThrustHitbox` | shared `100×42 @ (65,4)` | `32×10 @ (20,-7)` | 36 px | 47 px | 41 px |

“Effective root distance” includes the current 11 px Player Hurtbox half-width; the CollisionShape itself ends 6/2/5 px inside the respective visual tips. `FacingRoot.scale.x` mirrors each saved shape with the sprite, no shape reaches behind the Boss center, and only the family selected by the active attack frames is enabled. Expanded Enemy Debug draws all three bounds, active fill, visual-tip reference lines and the live Player Hurtbox; Compact and F1-hidden modes keep it disabled.

## Pressure pass

The pass shortens existing tells by about 8–10%, not by deleting anticipation frames. All effective-frame indices remain unchanged.

| Existing attack | FPS before → after | First active delay before → after | Full animation before → after |
| --- | ---: | ---: | ---: |
| Shield Bash | former 9.8 uniform frames → 10.0 custom durations | 0.204 → 0.460 s | 0.510 → 1.240 s (`0.46 / 0.10 / 0.68`) |
| Sword Slash | 9.0 → 9.8 | 0.222 → 0.204 s | 0.556 → 0.510 s |
| Heavy Overhead / Shockwave | 8.0 → 8.8 | 0.375 → 0.341 s | 0.750 → 0.682 s |
| Combo Slash step 1/2 | 11.0 → 12.0 | 0.182 → 0.167 s | 0.455 → 0.417 s each |
| Jump Smash | 9.0 → 9.8 | 0.333 → 0.306 s | 0.667 → 0.612 s |
| Charge Thrust | 10.0 → 11.0 | 0.200 → 0.182 s | 0.500 → 0.455 s |

The legacy shared 0.42-second field remains only as a defensive fallback for malformed/skipped active-window callbacks. Runtime cadence uses the per-skill active-end gaps above. Shield Bash retains active frames 2–3 but custom per-frame durations author `0.46` windup, `0.10` active and `0.68` recovery; no attack gains a new active frame or higher damage.

## Reset contract

`reset_boss()` restores spawn `(6120,596)`, Body 180, Shield 100, intact Shield overlay, initial left facing, Phase 1, collision, Hurtbox, attack ids/windows, zeroed turn reaction/cooldown, zeroed Attack Gap/timestamps/counter debug, and inactive AI. Before final defeat, Player death/respawn invokes this through `BossRoomController`; after final defeat, reward/gate state persists and the Boss remains defeated.
## Fixed Chapter I reward and scaled target pools

Body/Shield are 180/100. Every outgoing Boss damage and attack timing remains unchanged. The complete Death animation emits `boss_defeated`; Main's independent `BossRewardController` then grants 30 coins once and reveals Ravenfang Daggers at `(6210,592)`. The pickup persists through Player death, auto-equips on E, and must be collected before `CastleEntranceTrigger` loads the threshold. The Boss never rolls the normal-enemy loot table.

The fixed reward uses a restrained coin-bag/text presentation and an original 0.22-second procedural two-tone chime. Headless tests skip audio stream construction; graphical F5 creates it at runtime, so no external audio asset or leaked test playback is introduced.

## Player-behavior adaptation

The Gate Knight observes resolved Player movement/action state, position, velocity,
grounded state, side crossings and a short decaying history. It never reads raw
`Input` state. Observations enter the selector only after a 0.40-second reaction
delay; Phase 2 grows pressure 12% faster while retaining the same delay. Pressure
decays at 0.14 per second, so a fully learned habit clears in about 7.1 seconds.

- Close is `<= 68 px`, Far is `>= 205 px`, and the space between is Mid.
- Repeated airborne crossings bias the existing Heavy Overhead / Jump Smash into
  `Rising Gate Cleave`; the counter candidate is capped at 70%.
- Far play can offer `Gate Severance`, a low, non-homing 285 px/s ground sword
  wave, at 55–70% rather than forcing it. Its 8 damage remains below the Boss's
  heavy attack.
- An attack that has entered windup remains committed. Cooldowns, recovery,
  turn timing and the existing Player-turn gaps still own when the Boss may act.
