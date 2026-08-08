"""Deterministic, sample-free score rendering helpers for project-owned music."""

from __future__ import annotations

import hashlib
import json
import math
import struct
import subprocess
import tempfile
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Callable, Iterable

import numpy as np
from scipy import signal
from scipy.io import wavfile


SAMPLE_RATE = 48_000
TICKS_PER_QUARTER = 480


@dataclass(frozen=True)
class ScoreEvent:
    track: str
    start_beat: float
    duration_beats: float
    midi_note: int
    velocity: int
    pan: float


@dataclass(frozen=True)
class RenderAnalysis:
    sample_rate: int
    channels: int
    sample_count: int
    duration_seconds: float
    peak_dbfs: float
    rms_dbfs: float
    boundary_delta: float
    boundary_rms_20ms: float
    sha256: str


def midi_to_frequency(note: int) -> float:
    return 440.0 * (2.0 ** ((float(note) - 69.0) / 12.0))


def _envelope(
    length: int,
    attack_seconds: float,
    release_seconds: float,
    sample_rate: int = SAMPLE_RATE,
) -> np.ndarray:
    result = np.ones(length, dtype=np.float32)
    attack = min(length, max(1, int(round(attack_seconds * sample_rate))))
    release = min(length, max(1, int(round(release_seconds * sample_rate))))
    result[:attack] *= np.linspace(0.0, 1.0, attack, endpoint=False, dtype=np.float32)
    result[-release:] *= np.linspace(1.0, 0.0, release, endpoint=True, dtype=np.float32)
    return result


def synth_harpsichord(frequency: float, duration: float, seed: int) -> np.ndarray:
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    result = np.zeros(length, dtype=np.float32)
    rng = np.random.default_rng(seed)
    phases = rng.uniform(-math.pi, math.pi, 7)
    harmonics = ((1.0, 0.72), (2.0, 0.38), (3.0, 0.24), (4.0, 0.14),
                 (5.01, 0.10), (7.0, 0.06), (9.02, 0.035))
    for index, (ratio, gain) in enumerate(harmonics):
        decay = np.exp(-time * (3.0 + float(index) * 0.55)).astype(np.float32)
        result += np.sin(time * math.tau * frequency * ratio + phases[index]) * gain * decay
    pluck = rng.standard_normal(length).astype(np.float32)
    pluck *= np.exp(-time * 34.0).astype(np.float32) * 0.035
    result += pluck
    result *= _envelope(length, 0.003, min(0.075, duration * 0.22))
    return result * 0.38


def synth_bowed_string(frequency: float, duration: float, seed: int) -> np.ndarray:
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    vibrato_rate = rng.uniform(4.5, 5.4)
    vibrato_depth = rng.uniform(0.0018, 0.0034)
    phase = time * math.tau * frequency
    phase += np.sin(time * math.tau * vibrato_rate).astype(np.float32) * vibrato_depth * frequency
    result = np.zeros(length, dtype=np.float32)
    for harmonic, gain in ((1, 0.66), (2, 0.24), (3, 0.15), (4, 0.08), (5, 0.045)):
        result += np.sin(phase * float(harmonic) + harmonic * 0.17) * gain
    bow = rng.standard_normal(length).astype(np.float32) * 0.014
    result += signal.lfilter([0.08], [1.0, -0.92], bow).astype(np.float32)
    result *= _envelope(length, min(0.09, duration * 0.18), min(0.18, duration * 0.28))
    return result * 0.28


def synth_low_string(frequency: float, duration: float, seed: int) -> np.ndarray:
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    pitch = frequency * (1.0 + np.sin(time * math.tau * 4.2) * 0.0015)
    phase = np.cumsum(pitch, dtype=np.float64) * (math.tau / float(SAMPLE_RATE))
    result = (
        np.sin(phase) * 0.74
        + np.sin(phase * 2.0 + 0.15) * 0.23
        + np.sin(phase * 3.0 + 0.31) * 0.11
    ).astype(np.float32)
    result += rng.standard_normal(length).astype(np.float32) * 0.006
    result *= _envelope(length, 0.018, min(0.16, duration * 0.25))
    return result * 0.32


