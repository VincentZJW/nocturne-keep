# Chapter IV Boss Music CH4-M5 / CH4-MELODY QA Report

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
- Gaoler theme: D–C–B-flat–A–E-flat, retained as the Boss identity and authored in six formal treatments: low brass, cello/viola, higher low-string mirror, antiphonal fragments, fractured statement and chromatic/local inversion.
- Soul Prison theme: F–A-flat–G–F–E–E-flat–D. Its descending chromatic sigh represents the prisoners and resolves into the Gaoler's D centre without becoming heroic.
- Undertow motif: A–G–E-flat–D, a four-note falling current used selectively in flood/Undertow regions.
- Sections: Intro 0.000–9.231; The Warden 9.231–40.000; The Prisoners 40.000–64.615; The Flood 64.615–89.231; The Chains 89.231–113.846; The Empty Cell 113.846–135.385; The Gaoler Returns 135.385–166.154; Loop Return 166.154–184.615.
- Instrument roles: contrabass/cello-derived synthesis, bass brass, viola/low violin, timpani, gate impacts, chains, water-pressure texture, low soul/choir texture, restrained glass colour and cold pad.

### Phase 2

- Formal title: **The Gaol Breaks Within / 狱锁自内崩裂**
- OGG: `res://chapters/chapter_04_drowned_underkeep/assets/audio/music/boss/soul_gaoler_ormund/soul_gaoler_phase_02_broken_cage.ogg`
- BPM/meter: 104 BPM, 4/4
- Duration/loop: 166.153854 s; 0.000000–166.153854 s
- Gaoler theme: the same D–C–B-flat–A–E-flat identity shortened, chromatically bent, staggered between cello/brass, split between voices and locally inverted.
- Soul Prison theme: promoted from weak fragments to full strings/low choir statements, then placed against the Gaoler theme in the climax.
- Sections: Broken Gaoler 0.000–27.692; Soul Cage Rupture 27.692–50.769; Undertow Hunt 50.769–73.846; No Prison Holds 73.846–92.308; Chains Against Souls 92.308–115.385; Final Lock 115.385–147.692; Loop Return 147.692–166.154.
- Instrument roles: denser low strings, split bass brass, bass, timpani, chains, water, soul texture, restrained glass colour and gate impacts. This is an independent development score, not a speed-adjusted Phase 1 render.

### Transition

- Formal title: **The Soul Cage Gives Way / 魂笼崩裂**
- OGG: `res://chapters/chapter_04_drowned_underkeep/assets/audio/music/boss/soul_gaoler_ormund/soul_gaoler_phase_transition_soul_cage_break.ogg`
- Duration: 9.230771 s, non-looping
- Sync map: 1.153846 first chain break; 2.307692 second chain break; 4.615385 soul-cage collapse; 6.923077 flood surge; 8.653846 final iron impact; 9.230769 Phase 2 handoff

## CH4-MELODY enrichment contract

The new material is melodic, not merely extra instrumentation:

1. The Gaoler theme has six authored treatments. A is the original low-brass statement; B moves it to cello/viola; C raises it into the prisoners' register; D distributes fragments as brass → strings → chain → bass call-and-response; E compresses it into broken attack cells; F bends/inverts its intervals for Phase 2 instability.
2. The Soul Prison theme is the independent seven-note F–A-flat–G–F–E–E-flat–D line. Its F–E–E-flat–D close is the explicit half-step lament; `FULL`, `SIGH`, `INVERTED_MEMORY`, `FRAGMENT_FRONT` and `FRAGMENT_SIGH` treatments create development rather than literal repeats.
3. The Undertow motif is the independent A–G–E-flat–D current. It binds flood attacks and Phase 2 motion without occupying the entire score.
4. P1 `The Flood` omits a complete Gaoler statement and develops Undertow; P1 `The Empty Cell` removes the Gaoler theme and exposes the complete Soul theme. P2 `Undertow Hunt` similarly omits the complete Gaoler theme.
5. P1 `The Gaoler Returns` places Gaoler and shortened/inverted Soul material in counterpoint. P2 `Final Lock` is the full climax: low brass states the Gaoler theme while strings/low soul voices state the Soul theme and Undertow continues as a separate current.
6. Phase 2 changes Phase 1 through shorter note values, chromatic alteration, delayed voice entries, split phrases, local inversion and an inversion of thematic hierarchy: Gaoler dominates P1; Soul increasingly overwhelms him in P2.

The four low-foundation shapes rotate at a maximum of two identical bars. P1 uses four sectional harmonic environments; P2 uses suspended, chromatic-descent, diminished/tritone and pedal-bass environments without abandoning the D-centred identity. Every formal section changes at least one of melody, orchestration, harmony, density or percussion.

## Composition QA scores

These are score/arrangement assessments, not a claim of human auditory acceptance. The new-version values meet the requested authoring thresholds; final perceived fatigue and SFX balance remain a manual listening gate.

