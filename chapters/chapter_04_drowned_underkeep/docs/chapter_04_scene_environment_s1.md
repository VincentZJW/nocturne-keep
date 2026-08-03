# Chapter IV Scene & Environment S1 / 第四章场景与环境叙事设计

- Chapter: `Chapter IV: Drowned Underkeep / 第四章：淹没地牢`
- Boss: `Soul Gaoler Ormund / 魂狱看守·奥蒙德`
- Milestone: `CH4-S1`
- Status: **DESIGN COMPLETE / CONCEPT ART REQUIRES USER VISUAL ACCEPTANCE**
- Formal runtime implementation: **NOT STARTED**
- S0 authority: `res://chapters/chapter_04_drowned_underkeep/docs/chapter_04_scene_encounter_s0_audit.md`

This document is the art-direction and environmental-narrative handoff for S2. Concept images are references, not runtime assets; they must never be downscaled into backdrops and presented as finished pixel scenery.

## 1. Chapter intent

### Player fantasy

Descend beneath the Chapel of Thirteen Echoes and discover that the royal prison did not merely confine bodies: it used water pressure, keys, chains and soul cages to force failed sacrifices back into their corpses. The route starts with recognizable chapel remains, becomes an institutional water prison, mutates into a contaminated ecology, then reveals an industrial bureaucracy for imprisoning memory itself.

### Emotional arc

```text
Sacred remnants
  → institutional oppression
  → flooded biological corruption
  → administrative horror
  → monumental soul prison
  → released memory and false moonlight
```

### One memorable moment

After Ormund dies, the same black water that previously reflected prison bars begins reflecting a clean royal corridor from seven years ago. The architecture above the water remains ruined while the reflected architecture is intact, making the route to Chapter V visually impossible but narratively inevitable.

## 2. Macro-zone structure

| Zone | Areas | Visual thesis | Gameplay rhythm | Story reveal |
|---|---|---|---|---|
| A — Sacred runoff | 00–03 | Chapel limestone and faded gold are consumed by wet iron and drainage construction | Transition, shallow-water lesson, first vertical pressure | The chapel disposed of failed rites through this route |
| B — Prison ecology | 04–07 | Patrol galleries, cisterns and drains create layered aquatic habitats | Ranged-platform exam, creature arena, safe room, telegraphed ambush | The prison became an ecosystem around its prisoners |
| C — Soul-gaol institution | 08–11 | Workshop, records, gears and lock seals expose an organized soul-processing system | Elite introduction, mixed vertical combat, machinery pressure, final exam | Imprisonment was recorded and maintained as royal policy |
| D — Ormund and memory | 12–16 | Warm checkpoint contracts into black-iron ceremony, then opens into cyan memory water | Rest, staging, Boss, reward, transition | Ormund guarded both prisoners and the protagonist's buried past |

## 3. Visual language lock

### 3.1 Shape language

- Early chapter: eroded chapel arches and broken circular saint motifs interrupted by square drain mouths.
- Prison body: thick pointed cell arches, repeated vertical bars, riveted doors and heavy horizontal waterlines.
- Water ecology: low round drain openings, swollen cistern vaults, irregular sediment silhouettes and broken stepping stones.
- Soul institution: cages nested inside pointed arches, keyhole geometry, numbered plaques and radial lock mechanisms.
- Boss approach: increasingly symmetrical, oversized architecture with fewer small props and stronger central axes.
- Memory exit: symmetry remains, but hard iron silhouettes dissolve into reflected pale arches and open negative space.

### 3.2 Palette progression

| Palette role | Suggested colour | Use |
|---|---|---|
| Underkeep void | `#080D15` | Deep background and door interiors |
| Wet slate | `#202B38` | Primary masonry shadow |
| Cold limestone | `#566475` | Readable architecture edges |
| Black iron | `#151A22` | Bars, gates, chains and machinery |
| Oxidized teal | `#315C60` | Wet metal and shallow-water midtone |
| Sediment green | `#283E35` | Drainage/ecology accents only |
| Prison rust | `#754535` | Corrosion, warnings and institutional wear |
| Faded chapel gold | `#8D7545` | Areas 00–02 only, diminishing thereafter |
| Safe amber | `#B3834A` | Area 06 and 12 refuge light |
| Soul cyan | `#76B5C1` | Soul cage, Boss and memory accents |
| Memory silver | `#B7C7D2` | Areas 15–16 reflection and Chapter V tease |

