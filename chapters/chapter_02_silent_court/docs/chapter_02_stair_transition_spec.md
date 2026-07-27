# Chapter II closed stair transition specification

Status: implemented in Main, 2026-07-27

## Floor 1 → Floor 2

- Stair scene: `res://chapters/chapter_02_silent_court/scenes/rooms/grand_service_stair.tscn`
- Main instance: `SilentCourt/GameplayWorld/Geometry/GrandServiceStair`
- Terminal scene: `res://chapters/chapter_02_silent_court/scenes/rooms/grand_service_stair_terminal.tscn`
- Terminal instance: `SilentCourt/GameplayWorld/Geometry/GrandServiceStairTerminal`
- Collision wall: `.../GrandServiceStairTerminal/Geometry/EndWall/CollisionShape2D`
- Door: `.../GrandServiceStairTerminal/HeavyWoodDoor`
- Trigger: `SilentCourt/TransitionAreas/Floor1ToFloor2`
- Destination: `SilentCourt/PlayerSpawnPoints/CH2_FLOOR_2_START`
- Arrival architecture: `SilentCourt/GameplayWorld/Geometry/Floor2ArrivalVestibule`

The former Last Banquet walkable continuation at global `x=6320..7168` was cropped from the room rather than hidden. The new stone landing has a royal arch, heavy inset wood door, crest and paired candles. The terminal collision prevents bypassing the trigger or running into an empty corridor. F1 Camera right limit is 7040.

## Floor 2 → Floor 3

- Stair scene: `res://chapters/chapter_02_silent_court/scenes/rooms/servant_side_stair.tscn`
- Main instance: `SilentCourt/GameplayWorld/Geometry/ServantSideStair`
- Terminal scene: `res://chapters/chapter_02_silent_court/scenes/rooms/servant_side_stair_terminal.tscn`
- Terminal instance: `SilentCourt/GameplayWorld/Geometry/ServantSideStairTerminal`
- Collision wall: `.../ServantSideStairTerminal/Geometry/EndWall/CollisionShape2D`
- Door: `.../ServantSideStairTerminal/NarrowWoodDoor`
- Trigger: `SilentCourt/TransitionAreas/Floor2ToFloor3`
- Destination: `SilentCourt/PlayerSpawnPoints/CH2_FLOOR_3_START`
- Arrival architecture: `SilentCourt/GameplayWorld/Geometry/Floor3ArrivalVestibule`

The former Servant Passage walkable continuation at local `x=0..768` was removed. The narrower terminal uses timber structure, an old wall lamp and side-wing crest, and its collision-backed wall closes the outside of the stair. F2 Camera left limit is 64.

## Runtime sequence

1. Player enters the door threshold; concurrent and dead-player requests are rejected.
2. Input is locked and damage is temporarily disabled.
3. Encounter runtime deactivates all groups and removes Crossbow/Blood-Candle projectiles.
4. Fade reaches black, then the existing Player is relocated and Camera bounds are selected from destination world Y.
5. Camera smoothing is reset before fade-in.
6. Previous input/invulnerability contracts are restored; no Player, HUD or Camera instance is duplicated.

Ten automated requests per stair passed with exact destination and Camera bounds. Graphical MainBootstrap captures show both physical terminals and both arrival vestibules.
