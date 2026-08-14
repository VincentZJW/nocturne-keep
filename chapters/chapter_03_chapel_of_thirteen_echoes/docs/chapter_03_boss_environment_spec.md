# Chapter III Boss Environment Specification

## Scope and authority

This specification owns the environment route from the last Chapter III combat area to the planned Chapter IV boundary. It does not own Bell Confessor Edran's AI, statistics, dialogue data, reward item, or the Chapter IV map.

F5 remains authoritative through `res://scenes/bootstrap/main_bootstrap.tscn`. The formal Chapter III scene is `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn`; the old single-canvas placeholder is retained only for legacy regression coverage.

## Narrative and spatial sequence

The route is paced as:

1. `Vestibule of Thirteen Confessions / 十三忏前厅` — rest, checkpoint and ritual evidence.
2. `Gate of the Thirteenth Echo / 第十三回响之门` — thirteen bells and seals, cracked blood wax, controlled fade and collision-safe crossing.
3. `Sanctum of the Thirteenth Echo / 第十三回响圣所` — a flat combat floor beneath the Thirteenfold Absolution, altar, empty choir stalls and thirteen ritual stations.
4. `Reliquary of the Last Confession / 末次忏悔遗物室` — quiet post-Boss reward hand-off.
5. `Descent of the Drowned Saints / 溺圣下行道` — drowned chapel drainage, shallow animated water, half-submerged ossuary evidence and a live Chapter IV threshold.

The thirteenth position is emphasized through unstable light and the erased/empty next position. It suggests the Player's relationship to a fourteenth toll without presenting the conclusion as explicit text.

## Scene ownership

| Scene | Runtime responsibility |
|---|---|
| `scenes/areas/ch3_boss_antechamber.tscn` | Formal backdrop, confession objects, unique checkpoint and safe rest floor |
| `scenes/areas/ch3_boss_gate_transition.tscn` | Gate collision, thirteen-step visual/audio sequence, input lock, fade and typed crossing request |
| `scenes/areas/ch3_boss_sanctum.tscn` | Arena composition, intro camera/environment sequence, typed Boss anchor and death-response environment |
| `scenes/areas/ch3_post_boss_reliquary.tscn` | Reward presentation and authoritative reward-system hand-off |
| `scenes/areas/ch3_underkeep_descent.tscn` | Layered drainage/ossuary composition, shallow-water reactions and guarded Chapter IV scene request |

The level script owns cross-area routing and respawn binding. It does not synthesize an Edran instance or inventory reward.

## Assets

All Boss-route art and audio is original, deterministic project-owned work produced by `scripts/tools/generate_chapter_03_boss_environment_assets.gd`. Hard-edged PNGs use nearest-neighbour sampling. Sources are grouped under:

- `assets/environment/boss_antechamber/`
- `assets/doors/boss/`
- `assets/environment/boss_sanctum/`
- `assets/environment/boss_reliquary/`
- `assets/environment/water_transition/`
- `assets/props/boss/`
- `assets/fx/boss/`
- `assets/audio/boss/`

Runtime scenery uses texture assets; Godot geometry in these scenes is reserved for floors, blockers and triggers.

## Presentation state contracts

### Gate

`Chapter03BossGate` accepts one Player only after the formal `interact`/E confirmation, locks input, runs thirteen bell/seal steps, cracks the wax, opens the gate, disables the blocker and emits `crossing_requested(player)`. The formal `Chapter03RoomTransitionController` owns the single Fade, one-room swap and input restoration; the gate's internal Fade remains enabled only for the retired legacy-canvas regression. Re-entry cannot restart an active or completed sequence.

### Sanctum intro

After the formal room Fade completes, `Chapter03BossSanctum` locks the Player, lights thirteen candles sequentially, pans a dedicated bounded camera toward the altar/Boss anchor, gathers incense, pulses resonance, presents Edran's bilingual title, returns the camera and restores input. `BossIntegrationAnchor` is the typed hand-off for a future Edran scene.

### Boss death response

`notify_boss_defeated()` extinguishes the candles in reverse order, reveals permanent stained-glass cracks, replaces the intact altar with the collapsed state and opens the typed route to the reliquary. `Chapter03BossSanctumRoom` enables its saved post-Boss exit only after this sequence finishes. The signal is idempotent.

### Reward and Chapter IV boundary

The reliquary emits `reward_collection_requested(player)`. The authoritative reward system grants Thirteenfold Absolution and calls `notify_reward_collected()`. The rebuilt Underkeep descent keeps the existing chapter-completion gate, then emits a typed room request to the registered Chapter IV threshold. The destination is a formal playable landing scene; it is not the complete Chapter IV map.

## Main debug starts

| Spawn ID | Purpose |
|---|---|
| `CH3_BOSS_ANTE` | Checkpoint, ante chamber, gate and fade sequence |
| `CH3_BOSS` | Sanctum intro and environment hooks |
| `CH3_POST_BOSS` | Post-death environment and reward hand-off |
| `CH3_UNDERKEEP_DESCENT` | Open descent, shallow water and Chapter IV boundary |

## Current integration boundaries

- Edran and the Thirteenfold Absolution reward now have independent authoritative gameplay specifications; this environment document continues to own only their scene hooks.
- `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn` exists and accepts `CH4_START`, so the Chapter III-to-IV fade and landing are live.
- The destination is intentionally limited to a formal threshold/landing. Chapter IV's complete route, encounters and final environment remain outside this specification and are not claimed complete.
- The detailed Underkeep layer, collision and water contract is maintained in `chapter_03_underkeep_descent_spec.md`.