def synth_glass(frequency: float, duration: float, seed: int) -> np.ndarray:
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    result = np.zeros(length, dtype=np.float32)
    partials = ((1.0, 0.54, 3.2), (2.63, 0.28, 4.4), (4.17, 0.17, 5.8), (5.41, 0.09, 7.0))
    for ratio, gain, decay_rate in partials:
        phase = rng.uniform(-math.pi, math.pi)
        result += (
            np.sin(time * math.tau * frequency * ratio + phase)
            * gain
            * np.exp(-time * decay_rate)
        ).astype(np.float32)
    result *= _envelope(length, 0.0015, min(0.12, duration * 0.25))
    return result * 0.27


def synth_timpani(frequency: float, duration: float, seed: int) -> np.ndarray:
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    falling_frequency = frequency * (1.0 + 0.24 * np.exp(-time * 12.0))
    phase = np.cumsum(falling_frequency, dtype=np.float64) * (math.tau / float(SAMPLE_RATE))
    tone = np.sin(phase) * 0.82 + np.sin(phase * 1.48) * 0.19
    noise = rng.standard_normal(length).astype(np.float32)
    noise = signal.lfilter([0.12], [1.0, -0.82], noise).astype(np.float32)
    result = (tone.astype(np.float32) * 0.72 + noise * 0.07)
    result *= np.exp(-time * 3.3).astype(np.float32)
    result *= _envelope(length, 0.002, min(0.12, duration * 0.22))
    return result * 0.42


def synth_pipe_organ(frequency: float, duration: float, seed: int) -> np.ndarray:
    """Restrained additive chapel organ; no recorded pipe samples."""
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    result = np.zeros(length, dtype=np.float32)
    detune = rng.uniform(-0.0014, 0.0014)
    for ratio, gain in ((0.5, 0.16), (1.0, 0.58), (2.0, 0.24), (3.0, 0.11), (4.01, 0.06)):
        phase = rng.uniform(-math.pi, math.pi)
        result += np.sin(time * math.tau * frequency * ratio * (1.0 + detune) + phase) * gain
    breath = signal.lfilter(
        [0.025], [1.0, -0.985], rng.standard_normal(length).astype(np.float32)
    ).astype(np.float32)
    result += breath * 0.028
    result *= _envelope(length, min(0.12, duration * 0.18), min(0.20, duration * 0.24))
    return result * 0.25


def synth_formant_choir(frequency: float, duration: float, seed: int) -> np.ndarray:
    """Non-semantic vowel-like choir synthesized from oscillators and formants."""
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    vibrato = np.sin(time * math.tau * rng.uniform(4.0, 4.8)) * 0.0021
    phase = np.cumsum(frequency * (1.0 + vibrato), dtype=np.float64) * (math.tau / SAMPLE_RATE)
    source = (
        np.sin(phase) * 0.64
        + np.sin(phase * 2.0 + 0.2) * 0.21
        + np.sin(phase * 3.0 + 0.5) * 0.10
        + np.sin(phase * 4.0 + 0.7) * 0.05
    ).astype(np.float32)
    # Static vowel colouring.  The result evokes a distant choir without text or samples.
    low = signal.butter(2, 950.0, btype="lowpass", fs=SAMPLE_RATE, output="sos")
    high = signal.butter(2, 180.0, btype="highpass", fs=SAMPLE_RATE, output="sos")
    result = signal.sosfilt(high, signal.sosfilt(low, source)).astype(np.float32)
    result += rng.standard_normal(length).astype(np.float32) * 0.0025
    result *= _envelope(length, min(0.32, duration * 0.26), min(0.42, duration * 0.30))
    return result * 0.30


