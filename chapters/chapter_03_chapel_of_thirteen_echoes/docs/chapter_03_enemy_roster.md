# Chapter III Enemy Roster / 第三章敌人名册

Status: **Phase 2A–2F complete — all six normal enemies implemented and Main-accessible; Phase 3 Trial Hall and Phase 4 forced balance QA remain**

## Chapter function

`Chapel of Thirteen Echoes / 十三响礼拜堂` reveals that the Silent Bell was an instrument for thirteen named soul sacrifices, that the Crown and court clergy jointly authored the rite, and that the Night Warden entered this chapel seven years earlier. The roster must make ritual corruption readable through bodies and attacks without revealing the full result of the Fourteenth Toll or implementing the Bell-Confessor Priest Boss.

Player experience pillars:

1. **Every threat belongs to the chapel:** bells, censers, voiceless hymns, stained saints, confessionals and ritual records are the enemies' bodies and weapons.
2. **Pressure comes from roles, not health inflation:** every unit exposes a distinct target-priority decision and a readable safe response.
3. **Telegraph before control:** pulls, dives, runes, smoke and ambushes lock direction or location after visible warning; none may attack from an unseen floor or across rooms.
4. **A path to the attacker always exists:** elevated and airborne units remain reachable with the current Player traversal kit.
5. **The roster foreshadows the Boss:** thirteen-count motifs, recorded names and controlled silence escalate toward the Bell-Confessor Priest without implementing that encounter.

## Real-project baseline

- F5 root: `res://scenes/bootstrap/main_bootstrap.tscn`.
- Chapter registry: `res://scripts/systems/chapter/chapter_registry.gd`.
- Current Chapter III destination: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn`.
- Current profile: `res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/chapter/chapter_03_start_profile.tres`.
- Current Chapter III runtime content: the entry prototype contains all six saved enemy scenes in four separated acceptance encounter groups plus four direct test spawns. The formal map and station-based Trial Hall do not exist yet.
- Verified starting weapon: `Crimson Masque Stilettos / 绯幕礼刺`, `res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_stilettos.tres`, 14 Normal / 28 Dash Attack.

## Six-enemy roster

| ID | Name | Role | HP | Poise | Main pressure | Primary counterplay |
|---|---|---:|---:|---:|---|---|
| `bellchain_penitent` | Bellchain Penitent / 钟链忏者 | mid-close baseline | 70 | 32 | lash, ground slam, short pull | read lock, jump slam, punish recovery |
| `censer_executioner` | Censer Executioner / 香炉行刑者 | heavy area control | 126 | 82 | sweep, crush, bounded smoke | jump/route around, punish long recovery |
| `silent_chorister` | Silent Chorister / 无声唱诗灵 | ranged rhythm control | 84 | 36 | straight/crescent waves, regen field | approach through gaps, remove support first |
| `stained_glass_seraph` | Stained-Glass Seraph / 彩窗圣骸 | airborne pressure | 76 | 30 | shard fan, locked dive | use safe fan gaps, force fall, punish ground window |
| `confessional_wraith` | Confessional Wraith / 忏悔亡魂 | telegraphed ambush | 82 | 38 | emergence, short dash, scream | observe door, evade locked lane, punish retreat |
| `thirteenth_scribe` | Thirteenth Scribe / 十三响司录者 | delayed zone control | 98 | 46 | ink lance, delayed seal, brief slow, ward | leave marked floor, break ward with Dash Attack |

All values above are the implemented `baseline_v1` saved in Chapter III tuning Resources. Phase 4 twenty-kill/combination testing must still verify feel before final balance acceptance.

Runtime status: `bellchain_penitent` owns 70 frames; Executioner, Chorister, Seraph, Wraith and Scribe collectively own 345 additional transparent 64×64 frames. All six compose Health/Hitbox/Hurtbox/Poise/Loot, have saved scenes and are referenced by the Bootstrap-routed Chapter III acceptance scene.

## World and visual identity

### Bellchain Penitent / 钟链忏者

Former penitents were fitted with neck and wrist bells and compelled to recite between tolls. Death left them driven by chains and pendulum motion. Their grey-black robe, sealed mouth, old-copper throat bell and short prayer-bell chain form a stooped asymmetrical silhouette. They teach the chapter's basic rule: a bell telegraph is a promise about timing and direction.

### Censer Executioner / 香炉行刑者

Executioners dragged failed offerings below the chapel and burned clothing, blood and records in oversized censers. The corpse, smoke and brazier have fused. A tall hood, leather apron, two-handed chain and low iron censer create the roster's widest ground silhouette; it must not resemble the Mourning Armor or carry a generic axe/sword.

### Silent Chorister / 无声唱诗灵

The choir was ordered to sing through the thirteenth toll. Their voices vanished, but wax-sealed mouths and ritual gestures persisted. A damaged hymn book, long sleeves, slightly floating feet and an incomplete bell halo distinguish them from a conventional mage. Their visible waves and candle disturbance communicate sound that the player cannot hear.

### Stained-Glass Seraph / 彩窗圣骸

Royal propaganda saints left the windows as bodies of restrained glass and black lead. Broken wings, a pointed halo and a pale glass face expose the lie of sanctity. Dark blue, muted wine, old gold and small pale panes replace rainbow saturation; its silhouette must not reuse the Gargoyle Sentinel.

### Confessional Wraith / 忏悔亡魂

Confessionals were records and execution chambers rather than places of pardon. The wraith remains tethered to its timber booth. A grille-divided face, black drapery/smoke body, pale long arms and torn stole make the booth and spirit one design. Door movement is always the ambush telegraph.

### Thirteenth Scribe / 十三响司录者

Court scribes recorded every sacrificed name in ink mixed with blood and ash. The writing climbed onto their skin after the thirteenth toll. A parchment-covered face, bone-quill fingers, long scroll and back-mounted ledger create the tallest narrow silhouette and explain its delayed writing attacks.

## Planned chapter population, not an Encounter implementation

Target total: 44 normal enemies in the later formal map.

| Enemy | Planned count |
|---|---:|
| Bellchain Penitent | 13 |
| Censer Executioner | 5 |
| Silent Chorister | 7 |
| Stained-Glass Seraph | 6 |
| Confessional Wraith | 6 |
| Thirteenth Scribe | 5 |
| Story-compatible returning enemies | 2 |

Returning candidates are Blood-Candle Acolyte and Gargoyle Sentinel only when an authored location justifies them. They cannot replace a Chapter III role.

Encounter constraints for the later map:

- tutorial groups: 1–2 enemies; ordinary groups: 2–3; high-pressure groups: at most 4;
- at most one Executioner and one Scribe active in a group;
- two Choristers may not stack Hush Field;
- multiple Wraiths may not emerge without staggered telegraphs;
- a four-enemy group includes at least one or two low-pressure bodies and preserves a visible escape lane;
- no formal placement is authorized in this milestone.

## Recommended role combinations

| Combination | Decision created | Failure condition to test later |
|---|---|---|
| Penitent + Chorister | close pressure versus ranged priority | waves erase the lash/slam safe route |
| Penitent + Scribe | pursuit versus delayed floor mark | seal fills both retreat directions |
| Executioner + Penitent | slow heavy anchor plus readable basic unit | heavy recovery is covered continuously |
| Executioner + Chorister | ground sweep versus elevated support | no reachable route to support |
| Seraph + Penitent | air/ground split attention | dive marker hidden by chain effect |
| Wraith + Scribe | ambush plus zone control | both trigger without ordered warning |

Forbidden default combination: Executioner + Scribe + Chorister + Seraph. It concentrates heavy, field, ranged and air pressure without the low-pressure slot required by the chapter rules.

## Phase ownership

- Phase 0: this roster, art bible, combat/balance contract and file/Trial Hall plan.
- Phase 1: twelve real concept/silhouette PNGs and authenticity QA only.
- Phase 2A–2F: complete in roster order with independent scenes, Main references, graphical evidence and unified verification.
- Phase 3: Debug-only Enemy Trial Hall and combination harness.
- Phase 4: forced QA, at least 20 kills per enemy, at least 15 triggers per attack and five runs per required combination.

No Chapter III formal map, formal Encounter distribution, Boss, weapon, skill tree or Chapter IV work is included.

## Planned production file manifest

All paths below are relative to `res://chapters/chapter_03_chapel_of_thirteen_echoes/` and now exist.