No screen should use every accent. Each area receives one dominant accent and one minor counter-accent.

### 3.3 Material progression

1. Chapel limestone, broken saint sculpture, bone dust, parchment and old gold.
2. Wet prison brick, black iron, corroded brass, old oak and restrained leather.
3. Sediment, shallow water, algae traces, drain grates and submerged debris.
4. Precision lock plates, record shelves, soul-glass/cages, giant gear teeth and chain drums.
5. Fractured soul cages, pale memory residue and mirror-like post-Boss water.

### 3.4 Density and combat readability

- One dominant landmark per viewport; other props support it.
- 35–45% clean gameplay negative space.
- Rear architecture may be detailed but stays below actor contrast.
- Platforms use a continuous pale top edge and dark supported underside; decorative ledges use a broken/non-walkable edge language.
- Water body remains behind actors. A narrow 0–4 px foreground lip may overlap feet only.
- Keys, soul flames and door seals are accents, not repeated wallpaper.
- Hanging chains avoid Player head height unless they are behind actors and non-colliding.

## 4. Full route and pacing

```text
00 Drowned Threshold [transition]
  → 01 Flooded Intake [teach]
  → 02 Rusted Cellblock [institution]
  → 03 Broken Chainway [traversal combat]
  → 04 Harpoon Watch Gallery [vertical exam]
  → 05 Cistern of the Changed [ecology climax]
  → 06 Dry Gaoler's Cell [safe / story]
  → 07 Leech Sluice [ambush tension]
  → 08 Gaoler's Workshop [elite]
  → 09 Soul-Cage Registry [truth]
  → 10 Floodgate Engine Hall [machinery climax]
  → 11 Final Lock Approach [combat exam]
  → 12 Last Gaol Checkpoint [recovery]
  → 13 Soul Lock Antechamber [Boss staging]
  → 14 Core of Drowned Gaol [Boss]
  → 15 Broken Soul Reservoir [reward / revelation]
  → 16 Hall of Drowned Memories [Chapter V transition]
```

## 5. Environment narrative matrix

### 00 — Drowned Threshold / 淹没门槛

- **Past use:** Ossuary drainage corridor beneath the Chapel, used to move ritual remains away from public crypts.
- **What happened:** Floodwater erased written prayers and deposited saint fragments against the first prison gate.
- **Current inhabitants:** None; it is protected transition space.
- **Focal image:** A half-submerged saint relief facing a thick barred gate, sacred gold ending at the waterline.
- **Gameplay purpose:** 15–25 seconds of uninterrupted movement; title appears only after crossing the first true prison threshold.
- **Truth revealed:** The chapel and prison were one system, not adjacent accidents.
- **Difference:** Most chapel-like area; warmest residual gold; no soul cyan.

### 01 — Flooded Intake / 淹水引渠

- **Past use:** Intake chamber distributing water between prison sanitation and containment channels.
- **What happened:** A failed floodgate left the floor permanently shallow and converted the maintenance route into a hunting lane.
- **Current inhabitants:** Two Gaolers maintain old patrol habits; a Harpooner watches from a reachable catwalk; a Raider uses the water channel.
- **Focal image:** Broad intake arch and one maintenance catwalk above a clear shallow-water lane.
- **Gameplay purpose:** Teach water readability, platform ranged pressure and a safe retreat line.
- **Truth revealed:** Water level was an intentional disciplinary tool.
- **Difference:** Open and readable; only two effective heights; lower prop density than later rooms.

### 02 — Rusted Cellblock / 锈锁牢区

- **Past use:** General holding cells with an upper gaoler inspection walk.
- **What happened:** Doors rusted shut while prisoners remained restrained; one drain became a Maw nest.
- **Current inhabitants:** Gaolers patrol both levels, a Convict remains near a broken cell, a Penitent blocks the narrow centre and a Maw occupies the drain.
- **Focal image:** Repeating thick cell doors under an upper inspection gallery, broken by one collapsed cell.
- **Gameplay purpose:** Introduce shield routing, elevated non-ranged pressure and telegraphed floor ambush.
- **Truth revealed:** Prisoners were not evacuated when flooding began.
- **Difference:** Repetition and vertical bars dominate; warmer rust replaces chapel gold.

