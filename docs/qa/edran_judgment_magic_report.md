# Edran Lightning + Gravity Magic Report

Status: **PASS (automated/runtime contract); manual feel acceptance pending**

## Threefold Judgment

- attack kind: `edran_threefold_judgment`; each bolt receives a unique numeric
  `attack_id` from Edran's existing attack ledger.
- phases: Phase 1 and Phase 2.
- damage/count: 18 × 3; each 48 px diameter AOE has one-hit memory.
- history: 2.0 seconds retained, sampled every 0.10 seconds; target delay 1.0
  second. Each bolt resamples independently at 0.70-second intervals.
- timing: 0.85 windup, 0.65 per-bolt telegraph, 0.18 active, 0.32 visual,
  1.00/0.85 Phase 1/2 recovery.
- cooldown: 10.5 seconds Phase 1, 8.5 seconds Phase 2.
- selector: shared spell pool, recent-magic suppression and chain/action lock;
  Far pressure increases weight and historical movement distance supplies only
  a small standing-target multiplier.
- VFX: original cold-white/pale-blue chapel bolt, thirteen-node ground seal,
  muted-gold ring and pointed chapel-spire telegraph.
- SFX: the saved strike node reuses the chapter-owned low stone-pressure
  transient at restrained volume; Boss music is untouched.

The deterministic runtime test recorded targets `(80,0)`, `(88,0)`, `(96,0)`
for three moving historical samples with measured timing error `0.00s`. This
proves independent history reads, not current-input prediction. Standing,
walking, zigzag and Dash *feel/readability* remain manual acceptance cases.
The same focused suite activated the saved lightning scene's formal Hitbox,
resolved exactly 18 damage and rejected a second hit with the same attack ID.

## The Weight of Absolution

- phase: Phase 2 only.
- cast: 1.70 seconds; pre-seal Poise interrupt window ends at 0.90 seconds;
  Final Seal has cast armour.
- sure-hit: tracked Player seal; movement, jump, Dash and ordinary Hurtbox
  invulnerability do not alter Health settlement.
- HP rule: `HP > 50 -> 50`; `HP <= 50 -> take_damage(20)`.
- cooldown: 21 seconds complete, 9 seconds if interrupted before Final Seal.
- first cast delay/recovery: 8.0 / 1.35 seconds.
- safety: no DOT, freeze, mire, knockback or ordinary hitstop; post-cast Ice and
  major-pressure selection are suppressed for 1.75 seconds.
- VFX: tracked thirteenth-bell silhouette, thirteen concentric seals and
  black-blue/violet downward distortion with silver/dark-gold accents.
- SFX: Final Seal plays the chapter-owned 1.10-second thirteenth-bell sequence;
  no science-fiction gravity cue or BGM mutation is introduced.

## HP Test

| Before | Expected | Actual | PASS |
| -----: | -------: | -----: | :--: |
| 100 | 50 | 50 | PASS |
| 90 | 50 | 50 | PASS |
| 80 | 50 | 50 | PASS |
| 60 | 50 | 50 | PASS |
| 51 | 50 | 50 | PASS |
| 50 | 30 | 30 | PASS |
| 49 | 29 | 29 | PASS |
| 40 | 20 | 20 | PASS |
| 35 | 15 | 15 | PASS |
| 30 | 10 | 10 | PASS |
| 21 | 1 | 1 | PASS |
| 20 | 0 | 0 | PASS |
| 10 | 0 | 0 | PASS |

## Preserved verification

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit-after 2
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_judgment_magic.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_elemental_magic.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_b4_b7_full_boss.gd
```

The focused judgment suite passes 65 assertions. The broader historical
Chapter-III route harness also
surfaced an unrelated existing `UnderkeepDripPoint._release_drop()` teardown
error outside this task's Boss scope; it was not hidden or modified here.
