# Currency System Specification

`CurrencyManager` is the autoload instance of typed `CurrencyWallet`. It owns `current_coins`, add, spend, affordability, new-run reset and debug setup. Coins never become negative; a failed spend changes nothing.

The wallet persists across Player death and scene changes. `ChapterSession.reset_revival_state()` resets it for a new run. Debug-only `debug_reset_wallet()` and `debug_grant_test_coins()` support deterministic QA. `RunInventoryHud` observes `coins_changed`; Main and the threshold scene do not poll or own the amount. Store UI and save-file persistence remain outside this version.

Normal-enemy coin outcome probability is owned by the shared dynamic loot profile: Full/Light/Heavy/Critical Health use 72%/50%/35%/20%. This changes only whether a coin pickup is selected. Existing per-enemy quantities (Guard 1–2, Shield 2–4, Spear 2–3, Crossbow 2–3, Gargoyle 2–4), wallet behavior and the Boss's fixed 30-coin reward are unchanged. Environment deaths use half of the selected tier's coin probability and never produce healing.
