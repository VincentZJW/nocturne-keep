# First Boss Room Specification

Version: 1.0
Last updated: 2026-07-24

## Authored Main nodes

- `World/BossRoom/BossCheckpoint`: `(5480,612)`.
- `EntryTrigger`: `(5600,430)`.
- `EntranceGate`: x=5630.
- `FallenGateKnight`: `(6120,596)`.
- `ExitGate`: x=6480.
- `ExitTrigger`: `(6540,430)`.

## Flow

1. Entry selects the checkpoint, restores Player Health/Stamina, closes both gates, activates Boss, and shows signal-driven Boss HUD.
2. Player death runs the existing body/ghost sequence. Respawn at the checkpoint resets the Boss fully, opens the entrance, rearms entry, hides HUD, and never preserves Phase/attack state.
3. Boss death completes its animation, opens both gates, fades Boss HUD, and shows `The gate is open. / 大门已经开启。`.
4. Crossing Exit after victory shows `LEVEL COMPLETE / 第一关完成`; no second level is loaded.

Boss HUD observes Body/Shield signals only. Shield zero changes its readout to `BROKEN`; the HUD never mutates combat data.
