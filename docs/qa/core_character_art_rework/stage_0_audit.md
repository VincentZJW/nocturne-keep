# Core Character Art Rework — Stage 0 Audit

Date: 2026-07-28

Engine: Godot Engine 4.7.1 Standard (`a13da4feb`)

Scope: read-only runtime/resource audit; no character art or scene presentation was replaced

## 1. Project entry and chapter routes

| Item | Actual runtime value |
| --- | --- |
| `run/main_scene` | `res://scenes/bootstrap/main_bootstrap.tscn` |
| Bootstrap script | `res://scripts/core/main_bootstrap.gd` |
| Formal new-game target | `res://scenes/cinematics/opening_cinematic.tscn` |
| Opening-to-revival target | `res://scenes/levels/veilbound_catacomb.tscn` |
| Debug config | `res://scripts/systems/debug_run_config.gd` (`DebugRunConfig` Autoload) |
| Prologue profile authority | Constructed in `res://scripts/systems/chapter/chapter_registry.gd` |
| Prologue default/available spawns | `opening_start`; `opening_start`, `veilbound_catacomb_altar` |
| Chapter I profile | `res://chapters/chapter_01_ravenmourn_outskirts/resources/chapter/chapter_01_start_profile.tres` |
| Chapter II profile | `res://chapters/chapter_02_silent_court/resources/chapter/chapter_02_start_profile.tres` |

The requested shorthand `PROLOGUE_WAKE_SCENE` is not an implemented spawn id. The current direct prologue debug entry is `veilbound_catacomb_altar`, while the formal route always begins at `opening_start` and transitions from the cinematic to the catacomb.

## 2. Player runtime authority

### Paths and composition

| Item | Actual path/value |
| --- | --- |
| Formal Player scene | `res://scenes/player/player.tscn` |
| Main gameplay script | `res://scripts/player/player.gd` |
| Locomotion state authority | Embedded typed enum/FSM in `player.gd`; no separate locomotion StateMachine node |
| Action state authority | `res://scripts/player/player_action_controller.gd` at `Player/ActionController` |
| Animation authority | `res://scripts/player/player_animation_controller.gd` at `Player/AnimationController` |
| Visual node | `Player/VisualRoot/AnimatedSprite2D` |
| AnimationPlayer | None |
| Base SpriteFrames | `res://resources/player/player_sprite_frames.tres` |
| Weapon visual controller | `Player/VisualRoot/WeaponVisual`, script `res://scripts/player/player_weapon_visual.gd` |
| Body collision | Rectangle `24×52`, shape offset `(0, 2)` |
| Hurtbox | Rectangle `22×50`, shape offset `(0, 2)` |
| Normal Attack Hitbox | Rectangle `42×14`; Area offset `(29, -3)` |
| Dash Attack Hitbox | Rectangle `58×16`; Area offset `(37, -3)` |
| Camera | `Player/Camera2D`, position `(0, -105)`, smoothing speed `7.0` |

`WeaponVisual` is not a hand-mounted weapon Sprite. It atomically swaps the entire Player `SpriteFrames` resource so the character and weapon are baked together in every frame. Stage 1 must account for this before describing the current node as a weapon mount.

### Current production animation inventory

All three equipped-weapon frame sets expose the same 16 animation names and metadata:

| Animation | Frames | FPS | Loop |
| --- | ---: | ---: | :---: |
| `idle` | 4 | 5 | Yes |
| `run` | 6 | 10 | Yes |
| `jump_start` | 2 | 12 | No |
| `jump_loop` | 2 | 4 | Yes |
| `fall` | 2 | 4 | Yes |
| `land` | 2 | 12 | No |
| `dash_start` | 2 | 20 | No |
| `dash_loop` | 3 | 20 | Yes |
| `dash_end` | 2 | 20 | No |
| `air_dash_start` | 2 | 20 | No |
| `air_dash_loop` | 3 | 20 | Yes |
| `air_dash_end` | 2 | 20 | No |
| `attack` | 4 | 20 | No |
| `dash_attack` | 5 | 20 | No |
| `hurt` | 3 | 16 | No |
| `death` | 5 | 11.111 | No |

There are currently no runtime animations named `ready_idle`, `walk`, `turn`, `start_move`, `stop_move`, `jump_rise`, `jump_apex`, `double_jump`, `attack_1`, `attack_2`, `attack_3`, `combo_transition`, `interact`, or `respawn`. The existing repeated normal attack replays the same four-frame `attack`; it is not three distinct visual attacks.

### Visual size, origin, and Chapter I comparison

The audit measured imported alpha bounds, not nominal canvas size:

- Player idle union: `(11, 6)` through source row `60`, `53×55` visible bounds.
- Chapter I Cursed Castle Guard idle union: `(16, 3)` through source row `60`, `41×58` visible bounds.
- Current ratio: `55 / 58 = 0.9483` (`94.83%`).
- Both use centered `64×64` textures with a visible foot baseline at source row `y=60`; at the centered Sprite origin this is approximately local `y=+28`.
- The result is 0.17 percentage points below the new 95% minimum. No formal Player or `VisualRoot` scale override was found, so the correction belongs in redrawn source frames rather than node scaling.

