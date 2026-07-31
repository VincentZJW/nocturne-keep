# Boss Music MU3 QA — The Bell Within the Bone

Date: 2026-07-31
Formal route: `MainBootstrap -> Chapter03Route -> Ch3BossSanctumRoom`

## Result

| Contract | Status | Evidence |
|---|---|---|
| Original Phase 2 score exists | PASS | `hollow_pontiff_phase_02_bell_within_bone.ogg`, retained Python/MIDI/JSON |
| Phase 1 theme inheritance | PASS | Phase 1 thirteen-tone litany is reversed/registrally fractured; organ, bell and choir remain |
| Phase 2 pressure identity | PASS | 124 BPM 6/8, 130 bars, 10×13-bar cycles, denser low strings/drums/chains |
| Audio is non-empty production length | PASS | 125.806667 s Vorbis, 48 kHz stereo, 938,078 bytes |
| Loop boundary | PASS | whole-bar full-file loop; decoded endpoint delta 0.0; 600 s run completed 4 wraps |
| Peak/mix headroom | PASS | -3.10 dBFS peak, -17.50 dBFS RMS |
| Black-bell transition | PASS | typed `phase_transition_stage_reached(&"black_bell_reveal")`; no HP polling |
| One-shot switch | PASS | one formal switch plus 20 duplicate-guard regression cycles |
| Deck ownership | PASS | two decks only during 1.10 s crossfade; one afterward; no scene-local Music player |
| Main/F5 integration | PASS | formal Bootstrap debug route captures below |
| Ten-minute endurance | PASS | 4 wraps, max players 1, static memory growth -2,888 bytes |
| Output/Debugger | PASS | exact 4.7.1 clean focused test/capture/import logs |

## Objective audio data

- Title: `The Bell Within the Bone / 骨中之钟`
- Authored pulse: dotted-quarter = 124 BPM; 6/8; MIDI quarter = 186 BPM.
- Duration: rendered PCM 125.806458 s; final Vorbis 125.806667 s.
- Loop: 0.0–125.806458 s, 260 dotted-quarter pulses.
- Events: 2,052 deterministic score events, fixed seed `31312413`.
- Peak/RMS: -3.0980 / -17.4957 dBFS.
- SHA-256: `5f1916b08f505bcfd7a8ad22c7d6523c47f420090d2f01de0da4248bac3e5bf4`.
- Provenance: local oscillator/additive/noise synthesis only; no samples, remote service, real hymn or semantic choir text.

## Evidence

- `01_phase_01_transition_attenuation_main.png` — Phase 1 remains active at reduced level when protected transformation starts.
- `02_black_bell_crossfade_main.png` — named black-bell beat selected Phase 2; overlay shows two active decks only during crossfade.
- `03_phase_02_bell_bound_combat_main.png` — Phase 2 combat with one active deck and correct title/track.
- `04_phase_02_waveform.png` — complete-track waveform.
- `05_phase_02_spectrogram.png` — complete-track spectral distribution.

## Exact tests and outcomes

1. Phase 2 generator — PASS: 2,052 events, 125.806458 s, -3.10 dBFS peak, -17.50 dBFS RMS, endpoint delta 0.0.
2. `ffprobe` — PASS: Vorbis, 48,000 Hz, stereo, 125.806667 s.
3. `test_thirteenth_pontiff_music_mu3.gd` — PASS: black bell 1, formal Phase 2 1, guard cycles 20, settled players 1.
4. `test_music_manager_mu1.gd` — PASS: five buses, two decks, 20 baseline transitions.
5. `test_thirteenth_pontiff_music_mu2.gd` — PASS: Phase 1 intro/combat and approved MU3 handoff.
6. `test_edran_b4_b7_full_boss.gd` — PASS: protected transition, six Phase 2 attacks, death/reward interfaces.
7. `test_chapter_03_r5_full_route.gd` — PASS: 50 transitions, 10 cycles, persistent runtime.
8. `capture_thirteenth_pontiff_music_mu3_qa.gd` — PASS: three MainBootstrap runtime captures.
9. Real-time `MU_LONG_PLAY_SECONDS=600 MU_LONG_PLAY_TRACK_ID=CH3_BOSS_MUSIC_PHASE_02 test_music_manager_long_play.gd` — PASS: 4 wraps, max players 1, memory 32,600,269 -> 32,597,381 bytes, peak 32,602,101, growth -2,888.

## Manual listening boundary

Automation proves provenance, duration, format, seam, lifecycle state and runtime stability. Human listening should still judge musical taste, fatigue, attack-telegraph masking and perceived transition strength through `CH3_BOSS_MUSIC_TRANSITION`, then the full unforced `CH3_BOSS` fight.
