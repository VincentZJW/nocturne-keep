# Catacomb Revival Dialogue

Data resources:

- `res://resources/dialogue/catacomb_revival_monologue_zh.tres`
- `res://resources/dialogue/catacomb_revival_monologue_en.tres`
- `res://resources/dialogue/catacomb_revival_dialogue_zh.tres`
- `res://resources/dialogue/catacomb_revival_dialogue_en.tres`

The two aligned localized tracks contain speaker, line, presentation cue and automatic duration per entry. The monologue contains the required three protagonist lines; the main conversation contains all 27 required Candle Warden/protagonist exchanges from “Seven years.” through “learn how to live again.” Runtime verifies matching lengths before starting and displays both languages in the bottom subtitle panel.

Confirm input advances one entry without changing data order. Automatic timers preserve authored pauses. Holding Escape or Enter completes the entire sequence, hides the subtitle, records `revival_completed`, enables move-only control and leaves dagger/door prerequisites playable. Dialogue is not reconstructed as an if-chain and is not replayed by Player checkpoint death.
