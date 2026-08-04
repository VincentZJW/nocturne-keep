# Chapter IV S5 Transition and Performance QA

## Result

**PASS.** Threaded destination loading overlaps the unchanged fade, room replacement is atomic, persistent runtime nodes survive all transitions, old rooms are released, Encounter activation is gated until fade-in completes, and focused runs emit no parser/resource/gameplay errors or ObjectDB leak warnings.

## Exact validation commands

All commands used `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot`, Godot Engine `4.7.1.stable.official.a13da4feb`.

```text
Godot --headless --editor --path . --import --quit-after 2
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/profile_chapter_04_sync_load_s5.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_transitions_s5.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_encounter_manifests_s4.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_encounter_runtime_s4.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_main_encounters_s4.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_formal_route_s3.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_main_route_s3.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_enemy_runtime.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_main_integration.gd
Godot --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tests/capture_chapter_04_transitions_s5.gd
git diff --check
```

## Actual measurements and results

```text
CH4 S5 SYNC BASELINE | PASS rooms=17 load_total_us=530167 load_peak_us=101886 instantiate_total_us=1814 instantiate_peak_us=173
CH4 S5 TRANSITIONS | PASS transitions=32 peak_total_us=380968 peak_wait_us=13021 peak_instantiate_us=944 room_instances=1
CH4 S4 MANIFESTS | PASS rooms=10 groups=20 enemies=46 elevated=13 harpooners=7 seed=40446
CH4 S4 RUNTIME | PASS groups=2 serialized=true rearms=true reload_deterministic=true
CH4 S4 MAIN ENCOUNTERS | PASS bootstrap=res://scenes/bootstrap/main_bootstrap.tscn rooms=10 groups=20 enemies=46
CH4 S3/S4 FORMAL ROUTE | PASS rooms=17 assets=664 checkpoints=2 encounters=20 enemies=46
CH4 S3 MAIN ROUTE | PASS bootstrap=res://scenes/bootstrap/main_bootstrap.tscn rooms=17 final=CH4_AREA_16
CH4 ENEMY RUNTIME TEST | PASS
CH4 MAIN INTEGRATION TEST | PASS
CH4 S5 MAIN CAPTURE | PASS captures=3 room=CH4_AREA_04 wait_us=29 instantiate_us=185 transition_us=342770
```

## Main visual evidence

Saved under `res://docs/qa/chapter_04_scene_production/s5/main/`:

- `01_area03_before_transition_main.png`: formal Area 03 with Player/HUD immediately before the transition.
- `02_fade_covers_atomic_swap_main.png`: opaque transition frame proving the room swap is hidden by the existing fade.
- `03_area04_after_transition_main.png`: formal Area 04 after the transition with persistent Player/HUD and current enemies.

## Automated contract coverage

- 32 real `request_room_change()` operations across every room forward and backward.
- Exactly one `RoomHost` child after every swap.
- Every outgoing room `WeakRef` released.
- Persistent Player and HUD instance IDs unchanged.
- Destination spawn and Camera bounds correct.
- Destination encounters dormant beneath fade.
- Loader thread explicitly joined; focused test exits without ObjectDB leak warning.

## Manual acceptance required

1. Traverse the complete Chapter IV route on the target display and judge whether the fixed 0.36 s visual fade still feels appropriately paced.
2. Reverse direction repeatedly at several doors and confirm there is no perceptible camera flash or stale-room frame.
3. Enter Areas 01–05 from both sides and confirm encounters begin only after the new room is visible.
4. Verify controller/device-specific input remains locked only during the fade.