| Enemy | Scene | Controller | EnemyData | SpriteFrames |
|---|---|---|---|---|
| Penitent | `scenes/enemies/bellchain_penitent.tscn` | `scripts/enemies/bellchain_penitent.gd` | `resources/enemies/bellchain_penitent_data.tres` | `assets/enemies/bellchain_penitent/animations/bellchain_penitent_sprite_frames.tres` |
| Executioner | `scenes/enemies/censer_executioner.tscn` | `scripts/enemies/chapter_03_specialist_enemy.gd` | `resources/enemies/censer_executioner_data.tres` | `assets/enemies/censer_executioner/animations/censer_executioner_sprite_frames.tres` |
| Chorister | `scenes/enemies/silent_chorister.tscn` | `scripts/enemies/chapter_03_specialist_enemy.gd` | `resources/enemies/silent_chorister_data.tres` | `assets/enemies/silent_chorister/animations/silent_chorister_sprite_frames.tres` |
| Seraph | `scenes/enemies/stained_glass_seraph.tscn` | `scripts/enemies/chapter_03_specialist_enemy.gd` | `resources/enemies/stained_glass_seraph_data.tres` | `assets/enemies/stained_glass_seraph/animations/stained_glass_seraph_sprite_frames.tres` |
| Wraith | `scenes/enemies/confessional_wraith.tscn` | `scripts/enemies/chapter_03_specialist_enemy.gd` | `resources/enemies/confessional_wraith_data.tres` | `assets/enemies/confessional_wraith/animations/confessional_wraith_sprite_frames.tres` |
| Scribe | `scenes/enemies/thirteenth_scribe.tscn` | `scripts/enemies/chapter_03_specialist_enemy.gd` | `resources/enemies/thirteenth_scribe_data.tres` | `assets/enemies/thirteenth_scribe/animations/thirteenth_scribe_sprite_frames.tres` |

Each enemy root owns populated `sprites/` and `animations/` folders. Effects are represented by saved Chapter III projectile/field scenes rather than empty folders. Loot quantity Resources remain chapter-local under `resources/enemies/`, while the shared dynamic probability table is referenced unchanged.