### Current art and weapon variants

| Variant | SpriteFrames | Source frames | Weapon data/icon |
| --- | --- | --- | --- |
| 暮帷双匕 / Veilbound | `res://resources/player/player_sprite_frames.tres` | `res://assets/sprites/player/assassin/` | `res://resources/items/weapons/veilbound_daggers.tres`; `res://assets/ui/items/veilbound_daggers.png` |
| 鸦牙双匕 / Ravenfang | `res://resources/player/ravenfang_player_sprite_frames.tres` | `res://assets/sprites/player/ravenfang/` | `res://resources/items/weapons/ravenfang_daggers.tres`; `res://assets/ui/items/ravenfang_daggers.png` |
| 绯幕礼刺 / Crimson Masque | `res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_player_sprite_frames.tres` | `res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos/sprites/player/` | `res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_stilettos.tres` and its chapter-local icons |

Current concept/reference art exists under `res://assets/sprites/player/concept_c/` plus `res://docs/design/hooded_assassin_character_board.png`. It is an earlier limited-palette design board, not the requested full production character turnaround. Historical superseded frames are already separated under `res://assets/sprites/player/assassin/reference/` and `placeholder/`; no deprecated path is referenced by the active SpriteFrames resources.

### Death, Hurt, respawn, and HUD dependencies

- Base body fall and baked dagger-drop frames: `res://assets/sprites/player/assassin/death/death_01.png` through `death_05.png`.
- Ghost: `res://assets/sprites/player/assassin/death/ghost_hooded_face.png`, shown at `Player/VisualRoot/DeathEffects/GhostSprite` by `res://scripts/player/player_death_sequence.gd`.
- Ravenfang and Crimson Masque each have matching weapon-specific death frames in their own full-frame sets.
- Hurt uses three formal frames per weapon set and `res://scripts/player/player_hurt_controller.gd` for flash, knockback, camera shake, stun, and invulnerability.
- Respawn has no dedicated character animation: `PlayerRespawnController` waits for the death/ghost sequence, restores state, and the animation controller resets to `idle`.
- The prologue awakening body is a separate custom-drawn `RevivalPlayerArt`, not the gameplay SpriteFrames.
- No HUD Player portrait/avatar dependency was found. `RunInventoryHud` displays only the equipped weapon's `hud_icon`/`icon`.

### Formal chapter instancing

- Prologue catacomb: direct instance at `VeilboundCatacomb/World/Player` from `res://scenes/player/player.tscn`.
- Chapter I: direct instance at `RavenmournOutskirts/World/Player` from the same scene.
- Chapter II: shared `res://scenes/runtime/chapter_gameplay_runtime.tscn`, at `SilentCourt/GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player`; the runtime itself instances the same Player scene.
- Chapter III uses the same `ChapterRuntime` pattern.
- Only one formal Player PackedScene exists. `res://scenes/tools/player_animation_preview.tscn` is a tool visualization, not a second gameplay Player.
- Formal scenes override placement, z-index, or camera limits where needed; no formal Player/VisualRoot scale override or old SpriteFrames override was found.

## 3. Candle Warden runtime authority

| Item | Actual implementation |
| --- | --- |
| Formal scene | `res://scenes/npcs/candle_warden.tscn` |
| Formal script | `res://scripts/npcs/candle_warden.gd` |
| Prologue node | `VeilboundCatacomb/World/CandleWarden` |
| Sprite/Sprite2D | None |
| SpriteFrames | None |
| AnimationPlayer | None |
| Concept art | None found |
| Lantern/flame asset | None; generated in `_draw()` |
| Light/particles | No `PointLight2D`, `CanvasModulate`, `GPUParticles2D`, or `CPUParticles2D` |
| Layer | Catacomb instance `z_index=10`; Player also `z_index=10`; front architecture `z_index=5` |

The current Warden is one custom-drawn `Node2D`. Robe, hood, face slit, key, arm, cage lantern, flame, and fake glow are constructed from `draw_rect`, `draw_line`, `draw_circle`, and a few polygons every frame. It therefore has no reusable pixel source art and reads as the geometric placeholder style prohibited by the new brief.

Declared presentation states are `SEATED`, `RISING`, `IDLE`, `WALK`, `RAISE_LANTERN`, `TALK`, and `TURN_AWAY`. Actual visual differentiation is limited:

- `SEATED`: vertical offset.
- `IDLE`/`TALK`: identical body with a one-pixel-style sinusoidal bob.
- `RAISE_LANTERN`: lantern hand/lantern moves upward.
- `TURN_AWAY`: only becomes distinct because the catacomb controller sets `facing_left=false`.
- `RISING` and `WALK`: no unique body pose or frame sequence.

