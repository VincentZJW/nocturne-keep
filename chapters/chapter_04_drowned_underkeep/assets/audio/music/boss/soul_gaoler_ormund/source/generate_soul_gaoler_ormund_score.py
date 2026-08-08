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
# The former response is retained as historical pitch DNA, but the formal
# seven-note Soul Prison theme gives the prisoners an actual singable line:
# F-Ab-G-F-E-Eb-D.  Its final chromatic sigh falls into the Gaoler's D centre.
SOUL_RESPONSE = [41, 44, 43, 47, 46, 40]
SOUL_PRISON_THEME = [65, 68, 67, 65, 64, 63, 62]
# A-G-Eb-D: a compact falling current that connects flood passages without
# becoming another constantly repeated tune.
UNDERTOW_MOTIF = [57, 55, 51, 50]


def add_phrase(
    events: list[ScoreEvent], track: str, beat: float, notes: list[int],
    spacing: float, duration: float, velocity: int, pan: float,
    transpose: int = 0,
) -> None:
    for index, note in enumerate(notes):
        phrase_pan = pan + (-0.08 if index % 2 == 0 else 0.08)
        add(events, track, beat + index * spacing, duration, note + transpose, velocity, phrase_pan)


def add_gaoler_theme(
    events: list[ScoreEvent], beat: float, variant: str, velocity: int = 72,
) -> None:
    """Six authored treatments of the same Gaoler identity."""
    if variant == "A_LOW_BRASS":
        add_phrase(events, "brass", beat, GAOLER_MOTIF, 0.66, 0.58, velocity, -0.08)
    elif variant == "B_CELLO":
        add_phrase(events, "strings", beat, GAOLER_MOTIF, 0.64, 0.58, velocity - 5, -0.20)
        add(events, "brass", beat + 0.12, 3.25, 38, velocity - 24, 0.24)
    elif variant == "C_SOUL_MIRROR":
        add_phrase(events, "strings", beat, GAOLER_MOTIF, 0.70, 0.64, velocity - 9, 0.18, 12)
        add(events, "soul", beat + 0.18, 3.28, 50, velocity - 34, -0.30)
    elif variant == "D_ANTIPHONAL_FRAGMENTS":
        add_phrase(events, "brass", beat, GAOLER_MOTIF[:2], 0.52, 0.44, velocity, -0.34)
        add_phrase(events, "strings", beat + 1.18, GAOLER_MOTIF[2:4], 0.50, 0.44, velocity - 6, 0.30)
        add(events, "chain", beat + 2.30, 0.36, 76, velocity - 24, -0.55)
        add(events, "bass", beat + 2.72, 0.82, GAOLER_MOTIF[-1] - 12, velocity - 10, 0.08)
    elif variant == "E_FRACTURED":
        add_phrase(events, "strings", beat, GAOLER_MOTIF[:3], 0.36, 0.31, velocity, -0.28)
        add_phrase(events, "brass", beat + 1.48, GAOLER_MOTIF[3:], 0.42, 0.35, velocity + 2, 0.26)
    elif variant == "F_CHROMATIC_INVERSION":
        # D-Eb-F-E-Bb: a local inversion, not a replacement identity.
        add_phrase(events, "strings", beat, [50, 51, 53, 52, 46], 0.42, 0.36, velocity - 2, -0.24)
        add_phrase(events, "brass", beat + 0.22, [50, 49, 46], 0.68, 0.54, velocity - 10, 0.26)


def add_soul_theme(
    events: list[ScoreEvent], beat: float, variation: str = "FULL",
    velocity: int = 48, track: str = "strings", transpose: int = 0,
) -> None:
    notes = SOUL_PRISON_THEME
    spacing = 0.46
    duration = 0.40
    if variation == "SIGH":
        notes = [65, 64, 63, 62, 61, 62, 57]
        spacing = 0.43
    elif variation == "INVERTED_MEMORY":
        notes = [62, 63, 65, 67, 68, 67, 65]
        spacing = 0.40
    elif variation == "FRAGMENT_FRONT":
        notes = SOUL_PRISON_THEME[:4]
        spacing = 0.50
    elif variation == "FRAGMENT_SIGH":
        notes = SOUL_PRISON_THEME[3:]
        spacing = 0.48
    add_phrase(events, track, beat, notes, spacing, duration, velocity, 0.20, transpose)


