# Chapter III Structural Rework — R1 Room Plan

Date: 2026-07-29

Scope: R1 spatial planning only

Plan status: **PASS**

Runtime implementation status: **NOT STARTED — R2 approval required**

This document converts the R0 findings into a build-ready room plan. It does not create or modify scenes, scripts, Resources, assets, collisions, layers, Main routing or gameplay values.

## 1. Planning decision

Chapter III will stop being one `12784×720` horizontal canvas. The approved R2 target is one persistent chapter route scene with one persistent gameplay runtime and independently instantiable room scenes inside a `RoomHost`.

```text
Chapter03Route
├── RoomHost                         # exactly one active room instance
├── PersistentRuntime
│   └── ChapterRuntime               # exactly one Player, RespawnController and HUD
├── Chapter03RoomTransitionController
├── Chapter03EncounterCoordinator
└── Chapter03Presentation
```

The chapter-local transition controller will swap room PackedScenes under full Fade while the existing Player, Health, Stamina, HUD and Camera remain alive. `SceneTransitionManager` remains the authority for Chapter II → III and Chapter III → IV whole-scene travel. It will not be duplicated or repurposed as enemy/room gameplay logic.

This choice satisfies the current architecture better than full `change_scene` per room:

- Player HP, Stamina, temporary state and HUD do not reset at every internal door;
- there is never more than one Player, HUD or active room;
- every environment room remains independently instantiable for collision and art QA;
- local coordinates replace the current x4200/x6000/x9200 hard joins;
- a Boss room can be an independent PackedScene without sitting beside the organ hall on one canvas.

Planned route-root path for R2: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn`.

The current `chapter_03_entry_placeholder.tscn` remains authoritative until R2. R1 does not change `ChapterRegistry` or the Start Profile.

## 2. New route map

```text
Chapter II Royal Chapel Passage
        │  physical mirror-back door + global Fade
        ▼
┌──────────────────────────────────────────────────────┐
│ A · CH3_CHAPEL_VESTIBULE · 2048×720                │
│ safe arrival → title → central emblem → nave door   │
│                            └─ 512 px descending stair│
└──────────────────────────────────────────────────────┘
        │  E-open door → walk short stair → local Fade
        ▼
┌──────────────────────────────────────────────────────┐
│ B · CH3_NAVE_ENTRY · 2304×720                       │
│ ground route + two mid galleries + one high ledge   │
│ Bellchain/Wraith teaching → Scribe ranged teaching  │
└──────────────────────────────────────────────────────┘
        │  E-open choir screen → local Fade
        ▼
┌──────────────────────────────────────────────────────┐
│ C · CH3_CHOIR_GALLERY · 2432×720                    │
│ organ + choir seats + reachable maintenance deck    │
│ Executioner/Chorister → Seraph air punish lesson    │
└──────────────────────────────────────────────────────┘
        │  physical vestry door → local Fade
        ▼
┌──────────────────────────────────────────────────────┐
│ D · CH3_BOSS_CHECKPOINT · 896×720                   │
│ safe checkpoint, prayer bench, no enemy or platform │
└──────────────────────────────────────────────────────┘
        │  E-open confession arch → local Fade
        ▼
┌──────────────────────────────────────────────────────┐
│ E · CH3_BOSS_ANTE · 1664×720                        │
│ carpet + two bell saints + 13 tablets + blank XIV   │
│                                  → unique Boss gate  │
└──────────────────────────────────────────────────────┘
        │  E-confirmed Gate of the Thirteenth Echo
        │  gate ritual → Fade Out → room swap
        ▼
┌──────────────────────────────────────────────────────┐
│ F · CH3_BOSS · 3200×720                             │
│ independent flat sanctum, intro first, combat second│
└──────────────────────────────────────────────────────┘
        │  Boss-death exit door → local Fade
        ▼
  PostBossReliquary → rusted descent gate/stair → UnderkeepDescent
