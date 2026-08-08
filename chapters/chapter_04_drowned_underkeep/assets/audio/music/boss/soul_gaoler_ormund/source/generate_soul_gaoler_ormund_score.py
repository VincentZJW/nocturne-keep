#!/usr/bin/env python3
"""Render Soul Gaoler Ormund's original two-phase score and transition.

Every voice is synthesized locally.  The score uses no samples, downloaded
music, external generation service, or borrowed melody.
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
BEATS_PER_BAR = 4

P1_BPM = 78.0
P1_BARS = 60
P1_TITLE = "The Weight of the Last Key / 末钥之重"
P1_STEM = "soul_gaoler_phase_01_submerged_chains"

P2_BPM = 104.0
P2_BARS = 72
P2_TITLE = "The Gaol Breaks Within / 狱锁自内崩裂"
P2_STEM = "soul_gaoler_phase_02_broken_cage"

TRANSITION_BPM = 104.0
TRANSITION_BARS = 4
TRANSITION_TITLE = "The Soul Cage Gives Way / 魂笼崩裂"
TRANSITION_STEM = "soul_gaoler_phase_transition_soul_cage_break"

# Original D-minor/Phrygian gaoler motif: D-C-Bb-A-Eb.  The final Eb leaves
# the prison door unresolved instead of cadencing back to D.
GAOLER_MOTIF = [50, 48, 46, 45, 39]
SOUL_RESPONSE = [41, 44, 43, 47, 46, 40]


def add(
    events: list[ScoreEvent], track: str, beat: float, duration: float,
    note: int, velocity: int, pan: float,
) -> None:
    events.append(ScoreEvent(track, beat, duration, note, velocity, pan))


def p1_section(bar: int) -> str:
    if bar < 4:
        return "INTRO"
    if bar < 16:
        return "A_THE_WARDEN"
    if bar < 26:
        return "B_THE_CHAINS"
    if bar < 36:
        return "C_THE_FLOOD"
    if bar < 44:
        return "D_THE_CAGE"
    if bar < 56:
        return "A_PRIME_GAOLER_ADVANCES"
    return "LOOP_RETURN"


def build_phase_one() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    harmony = [
        (38, [50, 53, 57]),  # D minor
        (36, [48, 51, 55]),  # C minor
        (34, [46, 50, 53]),  # Bb
        (33, [45, 48, 52]),  # A diminished pressure
        (39, [51, 55, 58]),  # Eb
        (32, [44, 48, 51]),  # Ab/C colour
    ]
    for bar in range(P1_BARS):
        beat = float(bar * BEATS_PER_BAR)
        section = p1_section(bar)
        section_bar = {
            "INTRO": bar,
            "A_THE_WARDEN": bar - 4,
            "B_THE_CHAINS": bar - 16,
            "C_THE_FLOOD": bar - 26,
            "D_THE_CAGE": bar - 36,
            "A_PRIME_GAOLER_ADVANCES": bar - 44,
            "LOOP_RETURN": bar - 56,
        }[section]
        root, chord = harmony[(bar // 2 + (1 if section == "C_THE_FLOOD" else 0)) % len(harmony)]

        # Three deliberately changing low-frequency beds: gate-step, double
        # chain, and held pressure.  No pattern repeats unchanged over four bars.
        rhythm_variant = (bar // 2 + (2 if section == "A_PRIME_GAOLER_ADVANCES" else 0)) % 3
        foundation_velocity = 46 if section == "INTRO" else 58
        if section in ("C_THE_FLOOD", "A_PRIME_GAOLER_ADVANCES"):
            foundation_velocity += 8
        if section == "D_THE_CAGE":
            foundation_velocity -= 12
        add(events, "bass", beat, 3.72, root - 12, foundation_velocity + 7, -0.08)
        add(events, "brass", beat, 3.66, root, foundation_velocity, 0.05)
        for voice, note in enumerate(chord[:2]):
            add(events, "strings", beat + 0.05 * voice, 3.55, note - 12, foundation_velocity - 8, -0.32 + voice * 0.64)

        if rhythm_variant == 0:
            add(events, "timpani", beat, 0.82, 31, 72 if section != "INTRO" else 46, -0.10)
            add(events, "chain", beat + 1.0, 0.34, 72, 38, 0.58)
            add(events, "strings", beat + 2.0, 1.58, root, 49, -0.22)
        elif rhythm_variant == 1:
            add(events, "timpani", beat, 0.78, 33, 66, -0.12)
            add(events, "timpani", beat + 1.5, 0.55, 36, 48, 0.10)
            add(events, "chain", beat + 2.5, 0.42, 76, 46, -0.62)
        else:
            add(events, "soul", beat, 3.65, root + 12, 35, 0.18)
            add(events, "timpani", beat + 2.0, 0.72, 31, 55, 0.0)

        # Submerged ambience is sectional and low-passed, leaving the combat
        # SFX presence band clear.
        if bar % 2 == 0:
            water_velocity = 30 if section in ("INTRO", "D_THE_CAGE", "LOOP_RETURN") else 38
            if section == "C_THE_FLOOD":
                water_velocity = 53
            add(events, "water", beat, 7.72, 35 if bar % 4 else 31, water_velocity, -0.42)
            add(events, "pad", beat + 0.12, 7.48, chord[-1] + 12, 25 + water_velocity // 5, 0.42)

        # Main theme changes voice, register, spacing and ending by section.
        if section != "INTRO" and section_bar % 4 == 0:
            motif = GAOLER_MOTIF.copy()
            track = "brass"
            spacing = 0.72
            duration = 0.62
            transpose = 0
            if section == "B_THE_CHAINS":
                track, spacing, transpose = "strings", 0.64, 12
            elif section == "C_THE_FLOOD":
                motif = [50, 48, 45, 46, 39]
                spacing = 0.58
            elif section == "D_THE_CAGE":
                motif = [50, 46, 39]
                spacing, duration = 1.18, 1.02
            elif section == "A_PRIME_GAOLER_ADVANCES":
                track, spacing = "brass", 0.52
                add(events, "strings", beat + 0.25, 3.35, 38, 63, -0.34)
            for index, note in enumerate(motif):
                add(events, track, beat + index * spacing, duration, note + transpose, 68 + (10 if index in (0, len(motif) - 1) else 0), -0.18 if index % 2 == 0 else 0.18)

        # The imprisoned-soul counter-theme is non-semantic and does not mimic
        # Chapter III's liturgical writing.
        if section in ("B_THE_CHAINS", "D_THE_CAGE", "A_PRIME_GAOLER_ADVANCES") and section_bar % 4 == 2:
            for index, note in enumerate(SOUL_RESPONSE):
                add(events, "choir" if section != "D_THE_CAGE" else "soul", beat + index * 0.56, 0.48, note + 12, 36 + (8 if index in (0, 5) else 0), 0.30 if index % 2 else -0.30)

        if section == "B_THE_CHAINS" and section_bar in (1, 4, 7):
            add(events, "gate", beat + 2.0, 1.25, 38, 36, -0.48 + section_bar * 0.08)
        if section == "A_PRIME_GAOLER_ADVANCES" and section_bar % 3 == 0:
            add(events, "gate", beat, 1.35, 34, 49, 0.0)

    return events


def p2_section(bar: int) -> str:
    if bar < 14:
        return "A2_BROKEN_GAOLER"
    if bar < 26:
        return "B2_SOUL_CAGE_RUPTURE"
    if bar < 38:
        return "C2_UNDERTOW"
    if bar < 48:
        return "D2_NO_PRISON_HOLDS"
    if bar < 66:
        return "FINAL_LOCK"
    return "LOOP_RETURN"


def build_phase_two() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    harmony = [
        (38, [50, 53, 57]), (37, [49, 52, 56]), (36, [48, 51, 55]),
        (34, [46, 50, 53]), (39, [51, 54, 58]), (32, [44, 48, 51]),
    ]
    fragment_a = [50, 48, 46]
    fragment_b = [45, 39, 40]
    for bar in range(P2_BARS):
        beat = float(bar * BEATS_PER_BAR)
        section = p2_section(bar)
        root, chord = harmony[(bar + bar // 6) % len(harmony)]
        intensity = 0 if section == "D2_NO_PRISON_HOLDS" else 2 if section == "FINAL_LOCK" else 1

        # Faster, fractured pressure beds retain weight instead of becoming a
        # light action ostinato.
        add(events, "bass", beat, 1.72, root - 12, 67 + intensity * 4, -0.08)
        add(events, "bass", beat + 2.0, 1.48, root - 5 + (1 if bar % 5 == 0 else 0), 55 + intensity * 5, 0.08)
        add(events, "brass", beat, 1.82, root, 58 + intensity * 6, -0.12)
        add(events, "brass", beat + 2.5, 1.20, chord[-1], 49 + intensity * 5, 0.16)
        for voice, note in enumerate(chord[:2]):
            add(events, "strings", beat + voice * 0.08, 1.72, note - 12, 57 + intensity * 6, -0.36 + voice * 0.72)
            add(events, "strings", beat + 2.0 + voice * 0.06, 1.55, note - 12 + (1 if section == "B2_SOUL_CAGE_RUPTURE" else 0), 52 + intensity * 6, 0.36 - voice * 0.72)

        rhythm_variant = (bar + bar // 4) % 3
        if section != "D2_NO_PRISON_HOLDS":
            add(events, "timpani", beat, 0.66, 31, 76 + intensity * 5, -0.12)
            if rhythm_variant == 0:
                add(events, "chain", beat + 1.0, 0.31, 76, 48, 0.62)
                add(events, "timpani", beat + 2.0, 0.54, 35, 58, 0.10)
            elif rhythm_variant == 1:
                add(events, "timpani", beat + 1.5, 0.48, 36, 50, 0.12)
                add(events, "chain", beat + 3.0, 0.30, 79, 54, -0.62)
            else:
                add(events, "chain", beat + 0.5, 0.29, 74, 43, -0.58)
                add(events, "chain", beat + 2.5, 0.33, 81, 50, 0.58)
        else:
            add(events, "soul", beat, 3.72, root + 12, 50, -0.18)
            if bar % 2 == 0:
                add(events, "chain", beat + 3.0, 0.44, 69, 34, 0.46)

        if bar % 2 == 0:
            add(events, "water", beat, 7.70, 31 if section == "C2_UNDERTOW" else 35, 48 if section == "C2_UNDERTOW" else 32, -0.46)
            add(events, "soul", beat + 0.10, 7.48, chord[1] + 12, 34 + intensity * 4, 0.42)

        # Phase 1's D-C-Bb / A-Eb motif is split between strings, brass and
        # trapped-soul response, with displaced entrances and chromatic damage.
        if bar % 4 == 0:
            for index, note in enumerate(fragment_a):
                add(events, "strings", beat + index * 0.43, 0.35, note + (12 if section == "B2_SOUL_CAGE_RUPTURE" else 0), 72 + intensity * 4, -0.30)
            for index, note in enumerate(fragment_b):
                chromatic = -1 if section in ("B2_SOUL_CAGE_RUPTURE", "FINAL_LOCK") and index == 1 else 0
                add(events, "brass", beat + 1.75 + index * 0.47, 0.39, note + chromatic, 70 + intensity * 5, 0.28)
            add(events, "choir", beat + 2.20, 1.45, SOUL_RESPONSE[(bar // 4) % len(SOUL_RESPONSE)] + 12, 42 + intensity * 4, 0.0)

        if section == "C2_UNDERTOW" and bar % 3 == 1:
            for step in range(6):
                add(events, "bass", beat + step * 0.5, 0.42, root - 12 + (step % 4), 46 + step * 2, -0.22 + step * 0.08)
        if section == "FINAL_LOCK" and bar % 3 == 0:
            add(events, "gate", beat, 1.30, 31, 59, 0.0)
            add(events, "choir", beat + 0.12, 3.45, chord[-1] + 12, 48, 0.0)

    return events


def build_transition() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    # Four bars at 104 BPM = 9.230769 seconds.  Beat locations are also the
    # contract used by the Boss transition signal timeline.
    add(events, "soul", 0.0, 15.2, 26, 62, 0.0)
    add(events, "water", 0.0, 15.3, 31, 43, -0.35)
    add(events, "brass", 0.0, 3.6, 38, 48, 0.0)
    add(events, "chain", 2.0, 0.62, 69, 86, -0.65)   # 1.154 s
    add(events, "chain", 4.0, 0.72, 74, 94, 0.65)    # 2.308 s
    add(events, "gate", 8.0, 1.85, 35, 96, 0.0)      # 4.615 s cage rupture
    add(events, "water", 12.0, 3.4, 26, 84, 0.0)     # 6.923 s surge
    add(events, "gate", 15.0, 0.72, 31, 112, 0.0)    # 8.654 s final impact
    add(events, "timpani", 15.0, 0.70, 31, 110, 0.0)
    return events


def render_score(
    events: list[ScoreEvent], bpm: float, bars: int, title: str, stem: str,
    seed: int, sections: dict[str, list[int]], loops: bool,
) -> None:
    total_beats = float(bars * BEATS_PER_BAR)
    mix = render_events(events, bpm, total_beats, seed)
    edge_samples = int(round(0.008 * SAMPLE_RATE))
    edge_curve = np.sin(np.linspace(0.0, np.pi * 0.5, edge_samples, dtype=np.float32)) ** 2
    mix[:edge_samples] *= edge_curve[:, None]
    mix[-edge_samples:] *= edge_curve[::-1, None]
    ogg_path = OUTPUT_ROOT / f"{stem}.ogg"
    midi_path = OUTPUT_ROOT / f"{stem}.mid"
    analysis_path = OUTPUT_ROOT / f"{stem}.analysis.json"
    score_path = SOURCE_ROOT / f"{stem}_score.json"
    write_standard_midi(events, midi_path, bpm, 4, 4, title)
    write_ogg(mix, ogg_path, title)
    analysis = analyse_file_samples(mix, ogg_path)
    write_analysis(analysis, analysis_path)
    score_path.write_text(
        json.dumps(
            {
                "title": title,
                "seed": seed,
                "bpm": bpm,
                "time_signature": "4/4",
                "bars": bars,
                "duration_seconds": analysis.duration_seconds,
                "loop_begin_seconds": 0.0,
                "loop_end_seconds": analysis.duration_seconds if loops else 0.0,
                "loops": loops,
                "sections": sections,
                "gaoler_motif": GAOLER_MOTIF,
                "soul_response": SOUL_RESPONSE,
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
        build_phase_one(), P1_BPM, P1_BARS, P1_TITLE, P1_STEM, SEED,
        {
            "Intro": [1, 4], "A_The_Warden": [5, 16], "B_The_Chains": [17, 26],
            "C_The_Flood": [27, 36], "D_The_Cage": [37, 44],
            "A_prime_The_Gaoler_Advances": [45, 56], "Loop_Return": [57, 60],
        }, True,
    )
    render_score(
        build_phase_two(), P2_BPM, P2_BARS, P2_TITLE, P2_STEM, SEED + 1,
        {
            "A2_Broken_Gaoler": [1, 14], "B2_Soul_Cage_Rupture": [15, 26],
            "C2_Undertow": [27, 38], "D2_No_Prison_Holds": [39, 48],
            "Final_Lock": [49, 66], "Loop_Return": [67, 72],
        }, True,
    )
    render_score(
        build_transition(), TRANSITION_BPM, TRANSITION_BARS, TRANSITION_TITLE,
        TRANSITION_STEM, SEED + 2,
        {"Chain_Breaks": [1, 1], "Soul_Cage_Rupture": [2, 2], "Flood_Surge": [3, 3], "Final_Impact": [4, 4]},
        False,
    )


if __name__ == "__main__":
    main()
