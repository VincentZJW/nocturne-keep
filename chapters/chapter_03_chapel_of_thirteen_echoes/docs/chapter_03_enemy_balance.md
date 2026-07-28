# Chapter III Enemy Balance / 第三章敌人数值基线

Status: **Phase 2 baseline_v1 implemented — automated contracts pass; manual and Phase 4 balance playtest pending**

## Verified Player baseline

| Variable | Actual project value/source |
|---|---|
| Player max HP | 100, `scenes/player/player.tscn` → `HealthComponent` default |
| Equipped Chapter III weapon | Crimson Masque Stilettos / 绯幕礼刺 |
| WeaponData | `chapters/chapter_02_silent_court/resources/weapons/crimson_masque_stilettos.tres` |
| Normal damage | 14 |
| Dash Attack damage | 28 |
| Normal visual attack | 4 frames at 20 FPS = 0.20 s |
| Dash Attack visual | 5 frames at 20 FPS = 0.25 s |
| Normal chain cadence | minimum 0.32 s between starts; at most 3 attacks; 0.34 s end recovery |
| Dash | 480 px/s for 0.18 s; 25 stamina; repeated presses, not hold-to-repeat |
| Move/jump/gravity | 220 px/s, −420 px/s jump, 1100 px/s² gravity |
| Traversal support | 0.10 s coyote, 0.12 s jump buffer; debug Player currently enables double jump |

The prompt's 14/28 assumption matches the saved WeaponData exactly; this milestone does not change it.

## Prior chapter reality

- Current Chapter I ordinary enemy Resources are approximately 30–50 HP and 5–10 attack damage.
- Current Chapter II prototypes span 48–96 HP and 4–14 damage, with role pressure rather than uniform scaling.
- Chapter III therefore targets 70–98 HP for ordinary specialists and 126 HP only for the Executioner heavy. Difficulty is expected to come from readable combination pressure, not universal health inflation.

## Baseline_v1 values

| Enemy | HP | Poise | Normal hits to kill | Dash hits to kill |
|---|---:|---:|---:|---:|
| Bellchain Penitent | 70 | 32 | 5 | 3 |
| Censer Executioner | 126 | 82 | 9 | 5 |
| Silent Chorister | 84 | 36 | 6 | 3 |
| Stained-Glass Seraph | 76 | 30 | 6 | 3 |
| Confessional Wraith | 82 | 38 | 6 | 3 |
| Thirteenth Scribe | 98 | 46 | 7 | 4 |

Kill counts use `ceil(HP / damage)` and assume every hit resolves, no Paper Ward, no healing and no damage reduction.

## Attack values and Player survivability

| Enemy / attack | Damage | Hits to defeat 100 HP | Windup | Active | Recovery / cooldown |
|---|---:|---:|---:|---:|---:|
| Penitent · Chain Lash | 11 | 10 | 0.42 s | 0.12 s | 0.52 s |
| Penitent · Bell Slam | 13 | 8 | 0.62 s | 0.14 s | 0.76 s |
| Penitent · Short Chain Pull | 8 | 13 | Phase 2A tune, target 0.55 s | target 0.10 s | target 0.68 s; 3.0 s cooldown |
| Executioner · Censer Sweep | 14 | 8 | 0.66 s | 0.18 s | 0.90 s |
| Executioner · Overhead Crush | 17 | 6 | 0.82 s | 0.16 s | 1.05 s |
| Executioner · Smoke tick | 4 | 25 | visible release | max 3 ticks over ~2.0 s | per-target interval required |
| Chorister · Silent Wave | 10 | 10 | 0.55 s | projectile | Phase 2C tune |
| Chorister · Crescent Hymn | 12 | 9 | 0.68 s | projectile | Phase 2C tune |
| Seraph · Shard Volley | 9 | 12 | 0.60 s | volley | Phase 2D tune |
| Seraph · Dive | 13 | 8 | Phase 2D tune, marker required | locked dive | 0.70 s Ground Vulnerable on miss/break |
| Seraph · Shatter Burst | 8 | 13 | visual crack warning | single bounded event | no death damage |
| Wraith · Emerging Slash | 12 | 9 | after door + emerge telegraph | Phase 2E tune | Phase 2E tune |
| Wraith · Spectral Dash | 11 | 10 | Phase 2E tune | short locked lane | Phase 2E tune |
| Wraith · Confession Scream | 10 | 10 | Phase 2E tune | one bounded wave | Phase 2E tune |
| Scribe · Ink Lance | 10 | 10 | 0.52 s | projectile | Phase 2F tune |
| Scribe · Thirteenth Seal | 13 | 8 | write + 0.75–0.90 s delay | one activation | max 2 active |
| Scribe · Binding Script | 8 | 13 | Phase 2F tune | one hit | 3.0 s cooldown |

Times previously marked “Phase 2 tune” are now concentrated in the five role Resources. They are implemented prototype timings, not final balance acceptance; manual and Phase 4 combination tests may revise them without changing the HP/damage baseline silently.

## Control and defense limits

- Short Chain Pull: 20–30 px maximum, horizontal and collision-safe, same navigable platform only; no wall/floor crossing and no long control lock.
- Hush Field: 2.5 s, stamina regeneration ×0.65; does not disable Dash and does not stack. It ends when its owner dies.
- Smoke: about 2.0 s, maximum three accepted ticks per Player per release; unique sub-attack ids and a visible edge are required.
- Seraph Ground Vulnerable: about 0.70 s; Poise break causes a fall before the punish window.
- Binding Script: movement speed ×0.80 for about 1.0 s; no jump/Dash prohibition and no stacking.
- Paper Ward: at most one Normal hit absorbed/reduced; Dash Attack breaks it; about 4.0 s cooldown and no chain recast.

## Poise model decision

Chapter III now composes `Chapter03PoiseComponent` for all six enemies while Chapter II remains unchanged.

Accepted Player attacks supply 14 Normal / 28 Dash Poise pressure. Automated tests verify component wiring and Stagger recovery; the 30–82 scale remains `[PLAYTEST_REQUIRED]` for combat feel until Phase 4.

## Broken-state definitions for Phase 4

Balance fails if any of these occur:

- a visible hit lands outside its telegraph/visual bounds;
- one attack id damages the same target twice unintentionally;
- Volley shards each apply full primary damage in one volley;
- smoke exceeds three accepted ticks or damages every physics frame;
- pull, dash or projectile crosses a wall/floor/room boundary;
- two Hush Fields multiply or Binding Script stacks;
- repeated Normal attacks permanently reset every enemy before a decision;
- heavy Recovery is too short to permit a 0.32-second Player follow-up;
- remote units remain unreachable or four-unit combinations erase all safe routes;
- time-to-kill feels like health padding rather than role mastery.

All table values are now written into chapter-local runtime `.tres` files. No Player, weapon, Chapter I or Chapter II balance value was changed by this implementation.
