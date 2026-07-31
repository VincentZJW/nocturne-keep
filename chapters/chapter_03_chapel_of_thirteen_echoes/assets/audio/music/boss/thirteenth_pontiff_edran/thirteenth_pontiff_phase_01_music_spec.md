# Litany of the Thirteenth Bell / 第十三钟祷

## Musical contract

- Owner: Chapter III Boss Phase 1, The Thirteenth Pontiff Edran.
- Tempo/meter: dotted-quarter = 92 BPM, 6/8. MIDI uses the equivalent quarter = 138 BPM.
- Form: 96 bars, 192 dotted-quarter pulses, 125.217396 seconds; A (1–24), B (25–48), C (49–72), A' (73–96).
- Tonal centre: D Phrygian/minor, using E-flat as the liturgical friction and restrained A-flat pressure.
- Original thirteen-tone litany: D–E-flat–F–A-flat–G–F–E-flat–C–D–B-flat–A-flat–E-flat–D.
- Palette: additive pipe organ, oscillator/formant non-semantic choir, bowed low strings, synthesized old-bronze bell, bass drum, chain/censer transients and cold pad.
- Provenance: completely synthesized from fixed-seed local code. No samples, online service, commercial composition, real hymn, liturgical chant or semantic vocal text is used.

## Dramatic form

1. A — Organ Litany: ceremonial stillness and the Pontiff's controlled authority.
2. B — Thirteen Bells: exactly thirteen prominent old-bronze tolls over bars 29–41.
3. C — Unburied Summoning: lower choir, drum and chain pressure for summons and elemental magic.
4. A' — Judgement: the litany returns with wider register, but never resolves heroically.

## Runtime/loop contract

- Runtime asset: `thirteenth_pontiff_phase_01_litany.ogg`, Vorbis, 48 kHz, stereo.
- Godot import: loop enabled, offset 0, BPM 92, beat count 192, bar pulse count 2. The importer uses the dotted-quarter pulse as its bar grid; the typed definition retains the authored 6/8 meter.
- Entry: Boss intro begins at -18 dB; formal Phase 1 combat restores -10 dB.
- Exit after MU3: the cue attenuates to -24 dB over 0.75 seconds when Phase Transition starts, then crossfades for 1.10 seconds into `The Bell Within the Bone` when the typed `black_bell_reveal` stage fires.

## Editable deliverables

- `source/generate_thirteenth_pontiff_phase_01.py`: deterministic composition/render authority.
- `source/thirteenth_pontiff_phase_01_score.json`: complete 1,120-event score and section metadata.
- `thirteenth_pontiff_phase_01_litany.mid`: Standard MIDI file for future orchestration edits.
- `thirteenth_pontiff_phase_01_litany.analysis.json`: objective PCM/render analysis and SHA-256.
