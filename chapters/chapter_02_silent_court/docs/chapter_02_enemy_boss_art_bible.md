# Chapter II Enemy / Boss Art Bible

Status: Stage 0 baseline — approved target for Stages 1A–2D; no runtime art has been replaced yet

## 1. Chapter identity

`Chapter II: The Silent Court / 第二章：沉寂王庭` is a dead royal household still performing court service, guard ceremony, mourning rites and a final ball after the people inside have become hollow. Every character must answer three questions at native gameplay scale:

1. What court duty did this figure perform?
2. How has that duty survived as a cursed ritual?
3. What equipment or movement makes it readable before it attacks?

The roster is not a recolored medieval army. Its visual language is **court ceremony corrupted by seven years of silence**: black-violet textiles, dried-crimson accents, old gold, tarnished silver, pale wax, porcelain, funeral cloth and restrained soul-light.

## 2. Shared production rules

### Pixel construction

- Ordinary enemies author on transparent 64×64 cells unless a long weapon requires a wider cell. Their feet/origin and collision relationship must remain compatible with the saved enemy scenes.
- The Hollow Duchess authors on transparent 96×96 or a deliberately widened 96px-high cell when rapier, fan or transformed anatomy would otherwise clip. A wider cell must compensate its center offset so the saved world/feet anchor does not move.
- Nearest-neighbour import, no mipmaps, integer-aligned placement and no semi-pixel transforms are mandatory.
- Silhouette comes first. Internal pixels must describe material or anatomy; random single-pixel noise is prohibited.
- Every weapon needs blade/edge, body plane, guard or functional head, grip/shaft and a readable terminal. A pale line is not a weapon.
- Every costume needs at least three readable depth groups: deepest silhouette, local material colour and controlled edge/highlight. Pure-black blobs and one-colour rectangles fail.
- Left/right display may use `flip_h`, but asymmetric anatomy, weapon trails and attack volumes must still agree with facing.

### Shared palette family

| Role | Suggested range | Use |
|---|---|---|
| Court black | `#10111A`–`#1B1722` | deepest folds, voids, silhouette separation |
| Funeral violet | `#292338`–`#4B3B57` | court cloth, mourning fabric, cursed shadow |
| Dried crimson | `#612A36`–`#8E3D4B` | livery, blood wax, damaged ceremonial accents |
| Tarnished silver | `#68717C`–`#AAB3BB` | armor planes, weapon bodies, mask shadow |
| Porcelain / pale steel | `#D2D4D2`–`#E5DFD8` | face/mask, sharp edges, focal highlights |
| Old gold | `#8A6A3D`–`#B18A4D` | insignia, trim, ritual hardware; never broad fill |
| Soul blue | `#557C91`–`#8AB2BF` | restrained curse leakage and select eyes |
| Blood-wax ember | `#9C3D45`–`#D07858` | Acolyte flame and rare Phase 2 focal accents |

High-saturation red may appear only in small ritual/focal areas. It must not replace anatomy, material definition or phase differentiation.

### Animation and gameplay contract

- Existing AI timing, hitboxes, damage, health, movement and state decisions remain authoritative unless a later approved gameplay task changes them.
- Stage art may add presentation animation names, but existing names used by scripts must remain available or receive an explicit, tested mapping.
- Anticipation, active and recovery shapes must visually match the current attack phase and Hitbox direction. Active frames cannot hide the weapon or reverse the pose.
- Feet and body mass remain stable across idle, movement, turn, hit and death. Deliberate airborne/drop actions are the exception.
- Hurt is a short readable reaction; stagger is a larger punish window; death is a specific collapse/dissolution, not a reused hurt frame.
- Concept art, runtime SpriteFrames, saved enemy scene, formal Chapter II encounters and F5/Main evidence are one acceptance chain. A concept-only improvement is a FAIL.

## 3. Roster silhouette plan

