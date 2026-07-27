# Debug Chapter Start Specification

Status: Bootstrap routing implemented and verified

## Central configuration

`/root/DebugRunConfig` is a small Autoload backed by `res://scripts/systems/debug_run_config.gd`. It owns preferences because they must be available before any gameplay scene, but has no `_ready()` side effect and never changes scenes.

Default values:

```text
debug_chapter_start_enabled = false
debug_start_chapter_id = CHAPTER_01_RAVENMOURN_OUTSKIRTS
debug_start_spawn_id = dark_forest_tutorial_spawn
debug_reset_chapter_state_on_run = true
debug_use_test_currency = true
debug_test_currency = 30
debug_start_full_health = true
debug_skip_chapter_intro = false
debug_show_chapter_select = false
```

The shipped project default is `debug_chapter_start_enabled = false`; the block above shows the current selected profile values that become active only after a developer explicitly changes the flag to `true`. Both Chapter I and Chapter II now have valid saved profiles.

## Safety rules

- `is_chapter_start_allowed()` requires both `OS.is_debug_build()` and the enable flag. Release builds therefore ignore the override.
- `ChapterStartRouter.get_debug_target_profile()` requires `ChapterStartProfile.is_valid_debug_target()` before returning a target.
- An invalid target must fall back to the formal flow with a clear diagnostic; it must never load a missing path.
- Debug configuration must not be written into a formal save or mutate authored chapter defaults.
- `project.godot` remains pointed at `res://scenes/bootstrap/main_bootstrap.tscn`. Developers never hand-edit `run/main_scene` between chapters.

## Routing and diagnostics

`MainBootstrap` asks the router for a Debug profile exactly once. A valid target prints:

```text
DEBUG CHAPTER START ACTIVE | <chapter_id> | <scene_path>
```

and loads that PackedScene. Disabled Debug, a release build, or an invalid target follows the formal Opening route. The two routes return separately and cannot both continue. Chapter I/II controllers apply disposable Debug health/currency/spawn state only when `is_chapter_start_allowed()` is true.

To test Chapter II, enable the flag, select `CHAPTER_02_SILENT_COURT`, set `CH2_START`, and press F5. To restore the formal route, disable the flag and press F5; Opening must appear automatically.
