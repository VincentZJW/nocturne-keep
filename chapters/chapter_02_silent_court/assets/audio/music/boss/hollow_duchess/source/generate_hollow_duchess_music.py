#!/usr/bin/env python3
"""Render Seraphine's original two-phase waltz, stinger, MIDI and stems.

No samples, downloaded assets or external generation services are used. Every
voice is synthesized by the project-owned procedural music library.
"""

from __future__ import annotations

import json
import sys
from collections import defaultdict
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
MIDI_ROOT = OUTPUT_ROOT / "midi"
STEMS_ROOT = OUTPUT_ROOT / "stems"
P1_BPM = 96.0
P2_BPM = 120.0
BEATS_PER_BAR = 3
P1_BARS = 80
P2_BARS = 88
SEED = 22021913

MAIN_MOTIF = [74, 77, 76, 72, 75, 74]  # D-F-E-C-Eb-D, original courtly lament.
RESPONSE_MOTIF = [69, 72, 74, 73, 72, 69]  # A-C-D-C#-C-A, unanswered bow.


def add(
    events: list[ScoreEvent], track: str, beat: float, duration: float,
    note: int, velocity: int, pan: float,
) -> None:
    events.append(ScoreEvent(track, beat, duration, note, velocity, pan))


def p1_section(bar: int) -> str:
    if bar < 6:
        return "INTRO"
    if bar < 22:
        return "A_LAST_COURTESY"
    if bar < 38:
        return "B_EMPTY_PARTNER"
    if bar < 52:
        return "C_MIRROR_CRACKS"
    if bar < 68:
        return "A_PRIME_MASKED_RETURN"
    return "LOOP_RETURN"


def p1_motif(section: str, phrase: int) -> list[int]:
    variant = phrase % 4
    if section == "INTRO":
        return [74, 77, 76, 72, 69, 73]
    if section == "A_LAST_COURTESY":
        variants = [
            MAIN_MOTIF,
            [74, 77, 79, 76, 75, 72],
            [69, 72, 74, 77, 76, 74],
            [74, 76, 75, 72, 73, 69],
        ]
        return variants[variant]
    if section == "B_EMPTY_PARTNER":
        variants = [
            RESPONSE_MOTIF,
            [72, 74, 77, 76, 72, 69],
            [81, 79, 77, 76, 74, 72],
            [69, 73, 74, 72, 68, 69],
        ]
        return variants[variant]
    if section == "C_MIRROR_CRACKS":
        variants = [
            [74, 73, 77, 76, 72, 75],
            [77, 76, 72, 71, 75, 74],
            [62, 65, 64, 60, 63, 62],
            [74, 78, 77, 73, 72, 68],
        ]
        return variants[variant]
    if section == "A_PRIME_MASKED_RETURN":
        variants = [
            [86, 89, 88, 84, 87, 86],
            [74, 77, 79, 76, 75, 74],
            [81, 84, 86, 85, 84, 81],
            [74, 76, 75, 72, 69, 73],
        ]
        return variants[variant]
    return MAIN_MOTIF if variant < 2 else RESPONSE_MOTIF


