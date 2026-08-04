# Chapter IV S5 Room Transition and Performance Contract

## Scope

S5 hardens the existing 17-room formal route without changing its 0.18 s fade-out or 0.18 s fade-in, room art, collision, encounter balance, Player tuning, Boss flow or Chapter V handoff.

## Runtime lifecycle

1. `request_room_change()` rejects duplicate/concurrent requests, locks Player input and immediately starts loading the destination `PackedScene` on one owned worker `Thread`.
2. The existing fade-out runs while the worker loads. Only after the screen is opaque does the main thread join the worker and instantiate the destination.
3. The destination room is added with processing disabled. Its spawn contract is validated and its Encounter activation monitoring is suspended before the outgoing room is disabled, detached and queued for deletion.
4. Persistent `Player`, HUD, Camera2D and respawn services remain under `ChapterRuntime`; they are never reinstantiated. Player position, respawn anchor, Camera bounds and room label are updated on the main thread.
5. The destination begins processing under full opacity. Fade-in completes before Encounter activation resumes and Player input unlocks, preventing encounters from activating at the old-room coordinate beneath the transition.
6. The controller owns and explicitly joins its single loader thread on completion or `_exit_tree()`. At most one prepared room is retained after a successful transition.

The loader callback performs `ResourceLoader.load()` only. It never touches the SceneTree, nodes, transforms, physics, HUD or Camera from the worker thread.

## Fixed timing and budgets

- Fade-out: 0.18 s (unchanged)
- Fade-in: 0.18 s (unchanged)
- Post-fade resource wait budget: less than 400 ms in the automated worst-case guard
- Total transition guard: less than 1.0 s
- Active room instances after every transition: exactly 1

The 400 ms resource guard is a regression alarm, not a desired stall. The measured post-fade peak on the final 32-transition fresh-process run was 13.021 ms.

## Reproducible measurements

Exact Godot build: `4.7.1.stable.official.a13da4feb`, Apple M4 host.

Cold synchronous baseline (17 unique room paths, `CACHE_MODE_IGNORE`, fresh headless process):

```text
rooms=17
load_total_us=530167
load_peak_us=101886
instantiate_total_us=1814
instantiate_peak_us=173
```

Formal MainBootstrap transition route (16 rooms forward and 16 backward, fresh headless process):

```text
transitions=32
peak_total_us=380968
peak_post_fade_resource_wait_us=13021
peak_instantiate_us=944
room_instances=1
```

These measurements intentionally report different questions: the baseline measures cold synchronous loading cost for all rooms, while the route test measures the visible transition's residual wait after loading overlaps fade-out. They must not be interpreted as a single synthetic percentage speedup.

## Persistent and release contracts

- Player instance ID remains unchanged.
- HUD instance ID remains unchanged.
- Camera bounds match each destination room.
- Every outgoing room is released (verified with `WeakRef`).
- Destination spawn is exact.
- No dormant EncounterGroup activates during the fade.
- No hidden room continues process/physics; only the current room remains under `RoomHost`.
- Failed destination validation leaves the previous room intact and restores the previous Player input profile.

## Manual F5 acceptance

Start Chapter IV through the saved MainBootstrap debug profile, traverse any east/west room boundary repeatedly, and verify: fade length does not grow, Player/HUD remain stable, Camera snaps to the new room bounds without exposing another room, no encounter begins before fade-in ends, and returning to a prior room does not duplicate enemies or room nodes.
