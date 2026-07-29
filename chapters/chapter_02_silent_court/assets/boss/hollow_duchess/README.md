# Hollow Duchess asset provenance and runtime contract

Stage 2 (2026-07-29) replaces the former geometric runtime set with original project-owned art:

- The concept PNGs under `concept_art/` were produced for this project with OpenAI's built-in image-generation tool, then selected and cropped into the dedicated Phase 1, Unmasked Phase 2, weapon, mask and pose studies. They do not trace or reuse commercial-game characters.
- Every runtime frame is deterministic pixel art authored by the project script `res://chapters/chapter_02_silent_court/scripts/tools/generate_hollow_duchess_art_v2.gd` and indexed by `build_hollow_duchess_sprite_frames_v2.gd`.
- Superseded Stage 1 runtime art is preserved in `reference/deprecated_stage1/hollow_duchess_stage1_runtime_art.tar.gz`; no formal scene references that archive.

Runtime contract:

- Production frame canvas: 96×96 RGBA8 with a transparent background.
- Phase 1: 143 frames across the compatibility and expanded presentation families under `phase_01/`.
- Phase 2: 180 frames across compatibility and explicit Unmasked presentation families under `phase_02_unmasked/`.
- Transformation: 39 frames, including the 10-frame runtime `phase_transition`, under `phase_transition/`.
- Rendering: nearest-neighbour, no mipmaps, integer-scale review.
- Direction: source art faces right; `AnimatedSprite2D.flip_h` provides left-facing presentation.
- Authoritative SpriteFrames are the `.tres` files inside each phase directory. The older `animations/hollow_duchess_sprite_frames.tres` is retained only as a non-runtime reference.
