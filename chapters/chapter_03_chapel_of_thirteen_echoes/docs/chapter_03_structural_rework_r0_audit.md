# Chapter III Structural Rework — R0 Audit

Date: 2026-07-29

Scope: R0 read-only scene, collision, layering, room-connection and traversal audit

Audit status: **PASS**

Current formal-scene quality: **FAIL**

## 1. Runtime authority

- `project.godot` F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`.
- Chapter III Debug Start profile: `res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/chapter/chapter_03_start_profile.tres`.
- Chapter III saved Main target: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn`.
- Design viewport: `1280×720`; stretch mode is `canvas_items`.
- Chapter III runtime root after Bootstrap replaces the startup scene: `/root/Chapter03EntryPlaceholder`.
- The current Camera is `/root/Chapter03EntryPlaceholder/GameplayWorld/ChapterRuntime/Player/Camera2D`. The level script overrides its limits to `left=0`, `right=12784`, `top=0`, `bottom=720`.
- `/root/Chapter03EntryPlaceholder/CameraBounds` is an unhandled `Area2D` covering the same `12784×720`; no controller reads it. It is descriptive/redundant rather than authoritative.

The current chapter is not a room system. It is one `12784×720` horizontal canvas containing a 4200-pixel runtime-drawn enemy prototype followed by five Boss-route PackedScene instances.

## 2. Screenshot-to-runtime mapping

| User screenshot | Saved scene | Exact live nodes | Finding |
|---|---|---|---|
| 1 — empty Chapel Vestibule | `chapter_03_entry_placeholder.tscn` | `/root/Chapter03EntryPlaceholder/EnvironmentArt`, `/GameplayWorld/Geometry/MainFloor`, `/GameplayWorld/ChapterRuntime/Player`, `/GameplayWorld/Phase2AEncounter` through `/Phase2FEncounter` | The entire first 4200 px is drawn by `chapter_03_entry_art.gd::_draw()` using flat rectangles, circles, arcs and lines. It is still explicitly named an enemy acceptance prototype and has no formal vestibule room, door, furniture, platforms or room controller. |
| 2 — hard split between empty hall and formal wall | same Main target | left: `/EnvironmentArt`; right: `/GameplayWorld/Chapter03BossAreas/BossAntechamber/Backdrop` and `/Architecture` | Exact join is world `x=4200`. Physics floors meet, but the runtime-drawn prototype ends on the same pixel where a full 1664×720 formal backdrop begins. There is no door, corridor, stair, fade or architectural transition. |
| 3 — Boss gate / organ black gap | same Main target | `/GameplayWorld/Chapter03BossAreas/BossAntechamber`, `/BossGateTransition`, `/BossSanctum` | BossAntechamber art/floor ends at `x=5864`; BossSanctum begins at `x=6000`. The interval `x=5864..6000` is 136 px of clear-color black and has no floor collision. The gate is overlaid at world `x=5480..5864`; it does not own a connecting room or floor. |
| 4 — organ / reliquary seam and blocker | same Main target | `/GameplayWorld/Chapter03BossAreas/BossSanctum`, `/PostBossReliquary`, especially `/BossSanctum/BossExitBlocker` | Exact module join is `x=9200`. The two floors touch, but unrelated 3200×720 and 1280×720 backdrops hard-cut. A 48×420 BossExitBlocker occupies `x=9152..9200` with no matching visible door or seal, producing an air-wall reading until the Boss-death hook disables it. |

## 3. Current saved scene structure

```text
/root/Chapter03EntryPlaceholder
├── EnvironmentArt                         # runtime _draw(), z=-40, x=0..4200
├── GameplayWorld
│   ├── Geometry
│   │   ├── MainFloor                      # x=0..4200, top y=612
│   │   ├── SafetyBoundaryLeft             # x=-64..0
│   │   └── MainRouteExitPlaceholder       # x=12784..12848
│   ├── ChapterRuntime
│   │   ├── Player
│   │   ├── PlayerRespawnController
│   │   └── HUD (CanvasLayer)
│   ├── Phase2AEncounter                   # Bellchain, prototype zone
│   ├── Phase2BEncounter                   # Executioner, prototype zone
│   ├── Phase2CDEEncounter                 # Chorister/Seraph/Wraith prototype
│   ├── Phase2FEncounter                   # Scribe prototype zone
│   └── Chapter03BossAreas
│       ├── BossAntechamber                # world x=4200..5864
│       ├── BossGateTransition             # gate art x=5480..5864
│       ├── BossSanctum                    # world x=6000..9200
│       ├── PostBossReliquary               # world x=9200..10480
│       └── UnderkeepDescent                # world x=10480..12784
├── SpawnPoints
├── Checkpoints
├── CameraBounds
├── Doors                                  # one Marker2D only; no door controller
└── NarrativeTriggers
```

