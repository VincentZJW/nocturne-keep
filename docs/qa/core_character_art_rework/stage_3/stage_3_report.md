# Core Character Art Rework — Stage 3 Evidence

Date: 2026-07-28
Scope: The Candle Warden concept, runtime pixel acting, soul lantern, dialogue choreography and formal Prologue/Main integration.

## Result

Stage 3 implementation is complete. The old `_draw()` geometry NPC has been replaced by one typed `AnimatedSprite2D` presentation scene with 65 body frames, a separate six-frame soul flame, a restrained local light, soul motes, explicit gestures and camera choreography. Stage 4 strong QA has not been started or claimed.

## Evidence index

- Concept turnaround master: `concept_art/candle_warden_turnaround_master.png`
- Gesture/cinematic master: `concept_art/candle_warden_gesture_cinematic_master.png`
- Runtime contact sheet: `candle_warden_stage_3_contact_sheet.png`
- Entrance: `01_main_prologue_warden_rising.png`
- Lantern idle: `02_main_prologue_lantern_idle.png`
- Important-line emphasis: `03_main_prologue_talk_emphasis.png`
- Point gesture: `04_main_prologue_point.png`
- Warning gesture: `05_main_prologue_warn.png`
- Key offer: `06_main_prologue_offer_key.png`
- Door action: `07_main_prologue_open_door.png`
- Raised soul lantern: `08_main_prologue_soul_lantern.png`

All eight runtime images were captured from `res://scenes/levels/veilbound_catacomb.tscn`, the formal scene loaded by `MainBootstrap → OpeningCinematic`, at 1280×720 using the GL Compatibility renderer. They were visually inspected for mask, robe, hands, key, lantern, gesture, layering, dialogue readability and nearest-neighbour edges.

## Commands and actual outcomes

```text
Godot --headless --editor --path . --quit
PASS — import and script-class registration; no parse/resource errors.

Godot --headless --path . --script res://tests/narrative/test_candle_warden_stage_3.gd
PASS — 10 concept crops, 65 body frames, lantern FX, visual scale, acting cues, one formal Prologue instance.

Godot --headless --path . --script res://tests/level/test_veilbound_catacomb_flow.gd
PASS — F5 route, bilingual sequence, skip, daggers, door and Chapter I arrival.

Godot --headless --path . --script res://tests/level/test_veilbound_scene_transitions.gd
PASS — Opening skip, Catacomb skip and Chapter I tutorial transition.

Godot --headless --path . --script res://tests/systems/test_main_bootstrap_flow.gd
PASS — formal Opening route and Debug Chapter II route. Existing teardown reports two anonymous RefCounted ObjectDB leak warnings; verbose mode identifies no Warden node/resource and no Stage 3 functional error.

Godot --headless --path . --scene res://scenes/npcs/candle_warden.tscn --quit-after 120
PASS — independent Warden scene smoke.

Godot --path . --script res://scripts/tools/capture_candle_warden_stage_3_main_qa.gd
PASS — 8 formal Prologue captures.

Godot --path . --quit-after 900
PASS — F5 authority starts formal new game at OpeningCinematic; no red errors before controlled exit.
```

## Visual review notes

- The split mask and deep hood remain readable against the catacomb masonry.
- Lantern cage, cold-blue flame and key hand remain distinct; no line-placeholder lantern is visible.
- Point, warning, emphasis and offer-key silhouettes are different at gameplay scale.
- The lantern remains in front of the body, its flame reads within the cage, and dialogue remains above world presentation.
- The Warden is taller than the Player but not boss-sized; automated alpha bounds enforce the 105–120% ratio.
- No hostile posture, combat component, AI, or duplicate NPC was introduced.

## Known item carried into Stage 4

The existing `test_main_bootstrap_flow.gd` teardown emits two anonymous `RefCounted` leak warnings after its Chapter II threaded-load coverage. The focused Stage 3 test, formal Prologue flow test, independent scene smoke, capture run and F5 run exit cleanly. Stage 4 should still repeat debugger inspection and visual acceptance rather than treating this Stage 3 implementation report as final art approval.
