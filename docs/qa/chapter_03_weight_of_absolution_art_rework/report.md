# EDRAN – THE WEIGHT OF ABSOLUTION ART REWORK REPORT

## Current State

- Logic trigger status: **PASS** — the saved MainBootstrap path still forces the rite after the Phase 2 dialogue and before normal Phase 2 AI.
- Previous art quality issues: the runtime spell used `_draw()` circles, five pressure lines and a flat polygonal bell; Edran reused Mire animations and the sound layer was generic.
- Was geometry placeholder used: **Yes, before this rework; no in the formal runtime after it.**
- Was Phase 2 forced cast working before fix: **Yes.** This task preserved that chain instead of replacing its rules.

## Art Direction

- Core theme: gothic religious judgment, the weight of sin, sacred authority and forced spiritual submission.
- Bell design: a 128×128 reliquary bell with suspension crown, thick lip, layered cold-metal planes, cracks, central judgment relief and thirteen pointed chapel seals.
- Seal design: a thirteen-sector liturgical seal with balance imagery, cardinal braces, inner verdict geometry and restrained antique-gold hierarchy.
- Compression FX: descending silver-blue pressure strata, target-body squash, four-pixel downward camera load and compressed/dimmed sanctuary candles.
- Final Seal impact: the bell settles downward, seal contracts, a narrow silver judgment mark strikes through the target and the screen vignette briefly closes.
- Color palette: `#070A14`, `#101A2B`, `#526B83`, `#718596`, `#C6D3DB`, `#EDF3F3`, `#9A7B45`, `#C3AA6A`, `#625D76`.
- SFX approach: three original mono 44.1 kHz cues — low remote bell with chapel decay, stone/metal seal pressure, and a heavy final bell judgment without explosive spectacle.

## Assets

- Modified assets: Edran Phase 2 generator and SpriteFrames, Boss script, gravity spell scene/script, Boss sanctum candle grouping, focused Main QA/capture scripts.
- New formal assets created: 21 saved transparent VFX PNGs, one saved SpriteFrames Resource, ten dedicated Edran action frames, three original WAV cues and their deterministic source generators.
- Old placeholder assets replaced: every runtime `_draw()` bell, circle, line and resolution disc was removed from `pontiff_gravity_judgment.gd`; no old placeholder path remains referenced by the formal spell scene.
- Formal asset sheet: `weight_of_absolution_asset_sheet.png`.

## Runtime

- Main/F5 tested: **PASS**, authority `res://scenes/bootstrap/main_bootstrap.tscn`.
- CH3_BOSS tested: **PASS**, saved Chapter III route and Boss room.
- HP 60 result: **50**.
- HP 40 result: **20**.
- HP 15 result: **15**, unchanged and not healed.
- Phase 2 forced cast visible: **PASS** — dedicated windup is entered only after dialogue/title UI clears.
- Final Seal visible: **PASS** — dedicated Boss pose, sacred bell, judgment seal, compression and final impact all instantiate from saved formal resources.
- Any red errors: **No** in exact-engine import/parse, focused tests or graphical Main capture.

## QA Evidence

| Evidence | Result | File |
|---|---|---|
| Formal asset sheet | PASS | `weight_of_absolution_asset_sheet.png` |
| Phase 2 dialogue, HP 60 | PASS | `01_phase_02_dialogue_hp_60.png` |
| Edran ritual + target lock | PASS | `02_weight_cast_ritual.png` |
| Thirteenth bell + Final Seal | PASS | `03_thirteenth_bell_and_judgment_seal.png` |
| Final judgment, HP 50 | PASS | `04_final_judgment_hp_50.png` |
| Recovery before normal AI | PASS | `05_phase_02_recovery_complete.png` |

Exact Godot 4.7.1 results:

- Editor import/parse: PASS.
- `test_edran_judgment_magic.gd`: PASS, 100 assertions and 17 HP matrix cases.
- `test_edran_phase_02_forced_opening_main.gd`: PASS, `60→50`, `40→20`, `15→15`.
- `test_edran_b4_b7_full_boss.gd`: PASS, 20 battle regressions.
- `test_edran_elemental_magic.gd`: PASS, 986 assertions.
- Graphical Main capture: PASS, five 1280×720 screenshots; this runner intentionally uses the graphical renderer because a headless Viewport has no readable screen texture.

## QA Conclusion

- Is the spell no longer a rough geometry placeholder: **Yes — PASS.**
- Does it match “赦罪之重”: **Yes — PASS**, through a readable caster rite, detailed sacred bell, thirteen-part verdict seal, spatial oppression and final divine judgment.
- Is it ready for user test: **Yes.** Final subjective readability, sound balance and dramatic weight remain the user's manual acceptance gate.
