# Chapter I Story Specification

## Flow

1. Eight-shot opening cinematic.
2. The protagonist is drawn back into the preserved body on the Severed Altar.
3. The Candle Warden reveals the seven-year interval and orders the Veilbound toward Ravenmourn.
4. The player regains move-only control, recovers the paired daggers, and voluntarily crosses the catacomb threshold.
5. Main loads at `World/DarkForestTutorialSpawn`; the embedded tutorial gradually gives control vocabulary.
6. Visual remains of the Veiled Order connect the road to the failed expedition.
7. Forest, outskirts, and castle approach escalate enemy combinations.
8. Fallen Gate Knight guards the bridge and recognizes the protagonist at death.
9. The weighted gate opens; the player crosses a text-free threshold into the castle.

The catacomb revival is a new-game narrative event only. Later Health deaths retain the existing fast body/ghost/checkpoint sequence and never reload the dialogue.

## Required spoken text

The Boss has one line only:

> 钟……认得你。  
> The bell… remembers you.

It appears once on lethal damage, before the existing death presentation and gate flow finish. It resets only if the Boss room resets after player death. There is no “Chapter Complete”, “Gate Open”, or next-level title.

## Environmental beats

- Fallen Order cloak and paired daggers near the tutorial route.
- Warning post with broken occult marks.
- Empty armor with a cursed eye slit.
- Spearman remains and abandoned weapon.
- Cold campfire and broken field shelter.
- Soul Mark fragments close to the castle approach.
- Crows repeatedly frame the route toward Ravenmourn.

These are `CanvasItem` presentation only and own no `CollisionObject2D`.
