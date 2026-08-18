# CH1 Ground-Rising Blue Sword Wave QA

Date: 2026-08-18

Scope: `Fallen Gate Knight / 堕落守门骑士` — `ShockwaveStrike / Gate Severance` only

Overall result: **PASS (automated/runtime), manual visual-feel acceptance pending**

## Runtime mapping

| Item | Formal path / value |
|---|---|
| Main authority | `res://scenes/bootstrap/main_bootstrap.tscn` |
| Chapter I level | `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn` |
| Boss scene | `res://chapters/chapter_01_ravenmourn_outskirts/scenes/boss/fallen_gate_knight.tscn` |
| Boss script | `res://chapters/chapter_01_ravenmourn_outskirts/scripts/boss/fallen_gate_knight.gd` |
| Boss config | `res://chapters/chapter_01_ravenmourn_outskirts/scripts/boss/fallen_gate_knight_config.gd` |
| SpriteFrames | `res://chapters/chapter_01_ravenmourn_outskirts/resources/boss/fallen_gate_knight_sprite_frames.tres` |
| State / presentation | `ShockwaveStrike` / `Gate Severance` |
| Attack kind | `boss_gate_severance` |
| Debug route used | `CHAPTER_01_RAVENMOURN_OUTSKIRTS`, spawn `boss_checkpoint` |

## Before / after contract

| Property | Previous | Revised |
|---|---:|---:|
| Boss action frames | 6 | 10 |
| Boss action FPS | 8.8 | 10 |
| Release frame | broad state-time release | exact authored contact frame 8 (zero-based 7) |
| VFX | runtime horizontal Polygon2D crescent | canonical 12-frame `AnimatedSprite2D` rising blade |
| VFX source canvas | dynamic 132×42 | 96×112 PNG frames, displayed at 80×88 |
| Collision | one 96×26 rectangle | 34×34 vertical core + 78×14 grounded base |
| Ground relation | offset above bridge | grounded at `Vector2(52, 44)` |
| Visual sampling | runtime polygons | nearest-neighbour, no mipmap-dependent scaling |

The Boss now raises the Gatewarden Greatsword, holds a readable warning pose, drives the blade down, releases the energy only when the blade reaches the bridge, and then performs a short recovery. Phase I uses `shockwave_strike_shielded`; Phase II uses `shockwave_strike`, so the formal shield state remains coherent while sharing one attack contract.

## Preserved combat values

| Value | Result |
|---|---:|
| Damage | 8 (unchanged) |
| Travel distance | 330 px (unchanged) |
| Travel duration | 0.78 s (unchanged) |
| Materialize time | 0.10 s (unchanged) |
| Dissipate time | 0.16 s (unchanged) |
| Post-attack gap | 1.10 s (unchanged) |
| AI selection model | existing weighted Phase II selection (unchanged) |

## Visual asset evidence

- Canonical rise frame: `res://chapters/chapter_01_ravenmourn_outskirts/assets/boss/fallen_gate_knight/effects/gate_severance_wave_06.png` (96×112).
- Ground-contact Boss frame: `res://chapters/chapter_01_ravenmourn_outskirts/assets/boss/fallen_gate_knight/sprites/shockwave_strike/shockwave_strike_08.png` (128×96).
- Shielded telegraph set: `res://chapters/chapter_01_ravenmourn_outskirts/assets/boss/fallen_gate_knight/sprites/shockwave_strike_shielded/` (10 frames).
- The blade uses a dark indigo outer silhouette, saturated blue body, pale-cyan cutting ridge, sharp forward hook and a broad ground flare. It does not use a horizontal doughnut/crescent silhouette.

## Exact Godot 4.7.1 verification

Executable: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot`

Version: `4.7.1.stable.official.a13da4feb`

| Check | Result | Evidence |
|---|---|---|
| Editor import / parse | PASS | exited 0; no script/resource error |
| Formal art contract | PASS | `animations=42 frames=179 concepts=7 shield_states=4 gate_wave=12 main=true` |
| Natural releases | PASS | 20/20; every release used the canonical 12-frame rising blade |
| Standing path 90 px | PASS | 20/20 hits |
| Standing path 210 px | PASS | 20/20 hits |
| Standing path 340 px | PASS | 20/20 hits |
| Right-facing travel | PASS | 20/20 hits |
| Left-facing travel | PASS | 20/20 hits |
| Walk-out avoidance | PASS | 10/10 avoided |
| Jump avoidance | PASS | 10/10 avoided |
| Double-jump avoidance | PASS | 10/10 avoided |
| Dash-through avoidance | PASS | 10/10 avoided |
| Counter-window regression | PASS | Shockwave gap remains 1.100 s; all seven Boss actions passed |
| Controlled full fights | PASS | 20 fights, 20 shield breaks, every Phase II action at least 15 uses |
| MainBootstrap launch | PASS | 3/3 launches selected saved Chapter I level through Main |
| Output / Debugger scan | PASS | no red script, resource or runtime error in final commands |

## Main/F5 manual acceptance

The local debug start is intentionally set to Chapter I `boss_checkpoint` and is not part of the commit. Press F5 and enter the bridge encounter. Keep medium-to-far distance during Phase II so the existing weighted AI can choose Gate Severance. Confirm:

1. the greatsword reaches the bridge before the wave appears;
2. the wave grows from the bridge surface rather than floating;
3. its dominant silhouette is high and narrow, with a forward bend;
4. standing on its path is hit, while jump/double-jump clears the vertical core;
5. left/right releases mirror cleanly;
6. no other Boss attack, damage value, AI weight, music or Player behavior changed.

Subjective visual weight, warning readability and player feel remain the user's manual acceptance gate; they are not represented as automated proof.
