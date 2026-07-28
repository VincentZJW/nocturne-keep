# The Hollow Duchess, Seraphine — production contract

## Saved Main composition

- F5: `res://scenes/bootstrap/main_bootstrap.tscn`.
- Chapter II level: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`.
- Antechamber: `SilentCourt/GameplayWorld/Geometry/Rooms/SilentBallroomAntechamber`.
- Formal threshold: `SilentCourt/GameplayWorld/BossArea/DuchessBossEntrance`; collision is `DoorBlocker`, and the bilingual inscription reads “The final waltz admits no absence. / 最后一支舞，不容缺席。”
- Intro trigger: `SilentCourt/GameplayWorld/BossArea/BossActivationArea` at global x=3800.
- Boss: `SilentCourt/GameplayWorld/BossArea/HollowDuchess` at global x=4700.
- Presentation AnimationPlayer: `SilentCourt/GameplayWorld/BossArea/DuchessEncounterPresentation/AnimationPlayer`.
- Reliquary: `SilentCourt/GameplayWorld/BossArea/DuchessReliquary`; displayed weapon is `WeaponDisplay`, interaction is `InteractionArea` + `InteractionPrompt`, three-frame timer-driven flames are `CandleFlames`, and the hidden inventory pickup anchor is `WeaponDisplay/PickupAnchor`.
- Secret door: `SilentCourt/GameplayWorld/BossArea/BallroomMirrorGate/PassageBlocker`.

The last normal encounter ends at x=2320. CP05 is x=2500, the monumental threshold is x=3100 and the intro trigger is x=3800. Therefore the saved safe run is 1300 px (1.02 of the 1280-px design viewport), about 5.9 seconds at the 220 px/s ground target before entrance easing and player choice. The pre-change CP05→trigger distance was 600 px but then left the Boss at x=6000, another 2900 px away; that hidden second leg caused the long-corridor feel. The Ballroom was reduced from 4480 to 3712 px. Its collision-backed fight boundary is approximately x=3280..6050, 2770 px or 2.16 viewports.

## First-view and retry presentation

`DuchessEncounterPresentation` installs and plays three explicit animations: `intro_full` (6.40 s), `intro_retry` (1.25 s), and `phase_transition_full` (4.40 s). The room controller locks Player input, closes the rear gate, locks the Camera bounds and releases input only on `combat_started`. The first view sequentially lights candles, shows restrained dancer silhouettes and starts the original looping low-fidelity waltz at `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/audio/broken_waltz_intro.tres`; the waltz stops at Phase Transition. Chapter II currently has no separate ambient BGM bus/source to duck. Seraphine turns and presents:

1. 瑟芙琳：“七年了……这座舞厅仍记得你的脚步。”
2. 夜巡守卫：“你认识我？”
3. 瑟芙琳：“我只记得，殿下一直在等一个打开门的人。”
4. 夜巡守卫：“那个人是我？”
5. 瑟芙琳：“跳完这支舞，你自然会想起来。”

The title is `THE HOLLOW DUCHESS, SERAPHINE / 空心公爵夫人·瑟芙琳`. Retry skips the dialogue/dancer sequence, shows the title, and starts in 1.25 seconds. No Boss, Player or HUD instance is recreated.

## Phase transition and visuals

At first crossing 55% (121/220 HP), new attack selection stops and `PhaseTransition` begins after the current safe state. The Boss closes all Hitboxes, clears Phantom routes, becomes temporarily invulnerable, returns toward the saved dance-floor center, and emits typed start/completion signals. The room controller locks Player input, keeps Camera stable with a restrained 1.08 zoom, extinguishes the intro tone and draws low crimson soul fog. The one-shot sequence lasts 4.40 seconds and never heals or replaces the Boss.

Runtime transformation frames are:

- `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/phase_transition/hollow_duchess_transformation_sprite_frames.tres`
- named source stages: `mask_crack.png`, `mask_break.png`, `body_distort.png`, `dress_tear.png`, `phase_2_reveal.png`.

Phase 1 remains `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/animations/hollow_duchess_sprite_frames.tres`. At 2.75 seconds, runtime atomically swaps to the independently redrawn `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/phase_02_unmasked/hollow_duchess_unmasked_sprite_frames.tres`. It contains 100 source frames across all 20 saved animation names. The Unmasked form has a void face, two restrained red eyes, broken porcelain crown fragments, torn black-crimson dress, exposed bone/soul limbs, a spine-fan silhouette, elongated bone rapier and shattered-mask fan. It is not a modulate/shader substitute. Body and Hurtbox sizes remain unchanged.

## Phase values

| Contract | Phase 1 | Phase 2 — Unmasked |
| --- | ---: | ---: |
| Incoming damage multiplier | 1.00 | 0.85 |
| Poise | 60 | 80 |
| Stagger | 0.56 s | 0.48 s |
| Stagger protection | 2.50 s | 3.00 s |
| Attack gap | 0.84–1.02 s | 0.82–1.02 s |
| Rapier thrust | 11 | 13 |
| Fan slash | 13 | 16 |
| Backstep riposte | 12 | 14 |
| Side-step cut | 12 | 14 |
| Double lunge | unavailable | 10 / 14 |
| Phantom dancer sweep | unavailable | 12 |
| Final waltz crossing | unavailable | 10 per pass |

The 0.85 multiplier belongs to `HollowDuchessHitPolicy`, not Player WeaponData. No HP is restored at transition. Windups and recovery remain readable; the Phase 2 attack gap is only marginally tighter than Phase 1.

## Defeat, reliquary and Chapter III gate

The existing four-line death exchange and 3.70-second body dissolve remain. Defeat opens the short rear route, unlocks `The Duchess’s Reliquary`, lights its candles, removes its soul lock and restores Player control. The reliquary is at x=5550, 850 px from the saved Boss start (0.66 viewport, about 3.9 seconds at 220 px/s; shorter when the fight ends on the arena's right half). It is a compact stone-and-dark-oak medieval pedestal, not a glass cabinet. Its two normal-size crossed stilettos have separate pommels, grips, guards, tapered Pale Steel blades and points. Two restrained three-frame candle flames advance every 0.12 seconds from a Timer, with no decorative per-frame `_process`.

The reliquary owns a 112 px proximity Area and the exact prompt `按 E 拾取 绯幕礼刺 / PRESS E TO TAKE CRIMSON MASQUE`. It emits one typed pickup request; the transition controller then consumes the existing fixed WeaponPickup programmatically. That pickup's duplicate Area/input path is disabled, while its old floor sprite/glow stays hidden and the saved `WeaponDisplay` remains the sole visual source. Defeated/uncollected reload restores an unlocked, occupied reliquary and sealed mirror. Collected reload restores an empty reliquary and revealed mirror. Collection preserves the existing unique auto-equip, Tier 3, 14 Normal / 28 Dash and HUD contracts, then starts the thirteen-crack mirror reveal. Passage interaction remains impossible until collection and continues to show the lore-consistent missing-reward message.

## Drawing order and Stage A performance contract

Chapter II uses explicit absolute world layers rather than YSort for architecture. Backgrounds remain `-100..-30`, behind-actor props `-10`, enemies `10`, Player `12`, pickups `14`, effects `16`, the thin floor lip `20`, intentional front props `25`, foreground `30`, and HUD CanvasLayers. The entrance and reliquary roots are absolute `z_index=8`; only their high world-space text prompts use absolute `z_index=20`. Consequently the Player body cannot inherit `BossArea`'s `z_index=10` and fall behind either structure.

`HollowDuchessBallroomFx/VisibilityNotifier` disables the 3712×792 custom canvas whenever it is off-screen and limits visible decorative redraws to 12 Hz. Chapter defeat releases the fifteen inactive ordinary encounter groups over successive frames. `SceneTransitionManager.prepare_scene()` threads the Passage and Chapter III PackedScenes before the fade; prepared transitions instantiate in approximately 0.3 ms on the measured Apple M4 route, disable the retired scene immediately, and release its leaf-first tree in batches of 18 nodes. This replaces the previous one-frame scene-tree teardown. The repeatable Chapter II→Passage maximum fell from 39.014 ms to 13.082 ms and Passage→Chapter III from 22.318 ms to 10.952 ms in the saved MainBootstrap probe. Floor transitions, the Phase transition, death/reliquary and mirror reveal remain inside the normal rendered-frame envelope.

## Manual acceptance

Set `debug_start_chapter_id = CHAPTER_02_SILENT_COURT` and `debug_start_spawn_id = CH2_BOSS`, press F5, and start at CP05. Walk right past the safe threshold, allow the monumental door to open, cross to the saved trigger, view the first intro and fight Phase 1. At 121 HP verify the 4.40-second transformation and new silhouette, defeat Phase 2, walk right to the occupied reliquary, press E to claim Crimson Masque, then use E at the revealed Royal Chapel Passage.
