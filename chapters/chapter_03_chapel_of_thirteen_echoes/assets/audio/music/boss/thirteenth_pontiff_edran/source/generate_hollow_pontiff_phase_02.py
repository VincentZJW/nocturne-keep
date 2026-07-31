#!/usr/bin/env python3
"""Render Edran Phase 2's original, sample-free 6/8 pressure litany."""

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


SEED = 31312413
PULSE_BPM = 124.0  # Dotted-quarter pulse in 6/8.
MIDI_QUARTER_BPM = 186.0
PULSES_PER_BAR = 2
BAR_COUNT = 130  # Ten thirteen-bar pressure cycles.
TOTAL_PULSES = float(PULSES_PER_BAR * BAR_COUNT)
TITLE = "The Bell Within the Bone / 骨中之钟"
OUTPUT_ROOT = Path(__file__).resolve().parent.parent
OGG_PATH = OUTPUT_ROOT / "hollow_pontiff_phase_02_bell_within_bone.ogg"
MIDI_PATH = OUTPUT_ROOT / "hollow_pontiff_phase_02_bell_within_bone.mid"
ANALYSIS_PATH = OUTPUT_ROOT / "hollow_pontiff_phase_02_bell_within_bone.analysis.json"
SCORE_PATH = OUTPUT_ROOT / "source" / "hollow_pontiff_phase_02_score.json"

# Phase 1's original thirteen-note litany, inverted/downward and registrally fractured.
PHASE_01_MOTIF = [62, 63, 65, 68, 67, 65, 63, 60, 62, 58, 56, 51, 50]
HOLLOW_MOTIF = [50, 49, 47, 44, 45, 47, 49, 52, 50, 54, 56, 61, 62]


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


def section_for_cycle(cycle: int) -> str:
    return (
        "BONE_LITANY",
        "BOUND_PROCESSION",
        "ELEMENTAL_RUPTURE",
        "UNBURIED_CHOIR",
        "BLACK_BELL_JUDGEMENT",
    )[cycle // 2]


def build_score() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    progression = [
        (38, [50, 53, 56]),
        (39, [51, 54, 58]),
        (36, [48, 51, 55]),
        (32, [44, 49, 51]),
        (34, [46, 50, 53]),
        (37, [49, 53, 56]),
    ]
    for bar in range(BAR_COUNT):
        cycle = bar // 13
        cycle_bar = bar % 13
        section = section_for_cycle(cycle)
        pulse = float(bar * PULSES_PER_BAR)
        bass_note, chord = progression[(cycle_bar // 2 + cycle) % len(progression)]
        pressure = min(4, cycle // 2)

        # Urgent fixed organ and low strings retain the Phase 1 chapel identity.
        for voice, chord_note in enumerate(chord):
            pan = -0.34 + float(voice) * 0.34
            add(events, "organ", pulse, 0.90, chord_note, 49 + pressure * 3, pan)
            add(events, "organ", pulse + 1.0, 0.86, chord_note, 45 + pressure * 3, -pan)
            if voice < 2:
                add(events, "strings", pulse, 1.82, chord_note - 12, 47 + pressure * 4, pan * 0.45)
        add(events, "bass", pulse, 0.86, bass_note, 72 + pressure * 3, -0.08)
        add(events, "bass", pulse + 1.0, 0.74, bass_note + (7 if cycle_bar % 2 else 0), 58 + pressure * 3, 0.08)

        # Each thirteen-bar cycle carries one transformed thirteen-note litany.
        if cycle_bar in (0, 6):
            motif = HOLLOW_MOTIF if cycle_bar == 0 else list(reversed(PHASE_01_MOTIF))
            transpose = -12 if section in ("ELEMENTAL_RUPTURE", "BLACK_BELL_JUDGEMENT") else 0
            for index, note in enumerate(motif):
                start = pulse + float(index) * 0.25
                add(
                    events,
                    "organ",
                    start,
                    0.21,
                    note + transpose,
                    68 + (12 if index in (0, 6, 12) else 0) + pressure * 2,
                    -0.26 if index % 2 == 0 else 0.26,
                )

        # Low wordless choir fragments; deliberately non-semantic and never a real hymn.
        if cycle_bar in (2, 7, 11):
            choir_root = chord[0] + (0 if section == "UNBURIED_CHOIR" else 12)
            add(events, "choir", pulse, 1.78, choir_root, 45 + pressure * 4, -0.30)
            add(events, "choir", pulse + 0.12, 1.62, chord[1] + 12, 42 + pressure * 4, 0.30)

        # Dense but readable 6/8 combat pulse. Short rests before the thirteenth toll create breath.
        if cycle_bar != 12:
            add(events, "timpani", pulse, 0.62, 36, 66 + pressure * 4, -0.12)
            if cycle_bar % 2 == 1 or section in ("ELEMENTAL_RUPTURE", "BLACK_BELL_JUDGEMENT"):
                add(events, "timpani", pulse + 1.0, 0.50, 38, 49 + pressure * 4, 0.14)
        if cycle_bar in (1, 4, 8, 10):
            add(events, "chain", pulse + 0.5, 0.35, 76 + (cycle_bar % 3), 46 + pressure * 3, -0.62)
            add(events, "chain", pulse + 1.5, 0.31, 79 - (cycle_bar % 2), 42 + pressure * 3, 0.62)

        # The black bell closes each cycle: twelve restrained tolls, then one heavy thirteenth.
        if cycle_bar < 12:
            add(events, "bell", pulse, 1.72, 46 if cycle_bar % 3 else 50, 46 + pressure * 3, 0.22 if cycle_bar % 2 else -0.22)
        else:
            add(events, "bell", pulse, 2.90, 38, 92, 0.0)
            add(events, "timpani", pulse, 1.20, 31, 88, 0.0)

        # Elemental rupture gets cold upper fractures without masking attack telegraphs.
        if section == "ELEMENTAL_RUPTURE" and cycle_bar in (3, 8):
            add(events, "glass", pulse + 0.5, 0.68, 80 - cycle_bar, 45, 0.48)
        if section == "BLACK_BELL_JUDGEMENT" and cycle_bar in (0, 5):
            add(events, "pad", pulse, 5.80, chord[-1] + 12, 32, 0.36 if cycle_bar else -0.36)

    return events


def main() -> None:
    events = build_score()
    mix = render_events(events, PULSE_BPM, TOTAL_PULSES, SEED)
    edge_samples = int(round(0.008 * 48_000))
    edge_curve = np.sin(np.linspace(0.0, np.pi * 0.5, edge_samples, dtype=np.float32)) ** 2
    mix[:edge_samples] *= edge_curve[:, None]
    mix[-edge_samples:] *= edge_curve[::-1, None]
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
                "thirteen_bar_cycles": 10,
                "phase_01_motif": PHASE_01_MOTIF,
                "hollow_motif": HOLLOW_MOTIF,
                "sample_provenance": "fully synthesized; no samples or external services",
                "events": [event.__dict__ for event in events],
            },
            ensure_ascii=False,
            indent=2,
        ) + "\n",
        encoding="utf-8",
    )
    print(
        "HOLLOW_PONTIFF_PHASE_02_RENDER: PASS "
        f"events={len(events)} duration={analysis.duration_seconds:.6f}s "
        f"peak={analysis.peak_dbfs:.2f}dBFS rms={analysis.rms_dbfs:.2f}dBFS "
        f"boundary={analysis.boundary_delta:.6f} sha256={analysis.sha256}"
    )


if __name__ == "__main__":
    main()