def synth_bronze_bell(frequency: float, duration: float, seed: int) -> np.ndarray:
    """Old, slightly inharmonic bronze bell synthesized additively."""
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    result = np.zeros(length, dtype=np.float32)
    partials = (
        (0.50, 0.22, 1.35), (1.00, 0.46, 1.65), (1.19, 0.26, 2.10),
        (1.51, 0.19, 2.55), (2.01, 0.13, 3.10), (2.74, 0.08, 4.20),
    )
    for ratio, gain, decay in partials:
        result += (
            np.sin(time * math.tau * frequency * ratio + rng.uniform(-math.pi, math.pi))
            * gain * np.exp(-time * decay)
        ).astype(np.float32)
    strike = rng.standard_normal(length).astype(np.float32) * np.exp(-time * 55.0).astype(np.float32)
    result += strike * 0.028
    result *= _envelope(length, 0.001, min(0.20, duration * 0.20))
    return result * 0.38


def synth_cold_pad(frequency: float, duration: float, seed: int) -> np.ndarray:
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    result = np.zeros(length, dtype=np.float32)
    for cents, gain in ((-8.0, 0.25), (0.0, 0.42), (7.0, 0.25), (12.0, 0.08)):
        ratio = 2.0 ** (cents / 1200.0)
        result += np.sin(time * math.tau * frequency * ratio + rng.uniform(-math.pi, math.pi)) * gain
    result *= _envelope(length, min(0.45, duration * 0.24), min(0.55, duration * 0.30))
    return result * 0.19


def synth_chain(frequency: float, duration: float, seed: int) -> np.ndarray:
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    noise = rng.standard_normal(length).astype(np.float32)
    metallic = np.zeros(length, dtype=np.float32)
    for ratio, gain in ((5.7, 0.22), (8.2, 0.17), (11.1, 0.10)):
        metallic += np.sin(time * math.tau * frequency * ratio + rng.uniform(-math.pi, math.pi)) * gain
    result = metallic + signal.lfilter([0.18, -0.18], [1.0, -0.72], noise).astype(np.float32) * 0.08
    result *= np.exp(-time * 8.2).astype(np.float32)
    result *= _envelope(length, 0.001, min(0.08, duration * 0.30))
    return result * 0.26


def synth_bass_brass(frequency: float, duration: float, seed: int) -> np.ndarray:
    """Dark bass-brass pressure without recorded orchestral samples."""
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    swell = np.minimum(1.0, time / max(0.025, min(0.18, duration * 0.22)))
    phase = time * math.tau * frequency
    result = (
        np.sin(phase) * 0.62
        + np.sin(phase * 2.0 + 0.13) * 0.27
        + np.sin(phase * 3.0 + 0.37) * 0.15
        + np.sin(phase * 4.0 + 0.51) * 0.07
    ).astype(np.float32)
    breath = signal.sosfilt(
        signal.butter(2, 720.0, btype="lowpass", fs=SAMPLE_RATE, output="sos"),
        rng.standard_normal(length).astype(np.float32),
    ).astype(np.float32)
    result = result * swell.astype(np.float32) + breath * 0.012
    result *= _envelope(length, 0.025, min(0.24, duration * 0.28))
    return result * 0.34


def synth_water_pressure(frequency: float, duration: float, seed: int) -> np.ndarray:
    """Submerged, slowly modulated water-pressure texture."""
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    noise = rng.standard_normal(length).astype(np.float32)
    low = signal.sosfilt(
        signal.butter(3, 310.0, btype="lowpass", fs=SAMPLE_RATE, output="sos"), noise
    ).astype(np.float32)
    pulse = (0.68 + np.sin(time * math.tau * 0.19 + rng.uniform(-math.pi, math.pi)) * 0.24).astype(np.float32)
    tone = np.sin(time * math.tau * max(24.0, frequency * 0.5)).astype(np.float32) * 0.18
    result = low * pulse * 0.22 + tone
    result *= _envelope(length, min(0.55, duration * 0.24), min(0.70, duration * 0.30))
    return result * 0.20


