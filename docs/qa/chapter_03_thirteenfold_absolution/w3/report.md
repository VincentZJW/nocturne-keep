# Thirteenfold Absolution W3 QA

Date: 2026-08-02

## Result matrix

| Check | Result | Evidence |
| --- | --- | --- |
| Independent WeaponData | PASS | Chapter-local `thirteenfold_absolution_blades.tres`; different path from Crimson Masque |
| Tier / damage / flags | PASS | Automated W3 write phase: tier 3, `14/28`, unique, permanent, story reward |
| Unique inventory ownership | PASS | Duplicate `add_weapon()` rejected |
| Equipment and Player visual | PASS | Equipment resolves W3 Resource; Player resolves W2 formal SpriteFrames |
| Death/respawn retention | PASS | Lethal damage plus `respawn_at()` retained ownership, equipped ID and visual |
| Fresh-process disk restore | PASS | Separate exact-Godot write and load processes restored ID, damage, flags and recovery spawn |
| Formal New Game cleanup | PASS | Old isolated save removed; runtime returned to Veilbound; clean baseline created |
| Debug isolation | PASS | Save SHA-256 unchanged after Debug reset, flag mutation and equipment reset |
| MainBootstrap formal/debug lifetime | PASS | Existing formal Opening + Debug Chapter II test passed |
| Boss reward/reliquary | PARTIAL | Reserved for approved W4; no false grant path added |

## Exact automated route

Run the W3 test twice with the same isolated `user://` path:

```bash
W3_PROGRESS_PHASE=write "$GODOT_BIN" --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_w3_progress.gd
W3_PROGRESS_PHASE=load "$GODOT_BIN" --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_w3_progress.gd
```

The second process starts with only Veilbound, loads the first process's file, tests Player death/respawn, proves Debug isolation, then verifies New Game cleanup and removes the test file.

## Manual boundary

There is no formal pickup in W3, so Main gameplay cannot legitimately award the weapon yet. Use `CH3_REWARD_TEST` only to review the accepted W2 visual; it remains deliberately non-persistent. Full Boss-death-to-reliquary acquisition requires W4 approval.
