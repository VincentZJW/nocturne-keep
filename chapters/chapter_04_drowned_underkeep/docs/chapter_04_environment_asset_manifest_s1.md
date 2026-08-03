# Chapter IV S2 Environment Asset Manifest / 第四章环境资产生产清单

- Milestone owner: `CH4-S1` design handoff
- Consumer: `CH4-S2` formal pixel-asset production
- Status: **LOCKED FOR PRODUCTION / no runtime asset produced in S1**
- Base structural grid: 16 px detail grid, 32 px architecture grid
- Runtime rules: transparent PNG where modular; nearest filtering; lossless; no mipmaps; integer placement

## 1. Source classification

| Class | Assets | Decision |
|---|---|---|
| Reuse | Formal Player, eight Chapter IV enemy/elite scenes, Ormund, projectile/combat FX, HUD | Reuse unchanged; scene art must preserve their contrast and scale |
| Adapt | Chapter III Underkeep descent's wet-chapel language and presentation-only ripple concepts | Use as continuity reference; create Chapter IV-owned derivatives rather than cross-linking Chapter III-specific art |
| Adapt | Shared water-step/Dash/landing event hooks if compatible | Reuse code contract later; produce Chapter IV water art in Chapter IV folders |
| New | All formal Chapter IV walls, floors, cells, platforms, catwalks, cistern, floodgate, doors, narrative props, Boss architecture and memory transition | Required in S2 |
| Archive/reference only | `environment/threshold` and `environment/character_trial` backdrops | Retain until formal replacement is validated; do not use as S2 final room art |

No asset is licensed from an external pack. S1 concept boards were generated as original project-bound direction using the built-in image-generation workflow; S2 runtime pixels will be redrawn as deterministic project-owned assets.

## 2. Production batches

| Batch | Scope | Exit evidence |
|---|---|---|
| S2-A | Shared masonry, floors, water layers, structural arches and prison bars | Modular assembly board at 1280×720; no graybox required for primary surfaces |
| S2-B | Early/middle route platforms, cells, cistern, drainage and safe-room props | Areas 00–07 asset contact sheet and readability mockups |
| S2-C | Workshop, registry, machinery, final-lock, Boss and memory architecture | Areas 08–16 contact sheet and Boss-scale mockup |
| S2-D | Doors and dynamic FX sequences | Frame manifests, collision/presentation handoff and reduced-motion notes |
| S2-E | Import/scale/layer QA | Dimensions, alpha, nearest/no-mipmap audit and actor-overlay boards |

## 3. Core environment modules

### 3.1 Walls and architecture

Target folder: `assets/environment/walls/`

| ID | Asset | Suggested canvas | Variants | Areas | Priority |
|---|---|---:|---:|---|---|
| WALL-01 | Wet prison brick seamless module | 256×256 | 3 | 01–13 | P0 |
| WALL-02 | Eroded chapel limestone module | 256×256 | 2 | 00–02 | P0 |
| WALL-03 | Drainage masonry module | 256×256 | 2 | 05,07,10 | P0 |
| WALL-04 | Soul-gaol carved stone module | 256×256 | 2 | 09,11,13–15 | P0 |
| WALL-05 | Memory-overlay pale royal stone | 256×256 | 2 | 15–16 | P1 |
| WALL-06 | Thick pointed prison arch | 256×256 | 3 spans | 01–13 | P0 |
| WALL-07 | Chapel-to-prison transition arch | 320×256 | 1 | 00 | P0 |
| WALL-08 | Collapsed vault edge/cap | 256×128 | 4 | 00,03,07 | P1 |
| WALL-09 | Rear recess set | 128×192 | 4 | 01–12 | P1 |
| WALL-10 | Lock-seal buttress | 160×256 | 2 | 11,13–14 | P1 |

### 3.2 Floors

Target folder: `assets/environment/floors/`