def synth_soul_drone(frequency: float, duration: float, seed: int) -> np.ndarray:
    """Wordless trapped-soul drone, kept below the attack-telegraph band."""
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    wobble = np.sin(time * math.tau * rng.uniform(0.13, 0.22)) * 0.008
    phase = np.cumsum(frequency * (1.0 + wobble), dtype=np.float64) * (math.tau / SAMPLE_RATE)
    result = (
        np.sin(phase) * 0.54
        + np.sin(phase * 1.5 + 0.4) * 0.20
        + np.sin(phase * 2.01 + 0.7) * 0.12
    ).astype(np.float32)
    result *= _envelope(length, min(0.48, duration * 0.28), min(0.62, duration * 0.32))
    return result * 0.23


def synth_gate_impact(frequency: float, duration: float, seed: int) -> np.ndarray:
    """Short, broad iron-gate impact for score punctuation and transitions."""
    length = max(2, int(round(duration * SAMPLE_RATE)))
    time = np.arange(length, dtype=np.float32) / float(SAMPLE_RATE)
    rng = np.random.default_rng(seed)
    noise = rng.standard_normal(length).astype(np.float32)
    noise = signal.sosfilt(
        signal.butter(2, [95.0, 2400.0], btype="bandpass", fs=SAMPLE_RATE, output="sos"), noise
    ).astype(np.float32)
    metal = np.zeros(length, dtype=np.float32)
    for ratio, gain in ((1.0, 0.58), (2.37, 0.31), (4.73, 0.16), (7.11, 0.08)):
        metal += np.sin(time * math.tau * frequency * ratio + rng.uniform(-math.pi, math.pi)) * gain
    result = metal * np.exp(-time * 3.1).astype(np.float32) + noise * np.exp(-time * 7.5).astype(np.float32) * 0.22
    result *= _envelope(length, 0.001, min(0.16, duration * 0.18))
    return result * 0.36


SYNTHS: dict[str, Callable[[float, float, int], np.ndarray]] = {
    "harpsichord": synth_harpsichord,
    "strings": synth_bowed_string,
    "bass": synth_low_string,
    "glass": synth_glass,
    "timpani": synth_timpani,
    "organ": synth_pipe_organ,
    "choir": synth_formant_choir,
    "bell": synth_bronze_bell,
    "pad": synth_cold_pad,
    "chain": synth_chain,
    "brass": synth_bass_brass,
    "water": synth_water_pressure,
    "soul": synth_soul_drone,
    "gate": synth_gate_impact,
}


TRACK_GAIN: dict[str, float] = {
    "harpsichord": 0.66,
    "strings": 0.62,
    "bass": 0.78,
    "glass": 0.55,
    "timpani": 0.70,
    "organ": 0.67,
    "choir": 0.53,
    "bell": 0.56,
    "pad": 0.48,
    "chain": 0.44,
    "brass": 0.68,
    "water": 0.42,
    "soul": 0.46,
    "gate": 0.62,
}


def add_circular_mono(
    mix: np.ndarray,
    source: np.ndarray,
    start_sample: int,
    pan: float,
    gain: float,
) -> None:
    total = mix.shape[0]
    if total <= 0 or source.size == 0:
        return
    position = start_sample % total
    left_gain = math.cos((max(-1.0, min(1.0, pan)) + 1.0) * math.pi * 0.25)
    right_gain = math.sin((max(-1.0, min(1.0, pan)) + 1.0) * math.pi * 0.25)
    offset = 0
    while offset < source.size:
        count = min(source.size - offset, total - position)
        section = source[offset:offset + count] * gain
        mix[position:position + count, 0] += section * left_gain
        mix[position:position + count, 1] += section * right_gain
        offset += count
        position = 0


