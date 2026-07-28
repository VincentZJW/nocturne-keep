# Chapter III Enemy Art Bible / 第三章敌人美术规范

Status: **Stage 1 formal-art replacement complete — accepted concepts retained; all 415 Phase 2 runtime frames replaced by layered role-specific v2 art and verified through MainBootstrap**

## Art pillars

1. **Ritual object fused with victim:** every silhouette is organized around one chapel object, not a generic weapon swap.
2. **Restrained gothic palette:** blackened iron, ash cloth, old copper, bone wax, dried wine and desaturated glass remain readable against dark chapel masonry.
3. **Telegraph is part of the body:** bell swing, censer lift, sealed mouth/halo, folding glass wings, moving confessional door and writing hand announce the attack.
4. **Six silhouettes at thumbnail scale:** widths, height, posture, negative space and held objects remain distinct at 48×48 preview.
5. **Formal native pixel work:** no anti-aliased vector stand-in, recolored prior enemy, empty frame or generated file unused by the eventual Main SpriteFrames.

## Production format

- Concept art: original native pixel illustration, recommended 256×256 RGBA PNG, transparent background, full body and complete signature object.
- Silhouette/proportion sheet: recommended 192×192 RGBA PNG, transparent background, pure silhouette plus Player 64 px comparison guide.
- Gameplay animation frames: 64×64 RGBA PNG, transparent background, fixed origin and foot/hover baseline.
- Preview: 48×48 nearest-neighbor readability check; it is QA output, not a second production source.
- Godot display: `CanvasItem.texture_filter = TEXTURE_FILTER_NEAREST` (`texture_filter = 1`) on Sprite nodes; project default is `textures/canvas_textures/default_texture_filter=0` (Nearest). PNG import must not enable filtering or mipmaps.
- Animation cadence baseline from the current game: idle 4 FPS, grounded movement 8 FPS, alerts/attacks 10–12 FPS, hurt 12–16.67 FPS, death 8–9 FPS. Per-attack timing remains state-driven and must match the authored visual frame window.

The concepts may be produced with an in-repository Godot `Image` generator in Phase 1, but must be drawn as deliberate pixel clusters rather than smooth Polygon/Line2D compositions. No online asset, commercial character copy or unverifiable source is permitted.

## Shared Chapter III palette

| Swatch | Suggested value | Use |
|---|---|---|
| Chapel Void | `#090B12` | deepest gaps and face voids |
| Ash Cloth | `#292B34` | robes and charred fabric |
| Cold Iron | `#4B5561` | masks, lead, weapon structure |
| Bone Wax | `#D0C7B6` | readable faces, parchment, attack tips |
| Old Copper | `#8A6540` | bells, censers and ritual fittings |
| Dried Wine | `#6D2F3B` | controlled blood/royal accent |
| Glass Blue | `#496779` | restrained glass/spectral energy |
| Incense Ember | `#B45F42` | tiny active-fire cues only |

Each enemy selects five to seven colors plus transparency and may add one role-specific accent. Pale/bright pixels are reserved for eyes, attack edges and telegraphs; large bright bodies would destroy chapel readability.

## Silhouette separation matrix

| Enemy | Height/width | Posture | Signature negative space | Signature object |
|---|---|---|---|---|
| Penitent | medium/narrow | stooped pendulum | chain arc beside torso | throat bell + short prayer bell |
| Executioner | tall/very wide | planted, forward drag | large gap inside two-hand chain | floor-dragging censer |
| Chorister | medium/narrow | feet lifted, sleeves down | open book triangle | hymn book + broken halo |
| Seraph | medium/wide airborne | rigid icon | broken wing gaps | glass wings + pointed halo |
| Wraith | tall when emerged/narrow | leaning from booth | missing legs | timber grille + long arms |
| Scribe | tallest/thin | writing bend | scroll loop | face parchment + rear ledger |

## Enemy-specific visual contracts

### Bellchain Penitent