| Character | Gameplay silhouette | Material anchor | Weapon / prop anchor | Motion character |
|---|---|---|---|---|
| Hollow Retainer | tall, narrow servant coat; small shoulders; trailing split tails | dark court uniform, sash, pale gloves, half-mask | fine ceremonial smallsword | quick, precise, unnaturally polite |
| Court Halberdier | tallest ordinary ground enemy; crested helm; wide polearm span | dark silver armor, crimson mantle, royal trim | complete halberd head: point + axe + rear hook | stable formation steps and committed arcs |
| Mourning Armor | broadest ordinary enemy; hollow helm; massive pauldrons | layered plate, funeral veil, internal black mist | armored arms/body-weight attacks, not a generic sword knight | slow mass, poise, collapse into empty shell |
| Blood-Candle Acolyte | narrow robed column broken by sleeves and raised candle | layered ritual vestments, wax-sealed pale face | blood candle/candlestick and clear prayer hands | restrained procession, readable cast ritual |
| Hanging Stalker | inverted hook/rope, long arms, folded legs; different ground pose | torn hunting livery fused to suspension gear | claws and hanging hardware | held tension, locked drop, animal-fast recovery |
| Hollow Duchess P1 | high-waisted aristocratic hourglass with layered skirt and mask | black-crimson court gown, porcelain, lace, old gold | court rapier + folding blade fan | controlled waltz, economy, lethal etiquette |
| Hollow Duchess P2 | lower forward pose, elongated arms, torn skirt/void, back fan | ruptured court dress, bone, mask shards, soul mist | bone-stiletto rapier + skeletal fan | broken dance rhythm and predatory crossing lines |

The five ordinary enemies must remain distinguishable as solid black silhouettes beside the player. Phase 2 Duchess must remain recognizable as Seraphine, but cannot share Phase 1's body contour with a colour swap.

## 4. Character-specific art targets

### Hollow Retainer / 空壳侍从 — Stage 1A

- Court duty: service, greeting and expulsion after the soul is gone.
- Required features: slim servant uniform, damaged swallow tails, metal half-mask, pale/void face, sash or court badge, white gloves and a complete ceremonial smallsword.
- Motion phrase: “a corpse completing murder as court etiquette.” A short service/bow beat may precede violence but must not soften the current fast threat.
- Required presentation set: `idle`, `bow_or_service_idle`, `patrol`, `alert`, `approach`, `retreat`, `turn`, `stab_windup`, `stab_active`, `stab_recovery`, `combo_hit_01`, `combo_hit_02`, `combo_recovery`, `light_hit`, `stagger`, `hurt`, `death`.
- Compatibility mapping required for current `walk`, `attack_single_stab`, `attack_combo`, `alert`, `hurt`, `death` calls.

### Court Halberdier / 王庭戟卫 — Stage 1B

- Court duty: ceremonial formation guard and palace passage control.
- Required features: tall ceremonial armor, plume/spired helm, crimson shoulder mantle, royal crest and a complete two-handed halberd. It cannot reuse the Chapter I spear silhouette.
- The halberd head must retain point, axe blade and rear hook in every frame; both hands and shaft length remain readable.
- Required presentation set: `idle_guard`, `patrol`, `alert`, `approach`, `turn`, three-part `long_thrust`, three-part `halberd_sweep`, `shaft_push`, `light_hit`, `stagger`, `hurt`, `death`.
- Compatibility mapping required for current `idle`, `walk`, `attack_thrust`, `attack_sweep`, `attack_shaft_push`, `turn`, `hurt`, `death` calls.

### Mourning Armor / 哀悼铠甲 — Stage 1C

- Court duty: empty funerary armor carrying royal mourning memory.
- Required features: hollow helm, funeral veil/cloth, oversized but articulated pauldrons, mourning crest, thick articulated limbs and visible inner void/mist. It cannot read as the Chapter I Boss without a shield.
- Death must lose structural support: separated helm/pauldron, collapsing black cloth and escaping internal mist.
- Required presentation set: `dormant`, `idle`, `heavy_walk`, `alert`, `turn`, three-part `overhead`, `shoulder_charge`, `armor_sweep`, `poise_hit`, `stagger`, `hurt`, `death_collapse`, `hollow_armor_break`.
- Compatibility mapping required for current `walk`, `attack_overhead`, `attack_shoulder_bash`, `attack_heavy_sweep`, `stagger`, `hurt`, `death` calls.

