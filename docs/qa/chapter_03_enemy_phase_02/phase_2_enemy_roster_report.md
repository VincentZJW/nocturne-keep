# Chapter III Phase 2 Enemy Roster QA

Date: 2026-07-28

Engine: Godot 4.7.1 Standard (`4.7.1.stable.official.a13da4feb`)

F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`

Chapter III target: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn`

## Delivered roster

| Enemy | Saved scene | HP / Poise | Runtime frame count |
|---|---|---:|---:|
| Bellchain Penitent | `scenes/enemies/bellchain_penitent.tscn` | 70 / 32 | 70 |
| Censer Executioner | `scenes/enemies/censer_executioner.tscn` | 126 / 82 | included below |
| Silent Chorister | `scenes/enemies/silent_chorister.tscn` | 84 / 36 | included below |
| Stained-Glass Seraph | `scenes/enemies/stained_glass_seraph.tscn` | 76 / 30 | included below |
| Confessional Wraith | `scenes/enemies/confessional_wraith.tscn` | 82 / 38 | included below |
| Thirteenth Scribe | `scenes/enemies/thirteenth_scribe.tscn` | 98 / 46 | included below |

The five Phase 2B–2F roles contain 345 original transparent 64×64 frames; the complete six-enemy runtime roster contains 415. Every saved Sprite uses nearest filtering. All art was generated locally by the repository's Godot Image tooling; no downloaded or provenance-unknown asset was used.

## Commands and actual results

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script .../generate_phase_2b_2f_enemy_assets.gd
CH3 PHASE2B-2F ASSETS | PASS roles=5 frames=345

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script .../build_phase_2b_2f_sprite_frames.gd
CH3 PHASE2B-2F SPRITEFRAMES | PASS roles=5 frames=345

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script .../build_phase_2b_2f_enemy_scenes.gd
CH3 PHASE2B-2F SCENES | PASS roles=5

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . -s chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_phase_2_enemy_roster.gd
CH3_PHASE2_ROSTER_TEST: PASS roles=6 remaining_frames=345 main=6 combination_room=1

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . -s tests/combat/test_hitbox_hurtbox_components.gd
HITBOX_HURTBOX_TEST: PASS

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . -s tests/player/test_chain_dash_stamina.gd
CHAIN_DASH_STAMINA_TEST: PASS
```

Both `chapter_03_enemy_combination_test_room.tscn` and the Chapter III Main acceptance scene completed 600-frame headless smokes without script/resource errors. The graphical capture ran through MainBootstrap's legal Debug Chapter Start and printed:

```text
DEBUG CHAPTER START ACTIVE ...
CH3_PHASE2_MAIN_QA: PASS captures=5 route=MainBootstrap main=res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn
```

The ordered regression run executed 62 deterministic scripts. Sixty-one passed on the first run; the Player death-presentation timing test produced one early-completion failure under the long sequential load, then passed independently three consecutive times. An isolated untouched `HEAD` also passes that test. Nine older Chapter II/Main tests print shutdown-only leak diagnostics while returning PASS; `test_chapter_02_floor_transitions.gd` reproduces the identical 47 ObjectDB / 30 Resource / 2 Shape / 4 texture diagnostics in an isolated `git archive HEAD`, establishing pre-existing test-cleanup debt rather than a Phase 2 regression.

## Main screenshot evidence

| Capture | Size | Bytes | SHA-256 |
|---|---:|---:|---|
| `01_censer_executioner_overhead_main.png` | 1280×720 | 18,915 | `a5402b9233b2be3144f9f9677b1a1544a0d42f29032a4b2618d95be26a857550` |
| `02_silent_chorister_hymn_main.png` | 1280×720 | 18,894 | `47fb5e4f23dd429809405b94a23e52043d3d3eaf348cc0874506afb0b53407c5` |
| `03_stained_glass_seraph_dive_main.png` | 1280×720 | 18,590 | `fa01a6799894c000af56c785f287369ebe40f8cda22a81b1d3e03082280b5a7d` |
| `04_confessional_wraith_dash_main.png` | 1280×720 | 24,275 | `57eae875e0ad86d1ed23c2f50a0d9f659e1c6a3b099ff59b3c48bacf7690f24c` |
| `05_thirteenth_scribe_seal_main.png` | 1280×720 | 29,617 | `ac4718b6514c74ae2a5b235e7c0ce6569be5fa770fb33781fa68293e0476edd0` |

Bellchain Penitent retains its separately committed Phase 2A QA evidence. These five images were visually inspected and show distinct silhouettes/action cues in the actual Main-routed scene, not a mockup or concept board.

## Manual acceptance still required

- Confirm Executioner smoke boundaries/ticks remain readable while another enemy is active.
- Confirm Chorister wave gaps and Hush target priority feel fair.
- Confirm Seraph hover/dive height is reachable with the current traversal kit.
- Confirm Wraith booth reveal is visible before its first damaging frame.
- Confirm Scribe Seal warning, Binding slow and Paper Ward response are immediately understandable.
- Confirm combination pressure does not erase all safe routes.

The Chapter III entry is an enemy acceptance prototype. Passing this report does not claim completion of the formal chapel map, planned 44-enemy population, Phase 3 Trial Hall, Phase 4 twenty-kill balance sample, Boss, audio or final VFX.