def add_undertow(
    events: list[ScoreEvent], beat: float, velocity: int = 46,
    track: str = "strings", transpose: int = -12, reversed_flow: bool = False,
) -> None:
    notes = list(reversed(UNDERTOW_MOTIF)) if reversed_flow else UNDERTOW_MOTIF
    add_phrase(events, track, beat, notes, 0.54, 0.46, velocity, -0.18, transpose)


def add(
    events: list[ScoreEvent], track: str, beat: float, duration: float,
    note: int, velocity: int, pan: float,
) -> None:
    events.append(ScoreEvent(track, beat, duration, note, velocity, pan))


def p1_section(bar: int) -> str:
    if bar < 3:
        return "INTRO"
    if bar < 13:
        return "A_THE_WARDEN"
    if bar < 21:
        return "B_THE_PRISONERS"
    if bar < 29:
        return "C_THE_FLOOD"
    if bar < 37:
        return "D_THE_CHAINS"
    if bar < 44:
        return "E_THE_EMPTY_CELL"
    if bar < 54:
        return "A_PRIME_GAOLER_RETURNS"
    return "LOOP_RETURN"


def build_phase_one() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    harmony_by_section = {
        "INTRO": [(38, [50, 53, 57]), (39, [51, 55, 58])],
        "A_THE_WARDEN": [(38, [50, 53, 57]), (36, [48, 51, 55]), (34, [46, 50, 53]), (33, [45, 48, 52])],
        "B_THE_PRISONERS": [(34, [46, 50, 53]), (31, [43, 46, 50]), (39, [51, 55, 58]), (38, [50, 53, 57])],
        "C_THE_FLOOD": [(38, [50, 53, 57]), (32, [44, 48, 51]), (36, [48, 51, 55]), (39, [51, 55, 58])],
        "D_THE_CHAINS": [(38, [50, 53, 57]), (39, [51, 55, 58]), (32, [44, 48, 51]), (33, [45, 48, 52])],
        "E_THE_EMPTY_CELL": [(38, [50, 53, 57]), (35, [47, 50, 53]), (39, [51, 55, 58])],
        "A_PRIME_GAOLER_RETURNS": [(38, [50, 53, 57]), (36, [48, 51, 55]), (34, [46, 50, 53]), (39, [51, 55, 58]), (33, [45, 48, 52])],
        "LOOP_RETURN": [(39, [51, 55, 58]), (38, [50, 53, 57]), (33, [45, 48, 52])],
    }
    for bar in range(P1_BARS):
        beat = float(bar * BEATS_PER_BAR)
        section = p1_section(bar)
        starts = {"INTRO": 0, "A_THE_WARDEN": 3, "B_THE_PRISONERS": 13, "C_THE_FLOOD": 21,
                  "D_THE_CHAINS": 29, "E_THE_EMPTY_CELL": 37, "A_PRIME_GAOLER_RETURNS": 44,
                  "LOOP_RETURN": 54}
        section_bar = bar - starts[section]
        progression = harmony_by_section[section]
        root, chord = progression[(section_bar // 2) % len(progression)]
        foundation_velocity = 44 if section == "INTRO" else 60
        if section in ("C_THE_FLOOD", "A_PRIME_GAOLER_RETURNS"):
            foundation_velocity += 6
        if section == "E_THE_EMPTY_CELL":
            foundation_velocity -= 18

        # Four low-bed shapes prevent the same ostinato from surviving more
        # than two bars. Empty Cell deliberately breathes over two bars.
        foundation_variant = (section_bar // 2 + len(section)) % 4
        if section == "E_THE_EMPTY_CELL":
            if section_bar % 2 == 0:
                add(events, "bass", beat, 7.45, root - 12, foundation_velocity + 5, -0.08)
                add(events, "brass", beat + 0.10, 7.20, root, foundation_velocity - 9, 0.08)
        elif foundation_variant == 0:
            add(events, "bass", beat, 3.68, root - 12, foundation_velocity + 7, -0.08)
            add(events, "brass", beat, 3.58, root, foundation_velocity, 0.05)
        elif foundation_variant == 1:
            add(events, "bass", beat, 1.55, root - 12, foundation_velocity + 8, -0.12)
            add(events, "bass", beat + 2.0, 1.48, root - 5, foundation_velocity, 0.10)
            add(events, "brass", beat + 0.10, 3.38, chord[0], foundation_velocity - 7, 0.08)
        elif foundation_variant == 2:
            for pulse, offset in enumerate((0.0, 1.5, 3.0)):
                add(events, "bass", beat + offset, 0.74, root - 12 + (7 if pulse == 2 else 0), foundation_velocity + 2, -0.16 + pulse * 0.16)
            add(events, "brass", beat + 0.18, 3.25, root, foundation_velocity - 5, 0.06)
        else:
            add(events, "bass", beat + 0.5, 2.72, root - 12, foundation_velocity + 4, -0.06)
            add(events, "brass", beat + 1.0, 2.45, chord[-1] - 12, foundation_velocity - 8, 0.12)
        for voice, note in enumerate(chord[:2]):
            add(events, "strings", beat + 0.05 * voice, 3.42, note - 12, foundation_velocity - 12, -0.32 + voice * 0.64)

        rhythm_variant = (section_bar + len(section)) % 4
        if section != "E_THE_EMPTY_CELL":
            if rhythm_variant == 0:
                add(events, "timpani", beat, 0.80, 31, 69 if section != "INTRO" else 43, -0.10)
                add(events, "chain", beat + 1.0, 0.34, 72, 38, 0.58)
            elif rhythm_variant == 1:
                add(events, "timpani", beat + 0.5, 0.70, 33, 62, -0.12)
                add(events, "chain", beat + 2.5, 0.42, 76, 44, -0.62)
            elif rhythm_variant == 2:
                add(events, "timpani", beat, 0.72, 31, 58, 0.0)
                add(events, "timpani", beat + 2.5, 0.46, 36, 45, 0.12)
            else:
                add(events, "soul", beat, 3.50, root + 12, 31, 0.18)
                add(events, "chain", beat + 3.0, 0.30, 74, 34, -0.42)
        elif section_bar in (1, 5):
            add(events, "chain", beat + 2.75, 0.48, 69, 28, 0.52)
            add(events, "glass", beat + 1.5, 1.20, 62 if section_bar == 1 else 63, 27, -0.26)

        # Submerged ambience is sectional and low-passed, leaving the combat
        # SFX presence band clear.
        if bar % 2 == 0:
            water_velocity = 30 if section in ("INTRO", "E_THE_EMPTY_CELL", "LOOP_RETURN") else 38
            if section == "C_THE_FLOOD":
                water_velocity = 53
            add(events, "water", beat, 7.72, 35 if bar % 4 else 31, water_velocity, -0.42)
            add(events, "pad", beat + 0.12, 7.48, chord[-1] + 12, 25 + water_velocity // 5, 0.42)

        # Three themes now own different regions instead of forcing the Gaoler
        # sentence into every twenty seconds.
        if section == "INTRO":
            if section_bar == 1:
                add_soul_theme(events, beat + 0.5, "FRAGMENT_FRONT", 31, "strings", -12)
            elif section_bar == 2:
                add_phrase(events, "brass", beat + 0.5, GAOLER_MOTIF[:2], 0.88, 0.72, 46, -0.12)
        elif section == "A_THE_WARDEN":
            if section_bar == 0:
                add_gaoler_theme(events, beat, "A_LOW_BRASS", 75)
            elif section_bar == 4:
                add_gaoler_theme(events, beat, "B_CELLO", 69)
            elif section_bar == 8:
                add_gaoler_theme(events, beat, "C_SOUL_MIRROR", 68)
                add_phrase(events, "brass", beat + 0.20, GAOLER_MOTIF[:3], 0.72, 0.60, 58, -0.25)
        elif section == "B_THE_PRISONERS":
            if section_bar in (0, 4):
                add_soul_theme(events, beat, "FULL" if section_bar == 0 else "SIGH", 51, "strings", -12)
                add_phrase(events, "brass", beat + 0.20, GAOLER_MOTIF[:2], 0.92, 0.72, 44, -0.34)
            elif section_bar in (2, 6):
                add_soul_theme(events, beat + 0.30, "FRAGMENT_SIGH", 38, "choir", 0)
        elif section == "C_THE_FLOOD":
            if section_bar in (0, 4):
                add_undertow(events, beat, 52 if section_bar == 0 else 47, "strings", -12, section_bar == 4)
            elif section_bar in (2, 6):
                add_undertow(events, beat + 0.5, 40, "bass", -24, False)
        elif section == "D_THE_CHAINS":
            if section_bar in (0, 4):
                add_gaoler_theme(events, beat, "D_ANTIPHONAL_FRAGMENTS", 70)
            elif section_bar in (2, 6):
                add_soul_theme(events, beat, "FRAGMENT_SIGH", 43, "strings", -12)
                add_phrase(events, "brass", beat + 2.20, GAOLER_MOTIF[-2:], 0.52, 0.48, 58, -0.22)
            if section_bar in (1, 3, 5, 7):
                add(events, "gate", beat + 2.0, 1.10, 34 + (section_bar % 3), 39, -0.42 + section_bar * 0.10)
        elif section == "E_THE_EMPTY_CELL":
            if section_bar == 1:
                add_soul_theme(events, beat + 0.30, "FULL", 49, "strings", -12)
                add_soul_theme(events, beat + 0.62, "SIGH", 29, "glass", 0)
            elif section_bar == 5:
                add_soul_theme(events, beat + 0.55, "FRAGMENT_SIGH", 34, "choir", 0)
        elif section == "A_PRIME_GAOLER_RETURNS":
            if section_bar == 0:
                add_gaoler_theme(events, beat, "A_LOW_BRASS", 80)
            elif section_bar == 3:
                add_gaoler_theme(events, beat, "B_CELLO", 73)
            elif section_bar == 6:
                add_gaoler_theme(events, beat, "A_LOW_BRASS", 77)
                add_soul_theme(events, beat + 0.25, "INVERTED_MEMORY", 39, "strings", -12)
            elif section_bar == 9:
                add_gaoler_theme(events, beat, "C_SOUL_MIRROR", 71)
                add_soul_theme(events, beat + 0.38, "FRAGMENT_SIGH", 37, "choir", 0)
            if section_bar in (0, 5, 8):
                add(events, "gate", beat, 1.28, 34, 48, 0.0)
        elif section == "LOOP_RETURN":
            if section_bar == 0:
                add_gaoler_theme(events, beat, "D_ANTIPHONAL_FRAGMENTS", 59)
            elif section_bar == 3:
                add_undertow(events, beat + 0.5, 35, "strings", -12)

    return events


def p2_section(bar: int) -> str:
    if bar < 12:
        return "A2_BROKEN_GAOLER"
    if bar < 22:
        return "B2_SOUL_CAGE_RUPTURE"
    if bar < 32:
        return "C2_UNDERTOW"
    if bar < 40:
        return "D2_NO_PRISON_HOLDS"
    if bar < 50:
        return "E2_CHAINS_AGAINST_SOULS"
    if bar < 64:
        return "FINAL_LOCK"
    return "LOOP_RETURN"


def build_phase_two() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    harmony_by_section = {
        "A2_BROKEN_GAOLER": [(38, [50, 53, 57]), (37, [49, 52, 56]), (36, [48, 51, 55]), (34, [46, 50, 53])],
        "B2_SOUL_CAGE_RUPTURE": [(39, [51, 54, 58]), (38, [50, 53, 57]), (37, [49, 52, 56]), (32, [44, 48, 51])],
        "C2_UNDERTOW": [(38, [50, 53, 57]), (32, [44, 48, 51]), (35, [47, 50, 54]), (36, [48, 51, 55])],
        "D2_NO_PRISON_HOLDS": [(39, [51, 55, 58]), (33, [45, 48, 52]), (38, [50, 53, 57])],
        "E2_CHAINS_AGAINST_SOULS": [(34, [46, 50, 53]), (37, [49, 52, 56]), (39, [51, 54, 58]), (38, [50, 53, 57])],
        "FINAL_LOCK": [(38, [50, 53, 57]), (32, [44, 48, 51]), (39, [51, 54, 58]), (33, [45, 48, 52]), (34, [46, 50, 53])],
        "LOOP_RETURN": [(39, [51, 55, 58]), (36, [48, 51, 55]), (38, [50, 53, 57])],
    }
    starts = {"A2_BROKEN_GAOLER": 0, "B2_SOUL_CAGE_RUPTURE": 12, "C2_UNDERTOW": 22,
              "D2_NO_PRISON_HOLDS": 32, "E2_CHAINS_AGAINST_SOULS": 40,
              "FINAL_LOCK": 50, "LOOP_RETURN": 64}
    for bar in range(P2_BARS):
        beat = float(bar * BEATS_PER_BAR)
        section = p2_section(bar)
        section_bar = bar - starts[section]
        progression = harmony_by_section[section]
        root, chord = progression[(section_bar // 2 + section_bar // 5) % len(progression)]
        intensity = 0 if section == "D2_NO_PRISON_HOLDS" else 2 if section == "FINAL_LOCK" else 1

        # Four pressure beds rotate every two bars; Phase 2 stays heavy without
        # fixing every bar to the same two-pulse bass ostinato.
        foundation_variant = (section_bar // 2 + len(section)) % 4
        if foundation_variant == 0:
            add(events, "bass", beat, 1.68, root - 12, 67 + intensity * 4, -0.08)
            add(events, "bass", beat + 2.0, 1.44, root - 5, 56 + intensity * 4, 0.08)
            add(events, "brass", beat, 1.76, root, 57 + intensity * 6, -0.12)
        elif foundation_variant == 1:
            for pulse, offset in enumerate((0.0, 1.25, 2.75)):
                add(events, "bass", beat + offset, 0.72, root - 12 + (7 if pulse == 2 else 0), 58 + intensity * 5, -0.14 + pulse * 0.14)
            add(events, "brass", beat + 0.35, 2.92, chord[0], 53 + intensity * 5, 0.14)
        elif foundation_variant == 2:
            add(events, "bass", beat + 0.5, 2.85, root - 12, 64 + intensity * 4, -0.06)
            add(events, "brass", beat + 1.0, 2.30, chord[-1] - 12, 50 + intensity * 6, 0.16)
        else:
            add(events, "bass", beat, 0.82, root - 12, 66 + intensity * 4, -0.12)
            add(events, "bass", beat + 1.75, 0.72, root - 11, 52 + intensity * 4, 0.0)
            add(events, "bass", beat + 3.0, 0.64, root - 5, 58 + intensity * 4, 0.12)
            add(events, "brass", beat + 0.12, 3.28, root, 50 + intensity * 6, 0.08)
        for voice, note in enumerate(chord[:2]):
            string_offset = 0.0 if foundation_variant in (0, 3) else 0.5
            add(events, "strings", beat + string_offset + voice * 0.08, 1.54, note - 12, 54 + intensity * 6, -0.36 + voice * 0.72)
            if foundation_variant in (0, 1):
                add(events, "strings", beat + 2.15 + voice * 0.06, 1.30, note - 12 + (1 if section == "B2_SOUL_CAGE_RUPTURE" else 0), 49 + intensity * 6, 0.36 - voice * 0.72)

        rhythm_variant = (section_bar + section_bar // 3 + len(section)) % 4
        if section != "D2_NO_PRISON_HOLDS":
            if rhythm_variant == 0:
                add(events, "timpani", beat, 0.66, 31, 74 + intensity * 5, -0.12)
                add(events, "chain", beat + 1.0, 0.31, 76, 48, 0.62)
                add(events, "timpani", beat + 2.0, 0.54, 35, 58, 0.10)
            elif rhythm_variant == 1:
                add(events, "timpani", beat + 0.5, 0.60, 33, 68 + intensity * 5, -0.12)
                add(events, "timpani", beat + 1.5, 0.48, 36, 50, 0.12)
                add(events, "chain", beat + 3.0, 0.30, 79, 54, -0.62)
            elif rhythm_variant == 2:
                add(events, "timpani", beat, 0.64, 31, 70 + intensity * 5, -0.12)
                add(events, "chain", beat + 0.5, 0.29, 74, 43, -0.58)
                add(events, "chain", beat + 2.5, 0.33, 81, 50, 0.58)
            else:
                add(events, "timpani", beat + 2.0, 0.62, 31, 62 + intensity * 4, 0.0)
        else:
            add(events, "soul", beat, 3.72, root + 12, 50, -0.18)
            if bar % 2 == 0:
                add(events, "chain", beat + 3.0, 0.44, 69, 34, 0.46)

        if bar % 2 == 0:
            add(events, "water", beat, 7.70, 31 if section == "C2_UNDERTOW" else 35, 48 if section == "C2_UNDERTOW" else 32, -0.46)
            add(events, "soul", beat + 0.10, 7.48, chord[1] + 12, 34 + intensity * 4, 0.42)

        # Phase 2 is a conflict: the Gaoler fractures while the Soul theme
        # grows from fragments into full statements and finally counterpoint.
        if section == "A2_BROKEN_GAOLER":
            if section_bar in (0, 4, 8):
                add_gaoler_theme(events, beat, "E_FRACTURED" if section_bar != 8 else "F_CHROMATIC_INVERSION", 76)
            elif section_bar in (2, 6, 10):
                add_soul_theme(events, beat + 0.35, "FRAGMENT_SIGH", 39, "strings", -12)
        elif section == "B2_SOUL_CAGE_RUPTURE":
            if section_bar in (0, 5):
                add_soul_theme(events, beat, "SIGH" if section_bar == 0 else "INVERTED_MEMORY", 57, "strings", -12)
                add_soul_theme(events, beat + 0.22, "FRAGMENT_SIGH", 35, "choir", 0)
            elif section_bar in (2, 7):
                add_gaoler_theme(events, beat, "F_CHROMATIC_INVERSION", 70)
        elif section == "C2_UNDERTOW":
            if section_bar in (0, 3, 6, 9):
                add_undertow(events, beat, 54 - (section_bar // 3) * 2, "strings", -12, section_bar in (3, 9))
                add_undertow(events, beat + 0.32, 38, "bass", -24, False)
            elif section_bar in (2, 7):
                add_soul_theme(events, beat + 0.40, "FRAGMENT_FRONT", 38, "soul", -12)
        elif section == "D2_NO_PRISON_HOLDS":
            if section_bar in (1, 5):
                add_gaoler_theme(events, beat, "F_CHROMATIC_INVERSION", 56)
            elif section_bar in (3, 7):
                add_soul_theme(events, beat + 0.35, "SIGH", 43, "glass", -12)
        elif section == "E2_CHAINS_AGAINST_SOULS":
            if section_bar in (0, 4, 8):
                add_gaoler_theme(events, beat, "D_ANTIPHONAL_FRAGMENTS", 75)
            elif section_bar in (2, 6):
                add_soul_theme(events, beat, "FULL" if section_bar == 2 else "SIGH", 58, "strings", -12)
                add_soul_theme(events, beat + 0.28, "FRAGMENT_SIGH", 38, "choir", 0)
        elif section == "FINAL_LOCK":
            if section_bar in (0, 7):
                add_gaoler_theme(events, beat, "A_LOW_BRASS" if section_bar == 0 else "E_FRACTURED", 84)
                add_soul_theme(events, beat + 0.18, "FULL" if section_bar == 0 else "SIGH", 62, "strings", -12)
                add_soul_theme(events, beat + 0.42, "FRAGMENT_SIGH", 42, "choir", 0)
                add_undertow(events, beat + 1.65, 42, "bass", -24)
            elif section_bar in (3, 10):
                add_soul_theme(events, beat, "INVERTED_MEMORY" if section_bar == 3 else "FULL", 60, "strings", -12)
                add_phrase(events, "brass", beat + 1.05, GAOLER_MOTIF[:3], 0.48, 0.40, 70, -0.28)
            elif section_bar == 12:
                add_gaoler_theme(events, beat, "F_CHROMATIC_INVERSION", 78)
            if section_bar in (0, 4, 7, 11):
                add(events, "gate", beat, 1.25, 31, 58, 0.0)
                add(events, "choir", beat + 0.12, 3.36, chord[-1] + 12, 45, 0.0)
        elif section == "LOOP_RETURN":
            if section_bar in (0, 4):
                add_gaoler_theme(events, beat, "D_ANTIPHONAL_FRAGMENTS", 61)
            elif section_bar in (2, 6):
                add_undertow(events, beat + 0.45, 37, "strings", -12)

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
                "soul_prison_theme": SOUL_PRISON_THEME,
                "undertow_motif": UNDERTOW_MOTIF,
                "gaoler_theme_variations": [
                    "A_LOW_BRASS", "B_CELLO", "C_SOUL_MIRROR",
                    "D_ANTIPHONAL_FRAGMENTS", "E_FRACTURED",
                    "F_CHROMATIC_INVERSION",
                ],
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
            "Intro_Submerged_Gate": [1, 3], "A_The_Warden": [4, 13],
            "B_The_Prisoners": [14, 21], "C_The_Flood": [22, 29],
            "D_The_Chains": [30, 37], "E_The_Empty_Cell": [38, 44],
            "A_prime_The_Gaoler_Returns": [45, 54], "Loop_Return": [55, 60],
        }, True,
    )
    render_score(
        build_phase_two(), P2_BPM, P2_BARS, P2_TITLE, P2_STEM, SEED + 1,
        {
            "A2_Broken_Gaoler": [1, 12], "B2_Soul_Cage_Rupture": [13, 22],
            "C2_Undertow_Hunt": [23, 32], "D2_No_Prison_Holds": [33, 40],
            "E2_Chains_Against_Souls": [41, 50], "Final_Lock": [51, 64],
            "Loop_Return": [65, 72],
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
