# Chapter II Graybox F5 QA

Date: 2026-07-27 (Phase 1 vertical-graybox refresh)

Engine: Godot 4.7.1 Standard, GL Compatibility, Apple M4 OpenGL/Metal

Configured F5 scene: `res://scenes/bootstrap/main_bootstrap.tscn`

Debug target: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`

## Full traversal

Command:

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . chapters/chapter_02_silent_court/scenes/level/silent_court.tscn -- --recapture-ch2-graybox-fast
```

The QA driver pressed existing Input Map actions, released movement for a one-second rendered inspection in every room, never wrote Player coordinates, and crossed every room seam through `CharacterBody2D` physics. It also triggered Ground Dash, double-jump plus Air Dash, and automatic obstacle jumps. Result:

```text
CH2_GRAYBOX_F5_TRAVERSAL: PASS duration=146.02s screenshots=9
```

Logged final capture X coordinates were `1167.72, 4620.52, 9231.00, 13582.78, 17549.56, 21134.53, 23821.88, 26190.47, 29837.60`, each inside its intended room. Earlier attempts found and rejected two vertical-face blockers; the retained screenshots come only from the final successful traversal.

## Screenshot evidence

| Room | Screenshot | SHA-256 |
| --- | --- | --- |
| Castle Gate Interior | `res://docs/qa/chapter_02_graybox/room_01_castle_gate_interior_f5.png` | `31ed6d32957d5a0b7f4dc604d673f8fca62d981a4cd98d538c1292338af2c737` |
| Grey Banner Corridor | `res://docs/qa/chapter_02_graybox/room_02_grey_banner_corridor_f5.png` | `430b44e4efb6239fb6cf680c0a2ce671d5f51535fc031e5dec153dc0d2d5f559` |
| Last Banquet Hall | `res://docs/qa/chapter_02_graybox/room_03_last_banquet_hall_f5.png` | `71aad3628bb3a93510dc5f6ca695760002a9080be5661fbbd3be649e041fe944` |
| Royal Portrait Gallery | `res://docs/qa/chapter_02_graybox/room_04_royal_portrait_gallery_f5.png` | `a8da1063be2b48e2436243c8462266a41ae59bd38c323291cf856480c9b189ff` |
| Blood Candle Chapel | `res://docs/qa/chapter_02_graybox/room_05_blood_candle_chapel_f5.png` | `b9ca1c3cc0bffc05333b130ca347319aa051e41ec12e2c9e0fa6cd4e64709f4a` |
| Servant Passage | `res://docs/qa/chapter_02_graybox/room_06_servant_passage_f5.png` | `067d170f57ddf9f4e296d5f5b0add038da22fe00ed0cbef74234562d4eb7b2bf` |
| Old Armory Safe Room | `res://docs/qa/chapter_02_graybox/room_07_old_armory_safe_room_f5.png` | `83722f0acb8d3f00787b5399c56f4bb4596bff15865a56174e512d9ab4eb7be6` |
| Silent Ballroom Antechamber | `res://docs/qa/chapter_02_graybox/room_08_silent_ballroom_antechamber_f5.png` | `d8692bea272addfc101e369ab5523ce4314a7e8d901509ee193b18135130e56f` |
| Silent Ballroom | `res://docs/qa/chapter_02_graybox/room_09_silent_ballroom_f5.png` | `960b5c7acbe6651317df1dcd4b47ea9a4818b0bd92dad9a9cd3d1dccf22283ef` |

## Runtime and regression evidence

- Chapter contract: PASS — seven registry entries, Chapter II ready, Opening preserved.
- Silent Court contract: PASS — nine rooms, six spawns, fifteen encounters, one Player, one HUD.
- Player metrics: PASS — jump/double jump, ground/air Dash movement envelopes remain unchanged.
- Formal Opening → Catacomb → Main transition: PASS after narrowing the router to bypass `--script` test processes.
- Full deterministic suite: `47` tests, `0` failures.
- Both graphical traversals exited `0`; no `SCRIPT ERROR`, `ERROR`, debugger-red diagnostic or resource error was emitted.

## Manual follow-up

The evidence proves saved layout, direct F5 routing, continuous basic traversal, camera switching and HUD/profile state. Final platform-edge comfort, Chapel vertical jumping, optional branch feel and door/checkpoint interaction remain manual acceptance for this and the next stage.
