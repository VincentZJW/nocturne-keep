# Boss Music MU1 QA Report

Date: 2026-07-30
Scope: Chapter II Hollow Duchess Phase 2 composition, loop, shared music foundation, formal Boss binding and Main/F5 evidence. MU2/Chapter III music is excluded.

## Result matrix

| Item | Status | Evidence |
| --- | --- | --- |
| Original playable Phase 2 music | PASS | `hollow_duchess_phase_02_unmasked.ogg`, 1,363,013 bytes; fixed-seed generator and score retained |
| Phase 1 motif relationship | PASS | D–F–E–C–E-flat–D melody and D/C/E-flat/D bass transformed across 96 bars; score JSON/MIDI retained |
| Duration / format | PASS | 130.909333 s, OGG Vorbis, 48 kHz, stereo, approximately 83.2 kb/s |
| Dynamics | PASS | -3.10 dBFS peak, -18.65 dBFS RMS; no full-scale clipping |
| Seam construction | PASS | 0.000206 PCM endpoint amplitude delta (approximately -73.7 dBFS); periodic steady-state filtering, 3/4 whole-bar boundary and 600-second five-pass FFmpeg decode |
| Godot loop metadata | PASS | import `loop=true`, offset 0, BPM 132, 288 beats, 3 beats/bar |
| Music Bus architecture | PASS | `default_bus_layout.tres`: Master/Music/SFX/Ambient/UI; runtime decks route to Music |
| Reusable MusicManager | PASS | exactly two persistent decks; typed registry/API; no per-Boss music player |
| Phase transition | PASS | 0.90 s Phase 1 attenuation; 68% saved reveal marker; 1.10 s one-shot crossfade from Phase 2 strong beat |
| Transition regressions | PASS | 20 cycles; duplicate one-shot request rejected; one active player outside crossfade |
| Main/F5 route | PASS | `main_bootstrap.tscn → silent_court.tscn`; three formal debug spawn IDs and three captured runtime states |
| Real-time endurance | PASS | 600.0-second Godot AudioStreamPlayer run, four observed loop wraps, maximum one active player; static-memory growth -2,912 bytes |
| Output/Debugger | PASS | exact 4.7.1 import/parse, focused tests and Main capture reported no script/resource/red runtime errors |
| Subjective mix/fight feel | MANUAL | User should audition full fight against attack/dialogue/SFX; automation cannot certify musical taste or masking perception |

## Track delivery

- Title: `The Final Waltz, Unmasked / 无面的最后华尔兹`
- Runtime: `res://chapters/chapter_02_silent_court/assets/audio/music/boss/hollow_duchess/hollow_duchess_phase_02_unmasked.ogg`
- MIDI: same directory, `hollow_duchess_phase_02_unmasked.mid`
- Generator: `source/generate_hollow_duchess_phase_02.py`
- Event source: `source/hollow_duchess_phase_02_score.json`
- Shared renderer/MIDI writer: `res://scripts/audio/tools/procedural_music.py`
- Analysis: `hollow_duchess_phase_02_unmasked.analysis.json`
- Seed: `2202132`
- Tempo/meter/form: 132 BPM, 3/4, 96 bars, 288 beats
- Main instruments: broken harpsichord, bowed low strings, bass, glass partials and restrained timpani
- SHA-256: `971a386a616ca30416cb546fe9f3212f4f44f4bd6f54ae188d878ba4fb354d92`

The render is sample-free and does not quote a commercial track, real religious piece or existing waltz. The Phase 1 cue remains the original 6.6-second audited motif loop at `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/audio/broken_waltz_intro.tres`.

## Runtime binding evidence

- Global authority: `res://scripts/audio/music_manager.gd`
- Registry: `res://resources/audio/music_track_registry.tres`
- Boss event owner: `res://chapters/chapter_02_silent_court/scripts/boss/hollow_duchess_room_controller.gd`
- Reveal event owner: `res://chapters/chapter_02_silent_court/scripts/boss/duchess_encounter_presentation.gd`
- Formal level/debug entry: `res://chapters/chapter_02_silent_court/scripts/level/silent_court.gd`
- F5 main scene remains `res://scenes/bootstrap/main_bootstrap.tscn`.

The former `DuchessEncounterPresentation/BrokenWaltzPlayer` was removed. Music state now survives scene composition through the autoload and only the room controller decides Boss lifecycle timing.

## Commands and actual outcomes

1. Generator: `/opt/anaconda3/bin/python3 .../source/generate_hollow_duchess_phase_02.py` — PASS, 1,464 events, 130.909083 s, endpoint delta 0.000206.
2. Probe: `/opt/homebrew/bin/ffprobe ...hollow_duchess_phase_02_unmasked.ogg` — PASS, Vorbis/48 kHz/stereo/130.909333 s.
3. Continuous decode: `ffmpeg -stream_loop 4 -i <track> -t 600 -f null -` — PASS, five source passes decoded without error.
4. System audition: `ffplay -nodisp -autoexit -t 10 <track>` — PASS through the macOS output device; a two-copy seam excerpt (`-ss 128 -t 8`) also played across the real loop boundary without a playback error.
5. `test_music_manager_mu1.gd` — PASS, buses=5, decks=2, transitions=20, duplicate guard PASS.
6. `test_hollow_duchess_music_mu1.gd` — PASS through MainBootstrap, Phase 1 once, reveal once, Phase 2 once, overlay present.
7. `test_music_manager_long_play.gd` — PASS, real time 600.0 s, four loop wraps, max players=1; static memory start/end/peak = 30,244,858 / 30,241,946 / 30,246,666 bytes.
8. Existing Duchess Boss, Main integration, presentation/phase and Silent Court graybox suites — PASS.
9. Exact Godot 4.7.1 `--headless --editor --path . --quit` — PASS, import/parse completed without script/resource error.
10. Graphical Main capture driver — PASS on OpenGL/Metal Compatibility, three screenshots from the formal route.

## Visual and analysis evidence

- `01_ch2_phase_01_music_main.png` — Phase 1 track, one player, formal Boss HUD/room.
- `02_ch2_music_transition_main.png` — formal PhaseTransition while Phase 1 is attenuating.
- `03_ch2_phase_02_music_main.png` — reveal title and Phase 2 ID during the intended short two-deck crossfade.
- `04_phase_02_waveform.png` — whole-track waveform/dynamic headroom.
- `05_phase_02_spectrogram.png` — frequency-distribution evidence.

## Manual F5 acceptance

Enable Chapter II debug start and choose `CH2_BOSS_MUSIC_PHASE_01`, `CH2_BOSS_MUSIC_TRANSITION` or `CH2_BOSS_MUSIC_PHASE_02`. Confirm the overlay shows Phase 1 at entry, no hard cut at transformation, Phase 2 beginning from its opening strong beat, and no residual music after death/retry/scene exit. Then run `CH2_BOSS` for normal progression and judge dialogue/SFX readability at listening volume.

## Known boundary

The existing Phase 1 cue remains a short formal intro/motif loop, not a 90–150 second production composition. MU1 did not invent an unapproved fourth score. Some legacy Chapter II SceneTree tests still report their pre-existing ObjectDB cleanup warnings at process exit, but the exact editor parse, MU1 manager test, formal Main capture and runtime flow produced no red script/resource error. Chapter III music and the cross-Boss reward/exit polish are intentionally deferred to MU2–MU4; the final combined three-track QA matrix remains MU5.
