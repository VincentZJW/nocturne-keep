# Music System Specification

## Runtime ownership

`res://scripts/audio/music_manager.gd` is the single persistent music authority. It owns two reusable `AudioStreamPlayer` decks on the `Music` bus. Chapter/Boss controllers request stable track IDs; attack AI and presentation scenes do not create music players or poll HP to choose music.

The formal bus layout is:

```text
Master
├── Music
├── SFX
├── Ambient
└── UI
```

Definitions are typed `MusicTrackDefinition` Resources registered by `MusicTrackRegistry`. Runtime APIs include play, crossfade, fade out, stop, pause/resume, volume, dialogue duck/restore, one-shot phase switching and preload lookup.

## Chapter II — Hollow Duchess

| Track ID | Cue | Tempo/meter | Runtime gain | Loop |
| --- | --- | --- | --- | --- |
| `CH2_BOSS_MUSIC_PHASE_01` | Existing Broken Waltz motif loop | 109.09 BPM, 3/4 | -13 dB | 0.000–6.600 s |
| `CH2_BOSS_MUSIC_PHASE_02` | The Final Waltz, Unmasked | 132 BPM, 3/4 | -9 dB | 0.000–130.909083 s |

The existing Phase 1 asset is deliberately documented as a short intro/motif loop, not a new production-length score. MU1 does not silently add an unapproved fourth composition.

Event contract:

1. Room encounter begins: clear the encounter phase guard and start Phase 1 with a 0.35-second fade.
2. `phase_transition_started`: attenuate Phase 1 to -20 dB over 0.90 seconds. Dialogue independently lowers the Music bus by another 6 dB and restores it after the final line.
3. Saved presentation reaches 68% mask reveal: emit `phase_02_revealed`, restore the dialogue target and crossfade from the start of Phase 2 over 1.10 seconds.
4. The `CH2_DUCHESS_PHASE_02_ONCE` guard prevents repeated HP/hit events from restarting Phase 2.
5. Boss defeat: 1.50-second fade. Player respawn: immediate stop and phase-guard reset; the next encounter request always starts Phase 1. Leaving the room/scene: short safety fade, so its Reward route never retains battle music.

## Debug and diagnostics

Chapter II debug spawn IDs `CH2_BOSS_MUSIC_PHASE_01`, `CH2_BOSS_MUSIC_TRANSITION` and `CH2_BOSS_MUSIC_PHASE_02` route through `MainBootstrap`, request the formal Boss entrance and show a small overlay with track ID, playback position, Music Bus gain, active deck count and switch count. The overlay is disabled outside these explicit debug entries and does not write formal save data.

## Chapter III — The Thirteenth Pontiff

| Track ID | Cue | Tempo/meter | Runtime gain | Loop |
| --- | --- | --- | --- | --- |
| `CH3_BOSS_MUSIC_PHASE_01` | Litany of the Thirteenth Bell / 第十三钟祷 | dotted-quarter 92 BPM, 6/8 | Intro -18 dB; combat -10 dB | 0.000–125.217396 s |
| `CH3_BOSS_MUSIC_PHASE_02` | The Bell Within the Bone / 骨中之钟 | dotted-quarter 124 BPM, 6/8 | combat -10 dB | 0.000–125.806458 s |

The formal `Chapter03BossSanctumRoom` is the event authority. `intro_environment_started` begins the score at restrained level; Edran's typed `activated` signal restores combat level. `phase_transition_started` attenuates Phase 1 to -24 dB, and the existing named `black_bell_reveal` stage performs a guarded 1.10-second crossfade to Phase 2.

Sanctum intro, transformation and death dialogue expose typed `dialogue_started` / `dialogue_finished` signals. They apply and restore a 6 dB Music-bus Duck without touching either deck's crossfade Tween. Edran's death sequence starts a 1.50-second fade; a Player respawn rebuilds the saved Boss room, clears the Phase 2 one-shot guard, skips the already-seen long intro and activates a fresh Phase 1. Transitioning to `CH3_POST_BOSS` or `CH3_UNDERKEEP_DESCENT` therefore has an empty track ID and zero playing Boss decks.