def render_events(
    events: Iterable[ScoreEvent],
    bpm: float,
    total_beats: float,
    seed: int,
) -> np.ndarray:
    seconds_per_beat = 60.0 / bpm
    sample_count = int(round(total_beats * seconds_per_beat * SAMPLE_RATE))
    mix = np.zeros((sample_count, 2), dtype=np.float32)
    for index, event in enumerate(events):
        synth = SYNTHS[event.track]
        duration = max(0.035, event.duration_beats * seconds_per_beat)
        voice = synth(midi_to_frequency(event.midi_note), duration, seed + index * 7919)
        gain = TRACK_GAIN[event.track] * (float(event.velocity) / 127.0)
        add_circular_mono(
            mix,
            voice,
            int(round(event.start_beat * seconds_per_beat * SAMPLE_RATE)),
            event.pan,
            gain,
        )
    return finalize_circular_mix(mix)


def finalize_circular_mix(mix: np.ndarray) -> np.ndarray:
    # Circular early reflections keep the rendered loop periodic instead of adding a cut reverb tail.
    wet = mix.copy()
    for delay_seconds, gain, crossfeed in ((0.071, 0.13, 0.22), (0.113, 0.095, 0.36), (0.181, 0.06, 0.48)):
        rolled = np.roll(mix, int(round(delay_seconds * SAMPLE_RATE)), axis=0)
        wet[:, 0] += rolled[:, 0] * gain + rolled[:, 1] * gain * crossfeed
        wet[:, 1] += rolled[:, 1] * gain + rolled[:, 0] * gain * crossfeed
    high_pass = signal.butter(2, 28.0, btype="highpass", fs=SAMPLE_RATE, output="sos")
    low_pass = signal.butter(2, 15_500.0, btype="lowpass", fs=SAMPLE_RATE, output="sos")
    # Filter two consecutive copies and retain the second.  This lets the IIR
    # state settle into the score's own periodic cycle, rather than injecting a
    # zero-state transient at sample zero or repairing the tail with a crossfade.
    periodic_filter = np.vstack((high_pass, low_pass))
    sample_count = wet.shape[0]
    for channel in range(2):
        doubled = np.concatenate((wet[:, channel], wet[:, channel]))
        filtered = signal.sosfilt(periodic_filter, doubled)
        wet[:, channel] = filtered[sample_count:].astype(np.float32)
    wet -= np.mean(wet, axis=0, dtype=np.float64).astype(np.float32)
    wet = np.tanh(wet * 1.06).astype(np.float32)
    peak = float(np.max(np.abs(wet)))
    if peak > 0.0:
        wet *= np.float32(0.70 / peak)
    return wet


def write_ogg(mix: np.ndarray, output_path: Path, title: str) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    pcm = np.clip(mix * 32767.0, -32768.0, 32767.0).astype(np.int16)
    with tempfile.TemporaryDirectory(prefix="ravenmourn_music_") as directory:
        wav_path = Path(directory) / "master.wav"
        wavfile.write(wav_path, SAMPLE_RATE, pcm)
        command = [
            "/opt/homebrew/bin/ffmpeg",
            "-hide_banner", "-loglevel", "error", "-y",
            "-i", str(wav_path),
            "-c:a", "vorbis", "-strict", "experimental", "-q:a", "6",
            "-ar", str(SAMPLE_RATE), "-ac", "2",
            "-metadata", f"title={title}",
            "-metadata", "artist=Veil of Ravenmourn Original Score",
            str(output_path),
        ]
        subprocess.run(command, check=True)