The Warden is hidden at startup, becomes visible after the Player monologue, receives `RISING`, is changed to `WALK` while a Tween moves x from `840` to `760` over `1.1s`, then enters `IDLE`. Dialogue cues drive `TALK`, `RAISE_LANTERN`, and `TURN_AWAY`. The Warden later raises the lantern for the stone door. There is no authored farewell/departure animation; the Warden remains at x `760` after the revival completes.

Dialogue is data-driven through four `CatacombDialogue` resources and `CatacombDialogueUI`: 3 aligned Player monologue entries plus 27 aligned Warden/Player exchanges, for 30 bilingual entries. The scene controller validates track alignment before starting.

The only camera is the reused Player `Camera2D` with catacomb limits. The revival controller does not pan, frame, zoom, or Tween the camera toward the Warden. The translucent blue circles drawn around the lantern are not real scene lighting.

## 4. Prologue presentation chain

Formal F5 route:

`MainBootstrap` → `opening_cinematic.tscn` → `veilbound_catacomb.tscn` → `ravenmourn_outskirts.tscn`

The catacomb scene uses two different Player presentations:

1. `VeilboundCatacomb/World/Player/RevivalPlayerArt`, a custom-drawn story body for corpse, twitch, breath, sit-up, hands, kneel, stand, and unarmed states.
2. `VeilboundCatacomb/World/Player/VisualRoot/AnimatedSprite2D`, revealed only after the dagger pickup.

This split is functionally explicit but visually risky: Stage 1 must redesign both sources against one approved body model or the awakening will visibly change proportions at weapon pickup.

## 5. Stage 0 defect and risk register

1. **Player production art remains generated block art.** It is functionally complete but lacks the costume, anatomy, hand, material, and weapon detail demanded by the new brief.
2. **Player ratio narrowly misses the new target.** Current idle is `94.83%` of the Chapter I swordsman reference.
3. **Player presentation is fragmented across three baked full-frame weapon sets.** Every Player frame revision must remain synchronized across Veilbound, Ravenfang, and Crimson Masque or equipment swaps will change anatomy.
4. **No true weapon mount exists.** A Stage 1 mount/layer decision is required before claiming weapon-hand alignment is modular.
5. **Requested movement/combat presentation names exceed the runtime contract.** New names must be integrated without changing established input, attack timing, damage windows, or movement feel.
6. **Prologue revival art is a second geometric Player renderer.** It must be brought into the same approved design during Player rework.
7. **Candle Warden is entirely procedural geometry.** There is no concept, SpriteFrames, AnimationPlayer, formal light, particle, or unique walk/rise/talk animation.
8. **Candle Warden has no exit performance.** The current scene stops at the door-opening support pose.
9. **Prologue has no camera choreography for the Warden.** Composition is whatever the fixed Player camera sees.
10. **Start-id mismatch.** `PROLOGUE_WAKE_SCENE` is not a registered id; the actual direct target is `veilbound_catacomb_altar`.
11. **Existing test cleanup warnings.** `test_main_bootstrap_flow.gd` and `test_silent_court_graybox.gd` each report two leaked ObjectDB instances at process exit. They exit successfully and produce no red runtime error, but the warnings remain technical debt.

## 6. Verification evidence

Commands run with the exact Godot 4.7.1 executable:

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://scripts/tools/audit_core_character_assets.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/tools/validate_player_animation_assets.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/level/test_veilbound_catacomb_flow.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/systems/test_main_bootstrap_flow.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/systems/test_chapter_start_foundation.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_01_ravenmourn_outskirts/tests/level/test_chapter_one_flow.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_02_silent_court/tests/test_silent_court_graybox.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --quit-after 300
```

Results:

- Exact import/editor reopen: PASS; no Missing Resource, Invalid UID, parser error, or red error.
- Core character audit: PASS; all four SpriteFrames resources and all three formal character scenes loaded.
- Player asset validation: PASS, 38 active frames, ghost, and four byte-identical references.
- Prologue flow: PASS, F5 route, 30 bilingual entries, skip, daggers, door, and Main spawn.
- Main Bootstrap flow: PASS, formal Opening plus debug Chapter II route.
- Chapter start foundation: PASS, seven registry entries.
- Chapter I flow: PASS, one formal Player route and current Chapter I content.
- Chapter II graybox: PASS, nine rooms, three floors, 14 spawns, 15 encounters, 38 enemies, `player=1`, `hud=1`.
- Windowed Main/F5-equivalent startup: PASS on OpenGL Compatibility/Metal; formal new game selected `opening_cinematic.tscn`; exit code 0; no red Output/Debugger error.

## 7. Stage decision

Stage 0 is complete. No gameplay scene, art, animation, collision, dialogue, camera behavior, or balance value was changed.

Next stage, after explicit approval: **complete the Player's proportion, formal concept art, production pixel assets, three-weapon-compatible animation set, prologue revival consistency, and Main integration.**
