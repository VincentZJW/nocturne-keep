# Boss Music MU0 Audit and Production Plan

Date: 2026-07-30
Milestone: MU0
Status: complete audit and design gate; no new music or runtime integration has been produced

## Scope boundary

MU0 only audits the real runtime, analyses the existing Duchess cue, verifies local production capability and locks the production plan for three original Boss tracks. It does **not** create an audio file, add a MusicManager, change a Bus, modify a Boss scene, or begin MU1.

## Runtime and music-system audit

| Item | Audited result |
|---|---|
| Formal F5 entry | `res://scenes/bootstrap/main_bootstrap.tscn` from `project.godot` `run/main_scene` |
| Formal new-game route | `res://scenes/cinematics/opening_cinematic.tscn` |
| MusicManager / AudioManager | **Absent.** There is no global or scene-local formal music authority. |
| Bus layout | **Absent.** No `default_bus_layout.tres` exists and no script creates buses, so the project currently relies on `Master`. |
| Scene fade authority | `res://scripts/systems/scene_transition_manager.gd`; it fades the screen and retires old scene-local `AudioStreamPlayer` nodes, but it has no persistent music contract. |
| Current audio import policy | Chapter III WAV effects use lossless PCM import, no normalize, no trim and no loop. The embedded Duchess WAV Resource bypasses `.import` and stores its loop directly. |
| Music preload | No formal track registry or preload API exists. The Duchess cue loads because its presentation scene owns it as an external Resource. |
| First-play risk | No asynchronous music preload/crossfade layer exists; future OGG tracks could incur first-use decode/loading work unless explicitly preloaded. |

### Existing direct audio ownership

- Chapter II owns one direct `AudioStreamPlayer` at `SilentCourt/GameplayWorld/BossArea/DuchessEncounterPresentation/BrokenWaltzPlayer` through `duchess_encounter_presentation.tscn`.
- That player uses `bus = &"Master"` and `volume_db = -13.0`.
- Chapter III has no Boss music player. Its existing audio consists only of gate bell/wax/stone WAV effects and an underkeep water-drip WAV on local `AudioStreamPlayer2D` nodes.

## Chapter II audit

### Formal paths and event flow

- Chapter scene: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`
- Boss scene: `res://chapters/chapter_02_silent_court/scenes/boss/hollow_duchess.tscn`
- Boss script: `res://chapters/chapter_02_silent_court/scripts/boss/hollow_duchess.gd`
- Room controller: `res://chapters/chapter_02_silent_court/scripts/boss/hollow_duchess_room_controller.gd`
- Presentation scene: `res://chapters/chapter_02_silent_court/scenes/boss/duchess_encounter_presentation.tscn`
- Presentation script: `res://chapters/chapter_02_silent_court/scripts/boss/duchess_encounter_presentation.gd`
- Current cue: `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/audio/broken_waltz_intro.tres`
- Source generator: `res://chapters/chapter_02_silent_court/scripts/tools/generate_duchess_broken_waltz.gd`

The room controller receives typed `combat_started`, `phase_transition_started`, `phase_transition_completed`, `boss_defeated` and respawn events. Intro calls `BrokenWaltzPlayer.play()`. Phase transition calls `BrokenWaltzPlayer.stop()` immediately. Respawn resets the Boss but currently has no centralized music-state reset.

### Broken Waltz musical analysis

| Property | Actual value |
|---|---|
| Resource type | Embedded `AudioStreamWAV` (`.tres`) |
| Encoding | 16-bit PCM, mono, 22,050 Hz |
| Duration | 6.60 seconds |
| Tempo | 109.09 BPM (`0.55 s` per quarter-note beat) |
| Meter | 3/4, inferred from the bass changing every three beats and the four-bar render |
| Length | 12 quarter-note beats / 4 bars |
| Loop | Forward loop, sample 0 to 145,530; 0.000 to 6.600 s |
| Level in scene | `-13.0 dB` on `Master` |
| Tonal centre | D minor / modal D with chromatic E-flat colour |
| Six-note motif | D4 – F4 – E4 – C4 – E-flat4 – D4 |
| Four-bar bass | D2 – C2 – E-flat2 – D2 |
| Timbre | Procedural sine melody plus second harmonic, sine bass, shellac-like noise and periodic dropout |

