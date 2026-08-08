# Chapter IV Boss Music CH4-M5 QA Report

Date: 2026-08-08
Engine: Godot 4.7.1 Standard (`4.7.1.stable.official.a13da4feb`)
Main authority: `res://scenes/bootstrap/main_bootstrap.tscn`
Boss room: `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_14_core_of_drowned_gaol.tscn`

## Production masters

### Phase 1

- Formal title: **The Weight of the Last Key / 末钥之重**
- OGG: `res://chapters/chapter_04_drowned_underkeep/assets/audio/music/boss/soul_gaoler_ormund/soul_gaoler_phase_01_submerged_chains.ogg`
- BPM/meter: 78 BPM, 4/4
- Duration/loop: 184.615375 s; 0.000000–184.615375 s
- Main motif: D–C–B-flat–A–E-flat, complete low-register statements
- Secondary response: F–A-flat–G–B–B-flat–E
- Sections: Intro 0.000–12.308; A 12.308–49.231; B 49.231–80.000; C 80.000–110.769; D 110.769–135.385; A-prime 135.385–172.308; Loop Return 172.308–184.615
- Instrument roles: contrabass/cello-derived synthesis, bass brass, timpani, gate impacts, chains, water-pressure texture, low soul/choir texture and cold pad

### Phase 2

- Formal title: **The Gaol Breaks Within / 狱锁自内崩裂**
- OGG: `res://chapters/chapter_04_drowned_underkeep/assets/audio/music/boss/soul_gaoler_ormund/soul_gaoler_phase_02_broken_cage.ogg`
- BPM/meter: 104 BPM, 4/4
- Duration/loop: 166.153854 s; 0.000000–166.153854 s
- Main motif: the same D–C–B-flat–A–E-flat set fragmented, displaced and forced into unstable responses
- Secondary response: retained pitch identity with shorter offsets and denser chain/string countersubject
- Sections: A2 0.000–32.308; B2 32.308–60.000; C2 60.000–87.692; D2 87.692–110.769; Final Lock 110.769–152.308; Loop Return 152.308–166.154
- Instrument roles: denser low strings, bass brass, bass, timpani, chains, water, soul texture and gate impacts; composition is not a speed-adjusted Phase 1 render

### Transition

- Formal title: **The Soul Cage Gives Way / 魂笼崩裂**
- OGG: `res://chapters/chapter_04_drowned_underkeep/assets/audio/music/boss/soul_gaoler_ormund/soul_gaoler_phase_transition_soul_cage_break.ogg`
- Duration: 9.230771 s, non-looping
- Sync map: 1.153846 first chain break; 2.307692 second chain break; 4.615385 soul-cage collapse; 6.923077 flood surge; 8.653846 final iron impact; 9.230769 Phase 2 handoff

## Files and provenance

- Standard MIDI: the three matching `.mid` files in the formal Boss audio directory.
- Source scores: `source/*_score.json`.
- Authoritative generator: `source/generate_soul_gaoler_ormund_score.py`.
- Shared local renderer: `res://scripts/audio/tools/procedural_music.py`.
- Analysis: the three matching `.analysis.json` files.
- Provenance: fixed-seed original synthesis only. No downloaded/recorded sample, commercial music, remote music service, real hymn or religious lyric.

## Machine analysis

| Cue | Sample format | Peak | RMS | Endpoint delta | SHA-256 |
| --- | --- | ---: | ---: | ---: | --- |
| Phase 1 | 48 kHz stereo | -3.10 dBFS | -16.68 dBFS | 0.000000 | `b3a1cd244fe9cbc3f0312fbb67f87e8c1c62dd134366a08e90d7a979047b289e` |
| Phase 2 | 48 kHz stereo | -3.10 dBFS | -17.27 dBFS | 0.000000 | `37e7c494928c3b3b5902a69cc4ab1432569262fbe4e400d9b0c0da9cfd9b1375` |
| Transition | 48 kHz stereo | -3.10 dBFS | -22.57 dBFS | 0.000000 | `546c071a9381090b6e17fcb2a3e504510b353ca11764f0cb02f7c5d25f2a148a` |

## Runtime QA

