class_name RenderLayerContract
extends RefCounted

## Shared world-space draw-order contract. CanvasLayer UI is intentionally
## outside this z-index table.

const FAR_BACKGROUND: int = -100
const BACKGROUND_ARCHITECTURE: int = -60
const PROPS_BEHIND_ACTORS: int = -30
const GROUND_VISUAL: int = -10
const PLATFORMS: int = 0
const ENEMIES: int = 10
const NPCS: int = 11
const PLAYER: int = 12
const DROPS: int = 13
const INTERACTABLES: int = 14
const COMBAT_FX: int = 16
const LIMITED_FOREGROUND: int = 20