Current route coordinates:

| Segment | World span | Width | Physical floor | Formal room transition |
|---|---:|---:|---|---|
| Enemy acceptance prototype | `0..4200` | 4200 | yes | no |
| BossAntechamber | `4200..5864` | 1664 | yes | no; hard visual join at 4200 |
| Gate overlay | `5480..5864` | 384 | inherited from ante floor | auto-triggered gate sequence |
| Broken join | `5864..6000` | 136 | **no** | **no; black gap** |
| BossSanctum | `6000..9200` | 3200 | yes | teleport within same canvas |
| PostBossReliquary | `9200..10480` | 1280 | yes | no; hard backdrop join |
| UnderkeepDescent | `10480..12784` | 2304 | yes | no; hard backdrop join |

No saved nodes currently represent `CH3_NAVE_ENTRY`, `CH3_CHOIR_GALLERY` or `CH3_BOSS_CHECKPOINT` as independent rooms. `CH3_BOSS_ANTE` is a spawn inside the combined ante/gate canvas, not a room load. `CH3_BOSS` is a spawn inside the same level canvas, not an independently loaded Boss scene.

## 4. Room and transition controller audit

- The first 4200 px has no Room/Area controller; `chapter_03_entry_placeholder.gd` owns the entire canvas.
- The only normal-route door node is `/Doors/ChapelSideDoor`, a `Marker2D`; it has no visual, collision, interaction, opening animation or transition controller.
- There are no stair, lift/elevator or short-corridor PackedScenes.
- The Boss gate uses `Chapter03BossGate`, but `auto_trigger=true`. Entering `GateTrigger` immediately locks Player, plays the sequence, fades and emits `crossing_requested`.
- `chapter_03_entry_placeholder.gd::_on_boss_gate_crossing_requested()` directly changes Player `global_position` to `/SpawnPoints/CH3_BOSS` inside the same scene. This conflicts with the requested physical E-confirmed gate and independently loaded Boss room.
- Room-name HUD text changes only from the initially consumed Debug spawn. Normal traversal does not update the room label by zone, which is why later screenshot regions can still display `CHAPEL VESTIBULE`.
- BossSanctum is environment-only. The repository still has no Bell Confessor Edran Boss entity, so Boss HP/AI/introduction cannot currently satisfy the final R4/R5 flow.

## 5. Collision and air-wall audit

| Scene | Node path | Current collision | Problem | R2/R3 planned disposition |
|---|---|---|---|---|
| Main target | `GameplayWorld/Geometry/SafetyBoundaryLeft/CollisionShape2D` | world `x=-64..0`, `64×720` | Invisible outer boundary; outside the playable start but not represented by the requested rear entrance architecture. | Bind to a visible closed/rear entrance wall or place outside the loaded room bounds. |
| Main target | `GameplayWorld/Geometry/MainFloor/CollisionShape2D` | `4200×108`, top `y=612` | One uninterrupted prototype slab gives no room-specific ground, stair or platform semantics. | Replace with room-owned visible/collision-aligned floors. |
| Boss ante | `GameplayWorld/Chapter03BossAreas/BossAntechamber/Floor/CollisionShape2D` | world `x=4200..5864`, top `y=612` | Physically joins the prototype but visually hard-cuts; also carries the gate overlap. | Keep only inside a dedicated Boss-checkpoint/ante room, aligned to its own floor art. |
| Boss gate | `GameplayWorld/Chapter03BossAreas/BossGateTransition/GateBlocker/CollisionShape2D` | world center `(5672,402)`, `54×420` | Collision matches a closed gate, but trigger is automatic and the gate is an overlay rather than a room exit. | Retain a visible blocker contract; switch to E-confirmed opening and room transition. |
| Main target | **no node** | world `x=5864..6000` has no floor | 136 px black physical pit between gate/ante and sanctum. This is the screenshot-3 structural break. | Remove from continuous traversal; load the Boss room behind Fade, or author a real connecting structure. |
| Boss sanctum | `GameplayWorld/Chapter03BossAreas/BossSanctum/BossExitBlocker/CollisionShape2D` | world center `(9176,402)`, `48×420` | **Invisible blocker** at the screenshot-4 seam. No matching visible door or sealed architecture communicates why passage is blocked. | Add a visible exit seal/door synchronized to Boss state, or move it outside an independent Boss-room camera bound. |
| Reliquary | `GameplayWorld/Chapter03BossAreas/PostBossReliquary/DescentBlocker/CollisionShape2D` | world center `(10310,404)`, `50×410` | Has matching rusted-gate art and is disabled after reward collection; structurally valid, but must be retained in the correct dedicated room. | Preserve synchronized visual/collision state and test after room split. |
| Main target | `GameplayWorld/Geometry/MainRouteExitPlaceholder/CollisionShape2D` | world `x=12784..12848`, `64×720` | Invisible terminal boundary just beyond the descent backdrop; acceptable only as temporary Chapter IV boundary, not final visible architecture. | Replace/bind to the actual Chapter IV gate when that chapter exists. |

