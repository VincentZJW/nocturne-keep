# Cursed Shield Guard / 诅咒盾卫

Version: 2.1 · 2026-07-24

## Identity and role

A broad closed-helmet knight with a separate old-iron shield, short mace, dark plate, and restrained red eye slit. It is slower and wider than the Player. Its three-point shield is a readable positional resource rather than extra body Health.

## Runtime contract

- Main scene: `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn`.
- Enemy scene: `res://shared/scenes/enemies/cursed_shield_guard.tscn`.
- Behavior/config: `scripts/enemies/cursed_shield_guard.gd` and `resources/enemies/cursed_shield_guard_config.tres`.
- Body Health 5; Shield Health 3; weapon damage 8; GuardBreak 0.65 s; target-side turn delay 0.22 s.
- One shared `HurtboxComponent` delegates exactly once to `ShieldComponent`; there are no overlapping Shield/Body damage areas.
- Front normal/Dash hits reduce Shield by 1/2 and deal zero Body damage. The breaking hit discards overflow.
- Rear normal/Dash hits reduce Body by 1/2 and leave Shield unchanged.
- Side classification uses the attacking actor's root position, not the forward Hitbox center. A true actor source within 8 pixels of the enemy center is treated as a Body hit.
- `ShieldComponent` consumes `attacker instance id + attack_id` before routing. The consumed record survives Shield break, so a later active frame of the breaking Dash cannot reach Body; only a new attack id may damage the exposed body.
- Once Shield reaches zero it never regenerates. GuardBreak prevents movement, chase, attack, blocking, and turning while still accepting Body damage. Death remains higher priority.

## Direction and turning

`ShieldComponent` classifies `HitboxComponent.get_source_position()` against the enemy body and signed `FacingRoot.scale.x`. Player Hitboxes resolve that source to the Player root; generic legacy callers safely fall back to their Hitbox position. The Hitbox also carries attack kind, stable id, faction, and attack direction for audit/debug context. A target crossing behind enters `Turn`; the facing remains unchanged for 0.22 seconds and only flips if the target stays on that side. Attack, ShieldHit/Block, GuardBreak, Hurt, and Death do not turn.

## Independent presentation

- `VisualRoot/AnimatedSprite2D` contains shield-free body art for every action.
- `FacingRoot/ShieldVisual` owns `intact`, `cracked`, `critical`, and four-frame `shield_break` animations.
- 3/3 is intact, 2/3 has a readable light crack, 1/3 has a larger split/missing edge, and 0/3 plays break then hides permanently.
- `FacingRoot/ShieldHitEffect` adds three brief metal spark/flash frames at alpha 0.18 and a restrained 2-pixel shield shake on accepted front hits.
- Break retains `FacingRoot/ShieldBreakEffect`, fragments, and `VisualRoot/GuardBreakMarker`, but the auxiliary flash is confined to the shield at 0.05 seconds / alpha 0.30. The body is not modulated and the overlay has no pure-white core.
- Body actions resolve to `idle_unshielded`, `walk_unshielded`, `attack_unshielded`, `hurt_unshielded`, and `death_unshielded` after break. The body and shield are therefore never visually reassembled.

## Resources

- Body frames: `resources/enemies/cursed_shield_guard_sprite_frames.tres`.
- Shield states/break: `resources/enemies/cursed_shield_guard_shield_sprite_frames.tres`.
- Shield hit sparks: `resources/enemies/cursed_shield_guard_shield_hit_fx_sprite_frames.tres`.
- GuardBreak overlay: `resources/enemies/cursed_shield_guard_shield_break_fx_sprite_frames.tres`.
- Original transparent pixel assets: `assets/sprites/enemies/cursed_shield_guard/`.

All resources are nearest-neighbor, lossless, no-mipmap pixel art. Body and shield use the same 64×64 canvas and foot anchor; runtime left/right display uses the existing horizontal facing roots.

## Debug contract

Compact Main Enemy Debug exposes Body, Shield, visual state, source side, final route, attack type/id, broken flag, and enemy state without increasing panel size. Expanded output additionally exposes source position/direction, Shield/Body detector route flags, consumed status, duplicate blocking, applied Shield/Body damage, discarded overflow, Hitbox state, and GuardBreak remaining time.

## Main acceptance

Group01 places `CursedShieldGuard01` at `(500, 610)` before the Castle Guard at `(690, 610)`, providing immediate isolated space. Verify three front normal hits or two front Dash hits break Shield without changing Body 5/5; Shield 1 plus Dash 2 discards one overflow point; the breaking Dash's later active frame remains consumed; rear normal/Dash hits change Body to 4/5 or 3/5 without changing Shield; new post-break ids deal Body damage; the 0.22-second rear window is playable; the 0.65-second GuardBreak accepts punish damage; and Death dissolves without a ghost.
