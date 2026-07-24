# Collision Layers and World Geometry Specification

Version: 1.0
Last updated: 2026-07-24

## Project layer map

| Bit / project name | Current users | Collision contract |
| --- | --- | --- |
| 1 `World` | Floor, stone platforms, walls, WoodenBridge, closed CastleGate, rear barrier | full solid geometry unless a future surface is explicitly documented one-way |
| 2 `PlayerBody` | `Main/World/Player` | masks World + EnemyBody; body collider is 24×52 at local y=2 |
| 3 `EnemyBody` | grounded enemies and Boss | masks World + PlayerBody according to existing scenes |
| 4 `PlayerHurtbox` | Player Hurtbox | accepts EnemyHitbox and Projectile routing |
| 5 `EnemyHurtbox` | enemy/Boss Hurtboxes | accepts PlayerHitbox |
| 6 `PlayerHitbox` | normal Attack and Dash Attack | masks EnemyHurtbox; never owns body movement |
| 7 `EnemyHitbox` | enemy and Boss weapons | masks PlayerHurtbox |
| 8 `Detection` | encounter/AI sensing as authored | non-solid observation only |
| 9 `Projectile` | crossbow bolt hit area | PlayerHurtbox hit; companion body casts against World |

## Special first-level nodes

- `MoatHazard`: collision layer 0, mask PlayerBody + EnemyBody (2+4). It invokes the existing Player death flow once per life; a non-Boss enemy entering it receives lethal HealthComponent damage once. The Boss is explicitly ignored because bridge bounds prevent the fall. It is not ground.
- `BossBounds`: logical x clamp 5650..6320 on `FallenGateKnight`; no physics layer and no Player-blocking shape.
- `CastleGate`: World layer while closed/opening; its 48×260 `GateCollision` disables only after the 1.00-second lift completes.
- `RearBattleBarrier`: visible World layer during a live Boss encounter; disabled and hidden before entry, after Boss death, and after an uncleared respawn.

## Solid versus one-way

`Floor`, `PlatformA..D`, `GargoylePerch`, walls, `WoodenBridge`, `CastleFloor`, `CastleFacade`, rear barrier, and closed castle gate are full solid colliders. None of the five elevated first-level platforms has `one_way_collision` enabled. A future pass-through small jump platform must be individually named and documented; one-way is not the default.

Player normal, Hurt, Dash, Dash Attack, Death and post-respawn movement use the same 24×52 CharacterBody collider. Weapons, cloak, ghost and VFX remain outside it. `move_and_slide()` is the movement authority; ceiling contact clears negative vertical velocity, and no Dash path changes `global_position` to bypass World collision.
