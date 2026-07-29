# Chapter III Boss Environment Specification

## Scope and authority

This specification owns the environment route from the last Chapter III combat area to the planned Chapter IV boundary. It does not own Bell Confessor Edran's AI, statistics, dialogue data, reward item, or the Chapter IV map.

F5 remains authoritative through `res://scenes/bootstrap/main_bootstrap.tscn`. The formal Chapter III scene is `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn`.

## Narrative and spatial sequence

The route is paced as:

1. `Vestibule of Thirteen Confessions / 十三忏前厅` — rest, checkpoint and ritual evidence.
2. `Gate of the Thirteenth Echo / 第十三回响之门` — thirteen bells and seals, cracked blood wax, controlled fade and collision-safe crossing.
3. `Sanctum of the Thirteenth Echo / 第十三回响圣所` — a flat combat floor beneath the Thirteenfold Absolution, altar, empty choir stalls and thirteen ritual stations.
4. `Reliquary of the Last Confession / 末次忏悔遗物室` — quiet post-Boss reward hand-off.
5. `Descent of the Drowned Saints / 溺圣下行道` — damp ossuary masonry, descending steps, shallow water and the blocked Chapter IV boundary.

The thirteenth position is emphasized through unstable light and the erased/empty next position. It suggests the Player's relationship to a fourteenth toll without presenting the conclusion as explicit text.

## Scene ownership

| Scene | Runtime responsibility |
|---|---|
| `scenes/areas/ch3_boss_antechamber.tscn` | Formal backdrop, confession objects, unique checkpoint and safe rest floor |
| `scenes/areas/ch3_boss_gate_transition.tscn` | Gate collision, thirteen-step visual/audio sequence, input lock, fade and typed crossing request |
| `scenes/areas/ch3_boss_sanctum.tscn` | Arena composition, intro camera/environment sequence, typed Boss anchor and death-response environment |
| `scenes/areas/ch3_post_boss_reliquary.tscn` | Reward presentation and authoritative reward-system hand-off |
| `scenes/areas/ch3_underkeep_descent.tscn` | Water-transition presentation and guarded Chapter IV scene request |

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

`Chapter03BossGate` accepts one Player, locks input, runs thirteen bell/seal steps, cracks the wax, opens the gate, disables the blocker, fades out, emits `crossing_requested(player)`, fades in and restores full input. Re-entry cannot restart an active or completed sequence.

### Sanctum intro

`Chapter03BossSanctum` locks the Player, lights thirteen candles sequentially, pans a dedicated bounded camera toward the altar/Boss anchor, gathers incense, pulses resonance, returns the camera and restores input. `BossIntegrationAnchor` is the typed hand-off for a future Edran scene.

### Boss death response

`notify_boss_defeated()` extinguishes the candles in reverse order, reveals permanent stained-glass cracks, replaces the intact altar with the collapsed state and opens the route to the reliquary. The signal is idempotent.

### Reward and Chapter IV boundary

The reliquary emits `reward_collection_requested(player)`. Only an authoritative reward system may grant the future Boss item and call `notify_reward_collected()`. The Underkeep terminal emits a transition only when the registered Chapter IV PackedScene exists; otherwise it displays a clear planned-content message.

## Main debug starts

| Spawn ID | Purpose |
|---|---|
| `CH3_BOSS_ANTE` | Checkpoint, ante chamber, gate and fade sequence |
| `CH3_BOSS` | Sanctum intro and environment hooks |
| `CH3_POST_BOSS` | Post-death environment and reward hand-off |
| `CH3_UNDERKEEP_DESCENT` | Open descent, shallow water and Chapter IV boundary |

## Known integration boundaries

- `Bell Confessor Edran` has no authoritative scene/data/controller in the repository: Boss dialogue, Boss title, combat and actual death signal remain `PARTIAL`.
- No Chapter III Boss reward Resource exists: inventory grant remains `PARTIAL`; the environment hook is implemented and tested.
- `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn` does not exist: the downward route is complete to its terminal, while actual Chapter IV loading remains `PARTIAL`.