- Grey-black penitential robe, wrapped or metal-covered head, sealed mouth and copper throat bell.
- One hand controls a short chain; prayer bell remains visibly separate from the wrist and body.
- `chain_lash`: chain silhouette extends horizontally only after the shoulder/bell counter-swing.
- `bell_slam`: overhead/forward lift ends at a visible ground contact point.
- `chain_pull`: a taut narrow chain, not a full-screen hook; maximum visual reach matches the later hit/pull lane.

### Censer Executioner

- Largest Chapter III ground body, black execution hood, burnt apron and charred forearms.
- Censer is a heavy pierced iron volume with restrained ember pixels and thick two-hand chain.
- Sweep uses a low horizontal arc; crush raises the censer above the hood; smoke release visibly opens the censer before the bounded cloud appears.
- Smoke boundary uses a low contrast outer contour plus brighter inner ember points so the hazard remains readable without hiding enemies.

### Silent Chorister

- Wax-sealed/no-mouth face, torn choir robe, long sleeves and damaged hymn book.
- Feet remain just off the ground; incomplete bell halo is asymmetric and never resembles a generic mage ring.
- Straight wave and crescent wave use distinct silhouettes and leave visible gaps.
- Hush Field uses a thin floor/space bell-ring border; no opaque full-screen fog.

### Stained-Glass Seraph

- Black lead skeleton divides restrained dark-blue/wine/old-gold glass; pale face remains mask-like.
- Broken wing shapes differ from Gargoyle anatomy and expose angular gaps.
- Volley closes wings and lights shard origins; dive folds wings into an arrow shape and shows a separate landing marker.
- Ground Vulnerable is visibly cracked and collapsed; Return restores panes progressively.

### Confessional Wraith

- Booth and entity are one visual set: carved dark timber, grille-divided face, black-smoke drapery and pale arms.
- Hidden state still exposes a slightly moving door; Emerge never deals damage before the telegraph completes.
- Only Hidden/Retreat may reduce opacity. Attack, Hurt and Stagger remain solid/readable.

### Thirteenth Scribe

- Bone-white name parchment covers the face; narrow robe, quill fingers, waist scroll and large back ledger.
- Ink Lance reads as a straight line with a finite head, not a generic fireball.
- Seal Write shows hand/ground correspondence; delayed seal has a stable perimeter and one activation burst.
- Paper Ward is one page-like shield in front, visually absent after it consumes a hit.

## Required Phase 1 asset paths

| Enemy | Concept PNG | Silhouette PNG |
|---|---|---|
| Penitent | `assets/enemies/bellchain_penitent/concept_art/bellchain_penitent_concept.png` | `assets/enemies/bellchain_penitent/concept_art/bellchain_penitent_silhouette.png` |
| Executioner | `assets/enemies/censer_executioner/concept_art/censer_executioner_concept.png` | `assets/enemies/censer_executioner/concept_art/censer_executioner_silhouette.png` |
| Chorister | `assets/enemies/silent_chorister/concept_art/silent_chorister_concept.png` | `assets/enemies/silent_chorister/concept_art/silent_chorister_silhouette.png` |
| Seraph | `assets/enemies/stained_glass_seraph/concept_art/stained_glass_seraph_concept.png` | `assets/enemies/stained_glass_seraph/concept_art/stained_glass_seraph_silhouette.png` |
| Wraith | `assets/enemies/confessional_wraith/concept_art/confessional_wraith_concept.png` | `assets/enemies/confessional_wraith/concept_art/confessional_wraith_silhouette.png` |
| Scribe | `assets/enemies/thirteenth_scribe/concept_art/thirteenth_scribe_concept.png` | `assets/enemies/thirteenth_scribe/concept_art/thirteenth_scribe_silhouette.png` |

All paths are relative to `res://chapters/chapter_03_chapel_of_thirteen_echoes/`. Phase 1 created all twelve PNGs at these exact paths. The concepts are 256×256 RGBA and the silhouette/proportion sheets are 192×192 RGBA.

## Phase 1 provenance and production handoff