The six-note phrase occupies two 3/4 bars and repeats twice. The falling return through C–E-flat–D, the D/C/E-flat/D bass plan, triple meter and degraded shellac texture are the usable identity anchors for Phase 2.

### Truthful quality/status finding

The current cue is an original, valid, non-silent loop, but at four bars / 6.6 seconds it is an **intro motif loop**, not a production-length Phase 1 Boss track. It does not satisfy the final task's prohibition against using a short effect-like cue as a full Boss score. MU1 must keep it as the provenance source/intro cue and must not falsely report it as a 90–150 second formal Phase 1 composition. Extending or replacing Chapter II Phase 1 is outside the requested three-track MU0 plan and remains a final-QA risk unless separately approved.

### Current Phase 2 status

There is no Phase 2 stream, source score, transition sting, crossfade or track state. Phase 1 does **not** continue: it is stopped at transition start, leaving the Phase 2 fight without music.

## Chapter III audit

- Formal chapter route: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn`
- Formal Boss room: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_sanctum_room.tscn`
- Room controller: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/level/chapter_03_boss_sanctum_room.gd`
- Environment presentation: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/areas/chapter_03_boss_sanctum.gd`
- Boss scene: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/thirteenth_pontiff_edran.tscn`
- Boss script: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/bosses/thirteenth_pontiff_edran.gd`

Edran exposes typed `activated`, `phase_transition_started`, `phase_changed`, `phase_transition_finished`, `death_sequence_started` and `defeated` signals. The room already binds the transition and death presentation hooks. The 5.2-second transition contains an explicit `black_bell_reveal` stage, which is the correct musical switch point. No Phase 1, Phase 2, intro, transition or death music asset/player currently exists.

## Local production and rendering capability

| Tool | Status | Intended role |
|---|---|---|
| Godot 4.7.1 | available at `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot` | runtime import, loop playback, integration and QA |
| Python 3 | available at `/opt/anaconda3/bin/python3` | deterministic score, MIDI writer and sample-free synthesis |
| NumPy | available | oscillators, envelopes, mixing and analysis |
| SciPy | available | filters, convolution/reverb, WAV render and signal QA |
| FFmpeg 8.1.1 | available at `/opt/homebrew/bin/ffmpeg`; Vorbis encoder present | 48 kHz WAV to OGG Vorbis and metadata inspection |
| FFprobe | available | duration, channels, sample rate and bitrate validation |
| GarageBand | installed at `/Applications/GarageBand.app` | optional manual audition/refinement only; not required by the reproducible batch pipeline |
| `afplay` / `afinfo` / `afconvert` | available | local audition and independent file inspection/conversion |
| SoundFont / FluidSynth / TiMidity | not available; no `.sf2`/`.sf3` bank found | therefore the pipeline must not depend on an unknown sample library |
| MIDI Python packages | `mido` and `MIDIUtil` absent | write a minimal deterministic Standard MIDI file with project-owned Python instead of downloading packages |

The approved production route is a deterministic, fixed-seed, sample-free Python score/synthesis pipeline. It will generate a readable Standard MIDI source, render a 48 kHz stereo WAV master with purpose-built organ/string/choir/bell/percussion voices, and encode OGG with FFmpeg. This avoids remote services, API keys, unlicensed samples and provenance ambiguity. GarageBand is optional for human audition, not a hidden render dependency.

## Locked composition plans

### 1. The Final Waltz, Unmasked / 无面的最后华尔兹