| Item | Pre-enrichment | Enriched score |
| --- | ---: | ---: |
| Pressure | 9.2 | 9.2 |
| Weight | 9.3 | 9.3 |
| Character/background fit | 9.1 | 9.5 |
| Main-theme identity | 8.1 | 9.1 |
| Secondary-melody richness | 6.0 | 9.0 |
| Section richness | 7.6 | 9.4 |
| Harmonic richness | 7.0 | 8.9 |
| Orchestration variation | 7.4 | 9.1 |
| Long-form durability | 6.9 | 8.8 (provisional listening gate) |
| Phase 1/2 thematic relation | 8.9 | 9.5 |

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
| Phase 1 | 48 kHz stereo | -3.10 dBFS | -17.83 dBFS | 0.000000 | `1f20c6871333511247018d623629a0d3ce6c2040c72253122ac876f910564877` |
| Phase 2 | 48 kHz stereo | -3.10 dBFS | -19.28 dBFS | 0.000000 | `05458edd6c17c7db5cdfd4f4106f2be701db004c5795410fccd25f3d96c638dd` |
| Transition | 48 kHz stereo | -3.10 dBFS | -22.57 dBFS | 0.000000 | `2940d2cfd3f8ce3e32f4580b36fdf6462199b0385e53fedd03b5d780928fe6fe` |

Spectral-space check (Welch analysis at 24 kHz mono decode): P1 holds 94.25% of energy below 250 Hz and only 0.02% in 800–3000 Hz; P2 holds 93.14% below 250 Hz and 0.03% in 800–3000 Hz. Ten-second RMS variation is 4.54 dB in P1 and 2.00 dB in P2. The score therefore adds melodic notes without filling the combat-telegraph presence band. This is objective headroom evidence, not a substitute for combat listening.

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
| Phase 1 secondary melody | PASS | independent seven-note Soul Prison theme plus five treatments in MIDI/JSON |
| Phase 1 at least four sections | PASS | eight named regions |
| Phase 1 no mechanical repetition | PASS | 604 events, four rotating low foundations and no identical bass rhythm beyond two bars |
| Phase 2 original rebuild | PASS | 166.153854 s OGG/MIDI/source/analysis |
| Phase 2 inherits Phase 1 motif | PASS | same motif pitch set, re-voiced and fragmented |
| Phase 2 pressure escalation | PARTIAL | denser/faster event structure passes; user listening acceptance required |
| Phase 2 retains weight | PARTIAL | low-register instrumentation remains; user listening acceptance required |
| Phase 2 at least four sections | PASS | seven named regions |
| Phase 2 is not simple acceleration | PASS | independent 970-event score, seven regions, changed thematic hierarchy and four-plus harmonic environments |
| Transition Bridge | PASS | independent 9.23-second cue with five typed sync events |
| Intro integration | PASS | formal Boss room starts Phase 1 |
| Dialogue Duck | PASS | 6 dB Music-bus Duck and restore contract |
| Phase switch | PASS | guarded 0.18-second P2 handoff after transition |
| Death music exit | PASS | 2.0-second all-deck/stinger fade |
| Retry reset | PASS | guard clear and P1 restart |
| Boss SFX clarity | PARTIAL | conservative mix gain/headroom passes; user combat listening required |
| 15-minute Loop Phase 1 | PASS | 900 s, 4 wraps, one active player, static-memory growth -2,888 bytes |
| 15-minute Loop Phase 2 | PASS | 900 s, 5 wraps, one active player, static-memory growth -2,888 bytes |
| Main/F5 | PASS | MainBootstrap direct Phase 1 and true direct Phase 2 routes passed, including 120-second formal-room dwell per phase |
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
MUSIC_MANAGER_LONG_PLAY: PASS track=CH4_BOSS_SOUL_GAOLER_PHASE_01 seconds=900.0 wraps=4 max_players=1 memory_start=38115021 memory_end=38112133 memory_peak=38116853 memory_growth=-2888
MUSIC_MANAGER_LONG_PLAY: PASS track=CH4_BOSS_SOUL_GAOLER_PHASE_02 seconds=900.0 wraps=5 max_players=1 memory_start=38115021 memory_end=38112133 memory_peak=38116853 memory_growth=-2888
CH4_PARALLEL_LONG_PLAY_STATUS p1=0 p2=0
```

## Formal Main-room dwell QA

Command:

```text
CH4_MELODY_MAIN_DWELL_SECONDS=120 /Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://chapters/chapter_04_drowned_underkeep/tests/audio/test_soul_gaoler_music_ch4_m5.gd
```

Result:

```text
SOUL_GAOLER_MUSIC_CH4_M5: PASS main=Bootstrap real_bridge=1 boss_cycles=10 transition_cycles=20 direct_phase2=1
```

This enters the saved Chapter IV Boss room through MainBootstrap, keeps P1 active for 120 seconds, performs the real 9.23-second transition, reloads through the saved `CH4_BOSS_PHASE_02` route and keeps P2 active for 120 seconds. The automated dwell freezes Boss physics only during each timed music observation so the test Player cannot die; it does not alter saved gameplay, music, state or balance. Human combat listening is still required for subjective SFX masking and fatigue acceptance.

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
