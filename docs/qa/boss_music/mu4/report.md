# Boss Music MU4 QA — Dialogue and Lifecycle

Date: 2026-07-31  
Formal routes: `MainBootstrap -> SilentCourt / Chapter03Route`

## Result

| Contract | Status | Evidence |
|---|---|---|
| Dialogue Music Duck | PASS | Shared Music bus is attenuated by 6 dB; Chapter II and III bindings tested |
| Duck/Crossfade independence | PASS | Bus-level Duck remains active without cancelling either two-deck crossfade |
| Chapter II retry | PASS | Existing formal controller stops Phase 2, clears guard and starts Phase 1 on next encounter |
| Chapter III retry | PASS | Respawn rebuilds saved Boss room, clears guard, skips repeated long intro and starts Phase 1 |
| Boss death | PASS | Both room controllers begin a 1.50-second fade; track ID clears immediately and decks stop |
| Reward state | PASS | Chapter II post-Boss fade and Chapter III `CH3_POST_BOSS` retain no battle track |
| Chapter exit | PASS | Boss-room safety fade/stop leaves `CH3_UNDERKEEP_DESCENT` with zero Boss decks |
| Main/F5 integration | PASS | Bootstrap-routed Chapter II/III tests and three Chapter III graphical captures |
| Output/Debugger | PASS | Final focused exact-4.7.1 runs contain no red parser/resource/runtime error |

## Runtime contract

- Dialogue attenuation: 6.0 dB on the shared `Music` bus, 0.18-second attack and 0.25-second release.
- Crossfade safety: deck gain/crossfade Tweens remain separate from the Music-bus Duck Tween.
- Death fade: 1.50 seconds for both Bosses.
- Retry: formal attempts restart Phase 1 and clear their encounter-scoped phase-switch guard. Debug Phase 2 starts remain explicit exceptions and do not write persistent state.
- Reward/exit: no Phase 1/2 track ID and no active Boss deck.

## Main evidence

- `01_dialogue_duck_transition_main.png` — Edran transformation dialogue on the formal Main route; overlay reports the active 6 dB Duck.
- `02_retry_phase_01_main.png` — saved Boss room reconstructed after retry with Phase 1 selected.
- `03_reward_silent_main.png` — formal post-Boss reliquary route after death fade with no Boss music deck.

## Exact verification

- `test_music_manager_mu1.gd` — PASS: five buses, two reusable decks, 20 guarded transition cycles.
- `test_hollow_duchess_music_mu1.gd` — PASS: formal Main route, one Phase 1/2 start, 6 dB dialogue binding, death and Phase 1 retry. The long-standing Chapter II threaded-load teardown still reports two anonymous zero-reference `RefCounted` objects under verbose mode; no MusicManager, deck or MU4 resource is among them.
- `test_boss_music_mu4.gd` — PASS: 6 dB Duck, crossfade safety, Edran death, Phase 1 retry, silent Reward and silent chapter exit.
- `test_thirteenth_pontiff_music_mu3.gd` — PASS: black bell once, Phase 2 once, 20 one-shot guard cycles, one settled deck.
- `test_chapter_03_r5_full_route.gd` — PASS: 50 room transitions / 10 route cycles.
- `capture_boss_music_mu4_qa.gd` — PASS: three 1280×720 MainBootstrap captures.

## Boundary

MU4 proves deterministic lifecycle state and formal-route integration. Normal-volume human listening, full combat SFX masking, ten complete fights per Boss and the final three-score pressure matrix remain the separately approved MU5 gate.
