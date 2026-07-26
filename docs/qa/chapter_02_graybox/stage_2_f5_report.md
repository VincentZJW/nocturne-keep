# Chapter II Stage 2 F5 QA

Date: 2026-07-26

Engine: Godot 4.7.1 Standard, GL Compatibility, Apple M4 OpenGL/Metal

Configured F5 scene: `res://scenes/cinematics/opening_cinematic.tscn`

Debug target: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`

## Full traversal

Command:

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . -- --capture-ch2-graybox
```

The QA driver pressed existing Input Map actions, released movement for a 25-second visual inspection in every room, never wrote Player coordinates, and crossed every room seam through `CharacterBody2D` physics. It also triggered Ground Dash at X=1805.06, double-jump plus Air Dash at X=7252.83/Y=504.55, and ordinary jumps to traverse solid banquet tables and the Chapel altar. Result:

```text
CH2_GRAYBOX_F5_TRAVERSAL: PASS duration=362.05s screenshots=9
```

A one-second-stop final-geometry preflight completed in `146.09s`. The final 25-second-stop run then replaced all screenshots through forced renderer readback. Logged final capture X coordinates were `1167.90, 4621.09, 9231.74, 13582.62, 17550.33, 21134.79, 23821.05, 26189.91, 29838.21`, each inside its intended room.

## Screenshot evidence

| Room | Screenshot | SHA-256 |
| --- | --- | --- |
| Castle Gate Interior | `res://docs/qa/chapter_02_graybox/room_01_castle_gate_interior_f5.png` | `fb35750f69d5125f0d7673099a3f4c751d4f58d3079a7794e40de13b679b0664` |
| Grey Banner Corridor | `res://docs/qa/chapter_02_graybox/room_02_grey_banner_corridor_f5.png` | `ca9f19c01cbb61c4bb6e6dab2cf7320c8c8e46727c9d3fbbcaef5abb31d41e73` |
| Last Banquet Hall | `res://docs/qa/chapter_02_graybox/room_03_last_banquet_hall_f5.png` | `aab770ac746b3ffe32decfd0cfa60be174d94c1cdc7b09270d06b2686ce0eaf5` |
| Royal Portrait Gallery | `res://docs/qa/chapter_02_graybox/room_04_royal_portrait_gallery_f5.png` | `051fee583f1d27f15b032c011b327c4330595aebfa2005bc0d88ea6938171f1f` |
| Blood Candle Chapel | `res://docs/qa/chapter_02_graybox/room_05_blood_candle_chapel_f5.png` | `de83e1abb2bdf1ec7107e73565bcdea19efc9101b13c3a363717f9bddb232962` |
| Servant Passage | `res://docs/qa/chapter_02_graybox/room_06_servant_passage_f5.png` | `8100d8aad4194f6b07b22f72a350ae4eec48326353d9ac678a1372a03a87af58` |
| Old Armory Safe Room | `res://docs/qa/chapter_02_graybox/room_07_old_armory_safe_room_f5.png` | `040fbcd791db5010751d2585d096b282083596d60ade55ed651becd85b0cac10` |
| Silent Ballroom Antechamber | `res://docs/qa/chapter_02_graybox/room_08_silent_ballroom_antechamber_f5.png` | `637f5953cde30fbd766a0dec6de62ec903bfdd8f66032a2740f40b2901ad0a24` |
| Silent Ballroom | `res://docs/qa/chapter_02_graybox/room_09_silent_ballroom_f5.png` | `09591c49544dfbad20b12c6024fdbe96e9f6ad25c5c1dcde7429edd169982cfe` |

## Runtime and regression evidence

- Chapter contract: PASS — seven registry entries, Chapter II ready, Opening preserved.
- Silent Court contract: PASS — nine rooms, six spawns, fifteen encounters, one Player, one HUD.
- Player metrics: PASS — jump/double jump, ground/air Dash movement envelopes remain unchanged.
- Formal Opening → Catacomb → Main transition: PASS after narrowing the router to bypass `--script` test processes.
- Full deterministic suite: `45` tests, `0` failures.
- Both graphical traversals exited `0`; no `SCRIPT ERROR`, `ERROR`, debugger-red diagnostic or resource error was emitted.

## Manual follow-up

The evidence proves saved layout, direct F5 routing, continuous basic traversal, camera switching and HUD/profile state. Final platform-edge comfort, Chapel vertical jumping, optional branch feel and door/checkpoint interaction remain manual acceptance for this and the next stage.
