# Thirteenfold Absolution / 十三重赦刃 — W1 Concept Lock

Date: 2026-07-31

## Stage boundary

W1 establishes the visual production reference only. It does not create WeaponData, pixel sprites, SpriteFrames, Player animation integration, Inventory/Equipment/Save state, pickup interaction, Boss reward sequence or Main scene changes. Those remain W2–W5.

## Final identity

`Thirteenfold Absolution / 十三重赦刃` is one indivisible dual-dagger set reforged from Edran's broken hollow-bell crozier, thurible and thirteen extinguished seals. It expresses the Night Warden taking false absolution away from the Pontiff rather than accepting his creed.

The production palette is bone white/cold silver, black iron, aged copper/muted dark gold, restrained dark red and black leather. No real-world cross, church emblem, scripture, modern numeral or copied commercial-game motif is used.

## Weapon construction

### Absolution / 赦罪

- Long triangular thrust blade with a precise tip, bone-white face, black-iron bevel and narrow dark-red groove.
- Large but mechanically plausible oval hollow-bell ring guard. Thirteen extinguished studs surround it and one dark unlabeled socket remains empty.
- Black leather grip with aged-copper collars and a compact pointed crozier pommel.
- Silhouette reads as the longer, straighter main-hand authority blade.

### Penance / 忏悔

- Roughly three quarters of Absolution's length; shorter, wider and only subtly inward-hooked.
- Thurible vent apertures and a perforated semicircular censer guard provide a different structural silhouette.
- One small fixed side ring communicates the chain origin without becoming a flail or uncontrolled animation element.
- Dark-red/black wrap, old-copper segmentation and censer-lid pommel complete the off-hand identity.

## Twelve concept deliverables

All project assets live under:

`res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/thirteenfold_absolution/concept_art/`

1. `thirteenfold_absolution_pair_concept.png` — definitive shared material, length and silhouette master.
2. `absolution_main_blade_front.png` — front orthographic construction and thirteen-node ring guard.
3. `absolution_main_blade_side.png` — blade/ridge/guard thickness; proves the thrust blade is not a line.
4. `penance_offhand_blade_front.png` — thurible apertures, shallow hook and fixed ring.
5. `penance_offhand_blade_side.png` — off-hand thickness and compact guard assembly.
6. `thirteenfold_absolution_silhouette.png` — pure silhouette comparison; both weapons remain distinct without color.
7. `thirteenfold_guard_breakdown.png` — exploded old-copper, black-iron, stud, vent and collar construction reference.
8. `thirteen_seal_nodes.png` — thirteen filled extinguished medallions, one empty unlabeled recess and enlarged material sample.
9. `thirteenfold_player_scale.png` — Night Warden proportion, main/off-hand length and grip validation.
10. `thirteenfold_combat_pose.png` — side-scrolling ready, simultaneous thrust and dash-thrust posture reference.
11. `thirteenfold_reforging_sequence.png` — broken crozier/thurible to finished dual blades in four beats.
12. `thirteenfold_reliquary_concept.png` — low, Player-readable Reliquary of the Last Absolution with two candles and empty seat.

## W2 handoff constraints

- The main/off-hand length relationship, guards, grips and material boundaries must survive at gameplay pixel scale.
- Player visuals must keep Absolution in the forward/main hand and Penance in the shorter reverse/off-hand role.
- `attack_1`, `attack_2`, `attack_3` and `dash_attack` remain thrust-focused. No wide slash VFX or extra gameplay range is inferred from the concept art.
- Every animation must use the same blade lengths; neither weapon may collapse into a single metal line or flash back to Crimson Masque.
- The ring guard should be simplified into a readable hollow oval with grouped seal pixels; it must not be enlarged until it blocks the hand or torso.
- Penance's fixed ring is a silhouette cue, not a simulated chain.
- The reliquary must remain below the Player chest, use a front-safe draw layer and preserve full Player visibility.

## Generation provenance and prompt set

The twelve raster concepts were created specifically for this project with the built-in image-generation workflow. No third-party asset, commercial-game image or provenance-unknown source was imported.

The shared prompt set locked:

- polished original gothic game production concept art;
- exact pair continuity from the accepted master image;
- bone-white/cold-silver blades, black-iron bevels, aged copper, dark-red grooves and black leather;
- an oval hollow-bell main guard with thirteen extinguished seals plus one unlabeled empty socket;
- a perforated thurible off-hand guard with one fixed ring;
- no real-world religion, text, labels, UI, watermark, oversized fantasy weapons or ordinary recolored daggers;
- Night Warden identity preserved from the repository concept-art master;
- Edran relic continuity preserved from the repository equipment board.

Asset-specific prompts requested strict front/side orthographic views, solid silhouette comparison, exploded guard construction, exact seal array, Player scale, simultaneous dual-thrust poses, a four-beat relic reforging sequence and a low compact reliquary. The built-in tool outputs were copied into the Chapter III asset tree; originals remain in the Codex generated-image store per tool policy.
