# Music System Specification

## Runtime ownership

`res://scripts/audio/music_manager.gd` is the single persistent music authority. It owns two reusable `AudioStreamPlayer` decks on the `Music` bus. Chapter/Boss controllers request stable track IDs; attack AI and presentation scenes do not create music players or poll HP to choose music.

The formal bus layout is:

```text
Master
├── Music
├── SFX
├── Ambient
└── UI
```

Definitions are typed `MusicTrackDefinition` Resources registered by `MusicTrackRegistry`. Runtime APIs include play, crossfade, fade out, stop, pause/resume, volume, dialogue duck/restore, one-shot phase switching and preload lookup.

## Chapter II — Hollow Duchess

| Track ID | Cue | Tempo/meter | Runtime gain | Loop |
| --- | --- | --- | --- | --- |
| `CH2_BOSS_MUSIC_PHASE_01` | Existing Broken Waltz motif loop | 109.09 BPM, 3/4 | -13 dB | 0.000–6.600 s |
| `CH2_BOSS_MUSIC_PHASE_02` | The Final Waltz, Unmasked | 132 BPM, 3/4 | -9 dB | 0.000–130.909083 s |

The existing Phase 1 asset is deliberately documented as a short intro/motif loop, not a new production-length score. MU1 does not silently add an unapproved fourth composition.

Event contract:

1. Room encounter begins: clear the encounter phase guard and start Phase 1 with a 0.35-second fade.
2. `phase_transition_started`: attenuate Phase 1 by 10 dB over 0.90 seconds.
3. Saved presentation reaches 68% mask reveal: emit `phase_02_revealed`, restore the duck target and crossfade from the start of Phase 2 over 1.10 seconds.
4. The `CH2_DUCHESS_PHASE_02_ONCE` guard prevents repeated HP/hit events from restarting Phase 2.
5. Boss defeat: 1.50-second fade. Player respawn: immediate stop and phase-guard reset. Leaving the room/scene: short safety fade.

## Debug and diagnostics

Chapter II debug spawn IDs `CH2_BOSS_MUSIC_PHASE_01`, `CH2_BOSS_MUSIC_TRANSITION` and `CH2_BOSS_MUSIC_PHASE_02` route through `MainBootstrap`, request the formal Boss entrance and show a small overlay with track ID, playback position, Music Bus gain, active deck count and switch count. The overlay is disabled outside these explicit debug entries and does not write formal save data.

## Source and provenance

The Phase 2 score is a fixed-seed project-owned composition rendered with local NumPy/SciPy oscillators and FFmpeg Vorbis. It uses no downloaded samples, real hymn, existing waltz or remote generation service. The generator, event score JSON and Standard MIDI are retained next to the chapter-local OGG so future work remains reproducible.

## MU1 boundary

Only Chapter II Phase 2 and the shared foundation required to play it are complete. Chapter III Phase 1/2 production and their event bindings are MU2/MU3. Dialogue/reward/chapter-exit polish across both bosses and final three-track pressure QA remain MU4/MU5.