### 03 — Broken Chainway / 断链水廊

- **Past use:** Chain-supported service bridge carrying restraints and food between cell wings.
- **What happened:** Overloaded hoists tore the central bridge apart; improvised stone and timber steps remain.
- **Current inhabitants:** A Gaoler controls the approach, a Harpooner occupies the repaired watch, a Raider moves below and a Toad owns the broad landing.
- **Focal image:** Two broken chain spans framing a stable staged climb above shallow water.
- **Gameplay purpose:** Combine jump route, ranged approach and wide-ground heavy enemy without a pit-death punishment.
- **Truth revealed:** The prison continued operating during structural collapse.
- **Difference:** Most visibly fractured early room; diagonal chains replace cellblock repetition.

### 04 — Harpoon Watch Gallery / 鱼叉瞭望廊

- **Past use:** Elevated observation station for controlling flooded prisoners with tethered harpoons.
- **What happened:** Lower stairs collapsed, but maintenance ladders and hoist decks still connect the gallery.
- **Current inhabitants:** Two Harpooners at staggered heights; Gaoler and Penitent deny direct routes; Raider uses lower water.
- **Focal image:** Twin watch galleries with a central climb and an obvious protected fallback on the ground.
- **Gameplay purpose:** Full ranged-platform mastery; enemies activate sequentially so crossfire is readable.
- **Truth revealed:** Harpoons were prison tools before they became monster weapons.
- **Difference:** Strongest vertical silhouette before the Boss; colder blue iron and fewer cell doors.

### 05 — Cistern of the Changed / 异鳞蓄水池

- **Past use:** Large clean-water reservoir and overflow regulator.
- **What happened:** Bodies, ritual residue and prison waste turned it into the chapter's mutation source.
- **Current inhabitants:** Convict on dry edge, two Raiders in shallow water, one Toad on a low stone island and one telegraphed Maw at an overflow drain.
- **Focal image:** Central reservoir shrine/regulator surrounded by low stepping stones and multiple rear drain mouths.
- **Gameplay purpose:** Creature ecology arena; broad lateral movement, low platforms and no ranged pressure.
- **Truth revealed:** The monsters are a product of the institution's waste stream.
- **Difference:** Widest water surface and lowest architecture; sickly green appears only here and in drains.

### 06 — Dry Gaoler's Cell / 干涸狱卒室

- **Past use:** Private duty room for a record-keeping gaoler.
- **What happened:** The occupant sealed a dry door and copied prisoner names after official ledgers began erasing them.
- **Current inhabitants:** None; safe room.
- **Focal image:** Warm lamp over a handwritten ledger, key board and deliberately dry floor.
- **Gameplay purpose:** Midpoint checkpoint, supply and narrative rest; protected back and clear exit.
- **Truth revealed:** Some staff resisted the soul-erasure policy.
- **Difference:** Smallest room, warm amber, no water body and almost no moving props.

### 07 — Leech Sluice / 蛭潮排水渠

- **Past use:** Waste-water outflow and sediment filter corridor.
- **What happened:** Filters clogged with organic remains; drain mouths became nests.
- **Current inhabitants:** Gaoler and Raider draw attention while two Maws telegraph from separated drains.
- **Focal image:** Repeated low drain arches with visible bubble/sediment warning zones.
- **Gameplay purpose:** Rebuild tension after the safe room; controlled ambush timing and clear sightlines.
- **Truth revealed:** Disposal channels carried more than water.
- **Difference:** Lowest ceiling, strongest horizontal pipes/gutters and least vertical combat.

### 08 — Gaoler's Workshop / 狱卒工坊

- **Past use:** Repair shop for chains, keys, restraints and floodgate components; also an execution preparation space.
- **What happened:** Tools were adapted for soul restraint as ordinary prison hardware failed.
- **Current inhabitants:** Executioner on broad dais, Gaoler and Convict on main floor, Penitent on wide staging deck, Harpooner on reachable maintenance platform.
- **Focal image:** Broad execution/repair dais with a suspended but rear-layer restraint frame.
- **Gameplay purpose:** First elite fight with two-stage Encounter activation and a clear fallback bay.
- **Truth revealed:** Physical punishment and soul confinement merged operationally.
- **Difference:** Dense tool silhouettes and one warm forge remnant; no biological clutter.