def analyse_file_samples(mix: np.ndarray, output_path: Path) -> RenderAnalysis:
    peak = max(float(np.max(np.abs(mix))), 1.0e-12)
    rms = max(float(np.sqrt(np.mean(np.square(mix), dtype=np.float64))), 1.0e-12)
    edge = min(mix.shape[0] // 2, int(round(0.020 * SAMPLE_RATE)))
    boundary_delta = float(np.max(np.abs(mix[0] - mix[-1])))
    boundary_rms = float(np.sqrt(np.mean(np.square(mix[:edge] - mix[-edge:]), dtype=np.float64)))
    return RenderAnalysis(
        sample_rate=SAMPLE_RATE,
        channels=2,
        sample_count=mix.shape[0],
        duration_seconds=float(mix.shape[0]) / float(SAMPLE_RATE),
        peak_dbfs=20.0 * math.log10(peak),
        rms_dbfs=20.0 * math.log10(rms),
        boundary_delta=boundary_delta,
        boundary_rms_20ms=boundary_rms,
        sha256=hashlib.sha256(output_path.read_bytes()).hexdigest(),
    )


def write_analysis(analysis: RenderAnalysis, output_path: Path) -> None:
    output_path.write_text(json.dumps(asdict(analysis), indent=2) + "\n", encoding="utf-8")


def _variable_length(value: int) -> bytes:
    buffer = value & 0x7F
    result = bytearray([buffer])
    while value > 0x7F:
        value >>= 7
        buffer = (value & 0x7F) | 0x80
        result.insert(0, buffer)
    return bytes(result)


def _midi_track(events: list[tuple[int, int, bytes]]) -> bytes:
    events.sort(key=lambda item: (item[0], item[1]))
    body = bytearray()
    previous_tick = 0
    for tick, _order, payload in events:
        body.extend(_variable_length(max(0, tick - previous_tick)))
        body.extend(payload)
        previous_tick = tick
    body.extend(b"\x00\xFF\x2F\x00")
    return b"MTrk" + struct.pack(">I", len(body)) + bytes(body)


def write_standard_midi(
    score_events: Iterable[ScoreEvent],
    output_path: Path,
    bpm: float,
    numerator: int,
    denominator: int,
    title: str,
) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    tempo = int(round(60_000_000.0 / bpm))
    denominator_power = int(round(math.log2(float(denominator))))
    title_bytes = title.encode("utf-8")
    conductor = [
        (0, 0, b"\xFF\x03" + _variable_length(len(title_bytes)) + title_bytes),
        (0, 1, b"\xFF\x51\x03" + tempo.to_bytes(3, "big")),
        (0, 2, bytes([0xFF, 0x58, 0x04, numerator, denominator_power, 24, 8])),
    ]
    channel_map = {
        "harpsichord": 0, "strings": 1, "bass": 2, "glass": 3, "timpani": 9,
        "organ": 4, "choir": 5, "bell": 6, "pad": 7, "chain": 8,
        "brass": 10, "water": 11, "soul": 12, "gate": 13,
    }
    program_map = {
        "harpsichord": 6, "strings": 48, "bass": 43, "glass": 14, "timpani": 47,
        "organ": 19, "choir": 52, "bell": 14, "pad": 89, "chain": 115,
        "brass": 58, "water": 97, "soul": 91, "gate": 116,
    }
    grouped: dict[str, list[ScoreEvent]] = {name: [] for name in channel_map}
    for event in score_events:
        grouped[event.track].append(event)
    tracks = [_midi_track(conductor)]
    for name, items in grouped.items():
        channel = channel_map[name]
        track_name = name.encode("ascii")
        midi_events: list[tuple[int, int, bytes]] = [
            (0, 0, b"\xFF\x03" + _variable_length(len(track_name)) + track_name),
            (0, 1, bytes([0xC0 | channel, program_map[name]])),
        ]
        for event in items:
            start = int(round(event.start_beat * TICKS_PER_QUARTER))
            end = int(round((event.start_beat + event.duration_beats) * TICKS_PER_QUARTER))
            note = max(0, min(127, event.midi_note))
            velocity = max(1, min(127, event.velocity))
            midi_events.append((start, 3, bytes([0x90 | channel, note, velocity])))
            midi_events.append((end, 2, bytes([0x80 | channel, note, 0])))
        tracks.append(_midi_track(midi_events))
    header = b"MThd" + struct.pack(">IHHH", 6, 1, len(tracks), TICKS_PER_QUARTER)
    output_path.write_bytes(header + b"".join(tracks))