- Each concept was generated specifically for this project from the enemy-specific contract above using the built-in image generation workflow; no downloaded art, commercial-game character, real religious portrait or previous-chapter enemy image was used as an input.
- The source generation used a flat chroma-key field. The repository asset was locally keyed, hard-alpha cleaned, nearest-neighbor fitted to the 256×256 production canvas and visually inspected before acceptance.
- Each silhouette sheet is deterministically derived from its accepted concept alpha, uses the planned native gameplay height, and includes the existing 64 px Night Warden silhouette as a blue-grey scale guide. The ochre line is a shared foot/hover baseline, not a runtime platform asset.
- `docs/qa/chapter_03_enemy_phase_01/` preserves one concept/silhouette/48 px comparison sheet per enemy plus the six-enemy overview and the full authenticity manifest.
- These concepts are the mandatory visual source for the later Phase 2A–2F 64×64 SpriteFrames. A later Sprite that abandons the signature silhouette/object contract fails the handoff gate.

## Implemented animation families

Common where applicable: `idle`, `move` or `hover`, `alert`, `turn`, `light_hit`, `stagger`, `hurt`, `death`. Each named attack uses distinct `_windup`, `_active` and `_recovery` animations so the state/Hurtbox QA can identify its phase without guessing from a monolithic clip.

- Penitent: `chain_lash_*`, `bell_slam_*`, `chain_pull_*`.
- Executioner: `censer_sweep_*`, `overhead_crush_*`, `smoke_release_*`.
- Chorister: `silent_wave_*`, `crescent_hymn_*`, `hush_field_cast`, `hush_field_active`.
- Seraph: `window_dormant`, `detach`, `shard_volley_*`, `dive_*`, `ground_crash`, `ground_vulnerable`, `return_to_air`, `glass_death`.
- Wraith: `hidden`, `door_telegraph`, `emerge`, `emerging_slash_*`, `spectral_dash_*`, `scream_*`, `retreat`.
- Scribe: `ink_lance_*`, `seal_write`, `seal_delay`, `seal_activate`, `binding_script_*`, `paper_ward`.

The formal Stage 1 runtime assets live under each enemy's `sprites/` and `animations/` directories. Bellchain Penitent owns 70 frames; the remaining five roles own 345 frames. The previous Phase 2 sources were preserved for the initial comparison commit and then deleted after user approval; historical visual comparisons remain under `docs/qa/chapter_03_enemy_art_rework/`. The deterministic v2 generator uses hand-authored role polygons, clustered material highlights, curved chains, pierced objects, irregular cloth hems and equipment-specific effects rather than the former rectangular masks. It also writes one three-pose action reference and one effects reference per role.

The formal SpriteFrames paths are unchanged intentionally: scenes already referenced the correct chapter-local resources, so replacing every source PNG at the stable formal path updates isolated tests and the Main route together. The deprecated archive no longer exists and no SpriteFrames contains a legacy path. Current acceptance evidence belongs under `res://docs/qa/chapter_03_enemy_art_rework/`.

The obsolete Phase 2A and Phase 2B–2F art generators were removed with the deleted sources so they cannot overwrite the formal v2 frames. `generate_chapter_03_enemy_art_v2.gd` is the only supported Chapter III enemy-art generator.

## Authenticity QA gate used for Phase 2

For every required PNG, QA must record path, dimensions, byte size, SHA-256, alpha bounds and opaque/nontransparent pixel count. PASS also requires:

1. complete readable body and signature object;
2. non-empty/nontransparent content;
3. six distinct silhouettes at thumbnail size;
4. documented relation between concept and planned Sprite;
5. no first/second-chapter recolor and no protected character copy;
6. nearest-neighbor screenshot evidence.

The earlier Phase 2 set passed file/scene existence but fails the later visual-quality gate because geometry dominated the body and representative active frames lacked readable action change. Stage 1 therefore treats it as deprecated rather than retroactively calling it formal art. The v2 set must pass both deterministic integrity and the new concept/old/new/Main screenshot review defined in `chapter_03_enemy_sprite_quality_spec.md`; subjective final acceptance remains with the user.