| ID | Asset | Suggested canvas | Variants | Areas | Priority |
|---|---|---:|---:|---|---|
| FLOOR-01 | Wet flagstone strip | 256×64 | 4 | 00–13 | P0 |
| FLOOR-02 | Shallow-water channel bed | 256×64 | 3 | 01,03,05,07,10,14–16 | P0 |
| FLOOR-03 | Drain grate floor strip | 128×64 | 3 | 01,05,07,10 | P0 |
| FLOOR-04 | Execution slab strip | 256×64 | 2 | 08,11 | P1 |
| FLOOR-05 | Dry checkpoint stone | 256×64 | 2 | 06,12–13 | P0 |
| FLOOR-06 | Soul-core engraved floor | 256×64 | 3 | 13–15 | P1 |
| FLOOR-07 | Memory reflection walkway | 256×64 | 2 | 15–16 | P1 |
| FLOOR-08 | Broken edge/endcaps | 64×64 | 6 | 03,05,07 | P0 |

### 3.3 Flooded-cell modules

Target folder: `assets/environment/flooded_cells/`

| ID | Asset | Canvas | Variants | Areas | Priority |
|---|---|---:|---:|---|---|
| CELL-01 | Thick barred cell front | 128×160 | intact/open/bent | 01–03 | P0 |
| CELL-02 | Half-submerged cell alcove | 160×160 | 2 | 02,05 | P1 |
| CELL-03 | Collapsed cell opening | 160×160 | 2 | 02,07 | P1 |
| CELL-04 | Upper inspection cell bay | 192×160 | 2 | 02,04 | P0 |
| CELL-05 | Waterline wall trim | 256×32 | 4 | 01–05,07 | P0 |
| CELL-06 | Submerged restraint silhouette | 96×48 | 3 | 05 | P2 |

## 4. Platforms and traversal structures

### 4.1 Stone platforms

Target folder: `assets/environment/platforms/`

| ID | Asset | Widths | Structure | Intended users | Priority |
|---|---|---|---|---|---|
| PLAT-01 | Maintenance stone ledge | 96/128/160×32 | Wall brackets + underside | Harpooner/light | P0 |
| PLAT-02 | Wide prison dais | 160/224×48 | Columns + dark underside | Penitent/Convict | P0 |
| PLAT-03 | Execution platform | 256×64 | Stone base + restraint anchors | Executioner | P0 |
| PLAT-04 | Cistern stepping stones | 48/64/96×24 | Submerged bases | Player/creatures | P0 |
| PLAT-05 | Final-lock keeper gallery | 160×48 | Lock buttress support | Harpooner | P1 |
| PLAT-06 | Boss arena edge shelf | 192×32 | Recessed wall support | Staging only | P1 |

### 4.2 Catwalks and access pieces

Target folder: `assets/environment/catwalks/`

| ID | Asset | Canvas | Variants | Use | Priority |
|---|---:|---:|---|---|---|
| CAT-01 | Riveted iron catwalk | 128×48 | 96/128/160 lengths | Ranged platforms | P0 |
| CAT-02 | Old oak prison walkway | 128×48 | intact/cracked | 02–04 | P0 |
| CAT-03 | Chain-supported bridge span | 160×96 | intact/broken-left/broken-right | 03 | P0 |
| CAT-04 | Wall maintenance stairs | 128×96 | left/right | Mandatory access | P0 |
| CAT-05 | Short ladder | 32×96 | iron/oak | Optional visual/access where controller exists | P1 |
| CAT-06 | Hoist platform | 160×64 | 2 | 04,08 | P1 |
| CAT-07 | Platform support/bracket set | 64×64 | 8 | All platforms | P0 |
| CAT-08 | Non-walkable decorative ledge | 128×32 | 3 broken profiles | Rear architecture only | P1 |

Every formal platform receives a visual/collision contract and a documented top width. Decorative ledges must not share the continuous walkable top-edge treatment.

## 5. Cistern and drainage set

### 5.1 Cistern

Target folder: `assets/environment/cistern/`