```

No connector uses a black void, invisible boundary teleport or background hard cut. A player crossing an internal boundary always sees a physical door/stair structure before Fade.

## 3. Room scene and Camera contract

All positions below are local room coordinates. The shared floor top is `y=612`, matching the current Player foot baseline. Every transform and collision dimension must use integer pixels and scale `1,1`.

| ID | Planned PackedScene | Size / Camera bounds | Debug spawn | Room purpose |
|---|---|---:|---:|---|
| `CH3_CHAPEL_VESTIBULE` | `scenes/rooms/ch3_chapel_vestibule.tscn` | `2048×720`, `(0,0)..(2048,720)` | `(128,584)` | Safe Chapter II→III arrival and visual-language hand-off |
| `CH3_NAVE_ENTRY` | `scenes/rooms/ch3_nave_entry.tscn` | `2304×720`, `(0,0)..(2304,720)` | `(128,584)` | Ground-first combat and ranged-platform teaching |
| `CH3_CHOIR_GALLERY` | `scenes/rooms/ch3_choir_gallery.tscn` | `2432×720`, `(0,0)..(2432,720)` | `(128,584)` | Organ/choir identity and multi-height combat |
| `CH3_BOSS_CHECKPOINT` | `scenes/rooms/ch3_boss_checkpoint.tscn` | `896×720`, `(0,0)..(896,720)` | `(128,584)` | Safe reset and pressure release |
| `CH3_BOSS_ANTE` | adapted `scenes/areas/ch3_boss_antechamber.tscn` | `1664×720`, `(0,0)..(1664,720)` | `(160,584)` | Boss warning, confession story and explicit entry choice |
| `CH3_BOSS_GATE` | adapted `scenes/areas/ch3_boss_gate_transition.tscn` | `384×512` component inside the ante | no standalone spawn | E-confirmed physical boundary; not a separate Camera room |
| `CH3_BOSS` | adapted `scenes/areas/ch3_boss_sanctum.tscn` | `3200×720`, `(0,0)..(3200,720)` | `(240,584)` | Independent flat Boss arena and intro |
| `CH3_POST_BOSS` | existing reliquary, isolated in `RoomHost` | `1280×720` | `(128,584)` | Quiet reward hand-off |
| `CH3_UNDERKEEP_DESCENT` | existing descent, isolated in `RoomHost` | `2304×720` | `(128,584)` | Physical descent and Chapter IV boundary |

`CH3_VESTIBULE` remains accepted as a Debug alias for `CH3_CHAPEL_VESTIBULE`, but the room id and saved-scene name use the full form. The Start Profile should expose the six required QA ids only when their corresponding saved rooms exist in R2.

Each room will own this shallow structure:

```text
Chapter03Room
├── FarBackground
├── BackgroundArchitecture
├── PropsBehindActors
├── GroundAndPlatforms
│   ├── Visuals
│   └── Collision
├── Encounters
├── InteractablesAndDoors
├── SpawnPoints
├── CameraBounds
├── LimitedForeground
└── RoomController
```

Room scenes do not own a Player, HUD, respawn controller or global transition singleton. Door controllers emit typed destination requests; the route root performs the swap.

## 4. Room A — Chapel Vestibule redesign

### Spatial composition

The room is exactly `1.6` viewports wide, including a `512 px` stair threshold. The actual vestibule composition occupies x0..1536 (`1.2` viewports); x1536..2048 is the physical connecting stair.

| Zone | Local span | Composition and purpose |
|---|---:|---|
| Chapter II arrival | `x=0..384` | Mirror-back ceremonial door at x96..304; broken Silent Court carpet ends here; Player enters facing right |
| Waiting/prayer center | `x=384..1152` | Main ribbed vault, two formal pillar groups, two waiting benches, small baptismal font and cracked thirteen-bell floor emblem centered at x768 |
| Nave exit | `x=1152..1536` | Prayer lectern, right wall division and a readable physical nave door centered at x1424 |
| Threshold stair | `x=1536..2048` | Six shallow descending stone steps, side wall/ceiling, reduced light and Fade trigger at x1960; never presented as empty black space |

Selected medium assets: two waiting benches, one baptismal font, one prayer lectern and one torn carpet. Selected small assets: three prayer pages, one broken court crest, one dry censer and wall water stains. Dynamic assets are limited to two wall-candle loops, one light tapestry movement and the single title-bell tremor.

The only main visual focus is the central cracked floor emblem beneath the chapter title. The left mirror-back door and right nave door remain clear directional anchors. There are no enemies, elevated platforms or hidden traps.

### Narrative read

The room was where courtiers washed, waited and surrendered court identity before entering the chapel. The torn Chapter II carpet ends before the baptismal font; abandoned pages and dragged footprints continue toward the nave. This makes the transition from royal performance to compulsory confession legible without filling every wall.

## 5. Room B — Nave Entry layout

### Ground and platforms

The floor is continuous from x0..2304 at `y=612`; the main route never requires a jump. Platforms create optional pressure lanes and pursuit routes, not traversal gates.

| Surface | x span | Top y | Width | Route check | Use |
|---|---:|---:|---:|---|---|
| `WestSideGallery` | `520..680` | `552` | 160 | floor rise 60 ≤ 62.83 | first ranged teaching / safe punish landing |
| `EastSideGallery` | `1400..1560` | `552` | 160 | floor rise 60 ≤ 62.83 | ranged warning and attack space |
| `EastAccessCorbel` | `1632..1728` | `492` | 96 | gap 72 ≤ 107.51; rise 60 | traversal-only step, no enemy |
| `UpperArchiveLedge` | `1760..1904` | `432` | 144 | gap 32; rise 60 | Scribe position, full turn/Normal/Dash Attack space |

There are three effective combat height bands: floor, side galleries and high archive ledge. `EastAccessCorbel` is a connector, not a fourth combat tier. All required heights are reachable with ordinary single jumps; double jump and Air Dash remain convenience rather than progression requirements.

### Encounter rhythm

1. `NAVE_A`, x480..1180: one Bellchain Penitent on the ground plus one Confessional Wraith emerging from a visible booth. The booth opens before damage; maximum simultaneous attackers is two.
2. `NAVE_B`, x1320..2040: one Thirteenth Scribe on `UpperArchiveLedge`. The Player sees the access corbel before the Scribe activates. No ground heavy enemy masks the ranged tutorial.

The physical choir-screen door occupies x2152..2288. It remains collision-solid while closed and is never represented by a marker alone.

## 6. Room C — Choir Gallery / organ hall layout

The Choir Gallery replaces the old organ/Boss-door montage. Its pipe organ is the room focus; the Boss gate is not present here.

### Ground and platforms

| Surface | x span | Top y | Width | Route check | Use |
|---|---:|---:|---:|---|---|
| `WestChoirSeat` | `448..640` | `552` | 192 | floor rise 60 | safe landing below Chorister |
| `EastChoirSeat` | `1328..1520` | `552` | 192 | floor rise 60 | second punish/turning surface |
| `OrganAccessCorbel` | `1584..1680` | `492` | 96 | gap 64; rise 60 | traversal-only connector |
| `OrganMaintenanceDeck` | `1728..1888` | `432` | 160 | gap 48; rise 60 | high ranged/Seraph punish deck |

The floor remains clear for x0..2432. No organ image or background wall receives a body collision. Only visible platform slabs and floor geometry are solid.

### Encounter rhythm

1. `CHOIR_A`, x360..1160: one Censer Executioner on the wide ground lane and one Silent Chorister hovering 28–40 px above `WestChoirSeat`. The seat lets the Player reach it without blind jumping.
2. `CHOIR_B`, x1280..2100: one Stained-Glass Seraph in a bounded aerial lane above the maintenance side. `EastChoirSeat → OrganAccessCorbel → OrganMaintenanceDeck` provides three visible safe landings and a melee punish route. The Seraph's lowest punish state must resolve over the deck or ground, never outside Camera bounds.

Only one encounter stage is active at a time. The Censer Executioner never uses a narrow platform. No enemy patrol boundary crosses a door or RoomHost edge.

### Organ asset split

The organ will be authored as at least three saved visual parts in R2:

1. `organ_pipes_far` — z=-60, no collision;
2. `organ_case_behind` — z=-30, no collision;
3. `organ_maintenance_deck` — platform visual plus matching collision;
4. optional edge rail foreground — z=20, limited to legs/edges.

This prevents a single opaque organ sprite from hiding Player/Enemy bodies or creating one large air wall. The room exit is a vestry door at x2280; it leads to the checkpoint through Fade, not directly to the Boss gate.

## 7. Rooms D/E/F — Boss approach and arena

### Boss Checkpoint

`CH3_BOSS_CHECKPOINT` is a `896×720` safe room. It contains one chapter checkpoint, one narrow prayer bench, one extinguished bell niche and one physical confession-arch exit. It has no enemy, platform, trap, large organ, Boss gate or combat trigger.

The Player walks from local x128 to the exit interaction at x760: `632/220 = 2.87 s` at normal speed.

### Thirteen Confessions Antechamber

The antechamber remains `1664×720`, but its checkpoint is removed to Room D. The retained composition is deliberately reduced to:

- distinct black/oxblood carpet;
- one pair of more solemn pillars;
- one left and one right bell-saint statue;
- thirteen confession tablets plus an empty fourteenth recess;
- one unique centered/right Boss gate;
- environment text: `GATE OF THE THIRTEENTH ECHO / 第十三回响之门`;
- interaction prompt: `按 E 进入第十三回响圣所`.

The Player walks from local x160 to the gate interaction at x1456: `1296/220 = 5.89 s`. Checkpoint plus antechamber normal movement totals approximately `8.76 s`, inside the requested 6–10 second interval. No enemy, platform, trap or irrelevant main asset appears in this approach.

The current lectern, ritual registry and extra censer set are candidates to move to the checkpoint/reliquary or be omitted; they are not all retained in the antechamber.

### Boss gate and Sanctum

The Boss gate is interaction-only:

1. Player enters the prompt range;
2. no combat or automatic crossing starts;
3. Player presses `interact` (`E`);
4. control and facing lock;
5. gate ritual/door animation plays and blocker disables in sync;
6. Boss room is confirmed prepared;
7. Fade Out;
8. `RoomHost` replaces the antechamber with `ch3_boss_sanctum.tscn`;
9. Player moves to `CH3_BOSS`, Camera bounds update and one physics frame passes;
10. Fade In;
11. environment/Boss intro runs before Boss HP, AI or Hitbox activates.

Repeated E presses cannot restart the transition. Entering the trigger without E does nothing. The current `auto_trigger=true` and same-canvas `global_position` crossing are explicitly rejected for R4.

The `3200×720` Sanctum is independent and flat. Existing formal stained glass, ritual floor, altar, choir silhouettes, candles and incense may be adapted. The stained glass/ritual circle remains the focus; the organ is a far-background silhouette only, not a gameplay wall or a second room identity. No platform or foreground pillar may obstruct Player, Boss or attack telegraphs.

## 8. Door, stair, elevator and Fade decisions

| Boundary | Physical explanation | Interaction | Fade target | Planned duration |
|---|---|---|---|---:|
| Chapter II passage → Vestibule | mirror-back ceremonial door | existing cross-chapter confirmation | whole-scene Chapter III route | existing global 0.50 s |
| Vestibule → Nave | nave door + 512 px descending stone stair | E opens; Player walks stair | local room swap | 0.35 out / 0.35 in |
| Nave → Choir | barred choir-screen door + 96 px threshold | E after current Encounter clear | local room swap | 0.35 / 0.35 |
| Choir → Checkpoint | vestry side door | E after current Encounter clear | local room swap | 0.35 / 0.35 |
| Checkpoint → Ante | confession arch door | E; never combat-locked | local room swap | 0.30 / 0.30 |
| Ante → Boss | Thirteenth Echo gate | **E required** + ritual animation | independent Boss room | 0.45 / 0.45 |
| Boss → Reliquary | visible apse exit unlocked by Boss death | E after death flow | post-Boss room | 0.35 / 0.35 |
| Reliquary → Underkeep | rusted gate + descending ossuary stair | E after reward authority permits | descent room | 0.45 / 0.45 |

No elevator is planned in this route. The selected spaces have only shallow architectural height changes; an elevator would add machinery and waiting time without serving the chapter story or solving a real traversal problem.

The local swap sequence is fixed:

```text
interaction accepted
→ stop new Encounter activation
→ lock Player action input
→ play physical door/stair state
→ Fade Out
→ disable old room processing/collisions
→ instantiate prepared destination in RoomHost
→ resolve destination Marker2D
→ reposition persistent Player and zero velocity
→ apply local Camera bounds and room title
→ await one physics frame
→ free retired room
→ Fade In
→ restore input
```

Door visuals and collision share one state authority. A door is never visually open while its blocker remains active.

## 9. Platform envelope and placement rules

R1 uses the R0 measured values, not estimates:

| Player metric | Measured | R1 limit |
|---|---:|---:|
| single-jump rise | 83.77 px | ordinary rise ≤62 px |
| double-jump rise | 167.10 px | optional rise ≤133 px |
| forward single-jump range | 153.59 px | ordinary gap ≤107 px |
| forward double-jump range | 281.92 px | optional route stays below 225 px |
| one Dash segment | ≈86 px | not required for main-route reachability |
| safe landing width | 48 px | combat platforms are ≥96 px |

The planned platform chains use 60 px rises and 32–72 px horizontal gaps. They remain reachable by single jump and leave Dash/Air Dash as tactical choices. All remote-enemy surfaces are 144–192 px wide; only traversal corbels are 96 px. The floor is always a continuous primary route.

Expected distribution across the planned normal encounters is approximately 60% ground, 20–25% middle platform, 10% high platform and 10–15% airborne/ambush. No room has more than three effective combat heights.

## 10. Layer and collision ownership for later stages

R3 will apply one contract to every room:

| Category | Planned z/layer | Rule |
|---|---:|---|
| Far Background | `-100` | no collision |
| Background Architecture | `-60` | structural visuals behind actors |
| Props Behind Actors | `-30` | benches/statues/organ case, no body collision unless visibly solid |
| Ground Visual | `-10` | surface art aligned to room-owned collision |
| Platform Visuals | `0` | exact visible top equals CollisionShape top |
| Enemies | `10` | explicit scene-root z contract |
| Player | `12` | head/torso/weapons remain readable |
| Interactables/door prompts | `14` | gate leaves split from foreground frames |
| Limited Foreground | `20` | edge/foot occlusion only |
| HUD/Fade | CanvasLayer | HUD persistent; local Fade above HUD only during transition |

There is no `YSort` dependency. Door frames, organ rails, shallow water and checkpoint art must be split into behind/front pieces instead of placing one opaque sprite above actors.

Every solid boundary must have a matching visible wall, door, platform or floor. Every background-only organ, statue, stained glass and wall treatment must have collision disabled. R2/R3 must preserve an air-wall table derived from the R0 audit and record each removed/replaced blocker.

## 11. Asset reuse, adaptation and missing assets

R1 creates no assets. It defines the R2 asset gate:

| Disposition | Assets / systems |
|---|---|
| Reuse as-is | six accepted Chapter III enemy scenes/SpriteFrames; `chapter_gameplay_runtime.tscn`; shared combat/encounter components; gate bell/wax/stone audio; selected Boss FX |
| Adapt and split | Boss antechamber backdrop; bell-saint statues; confession tablets; Boss gate states; 3200×720 Sanctum art; reliquary; underkeep descent; organ case/foreground separation |
| New formal assets required | 2048×720 vestibule background/architecture; mirror-back door; nave door and short stair kit; 2304×720 nave wall/arch modules; side-gallery/ledge modules; choir-screen and vestry doors; 2432×720 choir backdrop; separate organ pipes/case/deck; choir seats; 896×720 checkpoint architecture; confession-arch door; visible Boss-room exit seal |
| Remove from runtime in R2 | `chapter_03_entry_art.gd` prototype draw output, x5864..6000 void, same-canvas hard joins, invisible Boss exit blocker, Marker2D-only chapel door, automatic Boss-gate crossing |

No long wall may be produced by stretching a non-tileable PNG. R2 must use exact-size variants, tileable pixel modules or correct NinePatch boundaries.

## 12. R2/R3/R4 implementation ownership

| Stage | Allowed implementation derived from this plan | Explicitly deferred |
|---|---|---|
| R2 | create formal room assets/scenes, RoomHost route, doors/Fades, platform visuals/collisions, remove black spans and hard joins | final z/collision QA, Boss entry flow polish |
| R3 | apply unified z contract, split occluders, visible-collision audit, fix every air wall/seam | Boss intro/HP/AI authority |
| R4 | finalize checkpoint, E-confirmed Boss gate, independent Sanctum load and intro gating | unrelated enemy/Boss balance or Chapter IV content |
| R5 | full F5 route, ten transition repetitions, platform combat, screenshots and forced QA | new chapter scope |

Bell Confessor Edran still lacks an authoritative Boss entity in the current repository. R1 defines the intro and room boundary but does not invent Boss combat, reward or Chapter IV systems.

## 13. R1 acceptance matrix

| Planning item | Status | Evidence |
|---|---|---|
| Vestibule size/function/layout | PASS | Sections 3–4 |
| Organ hall separated from Boss ante | PASS | Sections 2, 6–7 |
| All doors/stairs/Fades selected | PASS | Section 8 |
| Elevator decision recorded | PASS | Section 8 — not used, with reason |
| Platform coordinates and reachability | PASS | Sections 5–6 and 9 |
| All six required Debug spawns planned | PASS | Section 3 |
| Boss confirmation boundary | PASS | Section 7 |
| Persistent Player/HUD architecture | PASS | Sections 1 and 8 |
| Asset reuse/missing plan | PASS | Section 11 |
| Runtime scenes modified | NOT APPLICABLE | R1 is design-only |
| Main/F5 structure fixed | FAIL | Must wait for R2–R5 |

R1 is complete only as a room-planning milestone. The screenshots' runtime defects remain present until the approved implementation stages.

**第三章场景结构返修尚未通过最终验收。**
