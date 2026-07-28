# Chapter III Enemy Sprite Quality Specification

Status: Stage 1 production gate passed on 2026-07-28; subjective 1× playtest acceptance remains with the user

## Non-negotiable runtime standard

The formal 64×64 frame—not the 256×256 concept—is the acceptance target. Every animation family must preserve a readable head, torso, separate limbs, layered clothing/armor and the role's signature object. Rectangular dolls, single-pixel line weapons and palette-only role swaps fail.

## Structure and material gate

- Minimum three structural layers per role: body/vestment, secondary garment or armor, signature object/equipment.
- Material highlights are clustered and directional: cold steel/lead uses pale edge pixels; cloth uses long fold clusters; bone/paper uses warm off-white with dirty shadow; copper uses dark brown body plus ochre rim; glass uses colored panes separated by black lead; spirits use controlled translucent layers.
- Bright pixels are reserved for face slits, glass edges, attack tips, embers and telegraph glyphs. Large pale rectangles are forbidden.
- Ground roles keep feet at y=58–60. Airborne roles keep their stable hover center. Death can leave the baseline but must preserve identifiable equipment before dissolution.

## Per-role runtime identifiers

| Role | Mandatory visible identifiers | Attack-motion requirement |
|---|---|---|
| Bellchain Penitent | asymmetric wrapped mask, bolted mouth cage, throat bell, layered torn robe, separate prayer bell | curved segmented chain and readable bell endpoint |
| Censer Executioner | stitched pointed hood, massive shoulders/arms, iron apron, chain belt, pierced ember censer | censer lifts/sweeps/slams as a weighted volume; smoke opens from it |
| Silent Chorister | wax-sealed faceless mask, broken halo, long floating choir layers, expressive sleeves, open codex | book/hands open; straight wave, crescent and field are distinct |
| Stained-Glass Seraph | sacred mask/crown, reliquary torso, asymmetric colored panes, black lead skeleton | wing spread/fold and glass shards remain readable against dark rooms |
| Confessional Wraith | Gothic timber booth, grille, pale death-mask, long claws, layered spectral stole | spirit visibly emerges/retracts; booth remains part of silhouette |
| Thirteenth Scribe | paper-wrapped written face, narrow clerk vestment, ledger, bone quill, seals | quill/scroll/rune actions retain paper and ink material cues |

## Animation gate

Every role must replace `idle`, `walk` or hover movement, `alert`, `turn`, all attack `_windup/_active/_recovery` clips, `light_hit`, `stagger`, `hurt` and `death`; Wraith must also replace `hidden`. A single polished idle with legacy attacks fails. SpriteFrames names, counts, FPS and gameplay timing remain unchanged in this art-only milestone.

## Import and display gate

- Production files are transparent RGBA 64×64 PNGs.
- Runtime Sprite node: `AnimatedSprite2D`, Nearest filtering, whole-pixel scale/position.
- No mipmap or smoothing dependency. Existing `.import` sidecars must reimport the replaced source bytes.
- All formal frame textures must resolve under `assets/enemies/<role>/sprites/`; no formal SpriteFrames texture may resolve under `reference/deprecated_phase_2/`.

## Evidence gate

PASS requires: per-role concept/old/new comparison, sprite action preview, actual Main idle/attack capture, six-role combination capture, all-frame integrity test, independent scene smoke, MainBootstrap route, and zero parser/resource/runtime red errors. Subjective visual acceptance remains a user review gate even when deterministic tests pass.