| ID | Asset | Canvas | Variants | Priority |
|---|---:|---:|---:|---|
| CIS-01 | Reservoir regulator shrine | 256×256 | intact/corrupted | P0 |
| CIS-02 | Overflow drain mouth | 96×96 | round/square/barred | P0 |
| CIS-03 | Spillway arch | 192×160 | 2 | P1 |
| CIS-04 | Sediment bank/endcap | 128×64 | 4 | P1 |
| CIS-05 | Submerged chain anchor | 64×64 | 3 | P2 |
| CIS-06 | Low cistern divider | 128×64 | 2 | P1 |

### 5.2 Drainage

Target folder: `assets/props/drainage/`

| ID | Asset | Canvas | Variants | Priority |
|---|---:|---:|---:|---|
| DRAIN-01 | Ambush drain mouth | 96×80 | closed/telegraph/open | P0 |
| DRAIN-02 | Wall gutter | 128×48 | 3 | P1 |
| DRAIN-03 | Valve and handwheel | 48×64 | 3 | P1 |
| DRAIN-04 | Floor grate | 64×32 | intact/bent/broken | P0 |
| DRAIN-05 | Drain pipe termination | 64×64 | 4 | P1 |
| DRAIN-06 | Sediment/debris cluster | 64×32 | 6 | P2 |

## 6. Floodgate machinery

Target folder: `assets/environment/floodgate/` and `assets/props/waterwheels/`

| ID | Asset | Canvas | Frames/variants | Priority |
|---|---:|---:|---:|---|
| GATE-01 | Monumental Gothic waterwheel | 256×256 | 8 rotation frames | P0 |
| GATE-02 | Main gear train | 256×192 | 4 phase frames | P0 |
| GATE-03 | Chain drum and axle | 128×96 | idle/turn | P1 |
| GATE-04 | Floodgate housing | 256×256 | 2 | P0 |
| GATE-05 | Sluice channel module | 256×96 | 3 | P0 |
| GATE-06 | Waterwheel support pier | 128×192 | 2 | P0 |
| GATE-07 | Maintenance control desk | 96×96 | intact/broken | P1 |
| GATE-08 | Gear/chain small prop kit | 64×64 | 8 | P2 |

Machinery animation is presentation-only in S2. S4/S5 must synchronize any moving collision or water-state gameplay explicitly; visuals alone cannot imply a physics change.

## 7. Narrative prop kits

### 7.1 Prison bars and chains

| Folder | ID group | Required items |
|---|---|---|
| `assets/props/prison_bars/` | BAR-01..06 | wall bars, cell-front endcaps, bent bars, floor grates, inspection rail, barred recess |
| `assets/props/chains/` | CHAIN-01..08 | short/medium/long hanging chain, wall restraint, snapped chain, hoist chain, floor coil, anchor link |

Bars are sprites with thickness and fixtures, never Line2D. Chain sprites use a limited sway animation only for selected rear-layer instances.

### 7.2 Keys and records

| Folder | ID group | Required items |
|---|---|---|
| `assets/props/keys/` | KEY-01..06 | wall key board, ring set, ceremonial key, empty hook, lock plate, broken key pile |
| `assets/props/records/` | REC-01..08 | ledger desk, open ledger, shelf modules, numbered plaques, loose pages, soaked records, registry cabinet, erased-name tablet |

### 7.3 Workshop and restraint props

| Folder | ID group | Required items |
|---|---|---|
| `assets/props/torture_tools/` | TOOL-01..09 | broad restraint table, execution block, rear-layer rack, hook board, chain press, restraint chair, tool wall, leather straps, broken mechanism |
| `assets/props/crates/` | STORE-01..06 | wet crate variants, iron-bound box, barrel, broken crate, prison supply stack |
| `assets/props/corpses/` | REMAIN-01..05 | covered remains, submerged silhouette, empty restraint outline, bone bundle, collapsed prison uniform |

These props communicate use without gore focus. Large devices remain behind actors and cannot become invisible walls.

## 8. Soul-cage set

