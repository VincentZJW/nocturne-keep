# Chapter II first-pass environment art specification

Status: playable procedural/native-2D first pass; final pixel tiles and independent painted concept sheets remain future art work.

## Floor identities

- F1 Public Court: coarse blue-grey masonry, gate arches, grey guard banners, weapon silhouettes, compact armory, timber banquet tables and a monumental stone stair.
- F2 Noble/Chapel: oxidized portrait frames, red chapel arches/candles, altar massing and a narrow servant passage. Layout height and props distinguish it from F1 even with the shared native-2D renderer.
- F3 Ritual/Ballroom: purple-black wall panels, mirror frames, moonlit medallions, ceremonial trim and the existing Ballroom FX/Boss presentation.

## Asset ownership

- Concept reference folder: `res://chapters/chapter_02_silent_court/assets/environment/concept_art/`.
- Floor 1 art folder: `res://chapters/chapter_02_silent_court/assets/environment/floor_01_public_court/`.
- Floor 2 art folder: `res://chapters/chapter_02_silent_court/assets/environment/floor_02_noble_chapel/`.
- Floor 3 art folder: `res://chapters/chapter_02_silent_court/assets/environment/floor_03_silent_ballroom/`.

The current implementation uses editable Godot native 2D drawing and original project-owned pixel assets. No downloaded or provenance-unknown art is introduced. Empty floor folders are not claimed as finished concept art; their README files document intended replacement slots.

## Readability rules

- Full ground fill and masonry remain behind actors.
- Only a three-pixel surface lip is in front at z=20.
- Each stair uses a narrow structural beam behind actors plus an independently drawn edge/tread treatment; there is no large high-z triangular fill that can cover actors.
- Props never occupy the combat warning layer, and Boss-room ground remains flat.
- Texture filtering, mipmaps and external scaling are unchanged; actors retain nearest-neighbor presentation.
