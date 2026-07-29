# Chapter I Enemy Art Bible

## Narrative and visual target

Chapter I moves from a desecrated roadside watch, through a damp black forest, to Ravenmourn's military gate. Its enemies are not generic dark silhouettes: they are the remains of a recognizable western-medieval garrison, corroded by exposure and curse-light. The roster shares cold iron, weathered leather, rust and restrained red/blue supernatural accents, while every role keeps a distinct silhouette and weapon line.

## Shared production rules

- Standard enemy canvas: 64×64 RGBA PNG; Fallen Gate Knight body/weapon canvas: 128×96 RGBA PNG, with 96×96 shield overlays.
- Transparent background, nearest-neighbour display, stable foot anchor and right-facing source art.
- Outline masses use near-black blue, not featureless pure black. Metal separates into shadow, midtone and edge light.
- Attack readability comes from body weight and weapon direction. Effects support the contact point and never replace the weapon silhouette.
- Archived v1 frames live under each role's `reference/deprecated_v1/` folder and are forbidden in runtime resources.

## Roster identities

| Role | Silhouette | Material / color identity | Gameplay read |
|---|---|---|---|
| Castle Guard | compact closed helm, one-handed sword, broken tabard | worn iron, wine cloth, rust | baseline heavy infantry |
| Cursed Shield Guard | broad shoulders, large battered heater shield | layered plate, bruised red cloth, amber curse cracks | frontal defense / break state |
| Decayed Spearman | tall narrow helm, long horizontal spear | mail, dark leather, oxidized spearhead | reach threat |
| Fallen Crossbowman | light hooded armor, crossbow stock and rear quiver | leather, blue-grey steel, pale bolt line | ranged aim / reload |
| Gargoyle Sentinel | stone wings, horned head, hooked claws | cool masonry stone, moss, moon-blue seams | dormant-to-aerial threat |

## Animation phase language

The existing gameplay contracts are preserved. Ordinary melee enemies keep windup, active and recovery poses inside their existing attack animations: Guard `attack_01–02 / 03–04 / 05`; Spearman `attack_thrust_01–03 / 04–05 / 06`. Crossbowman separates `aim`, `shoot` and `reload`. Gargoyle separates `wake`, `dive_windup`, `dive`, `ground_stun` and `return_to_air`. This preserves combat timing while giving every phase purpose-built art.

## Runtime integration

The Chapter I level instances `first_level_encounters.tscn`, which in turn instances all five ordinary enemy scenes. Those scenes retain their gameplay scripts and now resolve their `AnimatedSprite2D` frames to Chapter I formal `sprites/` folders. No combat values, collision geometry, AI timings or drop tables were changed by this art milestone.