Target folder: `assets/props/soul_cages/`

| ID | Asset | Canvas | Variants/frames | Priority |
|---|---:|---:|---:|---|
| SOUL-01 | Standard numbered soul cage | 64×96 | intact/empty/cracked | P0 |
| SOUL-02 | Registry wall cage bay | 128×128 | 3 number motifs | P0 |
| SOUL-03 | Suspended transfer cage | 80×112 | 4 sway frames | P1 |
| SOUL-04 | Broken post-Boss cage | 96×96 | 4 break states | P0 |
| SOUL-05 | Soul-glass containment core | 48×64 | 6 inner-motion frames | P0 |
| SOUL-06 | Cage floor/ceiling mounts | 64×32 | 4 | P1 |
| SOUL-07 | Ormund-scale empty cage | 128×160 | 2 | P1 |

Cage body sits behind actors (`z=-30` where practical); soul FX uses gameplay-safe `z=16` only when it is a telegraph, otherwise remains rear presentation.

## 9. Doors and gates

| Folder | ID | Asset | Canvas | States | Priority |
|---|---|---|---:|---|---|
| `assets/doors/cell_doors/` | DOOR-01 | Thick barred cell door | 96×144 | closed/open/bent | P0 |
| `assets/doors/rusted_gates/` | DOOR-02 | Room isolation gate | 128×176 | closed/opening/open | P0 |
| `assets/doors/floodgates/` | DOOR-03 | Vertical floodgate | 160×192 | closed/half/open | P0 |
| `assets/doors/boss_gate/` | DOOR-04 | Soul-lock outer frame | 256×256 | rear frame | P0 |
| `assets/doors/boss_gate/` | DOOR-05 | Soul-lock moving panel | 192×224 | sealed/unlocking/open | P0 |
| `assets/doors/boss_gate/` | DOOR-06 | Soul-lock seal core | 96×96 | 8 frames | P0 |
| `assets/doors/chapter_exit/` | DOOR-07 | Memory gate frame | 192×224 | present/reflective | P1 |
| `assets/doors/chapter_exit/` | DOOR-08 | Sealed Chapter V panel | 128×192 | sealed only | P1 |

Each door set separates rear frame, moving panel, narrow front trim, interaction core and collision authority. No complete door receives foreground z.

## 10. Boss and memory environment

### 10.1 Boss area

Target folder: `assets/environment/boss_area/`

| ID | Asset | Canvas | Priority |
|---|---:|---:|---|
| BOSSENV-01 | Drowned-gaol core backdrop module | 512×320 | P0 |
| BOSSENV-02 | Chained prison-crown landmark | 256×256 | P0 |
| BOSSENV-03 | Monumental floodgate recess | 256×256 | P0 |
| BOSSENV-04 | Boss shallow-water bed/highlight strips | 256×64 | P0 |
| BOSSENV-05 | Arena edge architecture | 192×192 | P1 |
| BOSSENV-06 | Last-checkpoint desk/lamp/key rest | 128×128 | P1 |
| BOSSENV-07 | Antechamber empty-cage set | 96×144 | P1 |

### 10.2 Memory transition

Target folder: `assets/environment/memory_transition/`

| ID | Asset | Canvas | Frames/variants | Priority |
|---|---:|---:|---:|---|
| MEM-01 | Broken Soul Reservoir architecture | 512×256 | 1 | P0 |
| MEM-02 | Ruined drowned corridor module | 256×256 | 2 | P0 |
| MEM-03 | Intact reflected royal corridor | 256×128 | 3 | P0 |
| MEM-04 | Memory water body/highlight | 256×96 | 6 frames | P0 |
| MEM-05 | Released memory fragment | 32×32 | 8 forms × 4 frames | P1 |
| MEM-06 | Reflection transition mask/edge art | 256×64 | 4 frames | P1 |

The reflected royal hall is a Chapter V tease only. It cannot include Chapter V enemies, interactables or a complete playable room.

## 11. Dynamic FX manifests

