# The Bell Within the Bone / 骨中之钟

## Musical contract

- Owner: Chapter III Boss Phase 2, The Hollow Pontiff, Bell-Bound.
- Tempo/meter: dotted-quarter = 124 BPM, 6/8. MIDI uses the equivalent quarter = 186 BPM.
- Form: 130 bars, 260 dotted-quarter pulses, 125.806458 seconds; ten thirteen-bar pressure cycles grouped into five two-cycle sections.
- Tonal centre: D Phrygian/minor, preserving Phase 1's E-flat friction and adding lower chromatic collapse.
- Thematic inheritance: Phase 1's original thirteen-tone litany is reversed and registrally fractured; a second inverted/downward thirteen-note form becomes the Phase 2 organ ostinato.
- Palette: urgent additive pipe organ, non-semantic formant choir, dense low strings, bass, synthesized broken bronze bell, timpani, bone/chain transients, restrained glass fractures and cold pad.
- Provenance: completely synthesized from fixed-seed local code. No samples, online service, commercial score, hymn, religious chant or semantic vocal text is used.

## Dramatic form

1. Bone Litany — the original ritual survives inside the transformed body.
2. Bound Procession — chain and drum density replaces Phase 1's controlled procession.
3. Elemental Rupture — restrained glass colour supports elemental magic without masking telegraphs.
4. Unburied Choir — the wordless lower choir surfaces from beneath the organ.
5. Black Bell Judgement — each thirteen-bar cycle closes with a heavy low toll before the pulse resumes.

## Runtime and loop contract

- Runtime asset: `hollow_pontiff_phase_02_bell_within_bone.ogg`, Vorbis, 48 kHz, stereo.
- Loop: full-file whole-bar loop from 0.0 to 125.806458 seconds; both decoded endpoints taper to zero to prevent a click.
- Entry: Phase 1 attenuates when transformation begins; the named `black_bell_reveal` presentation event starts a 1.10-second crossfade, with Phase 2 starting at its authored first strong beat.
- Default runtime level: -10 dB through the Music bus. Dialogue and death lifecycle adjustments are owned by MU4.

## Editable deliverables

- `source/generate_hollow_pontiff_phase_02.py`: deterministic composition/render authority.
- `source/hollow_pontiff_phase_02_score.json`: complete score and transformation metadata.
- `hollow_pontiff_phase_02_bell_within_bone.mid`: Standard MIDI for future orchestration edits.
- `hollow_pontiff_phase_02_bell_within_bone.analysis.json`: objective PCM/render analysis and SHA-256.