Non-blocking `Area2D` triggers (encounters, title, checkpoint, intro, reward and Chapter IV prompt) use collision mask 2 and do not create the observed air walls.

There are **zero elevated `StaticBody2D` platforms** in the Chapter III Main target. The visible organ, arches, tablets and statues are presentation only; none provides a player/enemy stand surface.

## 6. Visual seam audit

| World join | Severity | Evidence and cause | Required correction |
|---:|---|---|---|
| `x=4200` | FAIL | Runtime `_draw()` prototype (`080a10/151823`) ends exactly where the 1664×720 Boss ante PNG begins. Floor tops align at 612, but wall rhythm, density, palette and architectural baseline do not. | Replace prototype with formal vestibule/nave/choir rooms and connect through a door/stair/Fade. |
| `x=5864..6000` | FAIL | 136 px have neither backdrop nor floor; project clear color is visible. | Eliminate the span through room loading; never decorate a void to conceal it. |
| `x=9200` | FAIL | Sanctum apse and reliquary backdrops touch without a shared doorway/end cap; the invisible blocker sits immediately before the join. | Make the Boss room independent and expose a visible post-Boss exit before loading the reliquary. |
| `x=10480` | PARTIAL | Reliquary and underkeep backdrops touch with different architectural bases; a visible descent gate exists earlier at x10310, but crossing the module boundary has no local Fade or Camera-bound update. | Move the descent behind the visible gate and transition to a dedicated underkeep room. |

All root and module positions are integer-valued. There are no 0.5-pixel transforms in the audited scene files. The visible seams come from whole-module composition and missing transition architecture, not subpixel placement.

## 7. Draw-order audit

No Chapter III scene enables `y_sort_enabled`, `top_level` or `show_behind_parent`; all `z_as_relative` values are default. Current ordering is inconsistent rather than centrally defined:

| Content | Current z/layer | Finding |
|---|---:|---|
| Prototype EnvironmentArt | `-40` | Behind actors, but remains runtime geometry rather than formal art. |
| Formal backdrops | `-30` to `-40` | Behind actors. |
| Boss ante Architecture | parent `-10` | Behind actors; correct relative intent. |
| Player and enemy roots | both `0` | No explicit actor hierarchy. When overlapping, tree order—not a chapter layer contract—decides draw order. |
| Player WeaponVisual / DeathEffects | child `1` / `2` | Correctly above Player body locally. |
| Boss checkpoint visual | `2` | Can cover Player lower body when overlapping; needs a behind/front split. |
| Boss gate Visuals | `12` | Entire 384×512 gate draws above Player/enemies. A door frame may be foreground, but one unsplit sprite can cover the whole actor during passage. |
| Sanctum Incense / Resonance | `6` / `7` | Draw above Player/enemies and can obscure action readability. They need controlled opacity/region or a behind/front split. |
| Underkeep shallow water | `3` | Intended limited foot foreground; retain only if it never covers torso/weapons. |
| World area titles/prompts | `30` / `40` | World-space CanvasItems; they are not part of the HUD CanvasLayer and can drift/overlap across module seams. |
| Runtime HUD | `CanvasLayer` default | Correctly separated from world draw order. |
| Gate transition Fade | `CanvasLayer 90` | Correctly above world and HUD for transition blackout. |

R3 should establish named layer constants or a documented chapter contract: far background → architecture → props behind → ground/platform → enemy → Player → interactables → limited foreground → HUD. Gate frames and water need split sprites rather than moving a whole opaque asset above actors.

## 8. Player movement envelope measured in this audit

Source: shipping `res://scenes/player/player.tscn`, real Input Map actions, 60 physics ticks/s, `tests/player/measure_player_level_metrics.gd`.

| Metric | Measured value | Design use |
|---|---:|---|
| Standing single-jump rise | `83.77 px` | main-route vertical reference |
| Standing debug double-jump rise | `167.10 px` | optional/high route reference; formal ability remains progression-controlled |
| Forward single-jump landing range | `153.59 px` | normal horizontal route reference |
| Forward double-jump landing range | `281.92 px` | optional route reference |
| Single jump + one Air Dash | `192.92 px` | assisted horizontal route, not main-route default |
| Double jump + one Air Dash | `321.26 px` | optional pursuit envelope |
| One Dash/Air-Dash segment | `≈86.0 px` measured average (`344/4`) | both use 480 px/s for 0.18 s; theoretical 86.4 px |
| Four chained Air Dash action distance | `344.00 px` | full-Stamina extreme; must not define ordinary platform spacing |
| Minimum safe landing width | `48 px` | Player body + safety margin |

