# Chapter IV Environment Concept Manifest / 第四章环境概念板清单

- Milestone: `CH4-S1`
- Generation mode: OpenAI built-in `image_gen` tool
- Input images: none
- External/licensed assets: none
- Intended use: S2 art-direction reference only
- Runtime use: prohibited

## 1. Saved concept boards

| ID | Path | Dimensions | SHA-256 | Coverage |
|---|---|---:|---|---|
| CONCEPT-01 | `res://chapters/chapter_04_drowned_underkeep/assets/concept_art/environment/chapter_04_environment_visual_identity.png` | 1536×1024 | `d1d6cd2861f5c2fa12ecaba32e97f9575233b9e9f5072fc110df8ed2abd6cfa4` | Chapter-wide material/palette progression |
| CONCEPT-02 | `res://chapters/chapter_04_drowned_underkeep/assets/concept_art/environment/chapter_04_early_route_concept.png` | 1536×1024 | `486b86a61f00a87e2e7fdec66d44bfe090e975c09ae8373c0b2c434b39d1651f` | Areas 00–03 |
| CONCEPT-03 | `res://chapters/chapter_04_drowned_underkeep/assets/concept_art/environment/chapter_04_middle_route_concept.png` | 1536×1024 | `4335bbd06d30254fab42c02314e33f7e6e4ed326b76b6492cec07c68363003c9` | Areas 04–07 |
| CONCEPT-04 | `res://chapters/chapter_04_drowned_underkeep/assets/concept_art/environment/chapter_04_late_route_concept.png` | 1536×1024 | `124ae40ec26c2a9d9a1d925c182cd97dbca5000c7a749e40695f7b9bf93c10ef` | Areas 08–11 |
| CONCEPT-05 | `res://chapters/chapter_04_drowned_underkeep/assets/concept_art/environment/chapter_04_boss_memory_route_concept.png` | 1536×1024 | `e2509e6421197d5cee198413f5556dc610091dd26126d80641f834b6d53c7e05` | Areas 12–16 |

## 2. Visual self-review

| Board | Composition | Story identity | Gameplay readability | S2 translation note | Status |
|---|---|---|---|---|---|
| Visual identity | Four strong material stages; rear architecture and waterline remain distinct | Sacred remains → prison → ecology → soul institution reads without labels | Side-view baselines are clear; density is deliberately aspirational | Reduce micro-detail into modular clusters; preserve palette/material progression | PASS |
| Early route | Chapel transition, intake, cellblock and broken bridge are clearly different | Establishes that prison infrastructure grew out of chapel drainage | Main paths and staged vertical access read; no isolated floating perch | Preserve thick supports and broken-chain diagonals; avoid copying ornamental density wholesale | PASS |
| Middle route | Gallery, cistern, safe cell and sluice each have one visual centre | Safe room's preserved names contrast with biological corruption | Gallery access and cistern negative space read; safe room is unmistakably non-combat | S2 needs explicit 128–160 px gameplay platforms and narrower safe-room composition | PASS |
| Late route | Execution dais, registry grid, waterwheel and final lock have strong silhouettes | Physical punishment becomes administrative soul imprisonment | Major combat floors remain visible; some upper detail must stay rear-layer | Convert cages/shelves into bounded modules; preserve clear ground lane | PASS |
| Boss/memory | Refuge → gate → broad core → released memory creates a complete cadence | Ormund as living lock and Chapter V memory reveal are readable | Boss centre is broad/flat; post-Boss path is uncluttered | Keep Boss props outside centre; reflection requires separate runtime layers | PASS |

These PASS results mean “usable art-direction references”, not “formal scene art accepted”. User visual acceptance remains required before S2 turns the direction into runtime assets.

## 3. Exact generation prompt set

### CONCEPT-01 — visual identity