`CH3_BOSS_MUSIC_PHASE_01` is a guarded MainBootstrap debug start that loads the saved Chapter III route/Boss room and enables the shared MusicManager diagnostic overlay. It is not an independent audio test scene and does not change the formal default Opening-first F5 route.

## Source and provenance

The Phase 2 score is a fixed-seed project-owned composition rendered with local NumPy/SciPy oscillators and FFmpeg Vorbis. It uses no downloaded samples, real hymn, existing waltz or remote generation service. The generator, event score JSON and Standard MIDI are retained next to the chapter-local OGG so future work remains reproducible.

## Chapter IV — Soul Gaoler Ormund

| Track ID | Cue | Tempo/meter | Runtime gain | Loop |
| --- | --- | --- | --- | --- |
| `CH4_BOSS_SOUL_GAOLER_PHASE_01` | The Weight of the Last Key / 末钥之重 | 78 BPM, 4/4 | -11.5 dB; dialogue Duck -6 dB | 0.000–184.615375 s |
| `CH4_BOSS_SOUL_GAOLER_TRANSITION` | The Soul Cage Gives Way / 魂笼崩裂 | 104 BPM, 4/4 | -8.5 dB | one shot, 9.230771 s |
| `CH4_BOSS_SOUL_GAOLER_PHASE_02` | The Gaol Breaks Within / 狱锁自内崩裂 | 104 BPM, 4/4 | -10 dB | 0.000–166.153854 s |

The shared gaoler motif is the original descending pitch set D–C–B-flat–A–E-flat. Phase 1 presents it in complete bass/brass statements over three alternating weight/chain/water rhythmic beds. Phase 2 fragments and displaces the same motif among low strings, bass brass and chain attacks; it is a recomposition with new section lengths and harmonic pressure, not a tempo-stretched Phase 1 master.

Phase 1 has seven formal regions: 4-bar submerged Intro, 12-bar `A_The_Warden`, 10-bar `B_The_Chains`, 10-bar `C_The_Flood`, 8-bar `D_The_Cage`, 12-bar `A_prime_The_Gaoler_Advances` and a 4-bar loop return. Phase 2 has 14-bar `A2_Broken_Gaoler`, 12-bar `B2_Soul_Cage_Rupture`, 12-bar `C2_Undertow`, 10-bar `D2_No_Prison_Holds`, 18-bar `Final_Lock` and a 6-bar loop return.

The saved Boss transition is 8 frames over 9.230769 seconds. Its typed events are aligned to the bridge at 1.153846 s (`first_chain_break`), 2.307692 s (`second_chain_break`), 4.615385 s (`soul_cage_collapse`), 6.923077 s (`flood_surge`) and 8.653846 s (`final_iron_impact`). The controller attenuates Phase 1 to -24 dB, plays the non-looping bridge, then performs a guarded 0.18-second Phase 2 handoff. Intro dialogue uses the shared Music-bus Duck at 6 dB; death fades all music over 2.0 seconds; retry clears the guard and starts Phase 1; `CH4_BOSS_PHASE_02` is a true MainBootstrap direct Phase 2 route.

All three masters are fixed-seed, project-owned 48 kHz stereo Vorbis renders. Their source score JSON, Standard MIDI, analysis JSON and generator are retained under the Chapter IV Boss audio tree. No recorded/downloaded sample, commercial melody, religious text or remote generation service is used.

## Lifecycle and milestone boundary

MU1–MU4 are complete: the three new original tracks, both protected phase transitions, 6 dB dialogue Duck, 1.50-second death fades, Phase 1 retries and silent Reward/exit states are bound to formal Main routes. MU5 remains the separately approved full-fight, long-loop, SFX-masking and forced QA matrix; MU4 does not pre-claim that subjective acceptance.