### 09 — Soul-Cage Registry / 囚魂档案室

- **Past use:** Administrative archive assigning body, cell and soul-cage numbers.
- **What happened:** Water destroyed paper records while soul cages continued cycling their occupants.
- **Current inhabitants:** Gaoler, Convict, Penitent and elevated Harpooner guard different archive levels.
- **Focal image:** Numbered soul cages beneath an upper record gallery, with one central broken ledger desk.
- **Gameplay purpose:** Mixed vertical combat and narrative reading without foreground cage occlusion.
- **Truth revealed:** Failed sacrifices were catalogued, not mourned.
- **Difference:** Most ordered and bureaucratic room; pale cyan lights repeat in a controlled grid.

### 10 — Floodgate Engine Hall / 水闸机轮厅

- **Past use:** Mechanical heart regulating every prison water level.
- **What happened:** Sabotage or overload bent the primary wheel and locked several gates out of phase.
- **Current inhabitants:** Convict and Penitent protect the mechanism; Raider and two Toads occupy separate water pockets.
- **Focal image:** One monumental Gothic waterwheel with readable gear train and stepped maintenance deck.
- **Gameplay purpose:** Machinery climax; two Toads use staggered Encounter timing; visual water changes never alter collision unexpectedly.
- **Truth revealed:** Mass drowning could be commanded from one station.
- **Difference:** Largest moving architecture; near-symmetrical industrial composition.

### 11 — Final Lock Approach / 终锁前庭

- **Past use:** Last inspection and weapon-clearance avenue before Ormund's domain.
- **What happened:** Every lesser lock was fused into one chain of seals after the soul prison became unstable.
- **Current inhabitants:** Gaoler, Convict and Penitent hold the ground; Harpooner watches from keeper gallery; second Executioner anchors the final group.
- **Focal image:** Long layered avenue of diminishing lock arches ending in a distant sealed Boss gate.
- **Gameplay purpose:** Two Encounter final exam: core roles first, Executioner pressure second; never five active at once.
- **Truth revealed:** The lower prison was designed to protect the world from what it held—or protect the secret from the world.
- **Difference:** Most severe perspective and negative space; almost no small props.

### 12 — Last Gaol Checkpoint / 末狱检查点

- **Past use:** Ormund's final guard station and key verification desk.
- **What happened:** It remained dry because the Boss gate isolated it from flood pressure.
- **Current inhabitants:** None; checkpoint.
- **Focal image:** One warm lamp, an empty key rest and the silhouette of the Boss gate ahead.
- **Gameplay purpose:** Full recovery and a 6–10 second uninterrupted approach.
- **Truth revealed:** Ormund once entered through ordinary procedure before becoming part of the lock.
- **Difference:** Warm but austere; fewer personal traces than Area 06.

### 13 — Soul Lock Antechamber / 魂锁前厅

- **Past use:** Ceremonial verification chamber for transferring soul cages into the core.
- **What happened:** Ormund's key-halberd and prison crown motifs became incorporated into the sealed gate.
- **Current inhabitants:** None; Boss staging.
- **Focal image:** Massive circular keyhole mechanism inside a layered pointed gate, flanked by empty cages.
- **Gameplay purpose:** Boss identity, music transition and explicit interaction; flat floor, no platform clutter.
- **Truth revealed:** Ormund is both gaoler and living key.
- **Difference:** Monumental symmetry and cold cyan accents; no rust-orange clutter.

### 14 — Core of the Drowned Gaol / 溺狱核心

- **Past use:** Central pressure reservoir and soul-lock anchor.
- **What happened:** Ormund fused with the mechanism to prevent the cages from rupturing.
- **Current inhabitants:** Ormund only.
- **Focal image:** Broad shallow mirror around a central chained soul-prison crown and three monumental floodgate recesses.
- **Gameplay purpose:** Clear flat Boss arena; water and gates support known mechanics without hiding telegraphs.
- **Truth revealed:** Ormund's cruelty and duty are the same action seen from different victims.
- **Difference:** Widest controlled negative space, strongest cyan light, zero ordinary props in the combat centre.