### Blood-Candle Acolyte / 血烛侍祭 — Stage 1D

- Court duty: private chapel attendant maintaining blood-wax rites and ally reinforcement.
- Required features: partially wax-sealed face, layered court vestments, long candle/candlestick, accumulated wax tears, clear prayer hands and cloth/sleeve depth.
- Flame uses 2–6-frame restrained motion; no static red dot and no bloom large enough to erase the body.
- Required presentation set: `prayer_idle`, `walk_or_reposition`, `alert`, `turn`, three-part `projectile_cast`, `ember_cast`, three-part `ally_buff`, `light_hit`, `stagger`, `hurt`, `death`, `candle_extinguish`.
- Compatibility mapping required for current `idle`, `walk`, `attack_cast`, `buff_channel`, `hurt`, `death` calls and the saved projectile muzzle position.

### Hanging Stalker / 倒悬猎兽 — Stage 1E

- Court duty: trained palace hunter fused with torn livery, rope and court hardware after the curse.
- Required features: clear inverted head/torso, long arms and claws, folded legs, hook/strap, torn hunting uniform and a distinct landed anatomy. It is not an insect, bat, spider or recolored gargoyle.
- Drop telegraph includes body tension, floor shadow and restrained debris before direction lock resolves.
- Required presentation set: `ceiling_hidden`, `ceiling_idle`, `ceiling_track`, `telegraph`, `detach`, `drop_attack`, `land`, `emerging_claw`, `short_chase`, `retreat_or_reclimb`, `turn`, `light_hit`, `stagger`, `hurt`, `death_fall`, `death_ground`.
- Compatibility mapping required for current `hang`, `telegraph`, `drop`, `ground_recovery`, `claw`, `retreat`, `return_to_anchor`, `hurt`, `death` calls.

## 5. Hollow Duchess quality bar

### Phase 1 — Stage 2A

Theme: **the hostess of the final ball**.

- Tall feminine court silhouette; layered black-crimson damaged gown; corseted waist; readable shoulders, sleeves and lace; porcelain mask and head ornament; dark-gold court details.
- Rapier needs point, blade plane, guard, grip and pommel. Blade fan needs ribs, cutting edges and separate folded/open forms.
- Required presentation set: `dormant`, `intro_back_facing`, `intro_turn`, `dialogue_idle`, `idle`, `elegant_walk`, `approach`, `retreat`, `sidestep`, `backstep`, `turn`, three-part `rapier_thrust`, three-part `fan_slash`, `backstep_riposte`, `sidestep_cut`, `light_hit`, `stagger`, `hurt`, `phase_transition_start`.

### Full transformation — Stage 2B

The 4.40-second gameplay transition must be rebuilt as authored character change, not a tint/flash. Key beats: locked body; porcelain hairline crack; crack spread; mask fragments fall; faceless cavity; altered jaw/head; elongated fingers/arms; torn dress; chest/abdomen void; back fan growth; rapier becomes bone stiletto; fan becomes skeletal blade; lower forward final reveal.

The current runtime swaps the dedicated transition SpriteFrames to Phase 2 SpriteFrames at 2.75 seconds. Later implementation must preserve the gameplay duration while aligning key poses to that swap or revise the presentation routing without changing the combat threshold.

### Phase 2 — Stage 2C

Theme: **court etiquette collapsed into the faceless true form**.

- Preserve female/gown/dance/rapier/fan identity while adding a broken head, elongated limbs, chest or abdomen void, torn skirt exposing bone/soul structure, skeletal back fan, bone-stiletto rapier and bone fan.
- Required presentation set: `phase_02_reveal`, `phase_02_idle`, `distorted_walk`, `phase_02_turn`, `phase_02_sidestep`, `phase_02_backstep`, `phase_02_thrust`, `phase_02_fan_slash`, `double_waltz_lunge`, `phantom_dancer_sweep`, `final_waltz_crossing`, `phase_02_light_hit`, `phase_02_stagger`, `phase_02_hurt`, `death_start`, `death_mask_shatter`, `death_collapse`, `death_dissolve`.

### Presentation completion — Stage 2D

