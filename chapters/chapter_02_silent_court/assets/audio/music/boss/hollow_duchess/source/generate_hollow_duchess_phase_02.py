#!/usr/bin/env python3
"""Render the original Chapter II Phase 2 score without external samples."""

from __future__ import annotations

import json
import sys
from pathlib import Path


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


SEED = 2202132
BPM = 132.0
BEATS_PER_BAR = 3
BAR_COUNT = 96
TOTAL_BEATS = float(BEATS_PER_BAR * BAR_COUNT)
TITLE = "The Final Waltz, Unmasked / 无面的最后华尔兹"
OUTPUT_ROOT = Path(__file__).resolve().parent.parent
OGG_PATH = OUTPUT_ROOT / "hollow_duchess_phase_02_unmasked.ogg"
MIDI_PATH = OUTPUT_ROOT / "hollow_duchess_phase_02_unmasked.mid"
ANALYSIS_PATH = OUTPUT_ROOT / "hollow_duchess_phase_02_unmasked.analysis.json"
SCORE_PATH = OUTPUT_ROOT / "source" / "hollow_duchess_phase_02_score.json"


def add_event(
    events: list[ScoreEvent],
    track: str,
    beat: float,
    duration: float,
    note: int,
    velocity: int,
    pan: float,
) -> None:
    events.append(ScoreEvent(track, beat, duration, note, velocity, pan))


def transformed_motif(section: int, phrase: int) -> list[int]:
    original = [74, 77, 76, 72, 75, 74]  # D5 F5 E5 C5 E-flat5 D5.
    if section == 0:
        return original
    if section == 1:
        displaced = [77, 76, 72, 75, 74, 73]
        return [note - (1 if phrase % 2 == 1 and index in (2, 5) else 0) for index, note in enumerate(displaced)]
    if section == 2:
        return [74, 71, 72, 76, 73, 74]
    if section == 3:
        return [74, 77, 76, 75, 74, 72]
    if section == 4:
        return [74, 75, 72, 76, 77, 74]
    return original if phrase % 2 == 0 else [74, 77, 76, 73, 75, 74]


def build_score() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    progression = [
        (50, [50, 53, 57]),  # D minor
        (48, [48, 51, 55]),  # C minor
        (51, [51, 55, 58]),  # E-flat major
        (50, [50, 53, 57]),
    ]
    for bar in range(BAR_COUNT):
        section = min(5, bar // 16)
        phrase = bar // 2
        beat = float(bar * BEATS_PER_BAR)
        root, chord = progression[(bar + (1 if section == 4 else 0)) % len(progression)]
        if section in (2, 4) and bar % 8 in (5, 6):
            chord = [root, root + 3, root + 6]
        density = 1.0 + float(section in (3, 5)) * 0.12
        add_event(events, "bass", beat, 1.12, root - 12, int(94 * density), -0.06)
        if bar % 4 == 3:
            add_event(events, "bass", beat + 2.0, 0.86, root - 5, 72, 0.08)
        add_event(events, "timpani", beat, 0.82, 38 if section < 3 else 36, 72 + section * 5, -0.10)
        if section >= 3 and bar % 2 == 1:
            add_event(events, "timpani", beat + 2.0, 0.52, 43, 54, 0.14)
        for chord_index, chord_note in enumerate(chord):
            pan = -0.42 + float(chord_index) * 0.42
            add_event(events, "strings", beat, 2.92, chord_note, 44 + section * 3, pan * 0.42)
            add_event(events, "harpsichord", beat + 1.0 + chord_index * 0.035, 0.72, chord_note + 12, 60 + section * 3, pan)
            add_event(events, "harpsichord", beat + 2.0 + chord_index * 0.028, 0.68, chord_note + 12, 57 + section * 3, -pan)
        motif = transformed_motif(section, phrase)
        motif_offset = (bar % 2) * 3
        for local_beat in range(3):
            note = motif[motif_offset + local_beat]
            accent = 87 if local_beat == 0 else 72
            if section == 1 and local_beat == 0:
                start = beat + 0.5
            elif section == 4 and local_beat == 1:
                start = beat + 1.5
            else:
                start = beat + float(local_beat)
            add_event(events, "harpsichord", start, 0.82, note, accent + section * 2, -0.26 if phrase % 2 == 0 else 0.26)
        if bar % 8 == 0:
            add_event(events, "glass", beat, 2.25, 86 - section, 72 + section * 2, 0.62)
            add_event(events, "glass", beat + 0.16, 1.92, 91 - section, 52 + section * 2, -0.58)
        if section >= 2 and bar % 4 == 2:
            add_event(events, "strings", beat + 0.5, 1.4, 63 - (bar % 3), 55 + section * 2, 0.54)
        if section in (3, 5):
            add_event(events, "bass", beat + 1.5, 0.42, root - 12, 66, 0.02)
    return events


def main() -> None:
    events = build_score()
    mix = render_events(events, BPM, TOTAL_BEATS, SEED)
    write_standard_midi(events, MIDI_PATH, BPM, 3, 4, TITLE)
    write_ogg(mix, OGG_PATH, TITLE)
    analysis = analyse_file_samples(mix, OGG_PATH)
    write_analysis(analysis, ANALYSIS_PATH)
    SCORE_PATH.write_text(
        json.dumps(
            {
                "title": TITLE,
                "seed": SEED,
                "bpm": BPM,
                "time_signature": "3/4",
                "bars": BAR_COUNT,
                "events": [event.__dict__ for event in events],
            },
            ensure_ascii=False,
            indent=2,
        ) + "\n",
        encoding="utf-8",
    )
    print(
        "HOLLOW_DUCHESS_PHASE_02_RENDER: PASS "
        f"events={len(events)} duration={analysis.duration_seconds:.6f}s "
        f"peak={analysis.peak_dbfs:.2f}dBFS rms={analysis.rms_dbfs:.2f}dBFS "
        f"boundary={analysis.boundary_delta:.6f} sha256={analysis.sha256}"
    )


if __name__ == "__main__":
    main()
