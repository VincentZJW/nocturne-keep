# Night Warden Core Character Art Specification

Version: 1.0

Date: 2026-07-28

Status: Stage 2 visually accepted; Stage 3 Candle Warden work not started

## Character identity

The Night Warden is the last Veilbound Night Oath: an adult gothic assassin restored by a soul-contract mark seven years after death. The production silhouette combines a pointed black hood, narrow face opening, damaged short cape, layered leather/dark-steel torso, long mobile legs and two clearly separated daggers. The design is deliberately slimmer than an armored Castle Guard but no longer childlike or chibi.

## Scale and origin contract

- Runtime canvas: 64×64 transparent PNG.
- Visible idle bounds: source rows 4–60, 57 px high.
- Chapter I Castle Guard reference: 58 px high.
- Production ratio: `57 / 58 = 98.28%`, inside the approved 95–105% band.
- Shared foot baseline: source row `y=60`; rows 61–63 are transparent padding.
- Sprite node scale remains `(1, 1)` and texture filtering remains nearest-neighbor.
- Body collision remains 24×52 at y=2; Hurtbox remains 22×50 at y=2.
- Normal and Dash Attack Hitboxes remain 42×14 at x=29/y=-3 and 58×16 at x=37/y=-3.

The visual rebuild does not change movement speed, gravity, jump velocity, dash distance, attack timing, damage, camera offset, Health or stamina.

## Palette and material separation

| Role | Color | Use |
| --- | --- | --- |
| Hood Black | `#08101A` | hood, deepest cloth and boot shadow |
| Midnight Navy | `#172B3D` | main cloth and leather mass |
| Moonlit Slate | `#607A90` | armor planes, bracers and structure |
| Pale Steel | `#D5DEE3` | blade edge, eye slit and critical highlights |
| Muted Amber | `#B98243` | restrained oath clasp, belt and weapon accent |

Secondary dark blue-gray values separate hood, chest, arms, legs and short cape in night scenes without introducing saturated color noise.

## Formal concept assets

Master boards and ten production crops live under `res://shared/assets/player/concept_art/`. The two master boards define adult proportions, front/side/back/three-quarter consistency, garment construction, silhouette, Chapter I Guard scale, action poses and all three dagger families. Cropped deliverables preserve editable project organization while avoiding duplicate divergent art direction.

## Formal runtime assets

Three complete body-and-weapon sets live under:

- `res://shared/assets/player/animations/veilbound/`
- `res://shared/assets/player/animations/ravenfang/`
- `res://shared/assets/player/animations/crimson_masque/`

Each exposes the same 30 animation names, frame counts, anchors and body anatomy. Equipment changes therefore replace only the authored weapon/material variant, not Player proportions.

Weapon silhouettes:

- Veilbound: straight short blade, readable guard, dark wrapped grip and restrained amber pommel.
- Ravenfang: hooked crow-talon blade, black grip and wing-like blue-black furniture.
- Crimson Masque: longer ceremonial thrust blade, porcelain/steel highlight, explicit guard and small crimson mask accent.

## Presentation routing

`PlayerAnimationController.select_attack_variant()` routes combo step 1/2/3 into the established logical `attack` slot immediately before playback. This preserves the existing action-state and hit-window API while providing three distinct silhouettes. Double jump now requests the authored `double_jump` one-shot, with the former `jump_start` behavior retained only as a missing-resource fallback.

The Prologue uses eight unarmed revival textures under `res://shared/assets/player/revival/`. `RevivalPlayerArt` keeps the existing controller cues and position offsets but no longer constructs the protagonist from geometric rectangles and lines. Dagger pickup still reveals the same formal shared Player scene.

## Effects

- `night_warden_ghost_hooded_face.png`: shared death/revival soul identity.
- `ground_dash_dust.png`: restrained ground contact reference.
- `double_jump_soul_crack.png`: short cold-blue soul-contract reference.

The formal death controller continues to own body fall, dagger separation, ghost rise, pause and respawn timing.

## Historical assets

Earlier `res://assets/sprites/player/assassin/` and weapon-specific frame trees remain as provenance/reference material. Active SpriteFrames resources no longer reference those roots; the Stage 2 deterministic audit verifies `legacy_refs=0`. Historical sources are deliberately retained as non-runtime reference because earlier approved animation work required those key poses to remain available.

## Stage 2 acceptance result

Stage 2 passed on 2026-07-28. The QA verified native Chapter I scale, all required locomotion/combat/hurt/death poses, released daggers, hooded ghost, three weapon adaptations and shared Prologue/Chapter I–III routing. Evidence and exact results are recorded in `res://docs/qa/core_character_art_rework/stage_2/stage_2_report.md`.

The next gate is Stage 3 Candle Warden work and is not part of this specification's accepted Player scope.