- Intro must show a back-facing Phase 1 body, slow turn, porcelain mask, dialogue idle and explicit ready pose while AI and hitboxes stay disabled.
- Phase 1 afterimages preserve mask, gown, rapier, fan and dance pose. Phase 2 afterimages preserve faceless head, elongated arms, torn gown, bone weapons and route clarity.
- Death uses Phase 2 art through staggered dance loss, back-fan collapse, final mask break, weapon failure, body fold and restrained dissolution.
- Existing reliquary, Crimson Masque pickup, mirror passage and Chapter III transition remain intact.

## 6. Asset ownership and directory contract

- Ordinary character source and runtime art stays under `res://chapters/chapter_02_silent_court/assets/enemies/<enemy_id>/` with `concept_art/`, `sprites/`, `animations/`, optional `effects/`, and `reference/deprecated_<version>/` for superseded sources.
- Duchess source and runtime art stays under `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/` to preserve current saved paths. A future plural `bosses/` migration is not part of this art rework.
- New concept deliverables are PNG, not programmatic rectangle-only SVG boards. Editable deterministic production scripts may be kept under Chapter II `scripts/tools/` when they produce deliberate pixel assets and pass visual review.
- Old formal PNGs must be archived before replacement. `.import`/`.godot` cache is not an archive and is never the source of truth.
- Shared `FallenCrossbowman` and `GargoyleSentinel` instances used by Chapter II remain under `res://shared/`; this rework does not silently duplicate or recolor them.

## 7. Per-stage acceptance gates

Each Stage 1A–2D must pass all applicable rows before its commit:

| Gate | Required evidence |
|---|---|
| Concept | original front/three-quarter concept plus weapon/prop and key-pose studies |
| Silhouette | black silhouette comparison at authored scale and native gameplay scale |
| Formal sprites | every required runtime family uses the new anatomy/equipment, not a legacy frame |
| Consistency | fixed foot/origin, stable proportions, complete weapon through every action |
| Scene binding | formal `.tscn` references the authoritative new SpriteFrames with no Inspector art override |
| Main binding | F5 Bootstrap → Chapter II formal encounter/Boss displays the same resources |
| Gameplay contract | hitbox direction/timing, collision, health, damage, AI and encounter logic regressions pass |
| Visual evidence | idle, movement, turn, every attack, hit/stagger and death captured from Main |
| Legacy search | zero runtime reference to archived formal frames |
| Output | exact Godot 4.7.1 import/parse and scene runs have no red parser/resource/runtime error |

Automatic asset checks cannot approve material quality, animation weight, silhouette appeal or battle readability. Those remain manual visual acceptance items. If a formal Sprite still reads as a placeholder at native Main scale, the stage is not complete.

## 8. Approved execution order

1. Stage 1A — Hollow Retainer.
2. Stage 1B — Court Halberdier.
3. Stage 1C — Mourning Armor.
4. Stage 1D — Blood-Candle Acolyte.
5. Stage 1E — Hanging Stalker.
6. Stage 2A — Hollow Duchess Phase 1.
7. Stage 2B — full Phase Transition.
8. Stage 2C — Hollow Duchess Phase 2.
9. Stage 2D — intro, afterimages/effects, death and reward handoff.
10. Stage 3 — complete Chapter II Main regression and final forced QA.

The user authorized Stage 1A–1E as one continuous delivery on 2026-07-29. All five ordinary-enemy stages now have original concept sheets, deterministic formal pixel frames, expanded presentation families, authoritative SpriteFrames and Main evidence. Their implementation record is `res://docs/qa/chapter_02_enemy_boss_art_rework/stage_1_report.md`.

Stage 2A–2D were approved and completed continuously on 2026-07-29. The dedicated Hollow Duchess attachment remained the highest-priority design and acceptance source. Delivery includes nine concept/weapon/mask boards, 143 Phase 1 frames, 39 transformation frames, 180 Unmasked Phase 2 frames, authoritative SpriteFrames replacement, MainBootstrap graphical evidence, gameplay/reward-transition regression coverage and an archived Stage 1 runtime set. The implementation and forced-QA record is `res://docs/qa/chapter_02_enemy_boss_art_rework/stage_2_report.md`.