```text
Use case: stylized-concept
Asset type: game environment concept art direction board for a 2D side-scrolling action game
Primary request: Create an original four-panel visual identity board for Chapter IV, Drowned Underkeep: a Gothic medieval royal prison beneath a ruined chapel, gradually transformed into a flooded soul-gaol.
Scene/backdrop: panel 1 chapel ossuary stone eroded by water and sacred bone fragments; panel 2 rusted prison masonry, barred cells, keys and chains; panel 3 black-green shallow cistern water, drainage mouths and mutated aquatic traces; panel 4 soul cages, floodgate machinery and drowned memory reflections.
Style/medium: high-detail 16-bit-inspired pixel art environment concept, crisp deliberate pixel clusters, production-quality game art, side-view orthographic language rather than painterly realism.
Composition/framing: wide landscape board divided into four clean scene panels, each readable as a side-scrolling gameplay viewport; reserve 35–45 percent clear gameplay negative space and show layered rear architecture, walkable ground, midground props and a very narrow foreground water edge.
Lighting/mood: cold blue-black and oxidized teal base, desaturated rust and old iron, fading chapel gold at the beginning, pale cyan soul light near the end; oppressive, mournful, damp, not neon.
Materials/textures: wet limestone, rusted iron, corroded brass, old oak, shallow dark water, sediment, chains, fractured reliquary stone.
Constraints: original design only; no characters; no enemies; no text; no labels; no logos; no watermark; no simple graybox geometry; no flat vector shapes; no modern sewer pipes; no high-saturation magic; no full-height foreground occlusion.
```

### CONCEPT-02 — early route

```text
Use case: stylized-concept
Asset type: game environment concept art for Chapter IV early route of a 2D side-scrolling action game
Primary request: Create an original four-panel production concept sheet showing the early route of Drowned Underkeep in chronological order: Drowned Threshold, Flooded Intake, Rusted Cellblock, Broken Chainway.
Scene/backdrop: Drowned Threshold must visibly transition from a flooded chapel ossuary with washed-away prayers and broken saint stone into black-iron prison architecture; Flooded Intake shows a shallow-water main path and one reachable maintenance platform; Rusted Cellblock shows barred cells, an upper gaoler patrol gallery and a telegraphed floor drain; Broken Chainway shows a collapsed chain-supported walkway over shallow water with a safe staged climbing route.
Style/medium: high-detail 16-bit-inspired pixel art environment concept, crisp intentional pixel clusters, production-quality side-view game environment, not painterly realism and not vector geometry.
Composition/framing: wide landscape board, four distinct side-scrolling gameplay-view panels; architecture has thickness and believable supports; preserve 35–45 percent clean combat space; exits and climb routes visually legible without labels.
Lighting/mood: fading chapel gold transitions into cold slate-blue, black iron, rust orange and muted green water; damp, mournful, oppressive.
Materials/textures: eroded chapel limestone, sacred bone fragments, wet prison brick, heavy barred doors, riveted iron, old oak walkways, chains, shallow water reflections and sediment.
Constraints: original design only; no characters; no enemies; no text; no labels; no logos; no watermark; no simple rectangles, Line2D-like bars or empty graybox rooms; no modern sewer aesthetic; no impossible floating platforms; no scenery that would cover actor bodies.
```

### CONCEPT-03 — middle route

```text
Use case: stylized-concept
Asset type: game environment concept art for Chapter IV middle route of a 2D side-scrolling action game
Primary request: Create an original four-panel production concept sheet showing Harpoon Watch Gallery, Cistern of the Changed, Dry Gaoler's Cell, and Leech Sluice.
Scene/backdrop: Harpoon Watch Gallery has two staggered but reachable iron-and-stone platforms, ladders and a clear ground fallback lane; Cistern is a broad shallow-water chamber with low stepping stones, drain mouths, drowned restraints and one strong reservoir focal point; Dry Gaoler's Cell is a protected dry checkpoint with old keys, ledger, narrow warm lamp and evidence of a gaoler who tried to preserve prisoner names; Leech Sluice is a low drainage corridor with readable bubbling ambush grates, maintenance ledges and clear sightlines.
Style/medium: high-detail 16-bit-inspired pixel art environment concept, crisp intentional pixel clusters, production-quality side-view game environment, not painterly realism and not flat vector art.
Composition/framing: wide landscape board divided into four gameplay-view panels; each room has one distinct visual centre, believable structural thickness and 35–45 percent combat or rest negative space; platform chains are visibly reachable without impossible floating geometry.
Lighting/mood: cold cyan water reflections and black iron in combat spaces; a restrained warm amber refuge in the safe cell; sickly desaturated green only around drains.
Materials/textures: damp limestone, rusted galleries, riveted catwalks, shallow water, sediment, prison ledgers, worn keys, drainage grates, restrained corpses under water only as subtle narrative silhouettes.
Constraints: original design only; no characters; no enemies; no text; no labels; no logos; no watermark; no gore focus; no modern sewer; no simple graybox; no inaccessible ranged perches; no large foreground object blocking gameplay.
```