Command:

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://chapters/chapter_04_drowned_underkeep/tests/audio/test_soul_gaoler_music_ch4_m5.gd
```

Result:

```text
SOUL_GAOLER_MUSIC_CH4_M5: PASS main=Bootstrap real_bridge=1 boss_cycles=10 transition_cycles=20 direct_phase2=1
```

The test uses MainBootstrap and the saved Chapter IV room. It checks the real-time 9.23-second bridge, five named animation sync cues, ten Boss lifecycles, twenty guarded handoffs, single-deck settlement and a fresh `CH4_BOSS_PHASE_02` Main reload.

## Forced QA matrix

| Item | Status | Evidence |
| --- | --- | --- |
| Current old-music audit | PASS | M0 reproduced both obsolete 12-second WAV failures |
| Phase 1 original rebuild | PASS | 184.615375 s OGG/MIDI/source/analysis |
| Phase 1 weight | PARTIAL | low-brass/bass/timpani density and section analysis; user listening acceptance required |
| Phase 1 pressure | PARTIAL | rhythmic/event analysis and runtime level pass; user listening acceptance required |
| Phase 1 drowned-gaol theme | PARTIAL | chain/water/soul layers are present; subjective acceptance required |
| Phase 1 main melody | PASS | explicit five-note score motif in MIDI/JSON |
| Phase 1 secondary melody | PASS | explicit six-note response in MIDI/JSON |
| Phase 1 at least four sections | PASS | seven named regions |
| Phase 1 no mechanical repetition | PASS | 583 events, three low-frequency beds and seven formal regions |
| Phase 2 original rebuild | PASS | 166.153854 s OGG/MIDI/source/analysis |
| Phase 2 inherits Phase 1 motif | PASS | same motif pitch set, re-voiced and fragmented |
| Phase 2 pressure escalation | PARTIAL | denser/faster event structure passes; user listening acceptance required |
| Phase 2 retains weight | PARTIAL | low-register instrumentation remains; user listening acceptance required |
| Phase 2 at least four sections | PASS | six named regions |
| Phase 2 is not simple acceleration | PASS | independent score, 1,011 events, different sections/harmony |
| Transition Bridge | PASS | independent 9.23-second cue with five typed sync events |
| Intro integration | PASS | formal Boss room starts Phase 1 |
| Dialogue Duck | PASS | 6 dB Music-bus Duck and restore contract |
| Phase switch | PASS | guarded 0.18-second P2 handoff after transition |
| Death music exit | PASS | 2.0-second all-deck/stinger fade |
| Retry reset | PASS | guard clear and P1 restart |
| Boss SFX clarity | PARTIAL | conservative mix gain/headroom passes; user combat listening required |
| 15-minute Loop Phase 1 | PASS | 900 s, 4 wraps, one active player, static-memory growth -2,888 bytes |
| 15-minute Loop Phase 2 | PASS | 900 s, 5 wraps, one active player, static-memory growth -2,888 bytes |
| Main/F5 | PASS | MainBootstrap direct Phase 1 and true direct Phase 2 routes passed |
| Output/Debugger | PASS | integration run exited 0 without red Godot errors |

Overall deterministic/runtime result: **PASS**. Overall listening acceptance: **PARTIAL**, because perceived weight, fatigue and attack-SFX masking require a human listening pass and are not honestly inferable from waveform statistics.

## Endurance QA

Commands:

```text
MU_LONG_PLAY_SECONDS=900 MU_LONG_PLAY_TRACK_ID=CH4_BOSS_SOUL_GAOLER_PHASE_01 /Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/audio/test_music_manager_long_play.gd
MU_LONG_PLAY_SECONDS=900 MU_LONG_PLAY_TRACK_ID=CH4_BOSS_SOUL_GAOLER_PHASE_02 /Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/audio/test_music_manager_long_play.gd
```

Results:

```text
MUSIC_MANAGER_LONG_PLAY: PASS track=CH4_BOSS_SOUL_GAOLER_PHASE_01 seconds=900.0 wraps=4 max_players=1 memory_start=37965649 memory_end=37962761 memory_peak=37967481 memory_growth=-2888
MUSIC_MANAGER_LONG_PLAY: PASS track=CH4_BOSS_SOUL_GAOLER_PHASE_02 seconds=900.0 wraps=5 max_players=1 memory_start=37965649 memory_end=37962761 memory_peak=37967481 memory_growth=-2888
```

## Final regression

Exact Godot 4.7.1 editor import/parse exited `0`. The final regression results were:

```text
SOUL_GAOLER_MUSIC_CH4_M5: PASS main=Bootstrap real_bridge=1 boss_cycles=10 transition_cycles=20 direct_phase2=1
SOUL GAOLER ORMUND TEST | PASS
CH4 Q4/BOSS FLOW | PASS Main=bootstrap Boss=P1/P2/death reward=locked/collected memory=CH5_START cistern=cleared
MUSIC_MANAGER_MU1_TEST: PASS buses=5 decks=2 transitions=20 duplicate_guard=PASS
MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn
```

All commands exited `0`; no red Godot parser, resource or runtime error was emitted.

## Manual acceptance route

1. Set Debug Chapter Start to `CHAPTER_04_DROWNED_UNDERKEEP` and spawn `CH4_BOSS_PHASE_01`.
2. Press F5. Confirm restrained P1 during the seven-line intro, then restored combat level.
3. Reduce Ormund below 55%. Confirm five visible transformation beats correspond to chain/impact/water events and Phase 2 begins only after the final impact.
4. Listen through attacks in both phases; verify telegraphs remain audible and neither loop becomes fatiguing.
5. Die/retry and confirm P1 restarts. Defeat Ormund and confirm the 2.0-second exit. Repeat with `CH4_BOSS_PHASE_02` to verify direct P2 iteration.
