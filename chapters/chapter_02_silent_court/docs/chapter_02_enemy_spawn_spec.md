# Chapter II enemy SpawnPoint specification

Status: implemented in Main, 2026-07-27

## Saved-node contract

All 38 formal nodes are direct children of `SilentCourt/EnemySpawnPoints` and use `Chapter02EnemySpawnPoint` (`scripts/level/chapter_02_enemy_spawn_point.gd`). Names follow `E##_GroundSpawn_##`, `E##_MidPlatformSpawn_##`, `E##_UpperPlatformSpawn_##`, `E##_CeilingSpawn_##` or `E##_AirSpawn_##`.

Each SpawnPoint owns:

- encounter ID, floor index, activation center/range;
- enemy PackedScene and readable role;
- placement type: `GROUND`, `PLATFORM` or `CEILING_AIR`;
- `platform_left_bound` and `platform_right_bound`; the Marker2D's global Y is the authoritative platform foot/floor Y;
- `drop_down_allowed` and `chase_off_platform_allowed` (both false for ordinary platform actors).

The runtime places the actor at the saved node's `global_position` before entering the tree, retains the SpawnPoint path as metadata and passes optional movement bounds to `GroundEnemyBase`. No Sprite-only offset or room-local placeholder anchor is used.

## Movement and edge safety

- `GroundEnemyBase.can_advance()` rejects normal AI movement beyond authored left/right bounds before consulting the existing WallCheck/FloorCheck raycasts.
- `reached_patrol_boundary()` uses the same bounds; patrol, approach and retreat cannot voluntarily step outside them.
- Knockback remains allowed to push an enemy from a platform as an explicit combat result. This milestone does not globally disable falling.
- Floor 1 E06 and Floor 2 E12 use bounds that stop normal enemies before the floor-transition stairs. `prepare_floor_change()` deactivates every encounter and clears chapter projectiles so enemies cannot cross a black-screen move.

## Placement inventory

- Ground: 22
- Mid/upper platform: 11
- Ceiling/Air: 5
- Formal SpawnPoints modified/created: 38
- Encounter groups rebuilt from SpawnPoints: 15

Platform actors and authored bounds:

| SpawnPoint | Actor | Bounds (world X) | Foot Y |
| --- | --- | ---: | ---: |
| E02_MidPlatformSpawn_01 | Hollow Retainer | 2188..2628 | 500 |
| E04_UpperPlatformSpawn_02 | Fallen Crossbowman | 4924..5204 | 450 |
| E07_UpperPlatformSpawn_02 | Fallen Crossbowman | 6368..6748 | -400 |
| E08_MidPlatformSpawn_02 | Hollow Retainer | 5028..5408 | -480 |
| E08_UpperPlatformSpawn_03 | Fallen Crossbowman | 5708..6088 | -480 |
| E09_UpperPlatformSpawn_01 | Blood-Candle Acolyte | 3340..3660 | -400 |
| E10_UpperPlatformSpawn_02 | Blood-Candle Acolyte | 2780..3180 | -500 |
| E11_UpperPlatformSpawn_01 | Blood-Candle Acolyte | 2220..2620 | -500 |
| E13_MidPlatformSpawn_01 | Fallen Crossbowman | 520..960 | -1300 |
| E13_UpperPlatformSpawn_02 | Hollow Retainer | 1200..1640 | -1370 |
| E14_UpperPlatformSpawn_02 | Blood-Candle Acolyte | 1200..1640 | -1370 |

The exact-engine platform test activates every one of these 11 actors for 240 physics frames and verifies feet, floor contact and left/right bounds. Enemy attack/hurt/death behavior remains the existing shared scene/component contract and is covered by the Phase 2 enemy tests; human F5 play remains required for platform-fight feel and extreme knockback recovery.
