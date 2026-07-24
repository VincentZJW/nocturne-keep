# Currency System Specification

`CurrencyManager` is the autoload instance of typed `CurrencyWallet`. It owns `current_coins`, add, spend, affordability, new-run reset and debug setup. Coins never become negative; a failed spend changes nothing.

The wallet persists across Player death and scene changes. `ChapterSession.reset_revival_state()` resets it for a new run. Debug-only `debug_reset_wallet()` and `debug_grant_test_coins()` support deterministic QA. `RunInventoryHud` observes `coins_changed`; Main and the threshold scene do not poll or own the amount. Store UI and save-file persistence remain outside this version.
