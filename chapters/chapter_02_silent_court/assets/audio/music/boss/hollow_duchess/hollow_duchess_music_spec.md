# Hollow Duchess Two-Phase Music Specification

## Identity and provenance

Seraphine's score is an original, sample-free dark court waltz rendered by
`source/generate_hollow_duchess_music.py`. All instruments are synthesized by
the repository's `scripts/audio/tools/procedural_music.py`; no downloaded,
commercial, third-party or generative-service audio is present. The JSON score,
standard MIDI and compressed stems are retained for revision.

The shared six-note identity is D–F–E–C–E-flat–D, answered by
A–C–D–C-sharp–C–A. Phase 2 transforms these motives rather than replacing them.

## Runtime masters

| Cue | BPM | Meter | Bars | Duration | Loop begin | Loop end | Default level |
|---|---:|---:|---:|---:|---:|---:|---:|
| `hollow_duchess_phase_01_waltz.ogg` | 96 | 3/4 | 80 | 150.000 s | 0.000 s | 150.000 s | -12.0 dB |
| `hollow_duchess_phase_02_unmasked_waltz.ogg` | 120 | 3/4 | 88 | 132.000 s | 0.000 s | 132.000 s | -9.5 dB |
| `hollow_duchess_transition_stinger.ogg` | 120 | 3/4 | 3 | 4.500 s | — | — | -7.5 dB |

Vorbis streams use 48 kHz stereo. Both masters are authored as circular scores,
then receive a transparent 10 ms raised-cosine edge taper. The exact boundary
sample delta is 0.0 in both generated analysis reports.

## Phase 1 — The Last Courteous Waltz

The 150-second form is `Intro (6 bars) → A (16) → B (16) → C (14) → A′ (16)
→ Loop Return (12)`. Intro and Loop Return subtract percussion and density;
A states the principal courtesy motive; B introduces the response in a changed
register and harmonic rotation; C adds chromatic mirror/glass fractures; A′
returns one octave wider with strings and restrained synthetic choir.

Four motif variants per main section, six harmonic roots, rhythmic displacement,
orchestration addition/subtraction and register changes prevent any exact one-
or two-bar cell from running unchanged more than four times.

## Phase 2 — The Final Waltz, Unmasked

The 132-second form is `A2 (20 bars) → B2 (20) → Phantom Dance (20) → Broken
Waltz (12) → Final Reprise (16)`. It retains 3/4, the Phase-1 motives, D-minor
bass gravity, harpsichord and strings, but raises the tempo to 120 BPM. A2
compresses the bow into six eighth-note thrusts; B2 adds chromatic fracture;
Phantom Dance displaces accents and introduces glass/chain colour; Broken Waltz
removes rhythmic density; Final Reprise restores the principal motive in upper
register with fuller orchestration. This is a related high-pressure variation,
not a playback-speed change.

## Transition and encounter lifecycle

- Intro starts Phase 1 at -18 dB. Dialogue adds 6 dB Music-bus ducking.
- Combat start restores the Phase-1 authored -12 dB target over 0.55 seconds.
- Phase transition fades Phase 1 toward -20 dB over 0.90 seconds and plays the
  one-shot 4.5-second `The Mask Breaks` Stinger on one persistent player.
- `phase_02_revealed` consumes one phase-switch guard and crossfades Phase 2 over
  1.00 second. Hurt, stagger and repeated HP notifications cannot retrigger it.
- Boss death fades the active score over 1.50 seconds.
- Respawn stops both decks and the Stinger, clears the guard, and the next room
  entry restarts Phase 1 from time zero. Debug Phase-2 entry remains transient.

Music uses the `Music` bus. The manager owns two persistent crossfade decks plus
one persistent non-looping transition player; it does not create players per
phase switch.

## Editable deliverables

- `source/generate_hollow_duchess_music.py`
- `source/*_score.json`
- `midi/*.mid`
- `stems/phase_01_{melody,orchestra,pulse}.ogg`
- `stems/phase_02_{melody,orchestra,pulse}.ogg`
- `*.analysis.json`

Regenerate from the repository root with:

```sh
python3 chapters/chapter_02_silent_court/assets/audio/music/boss/hollow_duchess/source/generate_hollow_duchess_music.py
```

The script is deterministic. Re-running it with the recorded seed recreates the
masters, score JSON, MIDI and stems.