### CONCEPT-04 — late route

```text
Use case: stylized-concept
Asset type: game environment concept art for Chapter IV late-route prison infrastructure in a 2D side-scrolling action game
Primary request: Create an original four-panel production concept sheet showing Gaoler's Workshop, Soul-Cage Registry, Floodgate Engine Hall, and Final Lock Approach.
Scene/backdrop: Workshop centres on a broad execution dais, complete restraint machinery, keys and tool racks, with a reachable maintenance platform that never obstructs combat; Registry centres on numbered soul cages and water-damaged prisoner records, with an upper archive gallery; Engine Hall centres on one enormous Gothic waterwheel and floodgate gear train with readable ground and stepped maintenance deck; Final Lock Approach is a severe black-iron avenue with a high keeper gallery, layered lock seals and two sequential combat pockets leading to a distant Boss gate.
Style/medium: high-detail 16-bit-inspired pixel art environment concept, crisp intentional pixel clusters, production-quality side-view game art, not painterly realism and not vector geometry.
Composition/framing: wide landscape board with four distinct side-scrolling gameplay panels; one focal structure per panel; believable supports, thick platforms and clear entrances/exits; preserve 35–45 percent negative combat space.
Lighting/mood: deep slate, iron black, oxidized teal and subdued rust; pale cyan soul fire as controlled accents; increasingly monumental and oppressive toward the final lock.
Materials/textures: wet masonry, riveted black iron, old wood, restraint leather, engraved prisoner plaques, corroded gears, wet chains, caged pale soul flame.
Constraints: original design only; no characters; no enemies; no text; no labels; no logos; no watermark; no simple line weapons or empty geometric shelves; no modern industrial machinery; no excessive clutter; no large foreground cages hiding actors; no impossible platform access.
```

### CONCEPT-05 — Boss and memory route

```text
Use case: stylized-concept
Asset type: game environment concept art for Chapter IV Boss staging and Chapter V transition in a 2D side-scrolling action game
Primary request: Create an original four-panel production concept sheet showing Last Gaol Checkpoint, Soul Lock Antechamber, Core of the Drowned Gaol Boss arena, and the post-Boss Broken Soul Reservoir flowing into Hall of Drowned Memories.
Scene/backdrop: Checkpoint is a small defensible gaoler station with a restrained warm lamp and a clear six-to-ten-second path to the Boss door; Antechamber centres on a massive layered soul-lock gate with Ormund's key-halberd and cage motifs but no combat clutter; Boss arena is broad and flat with shallow water, monumental chained floodgates and a huge empty central combat silhouette, no ordinary enemies; post-Boss reservoir shows broken soul cages releasing pale memory fragments as water reflects a different royal corridor from seven years earlier, ending at a sealed Chapter V gate.
Style/medium: high-detail 16-bit-inspired pixel art environment concept, crisp intentional pixel clusters, production-quality side-view game art, not painterly realism and not flat vector geometry.
Composition/framing: wide landscape board with four panels; entrances, exits and flat Boss combat area readable; architecture has physical thickness; 40 percent negative gameplay/staging space; post-Boss reflection is surreal but structurally coherent.
Lighting/mood: checkpoint warm amber refuge, antechamber cold black iron, Boss arena cyan soul-light and deep blue water, memory corridor pale moon-silver with faint old royal gold; tragic and revelatory, not triumphant.
Materials/textures: wet carved prison stone, massive riveted iron gate, soul cages, chained reservoirs, engraved lock seals, shallow reflective water, fractured memory glass-like reflections.
Constraints: original design only; no Boss character; no Player; no enemies; no text; no labels; no logos; no watermark; no simple rectangle gate; no neon effects; no giant foreground obstruction; no Chapter V full environment beyond a distant sealed memory doorway.
```

## 4. Runtime exclusion contract

Automated S2/S7 checks must confirm that none of the five concept PNG paths appears in `.tscn`, `.tres` or gameplay `.gd` resources. They are composition/material references only. Runtime art must be rebuilt from low-resolution, modular Chapter IV-owned pixel structures.
