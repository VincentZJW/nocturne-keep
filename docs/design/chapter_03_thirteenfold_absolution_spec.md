# Chapter III fixed reward — Thirteenfold Absolution / 十三重赦刃

Status: W1–W5 complete on 2026-08-02. The later Underkeep UD0–UD5 pass adds a formal Chapter IV threshold without changing this weapon contract.

## Identity and narrative role

`Thirteenfold Absolution / 十三重赦刃` is one indivisible tier-3 dual-dagger set. Its main blade is `Absolution / 赦罪`; its shorter off-hand blade is `Penance / 忏悔`. Edran's broken hollow-bell crozier, censer frame and thirteen extinguished seals are reforged after his defeat. The empty fourteenth seat remains unresolved environmental storytelling rather than an extra weapon or upgrade.

The set is original project art. Bone-white steel, old brass, dark iron and restrained hollow-bell blue separate it from Ravenfang and Crimson Masque without introducing real-world religious marks.

## Authoritative gameplay data

| Field | Value |
|---|---|
| Weapon ID | `thirteenfold_absolution_blades` |
| Visual ID | `thirteenfold_absolution` |
| Type / tier | `dual_daggers` / 3 |
| Normal attack | 14 |
| Dash attack | 28 |
| Ownership | unique, permanent, story reward |
| Pickup behavior | auto-equip; duplicates rejected |
| Sellable | no |

The independent authority is `res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/thirteenfold_absolution_blades.tres`. Inventory owns identity; Equipment owns the equipped selection and resolved damage; HUD and Player visuals listen to Equipment signals.

## Visual production contract

- 12 accepted concept-art sheets define pair, individual blades, silhouette, guards, seals, scale, combat, reforging and reliquary.
- The formal Player resource contains 30 animations and 97 transparent 64×64 PNG frames.
- Presentation assets include 32×32 inventory icon, 24×24 HUD icon, 64×64 pickup, 96×64 reliquary states and chapter-local effects.
- `PlayerWeaponVisual` swaps the complete SpriteFrames atomically. It does not alter movement timing, Hitboxes, collision, stamina or attack cadence.
- Right-facing is authored; left-facing uses the existing `flip_h` contract.

## Formal reward flow

1. `ThirteenthPontiffEdran.defeated` remains the Boss death authority.
2. `Chapter03RewardSequenceController` separately locks/protects the Player and runs the 4.20-second fragments → seals → blades → hold presentation.
3. The Boss exit opens only after both death environment and reward formation complete.
4. `CH3_POST_BOSS` reveals the generic `WeaponPickup` in the Last Confession Reliquary.
5. Successful collection adds the unique weapon, auto-equips it, shows the acquisition panel and permanently empties the reliquary.
6. Collection sets the canonical flags and opens the physical Underkeep blocker/exit.
7. `CH3_UNDERKEEP_DESCENT` inherits Player, HUD, unique ownership, equipped visual and 14/28 values.
8. Death/respawn and validated disk reload retain ownership/equipment. Returning to the reliquary cannot spawn a duplicate.

## Canonical progress state

| State | Authority |
|---|---|
| reward formed | `chapter_03_boss_reward_spawned` |
| reward collected | `chapter_03_boss_reward_collected` |
| descent unlocked | `chapter_03_underkeep_descent_unlocked` |
| chapter complete | `CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES` in completed chapters |
| recovery target | Chapter III + `CH3_UNDERKEEP_DESCENT` |

`PlayerProgressSaveService` writes versioned JSON under `user://`; unknown weapon IDs and invalid transactions are rejected before runtime mutation. Default F5 remains formal New Game. A future title/Continue milestone may call the already-tested explicit load API, but W5 does not create that UI.

## MainBootstrap debug starts

All four states route through `res://scenes/bootstrap/main_bootstrap.tscn`. They are disposable `is_debug_run` sessions and never write formal progress.

| Spawn | Truthful state |
|---|---|
| `CH3_BOSS` | Boss, formation, pickup and gate can be tested end-to-end; reward not owned initially |
| `CH3_POST_BOSS` | Boss treated as defeated; reward formed but uncollected; gate locked |
| `CH3_REWARD_TEST` | fast formal pickup/equip/animation QA; reward uncollected and no visual-only fake ownership |
| `CH3_UNDERKEEP_DESCENT` | reward owned/equipped/collected, gate unlocked, Chapter III complete |

## Stage ownership

- W1: concept lock and original concept assets.
- W2: formal pixel frames, effects and Player presentation resource.
- W3: independent WeaponData, Inventory/Equipment registration and minimum disk persistence.
- W4: Edran reward formation, formal reliquary pickup, acquisition panel and descent gate.
- W5: truthful debug starts, two-process full-flow recovery, death/respawn/return regression and final Main QA evidence.

Historical W2 documents describe the visual-only state that was correct during W2. W5 intentionally supersedes the runtime meaning of `CH3_REWARD_TEST`; it now uses the real uncollected pickup and Equipment transaction.

## Current boundary update

W5 originally stopped honestly at a missing Chapter IV scene. The later Underkeep UD0–UD5 environment pass created `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn` as a formal `CH4_START` threshold and connected the existing reward-gated descent to it. This does not change weapon ownership, damage, persistence or reward timing, and it does not claim that the complete Chapter IV map exists.

## Verification and evidence

- Two-process test: `res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_full_flow.gd`.
- Final Main capture: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/capture_thirteenfold_absolution_qa.gd`.
- QA report: `res://docs/qa/chapter_03_thirteenfold_absolution/w5/report.md`.
- Screenshot/path hashes: `res://docs/qa/chapter_03_thirteenfold_absolution/w5/sha256_manifest.txt`.

Manual F5 acceptance: select Chapter III and use `CH3_BOSS` for the complete encounter, `CH3_REWARD_TEST` for a short pickup/action check, or `CH3_UNDERKEEP_DESCENT` for post-acquisition death/respawn. Verify the HUD reads tier 3 and 14/28 after acquisition, the gate opens only after collection, the empty reliquary persists for the process lifetime, and the Underkeep E prompt fades into the single-player/single-HUD `CH4_START` threshold.
