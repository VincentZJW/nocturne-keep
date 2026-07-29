# Chapter I Sprite Quality and QA Specification

## Acceptance gates

1. Six roles have concept sheet, silhouette, action reference and effect reference.
2. Five ordinary roles use 64×64 formal frames; the Fallen Gate Knight uses 128×96 formal body/weapon frames so the guard-longsword can remain complete without scaling the body. Shield overlays remain 96×96.
3. Formal runtime total is 271 frames; archived v1 total is 290 PNGs.
4. Every frame has alpha, stable canvas size, deliberate non-transparent mass and at least a role-appropriate limited material palette.
5. Runtime `SpriteFrames` may only reference `assets/.../<role>/sprites/` or the new Chapter I effect folders—never `reference/deprecated_v1`.
6. MainBootstrap must load Chapter I and show all five ordinary roles plus the Boss with the formal frames.
7. Review evidence must include concept/old/new boards, formal sprite previews, actual Main idle/action captures and Boss phase evidence.

## Visual review checklist

- Silhouette remains identifiable at 48×48 nearest-neighbour reduction.
- Head, torso, limbs and weapon do not collapse into one block.
- Weapon direction matches hitbox direction and facing flip.
- Windup, active and recovery are visually separable.
- Hurt is not confused with death; Boss phase transition is not confused with hurt.
- Metal, cloth, leather, wood/stone and curse accents retain separate value bands.
- Player remains the fastest, darkest and most compact figure in mixed encounters.

## Status vocabulary

- **PASS:** formal resource is used in Main, automatic checks pass, and screenshot evidence is readable.
- **PARTIAL:** functional and integrated, but a named visual issue still needs manual art polish.
- **FAIL:** runtime still points to v1/archive, required role or action is absent, or Main cannot be validated.