- Target: Chapter II Duchess Phase 2.
- Meter/tempo: 3/4 at 132 BPM, 21% faster than the audited 109.09 BPM cue.
- Tonal centre: D minor/modal D, retaining E-flat corrosion.
- Motif continuity: transform D–F–E–C–E-flat–D through displacement, inversion fragments and semitone descents; accelerate D/C/E-flat/D bass cells.
- Form: 96 bars / approximately 130.91 seconds. Intro-pressure A, fractured dance B, glass-mask C, violent reprise A', bridge and loop return.
- Timbres: broken harpsichord/piano, short-bowed low strings, bowed bass, restrained frame/timpani impacts, glass partials and low pulse.
- Loop: bar 1 strong beat to bar 97 equivalent strong beat, sample 0 to 6,283,636 at 48 kHz (final endpoint will be rendered on an exact whole-sample boundary).
- Narrative rule: recognizably the same dance, never generic rock or an unrelated Boss theme.

### 2. Litany of the Thirteenth Bell / 第十三钟祷

- Target: Chapter III Edran Phase 1.
- Meter/tempo: 6/8 at 92 dotted-quarter BPM.
- Tonal centre: D Phrygian/minor with E-flat and restrained A-flat tension.
- Original ritual motif: D–E-flat–F–A-flat–G–F–E-flat–C–D–B-flat–A-flat–E-flat–D; thirteen tones without quoting a real hymn.
- Form: 96 bars / approximately 125.22 seconds. Organ litany A, thirteen-bell B, summon/element C, altar-return A'.
- Timbres: additive pipe organ, formant-based nonsemantic choir, low strings, inharmonic old bronze bell, bass drum, chain/censer metal and very low cold pad.
- Choir content: synthesized vowel/formant textures and project-original meaningless syllabic rhythm only; no Mass text, Latin hymn or real religious melody.
- Loop: whole-bar return from 0.000 to approximately 125.217 seconds.

### 3. The Bell Within the Bone / 骨中之钟

- Target: Chapter III Edran Phase 2.
- Meter/tempo: 6/8 at 124 dotted-quarter BPM.
- Tonal centre: the Phase 1 D centre destabilized by chromatic descent and tritone bell partials.
- Motif continuity: Phase 1's organ/bell/choir material is shortened, reversed and pushed into a 6+7 thirteen-unit accent cycle; this is a recomposition, not a playback-speed change.
- Form: 130 bars / approximately 125.81 seconds (ten thirteen-bar pressure cycles with larger sectional orchestration).
- Timbres: urgent organ ostinato, low choir, detuned/broken bell, dense low strings, war drum, bone-like transient and chain/censer percussion.
- Mix rule: mid/high spectral gaps remain around elemental telegraphs and summon cues; no continuous piercing highs.
- Loop: whole-bar return from 0.000 to approximately 125.806 seconds.

## Target delivery format

- Runtime: OGG Vorbis, 48,000 Hz, stereo, approximately quality 6, no leading/trailing silence.
- Source: project-owned `.py`, JSON/score data and Standard MIDI `.mid`; 48 kHz stereo WAV master retained only if repository size remains reasonable, otherwise produced reproducibly and documented.
- Headroom: master peak target no higher than approximately `-3 dBFS`; Music Bus supplies final game gain.
- Loop metadata: each track definition records BPM, meter, exact sample length and loop begin/end. OGG streams begin at a strong bar boundary and are preloaded before the encounter.
- Authenticity checks: non-silent RMS/peak, duration, channel/sample rate, waveform hash, spectrum, seamless boundary delta and ten-minute runtime playback.

## Planned runtime architecture and files

### Shared/global

- `res://default_bus_layout.tres` — `Master`, `Music`, `SFX`, `Ambient`, `UI` buses.
- `res://scripts/audio/music_track_definition.gd` — typed track metadata Resource.
- `res://scripts/audio/music_manager.gd` — Autoload with two persistent `AudioStreamPlayer` decks, preload, crossfade, fade, pause, dialogue duck and one-shot phase switch.
- `res://resources/audio/music_tracks/` — typed track-definition Resources/registry.
- `res://tests/audio/test_music_manager.gd` — deterministic state, duplicate-player and transition tests.

