# Chapter III Structural Rework — R4 Boss Flow Report

Status: **R4 environment/lifecycle scope complete**. Bell Confessor Edran combat, the authoritative Boss reward and Chapter IV remain explicit `PARTIAL` boundaries.

## Main authority and route

- F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`.
- Chapter III Main target: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn`.
- Saved route: `CH3_BOSS_CHECKPOINT → CH3_BOSS_ANTE → CH3_BOSS`.
- Typed future route: `CH3_BOSS → CH3_POST_BOSS → CH3_UNDERKEEP_DESCENT` after the authoritative Boss/reward systems invoke their existing hooks.

The route continues to own one persistent Player/HUD and exactly one child under `RoomHost`. No Boss threshold uses a same-canvas coordinate teleport.

## Checkpoint

`Ch3BossCheckpoint/CheckpointArea` is now a typed one-shot `Chapter03RoomCheckpoint`. Entering it:

1. records `chapter_03_boss_checkpoint_activated` in the runtime session;
2. copies `SpawnPoints/BossCheckpoint` into the persistent respawn anchor;
3. keeps `PlayerRespawnController` bound to that persistent marker after the checkpoint room is unloaded;
4. displays `LAST VIGIL AWAKENED / 末祷已铭记` once.

The checkpoint prop was moved behind the Player draw band, so activation no longer hides the Player torso.

## E-confirmed Boss gate

The formal gate at `Ch3BossAnteRoom/BossGate` is configured with `auto_trigger=false` and `use_internal_fade=false`.

- Proximity only shows `E · ENTER THE THIRTEENTH ECHO SANCTUM / 进入第十三回响圣所`.
- Only the Input Map `interact` action starts the thirteen-bell/seal ritual.
- Repeated E cannot restart an active/completed sequence.
- The gate owns bell, seal, wax and door presentation plus blocker release.
- `Chapter03RoomTransitionController` owns the single Fade and saved room replacement.

This removes the former double-Fade race and prevents the gate from restoring input while the route is still changing rooms.

## Sanctum intro

The formal Sanctum disables proximity auto-start. After the room Fade completes, the transition controller explicitly starts the environment intro:

1. Player input/velocity remain locked;
2. thirteen candles light in order;
3. the bounded intro camera reveals the altar/Boss anchor;
4. resonance and incense play;
5. `BELL CONFESSOR EDRAN / 钟忏司祭·埃德兰` and the bilingual epithet appear;
6. camera authority returns to Player;
7. input and prior invulnerability state are restored.

The existing `BossIntegrationAnchor` remains the only formal integration point. No fake Boss health, AI, Hitbox or damage source was added.

## Post-Boss lifecycle interfaces

- `Chapter03BossSanctumRoom` listens to the idempotent environment `death_environment_finished` signal and only then enables `PostBossExit`.
- `Chapter03PostBossRoom` reveals the reliquary on legitimate room entry but keeps `UnderkeepExit` disabled until the authoritative reward system calls `notify_reward_collected()`.
- Reward completion enables the visible descent gate and the saved Fade route to `CH3_UNDERKEEP_DESCENT`.
- The Underkeep terminal still refuses to load a nonexistent Chapter IV PackedScene and shows the planned-content message.

These are real typed scene boundaries, but normal gameplay cannot invoke Boss death/reward completion until those separately scoped systems exist.

## Main evidence

- `docs/qa/chapter_03_r4_checkpoint_main.png`
- `docs/qa/chapter_03_r4_boss_gate_prompt_main.png`
- `docs/qa/chapter_03_r4_boss_gate_ritual_main.png`
- `docs/qa/chapter_03_r4_boss_intro_title_main.png`
- `docs/qa/chapter_03_r4_sanctum_main.png`

All images were captured from `MainBootstrap → Chapter03Route`, not by F6-loading an area.

## Verification

1. Exact Godot 4.7.1 headless editor import/parse — PASS; no parser or missing-resource error.
2. `test_chapter_03_r4_boss_flow.gd` — PASS: checkpoint, E gate, room swap, intro, post-Boss and underkeep hooks.
3. R3 layer/collision regression — PASS.
4. R2 room architecture regression — PASS.
5. Boss environment regression — PASS.
6. Legacy Boss route regression — PASS.
7. six-enemy roster regression — PASS.
8. MainBootstrap graphical capture — PASS, five images.
9. default formal F5 smoke — PASS; Opening starts and no red runtime error is emitted.

## R4 acceptance

| Item | Status | Evidence |
|---|---|---|
| Boss checkpoint | PASS | typed activation, persistent respawn binding, Main screenshot |
| Boss antechamber | PASS | independent saved room and Main screenshot |
| Boss gate identity | PASS | unique gate label and closed/ritual states |
| explicit E prompt | PASS | proximity does not open; Main prompt evidence |
| independent Boss-room Fade | PASS | RoomHost swap and focused test |
| intro ordering | PASS | starts after Fade; title/camera/input assertions |
| Boss combat | PARTIAL | no authoritative Edran entity exists |
| Boss reward | PARTIAL | no authoritative reward Resource exists |
| Chapter IV load | PARTIAL | no Chapter IV PackedScene exists |

R4 is complete for the approved Boss-region environment and lifecycle boundary. It does not mislabel absent combat/content systems as complete.
