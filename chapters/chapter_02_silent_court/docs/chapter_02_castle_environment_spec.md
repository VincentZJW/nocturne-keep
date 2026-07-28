# Chapter II formal castle environment specification

Status: implemented in the saved Main route, 2026-07-28

## Visual language

The Silent Court now uses an original, reusable 16-bit-inspired castle kit instead of room-specific debug line drawings. The palette keeps the existing navy masonry and introduces desaturated iron, oxidized burgundy, muted royal gold, pale candlelight and cold portrait skin tones. Shapes stay rectilinear and nearest-neighbour readable; decoration remains behind actors and collision silhouettes are unchanged.

The source images are deterministically authored by `scripts/tools/generate_chapter_02_castle_assets.gd` with Godot `Image` operations. No downloaded or provenance-unknown art is used.

## Asset families

- `assets/weapons/crimson_masque_stilettos/`: separate world, pedestal, pickup and inventory presentations. Every version has a dark wrapped grip, gold crossguard, pale-steel tapered blade and distinct point; the two weapons remain offset when crossed. The saved Armory, reliquary, pickup scene and `WeaponData` each reference the corresponding formal asset rather than merely storing unused files.
- `assets/portraits/`: six inhabited royal portraits with faces, hair, garments and individual court identities. Gallery repetition may reuse them, but an empty rectangle is never treated as finished portrait art.
- `assets/doors/`: Armory iron door, Ballroom double door, Royal corridor door, stone arch and Blood Candle Chapel arch.
- `assets/environment/architecture/`: reusable stone pillar and wall niche.
- `assets/props/`: armour, racks, shield, banquet furniture, benches, crates, barrels, banners, bookshelf, altar, candelabra and crest.
- `assets/fx/`: a three-frame candle flame used by the timer-driven wall-sconce scene.

All PNGs use transparent backgrounds where appropriate, lossless import, no mipmaps and nearest-neighbour filtering through the project's pixel-art defaults.

## Saved room composition

| Saved room | Formal identity |
| --- | --- |
| Old Armory Safe Room | four stone niches, formal crossed stilettos, sword/spear racks, shield, armour, crates and iron door |
| Last Banquet Hall | pillars, torn drapes, long tables, benches, barrels, floor candelabra and abandoned place settings |
| Royal Portrait Gallery | eight framed placements using six actual royal subjects, crest, corridor doors, pillars and sconces |
| Blood Candle Chapel | full masonry arches and doors, altar, armour, benches, blood-red banners and candle groupings |
| Silent Ballroom Antechamber | approach pillars, banners, armour, crest, candelabra and formal threshold staging |
| Silent Ballroom | restrained pillars, framed drapes, crest, sconces and exit architecture behind the actors/Ballroom FX |

Each saved room sets `use_legacy_identity = false`; the previous debug-only crossed lines, empty portraits and thin arc identities remain available only as an explicit fallback in `chapter_02_room_graybox.gd`.

## Boss threshold and staging

`DuchessBossEntrance` emits a typed request instead of opening on proximity. `DuchessBossThresholdTransition` owns a 0.24-second fade-out, a 0.10-second fully black relocation, a 0.24-second fade-in and the hand-off to `HollowDuchessRoomController`. Player input and facing are locked, velocity is cleared, temporary invulnerability is applied, and the Camera floor limits are configured before the image returns.

The first entry then reuses the existing five-line `DuchessEncounterPresentation`, followed by the bilingual title and combat. `intro_seen` preserves the 1.25-second retry presentation after a Player death; no duplicate dialogue system was introduced. Exterior threshold armour and door art hide after the door opens, so they cannot cover the Player inside the Ballroom.

## Performance contract

- Generated textures are imported when the Chapter scene loads; no synchronous file loading occurs during either floor transition or the Boss threshold.
- The reusable wall sconce is timer-driven and its animated sprites pause when off-screen.
- Saved room art is composed from Sprite2D nodes; no per-frame procedural room drawing or node recreation was added.
- Existing incremental encounter retirement and threaded chapter transition behavior remains unchanged.
- The post-integration Stage A benchmark produced no wall-clock frame above 25 ms; the observed maximum was 18.757 ms during the Phase transition.

## Acceptance evidence

The authoritative graphical evidence is under `docs/qa/chapter_02_castle_polish/`. It contains 19 MainBootstrap captures covering all six rooms, both floor transitions, the complete Boss threshold/dialogue/title/combat sequence and the post-defeat formal reliquary display. Automated checks prove asset presence, all four weapon contexts, saved scene composition and transition staging; human F5 play must still judge final atmosphere, prop density and combat readability.