### 15 — Broken Soul Reservoir / 破魂蓄池

- **Past use:** Buffer reservoir for souls displaced during transfer.
- **What happened:** Ormund's death releases cages and memory fragments; water loses its prison-bar reflection.
- **Current inhabitants:** None; reward space.
- **Focal image:** Broken cage silhouettes rising from calm water while pale memories drift toward one reflected corridor.
- **Gameplay purpose:** Reward pickup, aftermath and unhurried truth reveal.
- **Truth revealed:** One released memory belongs to the protagonist's actions seven years ago.
- **Difference:** First space where cyan light becomes pale silver and architecture visually opens.

### 16 — Hall of Drowned Memories / 溺忆回廊

- **Past use:** Royal maintenance corridor deliberately removed from prison maps.
- **What happened:** Released memory overlays its intact seven-year-old form onto the drowned present.
- **Current inhabitants:** None; Chapter V transition.
- **Focal image:** Ruined upper corridor mirrored as an intact moonlit royal hall in the water, ending at a sealed memory door.
- **Gameplay purpose:** 15–30 second enemy-free transition and formal Chapter V placeholder.
- **Truth revealed:** The protagonist has already walked this route during the Night Repeated.
- **Difference:** Highest brightness, longest reflection and least visible prison iron; does not construct Chapter V beyond the sealed gate.

## 6. Lighting and dynamic-effect assignment

| Area | Primary light | Main dynamic effect | Processing rule |
|---|---|---|---|
| 00 | Fading chapel gold | Slow runoff and washed prayer fragments | Active only in threshold room |
| 01 | Cold intake reflection | Footstep/Dash ripples | Current room only |
| 02 | Rust lamp + blue spill | Sparse chain sway, drain bubbles | Current room only |
| 03 | Cyan water bounce | Chain drip and broken-span runoff | Current room only |
| 04 | Cold gallery lamps | Hoist-chain sway, distant drip | Current room only |
| 05 | Reservoir cyan-green | Broad local highlights, creature wake support | Current room only |
| 06 | Single safe amber | Lamp flicker only | No ambient particles |
| 07 | Drain sick-green | Bubble telegraphs, drain flow | Current room only |
| 08 | Forge amber vs cyan | Restraint chain sway | Current room only |
| 09 | Soul cyan grid | Slow soul movement inside cages | Current room only |
| 10 | Teal machinery spill | Waterwheel, flow strips, gate motion | Current room only; reduced motion supported |
| 11 | Sparse lock cyan | Slow seal pulse | Current room only |
| 12 | Warm checkpoint | Lamp flicker | Always cheap; no particles |
| 13 | Cold soul seal | Boss gate lock sequence | Only during interaction |
| 14 | Cyan core | Water/gate/Boss-response FX | Boss room only |
| 15 | Pale soul silver | Cage fragments and memory water shift | Sequence-bound |
| 16 | Moon-silver reflection | Slow memory ripple | Transition room only |

## 7. S2 art-production invariants

1. Build modular formal pixel assets from this direction; do not crop or downscale concept boards into runtime backgrounds.
2. Every walkable surface has a matching visual top and separate collision owner.
3. Doors are rear frame + moving panel + narrow front trim; the moving panel remains behind Player/Enemies.
4. Water is split into rear body, local highlight and narrow front lip.
5. Platforms show structural support and a clear access route; no floating slabs.
6. Soul cages have rear body and contained FX; no full-height foreground cage.
7. Each room uses one dominant landmark and a bounded prop kit.
8. Chapel gold disappears gradually rather than instantly; memory silver appears only after the Boss.
9. Runtime textures use nearest filtering, lossless import and no mipmaps.
10. S2 ends with usable modular assets, not scene assembly or Encounter placement.

## 8. S1 stop condition

The route, narrative function, visual progression, focal composition, palette, material language and dynamic-effect assignment are locked. Five original concept boards and the S2 asset manifest exist. No formal environment Sprite, scene assembly, collision, water/door runtime, Encounter layout or Main change is part of S1.