| Folder | ID group | Required sequences | Priority |
|---|---|---|---|
| `assets/fx/water/` | WFX-01..05 | rear water body, local highlight, 0–4 px front lip, flow strip, drain foam | P0 |
| `assets/fx/ripples/` | RFX-01..05 | step, landing, Dash, enemy wake, idle local ripple | P0 |
| `assets/fx/drips/` | DFX-01..04 | droplet, wall run, impact ring, sparse drip sheet | P1 |
| `assets/fx/chains/` | CFX-01..03 | rear chain sway, snapped-chain settle, hoist vibration | P1 |
| `assets/fx/soul_fire/` | SFX-01..04 | idle soul flame, pulse, released wisp, memory fragment | P0 |
| `assets/fx/soul_cage/` | SCFX-01..04 | contained drift, cage strain, crack leak, post-Boss release | P0 |
| `assets/fx/floodgate/` | GFX-01..05 | gear dust, chain strain, water surge, gate seal, lock spark | P1 |

FX constraints:

- No full-screen particles.
- No opaque water rectangle above actors.
- Soul cyan must not compete with attack telegraphs.
- Non-current room animation/process is disabled.
- Reduced-motion mode may freeze decorative chain sway and lower waterwheel speed without affecting gameplay.

## 12. Asset density packages by room

| Area | Dominant landmark | Medium assets | Small accents | Dynamic effect |
|---|---|---|---|---|
| 00 | Transition saint/gate | ossuary arch, runoff channel | bone, parchment, gold trim | runoff |
| 01 | intake arch | catwalk, regulator, grate | valve, chain, sediment | step/Dash ripple |
| 02 | cell frontage | inspection gallery, collapsed cell | keys, shackles, plaque | chain + drain bubbles |
| 03 | broken chain bridge | stair pier, watch deck | snapped links, debris | bridge runoff |
| 04 | twin watch galleries | central climb, hoist | hooks, rail fixtures | hoist sway |
| 05 | cistern regulator | stepping stones, drains | restraint, sediment | broad water highlight |
| 06 | ledger desk/lamp | key board, cot | names, empty hook | lamp flicker |
| 07 | drain-mouth rhythm | maintenance ledges, gutter | grates, debris | ambush bubbles |
| 08 | execution dais | maintenance platform, tool wall | keys, straps, crates | rear chain sway |
| 09 | numbered cage archive | upper gallery, ledger desk | plaques, records | cage soul drift |
| 10 | giant waterwheel | gear train, floodgate | valve, chain drum | wheel/flow |
| 11 | distant Boss gate | keeper gallery, lock arch | seal plates | seal pulse |
| 12 | final guard station | Boss-door vista | key rest, ledger | lamp flicker |
| 13 | soul-lock gate | empty cage pair | lock motifs | unlock sequence |
| 14 | prison crown/core | floodgate recesses | edge anchors only | core water response |
| 15 | broken cage reservoir | reward plinth, reflected hall | cage fragments | memory release |
| 16 | reflected royal corridor | sealed memory door | pale remnants | memory ripple |

## 13. S2 acceptance checklist

- [ ] Every P0 module exists as an original pixel asset in the declared Chapter IV folder.
- [ ] Contact sheets show intended scale beside the formal Player and at least one Chapter IV enemy.
- [ ] Wall/floor/platform modules tile or join without unintended seams.
- [ ] Walkable and decorative ledges are visually distinct.
- [ ] All Harpooner platform widths (128–160 px plans) can be assembled from the kit with supported undersides.
- [ ] Water is split into rear body/highlight/front lip.
- [ ] Doors are split into frame/panel/trim/core and have state frames.
- [ ] Soul cages do not require foreground occlusion.
- [ ] Boss arena art preserves a broad flat centre.
- [ ] Memory transition does not accidentally become Chapter V production.
- [ ] Texture imports are lossless, nearest and mipmap-free.
- [ ] Concept boards remain unreferenced by runtime scenes.
