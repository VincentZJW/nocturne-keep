#!/usr/bin/env python3
"""Render Edran Phase 1's original, sample-free 6/8 litany."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np


REPO_ROOT = Path(__file__).resolve().parents[8]
sys.path.insert(0, str(REPO_ROOT))

from scripts.audio.tools.procedural_music import (  # noqa: E402
    ScoreEvent,
    analyse_file_samples,
    render_events,
    write_analysis,
    write_ogg,
    write_standard_midi,
)


SEED = 31309213
PULSE_BPM = 92.0  # Dotted-quarter pulse in 6/8.
MIDI_QUARTER_BPM = 138.0
PULSES_PER_BAR = 2
BAR_COUNT = 96
TOTAL_PULSES = float(PULSES_PER_BAR * BAR_COUNT)
TITLE = "Litany of the Thirteenth Bell / 第十三钟祷"
OUTPUT_ROOT = Path(__file__).resolve().parent.parent
OGG_PATH = OUTPUT_ROOT / "thirteenth_pontiff_phase_01_litany.ogg"
MIDI_PATH = OUTPUT_ROOT / "thirteenth_pontiff_phase_01_litany.mid"
ANALYSIS_PATH = OUTPUT_ROOT / "thirteenth_pontiff_phase_01_litany.analysis.json"
SCORE_PATH = OUTPUT_ROOT / "source" / "thirteenth_pontiff_phase_01_score.json"

# D4–E-flat4–F4–A-flat4–G4–F4–E-flat4–C4–D4–B-flat3–A-flat3–E-flat3–D3.
THIRTEEN_TONE_MOTIF = [62, 63, 65, 68, 67, 65, 63, 60, 62, 58, 56, 51, 50]


def add(
    events: list[ScoreEvent],
    track: str,
    pulse: float,
    duration: float,
    note: int,
    velocity: int,
    pan: float,
) -> None:
    events.append(ScoreEvent(track, pulse, duration, note, velocity, pan))


def section_for_bar(bar: int) -> str:
    if bar < 24:
        return "A_ORGAN_LITANY"
    if bar < 48:
        return "B_THIRTEEN_BELLS"
    if bar < 72:
        return "C_UNBURIED_SUMMONING"
    return "A_PRIME_JUDGEMENT"


def build_score() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    # D Phrygian/minor: Dm, E-flat, C minor, B-flat, with restrained A-flat pressure.
    progression = [
        (38, [50, 53, 57]),
        (39, [51, 55, 58]),
        (36, [48, 51, 55]),
        (34, [46, 50, 53]),
        (32, [44, 48, 51]),
        (38, [50, 53, 56]),
    ]
    for bar in range(BAR_COUNT):
        section = section_for_bar(bar)
        pulse = float(bar * PULSES_PER_BAR)
        section_index = bar // 24
        progression_index = (bar // 2 + (1 if section == "C_UNBURIED_SUMMONING" else 0)) % len(progression)
        bass_note, chord = progression[progression_index]

        # Circular organ/low-string foundation: the final bars deliberately return to bar-one harmony.
        organ_velocity = 42 + section_index * 3
        if section == "C_UNBURIED_SUMMONING":
            organ_velocity += 7
        for voice, chord_note in enumerate(chord):
            pan = -0.32 + float(voice) * 0.32
            add(events, "organ", pulse, 1.94, chord_note, organ_velocity, pan)
            if voice < 2:
                add(events, "strings", pulse, 1.90, chord_note - 12, 38 + section_index * 4, pan * 0.55)
        add(events, "bass", pulse, 1.78, bass_note, 64 + section_index * 4, -0.05)
        if bar % 2 == 1:
            add(events, "bass", pulse + 1.0, 0.78, bass_note + 7, 46 + section_index * 3, 0.08)

        # Cold air in the nave; A' adds a slightly wider upper octave without becoming triumphant.
        if bar % 4 == 0:
            add(events, "pad", pulse, 7.82, chord[0] + 12, 35 + section_index * 2, -0.38)
            add(events, "pad", pulse + 0.08, 7.68, chord[-1] + 12, 31 + section_index * 2, 0.38)

        # The thirteen-note original litany is stated once per four-bar phrase.
        if bar % 4 == 0:
            motif = THIRTEEN_TONE_MOTIF.copy()
            if section == "C_UNBURIED_SUMMONING":
                motif = [note - 12 if index in (8, 9, 10, 11, 12) else note for index, note in enumerate(motif)]
            elif section == "A_PRIME_JUDGEMENT" and (bar // 4) % 2 == 1:
                motif = [note + (12 if index in (0, 3, 7) else 0) for index, note in enumerate(motif)]
            for index, note in enumerate(motif):
                start = pulse + float(index) * 0.5
                velocity = 61 + (12 if index in (0, 3, 8, 12) else 0) + section_index * 2
                add(events, "organ", start, 0.42, note, velocity, -0.20 if index % 2 == 0 else 0.20)

        # Wordless, synthesized vowel choir; no language or hymn source is used.
        if section in ("A_ORGAN_LITANY", "A_PRIME_JUDGEMENT") and bar % 4 == 2:
            add(events, "choir", pulse, 3.86, chord[1] + 12, 38 + section_index * 3, -0.24)
            add(events, "choir", pulse + 0.10, 3.72, chord[2] + 12, 35 + section_index * 3, 0.24)
        if section == "C_UNBURIED_SUMMONING" and bar % 2 == 0:
            add(events, "choir", pulse, 3.80, chord[0] + 12, 48, -0.30)
            add(events, "choir", pulse + 0.15, 3.56, chord[1] + 12, 44, 0.30)

        # B's thirteen old-bronze tolls: exactly thirteen prominent strikes over bars 28–40.
        if 28 <= bar <= 40:
            bell_note = 50 if bar in (28, 40) else 51 if bar % 3 == 0 else 46
            add(events, "bell", pulse, 2.65, bell_note, 76 if bar in (28, 40) else 63, 0.0)
        elif section == "A_PRIME_JUDGEMENT" and bar % 8 == 0:
            add(events, "bell", pulse, 2.50, 50, 58, 0.34)

        # C is the summon/element pressure passage: low drum and censers/chains, never a dance groove.
        if section == "C_UNBURIED_SUMMONING":
            add(events, "timpani", pulse, 0.85, 36, 63 if bar % 4 else 76, -0.10)
            if bar % 2 == 1:
                add(events, "timpani", pulse + 1.0, 0.62, 38, 50, 0.14)
            add(events, "chain", pulse + (0.5 if bar % 2 == 0 else 1.5), 0.48, 76, 45, 0.58 if bar % 2 else -0.58)
        elif section == "B_THIRTEEN_BELLS" and bar % 4 == 3:
            add(events, "chain", pulse + 1.5, 0.42, 79, 34, 0.52)
        elif section == "A_PRIME_JUDGEMENT" and bar % 4 == 0:
            add(events, "timpani", pulse, 0.78, 36, 52, -0.08)

    return events


def main() -> None:
    events = build_score()
    mix = render_events(events, PULSE_BPM, TOTAL_PULSES, SEED)
    # Vorbis flushes its final packet toward zero. Match both decoded edges with
    # a transparent 8 ms raised-cosine taper so the runtime loop has no click.
    edge_samples = int(round(0.008 * 48_000))
    edge_curve = np.sin(np.linspace(0.0, np.pi * 0.5, edge_samples, dtype=np.float32)) ** 2
    mix[:edge_samples] *= edge_curve[:, None]
    mix[-edge_samples:] *= edge_curve[::-1, None]
    # MIDI uses conventional quarter-note tempo. Each dotted-quarter score pulse = 1.5 MIDI quarters.
    midi_events = [
        ScoreEvent(
            event.track,
            event.start_beat * 1.5,
            event.duration_beats * 1.5,
            event.midi_note,
            event.velocity,
            event.pan,
        )
        for event in events
    ]
    write_standard_midi(midi_events, MIDI_PATH, MIDI_QUARTER_BPM, 6, 8, TITLE)
    write_ogg(mix, OGG_PATH, TITLE)
    analysis = analyse_file_samples(mix, OGG_PATH)
    write_analysis(analysis, ANALYSIS_PATH)
    SCORE_PATH.write_text(
        json.dumps(
            {
                "title": TITLE,
                "seed": SEED,
                "pulse_bpm": PULSE_BPM,
                "midi_quarter_bpm": MIDI_QUARTER_BPM,
                "time_signature": "6/8",
                "pulse_unit": "dotted_quarter",
                "bars": BAR_COUNT,
                "sections": {
                    "A": [1, 24],
                    "B": [25, 48],
                    "C": [49, 72],
                    "A_prime": [73, 96],
                },
                "thirteen_tone_motif": THIRTEEN_TONE_MOTIF,
                "sample_provenance": "fully synthesized; no samples or external services",
                "events": [event.__dict__ for event in events],
            },
            ensure_ascii=False,
            indent=2,
        ) + "\n",
        encoding="utf-8",
    )
    print(
        "THIRTEENTH_PONTIFF_PHASE_01_RENDER: PASS "
        f"events={len(events)} duration={analysis.duration_seconds:.6f}s "
        f"peak={analysis.peak_dbfs:.2f}dBFS rms={analysis.rms_dbfs:.2f}dBFS "
        f"boundary={analysis.boundary_delta:.6f} sha256={analysis.sha256}"
    )


if __name__ == "__main__":
    main()
