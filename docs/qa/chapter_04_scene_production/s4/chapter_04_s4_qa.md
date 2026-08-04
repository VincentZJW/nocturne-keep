# Chapter IV S4 Encounter Population QA

## Result

**PASS (automated structure/runtime/Main integration and graphical capture).** Manual feel, fairness and encounter readability remain user acceptance items.

## Exact validation commands

All commands used Godot Engine `4.7.1.stable.official.a13da4feb` at `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot`.

```text
Godot --headless --editor --path . --quit
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_encounter_manifests_s4.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_encounter_runtime_s4.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_main_encounters_s4.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_formal_route_s3.gd
Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_main_route_s3.gd
Godot --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tests/capture_chapter_04_encounters_s4.gd
```

## Actual results

```text
CH4 S4 MANIFESTS | PASS rooms=10 groups=20 enemies=46 elevated=13 harpooners=7 seed=40446
CH4 S4 RUNTIME | PASS groups=2 serialized=true rearms=true reload_deterministic=true
CH4 S4 MAIN ENCOUNTERS | PASS bootstrap=res://scenes/bootstrap/main_bootstrap.tscn rooms=10 groups=20 enemies=46
CH4 S3/S4 FORMAL ROUTE | PASS rooms=17 assets=664 checkpoints=2 encounters=20 enemies=46
CH4 S3 MAIN ROUTE | PASS bootstrap=res://scenes/bootstrap/main_bootstrap.tscn rooms=17 final=CH4_AREA_16
CH4 S4 MAIN CAPTURE | PASS captures=10 path=res://docs/qa/chapter_04_scene_production/s4/main
```

## Saved Main evidence

Ten Main-path captures are under `res://docs/qa/chapter_04_scene_production/s4/main/`, one for every combat room. Representative evidence:

- `01_flooded_intake_encounters_main.png`
- `04_harpoon_gallery_encounters_main.png`
- `08_workshop_encounters_main.png`
- `11_final_lock_encounters_main.png`

The captures show the current Player, HUD, formal S3 environment, Chapter IV replicated enemy art, water/platform placement and the saved S4 population together through the MainBootstrap route.

## Manual acceptance required

1. Traverse every combat room from both west and east.
2. Judge whether the `2 + 2` and `2 + 3` pacing feels fair with current player equipment.
3. Confirm seven Harpooner ledges are readable and attackable without confusing decorative ledges for gameplay platforms.
4. Confirm elevated heavy enemies do not become stuck during actual combat.
5. Confirm checkpoints 06 and 12 remain safe and ordinary-enemy-free.

S4 deliberately does not claim final combat balance or a hard simultaneous-attacker token limit.
