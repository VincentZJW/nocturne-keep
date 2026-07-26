# Debug Chapter Start Specification

Status: Stage 2A configuration complete; Stage 2B routing not implemented

## Central configuration

`/root/DebugRunConfig` is a small Autoload backed by `res://scripts/systems/debug_run_config.gd`. It owns preferences because they must be available before any gameplay scene, but has no `_ready()` side effect and never changes scenes.

Default values:

```text
debug_chapter_start_enabled = true
debug_start_chapter_id = CHAPTER_02_SILENT_COURT
debug_start_spawn_id = chapter_02_cp01
debug_reset_chapter_state_on_run = true
debug_use_test_currency = true
debug_test_currency = 30
debug_start_full_health = true
debug_skip_chapter_intro = false
debug_show_chapter_select = false
```

The default selection is intentionally Chapter II, but Stage 2A does not consume it. Chapter II remains `debug_ready = false` until its real scene and legal start profile exist.

## Safety rules

- `is_chapter_start_allowed()` requires both `OS.is_debug_build()` and the enable flag. Release builds therefore ignore the override.
- A future router must also require `ChapterStartProfile.is_valid_debug_target()` before changing scenes.
- An invalid target must fall back to the formal flow with a clear diagnostic; it must never load a missing path.
- Debug configuration must not be written into a formal save or mutate authored chapter defaults.
- `project.godot` remains pointed at the Opening. Developers stop hand-editing `run/main_scene` between chapters.

## Stage boundary

Stage 2B will add the sole routing authority and fallback behavior. Stage 2C will create the real Chapter II start profile and initialization bridge. Stage 2D will prove direct F5 entry with QA evidence. None of those behaviors are present in Stage 2A.
