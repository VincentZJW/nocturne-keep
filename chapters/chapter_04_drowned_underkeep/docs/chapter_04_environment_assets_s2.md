# Chapter IV S2 Formal Environment Asset Delivery

## Scope and result

CH4-S2 delivers the chapter-owned pixel asset kit required by the locked 17-area route. It does not assemble rooms, add collision, place encounters, change water gameplay, or alter the Main route. The deterministic catalog contains **297 original RGBA8 PNG assets**: 228 P0, 60 P1 and 9 P2.

All pixels were drawn through Godot 4.7.1 `Image` operations on a 16 px detail / 32 px architecture grid. No third-party or provenance-unknown asset is used, and S1 concept boards remain art-direction references rather than runtime textures.

## Delivered packages

| Package | Files | Purpose |
|---|---:|---|
| Doors | 21 | Cell, isolation, floodgate and soul-lock frame/panel/core states |
| Environment | 110 | Walls, floors, cells, platforms, catwalks, cistern, floodgate, Boss and memory architecture |
| FX | 95 | Split water, ripples, drips, chain motion, soul fire/cages and floodgate events |
| Props | 71 | Bars, chains, keys, records, drainage, storage, restraint tools, remains and soul cages |

Authoritative machine-readable inventory:

`res://chapters/chapter_04_drowned_underkeep/resources/environment/chapter_04_environment_asset_catalog_s2.json`

## Runtime-ready animation resources

`chapter_04_water_fx_frames.tres` packages 10 animations:

- rear water, local highlight, front lip, flow strip and drain foam;
- step ripple, landing splash, Dash splash, enemy wake and idle ripple.

`chapter_04_environment_motion_frames.tres` packages 15 animations:

- waterwheel, gear train, rear chain sway, drip and soul flame;
- contained/strained/cracked/released soul cage states;
- memory water, Boss gate seal and four floodgate event effects.

Looping and one-shot behavior is encoded in the resources. S3 scene consumers must set their `CanvasItem.texture_filter` to `NEAREST` and use integer positions/scales.

## Layer and assembly contract for S3

- Rear water body is 64 px high and remains behind actors.
- Local water highlight is a separate 16 px band.
- Front water lip is a separate 4 px maximum occlusion layer; it may cover feet only.
- Formal walkable ledges have continuous bright top edges and supported undersides. Broken decorative ledges do not.
- Doors are assembled from rear frame, moving panel, narrow trim/core and separate collision authority; a complete door sprite must never become one foreground occluder.
- Soul cage bodies remain behind actors. Cyan soul FX may move forward only when serving a gameplay telegraph.
- Boss architecture preserves a broad flat centre. Memory assets only tease the reflected royal corridor and do not implement Chapter V.

## Production and regeneration

Generate source PNGs:

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tools/generate_chapter_04_environment_assets_s2.gd
```

Import, then build SpriteFrames:

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --import
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tools/build_chapter_04_environment_resources_s2.gd
```

Generate the five QA boards:

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tools/generate_chapter_04_environment_s2_qa.gd
```

## S2 stop point

The assets are ready for review and later CH4-S3 room assembly. No formal room, collision, EncounterGroup, enemy placement, chapter transition or Main/F5 route change is part of this delivery.