Derived limits requested by the rework brief:

- Main-route vertical spacing: at most `62.83 px` (`83.77×75%`).
- Main-route horizontal gap: at most `107.51 px` (`153.59×70%`).
- Optional double-jump vertical spacing: at most `133.68 px` (`167.10×80%`).
- Remote-enemy platform: target `80–144 px` wide, but use at least 96 px where combat/turning occurs; never below the measured 48 px safe landing floor.
- Heavy-enemy surface: `128–192 px` or wider; Censer Executioner stays on ground/wide platforms.

## 9. Enemy placement implications

- Bellchain Penitent, Censer Executioner, Confessional Wraith and Thirteenth Scribe currently use ground-body movement with wall/floor checks and authored horizontal bounds. They do not navigate between vertical platform tiers.
- Silent Chorister and Stained-Glass Seraph set `airborne=true`, `gravity=0`, fixed hover origins and horizontal bounds. They can occupy aerial lanes, but the current Main has no intermediate player landing platform beneath them.
- Current prototype positions place Chorister at y455 and Seraph at y405 over a y612 floor. Their attackability relies on double jump/Air Dash rather than an authored ground→middle→air combat route.
- The correct R1 plan is not to put every enemy on a platform: ground roles remain on continuous ground/wide surfaces; Scribe/Chorister receive reachable wide/mid platforms where appropriate; Seraph gets a nearby safe landing tier and bounded hover lane.

## 10. Existing Debug spawn audit

Present:

- `chapter_03_start` / `Chapter03PlayerSpawn`
- `CH3_BELLCHAIN_TEST`
- `CH3_EXECUTIONER_TEST`
- `CH3_CHOIR_TEST`
- `CH3_SCRIBE_TEST`
- `CH3_BOSS_ANTE`
- `CH3_BOSS`
- `CH3_POST_BOSS`
- `CH3_UNDERKEEP_DESCENT`

Missing from the required structural QA route:

- `CH3_VESTIBULE`
- `CH3_NAVE_ENTRY`
- `CH3_CHOIR_GALLERY`
- `CH3_BOSS_CHECKPOINT`

These must be added only when their saved rooms exist; R0 does not create placeholder markers that would pretend the route is complete.

## 11. Parser/runtime baseline

Commands executed with exact Godot 4.7.1:

1. `Godot --headless --editor --path . --import --quit` — exit 0, no parser, missing-resource or autoload error.
2. `Godot --headless --path . res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn --quit-after 6` — exit 0, no red runtime error.
3. Existing Boss environment test — PASS.
4. Existing Boss route test — PASS.
5. Player movement metric — PASS with the values above.

The two existing Boss tests validate the previous environment contract, not this structural QA brief. They do not detect the 4200 seam, 136 px floor/backdrop gap, invisible Boss exit blocker, absent rooms/platforms or auto-trigger-vs-E mismatch. Their PASS result must not be treated as structural acceptance.

## 12. R1 rework proposal and stop point

Recommended architecture: independently instantiable room scenes loaded through the existing `SceneTransitionManager`/chapter-session boundary, not one 12784-pixel canvas.

```text
CH3_CHAPEL_VESTIBULE
  physical nave door → short stair vestibule → Fade
CH3_NAVE_ENTRY
  physical choir door → Fade
CH3_CHOIR_GALLERY
  physical checkpoint exit → Fade
CH3_BOSS_CHECKPOINT
  6–10 second safe walk
CH3_BOSS_ANTE
  E-confirmed thirteenth gate → Fade
CH3_BOSS
```

R1 should produce design/structure only:

1. Define one saved scene and Camera bounds per room above; retain reliquary/underkeep as post-Boss rooms rather than adjacent backdrops.
2. Assign one physical connector per boundary: entrance rear door, nave door + short stair, choir exit door, checkpoint-to-ante passage and E-confirmed Boss gate.
3. Define platform coordinates from the measured limits: no platform in vestibule/checkpoint/ante/Boss; at most two or three height bands in nave/choir; main-route rises ≤62 px and gaps ≤107 px; optional rises ≤133 px.
4. Preserve 35–45% readable negative space and one visual focus per viewport; do not solve seams by adding props.
5. Specify room-owned collision and a visible blocker for every closed boundary.
6. Specify the unified layer contract and which assets must split into behind/front components.
7. Define the six required structural Debug spawns and room-label update contract.
8. Keep Boss AI/reward/Chapter IV outside R1 unless separately approved and authoritative.

No `.gd`, `.tscn`, `.tres`, image, audio, Input Map, Player, enemy, Boss or gameplay value was changed during R0.

**第三章场景结构返修尚未通过最终验收。**
