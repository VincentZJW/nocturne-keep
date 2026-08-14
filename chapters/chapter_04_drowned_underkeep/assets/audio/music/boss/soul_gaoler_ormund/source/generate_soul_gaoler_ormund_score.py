#!/usr/bin/env python3
"""Render Ormund's original compound-meter Boss score.

The music is synthesized locally from authored note events. No samples,
downloaded music, external generation service, or borrowed melody are used.
The public BPM values are dotted-quarter pulses; MIDI/render tempo is the
equivalent quarter-note tempo so the saved 6/8 files remain standards-valid.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np


REPO_ROOT = Path(__file__).resolve().parents[8]
sys.path.insert(0, str(REPO_ROOT))

from scripts.audio.tools.procedural_music import (  # noqa: E402
    SAMPLE_RATE,
    ScoreEvent,
    analyse_file_samples,
    render_events,
    write_analysis,
    write_ogg,
    write_standard_midi,
)


OUTPUT_ROOT = Path(__file__).resolve().parent.parent
SOURCE_ROOT = Path(__file__).resolve().parent
SEED = 4041913
QUARTER_BEATS_PER_6_8_BAR = 3.0

P1_BPM = 102.0
P1_RENDER_BPM = P1_BPM * 1.5
P1_BARS = 128
P1_TITLE = "The Weight of the Last Key / 末钥之重"
P1_STEM = "soul_gaoler_phase_01_submerged_chains"

P2_BPM = 128.0
P2_RENDER_BPM = P2_BPM * 1.5
P2_BARS = 160
P2_TITLE = "The Gaol Breaks Within / 狱锁自内崩裂"
P2_STEM = "soul_gaoler_phase_02_broken_cage"

TRANSITION_BPM = 128.0
TRANSITION_RENDER_BPM = TRANSITION_BPM * 1.5
TRANSITION_BARS = 10
TRANSITION_TITLE = "The Soul Cage Gives Way / 魂笼崩裂"
TRANSITION_STEM = "soul_gaoler_phase_transition_soul_cage_break"

# Nine-note D-minor/Phrygian Ormund sentence. The opening preserves his old
# D-C-Bb-A-Eb identity; the closing F-Eb-D-A makes it a complete, hummable
# theme without using Edran's thirteen-bell/religious pitch language.
ORMUND_THEME = [50, 48, 46, 45, 39, 41, 40, 38, 45]
GAOLER_MOTIF = ORMUND_THEME[:5]
SOUL_PRISON_THEME = [65, 68, 67, 65, 64, 63, 62]
UNDERTOW_MOTIF = [57, 55, 51, 50]


def add(
    events: list[ScoreEvent], track: str, beat: float, duration: float,
    note: int, velocity: int, pan: float,
) -> None:
    events.append(ScoreEvent(track, beat, duration, note, velocity, pan))


def add_phrase(
    events: list[ScoreEvent], track: str, beat: float, notes: list[int],
    spacing: float, duration: float, velocity: int, pan: float,
    transpose: int = 0,
) -> None:
    for index, note in enumerate(notes):
        phrase_pan = pan + (-0.06 if index % 2 == 0 else 0.06)
        add(events, track, beat + index * spacing, duration, note + transpose, velocity, phrase_pan)


def add_ormund_statement(
    events: list[ScoreEvent], beat: float, track: str, velocity: int,
    compact: bool = False, transpose: int = 0,
) -> None:
    spacing = 0.34 if compact else 0.50
    duration = 0.28 if compact else 0.43
    add_phrase(events, track, beat, ORMUND_THEME, spacing, duration, velocity, -0.08, transpose)


def section_for(bar: int, ranges: list[tuple[int, str]]) -> tuple[str, int]:
    for start, name in reversed(ranges):
        if bar >= start:
            return name, bar - start
    raise ValueError("section map must begin at bar zero")


def add_compound_foundation(
    events: list[ScoreEvent], beat: float, root: int, chord: list[int],
    intensity: int, busy: bool,
) -> None:
    bass_velocity = 58 + intensity * 5
    # The two dotted-quarter anchors keep the 6/8 sway heavy rather than light.
    add(events, "bass", beat, 1.34, root - 12, bass_velocity + 7, -0.12)
    add(events, "bass", beat + 1.5, 1.28, root - 5, bass_velocity, 0.10)
    add(events, "brass", beat + 0.04, 1.30, root, 48 + intensity * 5, -0.04)
    add(events, "brass", beat + 1.54, 1.20, chord[0], 43 + intensity * 5, 0.10)
    pulse_offsets = (0.0, 0.5, 1.0, 1.5, 2.0, 2.5) if busy else (0.0, 1.0, 1.5, 2.5)
    for index, offset in enumerate(pulse_offsets):
        note = chord[index % 2] - 12
        velocity = 42 + intensity * 4 + (5 if offset in (0.0, 1.5) else 0)
        add(events, "strings", beat + offset, 0.38, note, velocity, -0.26 + (index % 2) * 0.52)


def add_compound_percussion(
    events: list[ScoreEvent], beat: float, bar: int, intensity: int,
    chain_accent: bool,
) -> None:
    add(events, "timpani", beat, 0.48, 31, 64 + intensity * 5, -0.08)
    add(events, "timpani", beat + 1.5, 0.44, 35, 52 + intensity * 5, 0.08)
    if bar % 2 == 1:
        add(events, "timpani", beat + 2.5, 0.28, 38, 38 + intensity * 4, 0.16)
    if chain_accent:
        add(events, "chain", beat + 2.52, 0.30, 74 + (bar % 4), 40 + intensity * 5, -0.52 if bar % 2 else 0.52)


P1_RANGES = [
    (0, "INTRO"), (8, "A"), (36, "B"), (60, "A_PRIME"),
    (84, "UNDERTOW"), (104, "A_DOUBLE_PRIME"),
]
P1_PROGRESSIONS = {
    "INTRO": [(38, [50, 53, 57]), (39, [51, 55, 58])],
    "A": [(38, [50, 53, 57]), (36, [48, 51, 55]), (34, [46, 50, 53]), (33, [45, 48, 52])],
    "B": [(34, [46, 50, 53]), (31, [43, 46, 50]), (39, [51, 55, 58]), (38, [50, 53, 57])],
    "A_PRIME": [(38, [50, 53, 57]), (36, [48, 51, 55]), (34, [46, 50, 53]), (39, [51, 55, 58])],
    "UNDERTOW": [(38, [50, 53, 57]), (32, [44, 48, 51]), (35, [47, 50, 54]), (36, [48, 51, 55])],
    "A_DOUBLE_PRIME": [(38, [50, 53, 57]), (34, [46, 50, 53]), (39, [51, 55, 58]), (33, [45, 48, 52])],
}


def build_phase_one() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    for bar in range(P1_BARS):
        beat = bar * QUARTER_BEATS_PER_6_8_BAR
        section, section_bar = section_for(bar, P1_RANGES)
        progression = P1_PROGRESSIONS[section]
        root, chord = progression[(section_bar // 4) % len(progression)]
        intensity = 0 if section == "INTRO" else 1 if section in ("B", "UNDERTOW") else 2
        add_compound_foundation(events, beat, root, chord, intensity, False)
        add_compound_percussion(events, beat, bar, intensity, section_bar % 8 == 7)
        if bar % 4 == 0:
            add(events, "water", beat, 11.7, 31 if section == "UNDERTOW" else 35, 30 + intensity * 4, -0.42)
            add(events, "pad", beat + 0.08, 11.4, chord[-1] + 12, 25 + intensity * 3, 0.40)

        if section == "INTRO" and section_bar == 3:
            add_phrase(events, "brass", beat, ORMUND_THEME[:4], 0.62, 0.52, 48, -0.08)
        elif section in ("A", "A_PRIME", "A_DOUBLE_PRIME") and section_bar % 8 == 0:
            lead = "brass" if section != "A_PRIME" else "strings"
            add_ormund_statement(events, beat, lead, 70 + intensity * 3)
        elif section == "B" and section_bar % 8 == 0:
            add_phrase(events, "strings", beat, SOUL_PRISON_THEME, 0.42, 0.35, 47, 0.18, -12)
        elif section == "UNDERTOW" and section_bar % 4 == 0:
            add_phrase(events, "strings", beat, UNDERTOW_MOTIF, 0.48, 0.40, 49, -0.18, -12)
        if section == "A_DOUBLE_PRIME" and section_bar in (8, 16):
            add_phrase(events, "strings", beat + 0.18, ORMUND_THEME[:5], 0.46, 0.38, 48, 0.20, 12)
    return events


P2_RANGES = [
    (0, "A2"), (32, "B2"), (64, "C2"), (92, "A3"), (124, "FINAL_LOCK"),
]
P2_PROGRESSIONS = {
    "A2": [(38, [50, 53, 57]), (37, [49, 52, 56]), (36, [48, 51, 55]), (34, [46, 50, 53])],
    "B2": [(39, [51, 54, 58]), (38, [50, 53, 57]), (37, [49, 52, 56]), (32, [44, 48, 51])],
    "C2": [(38, [50, 53, 57]), (32, [44, 48, 51]), (35, [47, 50, 54]), (36, [48, 51, 55])],
    "A3": [(38, [50, 53, 57]), (34, [46, 50, 53]), (39, [51, 54, 58]), (33, [45, 48, 52])],
    "FINAL_LOCK": [(38, [50, 53, 57]), (32, [44, 48, 51]), (39, [51, 54, 58]), (34, [46, 50, 53])],
}


def build_phase_two() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    for bar in range(P2_BARS):
        beat = bar * QUARTER_BEATS_PER_6_8_BAR
        section, section_bar = section_for(bar, P2_RANGES)
        progression = P2_PROGRESSIONS[section]
        root, chord = progression[(section_bar // 4 + section_bar // 12) % len(progression)]
        intensity = 3 if section == "FINAL_LOCK" else 2
        add_compound_foundation(events, beat, root, chord, intensity, True)
        # Syncopated cello answers the pulse without becoming a second melody.
        for offset, note in ((0.75, chord[0] - 5), (2.25, chord[1] - 5)):
            add(events, "strings", beat + offset, 0.32, note, 48 + intensity * 4, 0.22)
        add_compound_percussion(events, beat, bar, intensity, section_bar % 8 == 7)
        if bar % 4 == 0:
            add(events, "water", beat, 11.7, 31 if section == "C2" else 35, 36 + intensity * 3, -0.44)
            add(events, "soul", beat + 0.06, 11.5, chord[1] + 12, 30 + intensity * 3, 0.42)

        if section in ("A2", "A3", "FINAL_LOCK") and section_bar % 8 == 0:
            add_ormund_statement(events, beat, "brass", 78 + intensity * 3, True)
        elif section == "B2" and section_bar % 8 == 0:
            add_phrase(events, "strings", beat, SOUL_PRISON_THEME, 0.30, 0.24, 54, 0.18, -12)
        elif section == "C2" and section_bar % 4 == 0:
            add_phrase(events, "strings", beat, UNDERTOW_MOTIF, 0.31, 0.25, 56, -0.18, -12)
        if section == "FINAL_LOCK" and section_bar in (12, 28):
            add_phrase(events, "strings", beat + 0.20, ORMUND_THEME[:5], 0.30, 0.24, 53, 0.20, 12)
            add(events, "gate", beat, 0.88, 31, 66, 0.0)
    return events


def build_transition() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    total_beats = TRANSITION_BARS * QUARTER_BEATS_PER_6_8_BAR
    add(events, "soul", 0.0, total_beats - 0.2, 26, 62, 0.0)
    add(events, "water", 0.0, total_beats - 0.1, 31, 43, -0.35)
    add(events, "brass", 0.0, 4.2, 38, 50, 0.0)
    add(events, "chain", 3.0, 0.55, 69, 86, -0.65)
    add(events, "chain", 6.0, 0.62, 74, 94, 0.65)
    add(events, "gate", 12.0, 1.35, 35, 96, 0.0)
    add(events, "water", 18.0, 4.2, 26, 84, 0.0)
    add(events, "gate", 23.1, 0.62, 31, 112, 0.0)
    add(events, "timpani", 23.1, 0.58, 31, 110, 0.0)
    return events


def render_score(
    events: list[ScoreEvent], display_bpm: float, render_bpm: float,
    bars: int, title: str, stem: str, seed: int,
    sections: dict[str, list[int]], loops: bool,
) -> None:
    total_beats = bars * QUARTER_BEATS_PER_6_8_BAR
    mix = render_events(events, render_bpm, total_beats, seed)
    edge_samples = int(round(0.008 * SAMPLE_RATE))
    edge_curve = np.sin(np.linspace(0.0, np.pi * 0.5, edge_samples, dtype=np.float32)) ** 2
    mix[:edge_samples] *= edge_curve[:, None]
    mix[-edge_samples:] *= edge_curve[::-1, None]
    ogg_path = OUTPUT_ROOT / f"{stem}.ogg"
    midi_path = OUTPUT_ROOT / f"{stem}.mid"
    analysis_path = OUTPUT_ROOT / f"{stem}.analysis.json"
    score_path = SOURCE_ROOT / f"{stem}_score.json"
    write_standard_midi(events, midi_path, render_bpm, 6, 8, title)
    write_ogg(mix, ogg_path, title)
    analysis = analyse_file_samples(mix, ogg_path)
    write_analysis(analysis, analysis_path)
    score_path.write_text(
        json.dumps(
            {
                "title": title,
                "seed": seed,
                "bpm": display_bpm,
                "render_quarter_bpm": render_bpm,
                "time_signature": "6/8",
                "bars": bars,
                "duration_seconds": analysis.duration_seconds,
                "loop_begin_seconds": 0.0,
                "loop_end_seconds": analysis.duration_seconds if loops else 0.0,
                "loops": loops,
                "sections": sections,
                "ormund_theme": ORMUND_THEME,
                "gaoler_motif": GAOLER_MOTIF,
                "soul_prison_theme": SOUL_PRISON_THEME,
                "undertow_motif": UNDERTOW_MOTIF,
                "normal_active_layer_target": [5, 7],
                "chain_role": "phrase-ending and structural accents only",
                "sample_provenance": "fully synthesized locally; no samples or external services",
                "events": [event.__dict__ for event in events],
            },
            ensure_ascii=False,
            indent=2,
        ) + "\n",
        encoding="utf-8",
    )
    print(
        f"{stem.upper()}_RENDER: PASS events={len(events)} "
        f"duration={analysis.duration_seconds:.6f}s peak={analysis.peak_dbfs:.2f}dBFS "
        f"rms={analysis.rms_dbfs:.2f}dBFS boundary={analysis.boundary_delta:.6f} "
        f"sha256={analysis.sha256}"
    )


def main() -> None:
    render_score(
        build_phase_one(), P1_BPM, P1_RENDER_BPM, P1_BARS, P1_TITLE, P1_STEM, SEED,
        {
            "Intro": [1, 8], "A": [9, 36], "B": [37, 60],
            "A_prime": [61, 84], "C_Undertow": [85, 104],
            "A_double_prime": [105, 128],
        }, True,
    )
    render_score(
        build_phase_two(), P2_BPM, P2_RENDER_BPM, P2_BARS, P2_TITLE, P2_STEM, SEED + 1,
        {
            "A2": [1, 32], "B2": [33, 64], "C2_Undertow": [65, 92],
            "A3": [93, 124], "Final_Lock": [125, 160],
        }, True,
    )
    render_score(
        build_transition(), TRANSITION_BPM, TRANSITION_RENDER_BPM,
        TRANSITION_BARS, TRANSITION_TITLE, TRANSITION_STEM, SEED + 2,
        {
            "Chain_Breaks": [1, 2], "Soul_Cage_Rupture": [3, 4],
            "Flood_Surge": [5, 6], "Final_Impact": [7, 8],
        }, False,
    )


if __name__ == "__main__":
    main()