### Chapter II

- `res://chapters/chapter_02_silent_court/assets/audio/music/boss/hollow_duchess/hollow_duchess_phase_02_unmasked.ogg`
- Same directory: `.mid`, music spec and `source/generate_hollow_duchess_phase_02.py`.
- Modify `duchess_encounter_presentation.gd/.tscn` to stop owning formal music directly; retain the old cue only as an audited intro/motif source if required.
- Modify `hollow_duchess_room_controller.gd` to bind intro/combat/transition/phase reveal/defeat/respawn/room exit to MusicManager once, without HP polling.
- Add `test_hollow_duchess_music_flow.gd` and Main/F5 capture/stress evidence.

### Chapter III

- `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/audio/music/boss/thirteenth_pontiff_edran/thirteenth_pontiff_phase_01.ogg`
- `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/audio/music/boss/thirteenth_pontiff_edran/hollow_pontiff_phase_02.ogg`
- Same directory: both `.mid` files, shared music spec and deterministic source scripts/score data.
- Modify `chapter_03_boss_sanctum_room.gd` to own Boss-event-to-music orchestration.
- Modify `chapter_03_boss_sanctum.gd` only for typed intro/dialogue/black-bell/death/reward/underkeep timing signals needed by the orchestrator.
- Avoid putting music lifecycle logic inside attack/AI branches of `thirteenth_pontiff_edran.gd`; add a typed reveal signal only if the existing transition signals cannot identify `black_bell_reveal` precisely.
- Add Chapter III music-flow and Main/F5 stress tests.

### Debug and QA

- Extend `DebugRunConfig`, Chapter II/III start profiles and chapter-local entry routing for the requested music IDs without writing formal save state.
- Add a compact, disableable Main-loaded music debug overlay showing `track_id`, playback position, Music Bus gain and phase-switch state.
- Save reports/logs under `res://docs/qa/boss_music/`.

## Main/F5 verification entry plan

Formal startup remains `res://scenes/bootstrap/main_bootstrap.tscn`; no audio test scene will replace it.

- Chapter II full route: chapter `CHAPTER_02_SILENT_COURT`, spawn `CH2_BOSS`.
- Chapter III full route: chapter `CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES`, spawn `CH3_BOSS`.
- Existing Chapter III direct phase route: `CH3_BOSS_PHASE_02`.
- Planned Main music routes: `CH2_BOSS_MUSIC_PHASE_01`, `CH2_BOSS_MUSIC_TRANSITION`, `CH2_BOSS_MUSIC_PHASE_02`, `CH3_BOSS_MUSIC_PHASE_01`, `CH3_BOSS_MUSIC_TRANSITION`, `CH3_BOSS_MUSIC_PHASE_02`.

The music-specific IDs do not exist yet and are therefore **planned**, not claimed. Later stages must drive them through `MainBootstrap`/chapter profiles and keep formal save data untouched.

## MU0 verification baseline

- Exact Godot 4.7.1 editor/import/parse: PASS, exit 0.
- Formal MainBootstrap headless start for 240 frames: PASS, exit 0; selected formal opening cinematic.
- Output scan: no `ERROR`, `SCRIPT ERROR`, parse error or invalid-resource line.
- No audio audition or loop stress result is claimed in MU0 because no new audio has been produced.

## MU0 gate and known risks

- PASS: runtime ownership, cue properties, event hooks, local rendering tools and three-track composition plans are identified.
- FAIL for final delivery today: no MusicManager, no formal Bus layout, no Chapter II Phase 2 music, no Chapter III Boss music, no crossfade/duck/retry/exit integration and no stress QA exist yet.
- Scope risk requiring explicit acceptance before final QA: the existing 6.6-second Duchess cue is too short to count as a formal Phase 1 Boss score. MU1 remains scoped to Phase 2 unless the user separately approves a Phase 1 extension.
