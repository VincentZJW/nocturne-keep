# Chapter III Boss B2 QA

## Main/F5 contract

- Entry: `res://scenes/bootstrap/main_bootstrap.tscn`
- Debug chapter: `CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES`
- Debug spawn: `CH3_BOSS`
- Saved room instance: `Chapter03Route/RoomHost/Ch3BossSanctumRoom/BossActors/ThirteenthPontiffEdran`
- Saved boss scene: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/thirteenth_pontiff_edran.tscn`

## Evidence

- `01_edran_phase_01_idle_main.png`
- `02_edran_pontifical_sweep_active_main.png`
- `03_edran_b4_boundary_main.png`

B2 deliberately clamps at 198 HP and emits `phase_transition_requested`; it does not fabricate the B4 Phase Transition. Summon actors and the summon director remain B3 work.