def build_phase_1() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    progression = [
        (50, [50, 53, 57]),  # D minor
        (46, [46, 50, 53]),  # B-flat
        (43, [43, 46, 50]),  # G minor
        (45, [45, 49, 52]),  # A major shadow
        (48, [48, 51, 55]),  # C minor
        (51, [51, 55, 58]),  # E-flat
    ]
    for bar in range(P1_BARS):
        section = p1_section(bar)
        local_phrase = bar // 2
        beat = float(bar * BEATS_PER_BAR)
        shift = 1 if section == "B_EMPTY_PARTNER" else 2 if section == "C_MIRROR_CRACKS" else 0
        root, chord = progression[(bar // 2 + shift) % len(progression)]
        if bar >= 76:  # circle back to the opening D-minor/B-flat breath.
            root, chord = progression[(bar - 76) // 2]

        intro_or_return = section in ("INTRO", "LOOP_RETURN")
        pressure = section == "C_MIRROR_CRACKS"
        full = section in ("B_EMPTY_PARTNER", "A_PRIME_MASKED_RETURN")

        add(events, "bass", beat, 1.05, root - 12, 52 if intro_or_return else 68, -0.08)
        if not intro_or_return or bar % 2 == 0:
            add(events, "bass", beat + 1.95, 0.82, root - 5, 44 + int(full) * 8, 0.10)
        for voice, chord_note in enumerate(chord):
            pan = -0.38 + float(voice) * 0.38
            add(events, "strings", beat, 2.86, chord_note, 34 + int(full) * 8 + int(pressure) * 5, pan * 0.55)
            if not (section == "INTRO" and bar < 2):
                add(events, "harpsichord", beat + 1.0 + voice * 0.025, 0.62, chord_note + 12, 43 + int(full) * 8, pan)
                add(events, "harpsichord", beat + 2.0 + voice * 0.020, 0.58, chord_note + 12, 40 + int(pressure) * 7, -pan)

        motif = p1_motif(section, local_phrase)
        if bar % 2 == 0:
            for index, note in enumerate(motif):
                start = beat + float(index) * 0.5
                rhythm_offset = 0.16 if section == "C_MIRROR_CRACKS" and index in (2, 5) else 0.0
                add(events, "harpsichord", start + rhythm_offset, 0.42, note, 58 + (12 if index in (0, 3, 5) else 0), -0.24 if index % 2 == 0 else 0.24)
        elif section in ("B_EMPTY_PARTNER", "A_PRIME_MASKED_RETURN"):
            response = RESPONSE_MOTIF if local_phrase % 2 == 0 else list(reversed(RESPONSE_MOTIF))
            for index, note in enumerate(response[:3]):
                add(events, "strings", beat + float(index), 0.78, note + (12 if section.startswith("A_PRIME") else 0), 48 + index * 4, 0.30)

        if section == "C_MIRROR_CRACKS" and bar % 2 == 0:
            add(events, "glass", beat + 0.08, 2.2, 86 - (bar % 5), 54, 0.58)
            add(events, "glass", beat + 1.55, 1.1, 78 + (bar % 3), 42, -0.54)
        elif section == "A_PRIME_MASKED_RETURN" and bar % 4 == 0:
            add(events, "glass", beat, 2.4, 86, 46, 0.58)
        if section in ("INTRO", "LOOP_RETURN") and bar % 3 == 0:
            add(events, "pad", beat, 8.6, chord[0] + 12, 28, -0.25)
            add(events, "pad", beat + 0.08, 8.4, chord[-1] + 12, 25, 0.25)
        if full and bar % 4 == 2:
            add(events, "choir", beat, 5.6, chord[1] + 12, 27, -0.22)
            add(events, "choir", beat + 0.10, 5.4, chord[2] + 12, 25, 0.22)
        if pressure and bar % 4 == 0:
            add(events, "timpani", beat, 0.7, 38, 43, -0.08)
    return events


def p2_section(bar: int) -> str:
    if bar < 20:
        return "A2_UNMASKED"
    if bar < 40:
        return "B2_SHATTERED_ETIQUETTE"
    if bar < 60:
        return "PHANTOM_DANCE"
    if bar < 72:
        return "BROKEN_WALTZ"
    return "FINAL_REPRISE"


def p2_motif(section: str, phrase: int) -> list[int]:
    variants: dict[str, list[list[int]]] = {
        "A2_UNMASKED": [MAIN_MOTIF, [77, 76, 72, 75, 74, 70], [74, 77, 79, 76, 73, 74], [86, 84, 81, 79, 76, 74]],
        "B2_SHATTERED_ETIQUETTE": [[74, 73, 77, 76, 72, 71], [77, 76, 72, 75, 71, 74], [69, 72, 73, 77, 76, 70], [81, 79, 78, 74, 75, 72]],
        "PHANTOM_DANCE": [[74, 77, 72, 76, 73, 75], [77, 72, 76, 71, 75, 74], [62, 65, 60, 64, 61, 63], [86, 89, 84, 88, 85, 86]],
        "BROKEN_WALTZ": [[74, 77, 76, 72, 69, 73], RESPONSE_MOTIF, [81, 79, 77, 73, 72, 69], [74, 73, 69, 72, 68, 69]],
        "FINAL_REPRISE": [[86, 89, 88, 84, 87, 86], [74, 77, 79, 76, 75, 72], [81, 84, 83, 79, 82, 81], MAIN_MOTIF],
    }
    return variants[section][phrase % 4]


def build_phase_2() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    progression = [(50, [50, 53, 57]), (46, [46, 50, 53]), (43, [43, 46, 50]), (48, [48, 51, 55]), (45, [45, 48, 52]), (51, [51, 54, 58])]
    for bar in range(P2_BARS):
        section = p2_section(bar)
        beat = float(bar * BEATS_PER_BAR)
        phrase = bar // 2
        shift = 2 if section == "PHANTOM_DANCE" else 4 if section == "BROKEN_WALTZ" else 0
        root, chord = progression[(bar + shift) % len(progression)]
        sparse = section == "BROKEN_WALTZ"
        final = section == "FINAL_REPRISE"

        add(events, "bass", beat, 0.95, root - 12, 76 if not sparse else 53, -0.08)
        if not sparse or bar % 2 == 0:
            add(events, "bass", beat + 1.5, 0.45, root - 5, 58 + int(final) * 7, 0.08)
        add(events, "timpani", beat, 0.62, 36 if final else 38, 56 + int(final) * 12, -0.10)
        if section in ("B2_SHATTERED_ETIQUETTE", "PHANTOM_DANCE", "FINAL_REPRISE") and bar % 2 == 1:
            add(events, "timpani", beat + 2.0, 0.40, 43, 42, 0.12)
        for voice, chord_note in enumerate(chord):
            pan = -0.40 + float(voice) * 0.40
            add(events, "strings", beat, 2.84, chord_note, 46 + int(final) * 8 - int(sparse) * 9, pan * 0.48)
            if not sparse or voice != 1:
                add(events, "harpsichord", beat + 1.0 + voice * 0.02, 0.48, chord_note + 12, 56 + int(final) * 7, pan)
                add(events, "harpsichord", beat + 2.0 + voice * 0.02, 0.44, chord_note + 12, 53, -pan)

        motif = p2_motif(section, phrase)
        for index, note in enumerate(motif):
            start = beat + float(index) * 0.5
            if section == "PHANTOM_DANCE" and index in (1, 4):
                start += 0.18
            track = "strings" if sparse and index % 2 == 0 else "harpsichord"
            add(events, track, start, 0.40 if track == "harpsichord" else 0.72, note, 68 + (12 if index in (0, 3) else 0) + int(final) * 5, -0.28 if index % 2 == 0 else 0.28)
        if section == "PHANTOM_DANCE" and bar % 2 == 0:
            add(events, "glass", beat + 0.12, 1.8, 88 - bar % 4, 59, 0.62)
            add(events, "chain", beat + 1.68, 0.36, 78, 38, -0.55)
        elif section == "B2_SHATTERED_ETIQUETTE" and bar % 4 == 0:
            add(events, "glass", beat, 1.9, 85, 52, -0.58)
        if sparse and bar % 3 == 0:
            add(events, "pad", beat, 8.5, chord[0] + 12, 24, -0.30)
            add(events, "glass", beat + 2.15, 1.2, 81, 38, 0.48)
        if final and bar % 4 == 0:
            add(events, "choir", beat, 5.5, chord[1] + 12, 32, -0.24)
            add(events, "choir", beat + 0.1, 5.3, chord[2] + 12, 30, 0.24)
    return events


def build_stinger() -> list[ScoreEvent]:
    events: list[ScoreEvent] = []
    # Three 3/4 bars: the Phase-I bow is stretched, cracked, then lands on P2's D.
    for note, beat, duration, track, velocity, pan in [
        (74, 0.0, 1.35, "strings", 70, -0.28), (77, 0.0, 1.35, "strings", 58, 0.25),
        (73, 1.5, 1.20, "strings", 74, 0.22), (50, 0.0, 2.80, "bass", 78, -0.05),
        (88, 2.7, 1.25, "glass", 88, 0.52), (83, 3.0, 1.00, "glass", 70, -0.48),
        (48, 3.0, 2.75, "bass", 82, -0.04), (72, 3.0, 2.65, "choir", 42, 0.0),
        (79, 4.5, 0.55, "glass", 74, 0.55), (76, 5.1, 0.55, "glass", 70, -0.55),
        (38, 5.8, 0.90, "timpani", 86, -0.08), (50, 6.0, 2.75, "bass", 92, 0.0),
        (74, 6.0, 2.65, "strings", 84, -0.28), (77, 6.0, 2.65, "strings", 66, 0.28),
        (86, 6.0, 2.35, "glass", 62, 0.45),
    ]:
        add(events, track, beat, duration, note, velocity, pan)
    return events


def taper_loop(mix: np.ndarray) -> np.ndarray:
    edge = int(round(0.010 * SAMPLE_RATE))
    curve = np.sin(np.linspace(0.0, np.pi * 0.5, edge, dtype=np.float32)) ** 2
    mix[:edge] *= curve[:, None]
    mix[-edge:] *= curve[::-1, None]
    return mix


def write_product(
    basename: str, title: str, bpm: float, bars: int,
    events: list[ScoreEvent], seed: int, looped: bool,
) -> dict[str, object]:
    total_beats = float(bars * BEATS_PER_BAR)
    mix = render_events(events, bpm, total_beats, seed)
    if looped:
        mix = taper_loop(mix)
    else:
        fade = min(mix.shape[0], int(round(0.35 * SAMPLE_RATE)))
        mix[-fade:] *= np.linspace(1.0, 0.0, fade, dtype=np.float32)[:, None]
    ogg_path = OUTPUT_ROOT / f"{basename}.ogg"
    midi_path = MIDI_ROOT / f"{basename}.mid"
    analysis_path = OUTPUT_ROOT / f"{basename}.analysis.json"
    write_ogg(mix, ogg_path, title)
    write_standard_midi(events, midi_path, bpm, 3, 4, title)
    analysis = analyse_file_samples(mix, ogg_path)
    write_analysis(analysis, analysis_path)
    return {
        "title": title, "bpm": bpm, "time_signature": "3/4", "bars": bars,
        "duration_seconds": analysis.duration_seconds, "loop_begin_seconds": 0.0,
        "loop_end_seconds": analysis.duration_seconds if looped else 0.0,
        "sha256": analysis.sha256, "events": [event.__dict__ for event in events],
    }


def write_stems(prefix: str, title: str, bpm: float, bars: int, events: list[ScoreEvent], seed: int) -> None:
    groups = {
        "melody": {"harpsichord", "glass"},
        "orchestra": {"strings", "choir", "pad"},
        "pulse": {"bass", "timpani", "chain"},
    }
    for index, (group_name, track_names) in enumerate(groups.items()):
        selected = [event for event in events if event.track in track_names]
        if not selected:
            continue
        mix = taper_loop(render_events(selected, bpm, float(bars * BEATS_PER_BAR), seed + 1000 + index))
        write_ogg(mix, STEMS_ROOT / f"{prefix}_{group_name}.ogg", f"{title} [{group_name} stem]")


def main() -> None:
    MIDI_ROOT.mkdir(parents=True, exist_ok=True)
    STEMS_ROOT.mkdir(parents=True, exist_ok=True)
    p1_events = build_phase_1()
    p2_events = build_phase_2()
    stinger_events = build_stinger()
    p1 = write_product("hollow_duchess_phase_01_waltz", "The Last Courteous Waltz / 最后的礼仪华尔兹", P1_BPM, P1_BARS, p1_events, SEED, True)
    p2 = write_product("hollow_duchess_phase_02_unmasked_waltz", "The Final Waltz, Unmasked / 无面的最后华尔兹", P2_BPM, P2_BARS, p2_events, SEED + 1, True)
    stinger = write_product("hollow_duchess_transition_stinger", "The Mask Breaks / 面具碎裂", P2_BPM, 3, stinger_events, SEED + 2, False)
    write_stems("phase_01", p1["title"], P1_BPM, P1_BARS, p1_events, SEED)
    write_stems("phase_02", p2["title"], P2_BPM, P2_BARS, p2_events, SEED + 1)
    for name, product, sections in [
        ("hollow_duchess_phase_01_score.json", p1, {"intro": [1, 6], "A": [7, 22], "B": [23, 38], "C": [39, 52], "A_prime": [53, 68], "loop_return": [69, 80]}),
        ("hollow_duchess_phase_02_score.json", p2, {"A2": [1, 20], "B2": [21, 40], "phantom_dance": [41, 60], "broken_waltz": [61, 72], "final_reprise": [73, 88]}),
        ("hollow_duchess_transition_stinger_score.json", stinger, {"transformation_bridge": [1, 3]}),
    ]:
        product["sections"] = sections
        product["main_motif"] = MAIN_MOTIF
        product["response_motif"] = RESPONSE_MOTIF
        product["provenance"] = "fully synthesized; no samples, downloads, paid services or external generation"
        (OUTPUT_ROOT / "source" / name).write_text(json.dumps(product, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        "HOLLOW_DUCHESS_MUSIC_RENDER: PASS "
        f"p1={p1['duration_seconds']:.3f}s p2={p2['duration_seconds']:.3f}s "
        f"stinger={stinger['duration_seconds']:.3f}s events={len(p1_events)}/{len(p2_events)}/{len(stinger_events)}"
    )


if __name__ == "__main__":
    main()
