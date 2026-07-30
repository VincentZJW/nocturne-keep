# Boss Music MU2 QA Report

Date: 2026-07-30  
Scope: Chapter III Edran Phase 1 composition, loop, formal Boss event binding and Main/F5 evidence. MU3 Phase 2 music and complete transformation crossfade are excluded.

## Result matrix

| Item | Status | Evidence |
| --- | --- | --- |
| Original playable Phase 1 music | PASS | `thirteenth_pontiff_phase_01_litany.ogg`; fixed-seed generator, JSON score and MIDI retained |
| Identity / motif | PASS | Original 13-tone D–E-flat–F–A-flat–G–F–E-flat–C–D–B-flat–A-flat–E-flat–D litany; no real hymn/text/sample |
| Form / duration | PASS | 96 bars A–B–C–A', 125.217396 s PCM; 125.218667 s Vorbis decode |
| Format | PASS | OGG Vorbis, 48 kHz, stereo, 868,233 bytes, ~55.5 kb/s |
| Dynamics | PASS | -3.10 dBFS peak, -16.42 dBFS RMS; no full-scale clipping |
| Seam | PASS | 8 ms transparent edge treatment; decoded endpoint delta 0.00038285 / -68.34 dBFS; device-output seam audition passed |
| Godot loop metadata | PASS | `loop=true`, offset 0, dotted-quarter BPM 92, 192 pulses, 2 pulses/bar (authored meter 6/8) |
| Formal Boss intro/combat | PASS | Typed sanctum start event at -18 dB; Boss `activated` restores -10 dB; one start only |
| MU2 phase boundary | PASS | `phase_transition_started` fades Phase 1 over 0.90 s; no false Phase 2 music |
| MusicManager architecture | PASS | Persistent two-deck Autoload on Music bus; no sanctum/Boss-local Music player |
| Main/F5 route | PASS | `main_bootstrap.tscn → chapter_03_route.tscn → ch3_boss_sanctum_room.tscn`; three runtime captures |
| Real-time endurance | PASS | Final OGG played 600.0 real seconds; four wraps; maximum one deck; static-memory growth -2,888 bytes |
| Existing Boss/route regressions | PASS | Edran B4–B7, 986 elemental assertions / 20 cadence battles, and 50 Chapter III transitions |
| Output/Debugger | PASS | Exact 4.7.1 clean import/parse, focused tests, saved-room smoke, default Bootstrap and graphical capture have no red runtime error |
| Subjective fight mix | MANUAL | User should judge organ/bell/choir balance against live attacks, summons, magic and dialogue |

## Track delivery

- Title: `Litany of the Thirteenth Bell / 第十三钟祷`
- Runtime OGG: `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/audio/music/boss/thirteenth_pontiff_edran/thirteenth_pontiff_phase_01_litany.ogg`
- MIDI: same directory, `thirteenth_pontiff_phase_01_litany.mid`
- Generator: `source/generate_thirteenth_pontiff_phase_01.py`
- Event source: `source/thirteenth_pontiff_phase_01_score.json` (1,120 events)
- Analysis: `thirteenth_pontiff_phase_01_litany.analysis.json`
- Specification: `thirteenth_pontiff_phase_01_music_spec.md`
- SHA-256: `455cb6499a10fee0f7c901796c058fdbe6c38b1d6d3a396e9c1a7d76fc4350ac`

The score is fully synthesized with fixed-seed local NumPy/SciPy code and FFmpeg Vorbis encoding. It uses no downloaded asset, online generation service, semantic chant, real religious text, existing hymn or commercial score.

## Event binding

1. `Chapter03BossSanctum.intro_environment_started` → play Phase 1 and reach -18 dB over 0.60 s.
2. `ThirteenthPontiffEdran.activated` → retain the same playback position and restore -10 dB over 0.50 s.
3. `phase_transition_started` → clear the current track ID immediately and fade the active deck over 0.90 s.
4. Leaving the formal Boss room while Phase 1 is still active → short safety fade.

Edran AI never chooses a music track and the room does not poll HP. The room controller is the sole Chapter III Boss music event owner.

## Commands and outcomes

1. Generator — PASS: 1,120 events; 125.217396 s; peak -3.10 dBFS; RMS -16.42 dBFS.
2. `ffprobe` — PASS: Vorbis/48 kHz/stereo/125.218667 s/868,233 bytes.
3. Final decoded endpoint measurement — PASS: 0.00038285, approximately -68.34 dBFS.
4. `ffmpeg -stream_loop 4 -i <track> -t 600 -f null -` — PASS, continuous five-pass decode.
5. Full-section and seam `ffplay` audition — PASS through the macOS output device.
6. `test_music_manager_mu1.gd` — PASS: buses=5, decks=2, transitions=20, duplicate guard PASS, clean audio-thread shutdown.
7. `test_thirteenth_pontiff_music_mu2.gd` — PASS through MainBootstrap, track once, 6/8 metadata, combat level and transition fade.
8. `test_music_manager_long_play.gd` — PASS on final hash, 600 real seconds, four wraps, one active player, -2,888 byte static-memory growth.
9. Edran B4–B7, elemental magic and Chapter III R5 route suites — PASS.
10. Exact Godot 4.7.1 clean editor import, default F5-equivalent Bootstrap startup and independent Boss-room smoke — PASS.
11. Graphical Main capture — PASS on OpenGL/Metal Compatibility, three 1280×720 images.

## Visual and analysis evidence

- `01_ch3_phase_01_intro_main.png` — formal sanctum intro, Phase 1 track ID, one deck.
- `02_ch3_phase_01_combat_main.png` — formal Edran Phase 1 encounter/HUD, same track without restart.
- `03_ch3_phase_01_yield_main.png` — formal Phase Transition with the Phase 1 ID cleared while the deck attenuates.
- `04_phase_01_waveform.png` — full-track headroom and A–B–C–A' density.
- `05_phase_01_spectrogram.png` — organ/choir foundation, thirteen-bell region and denser summon passage.

## Manual F5 acceptance

Temporarily enable Chapter III debug start and select `CH3_BOSS_MUSIC_PHASE_01`, then press F5. Confirm the formal intro starts quietly, the same cue rises when Edran activates without restarting at 0:00, and the overlay remains at one active player. Fight through Phase 1 and judge the thirteen bell/organ/choir balance against melee, summon and elemental SFX. At 198 HP the track should fade to silence; that silence is the explicit MU2 boundary, not a completed Phase 2 transition. Restore Debug Chapter Start to disabled afterward.

## Known boundary

MU2 does not contain Edran Phase 2 music or the black-bell reveal crossfade. Dialogue ducking, defeat/retry/reward/exit lifecycle and final multi-track pressure testing remain MU3–MU5. No result in this report claims those later stages are complete.
