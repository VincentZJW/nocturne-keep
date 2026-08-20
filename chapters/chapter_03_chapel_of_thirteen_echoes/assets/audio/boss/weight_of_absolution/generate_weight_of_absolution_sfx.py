#!/usr/bin/env python3
"""Deterministic original SFX for Edran's Weight of Absolution rite."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44_100
ROOT = Path(__file__).resolve().parent
RNG = random.Random(13_031_314)


def _soft_clip(value: float) -> float:
    return math.tanh(value * 1.15) * 0.82


def _write(name: str, samples: list[float]) -> None:
    peak = max(max(abs(value) for value in samples), 0.001)
    gain = min(0.92 / peak, 1.0)
    payload = b"".join(
        struct.pack("<h", int(max(-1.0, min(1.0, value * gain)) * 32767.0))
        for value in samples
    )
    with wave.open(str(ROOT / name), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(payload)


def _reverb(source: list[float], taps: tuple[tuple[float, float], ...]) -> list[float]:
    result = source[:]
    for delay_seconds, gain in taps:
        delay = int(delay_seconds * SAMPLE_RATE)
        for index in range(delay, len(result)):
            result[index] += source[index - delay] * gain
    return [_soft_clip(value) for value in result]


def _bell_invocation() -> list[float]:
    duration = 2.35
    samples: list[float] = []
    partials = ((55.0, 0.55), (82.5, 0.72), (123.7, 0.42), (171.6, 0.24), (247.4, 0.13))
    for index in range(int(duration * SAMPLE_RATE)):
        time = index / SAMPLE_RATE
        attack = min(1.0, time / 0.018)
        envelope = attack * math.exp(-time * 1.55)
        value = 0.0
        for partial_index, (frequency, amplitude) in enumerate(partials):
            drift = 1.0 + math.sin(time * 0.31 + partial_index) * 0.0018
            value += math.sin(math.tau * frequency * drift * time) * amplitude
        # Felt-covered clapper: short, deep, non-explosive.
        value += math.sin(math.tau * 38.0 * time) * math.exp(-time * 13.0) * 0.50
        samples.append(value * envelope * 0.50)
    return _reverb(samples, ((0.17, 0.22), (0.31, 0.15), (0.53, 0.09), (0.79, 0.05)))


def _seal_lock() -> list[float]:
    duration = 1.55
    samples: list[float] = []
    smooth_noise = 0.0
    for index in range(int(duration * SAMPLE_RATE)):
        time = index / SAMPLE_RATE
        progress = time / duration
        smooth_noise = smooth_noise * 0.965 + RNG.uniform(-1.0, 1.0) * 0.035
        rise = min(1.0, time / 0.16)
        fall = min(1.0, (duration - time) / 0.20)
        envelope = rise * fall
        hum = math.sin(math.tau * (42.0 + progress * 8.0) * time) * 0.42
        stone = smooth_noise * (0.22 + progress * 0.18)
        liturgical_metal = math.sin(math.tau * 231.0 * time + math.sin(time * 7.0) * 0.8) * 0.08
        pulse = math.sin(math.tau * 6.5 * time) * 0.04
        samples.append(_soft_clip((hum + stone + liturgical_metal + pulse) * envelope))
    return _reverb(samples, ((0.09, 0.15), (0.23, 0.09)))


def _final_judgment() -> list[float]:
    duration = 1.45
    samples: list[float] = []
    smooth_noise = 0.0
    for index in range(int(duration * SAMPLE_RATE)):
        time = index / SAMPLE_RATE
        smooth_noise = smooth_noise * 0.93 + RNG.uniform(-1.0, 1.0) * 0.07
        body = math.sin(math.tau * (46.0 - time * 4.0) * time) * math.exp(-time * 5.2) * 0.84
        bell = (
            math.sin(math.tau * 91.0 * time) * 0.39
            + math.sin(math.tau * 136.5 * time) * 0.21
            + math.sin(math.tau * 203.0 * time) * 0.10
        ) * math.exp(-time * 2.15)
        # Heavy masonry pressure without an explosive high-frequency transient.
        crush = smooth_noise * math.exp(-time * 8.0) * 0.38
        tail = math.sin(math.tau * 31.0 * time) * math.exp(-time * 1.9) * 0.20
        samples.append(_soft_clip(body + bell + crush + tail))
    return _reverb(samples, ((0.12, 0.19), (0.29, 0.12), (0.48, 0.07)))


def main() -> None:
    _write("absolution_bell_invocation.wav", _bell_invocation())
    _write("absolution_seal_lock.wav", _seal_lock())
    _write("absolution_final_judgment.wav", _final_judgment())
    print("WEIGHT_OF_ABSOLUTION_SFX: PASS files=3")


if __name__ == "__main__":
    main()
