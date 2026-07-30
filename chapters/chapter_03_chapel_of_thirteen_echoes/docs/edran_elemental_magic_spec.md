# Edran elemental magic specification

Date: 2026-07-30
Runtime: Godot 4.7.1, `MainBootstrap -> Chapter03Route -> CH3_BOSS`

## Combat intent

The elemental rites extend Edran's existing two-phase encounter without replacing the crozier, censer, necromancy or Phase 2 attack families. Magic is deliberately selected through the same bounded action scheduler, so it cannot bypass turn commitment, phase transitions, stagger, death, summon cleanup or the existing major-action recovery rules.

## Summon cadence

| Rule | Phase 1 | Phase 2 |
|---|---:|---:|
| Summon cooldown | 6.2–7.4 s | 4.8–6.0 s |
| Interrupted retry | 3.0 s | 3.0 s |
| Living summon cap | 2 | 3 |
| Choir Husk cap | 1 | 1 |
| Actors created per cast | 1 | 1 |

Summon, elemental magic and existing major attacks share selection interlocks. Summon cannot be selected consecutively, is blocked while the Player is frozen, and leaves a 1.60 s major-action lock. Transition and death clear every summon.

## Elemental rites

### Cinder Absolution

- 0.58 s windup, 0.18 s direction lock, 0.72 s recovery.
- 8 direct damage.
- Applies a three-second burn: 5 damage at one-second intervals, exactly three ticks.
- Reapplying burn refreshes one timer; it never creates parallel damage stacks.
- Boss cannot select fire while the Player is already burning.

### Litany of Stillness

- 0.72 s windup, 0.20 s direction lock, 0.84 s recovery.
- 7 direct damage.
- Applies full freeze for 3.0 s, then 5.0 s freeze immunity.
- Freeze cancels current Player actions, blocks movement/actions/interactions, and uses safe gravity/collision processing rather than bypassing CharacterBody2D.
- Boss cannot select ice while the Player is frozen, when too many summons are active, or while freeze immunity prevents application.
- Freeze exit plays a short formal shatter animation before hiding the shell.

### Mire of the Unburied

- 2.0 s total cast; the target follows until 1.15 s, then locks in place.
- The field lasts 4.5 s.
- Inside the field, movement is multiplied by 0.35 and dash speed by 0.70.
- Only one Edran mire field may be active. It uses source-aware refresh/clear semantics.
- Mire is rejected while two or more danger fields are active, and existing large-area rites are restricted while mire/freeze pressure is present.

## Unified Player status ownership

`PlayerStatusEffectController` is the only owner of burn, freeze, freeze immunity and mire timers. It emits apply/refresh/change/expire signals. `PlayerStatusHUD` observes these signals; it never stores authoritative gameplay values. Death, respawn and chapter room transition call `clear_all()`.

Status visuals are transparent nearest-neighbour pixel SpriteFrames under `res://shared/assets/status_effects/`. Boss magic art, projectiles and field art remain Chapter III-local under the Edran asset folder.

## AI selection and safety rules

- One global magic cooldown per phase plus independent per-spell cooldowns.
- The same elemental spell cannot be selected twice in succession.
- Phase 1 weights: summon 22, fire 18, ice 10, mire 10, existing actions 40.
- Phase 2 weights: summon 27, fire 18, ice 13, mire 15, existing actions 27.
- Ineligible actions are removed before weighted selection; weights are not a promise of exact short-run percentages.
- Phase transition, death and stagger interruption close attack volumes, stop spell sequences and clean transient magic nodes.
- Frozen and post-freeze grace suppress high-pressure area combinations; Scripture Burial and Fourteenth Seat are also guarded against unsafe overlaps.

## Formal assets and runtime scenes

- Concept: `assets/bosses/thirteenth_pontiff_edran/concept_art/edran_elemental_rites_concept_board.png`
- Boss magic frames: `assets/bosses/thirteenth_pontiff_edran/magic_phase_01/` and `magic_phase_02/`
- Spell VFX: `assets/bosses/thirteenth_pontiff_edran/effects/`
- Spell scenes: `scenes/bosses/spells/`
- Player status art: `res://shared/assets/status_effects/`

All production visuals are generated on low-resolution transparent canvases with hard pixel edges. The spell runtime uses Sprite2D/AnimatedSprite2D resources; it does not use ColorRect, Line2D or Polygon2D as formal spell art.

## Debug and manual acceptance

Use Chapter III Debug Start with one of:

- `CH3_BOSS_MAGIC_TEST`: normal mixed elemental selection.
- `CH3_BOSS_FIRE_TEST`: fire presentation and burn contract.
- `CH3_BOSS_ICE_TEST`: freeze, shatter and immunity.
- `CH3_BOSS_MIRE_TEST`: telegraph tracking/lock and slow field.
- `CH3_BOSS_SUMMON_MAGIC_COMBO`: Phase 2 summon-plus-magic pressure.
- `CH3_BOSS`: full encounter.

Restore debug chapter start to disabled after testing. Automated checks certify deterministic rules and regressions; timing feel, fairness and readability remain manual playtest acceptance.
